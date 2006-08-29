From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] Fix verify_iovec() to not allow overflow of iov_len values
Date: Tue, 29 Aug 2006 10:55:29 -0700
Message-ID: <1156874129.3147.2.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:161 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965190AbWH2Rzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 13:55:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7THtXou008781
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:55:33 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7THtXCm253464
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:55:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7THtXsf010293
	for <netdev@vger.kernel.org>; Tue, 29 Aug 2006 13:55:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

verify_iovec() has the following piece of code that allows overflow
of iov_len values in an iovec.

        for (ct = 0; ct < m->msg_iovlen; ct++) {
                err += iov[ct].iov_len;
                /*
                 * Goal is not to verify user data, but to prevent returning
                 * negative value, which is interpreted as errno.
                 * Overflow is still possible, but it is harmless.
                 */
                if (err < 0)
                        return -EMSGSIZE;
        }

The comment specifically says that overflow is harmless, but I don't see any
valid reason to allow overflow.

Also, iov_len is of type size_t which is a 64-bit value on 64-bit systems,
but we store and return the overall iovec length in an int.

This patch changes the return type of verify_iovec() and verify_compat_iovec()
to ssize_t and also validates that each iov_len value and the sum of all
the iov_len values do not overflow ssize_t. In case of a overflow, EINVAL is
returned.

The man pages for sendmsg/recvmsg also list this failure mode. 
  http://www.die.net/doc/linux/man/man3/sendmsg.3.html
    EINVAL
        The sum of the iov_len values overflows an ssize_t

This is based on some earlier patches from Chris Wright and Andrew Morton that
were incomplete.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3614090..25645b0 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -294,7 +294,7 @@ extern int csum_partial_copy_fromiovecen
 					  int offset, 
 					  unsigned int len, int *csump);
 
-extern int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode);
+extern ssize_t verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
 extern int move_addr_to_user(void *kaddr, int klen, void __user *uaddr, int __user *ulen);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, void *kaddr);
diff --git a/include/net/compat.h b/include/net/compat.h
index 9859b60..c30d648 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -31,7 +31,7 @@ #define compat_msghdr	msghdr		/* to avoi
 #endif /* defined(CONFIG_COMPAT) */
 
 extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
-extern int verify_compat_iovec(struct msghdr *, struct iovec *, char *, int);
+extern ssize_t verify_compat_iovec(struct msghdr *, struct iovec *, char *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
diff --git a/net/compat.c b/net/compat.c
index d5d69fa..f5d1a96 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -29,22 +29,29 @@ #include <net/sock.h>
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
-static inline int iov_from_user_compat_to_kern(struct iovec *kiov,
+static inline ssize_t iov_from_user_compat_to_kern(struct iovec *kiov,
 					  struct compat_iovec __user *uiov32,
 					  int niov)
 {
-	int tot_len = 0;
+	compat_ssize_t tot_len = 0;
 
 	while(niov > 0) {
 		compat_uptr_t buf;
-		compat_size_t len;
+		compat_ssize_t len;
 
 		if(get_user(len, &uiov32->iov_len) ||
 		   get_user(buf, &uiov32->iov_base)) {
 			tot_len = -EFAULT;
 			break;
 		}
+		/* Validate that each iov_len value and the sum of all the
+		 * iov_len values do not overflow ssize_t.
+		 */
+		if (len < 0)
+			return -EINVAL;	
 		tot_len += len;
+		if (tot_len < 0)
+			return -EINVAL;
 		kiov->iov_base = compat_ptr(buf);
 		kiov->iov_len = (__kernel_size_t) len;
 		uiov32++;
@@ -74,10 +81,10 @@ int get_compat_msghdr(struct msghdr *kms
 }
 
 /* I've named the args so it is easy to tell whose space the pointers are in. */
-int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
+ssize_t verify_compat_iovec(struct msghdr *kern_msg, struct iovec *kern_iov,
 		   char *kern_address, int mode)
 {
-	int tot_len;
+	ssize_t tot_len;
 
 	if(kern_msg->msg_namelen) {
 		if(mode==VERIFY_READ) {
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 65e4b56..14b0f8f 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -37,9 +37,10 @@ #include <net/sock.h>
  *	in any case.
  */
 
-int verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
+ssize_t verify_iovec(struct msghdr *m, struct iovec *iov, char *address, int mode)
 {
 	int size, err, ct;
+	ssize_t tot_len = 0;
 	
 	if (m->msg_namelen) {
 		if (mode == VERIFY_READ) {
@@ -61,17 +62,22 @@ int verify_iovec(struct msghdr *m, struc
 	err = 0;
 
 	for (ct = 0; ct < m->msg_iovlen; ct++) {
-		err += iov[ct].iov_len;
+		ssize_t len;
+
 		/*
-		 * Goal is not to verify user data, but to prevent returning
-		 * negative value, which is interpreted as errno.
-		 * Overflow is still possible, but it is harmless.
+		 * Goal is not to verify user data, but to prevent the cases 
+		 * where an iov_len value or the sum of all iov_len values
+		 * overflows ssize_t.
 		 */
-		if (err < 0)
-			return -EMSGSIZE;
+		len = (ssize_t)iov[ct].iov_len;
+		if (len < 0)
+			return -EINVAL;
+		tot_len += len;
+		if (tot_len < 0)
+			return -EINVAL;
 	}
 
-	return err;
+	return tot_len;
 }
 
 /*
diff --git a/net/socket.c b/net/socket.c
index b4848ce..7848180 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1766,7 +1766,8 @@ asmlinkage long sys_sendmsg(int fd, stru
 			/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
 	struct msghdr msg_sys;
-	int err, ctl_len, iov_size, total_len;
+	int err, ctl_len, iov_size;
+	ssize_t total_len;
 	int fput_needed;
 	
 	err = -EFAULT;
@@ -1796,12 +1797,13 @@ asmlinkage long sys_sendmsg(int fd, stru
 
 	/* This will also move the address data into kernel space */
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov, address, VERIFY_READ);
+		total_len = verify_compat_iovec(&msg_sys, iov, address, VERIFY_READ);
 	} else
-		err = verify_iovec(&msg_sys, iov, address, VERIFY_READ);
-	if (err < 0) 
+		total_len = verify_iovec(&msg_sys, iov, address, VERIFY_READ);
+	if (total_len < 0) {
+		err = total_len;
 		goto out_freeiov;
-	total_len = err;
+	}
 
 	err = -ENOBUFS;
 
@@ -1861,7 +1863,8 @@ asmlinkage long sys_recvmsg(int fd, stru
 	struct iovec *iov=iovstack;
 	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
-	int err, iov_size, total_len, len;
+	int err, iov_size, len;
+	ssize_t total_len;
 	int fput_needed;
 
 	/* kernel mode address */
@@ -1903,12 +1906,13 @@ asmlinkage long sys_recvmsg(int fd, stru
 	uaddr = (void __user *) msg_sys.msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
+		total_len = verify_compat_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
 	} else
-		err = verify_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
-	if (err < 0)
+		total_len = verify_iovec(&msg_sys, iov, addr, VERIFY_WRITE);
+	if (total_len < 0) {
+		err = total_len;
 		goto out_freeiov;
-	total_len=err;
+	}
 
 	cmsg_ptr = (unsigned long)msg_sys.msg_control;
 	msg_sys.msg_flags = 0;


