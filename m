From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 14/18] switch sockets to ->read_iter/->write_iter
Date: Sat, 31 Jan 2015 03:56:40 +0000
Message-ID: <1422676604-18533-14-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55008 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758136AbbAaD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:46 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/socket.c | 56 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 27 insertions(+), 29 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 4d08b50..bbedbfc 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -113,10 +113,8 @@ unsigned int sysctl_net_busy_read __read_mostly;
 unsigned int sysctl_net_busy_poll __read_mostly;
 #endif
 
-static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
-			 unsigned long nr_segs, loff_t pos);
-static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
-			  unsigned long nr_segs, loff_t pos);
+static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to);
+static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from);
 static int sock_mmap(struct file *file, struct vm_area_struct *vma);
 
 static int sock_close(struct inode *inode, struct file *file);
@@ -142,8 +140,10 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 static const struct file_operations socket_file_ops = {
 	.owner =	THIS_MODULE,
 	.llseek =	no_llseek,
-	.aio_read =	sock_aio_read,
-	.aio_write =	sock_aio_write,
+	.read =		new_sync_read,
+	.write =	new_sync_write,
+	.read_iter =	sock_read_iter,
+	.write_iter =	sock_write_iter,
 	.poll =		sock_poll,
 	.unlocked_ioctl = sock_ioctl,
 #ifdef CONFIG_COMPAT
@@ -845,49 +845,47 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
-static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
-				unsigned long nr_segs, loff_t pos)
+static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
 	struct socket *sock = file->private_data;
-	struct msghdr msg;
+	struct msghdr msg = {.msg_iter = *to};
+	ssize_t res;
+
+	if (file->f_flags & O_NONBLOCK)
+		msg.msg_flags = MSG_DONTWAIT;
 
-	if (pos != 0)
+	if (iocb->ki_pos != 0)
 		return -ESPIPE;
 
 	if (iocb->ki_nbytes == 0)	/* Match SYS5 behaviour */
 		return 0;
 
-	msg.msg_name = NULL;
-	msg.msg_namelen = 0;
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-	iov_iter_init(&msg.msg_iter, READ, iov, nr_segs, iocb->ki_nbytes);
-	msg.msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
-
-	return __sock_recvmsg(iocb, sock, &msg, iocb->ki_nbytes, msg.msg_flags);
+	res = __sock_recvmsg(iocb, sock, &msg,
+			     iocb->ki_nbytes, msg.msg_flags);
+	*to = msg.msg_iter;
+	return res;
 }
 
-static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
-			  unsigned long nr_segs, loff_t pos)
+static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 {
 	struct file *file = iocb->ki_filp;
 	struct socket *sock = file->private_data;
-	struct msghdr msg;
+	struct msghdr msg = {.msg_iter = *from};
+	ssize_t res;
 
-	if (pos != 0)
+	if (iocb->ki_pos != 0)
 		return -ESPIPE;
 
-	msg.msg_name = NULL;
-	msg.msg_namelen = 0;
-	msg.msg_control = NULL;
-	msg.msg_controllen = 0;
-	iov_iter_init(&msg.msg_iter, WRITE, iov, nr_segs, iocb->ki_nbytes);
-	msg.msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
+	if (file->f_flags & O_NONBLOCK)
+		msg.msg_flags = MSG_DONTWAIT;
+
 	if (sock->type == SOCK_SEQPACKET)
 		msg.msg_flags |= MSG_EOR;
 
-	return __sock_sendmsg(iocb, sock, &msg, iocb->ki_nbytes);
+	res = __sock_sendmsg(iocb, sock, &msg, iocb->ki_nbytes);
+	*from = msg.msg_iter;
+	return res;
 }
 
 /*
-- 
2.1.4
