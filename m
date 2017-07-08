From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] get_compat_msghdr(): get rid of field-by-field copyin
Date: Sat, 8 Jul 2017 19:21:00 +0100
Message-ID: <20170708182100.GR10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54776 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752843AbdGHSVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 14:21:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 3 commits in vfs.git#misc.compat I hadn't pushed to Linus yet;
they touch net/* and I'd like to see at least "no objections" from networking
folks before asking to pull that; all of those are about getting rid of
field-by-field copyin.  Please, review and comment.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/compat.c b/net/compat.c
index aba929e5250f..dba5e222a0e5 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -37,21 +37,16 @@ int get_compat_msghdr(struct msghdr *kmsg,
 		      struct sockaddr __user **save_addr,
 		      struct iovec **iov)
 {
-	compat_uptr_t uaddr, uiov, tmp3;
-	compat_size_t nr_segs;
+	struct compat_msghdr msg;
 	ssize_t err;
 
-	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
-	    __get_user(uaddr, &umsg->msg_name) ||
-	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
-	    __get_user(uiov, &umsg->msg_iov) ||
-	    __get_user(nr_segs, &umsg->msg_iovlen) ||
-	    __get_user(tmp3, &umsg->msg_control) ||
-	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
-	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
+	if (copy_from_user(&msg, umsg, sizeof(*umsg)))
 		return -EFAULT;
 
-	if (!uaddr)
+	kmsg->msg_flags = msg.msg_flags;
+	kmsg->msg_namelen = msg.msg_namelen;
+
+	if (!msg.msg_name)
 		kmsg->msg_namelen = 0;
 
 	if (kmsg->msg_namelen < 0)
@@ -59,14 +54,16 @@ int get_compat_msghdr(struct msghdr *kmsg,
 
 	if (kmsg->msg_namelen > sizeof(struct sockaddr_storage))
 		kmsg->msg_namelen = sizeof(struct sockaddr_storage);
-	kmsg->msg_control = compat_ptr(tmp3);
+
+	kmsg->msg_control = compat_ptr(msg.msg_control);
+	kmsg->msg_controllen = msg.msg_controllen;
 
 	if (save_addr)
-		*save_addr = compat_ptr(uaddr);
+		*save_addr = compat_ptr(msg.msg_name);
 
-	if (uaddr && kmsg->msg_namelen) {
+	if (msg.msg_name && kmsg->msg_namelen) {
 		if (!save_addr) {
-			err = move_addr_to_kernel(compat_ptr(uaddr),
+			err = move_addr_to_kernel(compat_ptr(msg.msg_name),
 						  kmsg->msg_namelen,
 						  kmsg->msg_name);
 			if (err < 0)
@@ -77,13 +74,13 @@ int get_compat_msghdr(struct msghdr *kmsg,
 		kmsg->msg_namelen = 0;
 	}
 
-	if (nr_segs > UIO_MAXIOV)
+	if (msg.msg_iovlen > UIO_MAXIOV)
 		return -EMSGSIZE;
 
 	kmsg->msg_iocb = NULL;
 
 	return compat_import_iovec(save_addr ? READ : WRITE,
-				   compat_ptr(uiov), nr_segs,
+				   compat_ptr(msg.msg_iov), msg.msg_iovlen,
 				   UIO_FASTIOV, iov, &kmsg->msg_iter);
 }
 
