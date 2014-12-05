From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 09/12] switch memcpy_to_msg() and skb_copy{,_and_csum}_datagram_msg() to primitives
Date: Fri,  5 Dec 2014 05:58:50 +0000
Message-ID: <1417759133-18370-9-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

... making both non-draining.  That means that tcp_recvmsg() becomes
non-draining.  And _that_ would break iscsit_do_rx_data() unless we
	a) make sure tcp_recvmsg() is uniformly non-draining (it is)
	b) make sure it copes with arbitrary (including shifted)
iov_iter (it does, all it uses is iov_iter primitives)
	c) make iscsit_do_rx_data() initialize ->msg_iter only once.

Fortunately, (c) is doable with minimal work and we are rid of one
the two places where kernel send/recvmsg users would be unhappy with
non-draining behaviour.

Actually, that makes all but one of ->recvmsg() instances iov_iter-clean.
The exception is skcipher_recvmsg() and it also isn't hard to convert
to primitives (iov_iter_get_pages() is needed there).  That'll wait
a bit - there's some interplay with ->sendmsg() path for that one.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/target/iscsi/iscsi_target_util.c | 12 +++----
 include/linux/skbuff.h                   | 16 +++-------
 net/core/datagram.c                      | 54 +++++++++++---------------------
 3 files changed, 28 insertions(+), 54 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target_util.c b/drivers/target/iscsi/iscsi_target_util.c
index ce87ce9..7c6a95b 100644
--- a/drivers/target/iscsi/iscsi_target_util.c
+++ b/drivers/target/iscsi/iscsi_target_util.c
@@ -1326,21 +1326,19 @@ static int iscsit_do_rx_data(
 	struct iscsi_conn *conn,
 	struct iscsi_data_count *count)
 {
-	int data = count->data_length, rx_loop = 0, total_rx = 0, iov_len;
-	struct kvec *iov_p;
+	int data = count->data_length, rx_loop = 0, total_rx = 0;
 	struct msghdr msg;
 
 	if (!conn || !conn->sock || !conn->conn_ops)
 		return -1;
 
 	memset(&msg, 0, sizeof(struct msghdr));
-
-	iov_p = count->iov;
-	iov_len	= count->iov_count;
+	iov_iter_kvec(&msg.msg_iter, READ | ITER_KVEC,
+		      count->iov, count->iov_count, data);
 
 	while (total_rx < data) {
-		rx_loop = kernel_recvmsg(conn->sock, &msg, iov_p, iov_len,
-					(data - total_rx), MSG_WAITALL);
+		rx_loop = sock_recvmsg(conn->sock, &msg,
+				      (data - total_rx), MSG_WAITALL);
 		if (rx_loop <= 0) {
 			pr_debug("rx_loop: %d total_rx: %d\n",
 				rx_loop, total_rx);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4199dfa..45ac95c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2649,17 +2649,10 @@ int skb_copy_datagram_iter(const struct sk_buff *from, int offset,
 static inline int skb_copy_datagram_msg(const struct sk_buff *from, int offset,
 					struct msghdr *msg, int size)
 {
-	/* XXX: stripping const */
-	return skb_copy_datagram_iovec(from, offset, (struct iovec *)msg->msg_iter.iov, size);
-}
-int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb, int hlen,
-				     struct iovec *iov);
-static inline int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
-			    struct msghdr *msg)
-{
-	/* XXX: stripping const */
-	return skb_copy_and_csum_datagram_iovec(skb, hlen, (struct iovec *)msg->msg_iter.iov);
+	return skb_copy_datagram_iter(from, offset, &msg->msg_iter, size);
 }
+int skb_copy_and_csum_datagram_msg(struct sk_buff *skb, int hlen,
+				   struct msghdr *msg);
 int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
 				 struct iov_iter *from, int len);
 int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *frm);
@@ -2695,8 +2688,7 @@ static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 
 static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
 {
-	/* XXX: stripping const */
-	return memcpy_toiovec((struct iovec *)msg->msg_iter.iov, data, len);
+	return copy_to_iter(data, len, &msg->msg_iter) == len ? 0 : -EFAULT;
 }
 
 struct skb_checksum_ops {
diff --git a/net/core/datagram.c b/net/core/datagram.c
index b6e303b..41075ed 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -615,27 +615,25 @@ int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
 EXPORT_SYMBOL(zerocopy_sg_from_iter);
 
 static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
-				      u8 __user *to, int len,
+				      struct iov_iter *to, int len,
 				      __wsum *csump)
 {
 	int start = skb_headlen(skb);
 	int i, copy = start - offset;
 	struct sk_buff *frag_iter;
 	int pos = 0;
+	int n;
 
 	/* Copy header. */
 	if (copy > 0) {
-		int err = 0;
 		if (copy > len)
 			copy = len;
-		*csump = csum_and_copy_to_user(skb->data + offset, to, copy,
-					       *csump, &err);
-		if (err)
+		n = csum_and_copy_to_iter(skb->data + offset, copy, csump, to);
+		if (n != copy)
 			goto fault;
 		if ((len -= copy) == 0)
 			return 0;
 		offset += copy;
-		to += copy;
 		pos = copy;
 	}
 
@@ -647,26 +645,22 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 
 		end = start + skb_frag_size(frag);
 		if ((copy = end - offset) > 0) {
-			__wsum csum2;
-			int err = 0;
-			u8  *vaddr;
+			__wsum csum2 = 0;
 			struct page *page = skb_frag_page(frag);
+			u8  *vaddr = kmap(page);
 
 			if (copy > len)
 				copy = len;
-			vaddr = kmap(page);
-			csum2 = csum_and_copy_to_user(vaddr +
-							frag->page_offset +
-							offset - start,
-						      to, copy, 0, &err);
+			n = csum_and_copy_to_iter(vaddr + frag->page_offset +
+						  offset - start, copy,
+						  &csum2, to);
 			kunmap(page);
-			if (err)
+			if (n != copy)
 				goto fault;
 			*csump = csum_block_add(*csump, csum2, pos);
 			if (!(len -= copy))
 				return 0;
 			offset += copy;
-			to += copy;
 			pos += copy;
 		}
 		start = end;
@@ -691,7 +685,6 @@ static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int offset,
 			if ((len -= copy) == 0)
 				return 0;
 			offset += copy;
-			to += copy;
 			pos += copy;
 		}
 		start = end;
@@ -744,20 +737,19 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb)
 EXPORT_SYMBOL(__skb_checksum_complete);
 
 /**
- *	skb_copy_and_csum_datagram_iovec - Copy and checksum skb to user iovec.
+ *	skb_copy_and_csum_datagram_msg - Copy and checksum skb to user iovec.
  *	@skb: skbuff
  *	@hlen: hardware length
- *	@iov: io vector
+ *	@msg: destination
  *
  *	Caller _must_ check that skb will fit to this iovec.
  *
  *	Returns: 0       - success.
  *		 -EINVAL - checksum failure.
- *		 -EFAULT - fault during copy. Beware, in this case iovec
- *			   can be modified!
+ *		 -EFAULT - fault during copy.
  */
-int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
-				     int hlen, struct iovec *iov)
+int skb_copy_and_csum_datagram_msg(struct sk_buff *skb,
+				   int hlen, struct msghdr *msg)
 {
 	__wsum csum;
 	int chunk = skb->len - hlen;
@@ -765,28 +757,20 @@ int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
 	if (!chunk)
 		return 0;
 
-	/* Skip filled elements.
-	 * Pretty silly, look at memcpy_toiovec, though 8)
-	 */
-	while (!iov->iov_len)
-		iov++;
-
-	if (iov->iov_len < chunk) {
+	if (iov_iter_count(&msg->msg_iter) < chunk) {
 		if (__skb_checksum_complete(skb))
 			goto csum_error;
-		if (skb_copy_datagram_iovec(skb, hlen, iov, chunk))
+		if (skb_copy_datagram_msg(skb, hlen, msg, chunk))
 			goto fault;
 	} else {
 		csum = csum_partial(skb->data, hlen, skb->csum);
-		if (skb_copy_and_csum_datagram(skb, hlen, iov->iov_base,
+		if (skb_copy_and_csum_datagram(skb, hlen, &msg->msg_iter,
 					       chunk, &csum))
 			goto fault;
 		if (csum_fold(csum))
 			goto csum_error;
 		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE))
 			netdev_rx_csum_fault(skb->dev);
-		iov->iov_len -= chunk;
-		iov->iov_base += chunk;
 	}
 	return 0;
 csum_error:
@@ -794,7 +778,7 @@ csum_error:
 fault:
 	return -EFAULT;
 }
-EXPORT_SYMBOL(skb_copy_and_csum_datagram_iovec);
+EXPORT_SYMBOL(skb_copy_and_csum_datagram_msg);
 
 /**
  * 	datagram_poll - generic datagram poll
-- 
2.1.3
