From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 13/18] net/socket.c: fold do_sock_{read,write} into callers
Date: Mon,  2 Feb 2015 07:59:32 +0000
Message-ID: <1422863977-17668-13-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:32975 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932852AbbBBH7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 02:59:39 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/socket.c | 56 +++++++++++++++++++++-----------------------------------
 1 file changed, 21 insertions(+), 35 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 3326d67..4d08b50 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -845,25 +845,11 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
-static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
-		struct file *file, const struct iovec *iov,
-		unsigned long nr_segs)
-{
-	struct socket *sock = file->private_data;
-
-	msg->msg_name = NULL;
-	msg->msg_namelen = 0;
-	msg->msg_control = NULL;
-	msg->msg_controllen = 0;
-	iov_iter_init(&msg->msg_iter, READ, iov, nr_segs, iocb->ki_nbytes);
-	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
-
-	return __sock_recvmsg(iocb, sock, msg, iocb->ki_nbytes, msg->msg_flags);
-}
-
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 				unsigned long nr_segs, loff_t pos)
 {
+	struct file *file = iocb->ki_filp;
+	struct socket *sock = file->private_data;
 	struct msghdr msg;
 
 	if (pos != 0)
@@ -872,36 +858,36 @@ static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
 		return 0;
 
-	return do_sock_read(&msg, iocb, iocb->ki_filp, iov, nr_segs);
-}
-
-static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
-			struct file *file, const struct iovec *iov,
-			unsigned long nr_segs)
-{
-	struct socket *sock = file->private_data;
-
-	msg->msg_name = NULL;
-	msg->msg_namelen = 0;
-	msg->msg_control = NULL;
-	msg->msg_controllen = 0;
-	iov_iter_init(&msg->msg_iter, WRITE, iov, nr_segs, iocb->ki_nbytes);
-	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
-	if (sock->type == SOCK_SEQPACKET)
-		msg->msg_flags |= MSG_EOR;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	iov_iter_init(&msg.msg_iter, READ, iov, nr_segs, iocb->ki_nbytes);
+	msg.msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
-	return __sock_sendmsg(iocb, sock, msg, iocb->ki_nbytes);
+	return __sock_recvmsg(iocb, sock, &msg, iocb->ki_nbytes, msg.msg_flags);
 }
 
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 			  unsigned long nr_segs, loff_t pos)
 {
+	struct file *file = iocb->ki_filp;
+	struct socket *sock = file->private_data;
 	struct msghdr msg;
 
 	if (pos != 0)
 		return -ESPIPE;
 
-	return do_sock_write(&msg, iocb, iocb->ki_filp, iov, nr_segs);
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = NULL;
+	msg.msg_controllen = 0;
+	iov_iter_init(&msg.msg_iter, WRITE, iov, nr_segs, iocb->ki_nbytes);
+	msg.msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
+	if (sock->type == SOCK_SEQPACKET)
+		msg.msg_flags |= MSG_EOR;
+
+	return __sock_sendmsg(iocb, sock, &msg, iocb->ki_nbytes);
 }
 
 /*
-- 
2.1.4
