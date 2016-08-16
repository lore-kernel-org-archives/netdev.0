From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 2/2] net: ethernet: mediatek: enhance RX path by aggregating more SKBs into NAPI
Date: Tue, 16 Aug 2016 14:17:14 +0800
Message-ID: <1471328235-16724-3-git-send-email-sean.wang@mediatek.com>
References: <1471328235-16724-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:1351 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753160AbcHPGRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 02:17:24 -0400
In-Reply-To: <1471328235-16724-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds support for aggregating more SKBs feed into NAPI in
order to get more benefits from generic receive offload (GRO) by
peeking at the RX ring status and moving more packets right before
returning from NAPI RX polling handler if NAPI budgets are still
available.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 589ff50..d340673 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -902,9 +902,6 @@ release_desc:
 	wmb();
 	mtk_w32(eth, ring->calc_idx, MTK_QRX_CRX_IDX0);
 
-	if (done < budget)
-		mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
-
 	return done;
 }
 
@@ -1023,8 +1020,10 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
 	struct mtk_eth *eth = container_of(napi, struct mtk_eth, rx_napi);
 	u32 status, mask;
 	int rx_done = 0;
+	int remain_budget = budget;
 
 	mtk_handle_status_irq(eth);
+poll_again:
 	mtk_w32(eth, MTK_RX_DONE_INT, MTK_QMTK_INT_STATUS);
 	rx_done = mtk_poll_rx(napi, budget, eth);
 
@@ -1035,14 +1034,14 @@ static int mtk_napi_rx(struct napi_struct *napi, int budget)
 			 "done rx %d, intr 0x%08x/0x%x\n",
 			 rx_done, status, mask);
 	}
-
-	if (rx_done == budget)
+	if (rx_done == remain_budget)
 		return budget;
 
 	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
-	if (status & MTK_RX_DONE_INT)
-		return budget;
-
+	if (status & MTK_RX_DONE_INT) {
+		remain_budget -= rx_done;
+		goto poll_again;
+	}
 	napi_complete(napi);
 	mtk_irq_enable(eth, MTK_RX_DONE_INT);
 
-- 
1.7.9.5
