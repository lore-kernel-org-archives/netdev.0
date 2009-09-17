From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Thu, 17 Sep 2009 18:53:44 -0300
Message-ID: <20090917215344.GE3691@ghostprotocols.net>
References: <20090916170745.GD7699@ghostprotocols.net> <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com> <20090917212113.GC3691@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Ziv Ayalon <zivayalon@gmail.com>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430AbZIQVy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 17:54:28 -0400
Content-Disposition: inline
In-Reply-To: <20090917212113.GC3691@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Em Thu, Sep 17, 2009 at 06:21:13PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Thu, Sep 17, 2009 at 05:09:19PM +0300, Nir Tzachar escreveu:
> > Hello.
> > 
> > Below are some test results with the patch (only part 1, as I did not
> > manage to apply part 2).
> 
> I forgot to mention that the patches were made against DaveM's
> net-next-2.6 tree at:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
> 
> If you have a linux-2.6 git tree, just do:
> 
> cd linux-2.6
> git remote add net-next git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
> git branch -b net-next-recvmmsg net-next/master
> 
> And you should be able to apply the two patches cleanly.

Strange, I just checked out v2.6.31 and only one hunk in the _first_
patch (adding the recvmmsg entry in the sparc 32 syscall table) failed,
the second applied with just minor offsets.

You must have corrupted the patch when saving somehow, anyway, find
both, against v2.6.31, attached.

Back to building the kernel on 10 Gbit/s hardware.

- Arnaldo

--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-net-Introduce-recvmmsg-socket-syscall.patch"
Content-Transfer-Encoding: 8bit

>From fbdd4648e212c95d82672f385996df0d01086c00 Mon Sep 17 00:00:00 2001
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 17 Sep 2009 18:44:40 -0300
Subject: [PATCH 1/2] net: Introduce recvmmsg socket syscall
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Meaning receive multiple messages, reducing the number of syscalls and
net stack entry/exit operations.

Next patches will introduce mechanisms where protocols that want to
optimize this operation will provide an unlocked_recvmsg operation.

This takes into account comments made by:

. Paul Moore: sock_recvmsg is called only for the first datagram,
  sock_recvmsg_nosec is used for the rest.

. Caitlin Bestler: recvmmsg now has a struct timespec timeout, that
  works in the same fashion as the ppoll one.

  If the underlying protocol returns a datagram with MSG_OOB set, this
  will make recvmmsg return right away with as many datagrams (+ the OOB
  one) it has received so far.

. Rémi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
  datagrams and then recvmsg returns an error, recvmmsg will return
  the successfully received datagrams, store the error and return it
  in the next call.

This paves the way for a subsequent optimization, sk_prot->unlocked_recvmsg,
where we will be able to acquire the lock only at batch start and end, not at
every underlying recvmsg call.

Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Van Hoof <vanhoof@redhat.com>
Cc: Clark Williams <williams@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Nir Tzachar <nir.tzachar@gmail.com>
Cc: Nivedita Singhvi <niv@us.ibm.com>
Cc: Paul Moore <paul.moore@hp.com>
Cc: Rémi Denis-Courmont <remi.denis-courmont@nokia.com>
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
 net/socket.c                           |  225 ++++++++++++++++++++++++++------
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
diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/syscall_table.S
index 7ee0057..e76bad1 100644
--- a/arch/avr32/kernel/syscall_table.S
+++ b/arch/avr32/kernel/syscall_table.S
@@ -295,4 +295,5 @@ sys_call_table:
 	.long	sys_signalfd
 	.long	sys_ni_syscall		/* 280, was sys_timerfd */
 	.long	sys_eventfd
+	.long	sys_recvmmsg
 	.long	sys_ni_syscall		/* r8 is saturated at nr_syscalls */
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index fb1795d..e4d3d0f 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1612,6 +1612,7 @@ ENTRY(_sys_call_table)
 	.long _sys_pwritev
 	.long _sys_rt_tgsigqueueinfo
 	.long _sys_perf_counter_open
+	.long _sys_recvmmsg
 
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
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze/kernel/syscall_table.S
index 4572160..623dbf1 100644
--- a/arch/microblaze/kernel/syscall_table.S
+++ b/arch/microblaze/kernel/syscall_table.S
@@ -371,3 +371,4 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall
 	.long sys_rt_tgsigqueueinfo	/* 365 */
 	.long sys_perf_counter_open
+	.long sys_recvmmsg
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index b570821..b92aa3e 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -655,6 +655,7 @@ einval:	li	v0, -ENOSYS
 	sys	sys_rt_tgsigqueueinfo	4
 	sys	sys_perf_counter_open	5
 	sys	sys_accept4		4
+	sys     sys_recvmmsg            5
 	.endm
 
 	/* We pre-compute the number of _instruction_ bytes needed to
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index 3d866f2..d3384d8 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -492,4 +492,5 @@ sys_call_table:
 	PTR	sys_rt_tgsigqueueinfo
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index e855b11..c332346 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -418,4 +418,5 @@ EXPORT(sysn32_call_table)
 	PTR	compat_sys_rt_tgsigqueueinfo	/* 5295 */
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     compat_sys_recvmmsg
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index 0c49f1a..12bc997 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -538,4 +538,5 @@ sys_call_table:
 	PTR	compat_sys_rt_tgsigqueueinfo
 	PTR	sys_perf_counter_open
 	PTR	sys_accept4
+	PTR     compat_sys_recvmmsg
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_64.S
index bf420b6..056e0a7 100644
--- a/arch/sh/kernel/syscalls_64.S
+++ b/arch/sh/kernel/syscalls_64.S
@@ -391,3 +391,4 @@ sys_call_table:
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo
 	.long sys_perf_counter_open
+	.long sys_recvmmsg		/* 365 */
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
index 2ee7250..7e77138 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -83,7 +83,7 @@ sys_call_table32:
 /*310*/	.word compat_sys_utimensat, compat_sys_signalfd, sys_timerfd_create, sys_eventfd, compat_sys_fallocate
 	.word compat_sys_timerfd_settime, compat_sys_timerfd_gettime, compat_sys_signalfd4, sys_eventfd2, sys_epoll_create1
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, compat_sys_preadv
-	.word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo
+	.word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo, compat_sys_recvmmsg
 
 #endif /* CONFIG_COMPAT */
 
@@ -158,4 +158,4 @@ sys_call_table:
 /*310*/	.word sys_utimensat, sys_signalfd, sys_timerfd_create, sys_eventfd, sys_fallocate
 	.word sys_timerfd_settime, sys_timerfd_gettime, sys_signalfd4, sys_eventfd2, sys_epoll_create1
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys_preadv
-	.word sys_pwritev, sys_rt_tgsigqueueinfo
+	.word sys_pwritev, sys_rt_tgsigqueueinfo, sys_recvmmsg
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index e590261..2a188e5 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -832,4 +832,5 @@ ia32_sys_call_table:
 	.quad compat_sys_pwritev
 	.quad compat_sys_rt_tgsigqueueinfo	/* 335 */
 	.quad sys_perf_counter_open
+	.quad compat_sys_recvmmsg
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 732a307..3e72cae 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -342,6 +342,7 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_counter_open	336
+#define __NR_recvmmsg		337
 
 #ifdef __KERNEL__
 
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
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d51321d..4881b14 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -336,3 +336,4 @@ ENTRY(sys_call_table)
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_counter_open
+	.long sys_recvmmsg
diff --git a/arch/xtensa/include/asm/unistd.h b/arch/xtensa/include/asm/unistd.h
index c092c8f..4e55dc7 100644
--- a/arch/xtensa/include/asm/unistd.h
+++ b/arch/xtensa/include/asm/unistd.h
@@ -681,8 +681,10 @@ __SYSCALL(304, sys_signalfd, 3)
 __SYSCALL(305, sys_ni_syscall, 0)
 #define __NR_eventfd				306
 __SYSCALL(306, sys_eventfd, 1)
+#define __NR_recvmmsg				307
+__SYSCALL(307, sys_recvmmsg, 5)
 
-#define __NR_syscall_count			307
+#define __NR_syscall_count			308
 
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
 
 typedef enum {
 	SS_FREE = 0,			/* not allocated		*/
diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3b461df..c192bf8 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -65,6 +65,12 @@ struct msghdr {
 	unsigned	msg_flags;
 };
 
+/* For recvmmsg/sendmmsg */
+struct mmsghdr {
+	struct msghdr   msg_hdr;
+	unsigned        msg_len;
+};
+
 /*
  *	POSIX 1003.1g - ancillary data object information
  *	Ancillary data consits of a sequence of pairs of
@@ -327,6 +333,10 @@ extern int move_addr_to_user(struct sockaddr *kaddr, int klen, void __user *uadd
 extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *kaddr);
 extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
 
+struct timespec;
+
+extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
+			  unsigned int flags, struct timespec *timeout);
 #endif
 #endif /* not kernel and not glibc */
 #endif /* _LINUX_SOCKET_H */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 80de700..a3532ef 100644
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
@@ -559,6 +560,9 @@ asmlinkage long sys_recv(int, void __user *, size_t, unsigned);
 asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
 				struct sockaddr __user *, int __user *);
 asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags);
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
 
+struct compat_mmsghdr {
+	struct compat_msghdr msg_hdr;
+	compat_uint_t        msg_len;
+};
+
 struct compat_cmsghdr {
 	compat_size_t	cmsg_len;
 	compat_int_t	cmsg_level;
@@ -35,6 +40,9 @@ extern int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *);
 extern int verify_compat_iovec(struct msghdr *, struct iovec *, struct sockaddr *, int);
 extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
+extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
+					   unsigned, unsigned,
+					   struct timespec __user *);
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
index 8d73905..9a149a6 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -727,10 +727,10 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
 
 /* Argument list sizes for compat_sys_socketcall */
 #define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[19]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+static unsigned char nas[20]={AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 				AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 				AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-				AL(4)};
+				AL(4),AL(5)};
 #undef AL
 
 asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __user *msg, unsigned flags)
@@ -743,13 +743,36 @@ asmlinkage long compat_sys_recvmsg(int fd, struct compat_msghdr __user *msg, uns
 	return sys_recvmsg(fd, (struct msghdr __user *)msg, flags | MSG_CMSG_COMPAT);
 }
 
+asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
+				    unsigned vlen, unsigned int flags,
+				    struct timespec __user *timeout)
+{
+	int datagrams;
+	struct timespec ktspec;
+	struct compat_timespec __user *utspec =
+			(struct compat_timespec __user *)timeout;
+
+	if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	    get_user(ktspec.tv_nsec, &utspec->tv_nsec))
+		return -EFAULT;
+
+	datagrams = __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
+				   flags | MSG_CMSG_COMPAT, &ktspec);
+	if (datagrams > 0 &&
+	    (put_user(ktspec.tv_sec, &utspec->tv_sec) ||
+	     put_user(ktspec.tv_nsec, &utspec->tv_nsec)))
+		datagrams = -EFAULT;
+
+	return datagrams;
+}
+
 asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 {
 	int ret;
 	u32 a[6];
 	u32 a0, a1;
 
-	if (call < SYS_SOCKET || call > SYS_ACCEPT4)
+	if (call < SYS_SOCKET || call > SYS_RECVMMSG)
 		return -EINVAL;
 	if (copy_from_user(a, args, nas[call]))
 		return -EFAULT;
@@ -810,6 +833,10 @@ asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
 	case SYS_RECVMSG:
 		ret = compat_sys_recvmsg(a0, compat_ptr(a1), a[2]);
 		break;
+	case SYS_RECVMMSG:
+		ret = compat_sys_recvmmsg(a0, compat_ptr(a1), a[2], a[3],
+					  compat_ptr(a[4]));
+		break;
 	case SYS_ACCEPT4:
 		ret = sys_accept4(a0, compat_ptr(a1), compat_ptr(a[2]), a[3]);
 		break;
diff --git a/net/socket.c b/net/socket.c
index 6d47165..32db56a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -668,10 +668,9 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
-static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
-				 struct msghdr *msg, size_t size, int flags)
+static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct socket *sock,
+				       struct msghdr *msg, size_t size, int flags)
 {
-	int err;
 	struct sock_iocb *si = kiocb_to_siocb(iocb);
 
 	si->sock = sock;
@@ -680,13 +679,17 @@ static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	si->size = size;
 	si->flags = flags;
 
-	err = security_socket_recvmsg(sock, msg, size, flags);
-	if (err)
-		return err;
-
 	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
 }
 
+static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
+				 struct msghdr *msg, size_t size, int flags)
+{
+	int err = security_socket_recvmsg(sock, msg, size, flags);
+
+	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
+}
+
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
@@ -702,6 +705,21 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 	return ret;
 }
 
+static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
+			      size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private = &siocb;
+	ret = __sock_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1965,22 +1983,15 @@ out:
 	return err;
 }
 
-/*
- *	BSD recvmsg interface
- */
-
-SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
-		unsigned int, flags)
+static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
+			 struct msghdr *msg_sys, unsigned flags, int nosec)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
-	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
 	struct iovec *iov = iovstack;
-	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
-	int fput_needed;
 
 	/* kernel mode address */
 	struct sockaddr_storage addr;
@@ -1990,27 +2001,23 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	int __user *uaddr_len;
 
 	if (MSG_CMSG_COMPAT & flags) {
-		if (get_compat_msghdr(&msg_sys, msg_compat))
+		if (get_compat_msghdr(msg_sys, msg_compat))
 			return -EFAULT;
 	}
-	else if (copy_from_user(&msg_sys, msg, sizeof(struct msghdr)))
+	else if (copy_from_user(msg_sys, msg, sizeof(struct msghdr)))
 		return -EFAULT;
 
-	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (!sock)
-		goto out;
-
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
 
 	/*
@@ -2018,46 +2025,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	 *      kernel msghdr to use the kernel address space)
 	 */
 
-	uaddr = (__force void __user *)msg_sys.msg_name;
+	uaddr = (__force void __user *)msg_sys->msg_name;
 	uaddr_len = COMPAT_NAMELEN(msg);
 	if (MSG_CMSG_COMPAT & flags) {
-		err = verify_compat_iovec(&msg_sys, iov,
+		err = verify_compat_iovec(msg_sys, iov,
 					  (struct sockaddr *)&addr,
 					  VERIFY_WRITE);
 	} else
-		err = verify_iovec(&msg_sys, iov,
+		err = verify_iovec(msg_sys, iov,
 				   (struct sockaddr *)&addr,
 				   VERIFY_WRITE);
 	if (err < 0)
 		goto out_freeiov;
 	total_len = err;
 
-	cmsg_ptr = (unsigned long)msg_sys.msg_control;
-	msg_sys.msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
+	cmsg_ptr = (unsigned long)msg_sys->msg_control;
+	msg_sys->msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err = sock_recvmsg(sock, &msg_sys, total_len, flags);
+	err = (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
+							  total_len, flags);
 	if (err < 0)
 		goto out_freeiov;
 	len = err;
 
 	if (uaddr != NULL) {
 		err = move_addr_to_user((struct sockaddr *)&addr,
-					msg_sys.msg_namelen, uaddr,
+					msg_sys->msg_namelen, uaddr,
 					uaddr_len);
 		if (err < 0)
 			goto out_freeiov;
 	}
-	err = __put_user((msg_sys.msg_flags & ~MSG_CMSG_COMPAT),
+	err = __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMPAT),
 			 COMPAT_FLAGS(msg));
 	if (err)
 		goto out_freeiov;
 	if (MSG_CMSG_COMPAT & flags)
-		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg_compat->msg_controllen);
 	else
-		err = __put_user((unsigned long)msg_sys.msg_control - cmsg_ptr,
+		err = __put_user((unsigned long)msg_sys->msg_control - cmsg_ptr,
 				 &msg->msg_controllen);
 	if (err)
 		goto out_freeiov;
@@ -2066,21 +2074,150 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 out_freeiov:
 	if (iov != iovstack)
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
+	struct socket *sock = sockfd_lookup_light(fd, &err, &fput_needed);
+
+	if (!sock)
+		goto out;
+
+	err = __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
 
-#ifdef __ARCH_WANT_SYS_SOCKETCALL
+/*
+ *     Linux recvmmsg interface
+ */
+
+int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
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
+
+	while (datagrams < vlen) {
+		/*
+		 * No need to ask LSM for more than the first datagram.
+		 */
+		err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
+				    &msg_sys, flags, datagrams);
+		if (err < 0)
+			break;
+		err = put_user(err, &entry->msg_len);
+		if (err)
+			break;
+		++entry;
+		++datagrams;
+
+		if (timeout) {
+			ktime_get_ts(timeout);
+			*timeout = timespec_sub(end_time, *timeout);
+			if (timeout->tv_sec < 0) {
+				timeout->tv_sec = timeout->tv_nsec = 0;
+				break;
+			}
+
+			/* Timeout, return less than vlen datagrams */
+			if (timeout->tv_nsec == 0 && timeout->tv_sec == 0)
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
 
+	if (err == 0)
+		return datagrams;
+
+	if (datagrams != 0) {
+		/*
+		 * We may return less entries than requested (vlen) if the
+		 * sock is non block and there aren't enough datagrams...
+		 */
+		if (err != -EAGAIN) {
+			/*
+			 * ... or  if recvmsg returns an error after we
+			 * received some datagrams, where we record the
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
+	datagrams = __sys_recvmmsg(fd, mmsg, vlen, flags, &timeout_sys);
+
+	if (datagrams > 0 &&
+	    copy_to_user(timeout, &timeout_sys, sizeof(timeout_sys)))
+		datagrams = -EFAULT;
+
+	return datagrams;
+}
+
+#ifdef __ARCH_WANT_SYS_SOCKETCALL
 /* Argument list sizes for sys_socketcall */
 #define AL(x) ((x) * sizeof(unsigned long))
-static const unsigned char nargs[19]={
+static const unsigned char nargs[20] = {
 	AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
 	AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
 	AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
-	AL(4)
+	AL(4),AL(5)
 };
 
 #undef AL
@@ -2099,7 +2236,7 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 	unsigned long a0, a1;
 	int err;
 
-	if (call < 1 || call > SYS_ACCEPT4)
+	if (call < 1 || call > SYS_RECVMMSG)
 		return -EINVAL;
 
 	/* copy_from_user should be SMP safe. */
@@ -2173,6 +2310,10 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 	case SYS_RECVMSG:
 		err = sys_recvmsg(a0, (struct msghdr __user *)a1, a[2]);
 		break;
+	case SYS_RECVMMSG:
+		err = sys_recvmmsg(a0, (struct mmsghdr __user *)a1, a[2], a[3],
+				   (struct timespec __user *)a[4]);
+		break;
 	case SYS_ACCEPT4:
 		err = sys_accept4(a0, (struct sockaddr __user *)a1,
 				  (int __user *)a[2], a[3]);
-- 
1.6.2.5


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="0002-net-Allow-protocols-to-provide-an-unlocked_recvmsg.patch"
Content-Transfer-Encoding: 8bit

>From ccafdce1eefb3d59793931e746f1f07722fcfbbe Mon Sep 17 00:00:00 2001
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 17 Sep 2009 18:48:32 -0300
Subject: [PATCH 2/2] net: Allow protocols to provide an unlocked_recvmsg socket method
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

So thar recvmmsg can use it. With this patch recvmmsg actually _requires_ that
socket->ops->unlocked_recvmsg exists, and that socket->sk->sk_prot->unlocked_recvmsg
is non NULL.

We may well switch back to the previous scheme where sys_recvmmsg checks if
the underlying protocol provides an unlocked version and uses it, falling
back to the locked version if there is none.

But first lets see if this works with recvmmsg alone and what kinds of gains we
get with the unlocked_recvmmsg implementation in UDP. Followup patches can
restore that behaviour if we want to use it with, say, DCCP and SCTP without an
specific unlocked version.

This should address the concerns raised by Rémi about the MSG_UNLOCKED problem.

Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
Cc: Chris Van Hoof <vanhoof@redhat.com>
Cc: Clark Williams <williams@redhat.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Nir Tzachar <nir.tzachar@gmail.com>
Cc: Nivedita Singhvi <niv@us.ibm.com>
Cc: Paul Moore <paul.moore@hp.com>
Cc: Rémi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: Steven Whitehouse <steve@chygwyn.com>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/isdn/mISDN/socket.c    |    2 +
 drivers/net/pppoe.c            |    1 +
 drivers/net/pppol2tp.c         |    1 +
 include/linux/net.h            |    7 +++
 include/net/sock.h             |   13 +++++
 net/appletalk/ddp.c            |    1 +
 net/atm/pvc.c                  |    1 +
 net/atm/svc.c                  |    1 +
 net/ax25/af_ax25.c             |    1 +
 net/bluetooth/bnep/sock.c      |    1 +
 net/bluetooth/cmtp/sock.c      |    1 +
 net/bluetooth/hci_sock.c       |    1 +
 net/bluetooth/hidp/sock.c      |    1 +
 net/bluetooth/l2cap.c          |    1 +
 net/bluetooth/rfcomm/sock.c    |    1 +
 net/bluetooth/sco.c            |    1 +
 net/can/bcm.c                  |    1 +
 net/can/raw.c                  |    1 +
 net/core/sock.c                |   26 +++++++++
 net/dccp/ipv4.c                |    1 +
 net/dccp/ipv6.c                |    1 +
 net/decnet/af_decnet.c         |    1 +
 net/econet/af_econet.c         |    1 +
 net/ieee802154/af_ieee802154.c |    2 +
 net/ipv4/af_inet.c             |    3 +
 net/ipv4/udp.c                 |   52 +++++++++++++++---
 net/ipv6/af_inet6.c            |    2 +
 net/ipv6/raw.c                 |    1 +
 net/ipx/af_ipx.c               |    1 +
 net/irda/af_irda.c             |    4 ++
 net/iucv/af_iucv.c             |    1 +
 net/key/af_key.c               |    1 +
 net/llc/af_llc.c               |    1 +
 net/netlink/af_netlink.c       |    1 +
 net/netrom/af_netrom.c         |    1 +
 net/packet/af_packet.c         |    2 +
 net/phonet/socket.c            |    2 +
 net/rds/af_rds.c               |    1 +
 net/rose/af_rose.c             |    1 +
 net/rxrpc/af_rxrpc.c           |    1 +
 net/sctp/ipv6.c                |    1 +
 net/sctp/protocol.c            |    1 +
 net/socket.c                   |  112 +++++++++++++++++++++++++++++++++++----
 net/tipc/socket.c              |    3 +
 net/unix/af_unix.c             |    3 +
 net/x25/af_x25.c               |    1 +
 46 files changed, 244 insertions(+), 21 deletions(-)

diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index c36f521..6da3a71 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -590,6 +590,7 @@ static const struct proto_ops data_sock_ops = {
 	.getname	= data_sock_getname,
 	.sendmsg	= mISDN_sock_sendmsg,
 	.recvmsg	= mISDN_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= datagram_poll,
 	.listen		= sock_no_listen,
 	.shutdown	= sock_no_shutdown,
@@ -743,6 +744,7 @@ static const struct proto_ops base_sock_ops = {
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,
 	.recvmsg	= sock_no_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= sock_no_poll,
 	.listen		= sock_no_listen,
 	.shutdown	= sock_no_shutdown,
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 5f20902..bf30741 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1121,6 +1121,7 @@ static const struct proto_ops pppoe_ops = {
 	.getsockopt	= sock_no_getsockopt,
 	.sendmsg	= pppoe_sendmsg,
 	.recvmsg	= pppoe_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.ioctl		= pppox_ioctl,
 };
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0f9219..af6160c 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2590,6 +2590,7 @@ static struct proto_ops pppol2tp_ops = {
 	.getsockopt	= pppol2tp_getsockopt,
 	.sendmsg	= pppol2tp_sendmsg,
 	.recvmsg	= pppol2tp_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.ioctl		= pppox_ioctl,
 };
diff --git a/include/linux/net.h b/include/linux/net.h
index d67587a..8b852de 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -186,6 +186,10 @@ struct proto_ops {
 	int		(*recvmsg)   (struct kiocb *iocb, struct socket *sock,
 				      struct msghdr *m, size_t total_len,
 				      int flags);
+	int		(*unlocked_recvmsg)(struct kiocb *iocb,
+					    struct socket *sock,
+					    struct msghdr *m,
+					    size_t total_len, int flags);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
@@ -316,6 +320,8 @@ SOCKCALL_WRAP(name, sendmsg, (struct kiocb *iocb, struct socket *sock, struct ms
 	      (iocb, sock, m, len)) \
 SOCKCALL_WRAP(name, recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len, int flags), \
 	      (iocb, sock, m, len, flags)) \
+SOCKCALL_WRAP(name, unlocked_recvmsg, (struct kiocb *iocb, struct socket *sock, struct msghdr *m, size_t len, int flags), \
+	      (iocb, sock, m, len, flags)) \
 SOCKCALL_WRAP(name, mmap, (struct file *file, struct socket *sock, struct vm_area_struct *vma), \
 	      (file, sock, vma)) \
 	      \
@@ -337,6 +343,7 @@ static const struct proto_ops name##_ops = {			\
 	.getsockopt	= __lock_##name##_getsockopt,	\
 	.sendmsg	= __lock_##name##_sendmsg,	\
 	.recvmsg	= __lock_##name##_recvmsg,	\
+	.unlocked_recvmsg = __lock_##name##_unlocked_recvmsg,	\
 	.mmap		= __lock_##name##_mmap,		\
 };
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 950409d..7c62428 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -644,6 +644,11 @@ struct proto {
 					   struct msghdr *msg,
 					size_t len, int noblock, int flags, 
 					int *addr_len);
+	int			(*unlocked_recvmsg)(struct kiocb *iocb,
+						    struct sock *sk,
+						    struct msghdr *msg,
+						    size_t len, int noblock,
+						    int flags, int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
 	int			(*bind)(struct sock *sk, 
@@ -998,6 +1003,11 @@ extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
 						struct msghdr *, size_t);
 extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
 						struct msghdr *, size_t, int);
+extern int			sock_no_unlocked_recvmsg(struct kiocb *iocb,
+							 struct socket *sock,
+							 struct msghdr *msg,
+							 size_t size,
+							 int flags);
 extern int			sock_no_mmap(struct file *file,
 					     struct socket *sock,
 					     struct vm_area_struct *vma);
@@ -1014,6 +1024,9 @@ extern int sock_common_getsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, int __user *optlen);
 extern int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size, int flags);
+extern int sock_common_unlocked_recvmsg(struct kiocb *iocb, struct socket *sock,
+					struct msghdr *msg, size_t size,
+					int flags);
 extern int sock_common_setsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, int optlen);
 extern int compat_sock_common_getsockopt(struct socket *sock, int level,
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 875eda5..100c5d7 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1842,6 +1842,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(atalk_dgram_ops) = {
 	.getsockopt	= sock_no_getsockopt,
 	.sendmsg	= atalk_sendmsg,
 	.recvmsg	= atalk_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index e1d22d9..5c03749 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -122,6 +122,7 @@ static const struct proto_ops pvc_proto_ops = {
 	.getsockopt =	pvc_getsockopt,
 	.sendmsg =	vcc_sendmsg,
 	.recvmsg =	vcc_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 7b831b5..6c66ae9 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -644,6 +644,7 @@ static const struct proto_ops svc_proto_ops = {
 	.setsockopt =	svc_setsockopt,
 	.getsockopt =	svc_getsockopt,
 	.sendmsg =	vcc_sendmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.recvmsg =	vcc_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index da0f64f..43f4f57 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1976,6 +1976,7 @@ static const struct proto_ops ax25_proto_ops = {
 	.getsockopt	= ax25_getsockopt,
 	.sendmsg	= ax25_sendmsg,
 	.recvmsg	= ax25_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index e857628..0b26b3c 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -178,6 +178,7 @@ static const struct proto_ops bnep_sock_ops = {
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,
 	.recvmsg	= sock_no_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= sock_no_poll,
 	.listen		= sock_no_listen,
 	.shutdown	= sock_no_shutdown,
diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 16b0fad..72a4b5d 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -173,6 +173,7 @@ static const struct proto_ops cmtp_sock_ops = {
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,
 	.recvmsg	= sock_no_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= sock_no_poll,
 	.listen		= sock_no_listen,
 	.shutdown	= sock_no_shutdown,
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 4f9621f..bd0aace 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -603,6 +603,7 @@ static const struct proto_ops hci_sock_ops = {
 	.getname	= hci_sock_getname,
 	.sendmsg	= hci_sock_sendmsg,
 	.recvmsg	= hci_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.ioctl		= hci_sock_ioctl,
 	.poll		= datagram_poll,
 	.listen		= sock_no_listen,
diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 37c9d7d..90b40e2 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -224,6 +224,7 @@ static const struct proto_ops hidp_sock_ops = {
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,
 	.recvmsg	= sock_no_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= sock_no_poll,
 	.listen		= sock_no_listen,
 	.shutdown	= sock_no_shutdown,
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index bd0a4c1..945df03 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2743,6 +2743,7 @@ static const struct proto_ops l2cap_sock_ops = {
 	.getname	= l2cap_sock_getname,
 	.sendmsg	= l2cap_sock_sendmsg,
 	.recvmsg	= l2cap_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= bt_sock_poll,
 	.ioctl		= bt_sock_ioctl,
 	.mmap		= sock_no_mmap,
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 0b85e81..00b1a41 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -1092,6 +1092,7 @@ static const struct proto_ops rfcomm_sock_ops = {
 	.getname	= rfcomm_sock_getname,
 	.sendmsg	= rfcomm_sock_sendmsg,
 	.recvmsg	= rfcomm_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.shutdown	= rfcomm_sock_shutdown,
 	.setsockopt	= rfcomm_sock_setsockopt,
 	.getsockopt	= rfcomm_sock_getsockopt,
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 51ae0c3..5ef7b5c 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -965,6 +965,7 @@ static const struct proto_ops sco_sock_ops = {
 	.getname	= sco_sock_getname,
 	.sendmsg	= sco_sock_sendmsg,
 	.recvmsg	= bt_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= bt_sock_poll,
 	.ioctl		= bt_sock_ioctl,
 	.mmap		= sock_no_mmap,
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 72720c7..6e388b3 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1575,6 +1575,7 @@ static struct proto_ops bcm_ops __read_mostly = {
 	.getsockopt    = sock_no_getsockopt,
 	.sendmsg       = bcm_sendmsg,
 	.recvmsg       = bcm_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap          = sock_no_mmap,
 	.sendpage      = sock_no_sendpage,
 };
diff --git a/net/can/raw.c b/net/can/raw.c
index db3152d..b8fa610 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -730,6 +730,7 @@ static struct proto_ops raw_ops __read_mostly = {
 	.getsockopt    = raw_getsockopt,
 	.sendmsg       = raw_sendmsg,
 	.recvmsg       = raw_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap          = sock_no_mmap,
 	.sendpage      = sock_no_sendpage,
 };
diff --git a/net/core/sock.c b/net/core/sock.c
index 7633422..76a6279 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1643,6 +1643,13 @@ int sock_no_connect(struct socket *sock, struct sockaddr *saddr,
 }
 EXPORT_SYMBOL(sock_no_connect);
 
+int sock_no_unlocked_recvmsg(struct kiocb *iocb, struct socket *sock,
+			     struct msghdr *msg, size_t size, int flags)
+{
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(sock_no_unlocked_recvmsg);
+
 int sock_no_socketpair(struct socket *sock1, struct socket *sock2)
 {
 	return -EOPNOTSUPP;
@@ -2004,6 +2011,25 @@ int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
 }
 EXPORT_SYMBOL(sock_common_recvmsg);
 
+int sock_common_unlocked_recvmsg(struct kiocb *iocb, struct socket *sock,
+				 struct msghdr *msg, size_t size, int flags)
+{
+	struct sock *sk = sock->sk;
+	int addr_len = 0;
+	int err;
+
+	if (sk->sk_prot->unlocked_recvmsg == NULL)
+		return -EOPNOTSUPP;
+
+	err = sk->sk_prot->unlocked_recvmsg(iocb, sk, msg, size,
+					    flags & MSG_DONTWAIT,
+					    flags & ~MSG_DONTWAIT, &addr_len);
+	if (err >= 0)
+		msg->msg_namelen = addr_len;
+	return err;
+}
+EXPORT_SYMBOL(sock_common_unlocked_recvmsg);
+
 /*
  *	Set socket options on an inet socket.
  */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a0a36c9..263c9b8 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -974,6 +974,7 @@ static const struct proto_ops inet_dccp_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3e70faa..ae1f650 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1175,6 +1175,7 @@ static struct proto_ops inet6_dccp_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 77d4028..aa1af0b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2348,6 +2348,7 @@ static const struct proto_ops dn_proto_ops = {
 	.getsockopt =	dn_getsockopt,
 	.sendmsg =	dn_sendmsg,
 	.recvmsg =	dn_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index f0bbc57..857ff5b 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -765,6 +765,7 @@ static const struct proto_ops econet_ops = {
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	econet_sendmsg,
 	.recvmsg =	econet_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index af66180..1602409 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -197,6 +197,7 @@ static const struct proto_ops ieee802154_raw_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = ieee802154_sock_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
@@ -222,6 +223,7 @@ static const struct proto_ops ieee802154_dgram_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = ieee802154_sock_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 566ea6c..e8a44d4 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -854,6 +854,7 @@ const struct proto_ops inet_stream_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = tcp_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
 	.splice_read	   = tcp_splice_read,
@@ -880,6 +881,7 @@ const struct proto_ops inet_dgram_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_common_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
@@ -909,6 +911,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80e3812..4033ae5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -872,13 +872,34 @@ int udp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 	return 0;
 }
 
+static void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
+{
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
+}
+
+static int skb_kill_datagram_locked(struct sock *sk, struct sk_buff *skb,
+                                   unsigned int flags)
+{
+	int ret;
+	lock_sock(sk);
+	ret = skb_kill_datagram(sk, skb, flags);
+	release_sock(sk);
+	return ret;
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
  */
-
-int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		size_t len, int noblock, int flags, int *addr_len)
+static int __udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len,
+			 void (*free_datagram)(struct sock *,
+					       struct sk_buff *),
+			 int  (*kill_datagram)(struct sock *,
+					       struct sk_buff *, unsigned int))
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
@@ -956,23 +977,35 @@ try_again:
 		err = ulen;
 
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	free_datagram(sk, skb);
 out:
 	return err;
 
 csum_copy_err:
-	lock_sock(sk);
-	if (!skb_kill_datagram(sk, skb, flags))
+	if (!kill_datagram(sk, skb, flags))
 		UDP_INC_STATS_USER(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
-	release_sock(sk);
 
 	if (noblock)
 		return -EAGAIN;
 	goto try_again;
 }
 
+int udp_recvmsg(struct kiocb *iocb, struct sock *sk,
+		struct msghdr *msg, size_t len, int noblock,
+		int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram_locked,
+			     skb_kill_datagram_locked);
+}
+
+int udp_unlocked_recvmsg(struct kiocb *iocb, struct sock *sk,
+			 struct msghdr *msg, size_t len, int noblock,
+			 int flags, int *addr_len)
+{
+	return __udp_recvmsg(iocb, sk, msg, len, noblock, flags, addr_len,
+			     skb_free_datagram, skb_kill_datagram);
+}
 
 int udp_disconnect(struct sock *sk, int flags)
 {
@@ -1565,6 +1598,7 @@ struct proto udp_prot = {
 	.getsockopt	   = udp_getsockopt,
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
+	.unlocked_recvmsg  = udp_unlocked_recvmsg,
 	.sendpage	   = udp_sendpage,
 	.backlog_rcv	   = __udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 45f9a2a..7d0cc2f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -518,6 +518,7 @@ const struct proto_ops inet6_stream_ops = {
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   = tcp_sendmsg,		/* ok		*/
 	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
 	.splice_read	   = tcp_splice_read,
@@ -544,6 +545,7 @@ const struct proto_ops inet6_dgram_ops = {
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   = inet_sendmsg,		/* ok		*/
 	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  = sock_common_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d6c3c1c..c05ec59 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1326,6 +1326,7 @@ static const struct proto_ops inet6_sockraw_ops = {
 	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
 	.sendmsg	   = inet_sendmsg,		/* ok		*/
 	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index f1118d9..45048a0 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1953,6 +1953,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(ipx_dgram_ops) = {
 	.getsockopt	= ipx_getsockopt,
 	.sendmsg	= ipx_sendmsg,
 	.recvmsg	= ipx_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 50b43c5..7e97581 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -2489,6 +2489,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_stream_ops) = {
 	.getsockopt =	irda_getsockopt,
 	.sendmsg =	irda_sendmsg,
 	.recvmsg =	irda_recvmsg_stream,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -2513,6 +2514,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_seqpacket_ops) = {
 	.getsockopt =	irda_getsockopt,
 	.sendmsg =	irda_sendmsg,
 	.recvmsg =	irda_recvmsg_dgram,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -2537,6 +2539,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_dgram_ops) = {
 	.getsockopt =	irda_getsockopt,
 	.sendmsg =	irda_sendmsg_dgram,
 	.recvmsg =	irda_recvmsg_dgram,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -2562,6 +2565,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(irda_ultra_ops) = {
 	.getsockopt =	irda_getsockopt,
 	.sendmsg =	irda_sendmsg_ultra,
 	.recvmsg =	irda_recvmsg_dgram,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 49c15b4..c208622 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1693,6 +1693,7 @@ static struct proto_ops iucv_sock_ops = {
 	.getname	= iucv_sock_getname,
 	.sendmsg	= iucv_sock_sendmsg,
 	.recvmsg	= iucv_sock_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.poll		= iucv_sock_poll,
 	.ioctl		= sock_no_ioctl,
 	.mmap		= sock_no_mmap,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index dba9abd..f1af697 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3636,6 +3636,7 @@ static const struct proto_ops pfkey_ops = {
 	.getsockopt	=	sock_no_getsockopt,
 	.mmap		=	sock_no_mmap,
 	.sendpage	=	sock_no_sendpage,
+	.unlocked_recvmsg =	sock_no_unlocked_recvmsg,
 
 	/* Now the operations that really occur. */
 	.release	=	pfkey_release,
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c45eee1..d948caf 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -1115,6 +1115,7 @@ static const struct proto_ops llc_ui_ops = {
 	.getsockopt  = llc_ui_getsockopt,
 	.sendmsg     = llc_ui_sendmsg,
 	.recvmsg     = llc_ui_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap	     = sock_no_mmap,
 	.sendpage    = sock_no_sendpage,
 };
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2936fa3..e7a51bb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1978,6 +1978,7 @@ static const struct proto_ops netlink_ops = {
 	.getsockopt =	netlink_getsockopt,
 	.sendmsg =	netlink_sendmsg,
 	.recvmsg =	netlink_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index ce1a34b..3550d34 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1395,6 +1395,7 @@ static const struct proto_ops nr_proto_ops = {
 	.getsockopt	=	nr_getsockopt,
 	.sendmsg	=	nr_sendmsg,
 	.recvmsg	=	nr_recvmsg,
+	.unlocked_recvmsg =	sock_no_unlocked_recvmsg,
 	.mmap		=	sock_no_mmap,
 	.sendpage	=	sock_no_sendpage,
 };
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ebe5718..dc5d7ff 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2340,6 +2340,7 @@ static const struct proto_ops packet_ops_spkt = {
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	packet_sendmsg_spkt,
 	.recvmsg =	packet_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -2361,6 +2362,7 @@ static const struct proto_ops packet_ops = {
 	.getsockopt =	packet_getsockopt,
 	.sendmsg =	packet_sendmsg,
 	.recvmsg =	packet_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		packet_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index ada2a35..2bd24a5 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -327,6 +327,7 @@ const struct proto_ops phonet_dgram_ops = {
 #endif
 	.sendmsg	= pn_socket_sendmsg,
 	.recvmsg	= sock_common_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
@@ -352,6 +353,7 @@ const struct proto_ops phonet_stream_ops = {
 #endif
 	.sendmsg	= pn_socket_sendmsg,
 	.recvmsg	= sock_common_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index b11e7e5..3e8c846 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -377,6 +377,7 @@ static struct proto_ops rds_proto_ops = {
 	.getsockopt =	rds_getsockopt,
 	.sendmsg =	rds_sendmsg,
 	.recvmsg =	rds_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index e5f478c..a64c623 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1532,6 +1532,7 @@ static struct proto_ops rose_proto_ops = {
 	.getsockopt	=	rose_getsockopt,
 	.sendmsg	=	rose_sendmsg,
 	.recvmsg	=	rose_recvmsg,
+	.unlocked_recvmsg =	sock_no_unlocked_recvmsg,
 	.mmap		=	sock_no_mmap,
 	.sendpage	=	sock_no_sendpage,
 };
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index bfe493e..bf4c38a 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -766,6 +766,7 @@ static const struct proto_ops rxrpc_rpc_ops = {
 	.getsockopt	= sock_no_getsockopt,
 	.sendmsg	= rxrpc_sendmsg,
 	.recvmsg	= rxrpc_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage,
 };
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 6a4b190..b68d9f9 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -918,6 +918,7 @@ static const struct proto_ops inet6_seqpacket_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a76da65..78f52a3 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -897,6 +897,7 @@ static const struct proto_ops inet_seqpacket_ops = {
 	.getsockopt	   = sock_common_getsockopt,
 	.sendmsg	   = inet_sendmsg,
 	.recvmsg	   = sock_common_recvmsg,
+	.unlocked_recvmsg  = sock_no_unlocked_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
diff --git a/net/socket.c b/net/socket.c
index 32db56a..dc5b976 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -690,6 +690,32 @@ static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	return err ?: __sock_recvmsg_nosec(iocb, sock, msg, size, flags);
 }
 
+static inline int __sock_unlocked_recvmsg_nosec(struct kiocb *iocb,
+						struct socket *sock,
+						struct msghdr *msg,
+						size_t size, int flags)
+{
+	struct sock_iocb *si = kiocb_to_siocb(iocb);
+
+	si->sock = sock;
+	si->scm = NULL;
+	si->msg = msg;
+	si->size = size;
+	si->flags = flags;
+
+	return sock->ops->unlocked_recvmsg(iocb, sock, msg, size, flags);
+}
+
+static inline int __sock_unlocked_recvmsg(struct kiocb *iocb,
+					  struct socket *sock,
+					  struct msghdr *msg, size_t size,
+					  int flags)
+{
+	int err = security_socket_recvmsg(sock, msg, size, flags);
+
+	return err ?: __sock_unlocked_recvmsg_nosec(iocb, sock, msg, size, flags);
+}
+
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 		 size_t size, int flags)
 {
@@ -720,6 +746,58 @@ static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
 	return ret;
 }
 
+static int sock_unlocked_recvmsg(struct socket *sock, struct msghdr *msg,
+				 size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private = &siocb;
+	ret = __sock_unlocked_recvmsg(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
+static int sock_unlocked_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
+				       size_t size, int flags)
+{
+	struct kiocb iocb;
+	struct sock_iocb siocb;
+	int ret;
+
+	init_sync_kiocb(&iocb, NULL);
+	iocb.private = &siocb;
+	ret = __sock_unlocked_recvmsg_nosec(&iocb, sock, msg, size, flags);
+	if (-EIOCBQUEUED == ret)
+		ret = wait_on_sync_kiocb(&iocb);
+	return ret;
+}
+
+enum sock_recvmsg_security {
+	SOCK_RECVMSG_SEC = 0,
+	SOCK_RECVMSG_NOSEC,
+};
+
+enum sock_recvmsg_locking {
+	SOCK_LOCKED_RECVMSG = 0,
+	SOCK_UNLOCKED_RECVMSG,
+};
+
+static int (*sock_recvmsg_table[2][2])(struct socket *sock, struct msghdr *msg,
+				       size_t size, int flags) = {
+	[SOCK_RECVMSG_SEC] = {
+		[SOCK_LOCKED_RECVMSG]	= sock_recvmsg, /* The old one */
+		[SOCK_UNLOCKED_RECVMSG] = sock_unlocked_recvmsg,
+	},
+	[SOCK_RECVMSG_NOSEC] = {
+		[SOCK_LOCKED_RECVMSG]	= sock_recvmsg_nosec,
+		[SOCK_UNLOCKED_RECVMSG] = sock_unlocked_recvmsg_nosec,
+	},
+};
+
 int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
 		   struct kvec *vec, size_t num, size_t size, int flags)
 {
@@ -1984,7 +2062,9 @@ out:
 }
 
 static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
-			 struct msghdr *msg_sys, unsigned flags, int nosec)
+			 struct msghdr *msg_sys, unsigned flags,
+			 enum sock_recvmsg_security security,
+			 enum sock_recvmsg_locking locking)
 {
 	struct compat_msghdr __user *msg_compat =
 	    (struct compat_msghdr __user *)msg;
@@ -2044,8 +2124,8 @@ static int __sys_recvmsg(struct socket *sock, struct msghdr __user *msg,
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err = (nosec ? sock_recvmsg_nosec : sock_recvmsg)(sock, msg_sys,
-							  total_len, flags);
+	err = sock_recvmsg_table[security][locking](sock, msg_sys,
+						    total_len, flags);
 	if (err < 0)
 		goto out_freeiov;
 	len = err;
@@ -2092,7 +2172,8 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
 	if (!sock)
 		goto out;
 
-	err = __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
+	err = __sys_recvmsg(sock, msg, &msg_sys, flags,
+			    SOCK_RECVMSG_SEC, SOCK_LOCKED_RECVMSG);
 
 	fput_light(sock->file, fput_needed);
 out:
@@ -2111,6 +2192,7 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	struct mmsghdr __user *entry;
 	struct msghdr msg_sys;
 	struct timespec end_time;
+	enum sock_recvmsg_security security;
 
 	if (timeout &&
 	    poll_select_set_timeout(&end_time, timeout->tv_sec,
@@ -2123,20 +2205,25 @@ int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int vlen,
 	if (!sock)
 		return err;
 
+	lock_sock(sock->sk);
+
 	err = sock_error(sock->sk);
 	if (err)
 		goto out_put;
 
 	entry = mmsg;
 
+	security = SOCK_RECVMSG_SEC;
 	while (datagrams < vlen) {
-		/*
-		 * No need to ask LSM for more than the first datagram.
-		 */
 		err = __sys_recvmsg(sock, (struct msghdr __user *)entry,
-				    &msg_sys, flags, datagrams);
+				    &msg_sys, flags, security,
+				    SOCK_UNLOCKED_RECVMSG);
 		if (err < 0)
 			break;
+		/*
+		 * No need to ask LSM for more than the first datagram.
+		 */
+		security = SOCK_RECVMSG_NOSEC;
 		err = put_user(err, &entry->msg_len);
 		if (err)
 			break;
@@ -2165,9 +2252,8 @@ out_put:
 	fput_light(sock->file, fput_needed);
 
 	if (err == 0)
-		return datagrams;
-
-	if (datagrams != 0) {
+		err = datagrams;
+	else if (datagrams != 0) {
 		/*
 		 * We may return less entries than requested (vlen) if the
 		 * sock is non block and there aren't enough datagrams...
@@ -2182,9 +2268,11 @@ out_put:
 			sock->sk->sk_err = -err;
 		}
 
-		return datagrams;
+		err = datagrams;
 	}
 
+	release_sock(sock->sk);
+
 	return err;
 }
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1848693..141539b 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1791,6 +1791,7 @@ static const struct proto_ops msg_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_msg,
 	.recvmsg	= recv_msg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage
 };
@@ -1812,6 +1813,7 @@ static const struct proto_ops packet_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_packet,
 	.recvmsg	= recv_msg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage
 };
@@ -1833,6 +1835,7 @@ static const struct proto_ops stream_ops = {
 	.getsockopt	= getsockopt,
 	.sendmsg	= send_stream,
 	.recvmsg	= recv_stream,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap		= sock_no_mmap,
 	.sendpage	= sock_no_sendpage
 };
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index fc3ebb9..7e726a6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -521,6 +521,7 @@ static const struct proto_ops unix_stream_ops = {
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_stream_sendmsg,
 	.recvmsg =	unix_stream_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -542,6 +543,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_dgram_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
@@ -563,6 +565,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.getsockopt =	sock_no_getsockopt,
 	.sendmsg =	unix_seqpacket_sendmsg,
 	.recvmsg =	unix_dgram_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 5e6c072..7c20b26 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1620,6 +1620,7 @@ static const struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
 	.getsockopt =	x25_getsockopt,
 	.sendmsg =	x25_sendmsg,
 	.recvmsg =	x25_recvmsg,
+	.unlocked_recvmsg = sock_no_unlocked_recvmsg,
 	.mmap =		sock_no_mmap,
 	.sendpage =	sock_no_sendpage,
 };
-- 
1.6.2.5


--EeQfGwPcQSOJBaQU--
