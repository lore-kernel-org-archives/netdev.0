From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 04/18] flag parameters: signalfd
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7hn004047@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933079AbYEFVSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new signalfd4 syscall.  It extends the old signalfd
syscall by one parameter which is meant to hold a flag value.  In this
patch the only flag support is SFD_CLOEXEC which causes the close-on-exec
flag for the returned file descriptor to be set.

A new name SFD_CLOEXEC is introduced which in this implementation must
have the same value as O_CLOEXEC.

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

#define SFD_CLOEXEC O_CLOEXEC

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
 fs/signalfd.c                      |   14 ++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/signalfd.h           |    5 +++++
 include/linux/syscalls.h           |    1 +
 8 files changed, 33 insertions(+), 6 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..f556678 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -731,4 +731,5 @@ ia32_sys_call_table:
 	.quad sys32_fallocate
 	.quad compat_sys_timerfd_settime	/* 325 */
 	.quad compat_sys_timerfd_gettime
+	.quad compat_sys_signalfd4
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..c12a36c 100644
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
index ddb328b..29d12f8 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -205,11 +205,15 @@ static const struct file_operations signalfd_fops = {
 	.read		= signalfd_read,
 };
 
-asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemask)
+asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask,
+			      size_t sizemask, int flags)
 {
 	sigset_t sigmask;
 	struct signalfd_ctx *ctx;
 
+	if (flags & ~SFD_CLOEXEC)
+		return -EINVAL;
+
 	if (sizemask != sizeof(sigset_t) ||
 	    copy_from_user(&sigmask, user_mask, sizeof(sigmask)))
 		return -EINVAL;
@@ -228,7 +232,7 @@ asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemas
 		 * anon_inode_getfd() will install the fd.
 		 */
 		ufd = anon_inode_getfd("[signalfd]", &signalfd_fops, ctx,
-				       0);
+				       flags & O_CLOEXEC);
 		if (ufd < 0)
 			kfree(ctx);
 	} else {
@@ -250,3 +254,9 @@ asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemas
 
 	return ufd;
 }
+
+asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask,
+			     size_t sizemask)
+{
+	return sys_signalfd4(ufd, user_mask, sizemask, 0);
+}
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 8317d94..c310371 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -332,6 +332,7 @@
 #define __NR_fallocate		324
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
+#define __NR_signalfd4		327
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index d751135..69795bf 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -641,6 +641,8 @@ __SYSCALL(__NR_timerfd_settime, sys_timerfd_settime)
 __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
 #define __NR_paccept				288
 __SYSCALL(__NR_paccept, sys_paccept)
+#define __NR_signalfd4				289
+__SYSCALL(__NR_signalfd4, sys_signalfd4)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index ea037f2..8b3f7b7 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -8,6 +8,11 @@
 #ifndef _LINUX_SIGNALFD_H
 #define _LINUX_SIGNALFD_H
 
+/* For O_CLOEXEC */
+#include <linux/fcntl.h>
+
+/* Flags for signalfd4.  */
+#define SFD_CLOEXEC O_CLOEXEC
 
 struct signalfd_siginfo {
 	__u32 ssi_signo;
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e022405..da99ae4 100644
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
