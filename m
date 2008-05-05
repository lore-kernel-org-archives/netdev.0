From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 05/18] flag parameters: signalfd
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkRB029826@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971AbYEEDnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new signalfd4 syscall.  It extends the old signalfd
syscall by one parameter which is meant to hold a flag value.  In this
patch the only flag support is SFD_CLOEXEC which causes the close-on-exec
flag for the returned file descriptor to be set.

A new flag SFD_CLOEXEC is used instead of reusing O_CLOEXEC to prevent
exhaustion of the int bit field in case we need more flags.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_signalfd4
# ifdef __x86_64__
#  define __NR_signalfd4 289
# elif defined __i386__
#  define __NR_signalfd4 327
# else
#  error "need __NR_signalfd4"
# endif
#endif

#define SFD_CLOEXEC (1 << 0)

int
main (void)
{
  sigset_t ss;
  sigemptyset (&ss);
  sigaddset (&ss, SIGUSR1);
  int fd = syscall (__NR_signalfd4, -1, &ss, 8, 0);
  if (fd == -1)
    {
      puts ("signalfd4(0) failed");
      return 1;
    }
  int coe = fcntl (fd, F_GETFD);
  if (coe == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if (coe & FD_CLOEXEC)
    {
      puts ("signalfd4(0) set close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_signalfd4, -1, &ss, 8, SFD_CLOEXEC);
  if (fd == -1)
    {
      puts ("signalfd4(SFD_CLOEXEC) failed");
      return 1;
    }
  coe = fcntl (fd, F_GETFD);
  if (coe == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if ((coe & FD_CLOEXEC) == 0)
    {
      puts ("signalfd4(SFD_CLOEXEC) does not set close-on-exec flag");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/compat.c                        |   14 ++++++++++----
 fs/signalfd.c                      |   22 ++++++++++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/signalfd.h           |    3 +++
 include/linux/syscalls.h           |    1 +
 8 files changed, 39 insertions(+), 6 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -731,4 +731,5 @@ ia32_sys_call_table:
 	.quad sys32_fallocate
 	.quad compat_sys_timerfd_settime	/* 325 */
 	.quad compat_sys_timerfd_gettime
+	.quad compat_sys_signalfd4
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -326,3 +326,4 @@ ENTRY(sys_call_table)
 	.long sys_fallocate
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
+	.long sys_signalfd4
diff --git a/fs/compat.c b/fs/compat.c
index 332a869..2ab01c5 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -2131,9 +2131,9 @@ asmlinkage long compat_sys_epoll_pwait(int epfd,
 
 #ifdef CONFIG_SIGNALFD
 
-asmlinkage long compat_sys_signalfd(int ufd,
-				    const compat_sigset_t __user *sigmask,
-				    compat_size_t sigsetsize)
+asmlinkage long compat_sys_signalfd4(int ufd,
+				     const compat_sigset_t __user *sigmask,
+				     compat_size_t sigsetsize, int flags)
 {
 	compat_sigset_t ss32;
 	sigset_t tmp;
@@ -2148,9 +2148,15 @@ asmlinkage long compat_sys_signalfd(int ufd,
 	if (copy_to_user(ksigmask, &tmp, sizeof(sigset_t)))
 		return -EFAULT;
 
-	return sys_signalfd(ufd, ksigmask, sizeof(sigset_t));
+	return sys_signalfd4(ufd, ksigmask, sizeof(sigset_t), flags);
 }
 
+asmlinkage long compat_sys_signalfd(int ufd,
+				    const compat_sigset_t __user *sigmask,
+				    compat_size_t sigsetsize)
+{
+	return compat_sys_signalfd4(ufd, sigmask, sigsetsize, 0);
+}
 #endif /* CONFIG_SIGNALFD */
 
 #ifdef CONFIG_TIMERFD
diff --git a/fs/signalfd.c b/fs/signalfd.c
index 6197256..a73333b 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -28,6 +28,7 @@
 #include <linux/anon_inodes.h>
 #include <linux/signalfd.h>
 #include <linux/syscalls.h>
+#include <linux/flagsremap.h>
 
 struct signalfd_ctx {
 	sigset_t sigmask;
@@ -205,10 +206,21 @@ static const struct file_operations signalfd_fops = {
 	.read		= signalfd_read,
 };
 
-asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemask)
+static const struct flags_rmap signalfd_file_flags_remap[] = {
+	{ SFD_CLOEXEC, O_CLOEXEC },
+};
+
+asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask,
+			      size_t sizemask, int flags)
 {
 	sigset_t sigmask;
 	struct signalfd_ctx *ctx;
+	int fflags;
+
+	if (flags_remap(signalfd_file_flags_remap,
+			ARRAY_SIZE(signalfd_file_flags_remap),
+			flags, &fflags))
+		return -EINVAL;
 
 	if (sizemask != sizeof(sigset_t) ||
 	    copy_from_user(&sigmask, user_mask, sizeof(sigmask)))
@@ -228,7 +240,7 @@ asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemas
 		 * anon_inode_getfd() will install the fd.
 		 */
 		ufd = anon_inode_getfd("[signalfd]", &signalfd_fops, ctx,
-				       0);
+				       fflags);
 		if (ufd < 0)
 			kfree(ctx);
 	} else {
@@ -250,3 +262,9 @@ asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemas
 
 	return ufd;
 }
+
+asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask,
+			     size_t sizemask)
+{
+	return sys_signalfd4(ufd, user_mask, sizemask, 0);
+}
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 8317d94..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -332,6 +332,7 @@
 #define __NR_fallocate		324
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
+#define __NR_signalfd4		327
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -641,6 +641,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
 #define __NR_paccept				288
 __SYSCALL(__NR_paccept, sys_paccept)
+#define __NR_signalfd4				289
+__SYSCALL(__NR_signalfd4, sys_signalfd4)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index ea037f2..98a749a 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -9,6 +9,9 @@
 #define _LINUX_SIGNALFD_H
 
 
+/* Flags for signalfd4.  */
+#define SFD_CLOEXEC (1 << 0)
+
 struct signalfd_siginfo {
 	__u32 ssi_signo;
 	__s32 ssi_errno;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0522f36..aeb2df8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -610,6 +610,7 @@ asmlinkage long sys_set_robust_list(struct robust_list_head __user *head,
 				    size_t len);
 asmlinkage long sys_getcpu(unsigned __user *cpu, unsigned __user *node, struct getcpu_cache __user *cache);
 asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemask);
+asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask, size_t sizemask, int flags);
 asmlinkage long sys_timerfd_create(int clockid, int flags);
 asmlinkage long sys_timerfd_settime(int ufd, int flags,
 				    const struct itimerspec __user *utmr,
