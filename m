From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 08/18] flag parameters: epoll_create
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gk49029835@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756970AbYEEDn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the new epoll_create2 syscall.  It extends the old epoll_create
syscall by one parameter which is meant to hold a flag value.  In this
patch the only flag support is EPOLL_CLOEXEC which causes the close-on-exec
flag for the returned file descriptor to be set.

A new flag EPOLL_CLOEXEC is used instead of reusing O_CLOEXEC to prevent
exhaustion of the int bit field in case we need more flags.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_epoll_create2
# ifdef __x86_64__
#  define __NR_epoll_create2 291
# elif defined __i386__
#  define __NR_epoll_create2 329
# else
#  error "need __NR_epoll_create2"
# endif
#endif

#define EPOLL_CLOEXEC (1 << 0)

int
main (void)
{
  int fd = syscall (__NR_epoll_create2, 1, 0);
  if (fd == -1)
    {
      puts ("epoll_create2(0) failed");
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
      puts ("epoll_create2(0) set close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_epoll_create2, 1, EPOLL_CLOEXEC);
  if (fd == -1)
    {
      puts ("epoll_create2(EPOLL_CLOEXEC) failed");
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
      puts ("epoll_create2(EPOLL_CLOEXEC) set close-on-exec flag");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 arch/x86/ia32/ia32entry.S          |    1 +
 arch/x86/kernel/syscall_table_32.S |    1 +
 fs/eventpoll.c                     |   20 ++++++++++++++++++--
 include/asm-x86/unistd_32.h        |    1 +
 include/asm-x86/unistd_64.h        |    2 ++
 include/linux/eventpoll.h          |    2 ++
 include/linux/syscalls.h           |    1 +
 7 files changed, 26 insertions(+), 2 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
index b5e329d..37e4992 100644
--- a/arch/x86/ia32/ia32entry.S
+++ b/arch/x86/ia32/ia32entry.S
@@ -733,4 +733,5 @@ ia32_sys_call_table:
 	.quad compat_sys_timerfd_gettime
 	.quad compat_sys_signalfd4
 	.quad sys_eventfd2
+	.quad sys_epoll_create2
 ia32_syscall_end:
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index adff556..f59aba5 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -328,3 +328,4 @@ ENTRY(sys_call_table)
 	.long sys_timerfd_gettime
 	.long sys_signalfd4
 	.long sys_eventfd2
+	.long sys_epoll_create2
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 990c01d..7714e91 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -33,6 +33,7 @@
 #include <linux/bitops.h>
 #include <linux/mutex.h>
 #include <linux/anon_inodes.h>
+#include <linux/flagsremap.h>
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <asm/io.h>
@@ -1040,16 +1041,26 @@ retry:
 	return res;
 }
 
+static const struct flags_rmap epoll_file_flags_remap[] = {
+	{ EPOLL_CLOEXEC, O_CLOEXEC }
+};
+
 /*
  * It opens an eventpoll file descriptor. The "size" parameter is there
  * for historical reasons, when epoll was using an hash instead of an
  * RB tree. With the current implementation, the "size" parameter is ignored
  * (besides sanity checks).
  */
-asmlinkage long sys_epoll_create(int size)
+asmlinkage long sys_epoll_create2(int size, int flags)
 {
 	int error, fd = -1;
 	struct eventpoll *ep;
+	int fflags;
+
+	if (flags_remap(epoll_file_flags_remap,
+			ARRAY_SIZE(epoll_file_flags_remap),
+			flags, &fflags))
+		return -EINVAL;
 
 	DNPRINTK(3, (KERN_INFO "[%p] eventpoll: sys_epoll_create(%d)\n",
 		     current, size));
@@ -1068,7 +1079,7 @@ asmlinkage long sys_epoll_create(int size)
 	 * Creates all the items needed to setup an eventpoll file. That is,
 	 * a file structure and a free file descriptor.
 	 */
-	fd = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep, 0);
+	fd = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep, fflags);
 	if (fd < 0)
 		ep_free(ep);
 
@@ -1079,6 +1090,11 @@ error_return:
 	return fd;
 }
 
+asmlinkage long sys_epoll_create(int size)
+{
+	return sys_epoll_create2(size, 0);
+}
+
 /*
  * The following function implements the controller interface for
  * the eventpoll file that enables the insertion/removal/change of
diff --git a/include/linux/eventpoll.h b/include/linux/eventpoll.h
index cf79853..ca3a6e8 100644
--- a/include/linux/eventpoll.h
+++ b/include/linux/eventpoll.h
@@ -16,6 +16,8 @@
 
 #include <linux/types.h>
 
+/* Flags for epoll_create2.  */
+#define EPOLL_CLOEXEC (1 << 0)
 
 /* Valid opcodes to issue to sys_epoll_ctl() */
 #define EPOLL_CTL_ADD 1
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 8317d94..b3daf50 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -334,6 +334,7 @@
 #define __NR_timerfd_gettime	326
 #define __NR_signalfd4		327
 #define __NR_eventfd2		328
+#define __NR_epoll_create2	329
 
 #ifdef __KERNEL__
 
diff --git a/include/asm-x86/unistd_64.h b/include/asm-x86/unistd_64.h
index fe26e36..5ef6778 100644
--- a/include/asm-x86/unistd_64.h
+++ b/include/asm-x86/unistd_64.h
@@ -645,6 +645,8 @@ __SYSCALL(__NR_fallocate, sys_fallocate)
 __SYSCALL(__NR_signalfd4, sys_signalfd4)
 #define __NR_eventfd2				290
 __SYSCALL(__NR_eventfd2, sys_eventfd2)
+#define __NR_epoll_create2			291
+__SYSCALL(__NR_epoll_create2, sys_epoll_create2)
 
 
 #ifndef __NO_STUBS
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0522f36..aeb2df8 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -430,6 +430,7 @@ asmlinkage long sys_poll(struct pollfd __user *ufds, unsigned int nfds,
 asmlinkage long sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 			fd_set __user *exp, struct timeval __user *tvp);
 asmlinkage long sys_epoll_create(int size);
+asmlinkage long sys_epoll_create2(int size, int flags);
 asmlinkage long sys_epoll_ctl(int epfd, int op, int fd,
 				struct epoll_event __user *event);
 asmlinkage long sys_epoll_wait(int epfd, struct epoll_event __user *events,
