From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 2/5] {compat_,}verify_iovec(): switch to generic copying of
 iovecs
Date: Tue, 18 Nov 2014 19:42:06 +0000
Message-ID: <20141118194206.GC14641@ZenIV.linux.org.uk>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
 <20141118194053.GA14641@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141118194053.GA14641@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use {compat_,}rw_copy_check_uvector().  As the result, we are
guaranteed that all iovecs seen in ->msg_iov by ->sendmsg()
and ->recvmsg() will pass access_ok().  The next commit removes
now redundant checks in callees...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/compat.c     |   51 +++++++++++++++------------------------------------
 net/core/iovec.c |   37 ++++++++++++++-----------------------
 net/socket.c     |   38 ++++++++------------------------------
 3 files changed, 37 insertions(+), 89 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 562e920..7b4b6ad 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -31,33 +31,6 @@
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
-static inline int iov_from_user_compat_to_kern(struct iovec *kiov,
-					  struct compat_iovec __user *uiov32,
-					  int niov)
-{
-	int tot_len = 0;
-
-	while (niov > 0) {
-		compat_uptr_t buf;
-		compat_size_t len;
-
-		if (get_user(len, &uiov32->iov_len) ||
-		    get_user(buf, &uiov32->iov_base))
-			return -EFAULT;
-
-		if (len > INT_MAX - tot_len)
-			len = INT_MAX - tot_len;
-
-		tot_len += len;
-		kiov->iov_base = compat_ptr(buf);
-		kiov->iov_len = (__kernel_size_t) len;
-		uiov32++;
-		kiov++;
-		niov--;
-	}
-	return tot_len;
-}
-
 int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
 {
 	compat_uptr_t tmp1, tmp2, tmp3;
@@ -80,13 +53,15 @@ int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
 }
 
 /* I've named the args so it is easy to tell whose space the pointers are in. */
-int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
+int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *iov,
 		   struct sockaddr_storage *kern_address, int mode)
 {
-	int tot_len;
+	struct compat_iovec __user *p;
+	struct iovec *res;
+	int err;
 
 	if (kern_msg->msg_name && kern_msg->msg_namelen) {
-		if (mode == VERIFY_READ) {
+		if (mode == WRITE) {
 			int err = move_addr_to_kernel(kern_msg->msg_name,
 						      kern_msg->msg_namelen,
 						      kern_address);
@@ -99,13 +74,17 @@ int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
 		kern_msg->msg_namelen = 0;
 	}
 
-	tot_len = iov_from_user_compat_to_kern(kern_iov,
-					  (struct compat_iovec __user *)kern_msg->msg_iov,
-					  kern_msg->msg_iovlen);
-	if (tot_len >= 0)
-		kern_msg->msg_iov = kern_iov;
+	if (kern_msg->msg_iovlen > UIO_MAXIOV)
+		return -EMSGSIZE;
 
-	return tot_len;
+	p = (struct compat_iovec __user *)kern_msg->msg_iov;
+	err = compat_rw_copy_check_uvector(mode, p, kern_msg->msg_iovlen,
+					   UIO_FASTIOV, iov, &res);
+	if (err >= 0)
+		kern_msg->msg_iov = res;
+	else if (res != iov)
+		kfree(res);
+	return err;
 }
 
 /* Bleech... */
diff --git a/net/core/iovec.c b/net/core/iovec.c
index e1ec45a..86beeea 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -37,13 +37,13 @@
 
 int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *address, int mode)
 {
-	int size, ct, err;
+	struct iovec *res;
+	int err;
 
 	if (m->msg_name && m->msg_namelen) {
-		if (mode == VERIFY_READ) {
-			void __user *namep;
-			namep = (void __user __force *) m->msg_name;
-			err = move_addr_to_kernel(namep, m->msg_namelen,
+		if (mode == WRITE) {
+			void __user *namep = (void __user __force *)m->msg_name;
+			int err = move_addr_to_kernel(namep, m->msg_namelen,
 						  address);
 			if (err < 0)
 				return err;
@@ -53,24 +53,15 @@ int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *a
 		m->msg_name = NULL;
 		m->msg_namelen = 0;
 	}
-
-	size = m->msg_iovlen * sizeof(struct iovec);
-	if (copy_from_user(iov, (void __user __force *) m->msg_iov, size))
-		return -EFAULT;
-
-	m->msg_iov = iov;
-	err = 0;
-
-	for (ct = 0; ct < m->msg_iovlen; ct++) {
-		size_t len = iov[ct].iov_len;
-
-		if (len > INT_MAX - err) {
-			len = INT_MAX - err;
-			iov[ct].iov_len = len;
-		}
-		err += len;
-	}
-
+	if (m->msg_iovlen > UIO_MAXIOV)
+		return -EMSGSIZE;
+
+	err = rw_copy_check_uvector(mode, (void __user __force *)m->msg_iov,
+				    m->msg_iovlen, UIO_FASTIOV, iov, &res);
+	if (err >= 0)
+		m->msg_iov = res;
+	else if (res != iov)
+		kfree(res);
 	return err;
 }
 
diff --git a/net/socket.c b/net/socket.c
index 0ae8147..59020f0 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2032,24 +2032,14 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 			return err;
 	}
 
-	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
-		err = -EMSGSIZE;
-		if (msg_sys->msg_iovlen > UIO_MAXIOV)
-			goto out;
-		err = -ENOMEM;
-		iov = kmalloc(msg_sys->msg_iovlen * sizeof(struct iovec),
-			      GFP_KERNEL);
-		if (!iov)
-			goto out;
-	}
-
 	/* This will also move the address data into kernel space */
-	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(msg_sys, iov, &address, VERIFY_READ);
-	} else
-		err = verify_iovec(msg_sys, iov, &address, VERIFY_READ);
+	if (MSG_CMSG_COMPAT & flags)
+		err = verify_compat_iovec(msg_sys, iovstack, &address, WRITE);
+	else
+		err = verify_iovec(msg_sys, iovstack, &address, WRITE);
 	if (err < 0)
 		goto out_freeiov;
+	iov = msg_sys->msg_iov;
 	total_len = err;
 
 	err = -ENOBUFS;
@@ -2118,7 +2108,6 @@ out_freectl:
 out_freeiov:
 	if (iov != iovstack)
 		kfree(iov);
-out:
 	return err;
 }
 
@@ -2244,28 +2233,18 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 			return err;
 	}
 
-	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
-		err = -EMSGSIZE;
-		if (msg_sys->msg_iovlen > UIO_MAXIOV)
-			goto out;
-		err = -ENOMEM;
-		iov = kmalloc(msg_sys->msg_iovlen * sizeof(struct iovec),
-			      GFP_KERNEL);
-		if (!iov)
-			goto out;
-	}
-
 	/* Save the user-mode address (verify_iovec will change the
 	 * kernel msghdr to use the kernel address space)
 	 */
 	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags)
-		err = verify_compat_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
+		err = verify_compat_iovec(msg_sys, iovstack, &addr, READ);
 	else
-		err = verify_iovec(msg_sys, iov, &addr, VERIFY_WRITE);
+		err = verify_iovec(msg_sys, iovstack, &addr, READ);
 	if (err < 0)
 		goto out_freeiov;
+	iov = msg_sys->msg_iov;
 	total_len = err;
 
 	cmsg_ptr = (unsigned long)msg_sys->msg_control;
@@ -2306,7 +2285,6 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 out_freeiov:
 	if (iov != iovstack)
 		kfree(iov);
-out:
 	return err;
 }
 
-- 
1.7.10.4
