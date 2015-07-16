From: Josh Hunt <johunt@akamai.com>
Subject: [RFC] show socket info in fdinfo
Date: Wed, 15 Jul 2015 22:50:19 -0400
Message-ID: <1437015019-311-1-git-send-email-johunt@akamai.com>
Cc: Josh Hunt <johunt@akamai.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:35523 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752861AbbGPCuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 22:50:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sockets are unhashed they are no longer visible through the normal
methods. Provide a way to see all sockets in the system by dumping some
basic socket information in fdinfo.

Signed-off-by: Josh Hunt <johunt@akamai.com>
---

When trying to debug an application issue which wound up not closing sockets
properly we found there was no easy way through existing tools to show sockets
which have been unhashed. In order to get some basic information about all
allocated sockets on the system we'd like to dump this info into fdinfo.

 net/socket.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index 9963a0b..eced913 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -131,6 +131,9 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
+#ifdef CONFIG_PROC_FS
+static void sock_show_fdinfo(struct seq_file *m, struct file *file);
+#endif
 
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
@@ -153,6 +156,9 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo =	sock_show_fdinfo,
+#endif
 };
 
 /*
@@ -777,6 +783,52 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
+#ifdef CONFIG_PROC_FS
+static void sock_show_fdinfo(struct seq_file *m, struct file *file)
+{
+	struct socket *sock = NULL;
+	struct sock *sk = NULL;
+	int err;
+
+	sock = sock_from_file(file, &err);
+	if (sock) {
+		sk = sock->sk;
+		sock_hold(sk);
+		seq_printf(m, "state:\t%d\n"
+				"type:\t0x%x\n"
+				"flags\t%lu\n"
+				"sk_rcvbuf:\t%d\n"
+				"sk_sndbuf:\t%d\n"
+				"sk_forward_alloc:\t%d\n"
+				"sk_rmem_alloc:\t%d\n"
+				"sk_wmem_alloc:\t%d\n"
+				"sk_wmem_queued:\t%d\n"
+				"sk_err:\t%d\n"
+				"sk_state:\t0x%x\n"
+				"sk_flags:\t0x%lx\n"
+				"sk_unhashed:\t%d\n"
+				"sk_protocol:\t0x%x\n"
+				"sk_family:\t0x%x\n",
+				sock->state,
+				sock->type,
+				sock->flags,
+				sk->sk_rcvbuf,
+				sk->sk_sndbuf,
+				sk->sk_forward_alloc,
+				atomic_read(&sk->sk_rmem_alloc),
+				atomic_read(&sk->sk_wmem_alloc),
+				sk->sk_wmem_queued,
+				sk->sk_err,
+				sk->sk_state,
+				sk->sk_flags,
+				sk_unhashed(sk),
+				sk->sk_protocol,
+				sk->sk_family);
+		sock_put(sk);
+	}
+}
+#endif
+
 static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
-- 
1.7.9.5
