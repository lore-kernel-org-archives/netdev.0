From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/8][BNX2]: Restructure RX fast path handling.
Date: Wed, 12 Dec 2007 10:58:43 -0800
Message-ID: <1197485923.16386.27.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2299 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbXLLSOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:14:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Restructure RX fast path handling.

Add a new function to handle new SKB allocation and to prepare the
completed SKB.  This makes it easier to add support for non-linear
SKB.
 
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index dfe50c2..14119fb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2379,6 +2379,27 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct sk_buff *skb,
 	prod_bd->rx_bd_haddr_lo = cons_bd->rx_bd_haddr_lo;
 }
 
+static int
+bnx2_rx_skb(struct bnx2 *bp, struct sk_buff *skb, unsigned int len,
+	    dma_addr_t dma_addr, u32 ring_idx)
+{
+	int err;
+	u16 prod = ring_idx & 0xffff;
+
+	err = bnx2_alloc_rx_skb(bp, prod);
+	if (unlikely(err)) {
+		bnx2_reuse_rx_skb(bp, skb, (u16) (ring_idx >> 16), prod);
+		return err;
+	}
+
+	skb_reserve(skb, bp->rx_offset);
+	pci_unmap_single(bp->pdev, dma_addr, bp->rx_buf_use_size,
+			 PCI_DMA_FROMDEVICE);
+
+	skb_put(skb, len);
+	return 0;
+}
+
 static inline u16
 bnx2_get_hw_rx_cons(struct bnx2 *bp)
 {
@@ -2434,7 +2455,8 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 			L2_FHDR_ERRORS_TOO_SHORT |
 			L2_FHDR_ERRORS_GIANT_FRAME)) {
 
-			goto reuse_rx;
+			bnx2_reuse_rx_skb(bp, skb, sw_ring_cons, sw_ring_prod);
+			goto next_rx;
 		}
 
 		/* Since we don't have a jumbo ring, copy small packets
@@ -2444,8 +2466,11 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 			struct sk_buff *new_skb;
 
 			new_skb = netdev_alloc_skb(bp->dev, len + 2);
-			if (new_skb == NULL)
-				goto reuse_rx;
+			if (new_skb == NULL) {
+				bnx2_reuse_rx_skb(bp, skb, sw_ring_cons,
+						  sw_ring_prod);
+				goto next_rx;
+			}
 
 			/* aligned copy */
 			skb_copy_from_linear_data_offset(skb, bp->rx_offset - 2,
@@ -2457,20 +2482,9 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 				sw_ring_cons, sw_ring_prod);
 
 			skb = new_skb;
-		}
-		else if (bnx2_alloc_rx_skb(bp, sw_ring_prod) == 0) {
-			pci_unmap_single(bp->pdev, dma_addr,
-				bp->rx_buf_use_size, PCI_DMA_FROMDEVICE);
-
-			skb_reserve(skb, bp->rx_offset);
-			skb_put(skb, len);
-		}
-		else {
-reuse_rx:
-			bnx2_reuse_rx_skb(bp, skb,
-				sw_ring_cons, sw_ring_prod);
+		} else if (unlikely(bnx2_rx_skb(bp, skb, len, dma_addr,
+				    (sw_ring_cons << 16) | sw_ring_prod)))
 			goto next_rx;
-		}
 
 		skb->protocol = eth_type_trans(skb, bp->dev);
 


