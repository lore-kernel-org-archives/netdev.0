From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 7/7] ns: Wire up the setns system call
Date: Fri,  6 May 2011 19:25:01 -0700
Message-ID: <1304735101-1824-7-git-send-email-ebiederm@xmission.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
 <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-arch@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-1-git-send-email-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2: Most of the architecture support added by Daniel Lezcano <dlezcano@fr.ibm.com>
v3: ported to v2.6.36-rc4 by: Eric W. Biederman <ebiederm@xmission.com>
v4: Moved wiring up of the system call to another patch
v5: ported to v2.6.39-rc6

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 arch/alpha/include/asm/unistd.h        |    3 ++-
 arch/alpha/kernel/systbls.S            |    1 +
 arch/arm/include/asm/unistd.h          |    1 +
 arch/arm/kernel/calls.S                |    1 +
 arch/avr32/include/asm/unistd.h        |    3 ++-
 arch/avr32/kernel/syscall_table.S      |    1 +
 arch/blackfin/include/asm/unistd.h     |    3 ++-
 arch/blackfin/mach-common/entry.S      |    1 +
 arch/cris/arch-v10/kernel/entry.S      |    1 +
 arch/cris/arch-v32/kernel/entry.S      |    1 +
 arch/cris/include/asm/unistd.h         |    3 ++-
 arch/frv/include/asm/unistd.h          |    3 ++-
 arch/frv/kernel/entry.S                |    1 +
 arch/h8300/include/asm/unistd.h        |    3 ++-
 arch/h8300/kernel/syscalls.S           |    1 +
 arch/ia64/include/asm/unistd.h         |    3 ++-
 arch/ia64/kernel/entry.S               |    1 +
 arch/m32r/include/asm/unistd.h         |    3 ++-
 arch/m32r/kernel/syscall_table.S       |    1 +
 arch/m68k/include/asm/unistd.h         |    3 ++-
 arch/m68k/kernel/syscalltable.S        |    1 +
 arch/microblaze/include/asm/unistd.h   |    3 ++-
 arch/microblaze/kernel/syscall_table.S |    1 +
 arch/mips/include/asm/unistd.h         |   15 +++++++++------
 arch/mips/kernel/scall32-o32.S         |    1 +
 arch/mips/kernel/scall64-64.S          |    1 +
 arch/mips/kernel/scall64-n32.S         |    1 +
 arch/mips/kernel/scall64-o32.S         |    1 +
 arch/mn10300/include/asm/unistd.h      |    3 ++-
 arch/mn10300/kernel/entry.S            |    1 +
 arch/parisc/include/asm/unistd.h       |    4 ++--
 arch/parisc/kernel/syscall_table.S     |    1 +
 arch/powerpc/include/asm/systbl.h      |    1 +
 arch/powerpc/include/asm/unistd.h      |    3 ++-
 arch/s390/include/asm/unistd.h         |    3 ++-
 arch/s390/kernel/syscalls.S            |    1 +
 arch/sh/include/asm/unistd_32.h        |    3 ++-
 arch/sh/include/asm/unistd_64.h        |    3 ++-
 arch/sh/kernel/syscalls_32.S           |    1 +
 arch/sh/kernel/syscalls_64.S           |    1 +
 arch/sparc/include/asm/unistd.h        |    3 ++-
 arch/sparc/kernel/systbls_32.S         |    2 +-
 arch/sparc/kernel/systbls_64.S         |    4 ++--
 arch/x86/ia32/ia32entry.S              |    1 +
 arch/x86/include/asm/unistd_32.h       |    3 ++-
 arch/x86/include/asm/unistd_64.h       |    2 ++
 arch/x86/kernel/syscall_table_32.S     |    1 +
 arch/xtensa/include/asm/unistd.h       |    4 +++-
 include/asm-generic/unistd.h           |    4 +++-
 49 files changed, 81 insertions(+), 30 deletions(-)

diff --git a/arch/alpha/include/asm/unistd.h b/arch/alpha/include/asm/unistd.h
index 058937b..664383d 100644
--- a/arch/alpha/include/asm/unistd.h
+++ b/arch/alpha/include/asm/unistd.h
@@ -452,10 +452,11 @@
 #define __NR_fanotify_init		494
 #define __NR_fanotify_mark		495
 #define __NR_prlimit64			496
+#define __NR_setns                      497
 
 #ifdef __KERNEL__
 
-#define NR_SYSCALLS			497
+#define NR_SYSCALLS			498
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.S
index a6a1de9..4663fd5 100644
--- a/arch/alpha/kernel/systbls.S
+++ b/arch/alpha/kernel/systbls.S
@@ -515,6 +515,7 @@ sys_call_table:
 	.quad sys_fanotify_init
 	.quad sys_fanotify_mark				/* 495 */
 	.quad sys_prlimit64
+	.quad sys_setns
 
 	.size sys_call_table, . - sys_call_table
 	.type sys_call_table, @object
diff --git a/arch/arm/include/asm/unistd.h b/arch/arm/include/asm/unistd.h
index 87dbe3e..41afe2e 100644
--- a/arch/arm/include/asm/unistd.h
+++ b/arch/arm/include/asm/unistd.h
@@ -400,6 +400,7 @@
 #define __NR_open_by_handle_at		(__NR_SYSCALL_BASE+371)
 #define __NR_clock_adjtime		(__NR_SYSCALL_BASE+372)
 #define __NR_syncfs			(__NR_SYSCALL_BASE+373)
+#define __NR_setns                      (__NR_SYSCALL_BASE+374)
 
 /*
  * The following SWIs are ARM private.
diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
index 7fbf28c..a05f759 100644
--- a/arch/arm/kernel/calls.S
+++ b/arch/arm/kernel/calls.S
@@ -383,6 +383,7 @@
 		CALL(sys_open_by_handle_at)
 		CALL(sys_clock_adjtime)
 		CALL(sys_syncfs)
+		CALL(sys_setns)
 #ifndef syscalls_counted
 .equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
 #define syscalls_counted
diff --git a/arch/avr32/include/asm/unistd.h b/arch/avr32/include/asm/unistd.h
index 89861a2..800ea91 100644
--- a/arch/avr32/include/asm/unistd.h
+++ b/arch/avr32/include/asm/unistd.h
@@ -299,9 +299,10 @@
 #define __NR_signalfd		279
 /* 280 was __NR_timerfd */
 #define __NR_eventfd		281
+#define __NR_setns              282
 
 #ifdef __KERNEL__
-#define NR_syscalls		282
+#define NR_syscalls		283
 
 /* Old stuff */
 #define __IGNORE_uselib
diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/syscall_table.S
index e76bad1..c7fd394 100644
--- a/arch/avr32/kernel/syscall_table.S
+++ b/arch/avr32/kernel/syscall_table.S
@@ -296,4 +296,5 @@ sys_call_table:
 	.long	sys_ni_syscall		/* 280, was sys_timerfd */
 	.long	sys_eventfd
 	.long	sys_recvmmsg
+	.long	sys_setns
 	.long	sys_ni_syscall		/* r8 is saturated at nr_syscalls */
diff --git a/arch/blackfin/include/asm/unistd.h b/arch/blackfin/include/asm/unistd.h
index ff9a9f3..b638e6b 100644
--- a/arch/blackfin/include/asm/unistd.h
+++ b/arch/blackfin/include/asm/unistd.h
@@ -397,8 +397,9 @@
 #define __NR_open_by_handle_at	376
 #define __NR_clock_adjtime	377
 #define __NR_syncfs		378
+#define __NR_setns              379
 
-#define __NR_syscall		379
+#define __NR_syscall		380
 #define NR_syscalls		__NR_syscall
 
 /* Old optional stuff no one actually uses */
diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-common/entry.S
index f96933f..dda11ef 100644
--- a/arch/blackfin/mach-common/entry.S
+++ b/arch/blackfin/mach-common/entry.S
@@ -1753,6 +1753,7 @@ ENTRY(_sys_call_table)
 	.long _sys_open_by_handle_at
 	.long _sys_clock_adjtime
 	.long _sys_syncfs
+	.long _sys_setns
 
 	.rept NR_syscalls-(.-_sys_call_table)/4
 	.long _sys_ni_syscall
diff --git a/arch/cris/arch-v10/kernel/entry.S b/arch/cris/arch-v10/kernel/entry.S
index 0d6420d..1161883 100644
--- a/arch/cris/arch-v10/kernel/entry.S
+++ b/arch/cris/arch-v10/kernel/entry.S
@@ -937,6 +937,7 @@ sys_call_table:
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_setns			/* 335 */
 
         /*
          * NOTE!! This doesn't have to be exact - we just have
diff --git a/arch/cris/arch-v32/kernel/entry.S b/arch/cris/arch-v32/kernel/entry.S
index 3abf12c..84fed7e 100644
--- a/arch/cris/arch-v32/kernel/entry.S
+++ b/arch/cris/arch-v32/kernel/entry.S
@@ -880,6 +880,7 @@ sys_call_table:
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_setns			/* 335 */
 
         /*
          * NOTE!! This doesn't have to be exact - we just have
diff --git a/arch/cris/include/asm/unistd.h b/arch/cris/include/asm/unistd.h
index f6fad83..c59a107 100644
--- a/arch/cris/include/asm/unistd.h
+++ b/arch/cris/include/asm/unistd.h
@@ -339,10 +339,11 @@
 #define __NR_inotify_init1	332
 #define __NR_preadv		333
 #define __NR_pwritev		334
+#define __NR_setns              335
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 335
+#define NR_syscalls 336
 
 #include <arch/unistd.h>
 
diff --git a/arch/frv/include/asm/unistd.h b/arch/frv/include/asm/unistd.h
index b28da49..6470f11 100644
--- a/arch/frv/include/asm/unistd.h
+++ b/arch/frv/include/asm/unistd.h
@@ -343,10 +343,11 @@
 #define __NR_pwritev		334
 #define __NR_rt_tgsigqueueinfo	335
 #define __NR_perf_event_open	336
+#define __NR_setns              337
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 337
+#define NR_syscalls 338
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 /* #define __ARCH_WANT_OLD_READDIR */
diff --git a/arch/frv/kernel/entry.S b/arch/frv/kernel/entry.S
index 63d579b..017d6d7 100644
--- a/arch/frv/kernel/entry.S
+++ b/arch/frv/kernel/entry.S
@@ -1526,5 +1526,6 @@ sys_call_table:
 	.long sys_pwritev
 	.long sys_rt_tgsigqueueinfo	/* 335 */
 	.long sys_perf_event_open
+	.long sys_setns
 
 syscall_table_size = (. - sys_call_table)
diff --git a/arch/h8300/include/asm/unistd.h b/arch/h8300/include/asm/unistd.h
index 50f2c5a..85c9552 100644
--- a/arch/h8300/include/asm/unistd.h
+++ b/arch/h8300/include/asm/unistd.h
@@ -325,10 +325,11 @@
 #define __NR_move_pages		317
 #define __NR_getcpu		318
 #define __NR_epoll_pwait	319
+#define __NR_setns              320
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 320
+#define NR_syscalls 321
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/h8300/kernel/syscalls.S b/arch/h8300/kernel/syscalls.S
index faefaff..f4b2e67 100644
--- a/arch/h8300/kernel/syscalls.S
+++ b/arch/h8300/kernel/syscalls.S
@@ -333,6 +333,7 @@ SYMBOL_NAME_LABEL(sys_call_table)
 	.long SYMBOL_NAME(sys_ni_syscall)	/* sys_move_pages */
 	.long SYMBOL_NAME(sys_getcpu)
 	.long SYMBOL_NAME(sys_ni_syscall)	/* sys_epoll_pwait */
+	.long SYMBOL_NAME(sys_setns)		/* 320 */
 
 	.macro	call_sp addr
 	mov.l	#SYMBOL_NAME(\addr),er6
diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index 404d037..2fbda93 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -319,11 +319,12 @@
 #define __NR_open_by_handle_at  	1327
 #define __NR_clock_adjtime		1328
 #define __NR_syncfs			1329
+#define __NR_setns                      1330
 
 #ifdef __KERNEL__
 
 
-#define NR_syscalls			306 /* length of syscall table */
+#define NR_syscalls			307 /* length of syscall table */
 
 /*
  * The following defines stop scripts/checksyscalls.sh from complaining about
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 6de2e23..9ca8019 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1775,6 +1775,7 @@ sys_call_table:
 	data8 sys_open_by_handle_at
 	data8 sys_clock_adjtime
 	data8 sys_syncfs
+	data8 sys_setns				// 1330
 
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase NR_syscalls
 #endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
diff --git a/arch/m32r/include/asm/unistd.h b/arch/m32r/include/asm/unistd.h
index c705456..3c7dafc 100644
--- a/arch/m32r/include/asm/unistd.h
+++ b/arch/m32r/include/asm/unistd.h
@@ -330,10 +330,11 @@
 /* #define __NR_timerfd		322 removed */
 #define __NR_eventfd		323
 #define __NR_fallocate		324
+#define __NR_setns              325
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 325
+#define NR_syscalls 326
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_STAT64
diff --git a/arch/m32r/kernel/syscall_table.S b/arch/m32r/kernel/syscall_table.S
index 60536e2..528f2e6 100644
--- a/arch/m32r/kernel/syscall_table.S
+++ b/arch/m32r/kernel/syscall_table.S
@@ -324,3 +324,4 @@ ENTRY(sys_call_table)
 	.long sys_ni_syscall
 	.long sys_eventfd
 	.long sys_fallocate
+	.long sys_setns			/* 325 */
diff --git a/arch/m68k/include/asm/unistd.h b/arch/m68k/include/asm/unistd.h
index 29e1790..c11a093 100644
--- a/arch/m68k/include/asm/unistd.h
+++ b/arch/m68k/include/asm/unistd.h
@@ -347,10 +347,11 @@
 #define __NR_open_by_handle_at	341
 #define __NR_clock_adjtime	342
 #define __NR_syncfs		343
+#define __NR_setns              344
 
 #ifdef __KERNEL__
 
-#define NR_syscalls		344
+#define NR_syscalls		345
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/m68k/kernel/syscalltable.S b/arch/m68k/kernel/syscalltable.S
index 9b8393d..b5a7bbf 100644
--- a/arch/m68k/kernel/syscalltable.S
+++ b/arch/m68k/kernel/syscalltable.S
@@ -362,6 +362,7 @@ ENTRY(sys_call_table)
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns
 
 	.rept NR_syscalls-(.-sys_call_table)/4
 		.long sys_ni_syscall
diff --git a/arch/microblaze/include/asm/unistd.h b/arch/microblaze/include/asm/unistd.h
index 30edd61..dcebe59 100644
--- a/arch/microblaze/include/asm/unistd.h
+++ b/arch/microblaze/include/asm/unistd.h
@@ -390,8 +390,9 @@
 #define __NR_open_by_handle_at	372
 #define __NR_clock_adjtime	373
 #define __NR_syncfs		374
+#define __NR_setns              375
 
-#define __NR_syscalls		375
+#define __NR_syscalls		376
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze/kernel/syscall_table.S
index 85cea81..d915a12 100644
--- a/arch/microblaze/kernel/syscall_table.S
+++ b/arch/microblaze/kernel/syscall_table.S
@@ -379,3 +379,4 @@ ENTRY(sys_call_table)
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns			/* 375 */
diff --git a/arch/mips/include/asm/unistd.h b/arch/mips/include/asm/unistd.h
index fa2e37e..d0d84eb 100644
--- a/arch/mips/include/asm/unistd.h
+++ b/arch/mips/include/asm/unistd.h
@@ -363,16 +363,17 @@
 #define __NR_open_by_handle_at		(__NR_Linux + 340)
 #define __NR_clock_adjtime		(__NR_Linux + 341)
 #define __NR_syncfs			(__NR_Linux + 342)
+#define __NR_setns                      (__NR_Linux + 343)
 
 /*
  * Offset of the last Linux o32 flavoured syscall
  */
-#define __NR_Linux_syscalls		342
+#define __NR_Linux_syscalls		343
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI32 */
 
 #define __NR_O32_Linux			4000
-#define __NR_O32_Linux_syscalls		342
+#define __NR_O32_Linux_syscalls		343
 
 #if _MIPS_SIM == _MIPS_SIM_ABI64
 
@@ -682,16 +683,17 @@
 #define __NR_open_by_handle_at		(__NR_Linux + 299)
 #define __NR_clock_adjtime		(__NR_Linux + 300)
 #define __NR_syncfs			(__NR_Linux + 301)
+#define __NR_setns                      (__NR_Linux + 302)
 
 /*
  * Offset of the last Linux 64-bit flavoured syscall
  */
-#define __NR_Linux_syscalls		301
+#define __NR_Linux_syscalls		302
 
 #endif /* _MIPS_SIM == _MIPS_SIM_ABI64 */
 
 #define __NR_64_Linux			5000
-#define __NR_64_Linux_syscalls		301
+#define __NR_64_Linux_syscalls		302
 
 #if _MIPS_SIM == _MIPS_SIM_NABI32
 
@@ -1006,16 +1008,17 @@
 #define __NR_open_by_handle_at		(__NR_Linux + 304)
 #define __NR_clock_adjtime		(__NR_Linux + 305)
 #define __NR_syncfs			(__NR_Linux + 306)
+#define __NR_setns                      (__NR_Linux + 307)
 
 /*
  * Offset of the last N32 flavoured syscall
  */
-#define __NR_Linux_syscalls		306
+#define __NR_Linux_syscalls		307
 
 #endif /* _MIPS_SIM == _MIPS_SIM_NABI32 */
 
 #define __NR_N32_Linux			6000
-#define __NR_N32_Linux_syscalls		306
+#define __NR_N32_Linux_syscalls		307
 
 #ifdef __KERNEL__
 
diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall32-o32.S
index 7f5468b..c6a2b58 100644
--- a/arch/mips/kernel/scall32-o32.S
+++ b/arch/mips/kernel/scall32-o32.S
@@ -590,6 +590,7 @@ einval:	li	v0, -ENOSYS
 	sys	sys_open_by_handle_at	3	/* 4340 */
 	sys	sys_clock_adjtime	2
 	sys	sys_syncfs		1
+	sys	sys_setns		2
 	.endm
 
 	/* We pre-compute the number of _instruction_ bytes needed to
diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64-64.S
index a2e1fcb..57e4184 100644
--- a/arch/mips/kernel/scall64-64.S
+++ b/arch/mips/kernel/scall64-64.S
@@ -429,4 +429,5 @@ sys_call_table:
 	PTR	sys_open_by_handle_at
 	PTR	sys_clock_adjtime		/* 5300 */
 	PTR	sys_syncfs
+	PTR	sys_setns
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall64-n32.S
index b2c7624..91ae887 100644
--- a/arch/mips/kernel/scall64-n32.S
+++ b/arch/mips/kernel/scall64-n32.S
@@ -429,4 +429,5 @@ EXPORT(sysn32_call_table)
 	PTR	sys_open_by_handle_at
 	PTR	compat_sys_clock_adjtime	/* 6305 */
 	PTR	sys_syncfs
+	PTR	sys_setns
 	.size	sysn32_call_table,.-sysn32_call_table
diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall64-o32.S
index 049a9c8..02e6ae5 100644
--- a/arch/mips/kernel/scall64-o32.S
+++ b/arch/mips/kernel/scall64-o32.S
@@ -547,4 +547,5 @@ sys_call_table:
 	PTR	compat_sys_open_by_handle_at	/* 4340 */
 	PTR	compat_sys_clock_adjtime
 	PTR	sys_syncfs
+	PTR	sys_setns
 	.size	sys_call_table,.-sys_call_table
diff --git a/arch/mn10300/include/asm/unistd.h b/arch/mn10300/include/asm/unistd.h
index 9d056f5..faf57bb 100644
--- a/arch/mn10300/include/asm/unistd.h
+++ b/arch/mn10300/include/asm/unistd.h
@@ -349,10 +349,11 @@
 #define __NR_rt_tgsigqueueinfo	336
 #define __NR_perf_event_open	337
 #define __NR_recvmmsg		338
+#define __NR_setns              339
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 339
+#define NR_syscalls 340
 
 /*
  * specify the deprecated syscalls we want to support on this arch
diff --git a/arch/mn10300/kernel/entry.S b/arch/mn10300/kernel/entry.S
index fb93ad7..ae435e1 100644
--- a/arch/mn10300/kernel/entry.S
+++ b/arch/mn10300/kernel/entry.S
@@ -759,6 +759,7 @@ ENTRY(sys_call_table)
 	.long sys_rt_tgsigqueueinfo
 	.long sys_perf_event_open
 	.long sys_recvmmsg
+	.long sys_setns
 
 
 nr_syscalls=(.-sys_call_table)/4
diff --git a/arch/parisc/include/asm/unistd.h b/arch/parisc/include/asm/unistd.h
index 3eb82c2..bbaed57 100644
--- a/arch/parisc/include/asm/unistd.h
+++ b/arch/parisc/include/asm/unistd.h
@@ -814,9 +814,9 @@
 #define __NR_recvmmsg		(__NR_Linux + 319)
 #define __NR_accept4		(__NR_Linux + 320)
 #define __NR_prlimit64		(__NR_Linux + 321)
+#define __NR_setns              (__NR_Linux + 322)
 
-#define __NR_Linux_syscalls	(__NR_prlimit64 + 1)
-
+#define __NR_Linux_syscalls	(__NR_setns + 1)
 
 #define __IGNORE_select		/* newselect */
 #define __IGNORE_fadvise64	/* fadvise64_64 */
diff --git a/arch/parisc/kernel/syscall_table.S b/arch/parisc/kernel/syscall_table.S
index 4be85ee..151349c 100644
--- a/arch/parisc/kernel/syscall_table.S
+++ b/arch/parisc/kernel/syscall_table.S
@@ -420,6 +420,7 @@
 	ENTRY_COMP(recvmmsg)
 	ENTRY_SAME(accept4)		/* 320 */
 	ENTRY_SAME(prlimit64)
+	ENTRY_SAME(setns)
 
 	/* Nothing yet */
 
diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index 60f64b1..2a5f60c 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -352,3 +352,4 @@ SYSCALL_SPU(name_to_handle_at)
 COMPAT_SYS_SPU(open_by_handle_at)
 COMPAT_SYS_SPU(clock_adjtime)
 SYSCALL_SPU(syncfs)
+SYSCALL_SPU(setns)
diff --git a/arch/powerpc/include/asm/unistd.h b/arch/powerpc/include/asm/unistd.h
index 3c21564..2780f7a 100644
--- a/arch/powerpc/include/asm/unistd.h
+++ b/arch/powerpc/include/asm/unistd.h
@@ -371,10 +371,11 @@
 #define __NR_open_by_handle_at	346
 #define __NR_clock_adjtime	347
 #define __NR_syncfs		348
+#define __NR_setns              349
 
 #ifdef __KERNEL__
 
-#define __NR_syscalls		349
+#define __NR_syscalls		350
 
 #define __NR__exit __NR_exit
 #define NR_syscalls	__NR_syscalls
diff --git a/arch/s390/include/asm/unistd.h b/arch/s390/include/asm/unistd.h
index e821525..3399bed 100644
--- a/arch/s390/include/asm/unistd.h
+++ b/arch/s390/include/asm/unistd.h
@@ -276,7 +276,8 @@
 #define __NR_open_by_handle_at	336
 #define __NR_clock_adjtime	337
 #define __NR_syncfs		338
-#define NR_syscalls 339
+#define __NR_setns              339
+#define NR_syscalls 340
 
 /* 
  * There are some system calls that are not present on 64 bit, some
diff --git a/arch/s390/kernel/syscalls.S b/arch/s390/kernel/syscalls.S
index 9c65fd4..3ec04ba 100644
--- a/arch/s390/kernel/syscalls.S
+++ b/arch/s390/kernel/syscalls.S
@@ -347,3 +347,4 @@ SYSCALL(sys_name_to_handle_at,sys_name_to_handle_at,sys_name_to_handle_at_wrappe
 SYSCALL(sys_open_by_handle_at,sys_open_by_handle_at,compat_sys_open_by_handle_at_wrapper)
 SYSCALL(sys_clock_adjtime,sys_clock_adjtime,compat_sys_clock_adjtime_wrapper)
 SYSCALL(sys_syncfs,sys_syncfs,sys_syncfs_wrapper)
+SYSCALL(sys_setns,sys_setns,sys_setns)
diff --git a/arch/sh/include/asm/unistd_32.h b/arch/sh/include/asm/unistd_32.h
index ca7765e..26c697c 100644
--- a/arch/sh/include/asm/unistd_32.h
+++ b/arch/sh/include/asm/unistd_32.h
@@ -373,8 +373,9 @@
 #define __NR_open_by_handle_at	360
 #define __NR_clock_adjtime	361
 #define __NR_syncfs		362
+#define __NR_setns              363
 
-#define NR_syscalls 363
+#define NR_syscalls 364
 
 #ifdef __KERNEL__
 
diff --git a/arch/sh/include/asm/unistd_64.h b/arch/sh/include/asm/unistd_64.h
index a694009..330668a 100644
--- a/arch/sh/include/asm/unistd_64.h
+++ b/arch/sh/include/asm/unistd_64.h
@@ -394,10 +394,11 @@
 #define __NR_open_by_handle_at	371
 #define __NR_clock_adjtime	372
 #define __NR_syncfs		373
+#define __NR_setns              374
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 374
+#define NR_syscalls 375
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/sh/kernel/syscalls_32.S b/arch/sh/kernel/syscalls_32.S
index 030966a..67dcf66 100644
--- a/arch/sh/kernel/syscalls_32.S
+++ b/arch/sh/kernel/syscalls_32.S
@@ -380,3 +380,4 @@ ENTRY(sys_call_table)
 	.long sys_open_by_handle_at	/* 360 */
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns
diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_64.S
index ca0a614..dade54e 100644
--- a/arch/sh/kernel/syscalls_64.S
+++ b/arch/sh/kernel/syscalls_64.S
@@ -400,3 +400,4 @@ sys_call_table:
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns
diff --git a/arch/sparc/include/asm/unistd.h b/arch/sparc/include/asm/unistd.h
index 9d897b6..10b3105 100644
--- a/arch/sparc/include/asm/unistd.h
+++ b/arch/sparc/include/asm/unistd.h
@@ -404,8 +404,9 @@
 #define __NR_open_by_handle_at	333
 #define __NR_clock_adjtime	334
 #define __NR_syncfs		335
+#define __NR_setns              336
 
-#define NR_syscalls		336
+#define NR_syscalls		337
 
 #ifdef __32bit_syscall_numbers__
 /* Sparc 32-bit only has the "setresuid32", "getresuid32" variants,
diff --git a/arch/sparc/kernel/systbls_32.S b/arch/sparc/kernel/systbls_32.S
index 47ac73c..88d0a93 100644
--- a/arch/sparc/kernel/systbls_32.S
+++ b/arch/sparc/kernel/systbls_32.S
@@ -84,4 +84,4 @@ sys_call_table:
 /*320*/	.long sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys_preadv
 /*325*/	.long sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_event_open, sys_recvmmsg, sys_fanotify_init
 /*330*/	.long sys_fanotify_mark, sys_prlimit64, sys_name_to_handle_at, sys_open_by_handle_at, sys_clock_adjtime
-/*335*/	.long sys_syncfs
+/*335*/	.long sys_syncfs, sys_setns
diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systbls_64.S
index 4f3170c..19cdb12 100644
--- a/arch/sparc/kernel/systbls_64.S
+++ b/arch/sparc/kernel/systbls_64.S
@@ -85,7 +85,7 @@ sys_call_table32:
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, compat_sys_preadv
 	.word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo, sys_perf_event_open, compat_sys_recvmmsg, sys_fanotify_init
 /*330*/	.word sys32_fanotify_mark, sys_prlimit64, sys_name_to_handle_at, compat_sys_open_by_handle_at, compat_sys_clock_adjtime
-	.word sys_syncfs
+	.word sys_syncfs, sys_setns
 
 #endif /* CONFIG_COMPAT */
 
@@ -162,4 +162,4 @@ sys_call_table:
 /*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4, sys_preadv
 	.word sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_event_open, sys_recvmmsg, sys_fanotify_init
 /*330*/	.word sys_fanotify_mark, sys_prlimit64, sys_name_to_handle_at, sys_open_by_handle_at, sys_clock_adjtime
-	.word sys_syncfs
+	.word sys_syncfs, sys_setns
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 849a9d2..58bef77 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -848,4 +848,5 @@ ia32_sys_call_table:
 	.quad compat_sys_open_by_handle_at
 	.quad compat_sys_clock_adjtime
 	.quad sys_syncfs
+	.quad sys_setns				/* 345 */
 ia32_syscall_end:
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index a755ef5..be6c177 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -350,10 +350,11 @@
 #define __NR_open_by_handle_at  342
 #define __NR_clock_adjtime	343
 #define __NR_syncfs             344
+#define __NR_setns		345
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 345
+#define NR_syscalls 346
 
 #define __ARCH_WANT_IPC_PARSE_VERSION
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/unistd_64.h
index 160fa76..c46f833 100644
--- a/arch/x86/include/asm/unistd_64.h
+++ b/arch/x86/include/asm/unistd_64.h
@@ -677,6 +677,8 @@ __SYSCALL(__NR_open_by_handle_at, sys_open_by_handle_at)
 __SYSCALL(__NR_clock_adjtime, sys_clock_adjtime)
 #define __NR_syncfs                             306
 __SYSCALL(__NR_syncfs, sys_syncfs)
+#define __NR_setns				307
+__SYSCALL(__NR_setns, sys_setns)
 
 #ifndef __NO_STUBS
 #define __ARCH_WANT_OLD_READDIR
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index abce34d..3d77b82 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -344,3 +344,4 @@ ENTRY(sys_call_table)
 	.long sys_open_by_handle_at
 	.long sys_clock_adjtime
 	.long sys_syncfs
+	.long sys_setns			/* 345 */
diff --git a/arch/xtensa/include/asm/unistd.h b/arch/xtensa/include/asm/unistd.h
index 528042c..a6f934f 100644
--- a/arch/xtensa/include/asm/unistd.h
+++ b/arch/xtensa/include/asm/unistd.h
@@ -683,8 +683,10 @@ __SYSCALL(305, sys_ni_syscall, 0)
 __SYSCALL(306, sys_eventfd, 1)
 #define __NR_recvmmsg				307
 __SYSCALL(307, sys_recvmmsg, 5)
+#define __NR_setns				308
+__SYSCALL(308, sys_setns, 2)
 
-#define __NR_syscall_count			308
+#define __NR_syscall_count			309
 
 /*
  * sysxtensa syscall handler
diff --git a/include/asm-generic/unistd.h b/include/asm-generic/unistd.h
index 07c40d5..5fcd304 100644
--- a/include/asm-generic/unistd.h
+++ b/include/asm-generic/unistd.h
@@ -654,9 +654,11 @@ __SYSCALL(__NR_open_by_handle_at, sys_open_by_handle_at)
 __SYSCALL(__NR_clock_adjtime, sys_clock_adjtime)
 #define __NR_syncfs 267
 __SYSCALL(__NR_syncfs, sys_syncfs)
+#define __NR_setns 268
+__SYSCALL(__NR_setns, sys_setns)
 
 #undef __NR_syscalls
-#define __NR_syscalls 268
+#define __NR_syscalls 269
 
 /*
  * All syscalls below here should go away really,
-- 
1.6.5.2.143.g8cc62
