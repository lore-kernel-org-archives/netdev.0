From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [next PATCH 01/11] ixgbe: Add function for checking to see if we
 can reuse page
Date: Fri, 06 Jan 2017 08:06:33 -0800
Message-ID: <20170106160622.1501.56085.stgit@localhost.localdomain>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33511 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966902AbdAFQGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:06:45 -0500
Received: by mail-pg0-f68.google.com with SMTP id g1so44418300pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:06:35 -0800 (PST)
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch consolidates the code for the ixgbe driver so that it is more
inline with what is already in igb.  The general idea is to just
consolidate functions that represent logical steps in the Rx process so we
can later update them more easily.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   70 +++++++++++++++----------
 1 file changed, 41 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3beadc8c7a0a..e80d885af4d3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1947,6 +1947,41 @@ static inline bool ixgbe_page_is_reserved(struct page *page)
 	return (page_to_nid(page) != numa_mem_id()) || page_is_pfmemalloc(page);
 }
 
+static bool ixgbe_can_reuse_rx_page(struct ixgbe_rx_buffer *rx_buffer,
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
@@ -1968,18 +2003,18 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
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
@@ -1991,34 +2026,11 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
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
+	return ixgbe_can_reuse_rx_page(rx_buffer, page, truesize);
 }
 
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
