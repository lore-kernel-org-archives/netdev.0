From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 10/18] flag parameters: pipe
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkM4029841@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756942AbYEEDnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the new syscall pipe2 which is like pipe but it also
takes an additional parameter which takes a flag value.  This patch
implements the handling of O_CLOEXEC for the flag.  I did not add support
for the new syscall for the architectures which have a special sys_pipe
implementation.  I think the maintainers of those archs have the chance
to go with the unified implementation but that's up to them.

The implementation introduces do_pipe_flags.  I did that instead of changing
all callers of do_pipe because some of the callers are written in assembler.
I would probably screw up changing the assembly code.  To avoid breaking
code do_pipe is now a small wrapper around do_pipe_flags.  Once all callers
are changed over to do_pipe_flags the old do_pipe function can be removed.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_pipe2
# ifdef __x86_64__
#  define __NR_pipe2 293
# elif defined __i386__
#  define __NR_pipe2 331
# else
#  error "need __NR_pipe2"
# endif
#endif

int
main (void)
{
  int fd[2];
  if (syscall (__NR_pipe2, fd, 0) != 0)
    {
      puts ("pipe2(0) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      int coe = fcntl (fd[i], F_GETFD);
      if (coe == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if (coe & FD_CLOEXEC)
        {
          printf ("pipe2(0) set close-on-exit for fd[%d]\n", i);
          return 1;
        }
    }
  close (fd[0]);
  close (fd[1]);

  if (syscall (__NR_pipe2, fd, O_CLOEXEC) != 0)
    {
      puts ("pipe2(O_CLOEXEC) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      int coe = fcntl (fd[i], F_GETFD);
      if (coe == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if ((coe & FD_CLOEXEC) == 0)
        {
          printf ("pipe2(O_CLOEXEC) does not set close-on-exit for fd[%d]\n", i);
          return 1;
        }
    }
  close (fd[0]);
  close (fd[1]);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/cris/kernel/sys_cris.c        |    2 +-
 arch/ia64/ia32/sys_ia32.c          |    2 +-
 arch/ia64/kernel/sys_ia64.c        |    2 +-
 arch/m32r/kernel/sys_m32r.c        |    2 +-
 arch/mips/kernel/syscall.c         |    2 +-
 arch/parisc/hpux/sys_hpux.c        |    2 +-
 arch/sh/kernel/sys_sh32.c          |    2 +-
 arch/sparc/kernel/sys_sparc.c      |    2 +-
 arch/sparc64/kernel/sys_sparc.c    |    2 +-
 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/ia32/sys_ia32.c           |    2 +-
 arch/x86/kernel/syscall_table_32.S |    1 +
 arch/xtensa/kernel/syscall.c       |    2 +-
 fs/pipe.c                          |   23 ++++++++++++++++++-----
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/fs.h                 |    1 +
 17 files changed, 35 insertions(+), 16 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/cris/kernel/sys_cris.c b/arch/cris/kernel/sys_cris.c
index 8b99841..e32ef68 100644
--- a/arch/cris/kernel/sys_cris.c
+++ b/arch/cris/kernel/sys_cris.c
@@ -37,7 +37,7 @@ asmlinkage int sys_pipe(unsigned long __user * fildes)
         int error;
 
         lock_kernel();
-        error = do_pipe(fd);
+        error = do_pipe_flags(fd, 0);
         unlock_kernel();
         if (!error) {
                 if (copy_to_user(fildes, fd, 2*sizeof(int)))
diff --git a/arch/ia64/ia32/sys_ia32.c b/arch/ia64/ia32/sys_ia32.c
index 7e028ce..465116a 100644
--- a/arch/ia64/ia32/sys_ia32.c
+++ b/arch/ia64/ia32/sys_ia32.c
@@ -1139,7 +1139,7 @@ sys32_pipe (int __user *fd)
 	int retval;
 	int fds[2];
 
-	retval = do_pipe(fds);
+	retval = do_pipe_flags(fds, 0);
 	if (retval)
 		goto out;
 	if (copy_to_user(fd, fds, sizeof(fds)))
diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index 1eda194..bcbb6d8 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -160,7 +160,7 @@ sys_pipe (void)
 	int fd[2];
 	int retval;
 
-	retval = do_pipe(fd);
+	retval = do_pipe_flags(fd, 0);
 	if (retval)
 		goto out;
 	retval = fd[0];
diff --git a/arch/m32r/kernel/sys_m32r.c b/arch/m32r/kernel/sys_m32r.c
index 6d7a80f..fc90b8b 100644
--- a/arch/m32r/kernel/sys_m32r.c
+++ b/arch/m32r/kernel/sys_m32r.c
@@ -88,7 +88,7 @@ sys_pipe(unsigned long r0, unsigned long r1, unsigned long r2,
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (!error) {
 		if (copy_to_user((void __user *)r0, fd, 2*sizeof(int)))
 			error = -EFAULT;
diff --git a/arch/mips/kernel/syscall.c b/arch/mips/kernel/syscall.c
index af1bdc8..20d5391 100644
--- a/arch/mips/kernel/syscall.c
+++ b/arch/mips/kernel/syscall.c
@@ -45,7 +45,7 @@ asmlinkage int sys_pipe(nabi_no_regargs volatile struct pt_regs regs)
 	int fd[2];
 	int error, res;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (error) {
 		res = error;
 		goto out;
diff --git a/arch/parisc/hpux/sys_hpux.c b/arch/parisc/hpux/sys_hpux.c
index 0c5b9da..be255eb 100644
--- a/arch/parisc/hpux/sys_hpux.c
+++ b/arch/parisc/hpux/sys_hpux.c
@@ -448,7 +448,7 @@ int hpux_pipe(int *kstack_fildes)
 	int error;
 
 	lock_kernel();
-	error = do_pipe(kstack_fildes);
+	error = do_pipe_flags(kstack_fildes, 0);
 	unlock_kernel();
 	return error;
 }
diff --git a/arch/sh/kernel/sys_sh32.c b/arch/sh/kernel/sys_sh32.c
index 125e493..f0aa5c3 100644
--- a/arch/sh/kernel/sys_sh32.c
+++ b/arch/sh/kernel/sys_sh32.c
@@ -29,7 +29,7 @@ asmlinkage int sys_pipe(unsigned long r4, unsigned long r5,
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (!error) {
 		regs->regs[1] = fd[1];
 		return fd[0];
diff --git a/arch/sparc/kernel/sys_sparc.c b/arch/sparc/kernel/sys_sparc.c
index f188b5d..681fdf2 100644
--- a/arch/sparc/kernel/sys_sparc.c
+++ b/arch/sparc/kernel/sys_sparc.c
@@ -97,7 +97,7 @@ asmlinkage int sparc_pipe(struct pt_regs *regs)
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (error)
 		goto out;
 	regs->u_regs[UREG_I1] = fd[1];
diff --git a/arch/sparc64/kernel/sys_sparc.c b/arch/sparc64/kernel/sys_sparc.c
index 8d4761f..936178d 100644
--- a/arch/sparc64/kernel/sys_sparc.c
+++ b/arch/sparc64/kernel/sys_sparc.c
@@ -418,7 +418,7 @@ asmlinkage long sparc_pipe(struct pt_regs *regs)
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (error)
 		goto out;
 	regs->u_regs[UREG_I1] = fd[1];
diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -735,4 +735,5 @@ ia32_sys_call_table:
 	.quad sys_eventfd2
 	.quad sys_epoll_create2
 	.quad sys_dup3			/* 330 */
+	.quad sys_pipe2
 ia32_syscall_end:
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index f00afdf..d3c6408 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -238,7 +238,7 @@ asmlinkage long sys32_pipe(int __user *fd)
 	int retval;
 	int fds[2];
 
-	retval = do_pipe(fds);
+	retval = do_pipe_flags(fds, 0);
 	if (retval)
 		goto out;
 	if (copy_to_user(fd, fds, sizeof(fds)))
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -330,3 +330,4 @@ ENTRY(sys_call_table)
 	.long sys_eventfd2
 	.long sys_epoll_create2
 	.long sys_dup3			/* 330 */
+	.long sys_pipe2
diff --git a/arch/xtensa/kernel/syscall.c b/arch/xtensa/kernel/syscall.c
index f3e16ef..ac15ecb 100644
--- a/arch/xtensa/kernel/syscall.c
+++ b/arch/xtensa/kernel/syscall.c
@@ -49,7 +49,7 @@ asmlinkage long xtensa_pipe(int __user *userfds)
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, 0);
 	if (!error) {
 		if (copy_to_user(userfds, fd, 2 * sizeof(int)))
 			error = -EFAULT;
diff --git a/fs/pipe.c b/fs/pipe.c
index 3499f9f..796c0a0 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1027,26 +1027,29 @@ struct file *create_read_pipe(struct file *wrf)
 	return f;
 }
 
-int do_pipe(int *fd)
+int do_pipe_flags(int *fd, int flags)
 {
 	struct file *fw, *fr;
 	int error;
 	int fdw, fdr;
 
+	if (flags & ~O_CLOEXEC)
+		return -EINVAL;
+
 	fw = create_write_pipe();
 	if (IS_ERR(fw))
 		return PTR_ERR(fw);
 	fr = create_read_pipe(fw);
 	error = PTR_ERR(fr);
 	if (IS_ERR(fr))
 		goto err_write_pipe;
 
-	error = get_unused_fd();
+	error = get_unused_fd_flags(flags);
 	if (error < 0)
 		goto err_read_pipe;
 	fdr = error;
 
-	error = get_unused_fd();
+	error = get_unused_fd_flags(flags);
 	if (error < 0)
 		goto err_fdr;
 	fdw = error;
@@ -1075,16 +1078,21 @@ int do_pipe(int *fd)
 	return error;
 }
 
+int do_pipe(int *fd)
+{
+	return do_pipe_flags(fd, 0);
+}
+
 /*
  * sys_pipe() is the normal C calling standard for creating
  * a pipe. It's not the way Unix traditionally does this, though.
  */
-asmlinkage long __weak sys_pipe(int __user *fildes)
+asmlinkage long __weak sys_pipe2(int __user *fildes, int flags)
 {
 	int fd[2];
 	int error;
 
-	error = do_pipe(fd);
+	error = do_pipe_flags(fd, flags);
 	if (!error) {
 		if (copy_to_user(fildes, fd, sizeof(fd)))
 			error = -EFAULT;
@@ -1092,6 +1100,11 @@ asmlinkage long __weak sys_pipe(int __user *fildes)
 	return error;
 }
 
+asmlinkage long __weak sys_pipe(int __user *fildes)
+{
+	return sys_pipe2(fildes, 0);
+}
+
 /*
  * pipefs should _never_ be mounted by userland - too much of security hassle,
  * no real gain from having the whole whorehouse mounted. So we don't need
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 8317d94..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -336,6 +336,7 @@
 #define __NR_eventfd2		328
 #define __NR_epoll_create2	329
 #define __NR_dup3		330
+#define __NR_pipe2		331
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -649,6 +649,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_epoll_create2, sys_epoll_create2)
 #define __NR_dup3				292
 __SYSCALL(__NR_dup3, sys_dup3)
+#define __NR_pipe2				293
+__SYSCALL(__NR_pipe2, sys_pipe2)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a1ba005..3694eeb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1775,6 +1775,7 @@ static inline void allow_write_access(struct file *file)
 		atomic_inc(&file->f_path.dentry->d_inode->i_writecount);
 }
 extern int do_pipe(int *);
+extern int do_pipe_flags(int *, int);
 extern struct file *create_read_pipe(struct file *f);
 extern struct file *create_write_pipe(void);
 extern void free_write_pipe(struct file *);
