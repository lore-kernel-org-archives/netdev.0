From: John Crispin <john@phrozen.org>
Subject: [PATCH 2/4] net-next: mediatek: add RX IRQ delay support
Date: Mon, 19 Jun 2017 15:37:04 +0200
Message-ID: <20170619133706.3415-3-john@phrozen.org>
References: <20170619133706.3415-1-john@phrozen.org>
Cc: linux-mediatek@lists.infradead.org, netdev@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: Sean Wang <sean.wang@mediatek.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57328 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750984AbdFSNhW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 09:37:22 -0400
In-Reply-To: <20170619133706.3415-1-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PDMA engine used for RX allows IRQ aggregation. The patch sets up the
corresponding registers to aggregate 4 IRQs into one. Using aggregation
reduces the load on the core handling to a quarter thus reducing IRQ
latency and increasing RX performance by around 10%.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |  4 +++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 13 ++++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 24d5f1cad7f4..92be59a1e4e7 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -1861,9 +1861,11 @@ static int mtk_hw_init(struct mtk_eth *eth)
 	/* Enable RX VLan Offloading */
 	mtk_w32(eth, 1, MTK_CDMP_EG_CTRL);
 
+	/* enable interrupt delay for RX */
+	mtk_w32(eth, MTK_PDMA_DELAY_RX_DELAY, MTK_PDMA_DELAY_INT);
+
 	/* disable delay and normal interrupt */
 	mtk_w32(eth, 0, MTK_QDMA_DELAY_INT);
-	mtk_w32(eth, 0, MTK_PDMA_DELAY_INT);
 	mtk_irq_disable(eth, MTK_QDMA_INT_MASK, ~0);
 	mtk_irq_disable(eth, MTK_PDMA_INT_MASK, ~0);
 	mtk_w32(eth, RST_GL_PSE, MTK_RST_GL);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 3c46a3b613b9..e130c3b24c4c 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -125,7 +125,14 @@
 #define MTK_PST_DRX_IDX_CFG(x)	(MTK_PST_DRX_IDX0 << (x))
 
 /* PDMA Delay Interrupt Register */
-#define MTK_PDMA_DELAY_INT	0xa0c
+#define MTK_PDMA_DELAY_INT		0xa0c
+#define MTK_PDMA_DELAY_RX_EN		BIT(15)
+#define MTK_PDMA_DELAY_RX_PINT		4
+#define MTK_PDMA_DELAY_RX_PINT_SHIFT	8
+#define MTK_PDMA_DELAY_RX_PTIME		4
+#define MTK_PDMA_DELAY_RX_DELAY		\
+	(MTK_PDMA_DELAY_RX_EN | MTK_PDMA_DELAY_RX_PTIME | \
+	(MTK_PDMA_DELAY_RX_PINT << MTK_PDMA_DELAY_RX_PINT_SHIFT))
 
 /* PDMA Interrupt Status Register */
 #define MTK_PDMA_INT_STATUS	0xa20
@@ -206,6 +213,7 @@
 
 /* QDMA Interrupt Status Register */
 #define MTK_QMTK_INT_STATUS	0x1A18
+#define MTK_RX_DONE_DLY		BIT(30)
 #define MTK_RX_DONE_INT3	BIT(19)
 #define MTK_RX_DONE_INT2	BIT(18)
 #define MTK_RX_DONE_INT1	BIT(17)
@@ -214,8 +222,7 @@
 #define MTK_TX_DONE_INT2	BIT(2)
 #define MTK_TX_DONE_INT1	BIT(1)
 #define MTK_TX_DONE_INT0	BIT(0)
-#define MTK_RX_DONE_INT		(MTK_RX_DONE_INT0 | MTK_RX_DONE_INT1 | \
-				 MTK_RX_DONE_INT2 | MTK_RX_DONE_INT3)
+#define MTK_RX_DONE_INT		MTK_RX_DONE_DLY
 #define MTK_TX_DONE_INT		(MTK_TX_DONE_INT0 | MTK_TX_DONE_INT1 | \
 				 MTK_TX_DONE_INT2 | MTK_TX_DONE_INT3)
 
-- 
2.11.0
