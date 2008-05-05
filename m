From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 17/18] flag parameters: NONBLOCK in pipe
Date: Sun, 4 May 2008 23:42:46 -0400
Message-ID: <200805050342.m453gks2029862@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752AbYEEDm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2008 23:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds O_NONBLOCK support to pipe2.  It is minimally more involved
that the patches for eventfd et.al but still trivial.  The interfaces of the
create_write_pipe and create_read_pipe helper functions were changed and the
one other caller as well.

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
  int fds[2];
  if (syscall (__NR_pipe2, fds, 0) == -1)
    {
      puts ("pipe2(0) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      int fl = fcntl (fds[i], F_GETFL);
      if (fl == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if (fl & O_NONBLOCK)
        {
          printf ("pipe2(0) set non-blocking mode for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  if (syscall (__NR_pipe2, fds, O_NONBLOCK) == -1)
    {
      puts ("pipe2(O_NONBLOCK) failed");
      return 1;
    }
  for (int i = 0; i < 2; ++i)
    {
      int fl = fcntl (fds[i], F_GETFL);
      if (fl == -1)
        {
          puts ("fcntl failed");
          return 1;
        }
      if ((fl & O_NONBLOCK) == 0)
        {
          printf ("pipe2(O_NONBLOCK) does not set non-blocking mode for fds[%d]\n", i);
          return 1;
        }
      close (fds[i]);
    }

  puts ("OK");

  return 0;
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 fs/pipe.c          |   14 +++++++-------
 include/linux/fs.h |    4 ++--
 kernel/kmod.c      |    4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/pipe.c b/fs/pipe.c
index 3499f9f..796c0a0 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -949,7 +949,7 @@ fail_inode:
 	return NULL;
 }
 
-struct file *create_write_pipe(void)
+struct file *create_write_pipe(int flags)
 {
 	int err;
 	struct inode *inode;
@@ -982,7 +982,7 @@ struct file *create_write_pipe(void)
 		goto err_dentry;
 	f->f_mapping = inode->i_mapping;
 
-	f->f_flags = O_WRONLY;
+	f->f_flags = O_WRONLY | (flags & O_NONBLOCK);
 	f->f_version = 0;
 
 	return f;
@@ -1007,7 +1007,7 @@ void free_write_pipe(struct file *f)
 	put_filp(f);
 }
 
-struct file *create_read_pipe(struct file *wrf)
+struct file *create_read_pipe(struct file *wrf, int flags)
 {
 	struct file *f = get_empty_filp();
 	if (!f)
@@ -1019,7 +1019,7 @@ struct file *create_read_pipe(struct file *wrf)
 	f->f_mapping = wrf->f_path.dentry->d_inode->i_mapping;
 
 	f->f_pos = 0;
-	f->f_flags = O_RDONLY;
+	f->f_flags = O_RDONLY | (flags & O_NONBLOCK);
 	f->f_op = &read_pipe_fops;
 	f->f_mode = FMODE_READ;
 	f->f_version = 0;
@@ -1033,13 +1033,13 @@ struct file *create_read_pipe(struct file *wrf)
 	int error;
 	int fdw, fdr;
 
-	if (flags & ~O_CLOEXEC)
+	if (flags & ~(O_CLOEXEC | O_NONBLOCK))
 		return -EINVAL;
 
-	fw = create_write_pipe();
+	fw = create_write_pipe(flags);
 	if (IS_ERR(fw))
 		return PTR_ERR(fw);
-	fr = create_read_pipe(fw);
+	fr = create_read_pipe(fw, flags);
 	error = PTR_ERR(fr);
 	if (IS_ERR(fr))
 		goto err_write_pipe;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a1ba005..3694eeb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1776,8 +1776,8 @@ static inline void allow_write_access(struct file *file)
 }
 extern int do_pipe(int *);
 extern int do_pipe_flags(int *, int);
-extern struct file *create_read_pipe(struct file *f);
-extern struct file *create_write_pipe(void);
+extern struct file *create_read_pipe(struct file *f, int flags);
+extern struct file *create_write_pipe(int flags);
 extern void free_write_pipe(struct file *);
 
 extern struct file *do_filp_open(int dfd, const char *pathname,
diff --git a/kernel/kmod.c b/kernel/kmod.c
index 8df97d3..7356146 100644
--- a/kernel/kmod.c
+++ b/kernel/kmod.c
@@ -417,12 +417,12 @@ int call_usermodehelper_stdinpipe(struct subprocess_info *sub_info,
 {
 	struct file *f;
 
-	f = create_write_pipe();
+	f = create_write_pipe(0);
 	if (IS_ERR(f))
 		return PTR_ERR(f);
 	*filp = f;
 
-	f = create_read_pipe(f);
+	f = create_read_pipe(f, 0);
 	if (IS_ERR(f)) {
 		free_write_pipe(*filp);
 		return PTR_ERR(f);
