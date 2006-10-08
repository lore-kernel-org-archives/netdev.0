From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [PATCH] file descriptor loss while receiving SCM_RIGHTS
Date: Sun, 08 Oct 2006 12:53:11 +0200
Message-ID: <E1GWWHP-0006jw-00@dorka.pomaz.szeredi.hu>
Cc: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2.sa.eol.hu ([212.108.200.109]:48065 "EHLO
	mail-gw2.sa.eol.hu") by vger.kernel.org with ESMTP id S1751071AbWJHKxi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 06:53:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If more than one file descriptor was sent with an SCM_RIGHTS message,
and on the receiving end, after installing a nonzero (but not all)
file descritpors the process runs out of fds, then the already
installed fds will be lost (userspace will have no way of knowing
about them).

The following patch makes sure, that at least the already installed
fds are sent to userspace.  It doesn't solve the issue of losing file
descriptors in case of an EFAULT on the userspace buffer.

Signed-off-by: Miklos Szeredi <miklos@szeredi.hu>

---
Index: linux/net/core/scm.c
===================================================================
--- linux.orig/net/core/scm.c	2006-10-08 12:41:14.000000000 +0200
+++ linux/net/core/scm.c	2006-10-08 12:41:46.000000000 +0200
@@ -245,8 +245,7 @@ void scm_detach_fds(struct msghdr *msg, 
 	if (i > 0)
 	{
 		int cmlen = CMSG_LEN(i*sizeof(int));
-		if (!err)
-			err = put_user(SOL_SOCKET, &cm->cmsg_level);
+		err = put_user(SOL_SOCKET, &cm->cmsg_level);
 		if (!err)
 			err = put_user(SCM_RIGHTS, &cm->cmsg_type);
 		if (!err)
Index: linux/net/compat.c
===================================================================
--- linux.orig/net/compat.c	2006-10-08 12:43:41.000000000 +0200
+++ linux/net/compat.c	2006-10-08 12:43:47.000000000 +0200
@@ -285,8 +285,7 @@ void scm_detach_fds_compat(struct msghdr
 
 	if (i > 0) {
 		int cmlen = CMSG_COMPAT_LEN(i * sizeof(int));
-		if (!err)
-			err = put_user(SOL_SOCKET, &cm->cmsg_level);
+		err = put_user(SOL_SOCKET, &cm->cmsg_level);
 		if (!err)
 			err = put_user(SCM_RIGHTS, &cm->cmsg_type);
 		if (!err)

