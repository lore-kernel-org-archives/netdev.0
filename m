From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbe: Break out Rx buffer page management
Date: Thu, 16 Feb 2017 04:50:37 -0800
Message-ID: <20170216125041.46668-11-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29436 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754477AbdBPMut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:49 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We are going to be expanding the number of Rx paths in the driver.  Instead
of duplicating all that code I am pulling it apart into separate functions
so that we don't have so much code duplication.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 231 ++++++++++++++------------
 1 file changed, 122 insertions(+), 109 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6fc26cdacba2..1e5575305f2a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1847,7 +1847,6 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
 				     ixgbe_rx_pg_size(rx_ring),
 				     DMA_FROM_DEVICE,
 				     IXGBE_RX_DMA_ATTR);
-		IXGBE_CB(skb)->page_released = false;
 	} else {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
 
@@ -1857,7 +1856,6 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
 					      skb_frag_size(frag),
 					      DMA_FROM_DEVICE);
 	}
-	IXGBE_CB(skb)->dma = 0;
 }
 
 /**
@@ -1928,8 +1926,14 @@ static void ixgbe_reuse_rx_page(struct ixgbe_ring *rx_ring,
 	nta++;
 	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
 
-	/* transfer page from old buffer to new buffer */
-	*new_buff = *old_buff;
+	/* Transfer page from old buffer to new buffer.
+	 * Move each member individually to avoid possible store
+	 * forwarding stalls and unnecessary copy of skb.
+	 */
+	new_buff->dma		= old_buff->dma;
+	new_buff->page		= old_buff->page;
+	new_buff->page_offset	= old_buff->page_offset;
+	new_buff->pagecnt_bias	= old_buff->pagecnt_bias;
 }
 
 static inline bool ixgbe_page_is_reserved(struct page *page)
@@ -1937,16 +1941,10 @@ static inline bool ixgbe_page_is_reserved(struct page *page)
 	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
-static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
-				    struct ixgbe_rx_buffer *rx_buffer,
-				    struct page *page,
-				    const unsigned int truesize)
+static bool ixgbe_can_reuse_rx_page(struct ixgbe_rx_buffer *rx_buffer)
 {
-#if (PAGE_SIZE >= 8192)
-	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
-				   ixgbe_rx_bufsz(rx_ring);
-#endif
-	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias;
+	struct page *page = rx_buffer->page;
 
 	/* avoid re-using remote pages */
 	if (unlikely(ixgbe_page_is_reserved(page)))
@@ -1954,16 +1952,17 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != pagecnt_bias))
+	if (unlikely((page_ref_count(page) - pagecnt_bias) > 1))
 		return false;
-
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
 #else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
-
-	if (rx_buffer->page_offset > last_offset)
+	/* The last offset is a bit aggressive in that we assume the
+	 * worst case of FCoE being enabled and using a 3K buffer.
+	 * However this should have minimal impact as the 1K extra is
+	 * still less than one buffer in size.
+	 */
+#define IXGBE_LAST_OFFSET \
+	(SKB_WITH_OVERHEAD(PAGE_SIZE) - IXGBE_RXBUFFER_3K)
+	if (rx_buffer->page_offset > IXGBE_LAST_OFFSET)
 		return false;
 #endif
 
@@ -1971,7 +1970,7 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
 	 * the pagecnt_bias and page count so that we fully restock the
 	 * number of references the driver holds.
 	 */
-	if (unlikely(pagecnt_bias == 1)) {
+	if (unlikely(!pagecnt_bias)) {
 		page_ref_add(page, USHRT_MAX);
 		rx_buffer->pagecnt_bias = USHRT_MAX;
 	}
@@ -1994,106 +1993,65 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
  * The function will then update the page offset if necessary and return
  * true if the buffer can be reused by the adapter.
  **/
-static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
+static void ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			      struct ixgbe_rx_buffer *rx_buffer,
-			      unsigned int size,
-			      struct sk_buff *skb)
+			      struct sk_buff *skb,
+			      unsigned int size)
 {
-	struct page *page = rx_buffer->page;
-	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
-
-	if (unlikely(skb_is_nonlinear(skb)))
-		goto add_tail_frag;
-
-	if (size <= IXGBE_RX_HDR_SIZE) {
-		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
-
-		/* page is not reserved, we can reuse buffer as-is */
-		if (likely(!ixgbe_page_is_reserved(page)))
-			return true;
-
-		/* this page cannot be reused so discard it */
-		return false;
-	}
-
-add_tail_frag:
-	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, rx_buffer->page,
 			rx_buffer->page_offset, size, truesize);
-
-	return ixgbe_can_reuse_rx_page(rx_ring, rx_buffer, page, truesize);
+#if (PAGE_SIZE < 8192)
+	rx_buffer->page_offset ^= truesize;
+#else
+	rx_buffer->page_offset += truesize;
+#endif
 }
 
-static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
-					     union ixgbe_adv_rx_desc *rx_desc)
+static struct ixgbe_rx_buffer *ixgbe_get_rx_buffer(struct ixgbe_ring *rx_ring,
+						   union ixgbe_adv_rx_desc *rx_desc,
+						   struct sk_buff **skb,
+						   const unsigned int size)
 {
-	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 	struct ixgbe_rx_buffer *rx_buffer;
-	struct sk_buff *skb;
-	struct page *page;
 
 	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
-	page = rx_buffer->page;
-	prefetchw(page);
-
-	skb = rx_buffer->skb;
-
-	if (likely(!skb)) {
-		void *page_addr = page_address(page) +
-				  rx_buffer->page_offset;
+	prefetchw(rx_buffer->page);
+	*skb = rx_buffer->skb;
 
-		/* prefetch first cache line of first page */
-		prefetch(page_addr);
-#if L1_CACHE_BYTES < 128
-		prefetch(page_addr + L1_CACHE_BYTES);
-#endif
-
-		/* allocate a skb to store the frags */
-		skb = napi_alloc_skb(&rx_ring->q_vector->napi,
-				     IXGBE_RX_HDR_SIZE);
-		if (unlikely(!skb)) {
-			rx_ring->rx_stats.alloc_rx_buff_failed++;
-			return NULL;
-		}
-
-		/*
-		 * we will be copying header into skb->data in
-		 * pskb_may_pull so it is in our interest to prefetch
-		 * it now to avoid a possible cache miss
-		 */
-		prefetchw(skb->data);
-
-		/*
-		 * Delay unmapping of the first packet. It carries the
-		 * header information, HW may still access the header
-		 * after the writeback.  Only unmap it when EOP is
-		 * reached
-		 */
-		if (likely(ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)))
-			goto dma_sync;
-
-		IXGBE_CB(skb)->dma = rx_buffer->dma;
+	/* Delay unmapping of the first packet. It carries the header
+	 * information, HW may still access the header after the writeback.
+	 * Only unmap it when EOP is reached
+	 */
+	if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)) {
+		if (!*skb)
+			goto skip_sync;
 	} else {
-		if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
-			ixgbe_dma_sync_frag(rx_ring, skb);
+		if (*skb)
+			ixgbe_dma_sync_frag(rx_ring, *skb);
+	}
 
-dma_sync:
-		/* we are reusing so sync this buffer for CPU use */
-		dma_sync_single_range_for_cpu(rx_ring->dev,
-					      rx_buffer->dma,
-					      rx_buffer->page_offset,
-					      size,
-					      DMA_FROM_DEVICE);
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      size,
+				      DMA_FROM_DEVICE);
+skip_sync:
+	rx_buffer->pagecnt_bias--;
 
-		rx_buffer->skb = NULL;
-	}
+	return rx_buffer;
+}
 
-	/* pull page into skb */
-	if (ixgbe_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
+static void ixgbe_put_rx_buffer(struct ixgbe_ring *rx_ring,
+				struct ixgbe_rx_buffer *rx_buffer,
+				struct sk_buff *skb)
+{
+	if (ixgbe_can_reuse_rx_page(rx_buffer)) {
 		/* hand second half of page back to the ring */
 		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
@@ -2107,12 +2065,55 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 					     DMA_FROM_DEVICE,
 					     IXGBE_RX_DMA_ATTR);
 		}
-		__page_frag_cache_drain(page,
+		__page_frag_cache_drain(rx_buffer->page,
 					rx_buffer->pagecnt_bias);
 	}
 
-	/* clear contents of buffer_info */
+	/* clear contents of rx_buffer */
 	rx_buffer->page = NULL;
+	rx_buffer->skb = NULL;
+}
+
+static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
+					   struct ixgbe_rx_buffer *rx_buffer,
+					   union ixgbe_adv_rx_desc *rx_desc,
+					   unsigned int size)
+{
+	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
+#else
+	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+#endif
+	struct sk_buff *skb;
+
+	/* prefetch first cache line of first page */
+	prefetch(va);
+#if L1_CACHE_BYTES < 128
+	prefetch(va + L1_CACHE_BYTES);
+#endif
+
+	/* allocate a skb to store the frags */
+	skb = napi_alloc_skb(&rx_ring->q_vector->napi, IXGBE_RX_HDR_SIZE);
+	if (unlikely(!skb))
+		return NULL;
+
+	if (size > IXGBE_RX_HDR_SIZE) {
+		if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
+			IXGBE_CB(skb)->dma = rx_buffer->dma;
+
+		skb_add_rx_frag(skb, 0, rx_buffer->page,
+				rx_buffer->page_offset,
+				size, truesize);
+#if (PAGE_SIZE < 8192)
+		rx_buffer->page_offset ^= truesize;
+#else
+		rx_buffer->page_offset += truesize;
+#endif
+	} else {
+		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
+		rx_buffer->pagecnt_bias++;
+	}
 
 	return skb;
 }
@@ -2144,7 +2145,9 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 	while (likely(total_rx_packets < budget)) {
 		union ixgbe_adv_rx_desc *rx_desc;
+		struct ixgbe_rx_buffer *rx_buffer;
 		struct sk_buff *skb;
+		unsigned int size;
 
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
@@ -2153,8 +2156,8 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		}
 
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ring->next_to_clean);
-
-		if (!rx_desc->wb.upper.length)
+		size = le16_to_cpu(rx_desc->wb.upper.length);
+		if (!size)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
@@ -2163,13 +2166,23 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		 */
 		dma_rmb();
 
+		rx_buffer = ixgbe_get_rx_buffer(rx_ring, rx_desc, &skb, size);
+
 		/* retrieve a buffer from the ring */
-		skb = ixgbe_fetch_rx_buffer(rx_ring, rx_desc);
+		if (skb)
+			ixgbe_add_rx_frag(rx_ring, rx_buffer, skb, size);
+		else
+			skb = ixgbe_construct_skb(rx_ring, rx_buffer,
+						  rx_desc, size);
 
 		/* exit if we failed to retrieve a buffer */
-		if (!skb)
+		if (!skb) {
+			rx_ring->rx_stats.alloc_rx_buff_failed++;
+			rx_buffer->pagecnt_bias++;
 			break;
+		}
 
+		ixgbe_put_rx_buffer(rx_ring, rx_buffer, skb);
 		cleaned_count++;
 
 		/* place incomplete frames back on ring for completion */
-- 
2.11.0
