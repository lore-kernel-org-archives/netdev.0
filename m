From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] O_CLOEXEC for SCM_RIGHTS
Date: Sat, 2 Jun 2007 15:01:20 -0400
Message-ID: <200706021901.l52J1KbW016799@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756896AbXFBTBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2007 15:01:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part two in the O_CLOEXEC saga: adding support for file descriptors received
through Unix domain sockets.

The patch is once again pretty minimal, it introduces a new flag for recvmsg
and passes it just like the existing MSG_CMSG_COMPAT flag.  I think this bit
is not used otherwise but the networking people will know better.

This new flag is not recognized by recvfrom and recv.  These functions cannot
be used for that purpose and the asymmetry this introduces is not worse than
the already existing MSG_CMSG_COMPAT situations.

The patch must be applied on the patch which introduced O_CLOEXEC.  It has to
remove static from the new get_unused_fd_flags function but since scm.c cannot
live in a module the function still hasn't to be exported.

Here's a test program to make sure the code works.  It's so much longer than
the actual patch...

#include <errno.h>
#include <error.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>

#ifndef O_CLOEXEC
# define O_CLOEXEC 02000000
#endif
#ifndef MSG_CMSG_CLOEXEC
# define MSG_CMSG_CLOEXEC 0x40000000
#endif


int
main (int argc, char *argv[])
{
  if (argc > 1)
    {
      int fd = atol (argv[1]);
      printf ("child: fd = %d\n", fd);
      if (fcntl (fd, F_GETFD) == 0 || errno != EBADF)
        {
          puts ("file descriptor valid in child");
          return 1;
        }
      return 0;

    }

  struct sockaddr_un sun;
  strcpy (sun.sun_path, "./testsocket");
  sun.sun_family = AF_UNIX;

  char databuf[] = "hello";
  struct iovec iov[1];
  iov[0].iov_base = databuf;
  iov[0].iov_len = sizeof (databuf);

  union
  {
    struct cmsghdr hdr;
    char bytes[CMSG_SPACE (sizeof (int))];
  } buf;
  struct msghdr msg = { .msg_iov = iov, .msg_iovlen = 1,
                        .msg_control = buf.bytes,
                        .msg_controllen = sizeof (buf) };
  struct cmsghdr *cmsg = CMSG_FIRSTHDR (&msg);

  cmsg->cmsg_level = SOL_SOCKET;
  cmsg->cmsg_type = SCM_RIGHTS;
  cmsg->cmsg_len = CMSG_LEN (sizeof (int));

  msg.msg_controllen = cmsg->cmsg_len;

  pid_t child = fork ();
  if (child == -1)
    error (1, errno, "fork");
  if (child == 0)
    {
      int sock = socket (PF_UNIX, SOCK_STREAM, 0);
      if (sock < 0)
        error (1, errno, "socket");

      if (bind (sock, (struct sockaddr *) &sun, sizeof (sun)) < 0)
        error (1, errno, "bind");
      if (listen (sock, SOMAXCONN) < 0)
        error (1, errno, "listen");

      int conn = accept (sock, NULL, NULL);
      if (conn == -1)
        error (1, errno, "accept");

      *(int *) CMSG_DATA (cmsg) = sock;
      if (sendmsg (conn, &msg, MSG_NOSIGNAL) < 0)
        error (1, errno, "sendmsg");

      return 0;
    }

  /* For a test suite this should be more robust like a
     barrier in shared memory.  */
  sleep (1);
  
  int sock = socket (PF_UNIX, SOCK_STREAM, 0);
  if (sock < 0)
    error (1, errno, "socket");

  if (connect (sock, (struct sockaddr *) &sun, sizeof (sun)) < 0)
    error (1, errno, "connect");
  unlink (sun.sun_path);

  *(int *) CMSG_DATA (cmsg) = -1;

  if (recvmsg (sock, &msg, MSG_CMSG_CLOEXEC) < 0)
    error (1, errno, "recvmsg");

  int fd = *(int *) CMSG_DATA (cmsg);
  if (fd == -1)
    error (1, 0, "no descriptor received");

  char fdname[20];
  snprintf (fdname, sizeof (fdname), "%d", fd);
  execl ("/proc/self/exe", argv[0], fdname, NULL);
  puts ("execl failed");
  return 1;
}



Signed-off-by: Ulrich Drepper <drepper@redhat.com>

--- a/fs/open.c
+++ b/fs/open.c
@@ -855,7 +855,7 @@
 /*
  * Find an empty file descriptor entry, and mark it busy.
  */
-static int get_unused_fd_flags(int flags)
+int get_unused_fd_flags(int flags)
 {
 	struct files_struct * files = current->files;
 	int fd, error;
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -73,6 +73,7 @@ extern struct file * FASTCALL(fget_light(unsigned int fd, int *fput_needed));
 extern void FASTCALL(set_close_on_exec(unsigned int fd, int flag));
 extern void put_filp(struct file *);
 extern int get_unused_fd(void);
+extern int FASTCALL(get_unused_fd_flags(int flags));
 extern void FASTCALL(put_unused_fd(unsigned int fd));
 struct kmem_cache;
 
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -253,6 +253,9 @@ struct ucred {
 
 #define MSG_EOF         MSG_FIN
 
+#define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
+					   descriptor received through
+					   SCM_RIGHTS */
 #if defined(CONFIG_COMPAT)
 #define MSG_CMSG_COMPAT	0x80000000	/* This message needs 32 bit fixups */
 #else
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -228,7 +228,8 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 		err = security_file_receive(fp[i]);
 		if (err)
 			break;
-		err = get_unused_fd();
+		err = get_unused_fd_flags(MSG_CMSG_CLOEXEC & msg->msg_flags
+					  ? O_CLOEXEC : 0);
 		if (err < 0)
 			break;
 		new_fd = err;
--- a/net/socket.c
+++ b/net/socket.c
@@ -1939,9 +1939,7 @@ asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg,
 	total_len = err;
 
 	cmsg_ptr = (unsigned long)msg_sys.msg_control;
-	msg_sys.msg_flags = 0;
-	if (MSG_CMSG_COMPAT & flags)
-		msg_sys.msg_flags = MSG_CMSG_COMPAT;
+	msg_sys.msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
 
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
