From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 2/9] ixgbe: combine ixgbe_add_rx_frag and ixgbe_can_reuse_page
Date: Thu, 16 Aug 2012 15:48:31 -0700
Message-ID: <1345157318-23731-3-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755488Ab2HPWsu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:50 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch combines ixgbe_add_rx_frag and ixgbe_can_reuse_page into a
single function. The main motivation behind this is to make better use of
the values so that we don't have to load them from memory and into
registers twice.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 73 +++++++++++++--------------
 1 file changed, 34 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f7351c6..6a8c484 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1560,33 +1560,17 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 }
 
 /**
- * ixgbe_can_reuse_page - determine if we can reuse a page
- * @rx_buffer: pointer to rx_buffer containing the page we want to reuse
- *
- * Returns true if page can be reused in another Rx buffer
- **/
-static inline bool ixgbe_can_reuse_page(struct ixgbe_rx_buffer *rx_buffer)
-{
-	struct page *page = rx_buffer->page;
-
-	/* if we are only owner of page and it is local we can reuse it */
-	return likely(page_count(page) == 1) &&
-	       likely(page_to_nid(page) == numa_node_id());
-}
-
-/**
  * ixgbe_reuse_rx_page - page flip buffer and store it back on the ring
  * @rx_ring: rx descriptor ring to store buffers on
  * @old_buff: donor buffer to have page reused
  *
- * Syncronizes page for reuse by the adapter
+ * Synchronizes page for reuse by the adapter
  **/
 static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
 				struct ixgbe_rx_buffer *old_buff)
 {
 	struct ixgbe_rx_buffer *new_buff;
 	u16 nta = rx_ring->next_to_alloc;
-	u16 bufsz = ixgbe_rx_bufsz(rx_ring);
 
 	new_buff = &rx_ring->rx_buffer_info[nta];
 
@@ -1597,17 +1581,13 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
 	/* transfer page from old buffer to new buffer */
 	new_buff->page = old_buff->page;
 	new_buff->dma = old_buff->dma;
-
-	/* flip page offset to other buffer and store to new_buff */
-	new_buff->page_offset = old_buff->page_offset ^ bufsz;
+	new_buff->page_offset = old_buff->page_offset;
 
 	/* sync the buffer for use by the device */
 	dma_sync_single_range_for_device(rx_ring->dev, new_buff->dma,
-					 new_buff->page_offset, bufsz,
+					 new_buff->page_offset,
+					 ixgbe_rx_bufsz(rx_ring),
 					 DMA_FROM_DEVICE);
-
-	/* bump ref count on page before it is given to the stack */
-	get_page(new_buff->page);
 }
 
 /**
@@ -1617,20 +1597,38 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
  * @rx_desc: descriptor containing length of buffer written by hardware
  * @skb: sk_buff to place the data into
  *
- * This function is based on skb_add_rx_frag.  I would have used that
- * function however it doesn't handle the truesize case correctly since we
- * are allocating more memory than might be used for a single receive.
+ * This function will add the data contained in rx_buffer->page to the skb.
+ * This is done either through a direct copy if the data in the buffer is
+ * less than the skb header size, otherwise it will just attach the page as
+ * a frag to the skb.
+ *
+ * The function will then update the page offset if necessary and return
+ * true if the buffer can be reused by the adapter.
  **/
-static void ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
+static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			      struct ixgbe_rx_buffer *rx_buffer,
-			      struct sk_buff *skb, int size)
+			      union ixgbe_adv_rx_desc *rx_desc,
+			      struct sk_buff *skb)
 {
-	skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
-			   rx_buffer->page, rx_buffer->page_offset,
-			   size);
-	skb->len += size;
-	skb->data_len += size;
-	skb->truesize += ixgbe_rx_bufsz(rx_ring);
+	struct page *page = rx_buffer->page;
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
+	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
+
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+			rx_buffer->page_offset, size, truesize);
+
+	/* if we are only owner of page and it is local we can reuse it */
+	if (unlikely(page_count(page) != 1) ||
+	    unlikely(page_to_nid(page) != numa_node_id()))
+		return false;
+
+	/* flip page offset to other buffer */
+	rx_buffer->page_offset ^= truesize;
+
+	/* bump ref count on page before it is given to the stack */
+	get_page(page);
+
+	return true;
 }
 
 /**
@@ -1731,10 +1729,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		/* pull page into skb */
-		ixgbe_add_rx_frag(rx_ring, rx_buffer, skb,
-				  le16_to_cpu(rx_desc->wb.upper.length));
-
-		if (ixgbe_can_reuse_page(rx_buffer)) {
+		if (ixgbe_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
 			/* hand second half of page back to the ring */
 			ixgbe_reuse_rx_page(rx_ring, rx_buffer);
 		} else if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
-- 
1.7.11.2
