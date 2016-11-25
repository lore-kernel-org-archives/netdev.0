From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/5] net/socket: add per protocol mmesg support
Date: Fri, 25 Nov 2016 16:39:53 +0100
Message-ID: <34a5941b05089c68d398fed56fc65dada5ccacb5.1480086321.git.pabeni@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754928AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proto->recvmmsg allows leveraging per protocol optimization,
amortizing the protocol/locking overhead on multiple packets.

This commit introduces the procotol level callbacks and change
to generic implementation to use them.

We explicitly pass down to the protocol level both 'timeout'
and 'end_time' to avoid duplicating there the call to
poll_select_set_timeout().

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/net.h       |  5 +++++
 include/net/inet_common.h |  3 +++
 include/net/sock.h        |  6 ++++++
 net/ipv4/af_inet.c        | 16 ++++++++++++++++
 net/ipv6/af_inet6.c       |  1 +
 net/socket.c              | 26 +++++++++++++++++++++++++-
 6 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index cd0c8bd..95f1bc5 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -182,6 +182,11 @@ struct proto_ops {
 	 */
 	int		(*recvmsg)   (struct socket *sock, struct msghdr *m,
 				      size_t total_len, int flags);
+	int		(*recvmmsg)  (struct socket *sock,
+				      struct mmsghdr __user *user_mmsg,
+				      unsigned int *vlen, unsigned int flags,
+				      struct timespec *timeout,
+				      const struct timespec64 *end_time);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 5d68342..c7d5875 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -26,6 +26,9 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 		      size_t size, int flags);
 int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		 int flags);
+int inet_recvmmsg(struct socket *sock, struct mmsghdr __user *user_mmsg,
+		  unsigned int *vlen, unsigned int flags,
+		  struct timespec *timeout, const struct timespec64 *end_time);
 int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
diff --git a/include/net/sock.h b/include/net/sock.h
index c92dc19..11126f4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1010,6 +1010,12 @@ struct proto {
 	int			(*recvmsg)(struct sock *sk, struct msghdr *msg,
 					   size_t len, int noblock, int flags,
 					   int *addr_len);
+	int			(*recvmmsg)(struct sock *sk,
+					    struct mmsghdr __user *user_mmsg,
+					    unsigned int *nr,
+					    unsigned int flags,
+					    struct timespec *timeout,
+					    const struct timespec64 *end_time);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ddf5cd..747558d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -770,6 +770,21 @@ int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 }
 EXPORT_SYMBOL(inet_recvmsg);
 
+int inet_recvmmsg(struct socket *sock, struct mmsghdr __user *ummsg,
+		  unsigned int *vlen, unsigned int flags,
+		  struct timespec *timeout, const struct timespec64 *end_time)
+{
+	struct sock *sk = sock->sk;
+
+	if (!sk->sk_prot->recvmmsg)
+		return -EOPNOTSUPP;
+
+	sock_rps_record_flow(sk);
+
+	return sk->sk_prot->recvmmsg(sk, ummsg, vlen, flags, timeout, end_time);
+}
+EXPORT_SYMBOL(inet_recvmmsg);
+
 int inet_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
@@ -942,6 +957,7 @@ static int inet_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned lon
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = inet_recvmsg,
+	.recvmmsg	   = inet_recvmmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 	.set_peek_off	   = sk_set_peek_off,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d424f3a..f7ce6a2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -571,6 +571,7 @@ int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   = inet_sendmsg,		/* ok		*/
 	.recvmsg	   = inet_recvmsg,		/* ok		*/
+	.recvmmsg	   = inet_recvmmsg,		/* ok		*/
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 	.set_peek_off	   = sk_set_peek_off,
diff --git a/net/socket.c b/net/socket.c
index 9b5f360..49e6cd6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2140,6 +2140,8 @@ static int copy_msghdr_to_user_gen(struct msghdr *msg_sys, int flags,
 				  &msg->msg_controllen);
 }
 
+#define MSG_CMSG_MASK (MSG_CMSG_CLOEXEC | MSG_CMSG_COMPAT)
+
 static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags, int nosec)
 {
@@ -2163,7 +2165,7 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 		return err;
 
 	cmsg_ptr = (unsigned long)msg_sys->msg_control;
-	msg_sys->msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
+	msg_sys->msg_flags = flags & MSG_CMSG_MASK;
 
 	/* We assume all kernel code knows the size of sockaddr_storage */
 	msg_sys->msg_namelen = 0;
@@ -2218,6 +2220,21 @@ long __sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
  *     Linux recvmmsg interface
  */
 
+static int __proto_recvmmsg(struct socket *sock, struct mmsghdr __user *ummsg,
+			    unsigned int *vlen, unsigned int flags,
+			    struct timespec *timeout,
+			    const struct timespec64 *end_time)
+{
+	if (!sock->ops->recvmmsg)
+		return -EOPNOTSUPP;
+
+	if (sock->file->f_flags & O_NONBLOCK)
+		flags |= MSG_DONTWAIT;
+
+	/* defer LSM check and mmsg parsing to the proto operation */
+	return sock->ops->recvmmsg(sock, ummsg, vlen, flags, timeout, end_time);
+}
+
 int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		   unsigned int flags, struct timespec *timeout)
 {
@@ -2243,6 +2260,12 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	if (err)
 		goto out_put;
 
+	err = __proto_recvmmsg(sock, mmsg, &vlen, flags, timeout, &end_time);
+	if (err != -EOPNOTSUPP) {
+		datagrams = vlen;
+		goto chk_error;
+	}
+
 	entry = mmsg;
 	compat_entry = (struct compat_mmsghdr __user *)mmsg;
 
@@ -2287,6 +2310,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		cond_resched();
 	}
 
+chk_error:
 	if (err == 0)
 		goto out_put;
 
-- 
1.8.3.1
