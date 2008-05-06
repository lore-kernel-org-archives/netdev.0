From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 17/18] flag parameters: NONBLOCK in inotify_init
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7Ac004093@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932741AbYEFVSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds non-blocking support for inotify_init1.  The
additional changes needed are minimal.

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

#define IN_NONBLOCK O_NONBLOCK

int
main (void)
{
  int fd = syscall (__NR_inotify_init1, 0);
  if (fd == -1)
    {
      puts ("inotify_init1(0) failed");
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
      puts ("inotify_init1(0) set non-blocking mode");
      return 1;
    }
  close (fd);

  fd = syscall (__NR_inotify_init1, IN_NONBLOCK);
  if (fd == -1)
    {
      puts ("inotify_init1(IN_NONBLOCK) failed");
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
      puts ("inotify_init1(IN_NONBLOCK) set non-blocking mode");
      return 1;
    }
  close (fd);

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/inotify_user.c       |    4 ++--
 include/linux/inotify.h |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/inotify_user.c b/fs/inotify_user.c
index 8510059..dc7e1f6 100644
--- a/fs/inotify_user.c
+++ b/fs/inotify_user.c
@@ -574,7 +574,7 @@ asmlinkage long sys_inotify_init1(int flags)
 	struct file *filp;
 	int fd, ret;
 
-	if (flags & ~IN_CLOEXEC)
+	if (flags & ~(IN_CLOEXEC | IN_NONBLOCK))
 		return -EINVAL;
 
 	fd = get_unused_fd_flags(flags & O_CLOEXEC);
@@ -613,7 +613,7 @@ asmlinkage long sys_inotify_init1(int flags)
 	filp->f_path.dentry = dget(inotify_mnt->mnt_root);
 	filp->f_mapping = filp->f_path.dentry->d_inode->i_mapping;
 	filp->f_mode = FMODE_READ;
-	filp->f_flags = O_RDONLY;
+	filp->f_flags = O_RDONLY | (flags & O_NONBLOCK);
 	filp->private_data = dev;
 
 	INIT_LIST_HEAD(&dev->events);
diff --git a/include/linux/inotify.h b/include/linux/inotify.h
index 72ef821..bd57857 100644
--- a/include/linux/inotify.h
+++ b/include/linux/inotify.h
@@ -7,7 +7,7 @@
 #ifndef _LINUX_INOTIFY_H
 #define _LINUX_INOTIFY_H
 
-/* For O_CLOEXEC */
+/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/fcntl.h>
 #include <linux/types.h>
 
@@ -67,6 +67,7 @@ struct inotify_event {
 
 /* Flags for sys_inotify_init1.  */
 #define IN_CLOEXEC O_CLOEXEC
+#define IN_NONBLOCK O_NONBLOCK
 
 #ifdef __KERNEL__
 
