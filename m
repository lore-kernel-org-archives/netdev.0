From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 15/18] flag parameters: NONBLOCK in eventfd
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gk7s029856@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52497 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222AbYEEDnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:43:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the EFD_NONBLOCK flag to eventfd2.  The
additional changes needed are minimal thanks to the previous preparation.

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

#define EFD_NONBLOCK (1 << 1)

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

 fs/eventfd.c            |    1 +
 include/linux/eventfd.h |    1 +
 2 files changed, 2 insertions(+)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/eventfd.c b/fs/eventfd.c
index 343942d..ddb543d 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -201,6 +201,7 @@ struct file *eventfd_fget(int fd)
 
 static const struct flags_rmap eventfd_file_flags_remap[] = {
 	{ EFD_CLOEXEC, O_CLOEXEC },
+	{ EFD_NONBLOCK, O_NONBLOCK }
 };
 
 asmlinkage long sys_eventfd2(unsigned int count, int flags)
diff --git a/include/linux/eventfd.h b/include/linux/eventfd.h
index a701399..0c2f68b 100644
--- a/include/linux/eventfd.h
+++ b/include/linux/eventfd.h
@@ -12,6 +12,7 @@
 
 /* Flags for eventfd2.  */
 #define EFD_CLOEXEC (1 << 0)
+#define EFD_NONBLOCK (1 << 1)
 
 struct file *eventfd_fget(int fd);
 int eventfd_signal(struct file *file, int n);
