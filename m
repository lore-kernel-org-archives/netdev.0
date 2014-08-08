From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net v2 2/3] xen-netback: don't stop dealloc kthread too early
Date: Fri, 8 Aug 2014 17:37:12 +0100
Message-ID: <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17931 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959AbaHHQhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 12:37:15 -0400
In-Reply-To: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reference count the number of packets in host stack, so that we don't
stop the deallocation thread too early. If not, we can end up with
xenvif_free permanently waiting for deallocation thread to unmap grefs.

Reported-by: Thomas Leonard <talex5@gmail.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
---
 drivers/net/xen-netback/common.h    |    5 +++++
 drivers/net/xen-netback/interface.c |   16 ++++++++++++++++
 drivers/net/xen-netback/netback.c   |   24 ++++++++++++++++++++----
 3 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index ef3026f..d9b7f85 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -165,6 +165,8 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	u16 dealloc_ring[MAX_PENDING_REQS];
 	struct task_struct *dealloc_task;
 	wait_queue_head_t dealloc_wq;
+	wait_queue_head_t inflight_wq;
+	atomic_t inflight_packets;
 
 	/* Use kthread for guest RX */
 	struct task_struct *task;
@@ -329,4 +331,7 @@ extern unsigned int xenvif_max_queues;
 extern struct dentry *xen_netback_dbg_root;
 #endif
 
+void xenvif_inc_inflight_packets(struct xenvif_queue *queue);
+void xenvif_dec_inflight_packets(struct xenvif_queue *queue);
+
 #endif /* __XEN_NETBACK__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fdb4fca..6488801 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -43,6 +43,17 @@
 #define XENVIF_QUEUE_LENGTH 32
 #define XENVIF_NAPI_WEIGHT  64
 
+void xenvif_inc_inflight_packets(struct xenvif_queue *queue)
+{
+	atomic_inc(&queue->inflight_packets);
+}
+
+void xenvif_dec_inflight_packets(struct xenvif_queue *queue)
+{
+	if (atomic_dec_and_test(&queue->inflight_packets))
+		wake_up(&queue->inflight_wq);
+}
+
 static inline void xenvif_stop_queue(struct xenvif_queue *queue)
 {
 	struct net_device *dev = queue->vif->dev;
@@ -561,6 +572,8 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 
 	init_waitqueue_head(&queue->wq);
 	init_waitqueue_head(&queue->dealloc_wq);
+	init_waitqueue_head(&queue->inflight_wq);
+	atomic_set(&queue->inflight_packets, 0);
 
 	if (tx_evtchn == rx_evtchn) {
 		/* feature-split-event-channels == 0 */
@@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
 			queue->task = NULL;
 		}
 
+		wait_event(queue->inflight_wq,
+			   atomic_read(&queue->inflight_packets) == 0);
+
 		if (queue->dealloc_task) {
 			kthread_stop(queue->dealloc_task);
 			queue->dealloc_task = NULL;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 4734472..d2f0c7d7 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -107,6 +107,18 @@ static inline unsigned long idx_to_kaddr(struct xenvif_queue *queue,
 #define callback_param(vif, pending_idx) \
 	(vif->pending_tx_info[pending_idx].callback_struct)
 
+/* This function is used to set SKBTX_DEV_ZEROCOPY as well as
+ * increasing the inflight counter. We need to increase the inflight
+ * counter because core driver calls into xenvif_zerocopy_callback
+ * which calls xenvif_dec_inflight_packets.
+ */
+static void set_skb_zerocopy(struct xenvif_queue *queue,
+			     struct sk_buff *skb)
+{
+	skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+	xenvif_inc_inflight_packets(queue);
+}
+
 /* Find the containing VIF's structure from a pointer in pending_tx_info array
  */
 static inline struct xenvif_queue *ubuf_to_queue(const struct ubuf_info *ubuf)
@@ -1525,10 +1537,13 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
 	/* remove traces of mapped pages and frag_list */
 	skb_frag_list_init(skb);
 	uarg = skb_shinfo(skb)->destructor_arg;
+	/* See comment on set_skb_zerocopy */
+	if (uarg->callback == xenvif_zerocopy_callback)
+		xenvif_inc_inflight_packets(queue);
 	uarg->callback(uarg, true);
 	skb_shinfo(skb)->destructor_arg = NULL;
 
-	skb_shinfo(nskb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+	set_skb_zerocopy(queue, nskb);
 	kfree_skb(nskb);
 
 	return 0;
@@ -1589,7 +1604,7 @@ static int xenvif_tx_submit(struct xenvif_queue *queue)
 				if (net_ratelimit())
 					netdev_err(queue->vif->dev,
 						   "Not enough memory to consolidate frag_list!\n");
-				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+				set_skb_zerocopy(queue, skb);
 				kfree_skb(skb);
 				continue;
 			}
@@ -1609,7 +1624,7 @@ static int xenvif_tx_submit(struct xenvif_queue *queue)
 				   "Can't setup checksum in net_tx_action\n");
 			/* We have to set this flag to trigger the callback */
 			if (skb_shinfo(skb)->destructor_arg)
-				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+				set_skb_zerocopy(queue, skb);
 			kfree_skb(skb);
 			continue;
 		}
@@ -1641,7 +1656,7 @@ static int xenvif_tx_submit(struct xenvif_queue *queue)
 		 * skb. E.g. the __pskb_pull_tail earlier can do such thing.
 		 */
 		if (skb_shinfo(skb)->destructor_arg) {
-			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+			set_skb_zerocopy(queue, skb);
 			queue->stats.tx_zerocopy_sent++;
 		}
 
@@ -1681,6 +1696,7 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
 		queue->stats.tx_zerocopy_success++;
 	else
 		queue->stats.tx_zerocopy_fail++;
+	xenvif_dec_inflight_packets(queue);
 }
 
 static inline void xenvif_tx_dealloc_action(struct xenvif_queue *queue)
-- 
1.7.10.4
