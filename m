From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 net-next] xen-netback: always fully coalesce guest Rx packets
Date: Tue, 20 Jan 2015 14:49:52 +0000
Message-ID: <1421765392-30303-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51026 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbbATOyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2015 09:54:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always fully coalesce guest Rx packets into the minimum number of ring
slots.  Reducing the number of slots per packet has significant
performance benefits when receiving off-host traffic.

Results from XenServer's performance benchmarks:

                         Baseline    Full coalesce
Interhost VM receive      7.2 Gb/s   11 Gb/s
Interhost aggregate      24 Gb/s     24 Gb/s
Intrahost single stream  14 Gb/s     14 Gb/s
Intrahost aggregate      34 Gb/s     34 Gb/s

However, this can increase the number of grant ops per packet which
decreases performance of backend (dom0) to VM traffic (by ~10%)
/unless/ grant copy has been optimized for adjacent ops with the same
source or destination (see "grant-table: defer releasing pages
acquired in a grant copy"[1] expected in Xen 4.6).

[1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg01118.html

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
---
Changes in v2:
- Updated commit message with better results.

 drivers/net/xen-netback/common.h  |    1 -
 drivers/net/xen-netback/netback.c |  106 ++-----------------------------------
 2 files changed, 3 insertions(+), 104 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5f1fda4..589fa25 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -251,7 +251,6 @@ struct xenvif {
 struct xenvif_rx_cb {
 	unsigned long expires;
 	int meta_slots_used;
-	bool full_coalesce;
 };
 
 #define XENVIF_RX_CB(skb) ((struct xenvif_rx_cb *)(skb)->cb)
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 908e65e..568238d 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -233,51 +233,6 @@ static void xenvif_rx_queue_drop_expired(struct xenvif_queue *queue)
 	}
 }
 
-/*
- * Returns true if we should start a new receive buffer instead of
- * adding 'size' bytes to a buffer which currently contains 'offset'
- * bytes.
- */
-static bool start_new_rx_buffer(int offset, unsigned long size, int head,
-				bool full_coalesce)
-{
-	/* simple case: we have completely filled the current buffer. */
-	if (offset == MAX_BUFFER_OFFSET)
-		return true;
-
-	/*
-	 * complex case: start a fresh buffer if the current frag
-	 * would overflow the current buffer but only if:
-	 *     (i)   this frag would fit completely in the next buffer
-	 * and (ii)  there is already some data in the current buffer
-	 * and (iii) this is not the head buffer.
-	 * and (iv)  there is no need to fully utilize the buffers
-	 *
-	 * Where:
-	 * - (i) stops us splitting a frag into two copies
-	 *   unless the frag is too large for a single buffer.
-	 * - (ii) stops us from leaving a buffer pointlessly empty.
-	 * - (iii) stops us leaving the first buffer
-	 *   empty. Strictly speaking this is already covered
-	 *   by (ii) but is explicitly checked because
-	 *   netfront relies on the first buffer being
-	 *   non-empty and can crash otherwise.
-	 * - (iv) is needed for skbs which can use up more than MAX_SKB_FRAGS
-	 *   slot
-	 *
-	 * This means we will effectively linearise small
-	 * frags but do not needlessly split large buffers
-	 * into multiple copies tend to give large frags their
-	 * own buffers as before.
-	 */
-	BUG_ON(size > MAX_BUFFER_OFFSET);
-	if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head &&
-	    !full_coalesce)
-		return true;
-
-	return false;
-}
-
 struct netrx_pending_operations {
 	unsigned copy_prod, copy_cons;
 	unsigned meta_prod, meta_cons;
@@ -336,24 +291,13 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
 		BUG_ON(offset >= PAGE_SIZE);
 		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
 
-		bytes = PAGE_SIZE - offset;
+		if (npo->copy_off == MAX_BUFFER_OFFSET)
+			meta = get_next_rx_buffer(queue, npo);
 
+		bytes = PAGE_SIZE - offset;
 		if (bytes > size)
 			bytes = size;
 
-		if (start_new_rx_buffer(npo->copy_off,
-					bytes,
-					*head,
-					XENVIF_RX_CB(skb)->full_coalesce)) {
-			/*
-			 * Netfront requires there to be some data in the head
-			 * buffer.
-			 */
-			BUG_ON(*head);
-
-			meta = get_next_rx_buffer(queue, npo);
-		}
-
 		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
 			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
 
@@ -652,60 +596,16 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
 
 	while (xenvif_rx_ring_slots_available(queue, XEN_NETBK_RX_SLOTS_MAX)
 	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
-		RING_IDX max_slots_needed;
 		RING_IDX old_req_cons;
 		RING_IDX ring_slots_used;
 		int i;
 
 		queue->last_rx_time = jiffies;
 
-		/* We need a cheap worse case estimate for the number of
-		 * slots we'll use.
-		 */
-
-		max_slots_needed = DIV_ROUND_UP(offset_in_page(skb->data) +
-						skb_headlen(skb),
-						PAGE_SIZE);
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			unsigned int size;
-			unsigned int offset;
-
-			size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-			offset = skb_shinfo(skb)->frags[i].page_offset;
-
-			/* For a worse-case estimate we need to factor in
-			 * the fragment page offset as this will affect the
-			 * number of times xenvif_gop_frag_copy() will
-			 * call start_new_rx_buffer().
-			 */
-			max_slots_needed += DIV_ROUND_UP(offset + size,
-							 PAGE_SIZE);
-		}
-
-		/* To avoid the estimate becoming too pessimal for some
-		 * frontends that limit posted rx requests, cap the estimate
-		 * at MAX_SKB_FRAGS. In this case netback will fully coalesce
-		 * the skb into the provided slots.
-		 */
-		if (max_slots_needed > MAX_SKB_FRAGS) {
-			max_slots_needed = MAX_SKB_FRAGS;
-			XENVIF_RX_CB(skb)->full_coalesce = true;
-		} else {
-			XENVIF_RX_CB(skb)->full_coalesce = false;
-		}
-
-		/* We may need one more slot for GSO metadata */
-		if (skb_is_gso(skb) &&
-		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
-		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6))
-			max_slots_needed++;
-
 		old_req_cons = queue->rx.req_cons;
 		XENVIF_RX_CB(skb)->meta_slots_used = xenvif_gop_skb(skb, &npo, queue);
 		ring_slots_used = queue->rx.req_cons - old_req_cons;
 
-		BUG_ON(ring_slots_used > max_slots_needed);
-
 		__skb_queue_tail(&rxq, skb);
 	}
 
-- 
1.7.10.4
