From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v3 23/23] igb: Update code to better handle incrementing
 page count
Date: Thu, 10 Nov 2016 06:36:16 -0500
Message-ID: <20161110113616.76501.17072.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2423 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965890AbcKJRh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 12:37:27 -0500
In-Reply-To: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the driver code so that we do bulk updates of the page
reference count instead of just incrementing it by one reference at a time.
The advantage to doing this is that we cut down on atomic operations and
this in turn should give us a slight improvement in cycles per packet.  In
addition if we eventually move this over to using build_skb the gains will
be more noticeable.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c |   24 +++++++++++++++++-------
 2 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 5387b3a..786de01 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -210,7 +210,12 @@ struct igb_tx_buffer {
 struct igb_rx_buffer {
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
 
 struct igb_tx_queue_stats {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ba97392..f5a9fd6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3937,7 +3937,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__free_page(buffer_info->page);
+		__page_frag_drain(buffer_info->page, 0,
+				  buffer_info->pagecnt_bias);
 
 		buffer_info->page = NULL;
 	}
@@ -6813,13 +6814,15 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 				  struct page *page,
 				  unsigned int truesize)
 {
+	unsigned int pagecnt_bias = rx_buffer->pagecnt_bias--;
+
 	/* avoid re-using remote pages */
 	if (unlikely(igb_page_is_reserved(page)))
 		return false;
 
 #if (PAGE_SIZE < 8192)
 	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
+	if (unlikely(page_ref_count(page) != pagecnt_bias))
 		return false;
 
 	/* flip page offset to other buffer */
@@ -6832,10 +6835,14 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
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
@@ -6887,7 +6894,6 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 			return true;
 
 		/* this page cannot be reused so discard it */
-		__free_page(page);
 		return false;
 	}
 
@@ -6958,10 +6964,13 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		/* hand second half of page back to the ring */
 		igb_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
-		/* we are not reusing the buffer so unmap it */
+		/* We are not reusing the buffer so unmap it and free
+		 * any references we are holding to it
+		 */
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     PAGE_SIZE, DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
+		__page_frag_drain(page, 0, rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of rx_buffer */
@@ -7235,6 +7244,7 @@ static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
 	bi->dma = dma;
 	bi->page = page;
 	bi->page_offset = 0;
+	bi->pagecnt_bias = 1;
 
 	return true;
 }
