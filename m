From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH v2 net-next 0/4] kernel TLS
Date: Tue, 6 Jun 2017 09:59:50 -0700
Message-ID: <20170606165950.GA19036@davejwatson-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds support for kernel TLS encryption over TCP sockets.
A standard TCP socket is converted to a TLS socket using a setsockopt.
Only symmetric crypto is done in the kernel, as well as TLS record
framing.  The handshake remains in userspace, and the negotiated
cipher keys/iv are provided to the TCP socket.

We implemented support for this API in OpenSSL 1.1.0, the code is
available at https://github.com/Mellanox/tls-openssl/tree/master

It should work with any TLS library with similar modifications,
a test tool using gnutls is here: https://github.com/Mellanox/tls-af_ktls_tool

Changes from V1:

* EXPORT_SYMBOL GPL in patch 2
* Add link to OpenSSL patch & gnutls example in documentation patch.
* sk_write_pending check was rolled in to wait_for_memory path,
  avoids special case and fixes lock inbalance issue.
* Unify flag handling for sendmsg/sendfile

Changes from RFC V2:

* Generic ULP (upper layer protocol) framework instead of TLS specific
  setsockopts
* Dropped Mellanox hardware patches, will come as separate series.
  Framework will work for both.

RFC V2:

http://www.mail-archive.com/netdev@vger.kernel.org/msg160317.html

Changes from RFC V1:

* Socket based on changing TCP proto_ops instead of crypto framework
* Merged code with Mellanox's hardware tls offload
* Zerocopy sendmsg support added - sendpage/sendfile is no longer
  necessary for zerocopy optimization

RFC V1:

http://www.mail-archive.com/netdev@vger.kernel.org/msg88021.html

* Socket based on crypto userspace API framework, required two
  sockets in userspace, one encrypted, one unencrypted.

Paper: https://netdevconf.org/1.2/papers/ktls.pdf

Aviad Yehezkel (1):
  tcp: export do_tcp_sendpages and tcp_rate_check_app_limited functions

Boris Pismenny (2):
  tcp: ULP infrastructure
  tls: Documentation

Ilya Lesokhin (1):
  tls: kernel TLS support

 Documentation/networking/tls.txt   | 135 +++++++
 MAINTAINERS                        |  10 +
 include/linux/socket.h             |   1 +
 include/net/inet_connection_sock.h |   4 +
 include/net/tcp.h                  |  27 ++
 include/net/tls.h                  | 222 +++++++++++
 include/uapi/linux/tcp.h           |   1 +
 include/uapi/linux/tls.h           |  79 ++++
 net/Kconfig                        |   1 +
 net/Makefile                       |   1 +
 net/ipv4/Makefile                  |   2 +-
 net/ipv4/sysctl_net_ipv4.c         |  25 ++
 net/ipv4/tcp.c                     |  33 +-
 net/ipv4/tcp_ipv4.c                |   2 +
 net/ipv4/tcp_rate.c                |   1 +
 net/ipv4/tcp_ulp.c                 | 134 +++++++
 net/tls/Kconfig                    |  12 +
 net/tls/Makefile                   |   7 +
 net/tls/tls_main.c                 | 485 ++++++++++++++++++++++
 net/tls/tls_sw.c                   | 794 +++++++++++++++++++++++++++++++++++++
 20 files changed, 1973 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/networking/tls.txt
 create mode 100644 include/net/tls.h
 create mode 100644 include/uapi/linux/tls.h
 create mode 100644 net/ipv4/tcp_ulp.c
 create mode 100644 net/tls/Kconfig
 create mode 100644 net/tls/Makefile
 create mode 100644 net/tls/tls_main.c
 create mode 100644 net/tls/tls_sw.c

-- 
2.9.3
