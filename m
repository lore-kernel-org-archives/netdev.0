From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] socket: use ki_nbytes instead of iov_length()
Date: Fri, 16 Jan 2015 14:35:09 +0100
Message-ID: <1421415309-4639-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20150115214519.GB29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:50668 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbbAPNfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:35:30 -0500
In-Reply-To: <20150115214519.GB29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This field already contains the length of the iovec, no need to calculate it
again.

Suggested-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/socket.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index e1278d7e1d5d..9fcf15b61009 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -882,16 +882,15 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
 		unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
-	size_t size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	iov_iter_init(&msg->msg_iter, READ, iov, nr_segs, size);
+	iov_iter_init(&msg->msg_iter, READ, iov, nr_segs, iocb->ki_nbytes);
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 
-	return __sock_recvmsg(iocb, sock, msg, size, msg->msg_flags);
+	return __sock_recvmsg(iocb, sock, msg, iocb->ki_nbytes, msg->msg_flags);
 }
 
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -917,18 +916,17 @@ static ssize_t do_sock_write(struct msghdr *msg, struct kiocb *iocb,
 			unsigned long nr_segs)
 {
 	struct socket *sock = file->private_data;
-	size_t size = iov_length(iov, nr_segs);
 
 	msg->msg_name = NULL;
 	msg->msg_namelen = 0;
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
-	iov_iter_init(&msg->msg_iter, WRITE, iov, nr_segs, size);
+	iov_iter_init(&msg->msg_iter, WRITE, iov, nr_segs, iocb->ki_nbytes);
 	msg->msg_flags = (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
 	if (sock->type == SOCK_SEQPACKET)
 		msg->msg_flags |= MSG_EOR;
 
-	return __sock_sendmsg(iocb, sock, msg, size);
+	return __sock_sendmsg(iocb, sock, msg, iocb->ki_nbytes);
 }
 
 static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
-- 
2.2.2
