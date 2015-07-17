From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbevf: fold ixgbevf_pull_tail into ixgbevf_add_rx_frag
Date: Fri, 17 Jul 2015 07:25:19 -0700
Message-ID: <1437143123-5031-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19033 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758090AbbGQOZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:45 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change folds the ixgbevf_pull_tail call into ixgbevf_add_rx_frag.  The
advantage to doing this is that the fragment doesn't have to be modified
after it is added to the skb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 66 +++++++----------------
 1 file changed, 19 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index e71cdde..acfa051 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -649,46 +649,6 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
 }
 
 /**
- * ixgbevf_pull_tail - ixgbevf specific version of skb_pull_tail
- * @rx_ring: rx descriptor ring packet is being transacted on
- * @skb: pointer to current skb being adjusted
- *
- * This function is an ixgbevf specific version of __pskb_pull_tail.  The
- * main difference between this version and the original function is that
- * this function can make several assumptions about the state of things
- * that allow for significant optimizations versus the standard function.
- * As a result we can do things like drop a frag and maintain an accurate
- * truesize for the skb.
- **/
-static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
-			      struct sk_buff *skb)
-{
-	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
-	unsigned char *va;
-	unsigned int pull_len;
-
-	/* it is valid to use page_address instead of kmap since we are
-	 * working with pages allocated out of the lomem pool per
-	 * alloc_page(GFP_ATOMIC)
-	 */
-	va = skb_frag_address(frag);
-
-	/* we need the header to contain the greater of either ETH_HLEN or
-	 * 60 bytes if the skb->len is less than 60 for skb_pad.
-	 */
-	pull_len = eth_get_headlen(va, IXGBEVF_RX_HDR_SIZE);
-
-	/* align pull length to size of long to optimize memcpy performance */
-	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
-
-	/* update all of the pointers */
-	skb_frag_size_sub(frag, pull_len);
-	frag->page_offset += pull_len;
-	skb->data_len -= pull_len;
-	skb->tail += pull_len;
-}
-
-/**
  * ixgbevf_cleanup_headers - Correct corrupted or empty headers
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @rx_desc: pointer to the EOP Rx descriptor
@@ -721,10 +681,6 @@ static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
 		}
 	}
 
-	/* place header in linear portion of buffer */
-	if (skb_is_nonlinear(skb))
-		ixgbevf_pull_tail(rx_ring, skb);
-
 	/* if eth_skb_pad returns an error the skb was freed */
 	if (eth_skb_pad(skb))
 		return true;
@@ -789,16 +745,19 @@ static bool ixgbevf_add_rx_frag(struct ixgbevf_ring *rx_ring,
 				struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
+	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = IXGBEVF_RX_BUFSZ;
 #else
 	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
 #endif
+	unsigned int pull_len;
 
-	if ((size <= IXGBEVF_RX_HDR_SIZE) && !skb_is_nonlinear(skb)) {
-		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+	if (unlikely(skb_is_nonlinear(skb)))
+		goto add_tail_frag;
 
+	if (likely(size <= IXGBEVF_RX_HDR_SIZE)) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* page is not reserved, we can reuse buffer as is */
@@ -810,8 +769,21 @@ static bool ixgbevf_add_rx_frag(struct ixgbevf_ring *rx_ring,
 		return false;
 	}
 
+	/* we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = eth_get_headlen(va, IXGBEVF_RX_HDR_SIZE);
+
+	/* align pull length to size of long to optimize memcpy performance */
+	memcpy(__skb_put(skb, pull_len), va, ALIGN(pull_len, sizeof(long)));
+
+	/* update all of the pointers */
+	va += pull_len;
+	size -= pull_len;
+
+add_tail_frag:
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-			rx_buffer->page_offset, size, truesize);
+			(unsigned long)va & ~PAGE_MASK, size, truesize);
 
 	/* avoid re-using remote pages */
 	if (unlikely(ixgbevf_page_is_reserved(page)))
-- 
2.4.3
