FROM python:2-alpine

# the client version we will download from bumpx repo
ENV CLIENT_FILENAME instantclient-basiclite-linux.x64-11.2.0.4.0.zip

# work in this directory
WORKDIR /opt/ora

# take advantage of this repo to easily download the client (use it at your own risk)
ADD ./misc/${CLIENT_FILENAME} .

# we need libaio and libnsl, the latter is only available as package in the edge repository
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --update libaio libnsl unzip build-base && \
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1 && \
    unzip ${CLIENT_FILENAME} && \
    mkdir /etc/ld.so.conf.d && \
    echo /opt/ora/instantclient_11_2 > /etc/ld.so.conf.d/oracle.conf && \
    rm -rf ${CLIENT_FILENAME}    

ENV ORACLE_HOME /opt/ora/instantclient_11_2 
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ORACLE_HOME}

WORKDIR /opt/ora/instantclient_11_2
RUN ln -s libclntsh.so.11.1 libclntsh.so

ADD ./requirements.txt .

RUN pip install --no-cache -r ./requirements.txt
