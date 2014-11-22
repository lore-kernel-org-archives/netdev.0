From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 06/17] switch macvtap to ->read_iter()
Date: Sat, 22 Nov 2014 04:32:30 +0000
Message-ID: <20141122043230.GF30478@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	nab@linux-iscsi.org, hch@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/net/macvtap.c |   39 ++++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index cea99d4..cdd820f 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -829,16 +829,17 @@ done:
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
@@ -856,37 +857,27 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 			}
 			/* Nothing to read, let's sleep */
 			schedule();
-			continue;
 		}
-		iov_iter_init(&iter, READ, iv, segs, len);
-		ret = macvtap_put_user(q, skb, &iter);
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
 
@@ -1087,7 +1078,8 @@ static const struct file_operations macvtap_fops = {
 	.owner		= THIS_MODULE,
 	.open		= macvtap_open,
 	.release	= macvtap_release,
-	.aio_read	= macvtap_aio_read,
+	.read		= new_sync_read,
+	.read_iter	= macvtap_read_iter,
 	.aio_write	= macvtap_aio_write,
 	.poll		= macvtap_poll,
 	.llseek		= no_llseek,
@@ -1110,11 +1102,12 @@ static int macvtap_recvmsg(struct kiocb *iocb, struct socket *sock,
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
