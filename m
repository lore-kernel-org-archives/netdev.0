From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] ixgbe: Add function for checking to see if we can reuse page
Date: Thu, 16 Feb 2017 04:50:31 -0800
Message-ID: <20170216125041.46668-5-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7261 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753285AbdBPMuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:46 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch consolidates the code for the ixgbe driver so that it is more
inline with what is already in igb.  The general idea is to just
consolidate functions that represent logical steps in the Rx process so we
can later update them more easily.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 71 ++++++++++++++++-----------
 1 file changed, 42 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c1e14a2608ef..a19dda5711ae 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1930,6 +1930,42 @@ static inline bool ixgbe_page_is_reserved(struct page *page)
 	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
+static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
+				    struct ixgbe_rx_buffer *rx_buffer,
+				    struct page *page,
+				    const unsigned int truesize)
+{
+#if (PAGE_SIZE >= 8192)
+	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
+				   ixgbe_rx_bufsz(rx_ring);
+#endif
+	/* avoid re-using remote pages */
+	if (unlikely(ixgbe_page_is_reserved(page)))
+		return false;
+
+#if (PAGE_SIZE < 8192)
+	/* if we are only owner of page we can reuse it */
+	if (unlikely(page_count(page) != 1))
+		return false;
+
+	/* flip page offset to other buffer */
+	rx_buffer->page_offset ^= truesize;
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
+
+	if (rx_buffer->page_offset > last_offset)
+		return false;
+#endif
+
+	/* Even if we own the page, we are not allowed to use atomic_set()
+	 * This would break get_page_unless_zero() users.
+	 */
+	page_ref_inc(page);
+
+	return true;
+}
+
 /**
  * ixgbe_add_rx_frag - Add contents of Rx buffer to sk_buff
  * @rx_ring: rx descriptor ring to transact packets on
@@ -1951,18 +1987,18 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			      struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
+	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
 #else
 	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
-	unsigned int last_offset = ixgbe_rx_pg_size(rx_ring) -
-				   ixgbe_rx_bufsz(rx_ring);
 #endif
 
-	if ((size <= IXGBE_RX_HDR_SIZE) && !skb_is_nonlinear(skb)) {
-		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+	if (unlikely(skb_is_nonlinear(skb)))
+		goto add_tail_frag;
 
+	if (size <= IXGBE_RX_HDR_SIZE) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* page is not reserved, we can reuse buffer as-is */
@@ -1974,34 +2010,11 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 		return false;
 	}
 
+add_tail_frag:
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			rx_buffer->page_offset, size, truesize);
 
-	/* avoid re-using remote pages */
-	if (unlikely(ixgbe_page_is_reserved(page)))
-		return false;
-
-#if (PAGE_SIZE < 8192)
-	/* if we are only owner of page we can reuse it */
-	if (unlikely(page_count(page) != 1))
-		return false;
-
-	/* flip page offset to other buffer */
-	rx_buffer->page_offset ^= truesize;
-#else
-	/* move offset up to the next cache line */
-	rx_buffer->page_offset += truesize;
-
-	if (rx_buffer->page_offset > last_offset)
-		return false;
-#endif
-
-	/* Even if we own the page, we are not allowed to use atomic_set()
-	 * This would break get_page_unless_zero() users.
-	 */
-	page_ref_inc(page);
-
-	return true;
+	return ixgbe_can_reuse_rx_page(rx_ring, rx_buffer, page, truesize);
 }
 
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
-- 
2.11.0
