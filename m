From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net-next 2/2] net: stmmac: Disable flow ctrl for RX AVB queues and really enable TX AVB queues
Date: Thu, 12 Oct 2017 16:14:42 +0100
Message-ID: <bc2bb8e0f80cfa294c8b7c4fead6152f672c7401.1507820933.git.joabreu@synopsys.com>
References: <cover.1507820933.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:44674 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751963AbdJLPPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 11:15:14 -0400
In-Reply-To: <cover.1507820933.git.joabreu@synopsys.com>
In-Reply-To: <cover.1507820933.git.joabreu@synopsys.com>
References: <cover.1507820933.git.joabreu@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flow control must be disabled for AVB enabled queues and TX
AVB queues must be enabled by setting BIT(2) of TXQEN.

Correct this by passing the queue mode to DMA callbacks
and by checking in these functions wether we are in AVB
performing the necessary adjustments.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 16 +++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 21 +++++++++++++++------
 4 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index c26c8a7..e1e5ac0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -442,9 +442,9 @@ struct stmmac_dma_ops {
 	void (*dma_mode)(void __iomem *ioaddr, int txmode, int rxmode,
 			 int rxfifosz);
 	void (*dma_rx_mode)(void __iomem *ioaddr, int mode, u32 channel,
-			    int fifosz);
+			    int fifosz, u8 qmode);
 	void (*dma_tx_mode)(void __iomem *ioaddr, int mode, u32 channel,
-			    int fifosz);
+			    int fifosz, u8 qmode);
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index d74cedf..aeda3ab 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -225,6 +225,8 @@ enum power_event {
 #define MTL_CHAN_RX_DEBUG(x)		(MTL_CHANX_BASE_ADDR(x) + 0x38)
 
 #define MTL_OP_MODE_RSF			BIT(5)
+#define MTL_OP_MODE_TXQEN_MASK		GENMASK(3, 2)
+#define MTL_OP_MODE_TXQEN_AV		BIT(2)
 #define MTL_OP_MODE_TXQEN		BIT(3)
 #define MTL_OP_MODE_TSF			BIT(1)
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 898849b..572e96b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -191,7 +191,7 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt, u32 number_chan)
 }
 
 static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, int mode,
-				       u32 channel, int fifosz)
+				       u32 channel, int fifosz, u8 qmode)
 {
 	unsigned int rqs = fifosz / 256 - 1;
 	u32 mtl_rx_op, mtl_rx_int;
@@ -218,8 +218,10 @@ static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, int mode,
 	mtl_rx_op &= ~MTL_OP_MODE_RQS_MASK;
 	mtl_rx_op |= rqs << MTL_OP_MODE_RQS_SHIFT;
 
-	/* enable flow control only if each channel gets 4 KiB or more FIFO */
-	if (fifosz >= 4096) {
+	/* Enable flow control only if each channel gets 4 KiB or more FIFO and
+	 * only if channel is not an AVB channel.
+	 */
+	if ((fifosz >= 4096) && (qmode != MTL_QUEUE_AVB)) {
 		unsigned int rfd, rfa;
 
 		mtl_rx_op |= MTL_OP_MODE_EHFC;
@@ -271,7 +273,7 @@ static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, int mode,
 }
 
 static void dwmac4_dma_tx_chan_op_mode(void __iomem *ioaddr, int mode,
-				       u32 channel, int fifosz)
+				       u32 channel, int fifosz, u8 qmode)
 {
 	u32 mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
 	unsigned int tqs = fifosz / 256 - 1;
@@ -311,7 +313,11 @@ static void dwmac4_dma_tx_chan_op_mode(void __iomem *ioaddr, int mode,
 	 * reflect the available fifo size per queue (total fifo size / number
 	 * of enabled queues).
 	 */
-	mtl_tx_op |= MTL_OP_MODE_TXQEN;
+	mtl_tx_op &= ~MTL_OP_MODE_TXQEN_MASK;
+	if (mtl_tx_op != MTL_QUEUE_AVB)
+		mtl_tx_op |= MTL_OP_MODE_TXQEN;
+	else
+		mtl_tx_op |= MTL_OP_MODE_TXQEN_AV;
 	mtl_tx_op &= ~MTL_OP_MODE_TQS_MASK;
 	mtl_tx_op |= tqs << MTL_OP_MODE_TQS_SHIFT;
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index edf245b..0e1b0a3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1754,6 +1754,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 	u32 txmode = 0;
 	u32 rxmode = 0;
 	u32 chan = 0;
+	u8 qmode = 0;
 
 	if (rxfifosz == 0)
 		rxfifosz = priv->dma_cap.rx_fifo_size;
@@ -1785,13 +1786,19 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 
 	/* configure all channels */
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-		for (chan = 0; chan < rx_channels_count; chan++)
+		for (chan = 0; chan < rx_channels_count; chan++) {
+			qmode = priv->plat->rx_queues_cfg[chan].mode_to_use;
+
 			priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, chan,
-						   rxfifosz);
+						   rxfifosz, qmode);
+		}
+
+		for (chan = 0; chan < tx_channels_count; chan++) {
+			qmode = priv->plat->tx_queues_cfg[chan].mode_to_use;
 
-		for (chan = 0; chan < tx_channels_count; chan++)
 			priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, chan,
-						   txfifosz);
+						   txfifosz, qmode);
+		}
 	} else {
 		priv->hw->dma->dma_mode(priv->ioaddr, txmode, rxmode,
 					rxfifosz);
@@ -1954,6 +1961,8 @@ static void stmmac_tx_err(struct stmmac_priv *priv, u32 chan)
 static void stmmac_set_dma_operation_mode(struct stmmac_priv *priv, u32 txmode,
 					  u32 rxmode, u32 chan)
 {
+	u8 rxqmode = priv->plat->rx_queues_cfg[chan].mode_to_use;
+	u8 txqmode = priv->plat->tx_queues_cfg[chan].mode_to_use;
 	u32 rx_channels_count = priv->plat->rx_queues_to_use;
 	u32 tx_channels_count = priv->plat->tx_queues_to_use;
 	int rxfifosz = priv->plat->rx_fifo_size;
@@ -1970,9 +1979,9 @@ static void stmmac_set_dma_operation_mode(struct stmmac_priv *priv, u32 txmode,
 
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
 		priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, chan,
-					   rxfifosz);
+					   rxfifosz, rxqmode);
 		priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, chan,
-					   txfifosz);
+					   txfifosz, txqmode);
 	} else {
 		priv->hw->dma->dma_mode(priv->ioaddr, txmode, rxmode,
 					rxfifosz);
-- 
1.9.1
