From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 2/2] inet, inet6: make tcp_sendmsg() and tcp_sendpage() through inet_sendmsg() and inet_sendpage()
Date: Sun, 11 Jul 2010 14:41:55 +0800
Message-ID: <1278830515-22422-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:59700 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab0GKGot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 02:44:49 -0400
Received: by pvc7 with SMTP id 7so1399462pvc.19
        for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 23:44:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet, inet6: make tcp_sendmsg() and tcp_sendpage() through inet_sendmsg() and
inet_sendpage()

a new boolean flag no_autobind is added to structure proto to avoid the autobind
calls when the protocol is TCP. Then sock_rps_record_flow() is called int the
TCP's sendmsg() and sendpage() pathes.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/inet_common.h |    4 ++++
 include/net/sock.h        |    1 +
 include/net/tcp.h         |    8 ++++----
 net/ipv4/af_inet.c        |   15 +++++++++------
 net/ipv4/tcp.c            |   11 +++++------
 net/ipv4/tcp_ipv4.c       |    3 +++
 net/ipv6/af_inet6.c       |    8 ++++----
 net/ipv6/tcp_ipv6.c       |    3 +++
 8 files changed, 33 insertions(+), 20 deletions(-)
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 140c1ec..22fac98 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -21,6 +21,10 @@ extern int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
 extern int inet_accept(struct socket *sock, struct socket *newsock, int flags);
 extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			struct msghdr *msg, size_t size);
+extern ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+			     size_t size, int flags);
+extern int inet_recvmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, size_t size, int flags);
 extern int inet_shutdown(struct socket *sock, int how);
 extern int inet_listen(struct socket *sock, int backlog);
 extern void inet_sock_destruct(struct sock *sk);
diff --git a/include/net/sock.h b/include/net/sock.h
index 4f26f2f..3100e71 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -772,6 +772,7 @@ struct proto {
 	int			*sysctl_wmem;
 	int			*sysctl_rmem;
 	int			max_header;
+	bool			no_autobind;
 
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 33ce524..468b01f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -304,10 +304,10 @@ extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern int tcp_v4_remember_stamp(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
-extern int tcp_sendmsg(struct kiocb *iocb, struct socket *sock,
-		       struct msghdr *msg, size_t size);
-extern ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
-			    size_t size, int flags);
+extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t size);
+extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
+			size_t size, int flags);
 extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				 struct tcphdr *th, unsigned len);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 3ceb025..6a1100c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -727,28 +727,31 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	sock_rps_record_flow(sk);
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
+	if (!inet_sk(sk)->inet_num && !sk->sk_prot->no_autobind &&
+	    inet_autobind(sk))
 		return -EAGAIN;
 
 	return sk->sk_prot->sendmsg(iocb, sk, msg, size);
 }
 EXPORT_SYMBOL(inet_sendmsg);
 
-static ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
-			     size_t size, int flags)
+ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+		      size_t size, int flags)
 {
 	struct sock *sk = sock->sk;
 
 	sock_rps_record_flow(sk);
 
 	/* We may need to bind the socket. */
-	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
+	if (!inet_sk(sk)->inet_num && !sk->sk_prot->no_autobind &&
+	    inet_autobind(sk))
 		return -EAGAIN;
 
 	if (sk->sk_prot->sendpage)
 		return sk->sk_prot->sendpage(sk, page, offset, size, flags);
 	return sock_no_sendpage(sock, page, offset, size, flags);
 }
+EXPORT_SYMBOL(inet_sendpage);
 
 int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
@@ -894,10 +897,10 @@ const struct proto_ops inet_stream_ops = {
 	.shutdown	   = inet_shutdown,
 	.setsockopt	   = sock_common_setsockopt,
 	.getsockopt	   = sock_common_getsockopt,
-	.sendmsg	   = tcp_sendmsg,
+	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = inet_recvmsg,
 	.mmap		   = sock_no_mmap,
-	.sendpage	   = tcp_sendpage,
+	.sendpage	   = inet_sendpage,
 	.splice_read	   = tcp_splice_read,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4e6ddfb..f21e03c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -856,15 +856,15 @@ out_err:
 	return sk_stream_error(sk, flags, err);
 }
 
-ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
-		     size_t size, int flags)
+int tcp_sendpage(struct sock *sk, struct page *page, int offset,
+		 size_t size, int flags)
 {
 	ssize_t res;
-	struct sock *sk = sock->sk;
 
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
-		return sock_no_sendpage(sock, page, offset, size, flags);
+		return sock_no_sendpage(sk->sk_socket, page, offset, size,
+					flags);
 
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
@@ -897,10 +897,9 @@ static inline int select_size(struct sock *sk, int sg)
 	return tmp;
 }
 
-int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
-	struct sock *sk = sock->sk;
 	struct iovec *iov;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 8fa32f5..f7eb3a6 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2595,6 +2595,8 @@ struct proto tcp_prot = {
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
 	.recvmsg		= tcp_recvmsg,
+	.sendmsg		= tcp_sendmsg,
+	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v4_do_rcv,
 	.hash			= inet_hash,
 	.unhash			= inet_unhash,
@@ -2613,6 +2615,7 @@ struct proto tcp_prot = {
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
+	.no_autobind		= true,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e830cd4..56b9bf2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -522,10 +522,10 @@ const struct proto_ops inet6_stream_ops = {
 	.shutdown	   = inet_shutdown,		/* ok		*/
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
-	.sendmsg	   = tcp_sendmsg,		/* ok		*/
-	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.recvmsg	   = inet_recvmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
-	.sendpage	   = tcp_sendpage,
+	.sendpage	   = inet_sendpage,
 	.splice_read	   = tcp_splice_read,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
@@ -549,7 +549,7 @@ const struct proto_ops inet6_dgram_ops = {
 	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   = inet_sendmsg,		/* ok		*/
-	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.recvmsg	   = inet_recvmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ebc27e..fe6d404 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2142,6 +2142,8 @@ struct proto tcpv6_prot = {
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
 	.recvmsg		= tcp_recvmsg,
+	.sendmsg		= tcp_sendmsg,
+	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.hash			= tcp_v6_hash,
 	.unhash			= inet_unhash,
@@ -2160,6 +2162,7 @@ struct proto tcpv6_prot = {
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
 	.h.hashinfo		= &tcp_hashinfo,
+	.no_autobind		= true,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt	= compat_tcp_setsockopt,
 	.compat_getsockopt	= compat_tcp_getsockopt,
