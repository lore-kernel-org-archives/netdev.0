From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 06/18] flag parameters: eventfd
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkQF029829@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801AbYEEDnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new eventfd2 syscall.  It extends the old eventfd
syscall by one parameter which is meant to hold a flag value.  In this
patch the only flag support is EFD_CLOEXEC which causes the close-on-exec
flag for the returned file descriptor to be set.

A new flag EFD_CLOEXEC is used instead of reusing O_CLOEXEC to prevent
exhaustion of the int bit field in case we need more flags.

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

#define EFD_CLOEXEC (1 << 0)

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
 fs/eventfd.c                       |   20 ++++++++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/eventfd.h            |    3 +++
 include/linux/syscalls.h           |    1 +
 7 files changed, 27 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -732,4 +732,5 @@ ia32_sys_call_table:
 	.quad compat_sys_timerfd_settime	/* 325 */
 	.quad compat_sys_timerfd_gettime
 	.quad compat_sys_signalfd4
+	.quad sys_eventfd2
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -327,3 +327,4 @@ ENTRY(sys_call_table)
 	.long sys_timerfd_settime	/* 325 */
 	.long sys_timerfd_gettime
 	.long sys_signalfd4
+	.long sys_eventfd2
diff --git a/fs/eventfd.c b/fs/eventfd.c
index 343942d..ddb543d 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -16,6 +16,7 @@
 #include <linux/anon_inodes.h>
 #include <linux/eventfd.h>
 #include <linux/syscalls.h>
+#include <linux/flagsremap.h>
 
 struct eventfd_ctx {
 	wait_queue_head_t wqh;
@@ -198,10 +199,20 @@ struct file *eventfd_fget(int fd)
 	return file;
 }
 
-asmlinkage long sys_eventfd(unsigned int count)
+static const struct flags_rmap eventfd_file_flags_remap[] = {
+	{ EFD_CLOEXEC, O_CLOEXEC },
+};
+
+asmlinkage long sys_eventfd2(unsigned int count, int flags)
 {
 	int fd;
 	struct eventfd_ctx *ctx;
+	int fflags;
+
+	if (flags_remap(eventfd_file_flags_remap,
+			ARRAY_SIZE(eventfd_file_flags_remap),
+			flags, &fflags) != 0)
+		return -EINVAL;
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (!ctx)
@@ -214,9 +226,14 @@ asmlinkage long sys_eventfd(unsigned int count)
 	 * When we call this, the initialization must be complete, since
 	 * anon_inode_getfd() will install the fd.
 	 */
-	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx, 0);
+	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx, fflags);
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
index 8317d94..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -333,6 +333,7 @@
 #define __NR_timerfd_settime	325
 #define __NR_timerfd_gettime	326
 #define __NR_signalfd4		327
+#define __NR_eventfd2		328
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -643,6 +643,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_paccept, sys_paccept)
 #define __NR_signalfd4				289
 __SYSCALL(__NR_signalfd4, sys_signalfd4)
+#define __NR_eventfd2				290
+__SYSCALL(__NR_eventfd2, sys_eventfd2)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index a701399..0c2f68b 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -10,6 +10,9 @@
 
 #ifdef CONFIG_EVENTFD
 
+/* Flags for eventfd2.  */
+#define EFD_CLOEXEC (1 << 0)
+
 struct file *eventfd_fget(int fd);
 int eventfd_signal(struct file *file, int n);
 
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0522f36..aeb2df8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -617,6 +617,7 @@ asmlinkage long sys_set_robust_list(struct robust_list_head __user *head,
 				    struct itimerspec __user *otmr);
 asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
+asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
