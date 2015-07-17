From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] igb: Pull timestamp from fragment before adding it to skb
Date: Fri, 17 Jul 2015 07:25:18 -0700
Message-ID: <1437143123-5031-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1269 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758005AbbGQOZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:37 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change makes it so that we pull the timestamp from the fragment before
we add it to the skb.  By doing this we can avoid a possible issue in which
the fragment can possibly be less than IGB_RX_HDR_LEN due to the timestamp
being pulled after the copybreak check.

While making this change I realized we could also pull the rest of the
igb_pull_tail function into igb_add_rx_frag since in the case of igb,
unlike ixgbe, we are able to unmap the entire buffer before calling
add_rx_frag so merging the two allows for sharing of code between the two
merged functions.

Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 94 ++++++++-----------------------
 1 file changed, 25 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2f70a9b..fc7729e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6621,22 +6621,25 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 			    struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
+	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = IGB_RX_BUFSZ;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
+	unsigned int pull_len;
 
-	if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb)) {
-		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+	if (unlikely(skb_is_nonlinear(skb)))
+		goto add_tail_frag;
 
-		if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
-			igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
-			va += IGB_TS_HDR_LEN;
-			size -= IGB_TS_HDR_LEN;
-		}
+	if (unlikely(igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP))) {
+		igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
+		va += IGB_TS_HDR_LEN;
+		size -= IGB_TS_HDR_LEN;
+	}
 
+	if (likely(size <= IGB_RX_HDR_LEN)) {
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* page is not reserved, we can reuse buffer as-is */
@@ -6648,8 +6651,21 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 		return false;
 	}
 
+	/* we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = eth_get_headlen(va, IGB_RX_HDR_LEN);
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
 
 	return igb_can_reuse_rx_page(rx_buffer, page, truesize);
 }
@@ -6791,62 +6807,6 @@ static bool igb_is_non_eop(struct igb_ring *rx_ring,
 }
 
 /**
- *  igb_pull_tail - igb specific version of skb_pull_tail
- *  @rx_ring: rx descriptor ring packet is being transacted on
- *  @rx_desc: pointer to the EOP Rx descriptor
- *  @skb: pointer to current skb being adjusted
- *
- *  This function is an igb specific version of __pskb_pull_tail.  The
- *  main difference between this version and the original function is that
- *  this function can make several assumptions about the state of things
- *  that allow for significant optimizations versus the standard function.
- *  As a result we can do things like drop a frag and maintain an accurate
- *  truesize for the skb.
- */
-static void igb_pull_tail(struct igb_ring *rx_ring,
-			  union e1000_adv_rx_desc *rx_desc,
-			  struct sk_buff *skb)
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
-	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
-		/* retrieve timestamp from buffer */
-		igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
-
-		/* update pointers to remove timestamp header */
-		skb_frag_size_sub(frag, IGB_TS_HDR_LEN);
-		frag->page_offset += IGB_TS_HDR_LEN;
-		skb->data_len -= IGB_TS_HDR_LEN;
-		skb->len -= IGB_TS_HDR_LEN;
-
-		/* move va to start of packet data */
-		va += IGB_TS_HDR_LEN;
-	}
-
-	/* we need the header to contain the greater of either ETH_HLEN or
-	 * 60 bytes if the skb->len is less than 60 for skb_pad.
-	 */
-	pull_len = eth_get_headlen(va, IGB_RX_HDR_LEN);
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
  *  igb_cleanup_headers - Correct corrupted or empty headers
  *  @rx_ring: rx descriptor ring packet is being transacted on
  *  @rx_desc: pointer to the EOP Rx descriptor
@@ -6873,10 +6833,6 @@ static bool igb_cleanup_headers(struct igb_ring *rx_ring,
 		}
 	}
 
-	/* place header in linear portion of buffer */
-	if (skb_is_nonlinear(skb))
-		igb_pull_tail(rx_ring, rx_desc, skb);
-
 	/* if eth_skb_pad returns an error the skb was freed */
 	if (eth_skb_pad(skb))
 		return true;
-- 
2.4.3
