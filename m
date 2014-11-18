From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 5/5] fold verify_iovec() into copy_msghdr_from_user()
Date: Tue, 18 Nov 2014 19:43:45 +0000
Message-ID: <20141118194345.GF14641@ZenIV.linux.org.uk>
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

... and do the same on the compat side of things.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/socket.h |    1 -
 include/net/compat.h   |    5 ++-
 net/compat.c           |   52 ++++++++++++---------------
 net/core/iovec.c       |   38 --------------------
 net/socket.c           |   93 +++++++++++++++++++++++++++---------------------
 5 files changed, 77 insertions(+), 112 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 51bd666..de52228 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -322,7 +322,6 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
 extern unsigned long iov_pages(const struct iovec *iov, int offset,
 			       unsigned long nr_segs);
 
-extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *address, int mode);
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr_storage *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
diff --git a/include/net/compat.h b/include/net/compat.h
index 3b603b1..42a9c84 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -40,9 +40,8 @@ int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 #define compat_mmsghdr	mmsghdr
 #endif /* defined(CONFIG_COMPAT) */
 
-int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
-int verify_compat_iovec(struct msghdr *, struct iovec *,
-			struct sockaddr_storage *, int);
+ssize_t get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *,
+		      struct sockaddr __user **, struct iovec **);
 asmlinkage long compat_sys_sendmsg(int, struct compat_msghdr __user *,
 				   unsigned int);
 asmlinkage long compat_sys_sendmmsg(int, struct compat_mmsghdr __user *,
diff --git a/net/compat.c b/net/compat.c
index 7b4b6ad..062f157 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -31,14 +31,18 @@
 #include <asm/uaccess.h>
 #include <net/compat.h>
 
-int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
+ssize_t get_compat_msghdr(struct msghdr *kmsg,
+			  struct compat_msghdr __user *umsg,
+			  struct sockaddr __user **save_addr,
+			  struct iovec **iov)
 {
-	compat_uptr_t tmp1, tmp2, tmp3;
+	compat_uptr_t uaddr, uiov, tmp3;
+	ssize_t err;
 
 	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
-	    __get_user(tmp1, &umsg->msg_name) ||
+	    __get_user(uaddr, &umsg->msg_name) ||
 	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
-	    __get_user(tmp2, &umsg->msg_iov) ||
+	    __get_user(uiov, &umsg->msg_iov) ||
 	    __get_user(kmsg->msg_iovlen, &umsg->msg_iovlen) ||
 	    __get_user(tmp3, &umsg->msg_control) ||
 	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
@@ -46,44 +50,32 @@ int get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg)
 		return -EFAULT;
 	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
 		kmsg->msg_namelen = sizeof(struct sockaddr_storage);
-	kmsg->msg_name = compat_ptr(tmp1);
-	kmsg->msg_iov = compat_ptr(tmp2);
 	kmsg->msg_control = compat_ptr(tmp3);
-	return 0;
-}
 
-/* I've named the args so it is easy to tell whose space the pointers are in. */
-int verify_compat_iovec(struct msghdr *kern_msg, struct iovec *iov,
-		   struct sockaddr_storage *kern_address, int mode)
-{
-	struct compat_iovec __user *p;
-	struct iovec *res;
-	int err;
+	if (save_addr)
+		*save_addr = compat_ptr(uaddr);
 
-	if (kern_msg->msg_name && kern_msg->msg_namelen) {
-		if (mode == WRITE) {
-			int err = move_addr_to_kernel(kern_msg->msg_name,
-						      kern_msg->msg_namelen,
-						      kern_address);
+	if (uaddr && kmsg->msg_namelen) {
+		if (!save_addr) {
+			err = move_addr_to_kernel(compat_ptr(uaddr),
+						  kmsg->msg_namelen,
+						  kmsg->msg_name);
 			if (err < 0)
 				return err;
 		}
-		kern_msg->msg_name = kern_address;
 	} else {
-		kern_msg->msg_name = NULL;
-		kern_msg->msg_namelen = 0;
+		kmsg->msg_name = NULL;
+		kmsg->msg_namelen = 0;
 	}
 
-	if (kern_msg->msg_iovlen > UIO_MAXIOV)
+	if (kmsg->msg_iovlen > UIO_MAXIOV)
 		return -EMSGSIZE;
 
-	p = (struct compat_iovec __user *)kern_msg->msg_iov;
-	err = compat_rw_copy_check_uvector(mode, p, kern_msg->msg_iovlen,
-					   UIO_FASTIOV, iov, &res);
+	err = compat_rw_copy_check_uvector(save_addr ? READ : WRITE,
+					   compat_ptr(uiov), kmsg->msg_iovlen,
+					   UIO_FASTIOV, *iov, iov);
 	if (err >= 0)
-		kern_msg->msg_iov = res;
-	else if (res != iov)
-		kfree(res);
+		kmsg->msg_iov = *iov;
 	return err;
 }
 
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 4a35b21..fa3eed9 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -28,44 +28,6 @@
 #include <net/sock.h>
 
 /*
- *	Verify iovec. The caller must ensure that the iovec is big enough
- *	to hold the message iovec.
- *
- *	Save time not doing access_ok. copy_*_user will make this work
- *	in any case.
- */
-
-int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr_storage *address, int mode)
-{
-	struct iovec *res;
-	int err;
-
-	if (m->msg_name && m->msg_namelen) {
-		if (mode == WRITE) {
-			void __user *namep = (void __user __force *)m->msg_name;
-			int err = move_addr_to_kernel(namep, m->msg_namelen,
-						  address);
-			if (err < 0)
-				return err;
-		}
-		m->msg_name = address;
-	} else {
-		m->msg_name = NULL;
-		m->msg_namelen = 0;
-	}
-	if (m->msg_iovlen > UIO_MAXIOV)
-		return -EMSGSIZE;
-
-	err = rw_copy_check_uvector(mode, (void __user __force *)m->msg_iov,
-				    m->msg_iovlen, UIO_FASTIOV, iov, &res);
-	if (err >= 0)
-		m->msg_iov = res;
-	else if (res != iov)
-		kfree(res);
-	return err;
-}
-
-/*
  *	And now for the all-in-one: copy and checksum from a user iovec
  *	directly to a datagram
  *	Calls to csum_partial but the last must be in 32 bit chunks
diff --git a/net/socket.c b/net/socket.c
index 59020f0..ee3ee39 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1988,16 +1988,26 @@ struct used_address {
 	unsigned int name_len;
 };
 
-static int copy_msghdr_from_user(struct msghdr *kmsg,
-				 struct user_msghdr __user *umsg)
+static ssize_t copy_msghdr_from_user(struct msghdr *kmsg,
+				     struct user_msghdr __user *umsg,
+				     struct sockaddr __user **save_addr,
+				     struct iovec **iov)
 {
-	/* We are relying on the (currently) identical layouts.  Once
-	 * the kernel-side changes, this place will need to be updated
-	 */
-	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
+	struct sockaddr __user *uaddr;
+	struct iovec __user *uiov;
+	ssize_t err;
+
+	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
+	    __get_user(uaddr, &umsg->msg_name) ||
+	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
+	    __get_user(uiov, &umsg->msg_iov) ||
+	    __get_user(kmsg->msg_iovlen, &umsg->msg_iovlen) ||
+	    __get_user(kmsg->msg_control, &umsg->msg_control) ||
+	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
+	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
 		return -EFAULT;
 
-	if (kmsg->msg_name == NULL)
+	if (!uaddr)
 		kmsg->msg_namelen = 0;
 
 	if (kmsg->msg_namelen < 0)
@@ -2005,7 +2015,31 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 
 	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
 		kmsg->msg_namelen = sizeof(struct sockaddr_storage);
-	return 0;
+
+	if (save_addr)
+		*save_addr = uaddr;
+
+	if (uaddr && kmsg->msg_namelen) {
+		if (!save_addr) {
+			err = move_addr_to_kernel(uaddr, kmsg->msg_namelen,
+						  kmsg->msg_name);
+			if (err < 0)
+				return err;
+		}
+	} else {
+		kmsg->msg_name = NULL;
+		kmsg->msg_namelen = 0;
+	}
+
+	if (kmsg->msg_iovlen > UIO_MAXIOV)
+		return -EMSGSIZE;
+
+	err = rw_copy_check_uvector(save_addr ? READ : WRITE,
+				    uiov, kmsg->msg_iovlen,
+				    UIO_FASTIOV, *iov, iov);
+	if (err >= 0)
+		kmsg->msg_iov = *iov;
+	return err;
 }
 
 static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
@@ -2020,26 +2054,17 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
-	int err, ctl_len, total_len;
+	int ctl_len, total_len;
+	ssize_t err;
 
-	err = -EFAULT;
-	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(msg_sys, msg_compat))
-			return -EFAULT;
-	} else {
-		err = copy_msghdr_from_user(msg_sys, msg);
-		if (err)
-			return err;
-	}
+	msg_sys->msg_name = &address;
 
-	/* This will also move the address data into kernel space */
 	if (MSG_CMSG_COMPAT & flags)
-		err = verify_compat_iovec(msg_sys, iovstack, &address, WRITE);
+		err = get_compat_msghdr(msg_sys, msg_compat, NULL, &iov);
 	else
-		err = verify_iovec(msg_sys, iovstack, &address, WRITE);
+		err = copy_msghdr_from_user(msg_sys, msg, NULL, &iov);
 	if (err < 0)
 		goto out_freeiov;
-	iov = msg_sys->msg_iov;
 	total_len = err;
 
 	err = -ENOBUFS;
@@ -2215,36 +2240,24 @@ static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	unsigned long cmsg_ptr;
-	int err, total_len, len;
+	int total_len, len;
+	ssize_t err;
 
 	/* kernel mode address */
 	struct sockaddr_storage addr;
 
 	/* user mode address pointers */
 	struct sockaddr __user *uaddr;
-	int __user *uaddr_len;
+	int __user *uaddr_len = COMPAT_NAMELEN(msg);
 
-	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(msg_sys, msg_compat))
-			return -EFAULT;
-	} else {
-		err = copy_msghdr_from_user(msg_sys, msg);
-		if (err)
-			return err;
-	}
+	msg_sys->msg_name = &addr;
 
-	/* Save the user-mode address (verify_iovec will change the
-	 * kernel msghdr to use the kernel address space)
-	 */
-	uaddr = (__force void __user *)msg_sys->msg_name;
-	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags)
-		err = verify_compat_iovec(msg_sys, iovstack, &addr, READ);
+		err = get_compat_msghdr(msg_sys, msg_compat, &uaddr, &iov);
 	else
-		err = verify_iovec(msg_sys, iovstack, &addr, READ);
+		err = copy_msghdr_from_user(msg_sys, msg, &uaddr, &iov);
 	if (err < 0)
 		goto out_freeiov;
-	iov = msg_sys->msg_iov;
 	total_len = err;
 
 	cmsg_ptr = (unsigned long)msg_sys->msg_control;
-- 
1.7.10.4
