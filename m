From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/5] net/socket: factor out msghdr manipulation helpers
Date: Fri, 25 Nov 2016 16:39:52 +0100
Message-ID: <d22a859f37a8e696e552ce2f1a73d92aefa7f0e0.1480086321.git.pabeni@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35952 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754803AbcKYPlS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 10:41:18 -0500
In-Reply-To: <cover.1480086321.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so that they can be later used for recvmmsg refactor

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/sock.h | 18 ++++++++++
 net/socket.c       | 97 +++++++++++++++++++++++++++++-------------------------
 2 files changed, 70 insertions(+), 45 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 442cbb1..c92dc19 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1528,6 +1528,24 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc);
 
+static inline bool sock_recvmmsg_timeout(struct timespec *timeout,
+					 struct timespec64 end_time)
+{
+	struct timespec64 timeout64;
+
+	if (!timeout)
+		return false;
+
+	ktime_get_ts64(&timeout64);
+	*timeout = timespec64_to_timespec(timespec64_sub(end_time, timeout64));
+	if (timeout->tv_sec < 0) {
+		timeout->tv_sec = timeout->tv_nsec = 0;
+		return true;
+	}
+
+	return timeout->tv_nsec == 0 && timeout->tv_sec == 0;
+}
+
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
diff --git a/net/socket.c b/net/socket.c
index e2584c5..9b5f360 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1903,6 +1903,21 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 			    UIO_FASTIOV, iov, &kmsg->msg_iter);
 }
 
+static int copy_msghdr_from_user_gen(struct msghdr *msg_sys, unsigned int flags,
+				     struct compat_msghdr __user *msg_compat,
+				     struct user_msghdr __user *msg,
+				     struct sockaddr __user **uaddr,
+				     struct iovec **iov,
+				     struct sockaddr_storage *addr)
+{
+	msg_sys->msg_name = addr;
+
+	if (MSG_CMSG_COMPAT & flags)
+		return get_compat_msghdr(msg_sys, msg_compat, uaddr, iov);
+	else
+		return copy_msghdr_from_user(msg_sys, msg, uaddr, iov);
+}
+
 static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags,
 			 struct used_address *used_address,
@@ -1919,12 +1934,8 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	int ctl_len;
 	ssize_t err;
 
-	msg_sys->msg_name = &address;
-
-	if (MSG_CMSG_COMPAT & flags)
-		err = get_compat_msghdr(msg_sys, msg_compat, NULL, &iov);
-	else
-		err = copy_msghdr_from_user(msg_sys, msg, NULL, &iov);
+	err = copy_msghdr_from_user_gen(msg_sys, flags, msg_compat, msg, NULL,
+					&iov, &address);
 	if (err < 0)
 		return err;
 
@@ -2101,6 +2112,34 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	return __sys_sendmmsg(fd, mmsg, vlen, flags);
 }
 
+static int copy_msghdr_to_user_gen(struct msghdr *msg_sys, int flags,
+				   struct compat_msghdr __user *msg_compat,
+				   struct user_msghdr __user *msg,
+				   struct sockaddr __user *uaddr,
+				   struct sockaddr_storage *addr,
+				   unsigned long cmsgptr)
+{
+	int __user *uaddr_len = COMPAT_NAMELEN(msg);
+	int err;
+
+	if (uaddr) {
+		err = move_addr_to_user(addr, msg_sys->msg_namelen, uaddr,
+					uaddr_len);
+		if (err < 0)
+			return err;
+	}
+	err = __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMPAT),
+			 COMPAT_FLAGS(msg));
+	if (err)
+		return err;
+	if (MSG_CMSG_COMPAT & flags)
+		return __put_user((unsigned long)msg_sys->msg_control -
+				  cmsgptr, &msg_compat->msg_controllen);
+	else
+		return __put_user((unsigned long)msg_sys->msg_control - cmsgptr,
+				  &msg->msg_controllen);
+}
+
 static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags, int nosec)
 {
@@ -2117,14 +2156,9 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 
 	/* user mode address pointers */
 	struct sockaddr __user *uaddr;
-	int __user *uaddr_len = COMPAT_NAMELEN(msg);
 
-	msg_sys->msg_name = &addr;
-
-	if (MSG_CMSG_COMPAT & flags)
-		err = get_compat_msghdr(msg_sys, msg_compat, &uaddr, &iov);
-	else
-		err = copy_msghdr_from_user(msg_sys, msg, &uaddr, &iov);
+	err = copy_msghdr_from_user_gen(msg_sys, flags, msg_compat, msg, &uaddr,
+					&iov, &addr);
 	if (err < 0)
 		return err;
 
@@ -2140,24 +2174,8 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 	if (err < 0)
 		goto out_freeiov;
 	len = err;
-
-	if (uaddr != NULL) {
-		err = move_addr_to_user(&addr,
-					msg_sys->msg_namelen, uaddr,
-					uaddr_len);
-		if (err < 0)
-			goto out_freeiov;
-	}
-	err = __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMPAT),
-			 COMPAT_FLAGS(msg));
-	if (err)
-		goto out_freeiov;
-	if (MSG_CMSG_COMPAT & flags)
-		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
-				 &msg_compat->msg_controllen);
-	else
-		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
-				 &msg->msg_controllen);
+	err = copy_msghdr_to_user_gen(msg_sys, flags, msg_compat, msg, uaddr,
+				      &addr, cmsg_ptr);
 	if (err)
 		goto out_freeiov;
 	err = len;
@@ -2209,7 +2227,6 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct compat_mmsghdr __user *compat_entry;
 	struct msghdr msg_sys;
 	struct timespec64 end_time;
-	struct timespec64 timeout64;
 
 	if (timeout &&
 	    poll_select_set_timeout(&end_time, timeout->tv_sec,
@@ -2260,19 +2277,9 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		if (flags & MSG_WAITFORONE)
 			flags |= MSG_DONTWAIT;
 
-		if (timeout) {
-			ktime_get_ts64(&timeout64);
-			*timeout = timespec64_to_timespec(
-					timespec64_sub(end_time, timeout64));
-			if (timeout->tv_sec < 0) {
-				timeout->tv_sec = timeout->tv_nsec = 0;
-				break;
-			}
-
-			/* Timeout, return less than vlen datagrams */
-			if (timeout->tv_nsec == 0 && timeout->tv_sec == 0)
-				break;
-		}
+		/* Timeout, return less than vlen datagrams */
+		if (sock_recvmmsg_timeout(timeout, end_time))
+			break;
 
 		/* Out of band data, return right away */
 		if (msg_sys.msg_flags & MSG_OOB)
-- 
1.8.3.1
