From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 5/9] ixgbe: Make pull tail function separate from rest of cleanup_headers
Date: Thu, 16 Aug 2012 15:48:34 -0700
Message-ID: <1345157318-23731-6-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12017 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755823Ab2HPWsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:52 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change creates a separate function for functionality similar to
pskb_pull_tail.  The main motivation for moving it to a separate function
is so that later I can just skip this function in the case where we have
already copied the buffer into skb->head.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 94 ++++++++++++++++-----------
 1 file changed, 57 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b0020fc..d926973 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1458,6 +1458,61 @@ static bool ixgbe_is_non_eop(struct ixgbe_ring *rx_ring,
 }
 
 /**
+ * ixgbe_pull_tail - ixgbe specific version of skb_pull_tail
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @skb: pointer to current skb being adjusted
+ *
+ * This function is an ixgbe specific version of __pskb_pull_tail.  The
+ * main difference between this version and the original function is that
+ * this function can make several assumptions about the state of things
+ * that allow for significant optimizations versus the standard function.
+ * As a result we can do things like drop a frag and maintain an accurate
+ * truesize for the skb.
+ */
+static void ixgbe_pull_tail(struct ixgbe_ring *rx_ring,
+			    struct sk_buff *skb)
+{
+	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
+	unsigned char *va;
+	unsigned int pull_len;
+
+	/*
+	 * it is valid to use page_address instead of kmap since we are
+	 * working with pages allocated out of the lomem pool per
+	 * alloc_page(GFP_ATOMIC)
+	 */
+	va = skb_frag_address(frag);
+
+	/*
+	 * we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = skb_frag_size(frag);
+	if (pull_len > IXGBE_RX_HDR_SIZE)
+		pull_len = ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
+
+	/* align pull length to size of long to optimize memcpy performance */
+	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
+
+	/* update all of the pointers */
+	skb_frag_size_sub(frag, pull_len);
+	frag->page_offset += pull_len;
+	skb->data_len -= pull_len;
+	skb->tail += pull_len;
+
+	/*
+	 * if we sucked the frag empty then we should free it,
+	 * if there are other frags here something is screwed up in hardware
+	 */
+	if (skb_frag_size(frag) == 0) {
+		BUG_ON(skb_shinfo(skb)->nr_frags != 1);
+		skb_shinfo(skb)->nr_frags = 0;
+		__skb_frag_unref(frag);
+		skb->truesize -= ixgbe_rx_bufsz(rx_ring);
+	}
+}
+
+/**
  * ixgbe_dma_sync_frag - perform DMA sync for first frag of SKB
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @skb: pointer to current skb being updated
@@ -1509,10 +1564,7 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 				  union ixgbe_adv_rx_desc *rx_desc,
 				  struct sk_buff *skb)
 {
-	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
 	struct net_device *netdev = rx_ring->netdev;
-	unsigned char *va;
-	unsigned int pull_len;
 
 	/* verify that the packet does not have any known errors */
 	if (unlikely(ixgbe_test_staterr(rx_desc,
@@ -1522,40 +1574,8 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 		return true;
 	}
 
-	/*
-	 * it is valid to use page_address instead of kmap since we are
-	 * working with pages allocated out of the lomem pool per
-	 * alloc_page(GFP_ATOMIC)
-	 */
-	va = skb_frag_address(frag);
-
-	/*
-	 * we need the header to contain the greater of either ETH_HLEN or
-	 * 60 bytes if the skb->len is less than 60 for skb_pad.
-	 */
-	pull_len = skb_frag_size(frag);
-	if (pull_len > IXGBE_RX_HDR_SIZE)
-		pull_len = ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
-
-	/* align pull length to size of long to optimize memcpy performance */
-	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
-
-	/* update all of the pointers */
-	skb_frag_size_sub(frag, pull_len);
-	frag->page_offset += pull_len;
-	skb->data_len -= pull_len;
-	skb->tail += pull_len;
-
-	/*
-	 * if we sucked the frag empty then we should free it,
-	 * if there are other frags here something is screwed up in hardware
-	 */
-	if (skb_frag_size(frag) == 0) {
-		BUG_ON(skb_shinfo(skb)->nr_frags != 1);
-		skb_shinfo(skb)->nr_frags = 0;
-		__skb_frag_unref(frag);
-		skb->truesize -= ixgbe_rx_bufsz(rx_ring);
-	}
+	/* place header in linear portion of buffer */
+	ixgbe_pull_tail(rx_ring, skb);
 
 #ifdef IXGBE_FCOE
 	/* do not attempt to pad FCoE Frames as this will disrupt DDP */
-- 
1.7.11.2
