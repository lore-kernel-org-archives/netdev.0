From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] inet: add IP_BIND_ADDRESS_NO_PORT to overcome
 bind(0) limitations
Date: Sat, 06 Jun 2015 21:17:57 -0700
Message-ID: <1433650677.29864.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f195.google.com ([209.85.223.195]:33907 "EHLO
	mail-ie0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbFGESA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 00:18:00 -0400
Received: by iebtr6 with SMTP id tr6so5400566ieb.1
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 21:17:59 -0700 (PDT)
In-Reply-To: <CADVnQy=qbyTUdCPvDv8UbcuXJAsNhQVSiJCo83e9k8s8OWOF8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When an application needs to force a source IP on an active TCP socket
it has to use bind(IP, port=x).

As most applications do not want to deal with already used ports, x is
often set to 0, meaning the kernel is in charge to find an available
port.
But kernel does not know yet if this socket is going to be a listener or
be connected.
It has very limited choices (no full knowledge of final 4-tuple for a
connect())

With limited ephemeral port range (about 32K ports), it is very easy to
fill the space.

This patch adds a new SOL_IP socket option, asking kernel to ignore
the 0 port provided by application in bind(IP, port=0) and only
remember the given IP address.

The port will be automatically chosen at connect() time, in a way
that allows sharing a source port as long as the 4-tuples are unique.

This new feature is available for both IPv4 and IPv6 (Thanks Neal)

Tested:

Wrote a test program and checked its behavior on IPv4 and IPv6.

strace(1) shows sequences of bind(IP=127.0.0.2, port=0) followed by
connect().
Also getsockname() show that the port is still 0 right after bind()
but properly allocated after connect().

socket(PF_INET, SOCK_STREAM, IPPROTO_IP) = 5
setsockopt(5, SOL_IP, IP_BIND_ADDRESS_NO_PORT, [1], 4) = 0
bind(5, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.2")}, 16) = 0
getsockname(5, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("127.0.0.2")}, [16]) = 0
connect(5, {sa_family=AF_INET, sin_port=htons(53174), sin_addr=inet_addr("127.0.0.3")}, 16) = 0
getsockname(5, {sa_family=AF_INET, sin_port=htons(38050), sin_addr=inet_addr("127.0.0.2")}, [16]) = 0

IPv6 test :

socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 7
setsockopt(7, SOL_IP, IP_BIND_ADDRESS_NO_PORT, [1], 4) = 0
bind(7, {sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
getsockname(7, {sa_family=AF_INET6, sin6_port=htons(0), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0
connect(7, {sa_family=AF_INET6, sin6_port=htons(57300), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
getsockname(7, {sa_family=AF_INET6, sin6_port=htons(60964), inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0

I was able to bind()/connect() a million concurrent IPv4 sockets,
instead of ~32000 before patch.

lpaa23:~# ulimit -n 1000010
lpaa23:~# ./bind --connect --num-flows=1000000 &
1000000 sockets

lpaa23:~# grep TCP /proc/net/sockstat
TCP: inuse 2000063 orphan 0 tw 47 alloc 2000157 mem 66

Check that a given source port is indeed used by many different
connections :

lpaa23:~# ss -t src :40000 | head -10
State      Recv-Q Send-Q   Local Address:Port          Peer Address:Port
ESTAB      0      0           127.0.0.2:40000         127.0.202.33:44983
ESTAB      0      0           127.0.0.2:40000         127.2.27.240:44983
ESTAB      0      0           127.0.0.2:40000           127.2.98.5:44983
ESTAB      0      0           127.0.0.2:40000        127.0.124.196:44983
ESTAB      0      0           127.0.0.2:40000         127.2.139.38:44983
ESTAB      0      0           127.0.0.2:40000          127.1.59.80:44983
ESTAB      0      0           127.0.0.2:40000          127.3.6.228:44983
ESTAB      0      0           127.0.0.2:40000          127.0.38.53:44983
ESTAB      0      0           127.0.0.2:40000         127.1.197.10:44983

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: really implements IPv6 part, thanks Neal !

 include/net/inet_sock.h |    1 +
 include/uapi/linux/in.h |    1 +
 net/ipv4/af_inet.c      |    3 ++-
 net/ipv4/ip_sockglue.c  |    7 +++++++
 net/ipv6/af_inet6.c     |    3 ++-
 5 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b6c3737da4e9..47eb67b08abd 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -187,6 +187,7 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	__u8			bind_address_no_port:1;
 	__u8			rcv_tos;
 	__u8			convert_csum;
 	int			uc_index;
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 641338bef651..83d6236a2f08 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -112,6 +112,7 @@ struct in_addr {
 #define IP_MINTTL       21
 #define IP_NODEFRAG     22
 #define IP_CHECKSUM	23
+#define IP_BIND_ADDRESS_NO_PORT	24
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 6ad0f7a711c9..cc858ef44451 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -488,7 +488,8 @@ int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		inet->inet_saddr = 0;  /* Use device */
 
 	/* Make sure we are allowed to bind here. */
-	if (sk->sk_prot->get_port(sk, snum)) {
+	if ((snum || !inet->bind_address_no_port) &&
+	    sk->sk_prot->get_port(sk, snum)) {
 		inet->inet_saddr = inet->inet_rcv_saddr = 0;
 		err = -EADDRINUSE;
 		goto out_release_sock;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 7cfb0893f263..04ae2992a5cd 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -582,6 +582,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_TRANSPARENT:
 	case IP_MINTTL:
 	case IP_NODEFRAG:
+	case IP_BIND_ADDRESS_NO_PORT:
 	case IP_UNICAST_IF:
 	case IP_MULTICAST_TTL:
 	case IP_MULTICAST_ALL:
@@ -732,6 +733,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		inet->nodefrag = val ? 1 : 0;
 		break;
+	case IP_BIND_ADDRESS_NO_PORT:
+		inet->bind_address_no_port = val ? 1 : 0;
+		break;
 	case IP_MTU_DISCOVER:
 		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_OMIT)
 			goto e_inval;
@@ -1324,6 +1328,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_NODEFRAG:
 		val = inet->nodefrag;
 		break;
+	case IP_BIND_ADDRESS_NO_PORT:
+		val = inet->bind_address_no_port;
+		break;
 	case IP_MTU_DISCOVER:
 		val = inet->pmtudisc;
 		break;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f3866c0b6cfe..7de52b65173f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -362,7 +362,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		np->saddr = addr->sin6_addr;
 
 	/* Make sure we are allowed to bind here. */
-	if (sk->sk_prot->get_port(sk, snum)) {
+	if ((snum || !inet->bind_address_no_port) &&
+	    sk->sk_prot->get_port(sk, snum)) {
 		inet_reset_saddr(sk);
 		err = -EADDRINUSE;
 		goto out;
