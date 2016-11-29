From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [mm PATCH 2/3] mm: Rename __page_frag functions to
 __page_frag_cache, drop order from drain
Date: Tue, 29 Nov 2016 10:23:22 -0800
Message-ID: <20161129182322.13445.54080.stgit@localhost.localdomain>
References: <20161129182010.13445.31256.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
 jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161129182010.13445.31256.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch does two things.

First it goes through and renames the __page_frag prefixed functions to
__page_frag_cache so that we can be clear that we are draining or refilling
the cache, not the frags themselves.

Second we drop the order parameter from __page_frag_cache_drain since we
don't actually need to pass it since all fragments are either order 0 or
must be a compound page.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
 include/linux/gfp.h                       |    3 +--
 mm/page_alloc.c                           |   13 +++++++------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 5e66cdeb7ee3..7363503eab80 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3962,8 +3962,8 @@ static void igb_clean_rx_ring(struct igb_ring *rx_ring)
 				     PAGE_SIZE,
 				     DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__page_frag_drain(buffer_info->page, 0,
-				  buffer_info->pagecnt_bias);
+		__page_frag_cache_drain(buffer_info->page,
+					buffer_info->pagecnt_bias);
 
 		buffer_info->page = NULL;
 	}
@@ -6987,7 +6987,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma,
 				     PAGE_SIZE, DMA_FROM_DEVICE,
 				     DMA_ATTR_SKIP_CPU_SYNC);
-		__page_frag_drain(page, 0, rx_buffer->pagecnt_bias);
+		__page_frag_cache_drain(page, rx_buffer->pagecnt_bias);
 	}
 
 	/* clear contents of rx_buffer */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 6238c74e0a01..884080404e24 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -506,8 +506,7 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
-extern void __page_frag_drain(struct page *page, unsigned int order,
-			      unsigned int count);
+extern void __page_frag_cache_drain(struct page *page, unsigned int count);
 extern void *page_frag_alloc(struct page_frag_cache *nc,
 			     unsigned int fragsz, gfp_t gfp_mask);
 extern void page_frag_free(void *addr);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4218795a4694..9559f52e740d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3896,8 +3896,8 @@ void free_pages(unsigned long addr, unsigned int order)
  * drivers to provide a backing region of memory for use as either an
  * sk_buff->head, or to be used in the "frags" portion of skb_shared_info.
  */
-static struct page *__page_frag_refill(struct page_frag_cache *nc,
-				       gfp_t gfp_mask)
+static struct page *__page_frag_cache_refill(struct page_frag_cache *nc,
+					     gfp_t gfp_mask)
 {
 	struct page *page = NULL;
 	gfp_t gfp = gfp_mask;
@@ -3917,19 +3917,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
 	return page;
 }
 
-void __page_frag_drain(struct page *page, unsigned int order,
-		       unsigned int count)
+void __page_frag_cache_drain(struct page *page, unsigned int count)
 {
 	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
 
 	if (page_ref_sub_and_test(page, count)) {
+		unsigned int order = compound_order(page);
+
 		if (order == 0)
 			free_hot_cold_page(page, false);
 		else
 			__free_pages_ok(page, order);
 	}
 }
-EXPORT_SYMBOL(__page_frag_drain);
+EXPORT_SYMBOL(__page_frag_cache_drain);
 
 void *page_frag_alloc(struct page_frag_cache *nc,
 		      unsigned int fragsz, gfp_t gfp_mask)
@@ -3940,7 +3941,7 @@ void *page_frag_alloc(struct page_frag_cache *nc,
 
 	if (unlikely(!nc->va)) {
 refill:
-		page = __page_frag_refill(nc, gfp_mask);
+		page = __page_frag_cache_refill(nc, gfp_mask);
 		if (!page)
 			return NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
