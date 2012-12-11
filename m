From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 1/7] bna: Code Cleanup and Enhancements
Date: Tue, 11 Dec 2012 14:24:50 -0800
Message-ID: <1355264696-8927-2-git-send-email-rmody@brocade.com>
References: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, <David.Laight@ACULAB.COM>,
	<adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38594 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754099Ab2LKWZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 17:25:24 -0500
In-Reply-To: <1355264696-8927-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 -      Remove unnecessary prefetch
 -      Simplify checking & comparison of CQ flags
 -      Dereference & store unmap_array, unmap_cons & current unmap_array
        element only once
 -      Make structures tx_config & rx_config cache line aligned.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |   43 ++++++++++++++++++++-----------
 drivers/net/ethernet/brocade/bna/bnad.h |    4 +-
 2 files changed, 30 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index b441f33..1d29da7 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -210,7 +210,6 @@ bnad_txcmpl_process(struct bnad *bnad,
 	unmap_array = unmap_q->unmap_array;
 	unmap_cons = unmap_q->consumer_index;
 
-	prefetch(&unmap_array[unmap_cons + 1]);
 	while (wis) {
 		skb = unmap_array[unmap_cons].skb;
 
@@ -383,6 +382,20 @@ bnad_refill_rxq(struct bnad *bnad, struct bna_rcb *rcb)
 	}
 }
 
+#define flags_cksum_prot_mask (BNA_CQ_EF_IPV4 | BNA_CQ_EF_L3_CKSUM_OK | \
+					BNA_CQ_EF_IPV6 | \
+					BNA_CQ_EF_TCP | BNA_CQ_EF_UDP | \
+					BNA_CQ_EF_L4_CKSUM_OK)
+
+#define flags_tcp4 (BNA_CQ_EF_IPV4 | BNA_CQ_EF_L3_CKSUM_OK | \
+				BNA_CQ_EF_TCP | BNA_CQ_EF_L4_CKSUM_OK)
+#define flags_tcp6 (BNA_CQ_EF_IPV6 | \
+				BNA_CQ_EF_TCP | BNA_CQ_EF_L4_CKSUM_OK)
+#define flags_udp4 (BNA_CQ_EF_IPV4 | BNA_CQ_EF_L3_CKSUM_OK | \
+				BNA_CQ_EF_UDP | BNA_CQ_EF_L4_CKSUM_OK)
+#define flags_udp6 (BNA_CQ_EF_IPV6 | \
+				BNA_CQ_EF_UDP | BNA_CQ_EF_L4_CKSUM_OK)
+
 static u32
 bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 {
@@ -390,15 +403,12 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct bna_rcb *rcb = NULL;
 	unsigned int wi_range, packets = 0, wis = 0;
 	struct bnad_unmap_q *unmap_q;
-	struct bnad_skb_unmap *unmap_array;
+	struct bnad_skb_unmap *unmap_array, *curr_ua;
 	struct sk_buff *skb;
-	u32 flags, unmap_cons;
+	u32 flags, unmap_cons, masked_flags;
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
 	struct bnad_rx_ctrl *rx_ctrl = (struct bnad_rx_ctrl *)(ccb->ctrl);
 
-	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))
-		return 0;
-
 	prefetch(bnad->netdev);
 	BNA_CQ_QPGE_PTR_GET(ccb->producer_index, ccb->sw_qpt, cmpl,
 			    wi_range);
@@ -416,12 +426,13 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		unmap_array = unmap_q->unmap_array;
 		unmap_cons = unmap_q->consumer_index;
 
-		skb = unmap_array[unmap_cons].skb;
+		curr_ua = &unmap_array[unmap_cons];
+
+		skb = curr_ua->skb;
 		BUG_ON(!(skb));
-		unmap_array[unmap_cons].skb = NULL;
+		curr_ua->skb = NULL;
 		dma_unmap_single(&bnad->pcidev->dev,
-				 dma_unmap_addr(&unmap_array[unmap_cons],
-						dma_addr),
+				 dma_unmap_addr(curr_ua, dma_addr),
 				 rcb->rxq->buffer_size,
 				 DMA_FROM_DEVICE);
 		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
@@ -452,13 +463,15 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		}
 
 		skb_put(skb, ntohs(cmpl->length));
+
+		masked_flags = flags & flags_cksum_prot_mask;
+
 		if (likely
 		    ((bnad->netdev->features & NETIF_F_RXCSUM) &&
-		     (((flags & BNA_CQ_EF_IPV4) &&
-		      (flags & BNA_CQ_EF_L3_CKSUM_OK)) ||
-		      (flags & BNA_CQ_EF_IPV6)) &&
-		      (flags & (BNA_CQ_EF_TCP | BNA_CQ_EF_UDP)) &&
-		      (flags & BNA_CQ_EF_L4_CKSUM_OK)))
+		     ((masked_flags == flags_tcp4) ||
+		      (masked_flags == flags_udp4) ||
+		      (masked_flags == flags_tcp6) ||
+		      (masked_flags == flags_udp6))))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
 			skb_checksum_none_assert(skb);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index d783392..65fe74e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -284,8 +284,8 @@ struct bnad {
 	u8			tx_coalescing_timeo;
 	u8			rx_coalescing_timeo;
 
-	struct bna_rx_config rx_config[BNAD_MAX_RX];
-	struct bna_tx_config tx_config[BNAD_MAX_TX];
+	struct bna_rx_config rx_config[BNAD_MAX_RX]____cacheline_aligned;
+	struct bna_tx_config tx_config[BNAD_MAX_TX]____cacheline_aligned;
 
 	void __iomem		*bar0;	/* BAR0 address */
 
-- 
1.7.1
