From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 0/2] kproxy: Kernel Proxy
Date: Thu, 29 Jun 2017 11:27:03 -0700
Message-ID: <1498760825-8516-1-git-send-email-tom@herbertland.com>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35282 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdF2S1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:27:43 -0400
Received: by mail-pg0-f68.google.com with SMTP id f127so12803683pgc.2
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 11:27:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is raw, minimally tested, and error hanlding needs work. Posting
as RFC to get feedback on the design...

Sidecar proxies are becoming quite popular on server as a means to
perform layer 7 processing on application data as it is sent. Such
sidecars are used for SSL proxies, application firewalls, and L7
load balancers. While these proxies provide nice functionality,
their performance is obviously terrible since all the data needs
to take an extra hop though userspace.

Consider transmitting data on a TCP socket that goes through a
sidecar paroxy. The application does a sendmsg in userpsace, data
goes into kernel, back to userspace, and back to kernel. That is two
trips through TCP TX, one TCP RX, potentially three copies, three
sockets are touched, and three context switches. Using a proxy in the
receive path would have a similarly long path.

	 +--------------+      +------------------+
	 |  Application |      | Proxy            |
	 |              |      |                  |
	 |  sendmsg     |      | recvmsg sendmsg  |
	 +--------------+      +------------------+
	       |                    |       |
               |                    ^       |
---------------V--------------------|-------|--------------
	       |                    |       |
	       +---->--------->-----+       V
            TCP TX              TCP RX    TCP TX
  
The "boomerang" model this employs is quite expensive. This is
even much worse in the case that the proxy is an SSL proxy (e.g.
performing SSL inspection to implement and application firewall).
In this case The application encrypts using TLS, the proxy
immediately decrypts (it knows the key by virtue of have pretended
to be a certificate authority). Subsequently, the proxy re-encrpyts
it again to send. So each byte undergoes three crypto operations in
this path!


This patch set creates and in kernel proxy (kproxy). The concept is
fairly straightforward, two sockets are joined in the kernel as
a proxy. Proxy functionality will be done by BPF on the data stream,
kTLS is needed to make an SSL proxy. The most prominent ULP for a proxy
is http so we'll need a parser for http to make an in kernel http
proxy.

	 +--------------+
	 |  Application |
	 |              |
	 |  sendmsg     |
	 +--------------+
	       |
               |
---------------V-------------------------------------------
               |
	       |        +---------------+
               +------->|   Proxy       |---+
			| strparser+BPF |   |
			+---------------+   |
            TCP TX   TCP RX                 |
					    V
					 TCP TX

This patch set implements a very rudimentary kernel proxy, it just
provides an interface to create a proxy between two sockets. Once the
RX and TX paths are done for kTLS it should be straightforward to enable
to make an in kernel SSL proxy. Proxy functionality (like application
level filtering) will be implemented by BPF programs set on the kproxy.
This will use strparser to provide message deliniation (we'll need a
slight mofication to strparse to allow pass through mode). In kernel
layer 7 load balancing is also feasible, in that case we may want to
use a multiplexor structure like KCM (I had consider overloading KCM
for kproxy but decided they are too different.

kproxy eliminates the userspace boomerang, but you may notice that even
with kproxy we still have same number of sockets and sill potentially
perform three crypto ops on every byte. I have some ideas for how to
create a "zero proxy" that eliminates these without loss of the proxy
functionality. That would be the subject of a future path set.

Tom Herbert (2):
  skbuff: Function to send an skbuf on a socket
  kproxy: Kernel proxy

 include/linux/skbuff.h              |   2 +
 include/linux/socket.h              |   4 +-
 include/net/kproxy.h                |  80 +++++
 include/uapi/linux/kproxy.h         |  30 ++
 net/Kconfig                         |   1 +
 net/Makefile                        |   1 +
 net/core/skbuff.c                   |  66 ++++
 net/kproxy/Kconfig                  |  10 +
 net/kproxy/Makefile                 |   3 +
 net/kproxy/kproxyproc.c             | 246 +++++++++++++++
 net/kproxy/kproxysock.c             | 605 ++++++++++++++++++++++++++++++++++++
 security/selinux/hooks.c            |   4 +-
 security/selinux/include/classmap.h |   4 +-
 13 files changed, 1053 insertions(+), 3 deletions(-)
 create mode 100644 include/net/kproxy.h
 create mode 100644 include/uapi/linux/kproxy.h
 create mode 100644 net/kproxy/Kconfig
 create mode 100644 net/kproxy/Makefile
 create mode 100644 net/kproxy/kproxyproc.c
 create mode 100644 net/kproxy/kproxysock.c

-- 
2.7.4
