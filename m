From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 07/18] flag parameters: timerfd_create
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkOX029832@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756902AbYEEDnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timerfd_create syscall already has a flags parameter.  It just is
unused so far.  This patch changes this by introducing the TFD_CLOEXEC
flag to set the close-on-exec flag for the returned file descriptor.

A new flag TFD_CLOEXEC is used instead of reusing O_CLOEXEC to prevent
exhaustion of the int bit field in case we need more flags.

The following test must be adjusted for architectures other than x86 and
x86-64 and in case the syscall numbers changed.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#include <fcntl.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <sys/syscall.h>

#ifndef __NR_timerfd_create
# ifdef __x86_64__
#  define __NR_timerfd_create 283
# elif defined __i386__
#  define __NR_timerfd_create 322
# else
#  error "need __NR_timerfd_create"
# endif
#endif

#define TFD_CLOEXEC (1 << 0)

int
main (void)
{
  int fd = syscall (__NR_timerfd_create, CLOCK_REALTIME, 0);
  if (fd == -1)
    {
      puts ("timerfd_create(0) failed");
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
      puts ("timerfd_create(0) set close-on-exec flag");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_timerfd_create, CLOCK_REALTIME, TFD_CLOEXEC);
  if (fd == -1)
    {
      puts ("timerfd_create(TFD_CLOEXEC) failed");
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
      puts ("timerfd_create(TFD_CLOEXEC) set close-on-exec flag");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/timerfd.c            |   12 ++++++++++--
 include/linux/timerfd.h |    4 +++-
 2 files changed, 13 insertions(+), 3 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/timerfd.c b/fs/timerfd.c
index d87d354..f998991 100644
--- a/fs/timerfd.c
+++ b/fs/timerfd.c
@@ -21,6 +21,7 @@
 #include <linux/anon_inodes.h>
 #include <linux/timerfd.h>
 #include <linux/syscalls.h>
+#include <linux/flagsremap.h>
 
 struct timerfd_ctx {
 	struct hrtimer tmr;
@@ -179,12 +180,19 @@ static struct file *timerfd_fget(int fd)
 	return file;
 }
 
+static const struct flags_rmap timerfd_file_flags_remap[] = {
+	{ TFD_CLOEXEC, O_CLOEXEC },
+};
+
 asmlinkage long sys_timerfd_create(int clockid, int flags)
 {
 	int ufd;
 	struct timerfd_ctx *ctx;
+	int fflags;
 
-	if (flags)
+	if (flags_remap(timerfd_file_flags_remap,
+			ARRAY_SIZE(timerfd_file_flags_remap),
+			flags, &fflags))
 		return -EINVAL;
 	if (clockid != CLOCK_MONOTONIC &&
 	    clockid != CLOCK_REALTIME)
@@ -198,7 +207,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
 	ctx->clockid = clockid;
 	hrtimer_init(&ctx->tmr, clockid, HRTIMER_MODE_ABS);
 
-	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx, 0);
+	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx, fflags);
 	if (ufd < 0)
 		kfree(ctx);
 
diff --git a/include/linux/timerfd.h b/include/linux/timerfd.h
index cf2b10d..c2fb04e 100644
--- a/include/linux/timerfd.h
+++ b/include/linux/timerfd.h
@@ -8,9 +8,11 @@
 #ifndef _LINUX_TIMERFD_H
 #define _LINUX_TIMERFD_H
 
-
+/* Flags for timerfd_settime.  */
 #define TFD_TIMER_ABSTIME (1 << 0)
 
+/* Flags for timerfd_create.  */
+#define TFD_CLOEXEC (1 << 0)
 
 
 #endif /* _LINUX_TIMERFD_H */
