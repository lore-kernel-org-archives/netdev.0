From: Li Yu <raise.sail@gmail.com>
Subject: [RFC][PATCH 3/4] skbtrace: TCP/IP family support
Date: Wed, 11 Jul 2012 10:17:56 +0800
Message-ID: <4FFCE254.8090402@gmail.com>
References: <4FFBC6B6.2000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40614 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594Ab2GKCSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 22:18:01 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so1204818pbb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 19:18:01 -0700 (PDT)
In-Reply-To: <4FFBC6B6.2000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yu <bingtian.ly@taobao.com>

This implements skbtrace support for TCP/IP protocol family, but it does
not contains any particular traces.

Basically, it just refactors a bit for XX_get_name(), which will be used
in some socket based traces.

Thanks.

Sign-off-by: Li Yu <bingtian.ly@taobao.com>
---
 include/net/inet_common.h |    4 ++++
 include/net/ipv6.h        |    4 ++++
 net/ipv4/af_inet.c        |   46
++++++++++++++++++++++++++++++++++-----------
 net/ipv6/af_inet6.c       |   42 ++++++++++++++++++++++++++++++-----------
 net/ipv6/raw.c            |    1 +
 5 files changed, 75 insertions(+), 22 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 22fac98..74e8bfb 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -29,6 +29,10 @@ extern int inet_shutdown(struct socket *sock, int how);
 extern int inet_listen(struct socket *sock, int backlog);
 extern void inet_sock_destruct(struct sock *sk);
 extern int inet_bind(struct socket *sock, struct sockaddr *uaddr, int
addr_len);
+extern int __inet_sock_getname(struct sock *sk, struct sockaddr *uaddr,
+			int *uaddr_len, int peer);
+extern int __inet_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer);
 extern int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 			int *uaddr_len, int peer);
 extern int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned
long arg);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index aecf884..2ef2eee 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -603,6 +603,10 @@ extern void			ipv6_local_rxpmtu(struct sock *sk,
struct flowi6 *fl6, u32 mtu);
 extern int inet6_release(struct socket *sock);
 extern int inet6_bind(struct socket *sock, struct sockaddr *uaddr,
 		      int addr_len);
+extern int __inet6_sock_getname(struct sock *sk, struct sockaddr *uaddr,
+			 int *uaddr_len, int peer);
+extern int __inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+			 int *uaddr_len, int peer);
 extern int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 			 int *uaddr_len, int peer);
 extern int inet6_ioctl(struct socket *sock, unsigned int cmd,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 07a02f6..4ddbf8d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -119,6 +119,7 @@
 #include <linux/mroute.h>
 #endif

+#include <linux/skbtrace.h>

 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
@@ -698,23 +699,14 @@ do_err:
 }
 EXPORT_SYMBOL(inet_accept);

-
-/*
- *	This does both peername and sockname.
- */
-int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+int __inet_sock_getname(struct sock *sk, struct sockaddr *uaddr,
 			int *uaddr_len, int peer)
 {
-	struct sock *sk		= sock->sk;
 	struct inet_sock *inet	= inet_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in *, sin, uaddr);

 	sin->sin_family = AF_INET;
 	if (peer) {
-		if (!inet->inet_dport ||
-		    (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
-		     peer == 1))
-			return -ENOTCONN;
 		sin->sin_port = inet->inet_dport;
 		sin->sin_addr.s_addr = inet->inet_daddr;
 	} else {
@@ -725,9 +717,38 @@ int inet_getname(struct socket *sock, struct
sockaddr *uaddr,
 		sin->sin_addr.s_addr = addr;
 	}
 	memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	*uaddr_len = sizeof(*sin);
+	if (uaddr_len)
+		*uaddr_len = sizeof(*sin);
 	return 0;
 }
+EXPORT_SYMBOL(__inet_sock_getname);
+
+int __inet_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer)
+{
+	return __inet_sock_getname(sock->sk, uaddr, uaddr_len, peer);
+}
+EXPORT_SYMBOL(__inet_getname);
+
+/*
+ *	This does both peername and sockname.
+ */
+int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer)
+{
+	struct sock *sk		= sock->sk;
+	struct inet_sock *inet	= inet_sk(sk);
+
+	if (peer) {
+		if (!inet->inet_dport)
+			return -ENOTCONN;
+		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
+		     peer == 1)
+			return -ENOTCONN;
+	}
+
+	return __inet_getname(sock, uaddr, uaddr_len, peer);
+}
 EXPORT_SYMBOL(inet_getname);

 int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr
*msg,
@@ -914,6 +935,7 @@ const struct proto_ops inet_stream_ops = {
 	.connect	   = inet_stream_connect,
 	.socketpair	   = sock_no_socketpair,
 	.accept		   = inet_accept,
+	.skbtrace_getname  = __inet_getname,
 	.getname	   = inet_getname,
 	.poll		   = tcp_poll,
 	.ioctl		   = inet_ioctl,
@@ -942,6 +964,7 @@ const struct proto_ops inet_dgram_ops = {
 	.connect	   = inet_dgram_connect,
 	.socketpair	   = sock_no_socketpair,
 	.accept		   = sock_no_accept,
+	.skbtrace_getname  = __inet_getname,
 	.getname	   = inet_getname,
 	.poll		   = udp_poll,
 	.ioctl		   = inet_ioctl,
@@ -973,6 +996,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.connect	   = inet_dgram_connect,
 	.socketpair	   = sock_no_socketpair,
 	.accept		   = sock_no_accept,
+	.skbtrace_getname  = __inet_getname,
 	.getname	   = inet_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet_ioctl,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e22e6d8..e384ef1 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -437,15 +437,10 @@ void inet6_destroy_sock(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet6_destroy_sock);

-/*
- *	This does both peername and sockname.
- */
-
-int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+int __inet6_sock_getname(struct sock *sk, struct sockaddr *uaddr,
 		 int *uaddr_len, int peer)
 {
 	struct sockaddr_in6 *sin = (struct sockaddr_in6 *)uaddr;
-	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);

@@ -453,11 +448,6 @@ int inet6_getname(struct socket *sock, struct
sockaddr *uaddr,
 	sin->sin6_flowinfo = 0;
 	sin->sin6_scope_id = 0;
 	if (peer) {
-		if (!inet->inet_dport)
-			return -ENOTCONN;
-		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
-		    peer == 1)
-			return -ENOTCONN;
 		sin->sin6_port = inet->inet_dport;
 		sin->sin6_addr = np->daddr;
 		if (np->sndflow)
@@ -475,6 +465,34 @@ int inet6_getname(struct socket *sock, struct
sockaddr *uaddr,
 	*uaddr_len = sizeof(*sin);
 	return 0;
 }
+
+int __inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+		 int *uaddr_len, int peer)
+{
+	return __inet6_sock_getname(sock->sk, uaddr, uaddr_len, peer);
+}
+EXPORT_SYMBOL_GPL(__inet6_getname);
+
+/*
+ *	This does both peername and sockname.
+ */
+
+int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
+		 int *uaddr_len, int peer)
+{
+	struct sock *sk = sock->sk;
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (peer) {
+		if (!inet->inet_dport)
+			return -ENOTCONN;
+		if (((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_SYN_SENT)) &&
+		    peer == 1)
+			return -ENOTCONN;
+	}
+
+	return __inet6_getname(sock, uaddr, uaddr_len, peer);
+}
 EXPORT_SYMBOL(inet6_getname);

 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
@@ -518,6 +536,7 @@ const struct proto_ops inet6_stream_ops = {
 	.connect	   = inet_stream_connect,	/* ok		*/
 	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
 	.accept		   = inet_accept,		/* ok		*/
+	.skbtrace_getname  = __inet6_getname,
 	.getname	   = inet6_getname,
 	.poll		   = tcp_poll,			/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
@@ -544,6 +563,7 @@ const struct proto_ops inet6_dgram_ops = {
 	.connect	   = inet_dgram_connect,	/* ok		*/
 	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
 	.accept		   = sock_no_accept,		/* a do nothing	*/
+	.skbtrace_getname  = __inet6_getname,
 	.getname	   = inet6_getname,
 	.poll		   = udp_poll,			/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index b5c1dcb..3d0b3b4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1326,6 +1326,7 @@ static const struct proto_ops inet6_sockraw_ops = {
 	.connect	   = inet_dgram_connect,	/* ok		*/
 	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
 	.accept		   = sock_no_accept,		/* a do nothing	*/
+	.skbtrace_getname  = __inet6_getname,
 	.getname	   = inet6_getname,
 	.poll		   = datagram_poll,		/* ok		*/
 	.ioctl		   = inet6_ioctl,		/* must change  */
-- 
1.7.9.5
