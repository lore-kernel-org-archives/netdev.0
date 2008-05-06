From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 08/18] flag parameters: dup2
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7MN004059@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33287 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933225AbYEFVTB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new dup3 syscall.  It extends the old dup2
syscall by one parameter which is meant to hold a flag value.  Support
for the O_CLOEXEC flag is added in this patch.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_dup3
# ifdef __x86_64__
#  define __NR_dup3 292
# elif defined __i386__
#  define __NR_dup3 330
# else
#  error "need __NR_dup3"
# endif
#endif

int
main (void)
{
  int fd = syscall (__NR_dup3, 1, 4, 0);
  if (fd == -1)
    {
      puts ("dup3(0) failed");
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
      puts ("dup3(0) set close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_dup3, 1, 4, O_CLOEXEC);
  if (fd == -1)
    {
      puts ("dup3(O_CLOEXEC) failed");
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
      puts ("dup3(O_CLOEXEC) set close-on-exec flag");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/fcntl.c                         |   15 +++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/syscalls.h           |    1 +
 6 files changed, 19 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index 98fd76c..bec604b 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -734,4 +734,5 @@ ia32_sys_call_table:
 	.quad compat_sys_signalfd4
 	.quad sys_eventfd2
 	.quad sys_epoll_create2
+	.quad sys_dup3			/* 330 */
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index 4d7007c..24a3f1e 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -329,3 +329,4 @@ ENTRY(sys_call_table)
 	.long sys_signalfd4
 	.long sys_eventfd2
 	.long sys_epoll_create2
+	.long sys_dup3			/* 330 */
diff --git a/fs/fcntl.c b/fs/fcntl.c
index bfd7765..49a2284 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -126,13 +126,16 @@ static int dupfd(struct file *file, unsigned int start, int cloexec)
 	return fd;
 }
 
-asmlinkage long sys_dup2(unsigned int oldfd, unsigned int newfd)
+asmlinkage long sys_dup3(unsigned int oldfd, unsigned int newfd, int flags)
 {
 	int err = -EBADF;
 	struct file * file, *tofree;
 	struct files_struct * files = current->files;
 	struct fdtable *fdt;
 
+	if ((flags & ~O_CLOEXEC) != 0)
+		return -EINVAL;
+
 	spin_lock(&files->file_lock);
 	if (!(file = fcheck(oldfd)))
 		goto out_unlock;
@@ -164,7 +167,10 @@ asmlinkage long sys_dup2(unsigned int oldfd, unsigned int newfd)
 
 	rcu_assign_pointer(fdt->fd[newfd], file);
 	FD_SET(newfd, fdt->open_fds);
-	FD_CLR(newfd, fdt->close_on_exec);
+	if (flags & O_CLOEXEC)
+		FD_SET(newfd, fdt->close_on_exec);
+	else
+		FD_CLR(newfd, fdt->close_on_exec);
 	spin_unlock(&files->file_lock);
 
 	if (tofree)
@@ -182,6 +188,11 @@ out_fput:
 	goto out;
 }
 
+asmlinkage long sys_dup2(unsigned int oldfd, unsigned int newfd)
+{
+	return sys_dup3(oldfd, newfd, 0);
+}
+
 asmlinkage long sys_dup(unsigned int fildes)
 {
 	int ret = -EBADF;
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index a37d6b0..a1f6383 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -335,6 +335,7 @@
 #define __NR_signalfd4		327
 #define __NR_eventfd2		328
 #define __NR_epoll_create2	329
+#define __NR_dup3		330
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index b6315d2..9eb303e 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -647,6 +647,8 @@ __SYSCALL(__NR_signalfd4, sys_signalfd4)
 __SYSCALL(__NR_eventfd2, sys_eventfd2)
 #define __NR_epoll_create2			291
 __SYSCALL(__NR_epoll_create2, sys_epoll_create2)
+#define __NR_dup3				292
+__SYSCALL(__NR_dup3, sys_dup3)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index e33d285..143d5ee 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -305,6 +305,7 @@ asmlinkage long sys_fcntl64(unsigned int fd,
 #endif
 asmlinkage long sys_dup(unsigned int fildes);
 asmlinkage long sys_dup2(unsigned int oldfd, unsigned int newfd);
+asmlinkage long sys_dup3(unsigned int oldfd, unsigned int newfd, int flags);
 asmlinkage long sys_ioperm(unsigned long from, unsigned long num, int on);
 asmlinkage long sys_ioctl(unsigned int fd, unsigned int cmd,
 				unsigned long arg);
