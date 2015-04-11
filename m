From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Sat, 11 Apr 2015 22:18:27 +0100
Message-ID: <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37887 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbbDKVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:31 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

it's equal to iov_iter_count(&msg->msg_iter) in all cases

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/net.h  |  2 +-
 net/socket.c         | 27 ++++++++++++++-------------
 net/sunrpc/svcsock.c |  2 +-
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index e74114b..738ea48 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -211,7 +211,7 @@ int sock_create(int family, int type, int proto, struct socket **res);
 int sock_create_kern(int family, int type, int proto, struct socket **res);
 int sock_create_lite(int family, int type, int proto, struct socket **res);
 void sock_release(struct socket *sock);
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len);
+int sock_sendmsg(struct socket *sock, struct msghdr *msg);
 int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		 int flags);
 struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname);
diff --git a/net/socket.c b/net/socket.c
index b6ceeda..21676e4 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -610,17 +610,19 @@ void __sock_tx_timestamp(const struct sock *sk, __u8 *tx_flags)
 }
 EXPORT_SYMBOL(__sock_tx_timestamp);
 
-static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg,
-				     size_t size)
+static inline int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg)
 {
-	return sock->ops->sendmsg(sock, msg, size);
+	int ret = sock->ops->sendmsg(sock, msg, iov_iter_count(&msg->msg_iter));
+	BUG_ON(ret == -EIOCBQUEUED);
+	return ret;
 }
 
-int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
+int sock_sendmsg(struct socket *sock, struct msghdr *msg)
 {
-	int err = security_socket_sendmsg(sock, msg, size);
+	int err = security_socket_sendmsg(sock, msg,
+					  iov_iter_count(&msg->msg_iter));
 
-	return err ?: sock_sendmsg_nosec(sock, msg, size);
+	return err ?: sock_sendmsg_nosec(sock, msg);
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
@@ -628,7 +630,7 @@ int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
 {
 	iov_iter_kvec(&msg->msg_iter, WRITE | ITER_KVEC, vec, num, size);
-	return sock_sendmsg(sock, msg, size);
+	return sock_sendmsg(sock, msg);
 }
 EXPORT_SYMBOL(kernel_sendmsg);
 
@@ -819,7 +821,7 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	if (sock->type == SOCK_SEQPACKET)
 		msg.msg_flags |= MSG_EOR;
 
-	res = sock_sendmsg(sock, &msg, iov_iter_count(from));
+	res = sock_sendmsg(sock, &msg);
 	*from = msg.msg_iter;
 	return res;
 }
@@ -1657,7 +1659,7 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	msg.msg_flags = flags;
-	err = sock_sendmsg(sock, &msg, iov_iter_count(&msg.msg_iter));
+	err = sock_sendmsg(sock, &msg);
 
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1892,7 +1894,7 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
-	int ctl_len, total_len;
+	int ctl_len;
 	ssize_t err;
 
 	msg_sys->msg_name = &address;
@@ -1903,7 +1905,6 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 		err = copy_msghdr_from_user(msg_sys, msg, NULL, &iov);
 	if (err < 0)
 		return err;
-	total_len = iov_iter_count(&msg_sys->msg_iter);
 
 	err = -ENOBUFS;
 
@@ -1950,10 +1951,10 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	    used_address->name_len == msg_sys->msg_namelen &&
 	    !memcmp(&used_address->name, msg_sys->msg_name,
 		    used_address->name_len)) {
-		err = sock_sendmsg_nosec(sock, msg_sys, total_len);
+		err = sock_sendmsg_nosec(sock, msg_sys);
 		goto out_freectl;
 	}
-	err = sock_sendmsg(sock, msg_sys, total_len);
+	err = sock_sendmsg(sock, msg_sys);
 	/*
 	 * If this is sendmmsg() and sending to current destination address was
 	 * successful, remember it.
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index cc331b6..0c81202 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -257,7 +257,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 
 		svc_set_cmsg_data(rqstp, cmh);
 
-		if (sock_sendmsg(sock, &msg, 0) < 0)
+		if (sock_sendmsg(sock, &msg) < 0)
 			goto out;
 	}
 
-- 
2.1.4
