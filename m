From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/4] fm10k: Clean-up page reuse code
Date: Thu, 13 Nov 2014 08:18:26 -0800
Message-ID: <20141113161826.2790.24435.stgit@ahduyck-vm-fedora20>
References: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Vick <matthew.vick@intel.com>, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52737 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932539AbaKMQSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 11:18:36 -0500
In-Reply-To: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up the page reuse code getting it into a state where all
the workarounds needed are in place as well as cleaning up a few minor
oversights such as using __free_pages instead of put_page to drop a locally
allocated page.

It also cleans up how we clear the descriptor status bits.  Previously they
were zeroed as a part of clearing the hdr_addr.  However the hdr_addr is a
64 bit field and 64 bit writes can be a bit more expensive on on 32 bit
systems.  Since we are no longer using the header split feature the upper
32 bits of the address no longer need to be cleared.  As a result we can
just clear the status bits and leave the length and VLAN fields as-is which
should provide more information in debugging.

Cc: Matthew Vick <matthew.vick@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c |   34 +++++++++++++------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 73457ed..8c8deec 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -97,7 +97,6 @@ static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
 	 */
 	if (dma_mapping_error(rx_ring->dev, dma)) {
 		__free_page(page);
-		bi->page = NULL;
 
 		rx_ring->rx_stats.alloc_failed++;
 		return false;
@@ -147,8 +146,8 @@ void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count)
 			i -= rx_ring->count;
 		}
 
-		/* clear the hdr_addr for the next_to_use descriptor */
-		rx_desc->q.hdr_addr = 0;
+		/* clear the status bits for the next_to_use descriptor */
+		rx_desc->d.staterr = 0;
 
 		cleaned_count--;
 	} while (cleaned_count);
@@ -194,7 +193,7 @@ static void fm10k_reuse_rx_page(struct fm10k_ring *rx_ring,
 	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
 
 	/* transfer page from old buffer to new buffer */
-	memcpy(new_buff, old_buff, sizeof(struct fm10k_rx_buffer));
+	*new_buff = *old_buff;
 
 	/* sync the buffer for use by the device */
 	dma_sync_single_range_for_device(rx_ring->dev, old_buff->dma,
@@ -203,12 +202,17 @@ static void fm10k_reuse_rx_page(struct fm10k_ring *rx_ring,
 					 DMA_FROM_DEVICE);
 }
 
+static inline bool fm10k_page_is_reserved(struct page *page)
+{
+	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+}
+
 static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
 				    struct page *page,
 				    unsigned int truesize)
 {
 	/* avoid re-using remote pages */
-	if (unlikely(page_to_nid(page) != numa_mem_id()))
+	if (unlikely(fm10k_page_is_reserved(page)))
 		return false;
 
 #if (PAGE_SIZE < 8192)
@@ -218,22 +222,19 @@ static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
 
 	/* flip page offset to other buffer */
 	rx_buffer->page_offset ^= FM10K_RX_BUFSZ;
-
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
-	 */
-	atomic_inc(&page->_count);
 #else
 	/* move offset up to the next cache line */
 	rx_buffer->page_offset += truesize;
 
 	if (rx_buffer->page_offset > (PAGE_SIZE - FM10K_RX_BUFSZ))
 		return false;
-
-	/* bump ref count on page before it is given to the stack */
-	get_page(page);
 #endif
 
+	/* Even if we own the page, we are not allowed to use atomic_set()
+	 * This would break get_page_unless_zero() users.
+	 */
+	atomic_inc(&page->_count);
+
 	return true;
 }
 
@@ -270,12 +271,12 @@ static bool fm10k_add_rx_frag(struct fm10k_ring *rx_ring,
 
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
-		/* we can reuse buffer as-is, just make sure it is local */
-		if (likely(page_to_nid(page) == numa_mem_id()))
+		/* page is not reserved, we can reuse buffer as-is */
+		if (likely(!fm10k_page_is_reserved(page)))
 			return true;
 
 		/* this page cannot be reused so discard it */
-		put_page(page);
+		__free_page(page);
 		return false;
 	}
 
@@ -293,7 +294,6 @@ static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
 	struct page *page;
 
 	rx_buffer = &rx_ring->rx_buffer[rx_ring->next_to_clean];
-
 	page = rx_buffer->page;
 	prefetchw(page);
 
