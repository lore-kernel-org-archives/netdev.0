From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/6] [BNX2]: Remove the rx_offset field from
 the bnx2 structure.
Date: Fri, 16 May 2008 14:30:17 -0700
Message-ID: <1210973417.5507.19.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4225 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778AbYEPUZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:25:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Remove the rx_offset field from the bnx2 structure.

The rx_offset field is set to a constant value and initialized
only once.  By replacing all references to the rx_offset field,
we can eliminate rx_offset from the bnx2 structure.  This will
save 4 bytes for every bnx2 instance.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   19 +++++++++----------
 drivers/net/bnx2.h |    2 +-
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2589b99..2180922 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2624,7 +2624,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 
 	pci_dma_sync_single_for_device(bp->pdev,
 		pci_unmap_addr(cons_rx_buf, mapping),
-		bp->rx_offset + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
+		BNX2_RX_OFFSET + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 	bnapi->rx_prod_bseq += bp->rx_buf_use_size;
 
@@ -2662,7 +2662,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_napi *bnapi, struct sk_buff *skb,
 		return err;
 	}
 
-	skb_reserve(skb, bp->rx_offset);
+	skb_reserve(skb, BNX2_RX_OFFSET);
 	pci_unmap_single(bp->pdev, dma_addr, bp->rx_buf_use_size,
 			 PCI_DMA_FROMDEVICE);
 
@@ -2777,7 +2777,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		dma_addr = pci_unmap_addr(rx_buf, mapping);
 
 		pci_dma_sync_single_for_cpu(bp->pdev, dma_addr,
-			bp->rx_offset + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
+			BNX2_RX_OFFSET + RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 		rx_hdr = (struct l2_fhdr *) skb->data;
 		len = rx_hdr->l2_fhdr_pkt_len;
@@ -2815,7 +2815,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			}
 
 			/* aligned copy */
-			skb_copy_from_linear_data_offset(skb, bp->rx_offset - 2,
+			skb_copy_from_linear_data_offset(skb,
+							 BNX2_RX_OFFSET - 2,
 				      new_skb->data, len + 2);
 			skb_reserve(new_skb, 2);
 			skb_put(new_skb, len);
@@ -4754,7 +4755,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	u32 rx_size, rx_space, jumbo_size;
 
 	/* 8 for CRC and VLAN */
-	rx_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
+	rx_size = bp->dev->mtu + ETH_HLEN + BNX2_RX_OFFSET + 8;
 
 	rx_space = SKB_DATA_ALIGN(rx_size + BNX2_RX_ALIGN) + NET_SKB_PAD +
 		sizeof(struct skb_shared_info);
@@ -4774,14 +4775,14 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 		bp->rx_max_pg_ring = bnx2_find_max_ring(jumbo_size,
 							MAX_RX_PG_RINGS);
 		bp->rx_max_pg_ring_idx = (bp->rx_max_pg_ring * RX_DESC_CNT) - 1;
-		rx_size = RX_COPY_THRESH + bp->rx_offset;
+		rx_size = RX_COPY_THRESH + BNX2_RX_OFFSET;
 		bp->rx_copy_thresh = 0;
 	}
 
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment */
 	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
-	bp->rx_jumbo_thresh = rx_size - bp->rx_offset;
+	bp->rx_jumbo_thresh = rx_size - BNX2_RX_OFFSET;
 	bp->rx_ring_size = size;
 	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
 	bp->rx_max_ring_idx = (bp->rx_max_ring * RX_DESC_CNT) - 1;
@@ -5225,7 +5226,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	rx_skb = rx_buf->skb;
 
 	rx_hdr = (struct l2_fhdr *) rx_skb->data;
-	skb_reserve(rx_skb, bp->rx_offset);
+	skb_reserve(rx_skb, BNX2_RX_OFFSET);
 
 	pci_dma_sync_single_for_cpu(bp->pdev,
 		pci_unmap_addr(rx_buf, mapping),
@@ -7306,8 +7307,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->mac_addr[4] = (u8) (reg >> 8);
 	bp->mac_addr[5] = (u8) reg;
 
-	bp->rx_offset = sizeof(struct l2_fhdr) + 2;
-
 	bp->tx_ring_size = MAX_TX_DESC_CNT;
 	bnx2_set_rx_ring_size(bp, 255);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 1eaf5bb..142c27e 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -309,6 +309,7 @@ struct l2_fhdr {
 #endif
 };
 
+#define BNX2_RX_OFFSET		sizeof(struct l2_fhdr) + 2
 
 /*
  *  l2_context definition
@@ -6627,7 +6628,6 @@ struct bnx2 {
 	struct			vlan_group *vlgrp;
 #endif
 
-	u32			rx_offset;
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_buf_size;		/* with alignment */
 	u32			rx_copy_thresh;
-- 
1.5.5.GIT



