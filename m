From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/3] udp: try to avoid 2 cache miss on dequeue
Date: Mon, 29 May 2017 17:27:25 +0200
Message-ID: <53a22c4f792ffd2efe76e233212185ecee868c1a.1496070490.git.pabeni@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751145AbdE2P2G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 11:28:06 -0400
In-Reply-To: <cover.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when udp_recvmsg() is executed, on x86_64 and other archs, most skb
fields are on cold cachelines.
If the skb are linear and the kernel don't need to compute the udp
csum, only a handful of skb fields are required by udp_recvmsg().
Since we already use skb->dev_scratch to cache hot data, and
there are 32 bits unused on 64 bit archs, use such field to cache
as much data as we can, and try to prefetch on dequeue the relevant
fields that are left out.

This can save up to 2 cache miss per packet.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 103 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 53fa48d..616132e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1163,6 +1163,83 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	return ret;
 }
 
+/* Copy as much information as possible into skb->dev_scratch to avoid
+ * possibly multiple cache miss on dequeue();
+ */
+#if BITS_PER_LONG == 64
+
+/* we can store multiple info here: truesize, len and the bit needed to
+ * compute skb_csum_unnecessary will be on cold cache lines at recvmsg
+ * time.
+ * skb->len can be stored on 16 bits since the udp header has been already
+ * validated and pulled.
+ */
+struct udp_dev_scratch {
+	__u32 truesize;
+	__u16 len;
+	__u16 is_linear:1;
+	__u16 csum_unnecessary:1;
+};
+
+static void udp_set_dev_scratch(struct sk_buff *skb)
+{
+	struct udp_dev_scratch *scratch;
+
+	BUILD_BUG_ON(sizeof(struct udp_dev_scratch) > sizeof(long));
+	scratch = (struct udp_dev_scratch *)&skb->dev_scratch;
+	scratch->truesize = skb->truesize;
+	scratch->len = skb->len;
+	scratch->csum_unnecessary = !!skb_csum_unnecessary(skb);
+	scratch->is_linear = !skb_is_nonlinear(skb);
+}
+
+static int udp_skb_truesize(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->truesize;
+}
+
+static unsigned int udp_skb_len(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->len;
+}
+
+static bool udp_skb_csum_unnecessary(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->csum_unnecessary;
+}
+
+static bool udp_skb_is_linear(struct sk_buff *skb)
+{
+	return ((struct udp_dev_scratch *)&skb->dev_scratch)->is_linear;
+}
+
+#else
+static void udp_set_dev_scratch(struct sk_buff *skb)
+{
+	skb->dev_scratch = skb->truesize;
+}
+
+static int udp_skb_truesize(struct sk_buff *skb)
+{
+	return skb->dev_scratch;
+}
+
+static unsigned int udp_skb_len(struct sk_buff *skb)
+{
+	return skb->len;
+}
+
+static bool udp_skb_csum_unnecessary(struct sk_buff *skb)
+{
+	return skb_csum_unnecessary(skb);
+}
+
+static bool udp_skb_is_linear(struct sk_buff *skb)
+{
+	return !skb_is_nonlinear(skb);
+}
+#endif
+
 /* fully reclaim rmem/fwd memory allocated for skb */
 static void udp_rmem_release(struct sock *sk, int size, int partial,
 			     bool rx_queue_lock_held)
@@ -1213,14 +1290,16 @@ static void udp_rmem_release(struct sock *sk, int size, int partial,
  */
 void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(sk, skb->dev_scratch, 1, false);
+	prefetch(&skb->data);
+	udp_rmem_release(sk, udp_skb_truesize(skb), 1, false);
 }
 EXPORT_SYMBOL(udp_skb_destructor);
 
 /* as above, but the caller held the rx queue lock, too */
 static void udp_skb_dtor_locked(struct sock *sk, struct sk_buff *skb)
 {
-	udp_rmem_release(sk, skb->dev_scratch, 1, true);
+	prefetch(&skb->data);
+	udp_rmem_release(sk, udp_skb_truesize(skb), 1, true);
 }
 
 /* Idea of busylocks is to let producers grab an extra spinlock
@@ -1274,10 +1353,7 @@ int __udp_enqueue_schedule_skb(struct sock *sk, struct sk_buff *skb)
 		busy = busylock_acquire(sk);
 	}
 	size = skb->truesize;
-	/* Copy skb->truesize into skb->dev_scratch to avoid a cache line miss
-	 * in udp_skb_destructor()
-	 */
-	skb->dev_scratch = size;
+	udp_set_dev_scratch(skb);
 
 	/* we drop only if the receive buf is full and the receive
 	 * queue contains some other skb
@@ -1515,6 +1591,18 @@ struct sk_buff *__skb_recv_udp(struct sock *sk, unsigned int flags,
 }
 EXPORT_SYMBOL_GPL(__skb_recv_udp);
 
+static int copy_linear_skb(struct sk_buff *skb, int len, int off,
+			   struct iov_iter *to)
+{
+	int n, copy = len - off;
+
+	n = copy_to_iter(skb->data + off, copy, to);
+	if (n == copy)
+		return 0;
+
+	return -EFAULT;
+}
+
 /*
  * 	This should be easy, if there is something there we
  * 	return it, otherwise we block.
@@ -1541,7 +1629,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 	if (!skb)
 		return err;
 
-	ulen = skb->len;
+	ulen = udp_skb_len(skb);
 	copied = len;
 	if (copied > ulen - off)
 		copied = ulen - off;
@@ -1556,14 +1644,18 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 
 	if (copied < ulen || peeking ||
 	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
-		checksum_valid = !udp_lib_checksum_complete(skb);
+		checksum_valid = udp_skb_csum_unnecessary(skb) ||
+				!__udp_lib_checksum_complete(skb);
 		if (!checksum_valid)
 			goto csum_copy_err;
 	}
 
-	if (checksum_valid || skb_csum_unnecessary(skb))
-		err = skb_copy_datagram_msg(skb, off, msg, copied);
-	else {
+	if (checksum_valid || udp_skb_csum_unnecessary(skb)) {
+		if (udp_skb_is_linear(skb))
+			err = copy_linear_skb(skb, copied, off, &msg->msg_iter);
+		else
+			err = skb_copy_datagram_msg(skb, off, msg, copied);
+	} else {
 		err = skb_copy_and_csum_datagram_msg(skb, off, msg);
 
 		if (err == -EINVAL)
-- 
2.9.4
