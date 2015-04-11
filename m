From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 14/17] net: switch importing msghdr from userland to {compat_,}import_iovec()
Date: Sat, 11 Apr 2015 22:18:25 +0100
Message-ID: <1428787108-13650-14-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37884 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbbDKVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:31 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/compat.h |  2 +-
 net/compat.c         | 18 +++++++-----------
 net/socket.c         | 31 ++++++++++++-------------------
 3 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/include/net/compat.h b/include/net/compat.h
index 42a9c84..48103cf 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -40,7 +40,7 @@ int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 #define compat_mmsghdr	mmsghdr
 #endif /* defined(CONFIG_COMPAT) */
 
-ssize_t get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *,
+int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *,
 		      struct sockaddr __user **, struct iovec **);
 asmlinkage long compat_sys_sendmsg(int, struct compat_msghdr __user *,
 				   unsigned int);
diff --git a/net/compat.c b/net/compat.c
index c4b6b0f..5cfd26a 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -31,10 +31,10 @@
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
-ssize_t get_compat_msghdr(struct msghdr *kmsg,
-			  struct compat_msghdr __user *umsg,
-			  struct sockaddr __user **save_addr,
-			  struct iovec **iov)
+int get_compat_msghdr(struct msghdr *kmsg,
+		      struct compat_msghdr __user *umsg,
+		      struct sockaddr __user **save_addr,
+		      struct iovec **iov)
 {
 	compat_uptr_t uaddr, uiov, tmp3;
 	compat_size_t nr_segs;
@@ -81,13 +81,9 @@ ssize_t get_compat_msghdr(struct msghdr *kmsg,
 
 	kmsg->msg_iocb = NULL;
 
-	err = compat_rw_copy_check_uvector(save_addr ? READ : WRITE,
-					   compat_ptr(uiov), nr_segs,
-					   UIO_FASTIOV, *iov, iov);
-	if (err >= 0)
-		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
-			      *iov, nr_segs, err);
-	return err;
+	return compat_import_iovec(save_addr ? READ : WRITE,
+				   compat_ptr(uiov), nr_segs,
+				   UIO_FASTIOV, iov, &kmsg->msg_iter);
 }
 
 /* Bleech... */
diff --git a/net/socket.c b/net/socket.c
index 46f0e1d..e5669ce 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1841,10 +1841,10 @@ struct used_address {
 	unsigned int name_len;
 };
 
-static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
-				     struct user_msghdr __user *umsg,
-				     struct sockaddr __user **save_addr,
-				     struct iovec **iov)
+static int copy_msghdr_from_user(struct msghdr *kmsg,
+				 struct user_msghdr __user *umsg,
+				 struct sockaddr __user **save_addr,
+				 struct iovec **iov)
 {
 	struct sockaddr __user *uaddr;
 	struct iovec __user *uiov;
@@ -1890,13 +1890,8 @@ static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
 
 	kmsg->msg_iocb = NULL;
 
-	err = rw_copy_check_uvector(save_addr ? READ : WRITE,
-				    uiov, nr_segs,
-				    UIO_FASTIOV, *iov, iov);
-	if (err >= 0)
-		iov_iter_init(&kmsg->msg_iter, save_addr ? READ : WRITE,
-			      *iov, nr_segs, err);
-	return err;
+	return import_iovec(save_addr ? READ : WRITE, uiov, nr_segs,
+			    UIO_FASTIOV, iov, &kmsg->msg_iter);
 }
 
 static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
@@ -1921,8 +1916,8 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	else
 		err = copy_msghdr_from_user(msg_sys, msg, NULL, &iov);
 	if (err < 0)
-		goto out_freeiov;
-	total_len = err;
+		return err;
+	total_len = iov_iter_count(&msg_sys->msg_iter);
 
 	err = -ENOBUFS;
 
@@ -1988,8 +1983,7 @@ out_freectl:
 	if (ctl_buf != ctl)
 		sock_kfree_s(sock->sk, ctl_buf, ctl_len);
 out_freeiov:
-	if (iov != iovstack)
-		kfree(iov);
+	kfree(iov);
 	return err;
 }
 
@@ -2114,8 +2108,8 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 	else
 		err = copy_msghdr_from_user(msg_sys, msg, &uaddr, &iov);
 	if (err < 0)
-		goto out_freeiov;
-	total_len = err;
+		return err;
+	total_len = iov_iter_count(&msg_sys->msg_iter);
 
 	cmsg_ptr = (unsigned long)msg_sys->msg_control;
 	msg_sys->msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
@@ -2153,8 +2147,7 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 	err = len;
 
 out_freeiov:
-	if (iov != iovstack)
-		kfree(iov);
+	kfree(iov);
 	return err;
 }
 
-- 
2.1.4
