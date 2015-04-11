From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 13/17] net: switch sendto() and recvfrom() to import_single_range()
Date: Sat, 11 Apr 2015 22:18:24 +0100
Message-ID: <1428787108-13650-13-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37882 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932626AbbDKVSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2015 17:18:31 -0400
In-Reply-To: <20150411211742.GJ889@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/socket.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 989b1ae..46f0e1d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1650,18 +1650,14 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
 	struct iovec iov;
 	int fput_needed;
 
-	if (len > INT_MAX)
-		len = INT_MAX;
-	if (unlikely(!access_ok(VERIFY_READ, buff, len)))
-		return -EFAULT;
+	err = import_single_range(WRITE, buff, len, &iov, &msg.msg_iter);
+	if (unlikely(err))
+		return err;
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
 
-	iov.iov_base = buff;
-	iov.iov_len = len;
 	msg.msg_name = NULL;
-	iov_iter_init(&msg.msg_iter, WRITE, &iov, 1, len);
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
 	msg.msg_namelen = 0;
@@ -1675,7 +1671,7 @@ SYSCALL_DEFINE6(sendto, int, fd, void __user *, buff, size_t, len,
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
 	msg.msg_flags = flags;
-	err = sock_sendmsg(sock, &msg, len);
+	err = sock_sendmsg(sock, &msg, iov_iter_count(&msg.msg_iter));
 
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1710,26 +1706,22 @@ SYSCALL_DEFINE6(recvfrom, int, fd, void __user *, ubuf, size_t, size,
 	int err, err2;
 	int fput_needed;
 
-	if (size > INT_MAX)
-		size = INT_MAX;
-	if (unlikely(!access_ok(VERIFY_WRITE, ubuf, size)))
-		return -EFAULT;
+	err = import_single_range(READ, ubuf, size, &iov, &msg.msg_iter);
+	if (unlikely(err))
+		return err;
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		goto out;
 
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
-	iov.iov_len = size;
-	iov.iov_base = ubuf;
-	iov_iter_init(&msg.msg_iter, READ, &iov, 1, size);
 	/* Save some cycles and don't copy the address if not needed */
 	msg.msg_name = addr ? (struct sockaddr *)&address : NULL;
 	/* We assume all kernel code knows the size of sockaddr_storage */
 	msg.msg_namelen = 0;
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |= MSG_DONTWAIT;
-	err = sock_recvmsg(sock, &msg, size, flags);
+	err = sock_recvmsg(sock, &msg, iov_iter_count(&msg.msg_iter), flags);
 
 	if (err >= 0 && addr != NULL) {
 		err2 = move_addr_to_user(&address,
-- 
2.1.4
