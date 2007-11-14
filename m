From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Use sockfd_lookup_light in the rest of the net/socket.c
Date: Wed, 14 Nov 2007 19:42:18 +0300
Message-ID: <473B256A.8080104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:37679 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757062AbXKNQme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 11:42:34 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some time ago a sockfd_lookup_light was introduced and
most of the socket.c file was patched to use it. However
two routines were left - sys_sendto and sys_recvfrom.

Patch them as well, since this helper does exactly what
these two need.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/socket.c b/net/socket.c
index 74784df..f8ec651 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1581,16 +1581,11 @@ asmlinkage long sys_sendto(int fd, void __user *buff, size_t len,
 	struct msghdr msg;
 	struct iovec iov;
 	int fput_needed;
-	struct file *sock_file;
 
-	sock_file = fget_light(fd, &fput_needed);
-	err = -EBADF;
-	if (!sock_file)
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
+	if (!sock)
 		goto out;
 
-	sock = sock_from_file(sock_file, &err);
-	if (!sock)
-		goto out_put;
 	iov.iov_base = buff;
 	iov.iov_len = len;
 	msg.msg_name = NULL;
@@ -1612,7 +1607,7 @@ asmlinkage long sys_sendto(int fd, void __user *buff, size_t len,
 	err = sock_sendmsg(sock, &msg, len);
 
 out_put:
-	fput_light(sock_file, fput_needed);
+	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
@@ -1641,17 +1636,11 @@ asmlinkage long sys_recvfrom(int fd, void __user *ubuf, size_t size,
 	struct msghdr msg;
 	char address[MAX_SOCK_ADDR];
 	int err, err2;
-	struct file *sock_file;
 	int fput_needed;
 
-	sock_file = fget_light(fd, &fput_needed);
-	err = -EBADF;
-	if (!sock_file)
-		goto out;
-
-	sock = sock_from_file(sock_file, &err);
+	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
-		goto out_put;
+		goto out;
 
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
@@ -1670,8 +1659,8 @@ asmlinkage long sys_recvfrom(int fd, void __user *ubuf, size_t size,
 		if (err2 < 0)
 			err = err2;
 	}
-out_put:
-	fput_light(sock_file, fput_needed);
+
+	fput_light(sock->file, fput_needed);
 out:
 	return err;
 }
