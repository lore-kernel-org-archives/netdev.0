From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 09/11] net: stmmac: dma channel init prepared for multiple queues
Date: Tue, 14 Mar 2017 10:24:31 +0000
Message-ID: <240a92b2f39cce14b0d95da6a24d9db8ebb2d526.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:49718 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdCNKZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:25:00 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the DMA initialization process for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- dummy_dma_rx_phy was not being initialized

 drivers/net/ethernet/stmicro/stmmac/common.h      |  8 +++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 66 ++++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 51 ++++++++++++++----
 3 files changed, 88 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index bef1fc6..badc441 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -416,6 +416,14 @@ struct stmmac_dma_ops {
 	int (*reset)(void __iomem *ioaddr);
 	void (*init)(void __iomem *ioaddr, struct stmmac_dma_cfg *dma_cfg,
 		     u32 dma_tx, u32 dma_rx, int atds);
+	void (*init_chan)(void __iomem *ioaddr,
+			  struct stmmac_dma_cfg *dma_cfg, u32 chan);
+	void (*init_rx_chan)(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_rx_phy, u32 chan);
+	void (*init_tx_chan)(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_tx_phy, u32 chan);
 	/* Configure the AXI Bus Mode Register */
 	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
 	/* Dump DMA registers */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 74177f9..54b3876 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -71,36 +71,48 @@ static void dwmac4_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
 }
 
-static void dwmac4_dma_init_channel(void __iomem *ioaddr,
-				    struct stmmac_dma_cfg *dma_cfg,
-				    u32 dma_tx_phy, u32 dma_rx_phy,
-				    u32 channel)
+void dwmac4_dma_init_rx_chan(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_rx_phy, u32 chan)
 {
 	u32 value;
-	int txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
-	int rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
+	u32 rxpbl = dma_cfg->rxpbl ?: dma_cfg->pbl;
 
-	/* set PBL for each channels. Currently we affect same configuration
-	 * on each channel
-	 */
-	value = readl(ioaddr + DMA_CHAN_CONTROL(channel));
-	if (dma_cfg->pblx8)
-		value = value | DMA_BUS_MODE_PBL;
-	writel(value, ioaddr + DMA_CHAN_CONTROL(channel));
+	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
+	value = value | (rxpbl << DMA_BUS_MODE_RPBL_SHIFT);
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
+
+	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(chan));
+}
 
-	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(channel));
+void dwmac4_dma_init_tx_chan(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg,
+			     u32 dma_tx_phy, u32 chan)
+{
+	u32 value;
+	u32 txpbl = dma_cfg->txpbl ?: dma_cfg->pbl;
+
+	value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 	value = value | (txpbl << DMA_BUS_MODE_PBL_SHIFT);
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(channel));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
-	value = readl(ioaddr + DMA_CHAN_RX_CONTROL(channel));
-	value = value | (rxpbl << DMA_BUS_MODE_RPBL_SHIFT);
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(channel));
+	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(chan));
+}
 
-	/* Mask interrupts by writing to CSR7 */
-	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr + DMA_CHAN_INTR_ENA(channel));
+void dwmac4_dma_init_channel(void __iomem *ioaddr,
+			     struct stmmac_dma_cfg *dma_cfg, u32 chan)
+{
+	u32 value;
+
+	/* common channel control register config */
+	value = readl(ioaddr + DMA_CHAN_CONTROL(chan));
+	if (dma_cfg->pblx8)
+		value = value | DMA_BUS_MODE_PBL;
+	writel(value, ioaddr + DMA_CHAN_CONTROL(chan));
 
-	writel(dma_tx_phy, ioaddr + DMA_CHAN_TX_BASE_ADDR(channel));
-	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
+	/* Mask interrupts by writing to CSR7 */
+	writel(DMA_CHAN_INTR_DEFAULT_MASK,
+	       ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
 static void dwmac4_dma_init(void __iomem *ioaddr,
@@ -108,7 +120,6 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 			    u32 dma_tx, u32 dma_rx, int atds)
 {
 	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
-	int i;
 
 	/* Set the Fixed burst mode */
 	if (dma_cfg->fixed_burst)
@@ -122,9 +133,6 @@ static void dwmac4_dma_init(void __iomem *ioaddr,
 		value |= DMA_SYS_BUS_AAL;
 
 	writel(value, ioaddr + DMA_SYS_BUS_MODE);
-
-	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		dwmac4_dma_init_channel(ioaddr, dma_cfg, dma_tx, dma_rx, i);
 }
 
 static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel,
@@ -379,6 +387,9 @@ static void dwmac4_enable_tso(void __iomem *ioaddr, bool en, u32 chan)
 const struct stmmac_dma_ops dwmac4_dma_ops = {
 	.reset = dwmac4_dma_reset,
 	.init = dwmac4_dma_init,
+	.init_chan = dwmac4_dma_init_channel,
+	.init_rx_chan = dwmac4_dma_init_rx_chan,
+	.init_tx_chan = dwmac4_dma_init_tx_chan,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
 	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
@@ -402,6 +413,9 @@ const struct stmmac_dma_ops dwmac4_dma_ops = {
 const struct stmmac_dma_ops dwmac410_dma_ops = {
 	.reset = dwmac4_dma_reset,
 	.init = dwmac4_dma_init,
+	.init_chan = dwmac4_dma_init_channel,
+	.init_rx_chan = dwmac4_dma_init_rx_chan,
+	.init_tx_chan = dwmac4_dma_init_tx_chan,
 	.axi = dwmac4_dma_axi,
 	.dump_regs = dwmac4_dump_dma_regs,
 	.dma_rx_mode = dwmac4_dma_rx_chan_op_mode,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e60e077..725fe3e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1732,6 +1732,11 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
  */
 static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 {
+	u32 rx_channels_count = priv->plat->rx_queues_to_use;
+	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	u32 dummy_dma_rx_phy = 0;
+	u32 dummy_dma_tx_phy = 0;
+	u32 chan = 0;
 	int atds = 0;
 	int ret = 0;
 
@@ -1749,19 +1754,43 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
 		return ret;
 	}
 
-	priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
-			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
-
 	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
-		priv->rx_tail_addr = priv->dma_rx_phy +
-			    (DMA_RX_SIZE * sizeof(struct dma_desc));
-		priv->hw->dma->set_rx_tail_ptr(priv->ioaddr, priv->rx_tail_addr,
-					       STMMAC_CHAN0);
+		/* DMA Configuration */
+		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
+				    dummy_dma_tx_phy, dummy_dma_rx_phy, atds);
+
+		/* DMA RX Channel Configuration */
+		for (chan = 0; chan < rx_channels_count; chan++) {
+			priv->hw->dma->init_rx_chan(priv->ioaddr,
+						    priv->plat->dma_cfg,
+						    priv->dma_rx_phy, chan);
+
+			priv->rx_tail_addr = priv->dma_rx_phy +
+				    (DMA_RX_SIZE * sizeof(struct dma_desc));
+			priv->hw->dma->set_rx_tail_ptr(priv->ioaddr,
+						       priv->rx_tail_addr,
+						       chan);
+		}
 
-		priv->tx_tail_addr = priv->dma_tx_phy +
-			    (DMA_TX_SIZE * sizeof(struct dma_desc));
-		priv->hw->dma->set_tx_tail_ptr(priv->ioaddr, priv->tx_tail_addr,
-					       STMMAC_CHAN0);
+		/* DMA TX Channel Configuration */
+		for (chan = 0; chan < tx_channels_count; chan++) {
+			priv->hw->dma->init_chan(priv->ioaddr,
+							priv->plat->dma_cfg,
+							chan);
+
+			priv->hw->dma->init_tx_chan(priv->ioaddr,
+						    priv->plat->dma_cfg,
+						    priv->dma_tx_phy, chan);
+
+			priv->tx_tail_addr = priv->dma_tx_phy +
+				    (DMA_TX_SIZE * sizeof(struct dma_desc));
+			priv->hw->dma->set_tx_tail_ptr(priv->ioaddr,
+						       priv->tx_tail_addr,
+						       chan);
+		}
+	} else {
+		priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
+				    priv->dma_tx_phy, priv->dma_rx_phy, atds);
 	}
 
 	if (priv->plat->axi && priv->hw->dma->axi)
-- 
2.9.3
