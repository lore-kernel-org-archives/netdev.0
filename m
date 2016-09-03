From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v5 2/2] net: ethernet: mediatek: enhance RX path by aggregating more SKBs into NAPI
Date: Sat, 3 Sep 2016 17:59:27 +0800
Message-ID: <1472896767-18352-3-git-send-email-sean.wang@mediatek.com>
References: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:8427 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751953AbcICJ7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 05:59:39 -0400
In-Reply-To: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

The patch adds support for aggregating more SKBs feed into NAPI in
order to get more benefits from generic receive offload (GRO) by
peeking at the RX ring status and moving more packets right before
returning from NAPI RX polling handler if NAPI budgets are still
available and some packets already present in hardware.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 31 ++++++++++++++++-------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index a1bdb53..66fd45a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -893,14 +893,14 @@ release_desc:
 
 		done++;
 	}
-	/* make sure that all changes to the dma ring are flushed before
-	 * we continue
-	 */
-	wmb();
-	mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
 
-	if (done < budget)
-		mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
+	if (done) {
+		/* make sure that all changes to the dma ring are flushed before
+		 * we continue
+		 */
+		wmb();
+		mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
+	}
 
 	return done;
 }
@@ -1020,10 +1020,13 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
 	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
 	u32 status, mask;
 	int rx_done = 0;
+	int remain_budget = budget;
 
 	mtk_handle_status_irq(eth);
+
+poll_again:
 	mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
-	rx_done = mtk_poll_rx(napi, budget, eth);
+	rx_done = mtk_poll_rx(napi, remain_budget, eth);
 
 	if (unlikely(netif_msg_intr(eth))) {
 		status = mtk_r32(eth, MTK_PDMA_INT_STATUS);
@@ -1032,18 +1035,18 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
 			 "done rx %d, intr 0x%08x/0x%x\n",
 			 rx_done, status, mask);
 	}
-
-	if (rx_done == budget)
+	if (rx_done == remain_budget)
 		return budget;
 
 	status = mtk_r32(eth, MTK_PDMA_INT_STATUS);
-	if (status & MTK_RX_DONE_INT)
-		return budget;
-
+	if (status & MTK_RX_DONE_INT) {
+		remain_budget -= rx_done;
+		goto poll_again;
+	}
 	napi_complete(napi);
 	mtk_irq_enable(eth, MTK_PDMA_INT_MASK, MTK_RX_DONE_INT);
 
-	return rx_done;
+	return rx_done + budget - remain_budget;
 }
 
 static int mtk_tx_alloc(struct mtk_eth *eth)
-- 
1.9.1
