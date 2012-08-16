From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 7/9] ixgbe: Make allocating skb and placing data in it a separate function
Date: Thu, 16 Aug 2012 15:48:36 -0700
Message-ID: <1345157318-23731-8-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756838Ab2HPWsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:52 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch creates a function named ixgbe_fetch_rx_buffer. The sole
purpose of this function is to retrieve a single buffer off of the ring and
to place it in an skb.

The advantage to doing this is that it helps improve the readability since
I can decrease the indentation and for the code in this section.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 166 ++++++++++++++------------
 1 file changed, 89 insertions(+), 77 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d11fac5..9e72ae6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1693,6 +1693,89 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	return true;
 }
 
+static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
+					     union ixgbe_adv_rx_desc *rx_desc)
+{
+	struct ixgbe_rx_buffer *rx_buffer;
+	struct sk_buff *skb;
+	struct page *page;
+
+	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
+	page = rx_buffer->page;
+	prefetchw(page);
+
+	skb = rx_buffer->skb;
+
+	if (likely(!skb)) {
+		void *page_addr = page_address(page) +
+				  rx_buffer->page_offset;
+
+		/* prefetch first cache line of first page */
+		prefetch(page_addr);
+#if L1_CACHE_BYTES < 128
+		prefetch(page_addr + L1_CACHE_BYTES);
+#endif
+
+		/* allocate a skb to store the frags */
+		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+						IXGBE_RX_HDR_SIZE);
+		if (unlikely(!skb)) {
+			rx_ring->rx_stats.alloc_rx_buff_failed++;
+			return NULL;
+		}
+
+		/*
+		 * we will be copying header into skb->data in
+		 * pskb_may_pull so it is in our interest to prefetch
+		 * it now to avoid a possible cache miss
+		 */
+		prefetchw(skb->data);
+
+		/*
+		 * Delay unmapping of the first packet. It carries the
+		 * header information, HW may still access the header
+		 * after the writeback.  Only unmap it when EOP is
+		 * reached
+		 */
+		if (likely(ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)))
+			goto dma_sync;
+
+		IXGBE_CB(skb)->dma = rx_buffer->dma;
+	} else {
+		if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
+			ixgbe_dma_sync_frag(rx_ring, skb);
+
+dma_sync:
+		/* we are reusing so sync this buffer for CPU use */
+		dma_sync_single_range_for_cpu(rx_ring->dev,
+					      rx_buffer->dma,
+					      rx_buffer->page_offset,
+					      ixgbe_rx_bufsz(rx_ring),
+					      DMA_FROM_DEVICE);
+	}
+
+	/* pull page into skb */
+	if (ixgbe_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+		/* hand second half of page back to the ring */
+		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
+	} else if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
+		/* the page has been released from the ring */
+		IXGBE_CB(skb)->page_released = true;
+	} else {
+		/* we are not reusing the buffer so unmap it */
+		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+			       ixgbe_rx_pg_size(rx_ring),
+			       DMA_FROM_DEVICE);
+	}
+
+	/* clear contents of buffer_info */
+	rx_buffer->skb = NULL;
+	rx_buffer->dma = 0;
+	rx_buffer->page = NULL;
+
+	return skb;
+}
+
 /**
  * ixgbe_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @q_vector: structure containing interrupt and ring information
@@ -1718,11 +1801,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
 
 	do {
-		struct ixgbe_rx_buffer *rx_buffer;
 		union ixgbe_adv_rx_desc *rx_desc;
 		struct sk_buff *skb;
-		struct page *page;
-		u16 ntc;
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
@@ -1730,9 +1810,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			cleaned_count = 0;
 		}
 
-		ntc = rx_ring->next_to_clean;
-		rx_desc = IXGBE_RX_DESC(rx_ring, ntc);
-		rx_buffer = &rx_ring->rx_buffer_info[ntc];
+		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
 
 		if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
 			break;
@@ -1744,78 +1822,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		 */
 		rmb();
 
-		page = rx_buffer->page;
-		prefetchw(page);
-
-		skb = rx_buffer->skb;
-
-		if (likely(!skb)) {
-			void *page_addr = page_address(page) +
-					  rx_buffer->page_offset;
-
-			/* prefetch first cache line of first page */
-			prefetch(page_addr);
-#if L1_CACHE_BYTES < 128
-			prefetch(page_addr + L1_CACHE_BYTES);
-#endif
-
-			/* allocate a skb to store the frags */
-			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
-							IXGBE_RX_HDR_SIZE);
-			if (unlikely(!skb)) {
-				rx_ring->rx_stats.alloc_rx_buff_failed++;
-				break;
-			}
-
-			/*
-			 * we will be copying header into skb->data in
-			 * pskb_may_pull so it is in our interest to prefetch
-			 * it now to avoid a possible cache miss
-			 */
-			prefetchw(skb->data);
-
-			/*
-			 * Delay unmapping of the first packet. It carries the
-			 * header information, HW may still access the header
-			 * after the writeback.  Only unmap it when EOP is
-			 * reached
-			 */
-			if (likely(ixgbe_test_staterr(rx_desc,
-						      IXGBE_RXD_STAT_EOP)))
-				goto dma_sync;
+		/* retrieve a buffer from the ring */
+		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
 
-			IXGBE_CB(skb)->dma = rx_buffer->dma;
-		} else {
-			if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
-				ixgbe_dma_sync_frag(rx_ring, skb);
-
-dma_sync:
-			/* we are reusing so sync this buffer for CPU use */
-			dma_sync_single_range_for_cpu(rx_ring->dev,
-						      rx_buffer->dma,
-						      rx_buffer->page_offset,
-						      ixgbe_rx_bufsz(rx_ring),
-						      DMA_FROM_DEVICE);
-		}
-
-		/* pull page into skb */
-		if (ixgbe_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
-			/* hand second half of page back to the ring */
-			ixgbe_reuse_rx_page(rx_ring, rx_buffer);
-		} else if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
-			/* the page has been released from the ring */
-			IXGBE_CB(skb)->page_released = true;
-		} else {
-			/* we are not reusing the buffer so unmap it */
-			dma_unmap_page(rx_ring->dev, rx_buffer->dma,
-				       ixgbe_rx_pg_size(rx_ring),
-				       DMA_FROM_DEVICE);
-		}
-
-		/* clear contents of buffer_info */
-		rx_buffer->skb = NULL;
-		rx_buffer->dma = 0;
-		rx_buffer->page = NULL;
+		/* exit if we failed to retrieve a buffer */
+		if (!skb)
+			break;
 
 		ixgbe_get_rsc_cnt(rx_ring, rx_desc, skb);
 
-- 
1.7.11.2
