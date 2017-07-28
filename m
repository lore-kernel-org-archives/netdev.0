From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 1/3] proto_ops: Add locked held versions of sendmsg and sendpage
Date: Fri, 28 Jul 2017 16:22:41 -0700
Message-ID: <20170728232243.3040-2-tom@quantonium.net>
References: <20170728232243.3040-1-tom@quantonium.net>
Cc: rohit@quantonium.net, john.fastabend@gmail.com,
        Tom Herbert <tom@quantonium.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:32941 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753061AbdG1XXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 19:23:20 -0400
Received: by mail-pf0-f179.google.com with SMTP id d67so32878628pfc.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 16:23:20 -0700 (PDT)
In-Reply-To: <20170728232243.3040-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new proto_ops sendmsg_locked and sendpage_locked that can be
called when the socket lock is already held. Correspondingly, add
kernel_sendmsg_locked and kernel_sendpage_locked as front end
functions.

These functions will be used in zero proxy so that we can take
the socket lock in a ULP sendmsg/sendpage and then directly call the
backend transport proto_ops functions.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/net.h | 12 ++++++++++++
 include/net/sock.h  |  3 +++
 include/net/tcp.h   |  3 +++
 net/core/sock.c     | 22 ++++++++++++++++++++++
 net/ipv4/af_inet.c  |  2 ++
 net/ipv4/tcp.c      | 39 ++++++++++++++++++++++++++-------------
 net/socket.c        | 27 +++++++++++++++++++++++++++
 7 files changed, 95 insertions(+), 13 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index dda2cc939a53..b5c15b31709b 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -190,8 +190,16 @@ struct proto_ops {
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
 	int		(*set_peek_off)(struct sock *sk, int val);
 	int		(*peek_len)(struct socket *sock);
+
+	/* The following functions are called internally by kernel with
+	 * sock lock already held.
+	 */
 	int		(*read_sock)(struct sock *sk, read_descriptor_t *desc,
 				     sk_read_actor_t recv_actor);
+	int		(*sendpage_locked)(struct sock *sk, struct page *page,
+					   int offset, size_t size, int flags);
+	int		(*sendmsg_locked)(struct sock *sk, struct msghdr *msg,
+					  size_t size);
 };
 
 #define DECLARE_SOCKADDR(type, dst, src)	\
@@ -279,6 +287,8 @@ do {									\
 
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
 		   size_t num, size_t len);
+int kernel_sendmsg_locked(struct sock *sk, struct msghdr *msg,
+			  struct kvec *vec, size_t num, size_t len);
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
 		   size_t num, size_t len, int flags);
 
@@ -297,6 +307,8 @@ int kernel_setsockopt(struct socket *sock, int level, int optname, char *optval,
 		      unsigned int optlen);
 int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 		    size_t size, int flags);
+int kernel_sendpage_locked(struct sock *sk, struct page *page, int offset,
+			   size_t size, int flags);
 int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
 int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..393c38e9f6aa 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1582,11 +1582,14 @@ int sock_no_shutdown(struct socket *, int);
 int sock_no_getsockopt(struct socket *, int , int, char __user *, int __user *);
 int sock_no_setsockopt(struct socket *, int, int, char __user *, unsigned int);
 int sock_no_sendmsg(struct socket *, struct msghdr *, size_t);
+int sock_no_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t len);
 int sock_no_recvmsg(struct socket *, struct msghdr *, size_t, int);
 int sock_no_mmap(struct file *file, struct socket *sock,
 		 struct vm_area_struct *vma);
 ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
 			 size_t size, int flags);
+ssize_t sock_no_sendpage_locked(struct sock *sk, struct page *page,
+				int offset, size_t size, int flags);
 
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 12d68335acd4..1af32cceda58 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -351,8 +351,11 @@ int tcp_v4_rcv(struct sk_buff *skb);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
+int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size);
 int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
+int tcp_sendpage_locked(struct sock *sk, struct page *page, int offset,
+			size_t size, int flags);
 ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags);
 void tcp_release_cb(struct sock *sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..742f68c9c84a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2500,6 +2500,12 @@ int sock_no_sendmsg(struct socket *sock, struct msghdr *m, size_t len)
 }
 EXPORT_SYMBOL(sock_no_sendmsg);
 
+int sock_no_sendmsg_locked(struct sock *sk, struct msghdr *m, size_t len)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(sock_no_sendmsg_locked);
+
 int sock_no_recvmsg(struct socket *sock, struct msghdr *m, size_t len,
 		    int flags)
 {
@@ -2528,6 +2534,22 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, siz
 }
 EXPORT_SYMBOL(sock_no_sendpage);
 
+ssize_t sock_no_sendpage_locked(struct sock *sk, struct page *page,
+				int offset, size_t size, int flags)
+{
+	ssize_t res;
+	struct msghdr msg = {.msg_flags = flags};
+	struct kvec iov;
+	char *kaddr = kmap(page);
+
+	iov.iov_base = kaddr + offset;
+	iov.iov_len = size;
+	res = kernel_sendmsg_locked(sk, &msg, &iov, 1, size);
+	kunmap(page);
+	return res;
+}
+EXPORT_SYMBOL(sock_no_sendpage_locked);
+
 /*
  *	Default Socket Callbacks
  */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ce44fb7d498..f0103ffe1cdb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -944,6 +944,8 @@ const struct proto_ops inet_stream_ops = {
 	.sendpage	   = inet_sendpage,
 	.splice_read	   = tcp_splice_read,
 	.read_sock	   = tcp_read_sock,
+	.sendmsg_locked    = tcp_sendmsg_locked,
+	.sendpage_locked   = tcp_sendpage_locked,
 	.peek_len	   = tcp_peek_len,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 71ce33decd97..ae39926b98b4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1034,23 +1034,29 @@ ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 }
 EXPORT_SYMBOL_GPL(do_tcp_sendpages);
 
-int tcp_sendpage(struct sock *sk, struct page *page, int offset,
-		 size_t size, int flags)
+int tcp_sendpage_locked(struct sock *sk, struct page *page, int offset,
+			size_t size, int flags)
 {
-	ssize_t res;
-
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !sk_check_csum_caps(sk))
 		return sock_no_sendpage(sk->sk_socket, page, offset, size,
 					flags);
 
-	lock_sock(sk);
-
 	tcp_rate_check_app_limited(sk);  /* is sending application-limited? */
 
-	res = do_tcp_sendpages(sk, page, offset, size, flags);
+	return do_tcp_sendpages(sk, page, offset, size, flags);
+}
+
+int tcp_sendpage(struct sock *sk, struct page *page, int offset,
+		 size_t size, int flags)
+{
+	int ret;
+
+	lock_sock(sk);
+	ret = tcp_sendpage_locked(sk, page, offset, size, flags);
 	release_sock(sk);
-	return res;
+
+	return ret;
 }
 EXPORT_SYMBOL(tcp_sendpage);
 
@@ -1144,7 +1150,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	return err;
 }
 
-int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
+int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1155,8 +1161,6 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 	bool sg;
 	long timeo;
 
-	lock_sock(sk);
-
 	flags = msg->msg_flags;
 	if (unlikely(flags & MSG_FASTOPEN || inet_sk(sk)->defer_connect)) {
 		err = tcp_sendmsg_fastopen(sk, msg, &copied_syn, size);
@@ -1365,7 +1369,6 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
 	}
 out_nopush:
-	release_sock(sk);
 	return copied + copied_syn;
 
 do_fault:
@@ -1389,9 +1392,19 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 		sk->sk_write_space(sk);
 		tcp_chrono_stop(sk, TCP_CHRONO_SNDBUF_LIMITED);
 	}
-	release_sock(sk);
 	return err;
 }
+
+int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
+{
+	int ret;
+
+	lock_sock(sk);
+	ret = tcp_sendmsg_locked(sk, msg, size);
+	release_sock(sk);
+
+	return ret;
+}
 EXPORT_SYMBOL(tcp_sendmsg);
 
 /*
diff --git a/net/socket.c b/net/socket.c
index 79d9bb964cd8..c0a12ad39610 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -652,6 +652,20 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
+int kernel_sendmsg_locked(struct sock *sk, struct msghdr *msg,
+			  struct kvec *vec, size_t num, size_t size)
+{
+	struct socket *sock = sk->sk_socket;
+
+	if (!sock->ops->sendmsg_locked)
+		sock_no_sendmsg_locked(sk, msg, size);
+
+	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
+
+	return sock->ops->sendmsg_locked(sk, msg, msg_data_left(msg));
+}
+EXPORT_SYMBOL(kernel_sendmsg_locked);
+
 static bool skb_is_err_queue(const struct sk_buff *skb)
 {
 	/* pkt_type of skbs enqueued on the error queue are set to
@@ -3375,6 +3389,19 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 }
 EXPORT_SYMBOL(kernel_sendpage);
 
+int kernel_sendpage_locked(struct sock *sk, struct page *page, int offset,
+			   size_t size, int flags)
+{
+	struct socket *sock = sk->sk_socket;
+
+	if (sock->ops->sendpage_locked)
+		return sock->ops->sendpage_locked(sk, page, offset, size,
+						  flags);
+
+	return sock_no_sendpage_locked(sk, page, offset, size, flags);
+}
+EXPORT_SYMBOL(kernel_sendpage_locked);
+
 int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg)
 {
 	mm_segment_t oldfs = get_fs();
-- 
2.11.0
