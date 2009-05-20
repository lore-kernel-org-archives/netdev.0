From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 20 May 2009 20:06:52 -0300
Message-ID: <20090520230652.GB5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34763 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753928AbZETXG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 May 2009 19:06:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meaning receive multiple messages, reducing the number of syscalls and
net stack entry/exit operations.

Next patches will introduce mechanisms where protocols that want to
optimize this operation will provide an unlocked_recvmsg operation.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 arch/alpha/kernel/systbls.S      |    1 +
 arch/arm/kernel/calls.S          |    1 +
 arch/ia64/kernel/entry.S         |    1 +
 arch/mips/kernel/scall32-o32.S   |    2 +
 arch/mips/kernel/scall64-64.S    |    1 +
 arch/mips/kernel/scall64-n32.S   |    1 +
 arch/mips/kernel/scall64-o32.S   |    1 +
 arch/sh/kernel/syscalls_64.S     |    1 +
 arch/sparc/kernel/systbls_64.S   |    2 +-
 arch/x86/include/asm/unistd_64.h |    2 +
 include/linux/socket.h           |    6 +++
 include/linux/syscalls.h         |    3 ++
 include/net/compat.h             |    7 ++++
 kernel/sys_ni.c                  |    2 +
 net/compat.c                     |    7 ++++
 net/socket.c                     |   72 ++++++++++++++++++++++++++++++-------
 16 files changed, 95 insertions(+), 15 deletions(-)

diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.S
index 95c9aef..cda6b8b 100644
--- a/arch/alpha/kernel/systbls.S
+++ b/arch/alpha/kernel/systbls.S
@@ -497,6 +497,7 @@ sys_call_table:
 	.quad sys_signalfd
 	.quad sys_ni_syscall
 	.quad sys_eventfd
+	.quad sys_recvmmsg
 
 	.size sys_call_table, . - sys_call_table
 	.type sys_call_table, @object
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 1680e9e..80fa7fc 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -372,6 +372,7 @@
 /* 360 */	CALL(sys_inotify_init1)
 		CALL(sys_preadv)
 		CALL(sys_pwritev)
+		CALL(sys_recvmmsg)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 7bebac0..aef1e61 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1805,6 +1805,7 @@ sys_call_table:
 	data8 sys_inotify_init1
 	data8 sys_preadv
 	data8 sys_pwritev			// 1320
+	data8 sys_recvmmsg
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index 0b31b9b..283383c 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -652,6 +652,8 @@ einval:	li	v0, -ENOSYS
 	sys	sys_inotify_init1	1
 	sys	sys_preadv		6	/* 4330 */
 	sys	sys_pwritev		6
+	sys	sys_pwritev		6
+	sys	sys_recvmmsg		4
 	.endm
 
 	/* We pre-compute the number of _instruction_ bytes needed to
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index c647fd6..109550f 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -489,4 +489,5 @@ sys_call_table:
 	PTR	sys_inotify_init1
 	PTR	sys_preadv
 	PTR	sys_pwritev			/* 5390 */
+	PTR	sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index c2c16ef..d45f22c 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -415,4 +415,5 @@ EXPORT(sysn32_call_table)
 	PTR	sys_inotify_init1
 	PTR	sys_preadv
 	PTR	sys_pwritev
+	PTR	compat_sys_recvmmsg
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index 002fac2..de93e46 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -535,4 +535,5 @@ sys_call_table:
 	PTR	sys_inotify_init1
 	PTR	compat_sys_preadv		/* 4330 */
 	PTR	compat_sys_pwritev
+	PTR	compat_sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_64.S
index a083609..4d180ac 100644
--- a/arch/sh/kernel/syscalls_64.S
+++ b/arch/sh/kernel/syscalls_64.S
@@ -389,3 +389,4 @@ sys_call_table:
 	.long sys_inotify_init1		/* 360 */
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_recvmmsg
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
index 82b5bf8..5807ed5 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -156,4 +156,4 @@ sys_call_table:
 	.word sys_set_mempolicy, sys_kexec_load, sys_move_pages, sys_getcpu, sys_epoll_pwait
 /*310*/	.word sys_utimensat, sys_signalfd, sys_timerfd_create, sys_eventfd, sys_fallocate
 	.word sys_timerfd_settime, sys_timerfd_gettime, sys_signalfd4, sys_eventfd2, sys_epoll_create1
-/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys_preadv, sys_pwritev
+/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys_preadv, sys_pwritev, sys_recvmmsg
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 900e161..713a32a 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
 __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_counter_open			298
 __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
+#define __NR_recvmmsg				299
+__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 421afb4..50c6c44 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -65,6 +65,12 @@ struct msghdr {
 	unsigned	msg_flags;
 };
 
+/* For recvmmsg/sendmmsg */
+struct mmsghdr {
+	struct msghdr	msg_hdr;
+	unsigned	msg_len;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 677d159..dbf94dd 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -25,6 +25,7 @@ struct linux_dirent64;
 struct list_head;
 struct msgbuf;
 struct msghdr;
+struct mmsghdr;
 struct msqid_ds;
 struct new_utsname;
 struct nfsctl_arg;
@@ -555,6 +556,8 @@ asmlinkage long sys_recv(int, void __user *, size_t, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
 asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
+asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
+			     unsigned int vlen, unsigned flags);
 asmlinkage long sys_socket(int, int, int);
 asmlinkage long sys_socketpair(int, int, int, int __user *);
 asmlinkage long sys_socketcall(int call, unsigned long __user *args);
diff --git a/include/net/compat.h b/include/net/compat.h
index 5bbf8bf..35acabb 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -18,6 +18,11 @@ struct compat_msghdr {
 	compat_uint_t	msg_flags;
 };
 
+struct compat_mmsghdr {
+	struct compat_msghdr msg_hdr;
+	compat_uint_t	     msg_len;
+};
+
 struct compat_cmsghdr {
 	compat_size_t	cmsg_len;
 	compat_int_t	cmsg_level;
@@ -35,6 +40,8 @@ extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
+extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
+					   unsigned, unsigned);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
 extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
 
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 68320f6..f581fb0 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -48,7 +48,9 @@ cond_syscall(sys_shutdown);
 cond_syscall(sys_sendmsg);
 cond_syscall(compat_sys_sendmsg);
 cond_syscall(sys_recvmsg);
+cond_syscall(sys_recvmmsg);
 cond_syscall(compat_sys_recvmsg);
+cond_syscall(compat_sys_recvmmsg);
 cond_syscall(sys_socketcall);
 cond_syscall(sys_futex);
 cond_syscall(compat_sys_futex);
diff --git a/net/compat.c b/net/compat.c
index 8d73905..1ec778f 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -743,6 +743,13 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
+				    unsigned vlen, unsigned int flags)
+{
+	return sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+			    flags | MSG_CMSG_COMPAT);
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
diff --git a/net/socket.c b/net/socket.c
index 791d71a..f0249cb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1965,22 +1965,16 @@ out:
 	return err;
 }
 
-/*
- *	BSD recvmsg interface
- */
-
-SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
-		unsigned int, flags)
+static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
+			 unsigned flags)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
-	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
 	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
-	int fput_needed;
 
 	/* kernel mode address */
 	struct sockaddr_storage addr;
@@ -1996,13 +1990,9 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock)
-		goto out;
-
 	err = -EMSGSIZE;
 	if (msg_sys.msg_iovlen > UIO_MAXIOV)
-		goto out_put;
+		goto out;
 
 	/* Check whether to allocate the iovec area */
 	err = -ENOMEM;
@@ -2010,7 +2000,7 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
 		iov = sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
 		if (!iov)
-			goto out_put;
+			goto out;
 	}
 
 	/*
@@ -2066,9 +2056,63 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 out_freeiov:
 	if (iov != iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
+out:
+	return err;
+}
+
+/*
+ *	BSD recvmsg interface
+ */
+
+SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
+		unsigned int, flags)
+{
+	int fput_needed, err;
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	err = __sys_recvmsg(sock, msg, flags);
+
+	fput_light(sock->file, fput_needed);
+out:
+	return err;
+}
+
+/*
+ *	Linux recvmmsg interface
+ */
+
+SYSCALL_DEFINE4(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags)
+{
+	int fput_needed, err, datagrams = 0;
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	struct mmsghdr __user *entry = mmsg;
+
+	if (!sock)
+		goto out;
+
+	while (datagrams < vlen) {
+		err = __sys_recvmsg(sock, (struct msghdr __user *)entry, flags);
+		if (err < 0)
+			goto out_put;
+		err = __put_user(err, &entry->msg_len);
+		if (err)
+			goto out_put;
+		++entry;
+		++datagrams;
+	}
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
+	/*
+	 * We may return less entries than requested (vlen) if the
+	 * sock is non block and there aren't enough datagrams.
+	 */
+	if (err == 0 || (err == -EAGAIN && (flags & MSG_DONTWAIT)))
+		return datagrams;
 	return err;
 }
 
-- 
1.6.0.6

