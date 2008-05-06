From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 13/18] flag parameters: NONBLOCK in signalfd
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7er004075@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932946AbYEFVSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the SFD_NONBLOCK flag to signalfd4.  The
additional changes needed are minimal.

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

#define SFD_NONBLOCK O_NONBLOCK

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
  int fl = fcntl (fd, F_GETFL);
  if (fl == -1)
    {
      puts ("fcntl failed");
      return 1;
    }
  if (fl & O_NONBLOCK)
    {
      puts ("signalfd4(0) set non-blocking mode");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_signalfd4, -1, &ss, 8, SFD_NONBLOCK);
  if (fd == -1)
    {
      puts ("signalfd4(SFD_NONBLOCK) failed");
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
      puts ("signalfd4(SFD_NONBLOCK) does not set non-blocking mode");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/signalfd.c            |    4 ++--
 include/linux/signalfd.h |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/signalfd.c b/fs/signalfd.c
index c8609fa..5441a4b 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -211,7 +211,7 @@ asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask,
 	sigset_t sigmask;
 	struct signalfd_ctx *ctx;
 
-	if (flags & ~SFD_CLOEXEC)
+	if (flags & ~(SFD_CLOEXEC | SFD_NONBLOCK))
 		return -EINVAL;
 
 	if (sizemask != sizeof(sigset_t) ||
@@ -232,7 +232,7 @@ asmlinkage long sys_signalfd4(int ufd, sigset_t __user *user_mask,
 		 * anon_inode_getfd() will install the fd.
 		 */
 		ufd = anon_inode_getfd("[signalfd]", &signalfd_fops, ctx,
-				       flags & O_CLOEXEC);
+				       flags & (O_CLOEXEC | O_NONBLOCK));
 		if (ufd < 0)
 			kfree(ctx);
 	} else {
diff --git a/include/linux/signalfd.h b/include/linux/signalfd.h
index 8b3f7b7..bef0c46 100644
--- a/include/linux/signalfd.h
+++ b/include/linux/signalfd.h
@@ -8,11 +8,12 @@
 #ifndef _LINUX_SIGNALFD_H
 #define _LINUX_SIGNALFD_H
 
-/* For O_CLOEXEC */
+/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
 /* Flags for signalfd4.  */
 #define SFD_CLOEXEC O_CLOEXEC
+#define SFD_NONBLOCK O_NONBLOCK
 
 struct signalfd_siginfo {
 	__u32 ssi_signo;
