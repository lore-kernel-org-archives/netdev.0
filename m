From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 1/5] separate kernel- and userland-side msghdr
Date: Tue, 18 Nov 2014 19:41:34 +0000
Message-ID: <20141118194134.GB14641@ZenIV.linux.org.uk>
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

Kernel-side struct msghdr is (currently) using the same layout as
userland one, but it's not a one-to-one copy - even without considering
32bit compat issues, we have msg_iov, msg_name and msg_control copied
to kernel[1].  It's fairly localized, so we get away with a few functions
where that knowledge is needed (and we could shrink that set even
more).  Pretty much everything deals with the kernel-side variant and
the few places that want userland one just use a bunch of force-casts
to paper over the differences.

The thing is, kernel-side definition of struct msghdr is *not* exposed
in include/uapi - libc doesn't see it, etc.  So we can add struct user_msghdr,
with proper annotations and let the few places that ever deal with those
beasts use it for userland pointers.  Saner typechecking aside, that will
allow to change the layout of kernel-side msghdr - e.g. replace
msg_iov/msg_iovlen there with struct iov_iter, getting rid of the need
to modify the iovec as we copy data to/from it, etc.

We could introduce kernel_msghdr instead, but that would create much more
noise - the absolute majority of the instances would need to have the
type switched to kernel_msghdr and definition of struct msghdr in
include/linux/socket.h is not going to be seen by userland anyway.

This commit just introduces user_msghdr and switches the few places that
are dealing with userland-side msghdr to it.

[1] actually, it's even trickier than that - we copy msg_control for
sendmsg, but keep the userland address on recvmsg.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 arch/arm/kernel/sys_oabi-compat.c |    4 ++--
 include/linux/socket.h            |   16 +++++++++++++---
 include/linux/syscalls.h          |    6 +++---
 net/compat.c                      |    4 ++--
 net/socket.c                      |   29 ++++++++++++++++-------------
 5 files changed, 36 insertions(+), 23 deletions(-)

diff --git a/arch/arm/kernel/sys_oabi-compat.c b/arch/arm/kernel/sys_oabi-compat.c
index e90a314..b83f3b7 100644
--- a/arch/arm/kernel/sys_oabi-compat.c
+++ b/arch/arm/kernel/sys_oabi-compat.c
@@ -400,7 +400,7 @@ asmlinkage long sys_oabi_sendto(int fd, void __user *buff,
 	return sys_sendto(fd, buff, len, flags, addr, addrlen);
 }
 
-asmlinkage long sys_oabi_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
+asmlinkage long sys_oabi_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
 {
 	struct sockaddr __user *addr;
 	int msg_namelen;
@@ -446,7 +446,7 @@ asmlinkage long sys_oabi_socketcall(int call, unsigned long __user *args)
 		break;
 	case SYS_SENDMSG:
 		if (copy_from_user(a, args, 3 * sizeof(long)) == 0)
-			r = sys_oabi_sendmsg(a[0], (struct msghdr __user *)a[1], a[2]);
+			r = sys_oabi_sendmsg(a[0], (struct user_msghdr __user *)a[1], a[2]);
 		break;
 	default:
 		r = sys_socketcall(call, args);
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bb9b836..51bd666 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -53,10 +53,20 @@ struct msghdr {
 	__kernel_size_t	msg_controllen;	/* ancillary data buffer length */
 	unsigned int	msg_flags;	/* flags on received message */
 };
+ 
+struct user_msghdr {
+	void		__user *msg_name;	/* ptr to socket address structure */
+	int		msg_namelen;		/* size of socket address structure */
+	struct iovec	__user *msg_iov;	/* scatter/gather array */
+	__kernel_size_t	msg_iovlen;		/* # elements in msg_iov */
+	void		__user *msg_control;	/* ancillary data */
+	__kernel_size_t	msg_controllen;		/* ancillary data buffer length */
+	unsigned int	msg_flags;		/* flags on received message */
+};
 
 /* For recvmmsg/sendmmsg */
 struct mmsghdr {
-	struct msghdr   msg_hdr;
+	struct user_msghdr  msg_hdr;
 	unsigned int        msg_len;
 };
 
@@ -319,8 +329,8 @@ extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 struct timespec;
 
 /* The __sys_...msg variants allow MSG_CMSG_COMPAT */
-extern long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
-extern long __sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags);
+extern long __sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags);
+extern long __sys_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags);
 extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 			  unsigned int flags, struct timespec *timeout);
 extern int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index bda9b81..c9afdc7 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -25,7 +25,7 @@ struct linux_dirent64;
 struct list_head;
 struct mmap_arg_struct;
 struct msgbuf;
-struct msghdr;
+struct user_msghdr;
 struct mmsghdr;
 struct msqid_ds;
 struct new_utsname;
@@ -601,13 +601,13 @@ asmlinkage long sys_getpeername(int, struct sockaddr __user *, int __user *);
 asmlinkage long sys_send(int, void __user *, size_t, unsigned);
 asmlinkage long sys_sendto(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int);
-asmlinkage long sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags);
+asmlinkage long sys_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags);
 asmlinkage long sys_sendmmsg(int fd, struct mmsghdr __user *msg,
 			     unsigned int vlen, unsigned flags);
 asmlinkage long sys_recv(int, void __user *, size_t, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
-asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
+asmlinkage long sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags);
 asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
 			     unsigned int vlen, unsigned flags,
 			     struct timespec __user *timeout);
diff --git a/net/compat.c b/net/compat.c
index bc8aeef..562e920 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -740,7 +740,7 @@ COMPAT_SYSCALL_DEFINE3(sendmsg, int, fd, struct compat_msghdr __user *, msg, uns
 {
 	if (flags & MSG_CMSG_COMPAT)
 		return -EINVAL;
-	return __sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
+	return __sys_sendmsg(fd, (struct user_msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
 COMPAT_SYSCALL_DEFINE4(sendmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
@@ -756,7 +756,7 @@ COMPAT_SYSCALL_DEFINE3(recvmsg, int, fd, struct compat_msghdr __user *, msg, uns
 {
 	if (flags & MSG_CMSG_COMPAT)
 		return -EINVAL;
-	return __sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
+	return __sys_recvmsg(fd, (struct user_msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
 COMPAT_SYSCALL_DEFINE4(recv, int, fd, void __user *, buf, compat_size_t, len, unsigned int, flags)
diff --git a/net/socket.c b/net/socket.c
index fe20c31..0ae8147 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1989,8 +1989,11 @@ struct used_address {
 };
 
 static int copy_msghdr_from_user(struct msghdr *kmsg,
-				 struct msghdr __user *umsg)
+				 struct user_msghdr __user *umsg)
 {
+	/* We are relying on the (currently) identical layouts.  Once
+	 * the kernel-side changes, this place will need to be updated
+	 */
 	if (copy_from_user(kmsg, umsg, sizeof(struct msghdr)))
 		return -EFAULT;
 
@@ -2005,7 +2008,7 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 	return 0;
 }
 
-static int ___sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
+static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags,
 			 struct used_address *used_address)
 {
@@ -2123,7 +2126,7 @@ out:
  *	BSD sendmsg interface
  */
 
-long __sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
+long __sys_sendmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
@@ -2140,7 +2143,7 @@ out:
 	return err;
 }
 
-SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned int, flags)
+SYSCALL_DEFINE3(sendmsg, int, fd, struct user_msghdr __user *, msg, unsigned int, flags)
 {
 	if (flags & MSG_CMSG_COMPAT)
 		return -EINVAL;
@@ -2177,7 +2180,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 
 	while (datagrams < vlen) {
 		if (MSG_CMSG_COMPAT & flags) {
-			err = ___sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
+			err = ___sys_sendmsg(sock, (struct user_msghdr __user *)compat_entry,
 					     &msg_sys, flags, &used_address);
 			if (err < 0)
 				break;
@@ -2185,7 +2188,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 			++compat_entry;
 		} else {
 			err = ___sys_sendmsg(sock,
-					     (struct msghdr __user *)entry,
+					     (struct user_msghdr __user *)entry,
 					     &msg_sys, flags, &used_address);
 			if (err < 0)
 				break;
@@ -2215,7 +2218,7 @@ SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
 	return __sys_sendmmsg(fd, mmsg, vlen, flags);
 }
 
-static int ___sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
+static int ___sys_recvmsg(struct socket *sock, struct user_msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned int flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =
@@ -2311,7 +2314,7 @@ out:
  *	BSD recvmsg interface
  */
 
-long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags)
+long __sys_recvmsg(int fd, struct user_msghdr __user *msg, unsigned flags)
 {
 	int fput_needed, err;
 	struct msghdr msg_sys;
@@ -2328,7 +2331,7 @@ out:
 	return err;
 }
 
-SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
+SYSCALL_DEFINE3(recvmsg, int, fd, struct user_msghdr __user *, msg,
 		unsigned int, flags)
 {
 	if (flags & MSG_CMSG_COMPAT)
@@ -2373,7 +2376,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 		 * No need to ask LSM for more than the first datagram.
 		 */
 		if (MSG_CMSG_COMPAT & flags) {
-			err = ___sys_recvmsg(sock, (struct msghdr __user *)compat_entry,
+			err = ___sys_recvmsg(sock, (struct user_msghdr __user *)compat_entry,
 					     &msg_sys, flags & ~MSG_WAITFORONE,
 					     datagrams);
 			if (err < 0)
@@ -2382,7 +2385,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 			++compat_entry;
 		} else {
 			err = ___sys_recvmsg(sock,
-					     (struct msghdr __user *)entry,
+					     (struct user_msghdr __user *)entry,
 					     &msg_sys, flags & ~MSG_WAITFORONE,
 					     datagrams);
 			if (err < 0)
@@ -2571,13 +2574,13 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 				   (int __user *)a[4]);
 		break;
 	case SYS_SENDMSG:
-		err = sys_sendmsg(a0, (struct msghdr __user *)a1, a[2]);
+		err = sys_sendmsg(a0, (struct user_msghdr __user *)a1, a[2]);
 		break;
 	case SYS_SENDMMSG:
 		err = sys_sendmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3]);
 		break;
 	case SYS_RECVMSG:
-		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
+		err = sys_recvmsg(a0, (struct user_msghdr __user *)a1, a[2]);
 		break;
 	case SYS_RECVMMSG:
 		err = sys_recvmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3],
-- 
1.7.10.4
