From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] reintroduce accept4
Date: Thu, 13 Nov 2008 16:07:38 -0800 (PST)
Message-ID: <20081113.160738.193690346.davem@davemloft.net>
References: <18716.43376.534965.688695@cargo.ozlabs.ibm.com>
	<18716.43543.256621.825529@cargo.ozlabs.ibm.com>
	<20081113145737.96898aaf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	drepper-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davidel-AhlLAIvw+VEjIGhXcJzhZg@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org,
	hch-jcswGhMUV9g@public.gmane.org, alan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jakub-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081113145737.96898aaf.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Thu, 13 Nov 2008 14:57:37 -0800

> Here's the latest version, for review-n-test enjoyment:

This adds the sparc syscall hookups.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

diff --git a/arch/sparc/include/asm/unistd_32.h b/arch/sparc/include/asm/unistd_32.h
index 648643a..0d13d2a 100644
--- a/arch/sparc/include/asm/unistd_32.h
+++ b/arch/sparc/include/asm/unistd_32.h
@@ -338,8 +338,9 @@
 #define __NR_dup3		320
 #define __NR_pipe2		321
 #define __NR_inotify_init1	322
+#define __NR_accept4		323
 
-#define NR_SYSCALLS		323
+#define NR_SYSCALLS		324
 
 /* Sparc 32-bit only has the "setresuid32", "getresuid32" variants,
  * it never had the plain ones and there is no value to adding those
diff --git a/arch/sparc/include/asm/unistd_64.h b/arch/sparc/include/asm/unistd_64.h
index c5cc0e0..fa5d3c0 100644
--- a/arch/sparc/include/asm/unistd_64.h
+++ b/arch/sparc/include/asm/unistd_64.h
@@ -340,8 +340,9 @@
 #define __NR_dup3		320
 #define __NR_pipe2		321
 #define __NR_inotify_init1	322
+#define __NR_accept4		323
 
-#define NR_SYSCALLS		323
+#define NR_SYSCALLS		324
 
 #ifdef __KERNEL__
 #define __ARCH_WANT_IPC_PARSE_VERSION
diff --git a/arch/sparc/kernel/systbls.S b/arch/sparc/kernel/systbls.S
index e1b9233..7d08075 100644
--- a/arch/sparc/kernel/systbls.S
+++ b/arch/sparc/kernel/systbls.S
@@ -81,4 +81,4 @@ sys_call_table:
 /*305*/	.long sys_set_mempolicy, sys_kexec_load, sys_move_pages, sys_getcpu, sys_epoll_pwait
 /*310*/	.long sys_utimensat, sys_signalfd, sys_timerfd_create, sys_eventfd, sys_fallocate
 /*315*/	.long sys_timerfd_settime, sys_timerfd_gettime, sys_signalfd4, sys_eventfd2, sys_epoll_create1
-/*320*/	.long sys_dup3, sys_pipe2, sys_inotify_init1
+/*320*/	.long sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4
diff --git a/arch/sparc64/kernel/sys32.S b/arch/sparc64/kernel/sys32.S
index ade18ba..f061c4d 100644
--- a/arch/sparc64/kernel/sys32.S
+++ b/arch/sparc64/kernel/sys32.S
@@ -150,7 +150,7 @@ sys32_mmap2:
 sys32_socketcall:	/* %o0=call, %o1=args */
 	cmp		%o0, 1
 	bl,pn		%xcc, do_einval
-	 cmp		%o0, 17
+	 cmp		%o0, 18
 	bg,pn		%xcc, do_einval
 	 sub		%o0, 1, %o0
 	sllx		%o0, 5, %o0
@@ -319,6 +319,15 @@ do_sys_recvmsg: /* compat_sys_recvmsg(int, struct compat_msghdr *, unsigned int)
 	nop
 	nop
 	nop
+do_sys_accept4: /* sys_accept4(int, struct sockaddr *, int *, int) */
+63:	ldswa		[%o1 + 0x0] %asi, %o0
+	sethi		%hi(sys_accept4), %g1
+64:	lduwa		[%o1 + 0x8] %asi, %o2
+65:	ldswa		[%o1 + 0xc] %asi, %o3
+	jmpl		%g1 + %lo(sys_accept4), %g0
+66:	 lduwa		[%o1 + 0x4] %asi, %o1
+	nop
+	nop
 
 	.section	__ex_table,"a"
 	.align		4
@@ -353,4 +362,6 @@ do_sys_recvmsg: /* compat_sys_recvmsg(int, struct compat_msghdr *, unsigned int)
 	.word		57b, __retl_efault, 58b, __retl_efault
 	.word		59b, __retl_efault, 60b, __retl_efault
 	.word		61b, __retl_efault, 62b, __retl_efault
+	.word		63b, __retl_efault, 64b, __retl_efault
+	.word		65b, __retl_efault, 66b, __retl_efault
 	.previous
diff --git a/arch/sparc64/kernel/systbls.S b/arch/sparc64/kernel/systbls.S
index b2fa4c1..9fc78cf 100644
--- a/arch/sparc64/kernel/systbls.S
+++ b/arch/sparc64/kernel/systbls.S
@@ -82,7 +82,7 @@ sys_call_table32:
 	.word compat_sys_set_mempolicy, compat_sys_kexec_load, compat_sys_move_pages, sys_getcpu, compat_sys_epoll_pwait
 /*310*/	.word compat_sys_utimensat, compat_sys_signalfd, sys_timerfd_create, sys_eventfd, compat_sys_fallocate
 	.word compat_sys_timerfd_settime, compat_sys_timerfd_gettime, compat_sys_signalfd4, sys_eventfd2, sys_epoll_create1
-/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1
+/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4
 
 #endif /* CONFIG_COMPAT */
 
@@ -156,4 +156,4 @@ sys_call_table:
 	.word sys_set_mempolicy, sys_kexec_load, sys_move_pages, sys_getcpu, sys_epoll_pwait
 /*310*/	.word sys_utimensat, sys_signalfd, sys_timerfd_create, sys_eventfd, sys_fallocate
 	.word sys_timerfd_settime, sys_timerfd_gettime, sys_signalfd4, sys_eventfd2, sys_epoll_create1
-/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1
+/*320*/	.word sys_dup3, sys_pipe2, sys_inotify_init1, sys_accept4
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
