From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 2/3] bnx2: Add prefetches to rx path.
Date: Tue, 4 May 2010 22:21:45 -0700
Message-ID: <1273036906-29162-2-git-send-email-mchan@broadcom.com>
References: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2312 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551Ab0EEFKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 May 2010 01:10:21 -0400
In-Reply-To: <1273036906-29162-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add prefetches of the skb and the next rx descriptor to speed up rx path.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/bnx2.c |   12 +++++++++---
 drivers/net/bnx2.h |    1 +
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 6ad3184..cdee29b 100644
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
@@ -3086,7 +3088,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	while (sw_cons != hw_cons) {
 		unsigned int len, hdr_len;
 		u32 status;
-		struct sw_bd *rx_buf;
+		struct sw_bd *rx_buf, *next_rx_buf;
 		struct sk_buff *skb;
 		dma_addr_t dma_addr;
 		u16 vtag = 0;
@@ -3097,7 +3099,11 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		rx_buf = &rxr->rx_buf_ring[sw_ring_cons];
 		skb = rx_buf->skb;
+		prefetch(skb);
 
+		next_rx_buf =
+			&rxr->rx_buf_ring[RX_RING_IDX(NEXT_RX_BD(sw_cons))];
+		prefetch(next_rx_buf->desc);
 		rx_buf->skb = NULL;
 
 		dma_addr = dma_unmap_addr(rx_buf, mapping);
@@ -3106,7 +3112,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
 			PCI_DMA_FROMDEVICE);
 
-		rx_hdr = (struct l2_fhdr *) skb->data;
+		rx_hdr = rx_buf->desc;
 		len = rx_hdr->l2_fhdr_pkt_len;
 		status = rx_hdr->l2_fhdr_status;
 
@@ -5764,7 +5770,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
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


