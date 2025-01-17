FROM amazonlinux:latest

ENV NODE_VERSION v11.13.0
ENV YARN_VERSION 1.15.2
ENV USER node
ENV GROUP node
ENV HOME /home/${USER}
ENV NPM_PACKAGES=${HOME}/npm-packages
ENV PATH ${HOME}/bin:${NPM_PACKAGES}/bin:$HOME/yarn-v$YARN_VERSION/bin:$PATH
ENV NODE_PATH $NPM_PACKAGES/lib/node_modules:$NODE_PATH

RUN yum -y update && \
    yum -y install shadow-utils gcc44 gcc-c++ libgcc44 cmake curl tar gzip make xz python2-pip && \
    mkdir -p /home && \
    groupadd -g 1000 "$GROUP" && \
    adduser -g 1000 -u 1000 -s /bin/false -d "$HOME" "$USER" && \
    mkdir -p /app  "$HOME/yarn" /drone && \
    echo "prefix = $NPM_PACKAGES" >> "$HOME/.npmrc" && \
    cd /usr/src && \
    for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
        B9E2F5981AA6E0CD28160D9FF13993A75599653C \
        ; \
    do \
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done && \
    curl -fsSLO --compressed "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.xz" && \
    curl -fsSLO --compressed "https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc" && \
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
    grep "node-${NODE_VERSION}.tar.xz\$" SHASUMS256.txt | sha256sum -c -  \
    && tar -xf "node-${NODE_VERSION}.tar.xz" && \
    cd "node-${NODE_VERSION}" && \
    ./configure && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    cd /usr/src && \
    rm -rf "node-${NODE_VERSION}" "node-${NODE_VERSION}.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt && \
    for key in \
        6A010C5166006599AA17F08146C2130DFD2497F5 \
    ; \
    do \
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done && \
    curl -fsSLO --compressed "https://yarnpkg.com/downloads/${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz" && \
    curl -fsSLO --compressed "https://yarnpkg.com/downloads/${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz.asc" && \
    gpg --batch --verify yarn-v${YARN_VERSION}.tar.gz.asc yarn-v${YARN_VERSION}.tar.gz && \
    tar -xzf yarn-v$YARN_VERSION.tar.gz -C "${HOME}/" && \
    ln -s $HOME/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn && \
    ln -s $HOME/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && \
    rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz && \
    pip install PyPDF2 && \
    yum -y remove shadow-utils gcc44 gcc-c++ libgcc44 cmake tar gzip make xz && \
    yum -y clean all && \
    chown -R "$USER":"$GROUP" "$HOME" /app /usr/src /drone

WORKDIR /app
CMD [ "node" ]
