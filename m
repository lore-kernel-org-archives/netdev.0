From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v4 2/2] net: ethernet: mediatek: enhance RX path by aggregating more SKBs into NAPI
Date: Sat, 3 Sep 2016 00:56:47 +0800
Message-ID: <1472835407-17828-3-git-send-email-sean.wang@mediatek.com>
References: <1472835407-17828-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:37176 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932805AbcIBQ45 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:56:57 -0400
In-Reply-To: <1472835407-17828-1-git-send-email-sean.wang@mediatek.com>
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
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 33bb10f..44cab1b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -960,9 +960,6 @@ release_desc:
 	wmb();
 	mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
 
-	if (done < budget)
-		mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
-
 	return done;
 }
 
@@ -1081,10 +1078,13 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
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
@@ -1093,14 +1093,14 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
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
 
-- 
1.9.1
