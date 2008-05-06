From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 14/18] flag parameters: NONBLOCK in eventfd
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7md004078@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933249AbYEFVTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:19:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the EFD_NONBLOCK flag to eventfd2.  The
additional changes needed are minimal.

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

#define EFD_NONBLOCK O_NONBLOCK

int
main (void)
{
  int fd = syscall (__NR_eventfd2, 1, 0);
  if (fd == -1)
    {
      puts ("eventfd2(0) failed");
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
      puts ("eventfd2(0) sets non-blocking mode");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_eventfd2, 1, EFD_NONBLOCK);
  if (fd == -1)
    {
      puts ("eventfd2(EFD_NONBLOCK) failed");
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
      puts ("eventfd2(EFD_NONBLOCK) does not set non-blocking mode");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/eventfd.c            |    4 ++--
 include/linux/eventfd.h |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/eventfd.c b/fs/eventfd.c
index bd420e6..3ed4466 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -203,7 +203,7 @@ asmlinkage long sys_eventfd2(unsigned int count, int flags)
 	int fd;
 	struct eventfd_ctx *ctx;
 
-	if (flags & ~EFD_CLOEXEC)
+	if (flags & ~(EFD_CLOEXEC | EFD_NONBLOCK))
 		return -EINVAL;
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
@@ -218,7 +218,7 @@ asmlinkage long sys_eventfd2(unsigned int count, int flags)
 	 * anon_inode_getfd() will install the fd.
 	 */
 	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx,
-			      flags & O_CLOEXEC);
+			      flags & (O_CLOEXEC | O_NONBLOCK));
 	if (fd < 0)
 		kfree(ctx);
 	return fd;
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index a6c0eae..a667637 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -10,11 +10,12 @@
 
 #ifdef CONFIG_EVENTFD
 
-/* For O_CLOEXEC */
+/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 
 /* Flags for eventfd2.  */
 #define EFD_CLOEXEC O_CLOEXEC
+#define EFD_NONBLOCK O_NONBLOCK
 
 struct file *eventfd_fget(int fd);
 int eventfd_signal(struct file *file, int n);
