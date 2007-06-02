From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH] V2: O_CLOEXEC for SCM_RIGHTS
Date: Sat, 2 Jun 2007 17:48:31 -0400
Message-ID: <200706022148.l52LmVRx023291@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757053AbXFBVsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Jun 2007 17:48:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take two: I forgot to change the compat code.  This has now happened.  Only one
additional line changed.

Everything else from the first patch remains the same.  I try to avoid clogging
the list unnecessarily by not resending the test program.


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
--- a/net/compat.c
+++ b/net/compat.c
@@ -276,7 +276,8 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 		err = security_file_receive(fp[i]);
 		if (err)
 			break;
-		err = get_unused_fd();
+		err = get_unused_fd_flags(MSG_CMSG_CLOEXEC & msg->msg_flags
+					  ? O_CLOEXEC : 0);
 		if (err < 0)
 			break;
 		new_fd = err;
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
