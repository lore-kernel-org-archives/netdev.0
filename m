From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 2/3 v2] bnx2: Add prefetches to rx path.
Date: Thu, 6 May 2010 11:58:13 -0700
Message-ID: <1273172293-10241-2-git-send-email-mchan@broadcom.com>
References: <1273172293-10241-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1993 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754959Ab0EFSqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 14:46:48 -0400
In-Reply-To: <1273172293-10241-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add prefetches of the skb and the next rx descriptor to speed up rx path.

Use prefetchw() for the skb [suggested by Eric Dumazet].

The rx descriptor is in skb->data which is mapped for streaming mode DMA.
Eric Dumazet pointed out that we should not prefetch the data before
dma_sync.  So we prefetch only if dma_sync is no_op on the system.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   16 +++++++++++++---
 drivers/net/bnx2.h |    1 +
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 320526b..667f419 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2719,6 +2719,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
 	}
 
 	rx_buf->skb = skb;
+	rx_buf->desc = (struct l2_fhdr *) skb->data;
 	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
@@ -2941,6 +2942,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 	rxr->rx_prod_bseq += bp->rx_buf_use_size;
 
 	prod_rx_buf->skb = skb;
+	prod_rx_buf->desc = (struct l2_fhdr *) skb->data;
 
 	if (cons == prod)
 		return;
@@ -3074,6 +3076,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	u16 hw_cons, sw_cons, sw_ring_cons, sw_prod, sw_ring_prod;
 	struct l2_fhdr *rx_hdr;
 	int rx_pkt = 0, pg_ring_used = 0;
+	struct pci_dev *pdev = bp->pdev;
 
 	hw_cons = bnx2_get_hw_rx_cons(bnapi);
 	sw_cons = rxr->rx_cons;
@@ -3086,7 +3089,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	while (sw_cons != hw_cons) {
 		unsigned int len, hdr_len;
 		u32 status;
-		struct sw_bd *rx_buf;
+		struct sw_bd *rx_buf, *next_rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u16 vtag = 0;
@@ -3097,7 +3100,14 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
 		skb = rx_buf->skb;
+		prefetchw(skb);
 
+		if (!get_dma_ops(&pdev->dev)->sync_single_for_cpu) {
+			next_rx_buf =
+				&rxr->rx_buf_ring[
+					RX_RING_IDX(NEXT_RX_BD(sw_cons))];
+			prefetch(next_rx_buf->desc);
+		}
 		rx_buf->skb = NULL;
 
 		dma_addr = dma_unmap_addr(rx_buf, mapping);
@@ -3106,7 +3116,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
 			PCI_DMA_FROMDEVICE);
 
-		rx_hdr = (struct l2_fhdr *) skb->data;
+		rx_hdr = rx_buf->desc;
 		len = rx_hdr->l2_fhdr_pkt_len;
 		status = rx_hdr->l2_fhdr_status;
 
@@ -5764,7 +5774,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	rx_buf = &rxr->rx_buf_ring[rx_start_idx];
 	rx_skb = rx_buf->skb;
 
-	rx_hdr = (struct l2_fhdr *) rx_skb->data;
+	rx_hdr = rx_buf->desc;
 	skb_reserve(rx_skb, BNX2_RX_OFFSET);
 
 	pci_dma_sync_single_for_cpu(bp->pdev,
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ab34a5d..dd35bd0 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6551,6 +6551,7 @@ struct l2_fhdr {
 
 struct sw_bd {
 	struct sk_buff		*skb;
+	struct l2_fhdr		*desc;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
-- 
1.6.4.GIT


