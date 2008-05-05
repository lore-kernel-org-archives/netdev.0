From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 18/18] flag parameters: NONBLOCK in inotify_init
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gkjH029865@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767AbYEEDm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds non-blocking support for inotify_init1.  The
additional changes needed are minimal thanks to the previous preparation.

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

#define IN_NONBLOCK (1 << 1)

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

 fs/inotify_user.c       |    3 ++-
 include/linux/inotify.h |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/inotify_user.c b/fs/inotify_user.c
index 6676c06..4bb4c54 100644
--- a/fs/inotify_user.c
+++ b/fs/inotify_user.c
@@ -569,6 +569,7 @@ static const struct inotify_operations inotify_user_ops = {
 
 static const struct flags_rmap inotify_file_flags_remap[] = {
         { IN_CLOEXEC, O_CLOEXEC },
+        { IN_NONBLOCK, O_NONBLOCK }
 };
 
 asmlinkage long sys_inotify_init1(int flags)
@@ -621,7 +622,7 @@ asmlinkage long sys_inotify_init(void)
 	filp->f_path.dentry = dget(inotify_mnt->mnt_root);
 	filp->f_mapping = filp->f_path.dentry->d_inode->i_mapping;
 	filp->f_mode = FMODE_READ;
-	filp->f_flags = O_RDONLY;
+	filp->f_flags = O_RDONLY | (fflags & O_NONBLOCK);
 	filp->private_data = dev;
 
 	INIT_LIST_HEAD(&dev->events);
diff --git a/include/linux/inotify.h b/include/linux/inotify.h
index 742b917..af30cfd 100644
--- a/include/linux/inotify.h
+++ b/include/linux/inotify.h
@@ -65,6 +65,7 @@ struct inotify_event {
 
 /* Flags for sys_inotify_init1.  */
 #define IN_CLOEXEC (1 << 0)
+#define IN_NONBLOCK (1 << 1)
 
 #ifdef __KERNEL__
 
