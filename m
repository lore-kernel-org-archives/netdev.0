From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 01/11] net: stmmac: prepare dma op mode config for multiple queues
Date: Mon, 13 Mar 2017 16:12:32 +0000
Message-ID: <c6a295d3704a939bf700304a6c5516bcdd921899.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:33702 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754041AbdCMQMz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:12:55 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares DMA Operation Mode configuration for multiple queues.
The work consisted on breaking the DMA operation Mode configuration function
into RX and TX scope and adapting its mechanism in stmmac_main.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |   3 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 118 +++++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  84 +++++++++++----
 3 files changed, 125 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 9f0d26d..13bd3d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -424,6 +424,9 @@ struct stmmac_dma_ops {
 	 * An invalid value enables the store-and-forward mode */
 	void (*dma_mode)(void __iomem *ioaddr, int txmode, int rxmode,
 			 int rxfifosz);
+	void (*dma_rx_mode)(void __iomem *ioaddr, int mode, u32 channel,
+			    int fifosz);
+	void (*dma_tx_mode)(void __iomem *ioaddr, int mode, u32 channel);
 	/* To track extra statistic (if supported) */
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 6ac6b26..6285e8a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -182,70 +182,26 @@ static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
 		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(i));
 }
 
-static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
-				    int rxmode, u32 channel, int rxfifosz)
+static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, int mode,
+				       u32 channel, int fifosz)
 {
-	unsigned int rqs = rxfifosz / 256 - 1;
-	u32 mtl_tx_op, mtl_rx_op, mtl_rx_int;
-
-	/* Following code only done for channel 0, other channels not yet
-	 * supported.
-	 */
-	mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
-
-	if (txmode == SF_DMA_MODE) {
-		pr_debug("GMAC: enable TX store and forward mode\n");
-		/* Transmit COE type 2 cannot be done in cut-through mode. */
-		mtl_tx_op |= MTL_OP_MODE_TSF;
-	} else {
-		pr_debug("GMAC: disabling TX SF (threshold %d)\n", txmode);
-		mtl_tx_op &= ~MTL_OP_MODE_TSF;
-		mtl_tx_op &= MTL_OP_MODE_TTC_MASK;
-		/* Set the transmit threshold */
-		if (txmode <= 32)
-			mtl_tx_op |= MTL_OP_MODE_TTC_32;
-		else if (txmode <= 64)
-			mtl_tx_op |= MTL_OP_MODE_TTC_64;
-		else if (txmode <= 96)
-			mtl_tx_op |= MTL_OP_MODE_TTC_96;
-		else if (txmode <= 128)
-			mtl_tx_op |= MTL_OP_MODE_TTC_128;
-		else if (txmode <= 192)
-			mtl_tx_op |= MTL_OP_MODE_TTC_192;
-		else if (txmode <= 256)
-			mtl_tx_op |= MTL_OP_MODE_TTC_256;
-		else if (txmode <= 384)
-			mtl_tx_op |= MTL_OP_MODE_TTC_384;
-		else
-			mtl_tx_op |= MTL_OP_MODE_TTC_512;
-	}
-	/* For an IP with DWC_EQOS_NUM_TXQ == 1, the fields TXQEN and TQS are RO
-	 * with reset values: TXQEN on, TQS == DWC_EQOS_TXFIFO_SIZE.
-	 * For an IP with DWC_EQOS_NUM_TXQ > 1, the fields TXQEN and TQS are R/W
-	 * with reset values: TXQEN off, TQS 256 bytes.
-	 *
-	 * Write the bits in both cases, since it will have no effect when RO.
-	 * For DWC_EQOS_NUM_TXQ > 1, the top bits in MTL_OP_MODE_TQS_MASK might
-	 * be RO, however, writing the whole TQS field will result in a value
-	 * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
-	 */
-	mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;
-	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
+	unsigned int rqs = fifosz / 256 - 1;
+	u32 mtl_rx_op, mtl_rx_int;
 
 	mtl_rx_op = readl(ioaddr + MTL_CHAN_RX_OP_MODE(channel));
 
-	if (rxmode == SF_DMA_MODE) {
+	if (mode == SF_DMA_MODE) {
 		pr_debug("GMAC: enable RX store and forward mode\n");
 		mtl_rx_op |= MTL_OP_MODE_RSF;
 	} else {
-		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", rxmode);
+		pr_debug("GMAC: disable RX SF mode (threshold %d)\n", mode);
 		mtl_rx_op &= ~MTL_OP_MODE_RSF;
 		mtl_rx_op &= MTL_OP_MODE_RTC_MASK;
-		if (rxmode <= 32)
+		if (mode <= 32)
 			mtl_rx_op |= MTL_OP_MODE_RTC_32;
-		else if (rxmode <= 64)
+		else if (mode <= 64)
 			mtl_rx_op |= MTL_OP_MODE_RTC_64;
-		else if (rxmode <= 96)
+		else if (mode <= 96)
 			mtl_rx_op |= MTL_OP_MODE_RTC_96;
 		else
 			mtl_rx_op |= MTL_OP_MODE_RTC_128;
@@ -255,7 +211,7 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	mtl_rx_op |= rqs << MTL_OP_MODE_RQS_SHIFT;
 
 	/* enable flow control only if each channel gets 4 KiB or more FIFO */
-	if (rxfifosz >= 4096) {
+	if (fifosz >= 4096) {
 		unsigned int rfd, rfa;
 
 		mtl_rx_op |= MTL_OP_MODE_EHFC;
@@ -266,7 +222,7 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 		 * Set Threshold for Deactivating Flow Control to min 1 frame,
 		 * i.e. 1500 bytes.
 		 */
-		switch (rxfifosz) {
+		switch (fifosz) {
 		case 4096:
 			/* This violates the above formula because of FIFO size
 			 * limit therefore overflow may occur in spite of this.
@@ -306,11 +262,49 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
 	       ioaddr + MTL_CHAN_INT_CTRL(channel));
 }
 
-static void dwmac4_dma_operation_mode(void __iomem *ioaddr, int txmode,
-				      int rxmode, int rxfifosz)
+static void dwmac4_dma_tx_chan_op_mode(void __iomem *ioaddr, int mode,
+				       u32 channel)
 {
-	/* Only Channel 0 is actually configured and used */
-	dwmac4_dma_chan_op_mode(ioaddr, txmode, rxmode, 0, rxfifosz);
+	u32 mtl_tx_op = readl(ioaddr + MTL_CHAN_TX_OP_MODE(channel));
+
+	if (mode == SF_DMA_MODE) {
+		pr_debug("GMAC: enable TX store and forward mode\n");
+		/* Transmit COE type 2 cannot be done in cut-through mode. */
+		mtl_tx_op |= MTL_OP_MODE_TSF;
+	} else {
+		pr_debug("GMAC: disabling TX SF (threshold %d)\n", mode);
+		mtl_tx_op &= ~MTL_OP_MODE_TSF;
+		mtl_tx_op &= MTL_OP_MODE_TTC_MASK;
+		/* Set the transmit threshold */
+		if (mode <= 32)
+			mtl_tx_op |= MTL_OP_MODE_TTC_32;
+		else if (mode <= 64)
+			mtl_tx_op |= MTL_OP_MODE_TTC_64;
+		else if (mode <= 96)
+			mtl_tx_op |= MTL_OP_MODE_TTC_96;
+		else if (mode <= 128)
+			mtl_tx_op |= MTL_OP_MODE_TTC_128;
+		else if (mode <= 192)
+			mtl_tx_op |= MTL_OP_MODE_TTC_192;
+		else if (mode <= 256)
+			mtl_tx_op |= MTL_OP_MODE_TTC_256;
+		else if (mode <= 384)
+			mtl_tx_op |= MTL_OP_MODE_TTC_384;
+		else
+			mtl_tx_op |= MTL_OP_MODE_TTC_512;
+	}
+	/* For an IP with DWC_EQOS_NUM_TXQ == 1, the fields TXQEN and TQS are RO
+	 * with reset values: TXQEN on, TQS == DWC_EQOS_TXFIFO_SIZE.
+	 * For an IP with DWC_EQOS_NUM_TXQ > 1, the fields TXQEN and TQS are R/W
+	 * with reset values: TXQEN off, TQS 256 bytes.
+	 *
+	 * Write the bits in both cases, since it will have no effect when RO.
+	 * For DWC_EQOS_NUM_TXQ > 1, the top bits in MTL_OP_MODE_TQS_MASK might
+	 * be RO, however, writing the whole TQS field will result in a value
+	 * equal to DWC_EQOS_TXFIFO_SIZE, just like for DWC_EQOS_NUM_TXQ == 1.
+	 */
+	mtl_tx_op |= MTL_OP_MODE_TXQEN | MTL_OP_MODE_TQS_MASK;
+	writel(mtl_tx_op, ioaddr +  MTL_CHAN_TX_OP_MODE(channel));
 }
 
 static void dwmac4_get_hw_feature(void __iomem *ioaddr,
@@ -387,7 +381,8 @@ const struct stmmac_dma_ops dwmac4_dma_ops = {
 	.init = dwmac4_dma_init,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
+	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
+	.dma_tx_mode = dwmac4_dma_tx_chan_op_mode,
 	.enable_dma_irq = dwmac4_enable_dma_irq,
 	.disable_dma_irq = dwmac4_disable_dma_irq,
 	.start_tx = dwmac4_dma_start_tx,
@@ -409,7 +404,8 @@ const struct stmmac_dma_ops dwmac410_dma_ops = {
 	.init = dwmac4_dma_init,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
-	.dma_mode = dwmac4_dma_operation_mode,
+	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
+	.dma_tx_mode = dwmac4_dma_tx_chan_op_mode,
 	.enable_dma_irq = dwmac410_enable_dma_irq,
 	.disable_dma_irq = dwmac4_disable_dma_irq,
 	.start_tx = dwmac4_dma_start_tx,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ec363e1..660eef0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1285,14 +1285,20 @@ static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
  */
 static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 {
+	u32 rx_channels_count = priv->plat->rx_queues_to_use;
+	u32 tx_channels_count = priv->plat->tx_queues_to_use;
 	int rxfifosz = priv->plat->rx_fifo_size;
+	u32 txmode = 0;
+	u32 rxmode = 0;
+	u32 chan = 0;
 
 	if (rxfifosz == 0)
 		rxfifosz = priv->dma_cap.rx_fifo_size;
 
-	if (priv->plat->force_thresh_dma_mode)
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
-	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
+	if (priv->plat->force_thresh_dma_mode) {
+		txmode = tc;
+		rxmode = tc;
+	} else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
 		/*
 		 * In case of GMAC, SF mode can be enabled
 		 * to perform the TX COE in HW. This depends on:
@@ -1300,12 +1306,26 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 		 * 2) There is no bugged Jumbo frame support
 		 *    that needs to not insert csum in the TDES.
 		 */
-		priv->hw->dma->dma_mode(priv->ioaddr, SF_DMA_MODE, SF_DMA_MODE,
-					rxfifosz);
-		priv->xstats.threshold = SF_DMA_MODE;
-	} else
-		priv->hw->dma->dma_mode(priv->ioaddr, tc, SF_DMA_MODE,
+		txmode = SF_DMA_MODE;
+		rxmode = SF_DMA_MODE;
+		priv->xstats.threshold = SF_DMA_MODE;
+	} else {
+		txmode = tc;
+		rxmode = SF_DMA_MODE;
+	}
+
+	/* configure all channels */
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		for (chan = 0; chan < rx_channels_count; chan++)
+			priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, chan,
+						   rxfifosz);
+
+		for (chan = 0; chan < tx_channels_count; chan++)
+			priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, chan);
+	} else {
+		priv->hw->dma->dma_mode(priv->ioaddr, txmode, rxmode,
 					rxfifosz);
+	}
 }
 
 /**
@@ -1444,6 +1464,34 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 }
 
 /**
+ *  stmmac_set_dma_operation_mode - Set DMA operation mode by channel
+ *  @priv: driver private structure
+ *  @txmode: TX operating mode
+ *  @rxmode: RX operating mode
+ *  @chan: channel index
+ *  Description: it is used for configuring of the DMA operation mode in
+ *  runtime in order to program the tx/rx DMA thresholds or Store-And-Forward
+ *  mode.
+ */
+static void stmmac_set_dma_operation_mode(struct stmmac_priv *priv, u32 txmode,
+					  u32 rxmode, u32 chan)
+{
+	int rxfifosz = priv->plat->rx_fifo_size;
+
+	if (rxfifosz == 0)
+		rxfifosz = priv->dma_cap.rx_fifo_size;
+
+	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
+		priv->hw->dma->dma_rx_mode(priv->ioaddr, rxmode, chan,
+					   rxfifosz);
+		priv->hw->dma->dma_tx_mode(priv->ioaddr, txmode, chan);
+	} else {
+		priv->hw->dma->dma_mode(priv->ioaddr, txmode, rxmode,
+					rxfifosz);
+	}
+}
+
+/**
  * stmmac_dma_interrupt - DMA ISR
  * @priv: driver private structure
  * Description: this is the DMA ISR. It is called by the main ISR.
@@ -1452,11 +1500,8 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
  */
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
+	u32 chan = STMMAC_CHAN0;
 	int status;
-	int rxfifosz = priv->plat->rx_fifo_size;
-
-	if (rxfifosz == 0)
-		rxfifosz = priv->dma_cap.rx_fifo_size;
 
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely((status & handle_rx)) || (status & handle_tx)) {
@@ -1471,11 +1516,12 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		    (tc <= 256)) {
 			tc += 64;
 			if (priv->plat->force_thresh_dma_mode)
-				priv->hw->dma->dma_mode(priv->ioaddr, tc, tc,
-							rxfifosz);
+				stmmac_set_dma_operation_mode(priv->ioaddr,
+							      tc, tc, chan);
 			else
-				priv->hw->dma->dma_mode(priv->ioaddr, tc,
-							SF_DMA_MODE, rxfifosz);
+				stmmac_set_dma_operation_mode(priv->ioaddr, tc,
+							     SF_DMA_MODE, chan);
+
 			priv->xstats.threshold = tc;
 		}
 	} else if (unlikely(status == tx_hard_error))
@@ -1749,6 +1795,9 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 	/* Enable MAC RX Queues */
 	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
 		stmmac_mac_enable_rx_queues(priv);
+
+	/* Set the HW DMA mode and the COE */
+	stmmac_dma_operation_mode(priv);
 }
 
 /**
@@ -1812,9 +1861,6 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	else
 		stmmac_set_mac(priv->ioaddr, true);
 
-	/* Set the HW DMA mode and the COE */
-	stmmac_dma_operation_mode(priv);
-
 	stmmac_mmc_setup(priv);
 
 	if (init_ptp) {
-- 
2.9.3
