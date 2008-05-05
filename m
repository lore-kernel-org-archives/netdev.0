From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 11/18] flag parameters: inotify_init
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gki6029844@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901AbYEEDm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the new syscall inotify_init1 (note: the 1 stands
for the one parameter the syscall takes, as opposed to no parameter before).
The values excepted for this parameter are function-specific and defined
in the inotify.h header.  In this patch CLOEXEC support is introduced.

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

#define IN_CLOEXEC (1 << 0)

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
 fs/inotify_user.c                  |   20 ++++++++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/inotify.h            |    3 +++
 include/linux/syscalls.h           |    1 +
 7 files changed, 27 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -736,4 +736,5 @@ ia32_sys_call_table:
 	.quad sys_epoll_create2
 	.quad sys_dup3			/* 330 */
 	.quad sys_pipe2
+	.quad sys_inotify_init1
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -331,3 +331,4 @@ ENTRY(sys_call_table)
 	.long sys_epoll_create2
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
+	.long sys_inotify_init1
diff --git a/fs/inotify_user.c b/fs/inotify_user.c
index 6676c06..4bb4c54 100644
--- a/fs/inotify_user.c
+++ b/fs/inotify_user.c
@@ -32,6 +32,7 @@
 #include <linux/inotify.h>
 #include <linux/syscalls.h>
 #include <linux/magic.h>
+#include <linux/flagsremap.h>
 
 #include <asm/ioctls.h>
 
@@ -566,15 +567,25 @@ static const struct inotify_operations inotify_user_ops = {
 	.destroy_watch	= free_inotify_user_watch,
 };
 
-asmlinkage long sys_inotify_init(void)
+static const struct flags_rmap inotify_file_flags_remap[] = {
+        { IN_CLOEXEC, O_CLOEXEC },
+};
+
+asmlinkage long sys_inotify_init1(int flags)
 {
 	struct inotify_device *dev;
 	struct inotify_handle *ih;
 	struct user_struct *user;
 	struct file *filp;
 	int fd, ret;
+	int fflags;
+
+	if (flags_remap(inotify_file_flags_remap,
+			ARRAY_SIZE(inotify_file_flags_remap),
+			flags, &fflags) != 0)
+		return -EINVAL;
 
-	fd = get_unused_fd();
+	fd = get_unused_fd_flags(fflags);
 	if (fd < 0)
 		return fd;
 
@@ -638,6 +649,11 @@ out_put_fd:
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
index 8317d94..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -337,6 +337,7 @@
 #define __NR_epoll_create2	329
 #define __NR_dup3		330
 #define __NR_pipe2		331
+#define __NR_inotify_init1	332
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -651,6 +651,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_dup3, sys_dup3)
 #define __NR_pipe2				293
 __SYSCALL(__NR_pipe2, sys_pipe2)
+#define __NR_inotify_init1			294
+__SYSCALL(__NR_inotify_init1, sys_inotify_init1)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/inotify.h b/include/linux/inotify.h
index 742b917..af30cfd 100644
--- a/include/linux/inotify.h
+++ b/include/linux/inotify.h
@@ -63,6 +63,9 @@ struct inotify_event {
 			 IN_MOVED_TO | IN_DELETE | IN_CREATE | IN_DELETE_SELF | \
 			 IN_MOVE_SELF)
 
+/* Flags for sys_inotify_init1.  */
+#define IN_CLOEXEC (1 << 0)
+
 #ifdef __KERNEL__
 
 #include <linux/dcache.h>
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0522f36..aeb2df8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -547,6 +547,7 @@ asmlinkage long sys_get_mempolicy(int __user *policy,
 				unsigned long addr, unsigned long flags);
 
 asmlinkage long sys_inotify_init(void);
+asmlinkage long sys_inotify_init1(int flags);
 asmlinkage long sys_inotify_add_watch(int fd, const char __user *path,
 					u32 mask);
 asmlinkage long sys_inotify_rm_watch(int fd, u32 wd);
