From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [RFCv4 PATCH 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 16 Sep 2009 14:07:38 -0300
Message-ID: <20090916170738.GC7699@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nir Tzachar <nir.tzachar@gmail.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753107AbZIPRIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2009 13:08:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Meaning receive multiple messages, reducing the number of syscalls and
net stack entry/exit operations.

Next patches will introduce mechanisms where protocols that want to
optimize this operation will provide an unlocked_recvmsg operation.

This takes into account comments made by:

=2E Paul Moore: sock_recvmsg is called only for the first datagram,
  sock_recvmsg_nosec is used for the rest.

=2E Caitlin Bestler: recvmmsg now has a struct timespec timeout, that
  works in the same fashion as the ppoll one.

  If the underlying protocol returns a datagram with MSG_OOB set, this
  will make recvmmsg return right away with as many datagrams (+ the OO=
B
  one) it has received so far.

=2E R=E9mi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
  datagrams and then recvmsg returns an error, recvmmsg will return
  the successfully received datagrams, store the error and return it
  in the next call.

This paves the way for a subsequent optimization, sk_prot->unlocked_rec=
vmsg,
where we will be able to acquire the lock only at batch start and end, =
not at
every underlying recvmsg call.

Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Van Hoof <vanhoof@redhat.com>
Cc: Clark Williams <williams@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Nir Tzachar <nir.tzachar@gmail.com>
Cc: Nivedita Singhvi <niv@us.ibm.com>
Cc: Paul Moore <paul.moore@hp.com>
Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: Steven Whitehouse <steve@chygwyn.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 arch/alpha/kernel/systbls.S            |    1 +
 arch/arm/kernel/calls.S                |    1 +
 arch/avr32/kernel/syscall_table.S      |    1 +
 arch/blackfin/mach-common/entry.S      |    1 +
 arch/ia64/kernel/entry.S               |    1 +
 arch/microblaze/kernel/syscall_table.S |    1 +
 arch/mips/kernel/scall32-o32.S         |    1 +
 arch/mips/kernel/scall64-64.S          |    1 +
 arch/mips/kernel/scall64-n32.S         |    1 +
 arch/mips/kernel/scall64-o32.S         |    1 +
 arch/sh/kernel/syscalls_64.S           |    1 +
 arch/sparc/kernel/systbls_64.S         |    4 +-
 arch/x86/ia32/ia32entry.S              |    1 +
 arch/x86/include/asm/unistd_32.h       |    1 +
 arch/x86/include/asm/unistd_64.h       |    2 +
 arch/x86/kernel/syscall_table_32.S     |    1 +
 arch/xtensa/include/asm/unistd.h       |    4 +-
 include/linux/net.h                    |    1 +
 include/linux/socket.h                 |   10 ++
 include/linux/syscalls.h               |    4 +
 include/net/compat.h                   |    8 +
 kernel/sys_ni.c                        |    2 +
 net/compat.c                           |   33 +++++-
 net/socket.c                           |  225 ++++++++++++++++++++++++=
++------
 24 files changed, 259 insertions(+), 48 deletions(-)

diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.S
index 95c9aef..cda6b8b 100644
--- a/arch/alpha/kernel/systbls.S
+++ b/arch/alpha/kernel/systbls.S
@@ -497,6 +497,7 @@ sys_call_table:
 	.quad sys_signalfd
 	.quad sys_ni_syscall
 	.quad sys_eventfd
+	.quad sys_recvmmsg
=20
 	.size sys_call_table, . - sys_call_table
 	.type sys_call_table, @object
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index f776e72..43995f6 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -374,6 +374,7 @@
 		CALL(sys_pwritev)
 		CALL(sys_rt_tgsigqueueinfo)
 		CALL(sys_perf_counter_open)
+		CALL(sys_recvmmsg)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/sysc=
all_table.S
index 7ee0057..e76bad1 100644
--- a/arch/avr32/kernel/syscall_table.S
+++ b/arch/avr32/kernel/syscall_table.S
@@ -295,4 +295,5 @@ sys_call_table:
 	.long	sys_signalfd
 	.long	sys_ni_syscall		/* 280, was sys_timerfd */
 	.long	sys_eventfd
+	.long	sys_recvmmsg
 	.long	sys_ni_syscall		/* r8 is saturated at nr_syscalls */
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-com=
mon/entry.S
index fb1795d..e4d3d0f 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1612,6 +1612,7 @@ ENTRY(_sys_call_table)
 	.long _sys_pwritev
 	.long _sys_rt_tgsigqueueinfo
 	.long _sys_perf_counter_open
+	.long _sys_recvmmsg
=20
 	.rept NR_syscalls-(.-_sys_call_table)/4
 	.long _sys_ni_syscall
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index d0e7d37..d75b872 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1806,6 +1806,7 @@ sys_call_table:
 	data8 sys_preadv
 	data8 sys_pwritev			// 1320
 	data8 sys_rt_tgsigqueueinfo
+	data8 sys_recvmmsg
=20
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to incr=
ease NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze/k=
ernel/syscall_table.S
index 4572160..623dbf1 100644
--- a/arch/microblaze/kernel/syscall_table.S
+++ b/arch/microblaze/kernel/syscall_table.S
@@ -371,3 +371,4 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall
 	.long sys_rt_tgsigqueueinfo	/* 365 */
 	.long sys_perf_counter_open
+	.long sys_recvmmsg
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-=
o32.S
index b570821..b92aa3e 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -655,6 +655,7 @@ einval:	li	v0, -ENOSYS
 	sys	sys_rt_tgsigqueueinfo	4
 	sys	sys_perf_counter_open	5
 	sys	sys_accept4		4
+	sys     sys_recvmmsg            5
 	.endm
=20
 	/* We pre-compute the number of _instruction_ bytes needed to
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-6=
4.S
index 3d866f2..d3384d8 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -492,4 +492,5 @@ sys_call_table:
 	PTR	sys_rt_tgsigqueueinfo
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-=
n32.S
index 1a6ae12..15412f7 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -418,4 +418,5 @@ EXPORT(sysn32_call_table)
 	PTR	compat_sys_rt_tgsigqueueinfo	/* 5295 */
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     compat_sys_recvmmsg
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-=
o32.S
index cd31087..ba1e940 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -538,4 +538,5 @@ sys_call_table:
 	PTR	compat_sys_rt_tgsigqueueinfo
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     compat_sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_64.=
S
index bf420b6..056e0a7 100644
--- a/arch/sh/kernel/syscalls_64.S
+++ b/arch/sh/kernel/syscalls_64.S
@@ -391,3 +391,4 @@ sys_call_table:
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo
 	.long sys_perf_counter_open
+	.long sys_recvmmsg		/* 365 */
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls=
_64.S
index 91b06b7..ff40e70 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -83,7 +83,7 @@ sys_call_table32:
 /*310*/	.word compat_sys_utimensat, compat_sys_signalfd, sys_timerfd_c=
reate, sys_eventfd, compat_sys_fallocate
 	.word compat_sys_timerfd_settime, compat_sys_timerfd_gettime, compat_=
sys_signalfd4, sys_eventfd2, sys_epoll_create1
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, com=
pat_sys_preadv
-	.word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo, sys_perf_coun=
ter_open
+	.word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo, sys_perf_coun=
ter_open, compat_sys_recvmmsg
=20
 #endif /* CONFIG_COMPAT */
=20
@@ -158,4 +158,4 @@ sys_call_table:
 /*310*/	.word sys_utimensat, sys_signalfd, sys_timerfd_create, sys_eve=
ntfd, sys_fallocate
 	.word sys_timerfd_settime, sys_timerfd_gettime, sys_signalfd4, sys_ev=
entfd2, sys_epoll_create1
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys=
_preadv
-	.word sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_counter_open
+	.word sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_counter_open, sys_=
recvmmsg
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index ba331bf..94dc323 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -832,4 +832,5 @@ ia32_sys_call_table:
 	.quad compat_sys_pwritev
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_counter_open
+	.quad compat_sys_recvmmsg
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/un=
istd_32.h
index 8deaada..665ea30 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -342,6 +342,7 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
+#define __NR_recvmmsg		337
=20
 #ifdef __KERNEL__
=20
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/un=
istd_64.h
index b9f3c60..f837601 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
 __SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
 #define __NR_perf_counter_open			298
 __SYSCALL(__NR_perf_counter_open, sys_perf_counter_open)
+#define __NR_recvmmsg				299
+__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
=20
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/sysca=
ll_table_32.S
index d51321d..4881b14 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -336,3 +336,4 @@ ENTRY(sys_call_table)
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
+	.long sys_recvmmsg
diff --git a/arch/xtensa/include/asm/unistd.h b/arch/xtensa/include/asm=
/unistd.h
index c092c8f..4e55dc7 100644
--- a/arch/xtensa/include/asm/unistd.h
+++ b/arch/xtensa/include/asm/unistd.h
@@ -681,8 +681,10 @@ __SYSCALL(304, sys_signalfd, 3)
 __SYSCALL(305, sys_ni_syscall, 0)
 #define __NR_eventfd				306
 __SYSCALL(306, sys_eventfd, 1)
+#define __NR_recvmmsg				307
+__SYSCALL(307, sys_recvmmsg, 5)
=20
-#define __NR_syscall_count			307
+#define __NR_syscall_count			308
=20
 /*
  * sysxtensa syscall handler
diff --git a/include/linux/net.h b/include/linux/net.h
index 4fc2ffd..d67587a 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -41,6 +41,7 @@
 #define SYS_SENDMSG	16		/* sys_sendmsg(2)		*/
 #define SYS_RECVMSG	17		/* sys_recvmsg(2)		*/
 #define SYS_ACCEPT4	18		/* sys_accept4(2)		*/
+#define SYS_RECVMMSG	19		/* sys_recvmmsg(2)		*/
=20
 typedef enum {
 	SS_FREE =3D 0,			/* not allocated		*/
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3b461df..c192bf8 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -65,6 +65,12 @@ struct msghdr {
 	unsigned	msg_flags;
 };
=20
+/* For recvmmsg/sendmmsg */
+struct mmsghdr {
+	struct msghdr   msg_hdr;
+	unsigned        msg_len;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
@@ -327,6 +333,10 @@ extern int move_addr_to_user(struct sockaddr *kadd=
r, int klen, void __user *uadd
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct so=
ckaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void=
 *data);
=20
+struct timespec;
+
+extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigne=
d int vlen,
+			  unsigned int flags, struct timespec *timeout);
 #endif
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index a8e3782..b21818c 100644
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
@@ -686,6 +687,9 @@ asmlinkage long sys_recv(int, void __user *, size_t=
, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
 asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigne=
d flags);
+asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
+			     unsigned int vlen, unsigned flags,
+			     struct timespec __user *timeout);
 asmlinkage long sys_socket(int, int, int);
 asmlinkage long sys_socketpair(int, int, int, int __user *);
 asmlinkage long sys_socketcall(int call, unsigned long __user *args);
diff --git a/include/net/compat.h b/include/net/compat.h
index 5bbf8bf..96c38d8 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -18,6 +18,11 @@ struct compat_msghdr {
 	compat_uint_t	msg_flags;
 };
=20
+struct compat_mmsghdr {
+	struct compat_msghdr msg_hdr;
+	compat_uint_t        msg_len;
+};
+
 struct compat_cmsghdr {
 	compat_size_t	cmsg_len;
 	compat_int_t	cmsg_level;
@@ -35,6 +40,9 @@ extern int get_compat_msghdr(struct msghdr *, struct =
compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct=
 sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __u=
ser *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __u=
ser *,unsigned);
+extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr =
__user *,
+					   unsigned, unsigned,
+					   struct timespec __user *);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __use=
r *, int __user *);
 extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
=20
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
index 12728b1..ee57376 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -727,10 +727,10 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
=20
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[19]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+static unsigned char nas[20]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-				AL(4)};
+				AL(4),AL(5)};
 #undef AL
=20
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user=
 *msg, unsigned flags)
@@ -755,13 +755,36 @@ asmlinkage long compat_sys_recvfrom(int fd, void =
__user *buf, size_t len,
 	return sys_recvfrom(fd, buf, len, flags | MSG_CMSG_COMPAT, addr, addr=
len);
 }
=20
+asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __us=
er *mmsg,
+				    unsigned vlen, unsigned int flags,
+				    struct timespec __user *timeout)
+{
+	int datagrams;
+	struct timespec ktspec;
+	struct compat_timespec __user *utspec =3D
+			(struct compat_timespec __user *)timeout;
+
+	if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	    get_user(ktspec.tv_nsec, &utspec->tv_nsec))
+		return -EFAULT;
+
+	datagrams =3D __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+				   flags | MSG_CMSG_COMPAT, &ktspec);
+	if (datagrams > 0 &&
+	    (put_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	     put_user(ktspec.tv_nsec, &utspec->tv_nsec)))
+		datagrams =3D -EFAULT;
+
+	return datagrams;
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
 	u32 a[6];
 	u32 a0, a1;
=20
-	if (call < SYS_SOCKET || call > SYS_ACCEPT4)
+	if (call < SYS_SOCKET || call > SYS_RECVMMSG)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -823,6 +846,10 @@ asmlinkage long compat_sys_socketcall(int call, u3=
2 __user *args)
 	case SYS_RECVMSG:
 		ret =3D compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_RECVMMSG:
+		ret =3D compat_sys_recvmmsg(a0, compat_ptr(a1), a[2], a[3],
+					  compat_ptr(a[4]));
+		break;
 	case SYS_ACCEPT4:
 		ret =3D sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
 		break;
diff --git a/net/socket.c b/net/socket.c
index 6d47165..32db56a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -668,10 +668,9 @@ void __sock_recv_timestamp(struct msghdr *msg, str=
uct sock *sk,
=20
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
=20
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *so=
ck,
-				 struct msghdr *msg, size_t size, int flags)
+static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct sock=
et *sock,
+				       struct msghdr *msg, size_t size, int flags)
 {
-	int err;
 	struct sock_iocb *si =3D kiocb_to_siocb(iocb);
=20
 	si->sock =3D sock;
@@ -680,13 +679,17 @@ static inline int __sock_recvmsg(struct kiocb *io=
cb, struct socket *sock,
 	si->size =3D size;
 	si->flags =3D flags;
=20
-	err =3D security_socket_recvmsg(sock, msg, size, flags);
-	if (err)
-		return err;
-
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
=20
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *so=
ck,
+				 struct msghdr *msg, size_t size, int flags)
+{
+	int err =3D security_socket_recvmsg(sock, msg, size, flags);
+
+	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
+}
+
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
@@ -702,6 +705,21 @@ int sock_recvmsg(struct socket *sock, struct msghd=
r *msg,
 	return ret;
 }
=20
+static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private =3D &siocb;
+	ret =3D __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED =3D=3D ret)
+		ret =3D wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1965,22 +1983,15 @@ out:
 	return err;
 }
=20
-/*
- *	BSD recvmsg interface
- */
-
-SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
-		unsigned int, flags)
+static int __sys_recvmsg(struct socket *sock, struct msghdr __user *ms=
g,
+			 struct msghdr *msg_sys, unsigned flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =3D
 	    (struct compat_msghdr __user *)msg;
-	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov =3D iovstack;
-	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
-	int fput_needed;
=20
 	/* kernel mode address */
 	struct sockaddr_storage addr;
@@ -1990,27 +2001,23 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr=
 __user *, msg,
 	int __user *uaddr_len;
=20
 	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(&msg_sys, msg_compat))
+		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
 	}
-	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
=20
-	sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock)
-		goto out;
-
 	err =3D -EMSGSIZE;
-	if (msg_sys.msg_iovlen > UIO_MAXIOV)
-		goto out_put;
+	if (msg_sys->msg_iovlen > UIO_MAXIOV)
+		goto out;
=20
 	/* Check whether to allocate the iovec area */
 	err =3D -ENOMEM;
-	iov_size =3D msg_sys.msg_iovlen * sizeof(struct iovec);
-	if (msg_sys.msg_iovlen > UIO_FASTIOV) {
+	iov_size =3D msg_sys->msg_iovlen * sizeof(struct iovec);
+	if (msg_sys->msg_iovlen > UIO_FASTIOV) {
 		iov =3D sock_kmalloc(sock->sk, iov_size, GFP_KERNEL);
 		if (!iov)
-			goto out_put;
+			goto out;
 	}
=20
 	/*
@@ -2018,46 +2025,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr=
 __user *, msg,
 	 *      kernel msghdr to use the kernel address space)
 	 */
=20
-	uaddr =3D (__force void __user *)msg_sys.msg_name;
+	uaddr =3D (__force void __user *)msg_sys->msg_name;
 	uaddr_len =3D COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err =3D verify_compat_iovec(&msg_sys, iov,
+		err =3D verify_compat_iovec(msg_sys, iov,
 					  (struct sockaddr *)&addr,
 					  VERIFY_WRITE);
 	} else
-		err =3D verify_iovec(&msg_sys, iov,
+		err =3D verify_iovec(msg_sys, iov,
 				   (struct sockaddr *)&addr,
 				   VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
 	total_len =3D err;
=20
-	cmsg_ptr =3D (unsigned long)msg_sys.msg_control;
-	msg_sys.msg_flags =3D flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
+	cmsg_ptr =3D (unsigned long)msg_sys->msg_control;
+	msg_sys->msg_flags =3D flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
=20
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |=3D MSG_DONTWAIT;
-	err =3D sock_recvmsg(sock, &msg_sys, total_len, flags);
+	err =3D (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
+							  total_len, flags);
 	if (err < 0)
 		goto out_freeiov;
 	len =3D err;
=20
 	if (uaddr !=3D NULL) {
 		err =3D move_addr_to_user((struct sockaddr *)&addr,
-					msg_sys.msg_namelen, uaddr,
+					msg_sys->msg_namelen, uaddr,
 					uaddr_len);
 		if (err < 0)
 			goto out_freeiov;
 	}
-	err =3D __put_user((msg_sys.msg_flags & ~MSG_CMSG_COMPAT),
+	err =3D __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMPAT),
 			 COMPAT_FLAGS(msg));
 	if (err)
 		goto out_freeiov;
 	if (MSG_CMSG_COMPAT & flags)
-		err =3D __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err =3D __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg_compat->msg_controllen);
 	else
-		err =3D __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err =3D __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg->msg_controllen);
 	if (err)
 		goto out_freeiov;
@@ -2066,21 +2074,150 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghd=
r __user *, msg,
 out_freeiov:
 	if (iov !=3D iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
-out_put:
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
+	struct msghdr msg_sys;
+	struct socket *sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	err =3D __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
=20
-#ifdef __ARCH_WANT_SYS_SOCKETCALL
+/*
+ *     Linux recvmmsg interface
+ */
+
+int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int v=
len,
+		   unsigned int flags, struct timespec *timeout)
+{
+	int fput_needed, err, datagrams;
+	struct socket *sock;
+	struct mmsghdr __user *entry;
+	struct msghdr msg_sys;
+	struct timespec end_time;
+
+	if (timeout &&
+	    poll_select_set_timeout(&end_time, timeout->tv_sec,
+				    timeout->tv_nsec))
+		return -EINVAL;
+
+	datagrams =3D 0;
+
+	sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
+	if (!sock)
+		return err;
+
+	err =3D sock_error(sock->sk);
+	if (err)
+		goto out_put;
+
+	entry =3D mmsg;
+
+	while (datagrams < vlen) {
+		/*
+		 * No need to ask LSM for more than the first datagram.
+		 */
+		err =3D __sys_recvmsg(sock, (struct msghdr __user *)entry,
+				    &msg_sys, flags, datagrams);
+		if (err < 0)
+			break;
+		err =3D put_user(err, &entry->msg_len);
+		if (err)
+			break;
+		++entry;
+		++datagrams;
+
+		if (timeout) {
+			ktime_get_ts(timeout);
+			*timeout =3D timespec_sub(end_time, *timeout);
+			if (timeout->tv_sec < 0) {
+				timeout->tv_sec =3D timeout->tv_nsec =3D 0;
+				break;
+			}
+
+			/* Timeout, return less than vlen datagrams */
+			if (timeout->tv_nsec =3D=3D 0 && timeout->tv_sec =3D=3D 0)
+				break;
+		}
+
+		/* Out of band data, return right away */
+		if (msg_sys.msg_flags & MSG_OOB)
+			break;
+	}
+
+out_put:
+	fput_light(sock->file, fput_needed);
=20
+	if (err =3D=3D 0)
+		return datagrams;
+
+	if (datagrams !=3D 0) {
+		/*
+		 * We may return less entries than requested (vlen) if the
+		 * sock is non block and there aren't enough datagrams...
+		 */
+		if (err !=3D -EAGAIN) {
+			/*
+			 * ... or  if recvmsg returns an error after we
+			 * received some datagrams, where we record the
+			 * error to return on the next call or if the
+			 * app asks about it using getsockopt(SO_ERROR).
+			 */
+			sock->sk->sk_err =3D -err;
+		}
+
+		return datagrams;
+	}
+
+	return err;
+}
+
+SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
+		unsigned int, vlen, unsigned int, flags,
+		struct timespec __user *, timeout)
+{
+	int datagrams;
+	struct timespec timeout_sys;
+
+	if (!timeout)
+		return __sys_recvmmsg(fd, mmsg, vlen, flags, NULL);
+
+	if (copy_from_user(&timeout_sys, timeout, sizeof(timeout_sys)))
+		return -EFAULT;
+
+	datagrams =3D __sys_recvmmsg(fd, mmsg, vlen, flags, &timeout_sys);
+
+	if (datagrams > 0 &&
+	    copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
+		datagrams =3D -EFAULT;
+
+	return datagrams;
+}
+
+#ifdef __ARCH_WANT_SYS_SOCKETCALL
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[19]=3D{
+static const unsigned char nargs[20] =3D {
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-	AL(4)
+	AL(4),AL(5)
 };
=20
 #undef AL
@@ -2099,7 +2236,7 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned l=
ong __user *, args)
 	unsigned long a0, a1;
 	int err;
=20
-	if (call < 1 || call > SYS_ACCEPT4)
+	if (call < 1 || call > SYS_RECVMMSG)
 		return -EINVAL;
=20
 	/* copy_from_user should be SMP safe. */
@@ -2173,6 +2310,10 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned =
long __user *, args)
 	case SYS_RECVMSG:
 		err =3D sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_RECVMMSG:
+		err =3D sys_recvmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3],
+				   (struct timespec __user *)a[4]);
+		break;
 	case SYS_ACCEPT4:
 		err =3D sys_accept4(a0, (struct sockaddr __user *)a1,
 				  (int __user *)a[2], a[3]);
--=20
1.5.5.1


