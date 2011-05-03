From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] net: Add sendmmsg socket system call
Date: Tue, 3 May 2011 16:21:35 +1000
Message-ID: <20110503162135.5e410fcf@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36247 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751796Ab1ECGVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 02:21:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds a multiple message send syscall and is the send
version of the existing recvmmsg syscall. This is heavily
based on the patch by Arnaldo that added recvmmsg.

I wrote a microbenchmark to test the performance gains of using
this new syscall:

http://ozlabs.org/~anton/junkcode/sendmmsg_test.c

The test was run on a ppc64 box with a 10 Gbit network card. The
benchmark can send both UDP and RAW ethernet packets.

64B UDP
# sendmmsg_test -u 192.168.1.2 12345 64 <batch>

batch   pkts/sec
1       804570
2       872800 (+ 8 %)
4       916556 (+14 %)
8       939712 (+17 %)
16      952688 (+18 %)
32      956448 (+19 %)
64      964800 (+20 %)

64B raw socket
# sendmmsg_test -r eth1 64 <batch>

batch   pkts/sec
1       1201449
2       1350028 (+12 %)
4       1461416 (+22 %)
8       1513080 (+26 %)
16      1541216 (+28 %)
32      1553440 (+29 %)
64      1557888 (+30 %)

We see a 20% improvement in throughput on UDP send and 30%
on raw socket send.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/net/socket.c
===================================================================
--- linux-net.orig/net/socket.c	2011-05-03 16:16:10.833560264 +1000
+++ linux-net/net/socket.c	2011-05-03 16:16:21.693758603 +1000
@@ -551,11 +551,10 @@ int sock_tx_timestamp(struct sock *sk, _
 }
 EXPORT_SYMBOL(sock_tx_timestamp);
 
-static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size)
+static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
+				       struct msghdr *msg, size_t size)
 {
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
-	int err;
 
 	sock_update_classid(sock->sk);
 
@@ -564,13 +563,17 @@ static inline int __sock_sendmsg(struct
 	si->msg = msg;
 	si->size = size;
 
-	err = security_socket_sendmsg(sock, msg, size);
-	if (err)
-		return err;
-
 	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
+static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+				 struct msghdr *msg, size_t size)
+{
+	int err = security_socket_sendmsg(sock, msg, size);
+
+	return err ?: __sock_sendmsg_nosec(iocb, sock, msg, size);
+}
+
 int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct kiocb iocb;
@@ -586,6 +589,20 @@ int sock_sendmsg(struct socket *sock, st
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
+int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private = &siocb;
+	ret = __sock_sendmsg_nosec(&iocb, sock, msg, size);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
 int kernel_sendmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size)
 {
@@ -1863,57 +1880,47 @@ SYSCALL_DEFINE2(shutdown, int, fd, int,
 #define COMPAT_NAMELEN(msg)	COMPAT_MSG(msg, msg_namelen)
 #define COMPAT_FLAGS(msg)	COMPAT_MSG(msg, msg_flags)
 
-/*
- *	BSD sendmsg interface
- */
-
-SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned, flags)
+static int __sys_sendmsg(struct socket *sock, struct msghdr __user *msg,
+			 struct msghdr *msg_sys, unsigned flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
-	struct socket *sock;
 	struct sockaddr_storage address;
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
 	unsigned char ctl[sizeof(struct cmsghdr) + 20]
 	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
-	struct msghdr msg_sys;
 	int err, ctl_len, iov_size, total_len;
-	int fput_needed;
 
 	err = -EFAULT;
 	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(&msg_sys, msg_compat))
+		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
-	} else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	} else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock)
-		goto out;
-
 	/* do not move before msg_sys is valid */
 	err = -EMSGSIZE;
-	if (msg_sys.msg_iovlen > UIO_MAXIOV)
-		goto out_put;
+	if (msg_sys->msg_iovlen > UIO_MAXIOV)
+		goto out;
 
 	/* Check whether to allocate the iovec area */
 	err = -ENOMEM;
-	iov_size = msg_sys.msg_iovlen * sizeof(struct iovec);
-	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
+	iov_size = msg_sys->msg_iovlen * sizeof(struct iovec);
+	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
 		if (!iov)
-			goto out_put;
+			goto out;
 	}
 
 	/* This will also move the address data into kernel space */
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov,
+		err = verify_compat_iovec(msg_sys, iov,
 					  (struct sockaddr *)&address,
 					  VERIFY_READ);
 	} else
-		err = verify_iovec(&msg_sys, iov,
+		err = verify_iovec(msg_sys, iov,
 				   (struct sockaddr *)&address,
 				   VERIFY_READ);
 	if (err < 0)
@@ -1922,17 +1929,17 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 
 	err = -ENOBUFS;
 
-	if (msg_sys.msg_controllen > INT_MAX)
+	if (msg_sys->msg_controllen > INT_MAX)
 		goto out_freeiov;
-	ctl_len = msg_sys.msg_controllen;
+	ctl_len = msg_sys->msg_controllen;
 	if ((MSG_CMSG_COMPAT & flags) && ctl_len) {
 		err =
-		    cmsghdr_from_user_compat_to_kern(&msg_sys, sock->sk, ctl,
+		    cmsghdr_from_user_compat_to_kern(msg_sys, sock->sk, ctl,
 						     sizeof(ctl));
 		if (err)
 			goto out_freeiov;
-		ctl_buf = msg_sys.msg_control;
-		ctl_len = msg_sys.msg_controllen;
+		ctl_buf = msg_sys->msg_control;
+		ctl_len = msg_sys->msg_controllen;
 	} else if (ctl_len) {
 		if (ctl_len > sizeof(ctl)) {
 			ctl_buf = sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
@@ -1941,21 +1948,22 @@ SYSCALL_DEFINE3(sendmsg, int, fd, struct
 		}
 		err = -EFAULT;
 		/*
-		 * Careful! Before this, msg_sys.msg_control contains a user pointer.
+		 * Careful! Before this, msg_sys->msg_control contains a user pointer.
 		 * Afterwards, it will be a kernel pointer. Thus the compiler-assisted
 		 * checking falls down on this.
 		 */
 		if (copy_from_user(ctl_buf,
-				   (void __user __force *)msg_sys.msg_control,
+				   (void __user __force *)msg_sys->msg_control,
 				   ctl_len))
 			goto out_freectl;
-		msg_sys.msg_control = ctl_buf;
+		msg_sys->msg_control = ctl_buf;
 	}
-	msg_sys.msg_flags = flags;
+	msg_sys->msg_flags = flags;
 
 	if (sock->file->f_flags & O_NONBLOCK)
-		msg_sys.msg_flags |= MSG_DONTWAIT;
-	err = sock_sendmsg(sock, &msg_sys, total_len);
+		msg_sys->msg_flags |= MSG_DONTWAIT;
+	err = (nosec ? sock_sendmsg_nosec : sock_sendmsg)(sock, msg_sys,
+							  total_len);
 
 out_freectl:
 	if (ctl_buf != ctl)
@@ -1963,12 +1971,114 @@ out_freectl:
 out_freeiov:
 	if (iov != iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
-out_put:
+out:
+	return err;
+}
+
+/*
+ *	BSD sendmsg interface
+ */
+
+SYSCALL_DEFINE3(sendmsg, int, fd, struct msghdr __user *, msg, unsigned, flags)
+{
+	int fput_needed, err;
+	struct msghdr msg_sys;
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	err = __sys_sendmsg(sock, msg, &msg_sys, flags, 0);
+
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
 
+/*
+ *	Linux sendmmsg interface
+ */
+
+int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
+		   unsigned int flags)
+{
+	int fput_needed, err, datagrams;
+	struct socket *sock;
+	struct mmsghdr __user *entry;
+	struct compat_mmsghdr __user *compat_entry;
+	struct msghdr msg_sys;
+
+	datagrams = 0;
+
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (!sock)
+		return err;
+
+	err = sock_error(sock->sk);
+	if (err)
+		goto out_put;
+
+	entry = mmsg;
+	compat_entry = (struct compat_mmsghdr __user *)mmsg;
+
+	while (datagrams < vlen) {
+		/*
+		 * No need to ask LSM for more than the first datagram.
+		 */
+		if (MSG_CMSG_COMPAT & flags) {
+			err = __sys_sendmsg(sock, (struct msghdr __user *)compat_entry,
+					    &msg_sys, flags, datagrams);
+			if (err < 0)
+				break;
+			err = __put_user(err, &compat_entry->msg_len);
+			++compat_entry;
+		} else {
+			err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
+					    &msg_sys, flags, datagrams);
+			if (err < 0)
+				break;
+			err = put_user(err, &entry->msg_len);
+			++entry;
+		}
+
+		if (err)
+			break;
+		++datagrams;
+	}
+
+out_put:
+	fput_light(sock->file, fput_needed);
+
+	if (err == 0)
+		return datagrams;
+
+	if (datagrams != 0) {
+		/*
+		 * We may send less entries than requested (vlen) if the
+		 * sock is non blocking...
+		 */
+		if (err != -EAGAIN) {
+			/*
+			 * ... or if sendmsg returns an error after we
+			 * send some datagrams, where we record the
+			 * error to return on the next call or if the
+			 * app asks about it using getsockopt(SO_ERROR).
+			 */
+			sock->sk->sk_err = -err;
+		}
+
+		return datagrams;
+	}
+
+	return err;
+}
+
+SYSCALL_DEFINE4(sendmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags)
+{
+	return __sys_sendmmsg(fd, mmsg, vlen, flags);
+}
+
 static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 			 struct msghdr *msg_sys, unsigned flags, int nosec)
 {
@@ -2214,11 +2324,11 @@ SYSCALL_DEFINE5(recvmmsg, int, fd, struc
 #ifdef __ARCH_WANT_SYS_SOCKETCALL
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[20] = {
+static const unsigned char nargs[21] = {
 	AL(0), AL(3), AL(3), AL(3), AL(2), AL(3),
 	AL(3), AL(3), AL(4), AL(4), AL(4), AL(6),
 	AL(6), AL(2), AL(5), AL(5), AL(3), AL(3),
-	AL(4), AL(5)
+	AL(4), AL(5), AL(4)
 };
 
 #undef AL
@@ -2238,7 +2348,7 @@ SYSCALL_DEFINE2(socketcall, int, call, u
 	int err;
 	unsigned int len;
 
-	if (call < 1 || call > SYS_RECVMMSG)
+	if (call < 1 || call > SYS_SENDMMSG)
 		return -EINVAL;
 
 	len = nargs[call];
@@ -2313,6 +2423,9 @@ SYSCALL_DEFINE2(socketcall, int, call, u
 	case SYS_SENDMSG:
 		err = sys_sendmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_SENDMMSG:
+		err = sys_sendmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3]);
+		break;
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
Index: linux-net/net/compat.c
===================================================================
--- linux-net.orig/net/compat.c	2011-05-03 16:16:10.823560081 +1000
+++ linux-net/net/compat.c	2011-05-03 16:16:21.693758603 +1000
@@ -722,11 +722,11 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
 
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[20] = {
+static unsigned char nas[21] = {
 	AL(0), AL(3), AL(3), AL(3), AL(2), AL(3),
 	AL(3), AL(3), AL(4), AL(4), AL(4), AL(6),
 	AL(6), AL(2), AL(5), AL(5), AL(3), AL(3),
-	AL(4), AL(5)
+	AL(4), AL(5), AL(4)
 };
 #undef AL
 
@@ -735,6 +735,13 @@ asmlinkage long compat_sys_sendmsg(int f
 	return sys_sendmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_sendmmsg(int fd, struct compat_mmsghdr __user *mmsg,
+				    unsigned vlen, unsigned int flags)
+{
+	return __sys_sendmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+			      flags | MSG_CMSG_COMPAT);
+}
+
 asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, unsigned int flags)
 {
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
@@ -780,7 +787,7 @@ asmlinkage long compat_sys_socketcall(in
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_RECVMMSG)
+	if (call < SYS_SOCKET || call > SYS_SENDMMSG)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -839,6 +846,9 @@ asmlinkage long compat_sys_socketcall(in
 	case SYS_SENDMSG:
 		ret = compat_sys_sendmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_SENDMMSG:
+		ret = compat_sys_sendmmsg(a0, compat_ptr(a1), a[2], a[3]);
+		break;
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
Index: linux-net/include/linux/socket.h
===================================================================
--- linux-net.orig/include/linux/socket.h	2011-05-03 16:16:10.973562820 +1000
+++ linux-net/include/linux/socket.h	2011-05-03 16:16:21.693758603 +1000
@@ -333,5 +333,7 @@ struct timespec;
 
 extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 			  unsigned int flags, struct timespec *timeout);
+extern int __sys_sendmmsg(int fd, struct mmsghdr __user *mmsg,
+			  unsigned int vlen, unsigned int flags);
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
Index: linux-net/include/linux/syscalls.h
===================================================================
--- linux-net.orig/include/linux/syscalls.h	2011-05-03 16:16:11.003563369 +1000
+++ linux-net/include/linux/syscalls.h	2011-05-03 16:16:21.693758603 +1000
@@ -610,6 +610,8 @@ asmlinkage long sys_send(int, void __use
 asmlinkage long sys_sendto(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int);
 asmlinkage long sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags);
+asmlinkage long sys_sendmmsg(int fd, struct mmsghdr __user *msg,
+			     unsigned int vlen, unsigned flags);
 asmlinkage long sys_recv(int, void __user *, size_t, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
Index: linux-net/include/net/compat.h
===================================================================
--- linux-net.orig/include/net/compat.h	2011-05-03 16:16:10.963562637 +1000
+++ linux-net/include/net/compat.h	2011-05-03 16:16:21.693758603 +1000
@@ -43,6 +43,8 @@ extern int compat_sock_get_timestampns(s
 extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
+extern asmlinkage long compat_sys_sendmmsg(int, struct compat_mmsghdr __user *,
+					   unsigned, unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
 					   unsigned, unsigned,
Index: linux-net/kernel/sys_ni.c
===================================================================
--- linux-net.orig/kernel/sys_ni.c	2011-05-03 16:16:11.023563733 +1000
+++ linux-net/kernel/sys_ni.c	2011-05-03 16:16:21.693758603 +1000
@@ -46,7 +46,9 @@ cond_syscall(sys_getsockopt);
 cond_syscall(compat_sys_getsockopt);
 cond_syscall(sys_shutdown);
 cond_syscall(sys_sendmsg);
+cond_syscall(sys_sendmmsg);
 cond_syscall(compat_sys_sendmsg);
+cond_syscall(compat_sys_sendmmsg);
 cond_syscall(sys_recvmsg);
 cond_syscall(sys_recvmmsg);
 cond_syscall(compat_sys_recvmsg);
Index: linux-net/include/linux/net.h
===================================================================
--- linux-net.orig/include/linux/net.h	2011-05-03 16:16:10.983563003 +1000
+++ linux-net/include/linux/net.h	2011-05-03 16:16:21.693758603 +1000
@@ -42,6 +42,7 @@
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
 #define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
 #define SYS_RECVMMSG	19		/* sys_recvmmsg(2)		*/
+#define SYS_SENDMMSG	20		/* sys_sendmmsg(2)		*/
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
Index: linux-net/arch/powerpc/include/asm/systbl.h
===================================================================
--- linux-net.orig/arch/powerpc/include/asm/systbl.h	2011-05-03 16:16:10.873560993 +1000
+++ linux-net/arch/powerpc/include/asm/systbl.h	2011-05-03 16:16:21.693758603 +1000
@@ -352,3 +352,4 @@ SYSCALL_SPU(name_to_handle_at)
 COMPAT_SYS_SPU(open_by_handle_at)
 COMPAT_SYS_SPU(clock_adjtime)
 SYSCALL_SPU(syncfs)
+COMPAT_SYS_SPU(sendmmsg)
Index: linux-net/arch/powerpc/include/asm/unistd.h
===================================================================
--- linux-net.orig/arch/powerpc/include/asm/unistd.h	2011-05-03 16:16:10.853560629 +1000
+++ linux-net/arch/powerpc/include/asm/unistd.h	2011-05-03 16:16:21.693758603 +1000
@@ -371,10 +371,11 @@
 #define __NR_open_by_handle_at	346
 #define __NR_clock_adjtime	347
 #define __NR_syncfs		348
+#define __NR_sendmmsg		349
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		349
+#define __NR_syscalls		350
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
Index: linux-net/arch/x86/include/asm/unistd_32.h
===================================================================
--- linux-net.orig/arch/x86/include/asm/unistd_32.h	2011-05-03 16:16:10.883561176 +1000
+++ linux-net/arch/x86/include/asm/unistd_32.h	2011-05-03 16:16:21.693758603 +1000
@@ -350,10 +350,11 @@
 #define __NR_open_by_handle_at  342
 #define __NR_clock_adjtime	343
 #define __NR_syncfs             344
+#define __NR_sendmmsg		345
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 345
+#define NR_syscalls 346
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
Index: linux-net/arch/x86/include/asm/unistd_64.h
===================================================================
--- linux-net.orig/arch/x86/include/asm/unistd_64.h	2011-05-03 16:16:10.903561542 +1000
+++ linux-net/arch/x86/include/asm/unistd_64.h	2011-05-03 16:16:21.693758603 +1000
@@ -677,6 +677,8 @@ __SYSCALL(__NR_open_by_handle_at, sys_op
 __SYSCALL(__NR_clock_adjtime, sys_clock_adjtime)
 #define __NR_syncfs                             306
 __SYSCALL(__NR_syncfs, sys_syncfs)
+#define __NR_sendmmsg				307
+__SYSCALL(__NR_sendmmsg, sys_sendmmsg)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
Index: linux-net/arch/x86/kernel/syscall_table_32.S
===================================================================
--- linux-net.orig/arch/x86/kernel/syscall_table_32.S	2011-05-03 16:16:10.923561908 +1000
+++ linux-net/arch/x86/kernel/syscall_table_32.S	2011-05-03 16:16:21.693758603 +1000
@@ -344,3 +344,4 @@ ENTRY(sys_call_table)
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_sendmmsg		/* 345 */
Index: linux-net/arch/x86/ia32/ia32entry.S
===================================================================
--- linux-net.orig/arch/x86/ia32/ia32entry.S	2011-05-03 16:16:10.943562272 +1000
+++ linux-net/arch/x86/ia32/ia32entry.S	2011-05-03 16:16:21.693758603 +1000
@@ -848,4 +848,5 @@ ia32_sys_call_table:
 	.quad compat_sys_open_by_handle_at
 	.quad compat_sys_clock_adjtime
 	.quad sys_syncfs
+	.quad compat_sys_sendmmsg	/* 345 */
 ia32_syscall_end:
