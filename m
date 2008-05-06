From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 10/18] flag parameters: inotify_init
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7EM004065@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933107AbYEFVSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the new syscall inotify_init1 (note: the 1 stands
for the one parameter the syscall takes, as opposed to no parameter before).
The values excepted for this parameter are function-specific and defined
in the inotify.h header.  Here the values must match the O_* flags, though.
In this patch CLOEXEC support is introduced.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_inotify_init1
# ifdef __x86_64__
#  define __NR_inotify_init1 294
# elif defined __i386__
#  define __NR_inotify_init1 332
# else
#  error "need __NR_inotify_init1"
# endif
#endif

#define IN_CLOEXEC O_CLOEXEC

int
main (void)
{
  int fd;
  fd = syscall (__NR_inotify_init1, 0);
  if (fd == -1)
    {
      puts ("inotify_init1(0) failed");
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
      puts ("inotify_init1(0) set close-on-exit");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_inotify_init1, IN_CLOEXEC);
  if (fd == -1)
    {
      puts ("inotify_init1(IN_CLOEXEC) failed");
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
      puts ("inotify_init1(O_CLOEXEC) does not set close-on-exit");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/inotify_user.c                  |   12 ++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/inotify.h            |    5 +++++
 include/linux/syscalls.h           |    1 +
 7 files changed, 21 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 34071a2..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -736,4 +736,5 @@ ia32_sys_call_table:
 	.quad sys_epoll_create2
 	.quad sys_dup3			/* 330 */
 	.quad sys_pipe2
+	.quad sys_inotify_init1
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 6615476..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -331,3 +331,4 @@ ENTRY(sys_call_table)
 	.long sys_epoll_create2
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
+	.long sys_inotify_init1
diff --git a/fs/inotify_user.c b/fs/inotify_user.c
index 6676c06..93ab4a6 100644
--- a/fs/inotify_user.c
+++ b/fs/inotify_user.c
@@ -566,7 +566,7 @@ static const struct inotify_operations inotify_user_ops = {
 	.destroy_watch	= free_inotify_user_watch,
 };
 
-asmlinkage long sys_inotify_init(void)
+asmlinkage long sys_inotify_init1(int flags)
 {
 	struct inotify_device *dev;
 	struct inotify_handle *ih;
@@ -574,7 +574,10 @@ asmlinkage long sys_inotify_init(void)
 	struct file *filp;
 	int fd, ret;
 
-	fd = get_unused_fd();
+	if (flags & ~IN_CLOEXEC)
+		return -EINVAL;
+
+	fd = get_unused_fd_flags(flags & O_CLOEXEC);
 	if (fd < 0)
 		return fd;
 
@@ -638,6 +641,11 @@ out_put_fd:
 	return ret;
 }
 
+asmlinkage long sys_inotify_init(void)
+{
+	return sys_inotify_init1(0);
+}
+
 asmlinkage long sys_inotify_add_watch(int fd, const char __user *path, u32 mask)
 {
 	struct inode *inode;
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 748a05c..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -337,6 +337,7 @@
 #define __NR_epoll_create2	329
 #define __NR_dup3		330
 #define __NR_pipe2		331
+#define __NR_inotify_init1	332
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index 6aa423d..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -651,6 +651,8 @@ __SYSCALL(__NR_epoll_create2, sys_epoll_create2)
 __SYSCALL(__NR_dup3, sys_dup3)
 #define __NR_pipe2				293
 __SYSCALL(__NR_pipe2, sys_pipe2)
+#define __NR_inotify_init1			294
+__SYSCALL(__NR_inotify_init1, sys_inotify_init1)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/inotify.h b/include/linux/inotify.h
index 742b917..72ef821 100644
--- a/include/linux/inotify.h
+++ b/include/linux/inotify.h
@@ -7,6 +7,8 @@
 #ifndef _LINUX_INOTIFY_H
 #define _LINUX_INOTIFY_H
 
+/* For O_CLOEXEC */
+#include <linux/fcntl.h>
 #include <linux/types.h>
 
 /*
@@ -63,6 +65,9 @@ struct inotify_event {
 			 IN_MOVED_TO | IN_DELETE | IN_CREATE | IN_DELETE_SELF | \
 			 IN_MOVE_SELF)
 
+/* Flags for sys_inotify_init1.  */
+#define IN_CLOEXEC O_CLOEXEC
+
 #ifdef __KERNEL__
 
 #include <linux/dcache.h>
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 143d5ee..aeb2df8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -547,6 +547,7 @@ asmlinkage long sys_get_mempolicy(int __user *policy,
 				unsigned long addr, unsigned long flags);
 
 asmlinkage long sys_inotify_init(void);
+asmlinkage long sys_inotify_init1(int flags);
 asmlinkage long sys_inotify_add_watch(int fd, const char __user *path,
 					u32 mask);
 asmlinkage long sys_inotify_rm_watch(int fd, u32 wd);
