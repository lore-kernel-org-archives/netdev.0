From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] ixgbe: Update code to better handle incrementing page count
Date: Thu, 16 Feb 2017 04:50:34 -0800
Message-ID: <20170216125041.46668-8-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7261 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754615AbdBPMuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:46 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Batch the page count updates instead of doing them one at a time.  By doing
this we can improve the overall performance as the atomic increment
operations can be expensive due to the fact that on x86 they are locked
operations which can cause stalls.  By doing bulk updates we can
consolidate the stall which should help to improve the overall receive
performance.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  7 ++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 39 +++++++++++++++++----------
 2 files changed, 31 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8167e77b924f..d765db6bd8b2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -195,7 +195,12 @@ struct ixgbe_rx_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	struct page *page;
-	unsigned int page_offset;
+#if (BITS_PER_LONG > 32) || (PAGE_SIZE >= 65536)
+	__u32 page_offset;
+#else
+	__u16 page_offset;
+#endif
+	__u16 pagecnt_bias;
 };
 
 struct ixgbe_queue_stats {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ddde6759f094..e4487109292a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1589,6 +1589,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+	bi->pagecnt_bias = 1;
 
 	return true;
 }
@@ -1943,13 +1944,15 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
 	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
 				   ixgbe_rx_bufsz(rx_ring);
 #endif
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+
 	/* avoid re-using remote pages */
 	if (unlikely(ixgbe_page_is_reserved(page)))
 		return false;
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_count(page) != pagecnt_bias))
 		return false;
 
 	/* flip page offset to other buffer */
@@ -1962,10 +1965,14 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
 		return false;
 #endif
 
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
+	/* If we have drained the page fragment pool we need to update
+	 * the pagecnt_bias and page count so that we fully restock the
+	 * number of references the driver holds.
 	 */
-	page_ref_inc(page);
+	if (unlikely(pagecnt_bias == 1)) {
+		page_ref_add(page, USHRT_MAX);
+		rx_buffer->pagecnt_bias = USHRT_MAX;
+	}
 
 	return true;
 }
@@ -2009,7 +2016,6 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			return true;
 
 		/* this page cannot be reused so discard it */
-		__free_pages(page, ixgbe_rx_pg_order(rx_ring));
 		return false;
 	}
 
@@ -2088,15 +2094,19 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 	if (ixgbe_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
 		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
-	} else if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
-		/* the page has been released from the ring */
-		IXGBE_CB(skb)->page_released = true;
 	} else {
-		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
-				     ixgbe_rx_pg_size(rx_ring),
-				     DMA_FROM_DEVICE,
-				     IXGBE_RX_DMA_ATTR);
+		if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
+			/* the page has been released from the ring */
+			IXGBE_CB(skb)->page_released = true;
+		} else {
+			/* we are not reusing the buffer so unmap it */
+			dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
+					     ixgbe_rx_pg_size(rx_ring),
+					     DMA_FROM_DEVICE,
+					     IXGBE_RX_DMA_ATTR);
+		}
+		__page_frag_cache_drain(page,
+					rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of buffer_info */
@@ -4914,7 +4924,8 @@ static void ixgbe_clean_rx_ring(struct ixgbe_ring *rx_ring)
 				     ixgbe_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE,
 				     IXGBE_RX_DMA_ATTR);
-		__free_pages(rx_buffer->page, ixgbe_rx_pg_order(rx_ring));
+		__page_frag_cache_drain(rx_buffer->page,
+					rx_buffer->pagecnt_bias);
 
 		rx_buffer->page = NULL;
 	}
-- 
2.11.0
