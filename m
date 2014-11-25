From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 06/17] switch macvtap to ->read_iter()
Date: Tue, 25 Nov 2014 14:02:20 +0000
Message-ID: <1416924151-28698-6-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/macvtap.c |   61 ++++++++++++++++++++++---------------------------
 1 file changed, 27 insertions(+), 34 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 42a80d3..8f80045 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -831,64 +831,55 @@ done:
 }
 
 static ssize_t macvtap_do_read(struct macvtap_queue *q,
-			       const struct iovec *iv, unsigned long segs,
-			       unsigned long len,
+			       struct iov_iter *to,
 			       int noblock)
 {
 	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 	ssize_t ret = 0;
-	struct iov_iter iter;
 
-	while (len) {
+	if (!iov_iter_count(to))
+		return 0;
+
+	while (1) {
 		if (!noblock)
 			prepare_to_wait(sk_sleep(&q->sk), &wait,
 					TASK_INTERRUPTIBLE);
 
 		/* Read frames from the queue */
 		skb = skb_dequeue(&q->sk.sk_receive_queue);
-		if (!skb) {
-			if (noblock) {
-				ret = -EAGAIN;
-				break;
-			}
-			if (signal_pending(current)) {
-				ret = -ERESTARTSYS;
-				break;
-			}
-			/* Nothing to read, let's sleep */
-			schedule();
-			continue;
+		if (skb)
+			break;
+		if (noblock) {
+			ret = -EAGAIN;
+			break;
 		}
-		iov_iter_init(&iter, READ, iv, segs, len);
-		ret = macvtap_put_user(q, skb, &iter);
+		if (signal_pending(current)) {
+			ret = -ERESTARTSYS;
+			break;
+		}
+		/* Nothing to read, let's sleep */
+		schedule();
+	}
+	if (skb) {
+		ret = macvtap_put_user(q, skb, to);
 		kfree_skb(skb);
-		break;
 	}
-
 	if (!noblock)
 		finish_wait(sk_sleep(&q->sk), &wait);
 	return ret;
 }
 
-static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
-				unsigned long count, loff_t pos)
+static ssize_t macvtap_read_iter(struct kiocb *iocb, struct iov_iter *to)
 {
 	struct file *file = iocb->ki_filp;
 	struct macvtap_queue *q = file->private_data;
-	ssize_t len, ret = 0;
+	ssize_t len = iov_iter_count(to), ret;
 
-	len = iov_length(iv, count);
-	if (len < 0) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	ret = macvtap_do_read(q, iv, count, len, file->f_flags & O_NONBLOCK);
+	ret = macvtap_do_read(q, to, file->f_flags & O_NONBLOCK);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
-out:
 	return ret;
 }
 
@@ -1089,7 +1080,8 @@ static const struct file_operations macvtap_fops = {
 	.owner		= THIS_MODULE,
 	.open		= macvtap_open,
 	.release	= macvtap_release,
-	.aio_read	= macvtap_aio_read,
+	.read		= new_sync_read,
+	.read_iter	= macvtap_read_iter,
 	.aio_write	= macvtap_aio_write,
 	.poll		= macvtap_poll,
 	.llseek		= no_llseek,
@@ -1112,11 +1104,12 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
 			   int flags)
 {
 	struct macvtap_queue *q = container_of(sock, struct macvtap_queue, sock);
+	struct iov_iter to;
 	int ret;
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	ret = macvtap_do_read(q, m->msg_iov, m->msg_iovlen, total_len,
-			  flags & MSG_DONTWAIT);
+	iov_iter_init(&to, READ, m->msg_iov, m->msg_iovlen, total_len);
+	ret = macvtap_do_read(q, &to, flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
-- 
1.7.10.4
