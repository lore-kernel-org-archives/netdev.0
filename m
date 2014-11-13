From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 1/4] igb: Clean-up page reuse code
Date: Thu, 13 Nov 2014 08:18:19 -0800
Message-ID: <20141113161819.2790.87532.stgit@ahduyck-vm-fedora20>
References: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932998AbaKMQSg (ORCPT <rfc822;netdev@vger.kernel.org>);
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

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   35 +++++++++++++----------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1e35fae..ade207d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6529,15 +6529,17 @@ static void igb_reuse_rx_page(struct igb_ring *rx_ring,
 					 DMA_FROM_DEVICE);
 }
 
+static inline bool igb_page_is_reserved(struct page *page)
+{
+	return (page_to_nid(page) != numa_mem_id()) || page->pfmemalloc;
+}
+
 static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 				  struct page *page,
 				  unsigned int truesize)
 {
 	/* avoid re-using remote pages */
-	if (unlikely(page_to_nid(page) != numa_node_id()))
-		return false;
-
-	if (unlikely(page->pfmemalloc))
+	if (unlikely(igb_page_is_reserved(page)))
 		return false;
 
 #if (PAGE_SIZE < 8192)
@@ -6547,22 +6549,19 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
 
 	/* flip page offset to other buffer */
 	rx_buffer->page_offset ^= IGB_RX_BUFSZ;
-
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
-	 */
-	atomic_inc(&page->_count);
 #else
 	/* move offset up to the next cache line */
 	rx_buffer->page_offset += truesize;
 
 	if (rx_buffer->page_offset > (PAGE_SIZE - IGB_RX_BUFSZ))
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
 
@@ -6605,13 +6604,12 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
-		/* we can reuse buffer as-is, just make sure it is local */
-		if (likely((page_to_nid(page) == numa_node_id()) &&
-			   !page->pfmemalloc))
+		/* page is not reserved, we can reuse buffer as-is */
+		if (likely(!igb_page_is_reserved(page)))
 			return true;
 
 		/* this page cannot be reused so discard it */
-		put_page(page);
+		__free_page(page);
 		return false;
 	}
 
@@ -6629,7 +6627,6 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 	struct page *page;
 
 	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
-
 	page = rx_buffer->page;
 	prefetchw(page);
 
@@ -7050,8 +7047,8 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 			i -= rx_ring->count;
 		}
 
-		/* clear the hdr_addr for the next_to_use descriptor */
-		rx_desc->read.hdr_addr = 0;
+		/* clear the status bits for the next_to_use descriptor */
+		rx_desc->wb.upper.status_error = 0;
 
 		cleaned_count--;
 	} while (cleaned_count);
