From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 15/18] flag parameters: NONBLOCK in timerfd_create
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI72i004086@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48585 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933161AbYEFVSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the TFD_NONBLOCK flag to timerfd_create.  The
additional changes needed are minimal.

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

#define TFD_NONBLOCK O_NONBLOCK

int
main (void)
{
  int fd = syscall (__NR_timerfd_create, CLOCK_REALTIME, 0);
  if (fd == -1)
    {
      puts ("timerfd_create(0) failed");
      return 1;
    }
  int fl = fcntl (fd, F_GETFL);
  if (fl == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if (fl & O_NONBLOCK)
    {
      puts ("timerfd_create(0) set non-blocking mode");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_timerfd_create, CLOCK_REALTIME, TFD_NONBLOCK);
  if (fd == -1)
    {
      puts ("timerfd_create(TFD_NONBLOCK) failed");
      return 1;
    }
  fl = fcntl (fd, F_GETFL);
  if (fl == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if ((fl & O_NONBLOCK) == 0)
    {
      puts ("timerfd_create(TFD_NONBLOCK) set non-blocking mode");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/timerfd.c            |    4 ++--
 include/linux/timerfd.h |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/timerfd.c b/fs/timerfd.c
index c6ef5e3..75d44ef 100644
--- a/fs/timerfd.c
+++ b/fs/timerfd.c
@@ -184,7 +184,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
 	int ufd;
 	struct timerfd_ctx *ctx;
 
-	if (flags & ~TFD_CLOEXEC)
+	if (flags & ~(TFD_CLOEXEC | TFD_NONBLOCK))
 		return -EINVAL;
 	if (clockid != CLOCK_MONOTONIC &&
 	    clockid != CLOCK_REALTIME)
@@ -199,7 +199,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
 	hrtimer_init(&ctx->tmr, clockid, HRTIMER_MODE_ABS);
 
 	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx,
-			       flags & O_CLOEXEC);
+			       flags & (O_CLOEXEC | O_NONBLOCK));
 	if (ufd < 0)
 		kfree(ctx);
 
diff --git a/include/linux/timerfd.h b/include/linux/timerfd.h
index 96ed97d..86cb050 100644
--- a/include/linux/timerfd.h
+++ b/include/linux/timerfd.h
@@ -8,7 +8,7 @@
 #ifndef _LINUX_TIMERFD_H
 #define _LINUX_TIMERFD_H
 
-/* For O_CLOEXEC */
+/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
 /* Flags for timerfd_settime.  */
@@ -16,6 +16,7 @@
 
 /* Flags for timerfd_create.  */
 #define TFD_CLOEXEC O_CLOEXEC
+#define TFD_NONBLOCK O_NONBLOCK
 
 
 #endif /* _LINUX_TIMERFD_H */
