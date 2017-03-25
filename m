From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] i40e/i40evf: Update code to better handle incrementing page count
Date: Sat, 25 Mar 2017 01:12:55 -0700
Message-ID: <20170325081305.31835-2-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:32490 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750820AbdCYINJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:09 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Update the driver code so that we do bulk updates of the page reference
count instead of just incrementing it by one reference at a time.  The
advantage to doing this is that we cut down on atomic operations and
this in turn should give us a slight improvement in cycles per packet.
In addition if we eventually move this over to using build_skb the gains
will be more noticeable.

I also found and fixed a store forwarding stall from where we were
assigning "*new_buff = *old_buff".  By breaking it up into individual
copies we can avoid this and as a result the performance is slightly
improved.

Change-ID: I1d3880dece4133eca3c32423b04a5467321ccc52
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 25 ++++++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  7 ++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 24 ++++++++++++++++++------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  7 ++++++-
 4 files changed, 48 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 0ca307a6c731..e5c89770cbc2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1154,7 +1154,7 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     I40E_RX_DMA_ATTR);
-		__free_pages(rx_bi->page, 0);
+		__page_frag_cache_drain(rx_bi->page, rx_bi->pagecnt_bias);
 
 		rx_bi->page = NULL;
 		rx_bi->page_offset = 0;
@@ -1299,6 +1299,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+	bi->pagecnt_bias = 1;
 
 	return true;
 }
@@ -1604,7 +1605,10 @@ static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
 	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
 
 	/* transfer page from old buffer to new buffer */
-	*new_buff = *old_buff;
+	new_buff->dma		= old_buff->dma;
+	new_buff->page		= old_buff->page;
+	new_buff->page_offset	= old_buff->page_offset;
+	new_buff->pagecnt_bias	= old_buff->pagecnt_bias;
 }
 
 /**
@@ -1656,6 +1660,7 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 #if (PAGE_SIZE >= 8192)
 	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
 #endif
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
 
 	/* Is any reuse possible? */
 	if (unlikely(!i40e_page_is_reusable(page)))
@@ -1663,7 +1668,7 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_count(page) != pagecnt_bias))
 		return false;
 
 	/* flip page offset to other buffer */
@@ -1676,9 +1681,14 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 		return false;
 #endif
 
-	/* Inc ref count on page before passing it up to the stack */
-	get_page(page);
-
+	/* If we have drained the page fragment pool we need to update
+	 * the pagecnt_bias and page count so that we fully restock the
+	 * number of references the driver holds.
+	 */
+	if (unlikely(pagecnt_bias == 1)) {
+		page_ref_add(page, USHRT_MAX);
+		rx_buffer->pagecnt_bias = USHRT_MAX;
+	}
 	return true;
 }
 
@@ -1725,7 +1735,6 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			return true;
 
 		/* this page cannot be reused so discard it */
-		__free_pages(page, 0);
 		return false;
 	}
 
@@ -1819,6 +1828,8 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 		/* we are not reusing the buffer so unmap it */
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
 				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
+		__page_frag_cache_drain(rx_buffer->page,
+					rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of buffer_info */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 49c7b2089d8e..77c3e96f5172 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -258,7 +258,12 @@ struct i40e_tx_buffer {
 struct i40e_rx_buffer {
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
 
 struct i40e_queue_stats {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d7790c08e523..d892922a2ed9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -526,7 +526,7 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     I40E_RX_DMA_ATTR);
-		__free_pages(rx_bi->page, 0);
+		__page_frag_cache_drain(rx_bi->page, rx_bi->pagecnt_bias);
 
 		rx_bi->page = NULL;
 		rx_bi->page_offset = 0;
@@ -671,6 +671,7 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+	bi->pagecnt_bias = 1;
 
 	return true;
 }
@@ -966,7 +967,10 @@ static void i40e_reuse_rx_page(struct i40e_ring *rx_ring,
 	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
 
 	/* transfer page from old buffer to new buffer */
-	*new_buff = *old_buff;
+	new_buff->dma		= old_buff->dma;
+	new_buff->page		= old_buff->page;
+	new_buff->page_offset	= old_buff->page_offset;
+	new_buff->pagecnt_bias	= old_buff->pagecnt_bias;
 }
 
 /**
@@ -1018,6 +1022,7 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 #if (PAGE_SIZE >= 8192)
 	unsigned int last_offset = PAGE_SIZE - I40E_RXBUFFER_2048;
 #endif
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
 
 	/* Is any reuse possible? */
 	if (unlikely(!i40e_page_is_reusable(page)))
@@ -1025,7 +1030,7 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_count(page) != pagecnt_bias))
 		return false;
 
 	/* flip page offset to other buffer */
@@ -1038,8 +1043,14 @@ static bool i40e_can_reuse_rx_page(struct i40e_rx_buffer *rx_buffer,
 		return false;
 #endif
 
-	/* Inc ref count on page before passing it up to the stack */
-	get_page(page);
+	/* If we have drained the page fragment pool we need to update
+	 * the pagecnt_bias and page count so that we fully restock the
+	 * number of references the driver holds.
+	 */
+	if (unlikely(pagecnt_bias == 1)) {
+		page_ref_add(page, USHRT_MAX);
+		rx_buffer->pagecnt_bias = USHRT_MAX;
+	}
 
 	return true;
 }
@@ -1087,7 +1098,6 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 			return true;
 
 		/* this page cannot be reused so discard it */
-		__free_pages(page, 0);
 		return false;
 	}
 
@@ -1181,6 +1191,8 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 		/* we are not reusing the buffer so unmap it */
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
 				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
+		__page_frag_cache_drain(rx_buffer->page,
+					rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of buffer_info */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 013512124e6a..7b41df1909be 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -244,7 +244,12 @@ struct i40e_tx_buffer {
 struct i40e_rx_buffer {
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
 
 struct i40e_queue_stats {
-- 
2.12.0
