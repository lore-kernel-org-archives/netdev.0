From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [RFC] copy_msghdr_from_user(): get rid of field-by-field copyin
Date: Sat, 8 Jul 2017 19:22:08 +0100
Message-ID: <20170708182207.GS10672@ZenIV.linux.org.uk>
References: <20170708182100.GR10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54790 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752861AbdGHSWJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2017 14:22:09 -0400
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.87 #1 (Red Hat Linux))
        id 1dTuMq-0002rI-21
        for netdev@vger.kernel.org; Sat, 08 Jul 2017 18:22:08 +0000
Content-Disposition: inline
In-Reply-To: <20170708182100.GR10672@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/socket.c b/net/socket.c
index c2564eb25c6b..af33d929135a 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1870,22 +1870,18 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 				 struct sockaddr __user **save_addr,
 				 struct iovec **iov)
 {
-	struct sockaddr __user *uaddr;
-	struct iovec __user *uiov;
-	size_t nr_segs;
+	struct user_msghdr msg;
 	ssize_t err;
 
-	if (!access_ok(VERIFY_READ, umsg, sizeof(*umsg)) ||
-	    __get_user(uaddr, &umsg->msg_name) ||
-	    __get_user(kmsg->msg_namelen, &umsg->msg_namelen) ||
-	    __get_user(uiov, &umsg->msg_iov) ||
-	    __get_user(nr_segs, &umsg->msg_iovlen) ||
-	    __get_user(kmsg->msg_control, &umsg->msg_control) ||
-	    __get_user(kmsg->msg_controllen, &umsg->msg_controllen) ||
-	    __get_user(kmsg->msg_flags, &umsg->msg_flags))
+	if (copy_from_user(&msg, umsg, sizeof(*umsg)))
 		return -EFAULT;
 
-	if (!uaddr)
+	kmsg->msg_control = msg.msg_control;
+	kmsg->msg_controllen = msg.msg_controllen;
+	kmsg->msg_flags = msg.msg_flags;
+
+	kmsg->msg_namelen = msg.msg_namelen;
+	if (!msg.msg_name)
 		kmsg->msg_namelen = 0;
 
 	if (kmsg->msg_namelen < 0)
@@ -1895,11 +1891,11 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 		kmsg->msg_namelen = sizeof(struct sockaddr_storage);
 
 	if (save_addr)
-		*save_addr = uaddr;
+		*save_addr = msg.msg_name;
 
-	if (uaddr && kmsg->msg_namelen) {
+	if (msg.msg_name && kmsg->msg_namelen) {
 		if (!save_addr) {
-			err = move_addr_to_kernel(uaddr, kmsg->msg_namelen,
+			err = move_addr_to_kernel(msg.msg_name, kmsg->msg_namelen,
 						  kmsg->msg_name);
 			if (err < 0)
 				return err;
@@ -1909,12 +1905,13 @@ static int copy_msghdr_from_user(struct msghdr *kmsg,
 		kmsg->msg_namelen = 0;
 	}
 
-	if (nr_segs > UIO_MAXIOV)
+	if (msg.msg_iovlen > UIO_MAXIOV)
 		return -EMSGSIZE;
 
 	kmsg->msg_iocb = NULL;
 
-	return import_iovec(save_addr ? READ : WRITE, uiov, nr_segs,
+	return import_iovec(save_addr ? READ : WRITE,
+			    msg.msg_iov, msg.msg_iovlen,
 			    UIO_FASTIOV, iov, &kmsg->msg_iter);
 }
 
