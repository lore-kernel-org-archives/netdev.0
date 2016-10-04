From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v2 net-next 6/7] xen-netback: batch copies for multiple to-guest rx packets
Date: Tue, 4 Oct 2016 10:29:17 +0100
Message-ID: <1475573358-32414-7-git-send-email-paul.durrant@citrix.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54781 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754180AbcJDJtM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 05:49:12 -0400
In-Reply-To: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

Instead of flushing the copy ops when an packet is complete, complete
packets when their copy ops are done.  This improves performance by
reducing the number of grant copy hypercalls.

Latency is still limited by the relatively small size of the copy
batch.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
[re-based]
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
---
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h |  1 +
 drivers/net/xen-netback/rx.c     | 27 +++++++++++++++++----------
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 7d12a38..cf68149 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -132,6 +132,7 @@ struct xenvif_copy_state {
 	struct gnttab_copy op[COPY_BATCH_SIZE];
 	RING_IDX idx[COPY_BATCH_SIZE];
 	unsigned int num;
+	struct sk_buff_head *completed;
 };
 
 struct xenvif_queue { /* Per-queue data for xenvif */
diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index ae822b8..8c8c5b5 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -133,6 +133,7 @@ static void xenvif_rx_queue_drop_expired(struct xenvif_queue *queue)
 static void xenvif_rx_copy_flush(struct xenvif_queue *queue)
 {
 	unsigned int i;
+	int notify;
 
 	gnttab_batch_copy(queue->rx_copy.op, queue->rx_copy.num);
 
@@ -154,6 +155,13 @@ static void xenvif_rx_copy_flush(struct xenvif_queue *queue)
 	}
 
 	queue->rx_copy.num = 0;
+
+	/* Push responses for all completed packets. */
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->rx, notify);
+	if (notify)
+		notify_remote_via_irq(queue->rx_irq);
+
+	__skb_queue_purge(queue->rx_copy.completed);
 }
 
 static void xenvif_rx_copy_add(struct xenvif_queue *queue,
@@ -279,18 +287,10 @@ static void xenvif_rx_next_skb(struct xenvif_queue *queue,
 static void xenvif_rx_complete(struct xenvif_queue *queue,
 			       struct xenvif_pkt_state *pkt)
 {
-	int notify;
-
-	/* Complete any outstanding copy ops for this skb. */
-	xenvif_rx_copy_flush(queue);
-
-	/* Push responses and notify. */
+	/* All responses are ready to be pushed. */
 	queue->rx.rsp_prod_pvt = queue->rx.req_cons;
-	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->rx, notify);
-	if (notify)
-		notify_remote_via_irq(queue->rx_irq);
 
-	dev_kfree_skb(pkt->skb);
+	__skb_queue_tail(queue->rx_copy.completed, pkt->skb);
 }
 
 static void xenvif_rx_next_chunk(struct xenvif_queue *queue,
@@ -429,13 +429,20 @@ void xenvif_rx_skb(struct xenvif_queue *queue)
 
 void xenvif_rx_action(struct xenvif_queue *queue)
 {
+	struct sk_buff_head completed_skbs;
 	unsigned int work_done = 0;
 
+	__skb_queue_head_init(&completed_skbs);
+	queue->rx_copy.completed = &completed_skbs;
+
 	while (xenvif_rx_ring_slots_available(queue) &&
 	       work_done < RX_BATCH_SIZE) {
 		xenvif_rx_skb(queue);
 		work_done++;
 	}
+
+	/* Flush any pending copies and complete all skbs. */
+	xenvif_rx_copy_flush(queue);
 }
 
 static bool xenvif_rx_queue_stalled(struct xenvif_queue *queue)
-- 
2.1.4
