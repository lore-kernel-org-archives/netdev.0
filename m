From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: [PATCH v2 net-next 1/4] net: socket: add support for async operations
Date: Mon, 16 Mar 2015 09:15:14 -0700
Message-ID: <20150316161514.16418.67336.stgit@tstruk-mobl1>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61486 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965272AbbCPQRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 12:17:50 -0400
In-Reply-To: <20150316161508.16418.23674.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for async operations.

Signed-off-by: Tadeusz Struk <tadeusz.struk@intel.com>
---
 include/linux/net.h |    5 ++++
 net/socket.c        |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index e74114b..e9180bf 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -25,6 +25,7 @@
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
 #include <linux/jump_label.h>
+#include <linux/aio.h>
 #include <uapi/linux/net.h>
 
 struct poll_table_struct;
@@ -173,6 +174,10 @@ struct proto_ops {
 	 */
 	int		(*recvmsg)   (struct socket *sock, struct msghdr *m,
 				      size_t total_len, int flags);
+	int		(*aio_sendmsg)(struct kiocb *iocb, struct socket *sock,
+				       struct msghdr *m);
+	int		(*aio_recvmsg)(struct kiocb *iocb, struct socket *sock,
+				       struct msghdr *m, int flags);
 	int		(*mmap)	     (struct file *file, struct socket *sock,
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
diff --git a/net/socket.c b/net/socket.c
index 95d3085..1364dfb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -132,6 +132,11 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
 
+static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
+			     unsigned long nr_segs, loff_t loff);
+static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
+			      unsigned long nr_segs, loff_t loff);
+
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
  *	in the operation structures but are done directly via the socketcall() multiplexor.
@@ -144,6 +149,8 @@ static const struct file_operations socket_file_ops = {
 	.write =	new_sync_write,
 	.read_iter =	sock_read_iter,
 	.write_iter =	sock_write_iter,
+	.aio_read =	sock_aio_read,
+	.aio_write =	sock_aio_write,
 	.poll =		sock_poll,
 	.unlocked_ioctl = sock_ioctl,
 #ifdef CONFIG_COMPAT
@@ -836,6 +843,62 @@ static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from)
 	return res;
 }
 
+static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
+			     unsigned long nr_segs, loff_t loff)
+{
+	struct file *file = iocb->ki_filp;
+	struct socket *sock = file->private_data;
+	struct iov_iter iter;
+	struct msghdr msg = {0};
+	ssize_t res;
+
+	if (file->f_flags & O_NONBLOCK)
+		msg.msg_flags = MSG_DONTWAIT;
+
+	if (iocb->ki_pos != 0)
+		return -ESPIPE;
+
+	if (iocb->ki_nbytes == 0)
+		return 0;
+
+	if (sock->ops->aio_recvmsg) {
+		iov_iter_init(&iter, READ, iov, nr_segs, iocb->ki_nbytes);
+		msg.msg_iter = iter;
+		res = sock->ops->aio_recvmsg(iocb, sock, &msg, msg.msg_flags);
+	} else {
+		res = -EOPNOTSUPP;
+	}
+	return res;
+}
+
+static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
+			      unsigned long nr_segs, loff_t loff)
+{
+	struct file *file = iocb->ki_filp;
+	struct socket *sock = file->private_data;
+	struct iov_iter iter;
+	struct msghdr msg = {0};
+	ssize_t res;
+
+	if (iocb->ki_pos != 0)
+		return -ESPIPE;
+
+	if (file->f_flags & O_NONBLOCK)
+		msg.msg_flags = MSG_DONTWAIT;
+
+	if (sock->type == SOCK_SEQPACKET)
+		msg.msg_flags |= MSG_EOR;
+
+	if (sock->ops->aio_sendmsg) {
+		iov_iter_init(&iter, WRITE, iov, nr_segs, iocb->ki_nbytes);
+		msg.msg_iter = iter;
+		res = sock->ops->aio_sendmsg(iocb, sock, &msg);
+	} else {
+		res = -EOPNOTSUPP;
+	}
+	return res;
+}
+
 /*
  * Atomic setting of ioctl hooks to avoid race
  * with module unload.
