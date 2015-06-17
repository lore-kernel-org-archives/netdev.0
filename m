From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/17] fm10k: fold fm10k_pull_tail into fm10k_add_rx_frag
Date: Wed, 17 Jun 2015 05:54:48 -0700
Message-ID: <1434545704-112470-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22624 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755707AbbFQMzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 08:55:07 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change folds the fm10k_pull_tail call into fm10k_add_rx_frag.  The
advantage to doing this is that the fragment doesn't have to be modified
after it is added to the skb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 66 ++++++++-------------------
 1 file changed, 20 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c754b20..982fdcd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -269,16 +269,19 @@ static bool fm10k_add_rx_frag(struct fm10k_rx_buffer *rx_buffer,
 			      struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
+	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 	unsigned int size = le16_to_cpu(rx_desc->w.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = FM10K_RX_BUFSZ;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
+	unsigned int pull_len;
 
-	if ((size <= FM10K_RX_HDR_LEN) && !skb_is_nonlinear(skb)) {
-		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+	if (unlikely(skb_is_nonlinear(skb)))
+		goto add_tail_frag;
 
+	if (likely(size <= FM10K_RX_HDR_LEN)) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* page is not reserved, we can reuse buffer as-is */
@@ -290,8 +293,21 @@ static bool fm10k_add_rx_frag(struct fm10k_rx_buffer *rx_buffer,
 		return false;
 	}
 
+	/* we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = eth_get_headlen(va, FM10K_RX_HDR_LEN);
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
 
 	return fm10k_can_reuse_rx_page(rx_buffer, page, truesize);
 }
@@ -518,44 +534,6 @@ static bool fm10k_is_non_eop(struct fm10k_ring *rx_ring,
 }
 
 /**
- * fm10k_pull_tail - fm10k specific version of skb_pull_tail
- * @skb: pointer to current skb being adjusted
- *
- * This function is an fm10k specific version of __pskb_pull_tail.  The
- * main difference between this version and the original function is that
- * this function can make several assumptions about the state of things
- * that allow for significant optimizations versus the standard function.
- * As a result we can do things like drop a frag and maintain an accurate
- * truesize for the skb.
- */
-static void fm10k_pull_tail(struct sk_buff *skb)
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
-	pull_len = eth_get_headlen(va, FM10K_RX_HDR_LEN);
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
  * fm10k_cleanup_headers - Correct corrupted or empty headers
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @rx_desc: pointer to the EOP Rx descriptor
@@ -580,10 +558,6 @@ static bool fm10k_cleanup_headers(struct fm10k_ring *rx_ring,
 		return true;
 	}
 
-	/* place header in linear portion of buffer */
-	if (skb_is_nonlinear(skb))
-		fm10k_pull_tail(skb);
-
 	/* if eth_skb_pad returns an error the skb was freed */
 	if (eth_skb_pad(skb))
 		return true;
-- 
2.4.3
