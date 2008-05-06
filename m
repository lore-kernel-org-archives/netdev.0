From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 05/18] flag parameters: eventfd
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7Of004050@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932623AbYEFVSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new eventfd2 syscall.  It extends the old eventfd
syscall by one parameter which is meant to hold a flag value.  In this
patch the only flag support is EFD_CLOEXEC which causes the close-on-exec
flag for the returned file descriptor to be set.

A new name EFD_CLOEXEC is introduced which in this implementation must
have the same value as O_CLOEXEC.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_eventfd2
# ifdef __x86_64__
#  define __NR_eventfd2 290
# elif defined __i386__
#  define __NR_eventfd2 328
# else
#  error "need __NR_eventfd2"
# endif
#endif

#define EFD_CLOEXEC O_CLOEXEC

int
main (void)
{
  int fd = syscall (__NR_eventfd2, 1, 0);
  if (fd == -1)
    {
      puts ("eventfd2(0) failed");
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
      puts ("eventfd2(0) sets close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_eventfd2, 1, EFD_CLOEXEC);
  if (fd == -1)
    {
      puts ("eventfd2(EFD_CLOEXEC) failed");
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
      puts ("eventfd2(EFD_CLOEXEC) does not set close-on-exec flag");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/eventfd.c                       |   13 +++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/eventfd.h            |    6 ++++++
 include/linux/syscalls.h           |    1 +
 7 files changed, 23 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index f556678..d1a3733 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -732,4 +732,5 @@ ia32_sys_call_table:
 	.quad compat_sys_timerfd_settime	/* 325 */
 	.quad compat_sys_timerfd_gettime
 	.quad compat_sys_signalfd4
+	.quad sys_eventfd2
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index c12a36c..cf112cb 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -327,3 +327,4 @@ ENTRY(sys_call_table)
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
 	.long sys_signalfd4
+	.long sys_eventfd2
diff --git a/fs/eventfd.c b/fs/eventfd.c
index 6094265..d872e00 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -198,11 +198,14 @@ struct file *eventfd_fget(int fd)
 	return file;
 }
 
-asmlinkage long sys_eventfd(unsigned int count)
+asmlinkage long sys_eventfd2(unsigned int count, int flags)
 {
 	int fd;
 	struct eventfd_ctx *ctx;
 
+	if (flags & ~EFD_CLOEXEC)
+		return -EINVAL;
+
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
 		return -ENOMEM;
@@ -214,9 +217,15 @@ asmlinkage long sys_eventfd(unsigned int count)
 	 * When we call this, the initialization must be complete, since
 	 * anon_inode_getfd() will install the fd.
 	 */
-	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx, 0);
+	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx,
+			      flags & O_CLOEXEC);
 	if (fd < 0)
 		kfree(ctx);
 	return fd;
 }
 
+asmlinkage long sys_eventfd(unsigned int count)
+{
+	return sys_eventfd2(count, 0);
+}
+
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index c310371..edbd872 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -333,6 +333,7 @@
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
 #define __NR_signalfd4		327
+#define __NR_eventfd2		328
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index 69795bf..ff94de1 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -643,6 +643,8 @@ __SYSCALL(__NR_timerfd_gettime, sys_timerfd_gettime)
 __SYSCALL(__NR_paccept, sys_paccept)
 #define __NR_signalfd4				289
 __SYSCALL(__NR_signalfd4, sys_signalfd4)
+#define __NR_eventfd2				290
+__SYSCALL(__NR_eventfd2, sys_eventfd2)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index a701399..a6c0eae 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -10,6 +10,12 @@
 
 #ifdef CONFIG_EVENTFD
 
+/* For O_CLOEXEC */
+#include <linux/fcntl.h>
+
+/* Flags for eventfd2.  */
+#define EFD_CLOEXEC O_CLOEXEC
+
 struct file *eventfd_fget(int fd);
 int eventfd_signal(struct file *file, int n);
 
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index da99ae4..55f8bf6 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -617,6 +617,7 @@ asmlinkage long sys_timerfd_settime(int ufd, int flags,
 				    struct itimerspec __user *otmr);
 asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
+asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
