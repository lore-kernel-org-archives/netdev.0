From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 08/25] bnx2x: Memory allocation
Date: Wed, 13 Aug 2008 17:13:47 +0300
Message-ID: <1218636827.547.84.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1047 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753502AbYHMOOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory allocation
- The CQE ring was allocated to the max size even for a chip that does 
  not support it. Fixed to allocate according to the chip type to save 
  memory
- The rx_page_ring was not freed on driver unload

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c8b6178..b8cdce2 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4252,7 +4252,9 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 static void bnx2x_init_rx_rings(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
-	u16 ring_prod, cqe_ring_prod = 0;
+	int max_agg_queues = CHIP_IS_E1(bp) ? ETH_MAX_AGGREGATION_QUEUES_E1 :
+					      ETH_MAX_AGGREGATION_QUEUES_E1H;
+	u16 ring_prod, cqe_ring_prod;
 	int i, j;
 
 	bp->rx_buf_use_size = bp->dev->mtu;
@@ -4266,9 +4268,9 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 		   bp->dev->mtu + ETH_OVREHEAD);
 
 		for_each_queue(bp, j) {
-			for (i = 0; i < ETH_MAX_AGGREGATION_QUEUES_E1H; i++) {
-				struct bnx2x_fastpath *fp = &bp->fp[j];
+			struct bnx2x_fastpath *fp = &bp->fp[j];
 
+			for (i = 0; i < max_agg_queues; i++) {
 				fp->tpa_pool[i].skb =
 				   netdev_alloc_skb(bp->dev, bp->rx_buf_size);
 				if (!fp->tpa_pool[i].skb) {
@@ -4348,8 +4350,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 				BNX2X_ERR("disabling TPA for queue[%d]\n", j);
 				/* Cleanup already allocated elements */
 				bnx2x_free_rx_sge_range(bp, fp, ring_prod);
-				bnx2x_free_tpa_pool(bp, fp,
-					      ETH_MAX_AGGREGATION_QUEUES_E1H);
+				bnx2x_free_tpa_pool(bp, fp, max_agg_queues);
 				fp->disable_tpa = 1;
 				ring_prod = 0;
 				break;
@@ -5772,6 +5773,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 			       NUM_RCQ_BD);
 
 		/* SGE ring */
+		BNX2X_FREE(bnx2x_fp(bp, i, rx_page_ring));
 		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_sge_ring),
 			       bnx2x_fp(bp, i, rx_sge_mapping),
 			       BCM_PAGE_SIZE * NUM_RX_SGE_PAGES);
@@ -5949,7 +5951,8 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 			dev_kfree_skb(skb);
 		}
 		if (!fp->disable_tpa)
-			bnx2x_free_tpa_pool(bp, fp,
+			bnx2x_free_tpa_pool(bp, fp, CHIP_IS_E1(bp) ?
+					    ETH_MAX_AGGREGATION_QUEUES_E1 :
 					    ETH_MAX_AGGREGATION_QUEUES_E1H);
 	}
 }
-- 
1.5.3.2




