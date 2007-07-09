From: akpm@linux-foundation.org
Subject: [patch 1/2] Introduce O_CLOEXEC
Date: Mon, 09 Jul 2007 14:54:53 -0700
Message-ID: <200707092154.l69LssVX014487@imap1.linux-foundation.org>
Cc: akpm@linux-foundation.org, drepper@redhat.com, chris@zankel.net,
	davidel@xmailserver.org, kyle@parisc-linux.org, mingo@elte.hu,
	mtk-manpages@gmx.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49022 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755806AbXGIV42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 17:56:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>

The problem is as follows: in multi-threaded code (or more correctly: all
code using clone() with CLONE_FILES) we have a race when exec'ing.

   thread #1                       thread #2

   fd=open()

                                   fork + exec

  fcntl(fd,F_SETFD,FD_CLOEXEC)

In some applications this can happen frequently.  Take a web browser.  One
thread opens a file and another thread starts, say, an external PDF viewer.
 The result can even be a security issue if that open file descriptor
refers to a sensitive file and the external program can somehow be tricked
into using that descriptor.

Just adding O_CLOEXEC support to open() doesn't solve the whole set of
problems.  There are other ways to create file descriptors (socket,
epoll_create, Unix domain socket transfer, etc).  These can and should be
addressed separately though.  open() is such an easy case that it makes not
much sense putting the fix off.

The test program:

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#ifndef O_CLOEXEC
# define O_CLOEXEC 02000000
#endif

int
main (int argc, char *argv[])
{
  int fd;
  if (argc > 1)
    {
      fd = atol (argv[1]);
      printf ("child: fd = %d\n", fd);
      if (fcntl (fd, F_GETFD) == 0 || errno != EBADF)
        {
          puts ("file descriptor valid in child");
          return 1;
        }
      return 0;
    }

  fd = open ("/proc/self/exe", O_RDONLY | O_CLOEXEC);
  printf ("in parent: new fd = %d\n", fd);
  char buf[20];
  snprintf (buf, sizeof (buf), "%d", fd);
  execl ("/proc/self/exe", argv[0], buf, NULL);
  puts ("execl failed");
  return 1;
}

[kyle@parisc-linux.org: parisc fix]
Signed-off-by: Ulrich Drepper <drepper@redhat.com>
Acked-by: Ingo Molnar <mingo@elte.hu>
Cc: Davide Libenzi <davidel@xmailserver.org>
Cc: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: Chris Zankel <chris@zankel.net>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/open.c                   |   14 +++++++++++---
 include/asm-generic/fcntl.h |    3 +++
 include/asm-parisc/fcntl.h  |   31 ++++++++++++++++---------------
 3 files changed, 30 insertions(+), 18 deletions(-)

diff -puN fs/open.c~introduce-o_cloexec-take-2 fs/open.c
--- a/fs/open.c~introduce-o_cloexec-take-2
+++ a/fs/open.c
@@ -855,7 +855,7 @@ EXPORT_SYMBOL(dentry_open);
 /*
  * Find an empty file descriptor entry, and mark it busy.
  */
-int get_unused_fd(void)
+static int get_unused_fd_flags(int flags)
 {
 	struct files_struct * files = current->files;
 	int fd, error;
@@ -891,7 +891,10 @@ repeat:
 	}
 
 	FD_SET(fd, fdt->open_fds);
-	FD_CLR(fd, fdt->close_on_exec);
+	if (flags & O_CLOEXEC)
+		FD_SET(fd, fdt->close_on_exec);
+	else
+		FD_CLR(fd, fdt->close_on_exec);
 	files->next_fd = fd + 1;
 #if 1
 	/* Sanity check */
@@ -907,6 +910,11 @@ out:
 	return error;
 }
 
+int get_unused_fd(void)
+{
+	return get_unused_fd_flags(0);
+}
+
 EXPORT_SYMBOL(get_unused_fd);
 
 static void __put_unused_fd(struct files_struct *files, unsigned int fd)
@@ -959,7 +967,7 @@ long do_sys_open(int dfd, const char __u
 	int fd = PTR_ERR(tmp);
 
 	if (!IS_ERR(tmp)) {
-		fd = get_unused_fd();
+		fd = get_unused_fd_flags(flags);
 		if (fd >= 0) {
 			struct file *f = do_filp_open(dfd, tmp, flags, mode);
 			if (IS_ERR(f)) {
diff -puN include/asm-generic/fcntl.h~introduce-o_cloexec-take-2 include/asm-generic/fcntl.h
--- a/include/asm-generic/fcntl.h~introduce-o_cloexec-take-2
+++ a/include/asm-generic/fcntl.h
@@ -48,6 +48,9 @@
 #ifndef O_NOATIME
 #define O_NOATIME	01000000
 #endif
+#ifndef O_CLOEXEC
+#define O_CLOEXEC	02000000	/* set close_on_exec */
+#endif
 #ifndef O_NDELAY
 #define O_NDELAY	O_NONBLOCK
 #endif
diff -puN include/asm-parisc/fcntl.h~introduce-o_cloexec-take-2 include/asm-parisc/fcntl.h
--- a/include/asm-parisc/fcntl.h~introduce-o_cloexec-take-2
+++ a/include/asm-parisc/fcntl.h
@@ -3,21 +3,22 @@
 
 /* open/fcntl - O_SYNC is only implemented on blocks devices and on files
    located on an ext2 file system */
-#define O_APPEND	00000010
-#define O_BLKSEEK	00000100 /* HPUX only */
-#define O_CREAT		00000400 /* not fcntl */
-#define O_EXCL		00002000 /* not fcntl */
-#define O_LARGEFILE	00004000
-#define O_SYNC		00100000
-#define O_NONBLOCK	00200004 /* HPUX has separate NDELAY & NONBLOCK */
-#define O_NOCTTY	00400000 /* not fcntl */
-#define O_DSYNC		01000000 /* HPUX only */
-#define O_RSYNC		02000000 /* HPUX only */
-#define O_NOATIME	04000000
-
-#define O_DIRECTORY	00010000 /* must be a directory */
-#define O_NOFOLLOW	00000200 /* don't follow links */
-#define O_INVISIBLE	04000000 /* invisible I/O, for DMAPI/XDSM */
+#define O_APPEND	000000010
+#define O_BLKSEEK	000000100 /* HPUX only */
+#define O_CREAT		000000400 /* not fcntl */
+#define O_EXCL		000002000 /* not fcntl */
+#define O_LARGEFILE	000004000
+#define O_SYNC		000100000
+#define O_NONBLOCK	000200004 /* HPUX has separate NDELAY & NONBLOCK */
+#define O_NOCTTY	000400000 /* not fcntl */
+#define O_DSYNC		001000000 /* HPUX only */
+#define O_RSYNC		002000000 /* HPUX only */
+#define O_NOATIME	004000000
+#define O_CLOEXEC	010000000 /* set close_on_exec */
+
+#define O_DIRECTORY	000010000 /* must be a directory */
+#define O_NOFOLLOW	000000200 /* don't follow links */
+#define O_INVISIBLE	004000000 /* invisible I/O, for DMAPI/XDSM */
 
 #define F_GETLK64	8
 #define F_SETLK64	9
_
