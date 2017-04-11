From: <sean.wang@mediatek.com>
Subject: [PATCH net-next] net: ethernet: mediatek: enhance TX path with recycling more SKBs in one poll
Date: Tue, 11 Apr 2017 16:34:27 +0800
Message-ID: <1491899667-19596-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

The patch adds the enhancement for recycling more TX completed SKBs in
one NAPI polling handler if NAPI budgets are still available and hardware
raises status bit shown for certain SKBs are aready done.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 14e1bd1..ac8f1b9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1074,10 +1074,13 @@ static int mtk_napi_tx(struct napi_struct *napi, int budget)
 	struct mtk_eth *eth = container_of(napi, struct mtk_eth, tx_napi);
 	u32 status, mask;
 	int tx_done = 0;
+	int remain_budget = budget;
 
 	mtk_handle_status_irq(eth);
+
+poll_again:
 	mtk_w32(eth, MTK_TX_DONE_INT, MTK_QMTK_INT_STATUS);
-	tx_done = mtk_poll_tx(eth, budget);
+	tx_done = mtk_poll_tx(eth, remain_budget);
 
 	if (unlikely(netif_msg_intr(eth))) {
 		status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
@@ -1087,17 +1090,19 @@ static int mtk_napi_tx(struct napi_struct *napi, int budget)
 			 tx_done, status, mask);
 	}
 
-	if (tx_done == budget)
+	if (tx_done == remain_budget)
 		return budget;
 
 	status = mtk_r32(eth, MTK_QMTK_INT_STATUS);
-	if (status & MTK_TX_DONE_INT)
-		return budget;
+	if (status & MTK_TX_DONE_INT) {
+		remain_budget -= tx_done;
+		goto poll_again;
+	}
 
 	napi_complete(napi);
 	mtk_irq_enable(eth, MTK_QDMA_INT_MASK, MTK_TX_DONE_INT);
 
-	return tx_done;
+	return tx_done + budget - remain_budget;
 }
 
 static int mtk_napi_rx(struct napi_struct *napi, int budget)
-- 
1.9.1
