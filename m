From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 03/11] net: stmmac: rx/tx dma start/stop prepared for multiple queues
Date: Mon, 13 Mar 2017 16:12:34 +0000
Message-ID: <cb524f144dd54c8f6862d05ca6581d5165be48df.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:57371 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754071AbdCMQNF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:13:05 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the RX/TX DMA stop/start process for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |   8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h  |   8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c  |  24 ++---
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h   |   8 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c   |   8 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 108 +++++++++++++++++++---
 6 files changed, 125 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 0351b54..042b482 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -433,10 +433,10 @@ struct stmmac_dma_ops {
 	void (*enable_dma_transmission) (void __iomem *ioaddr);
 	void (*enable_dma_irq)(void __iomem *ioaddr, u32 chan);
 	void (*disable_dma_irq)(void __iomem *ioaddr, u32 chan);
-	void (*start_tx) (void __iomem *ioaddr);
-	void (*stop_tx) (void __iomem *ioaddr);
-	void (*start_rx) (void __iomem *ioaddr);
-	void (*stop_rx) (void __iomem *ioaddr);
+	void (*start_tx)(void __iomem *ioaddr, u32 chan);
+	void (*stop_tx)(void __iomem *ioaddr, u32 chan);
+	void (*start_rx)(void __iomem *ioaddr, u32 chan);
+	void (*stop_rx)(void __iomem *ioaddr, u32 chan);
 	int (*dma_interrupt) (void __iomem *ioaddr,
 			      struct stmmac_extra_stats *x);
 	/* If supported then get the optional core features */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
index 393a657..2c19042 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -188,10 +188,10 @@ void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
 void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan);
 void dwmac410_enable_dma_irq(void __iomem *ioaddr, u32 chan);
 void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan);
-void dwmac4_dma_start_tx(void __iomem *ioaddr);
-void dwmac4_dma_stop_tx(void __iomem *ioaddr);
-void dwmac4_dma_start_rx(void __iomem *ioaddr);
-void dwmac4_dma_stop_rx(void __iomem *ioaddr);
+void dwmac4_dma_start_tx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_stop_tx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan);
+void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan);
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
 			 struct stmmac_extra_stats *x);
 void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index c932791..3512d18 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -45,49 +45,49 @@ void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan)
 	writel(tail_ptr, ioaddr + DMA_CHAN_TX_END_ADDR(0));
 }
 
-void dwmac4_dma_start_tx(void __iomem *ioaddr)
+void dwmac4_dma_start_tx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value |= DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value |= GMAC_CONFIG_TE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_tx(void __iomem *ioaddr)
+void dwmac4_dma_stop_tx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value &= ~DMA_CONTROL_ST;
-	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_TX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value &= ~GMAC_CONFIG_TE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_start_rx(void __iomem *ioaddr)
+void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value |= DMA_CONTROL_SR;
 
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value |= GMAC_CONFIG_RE;
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_dma_stop_rx(void __iomem *ioaddr)
+void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan)
 {
-	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	u32 value = readl(ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value &= ~DMA_CONTROL_SR;
-	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(STMMAC_CHAN0));
+	writel(value, ioaddr + DMA_CHAN_RX_CONTROL(chan));
 
 	value = readl(ioaddr + GMAC_CONFIG);
 	value &= ~GMAC_CONFIG_RE;
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index dec0816..6c6cc71 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -139,10 +139,10 @@
 void dwmac_enable_dma_transmission(void __iomem *ioaddr);
 void dwmac_enable_dma_irq(void __iomem *ioaddr, u32 chan);
 void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan);
-void dwmac_dma_start_tx(void __iomem *ioaddr);
-void dwmac_dma_stop_tx(void __iomem *ioaddr);
-void dwmac_dma_start_rx(void __iomem *ioaddr);
-void dwmac_dma_stop_rx(void __iomem *ioaddr);
+void dwmac_dma_start_tx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_stop_tx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_start_rx(void __iomem *ioaddr, u32 chan);
+void dwmac_dma_stop_rx(void __iomem *ioaddr, u32 chan);
 int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
 int dwmac_dma_reset(void __iomem *ioaddr);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 285cfc9..7be60c3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -57,28 +57,28 @@ void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 	writel(0, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_dma_start_tx(void __iomem *ioaddr)
+void dwmac_dma_start_tx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_tx(void __iomem *ioaddr)
+void dwmac_dma_stop_tx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_ST;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_start_rx(void __iomem *ioaddr)
+void dwmac_dma_start_rx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value |= DMA_CONTROL_SR;
 	writel(value, ioaddr + DMA_CONTROL);
 }
 
-void dwmac_dma_stop_rx(void __iomem *ioaddr)
+void dwmac_dma_stop_rx(void __iomem *ioaddr, u32 chan)
 {
 	u32 value = readl(ioaddr + DMA_CONTROL);
 	value &= ~DMA_CONTROL_SR;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 77d1b38..58ad199 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1278,6 +1278,96 @@ static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
 }
 
 /**
+ * stmmac_start_rx_dma - start RX DMA channel
+ * @priv: driver private structure
+ * @chan: RX channel index
+ * Description:
+ * This starts a RX DMA channel
+ */
+static void stmmac_start_rx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA RX processes started in channel %d\n", chan);
+	priv->hw->dma->start_rx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_start_tx_dma - start TX DMA channel
+ * @priv: driver private structure
+ * @chan: TX channel index
+ * Description:
+ * This starts a TX DMA channel
+ */
+static void stmmac_start_tx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA TX processes started in channel %d\n", chan);
+	priv->hw->dma->start_tx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_stop_rx_dma - stop RX DMA channel
+ * @priv: driver private structure
+ * @chan: RX channel index
+ * Description:
+ * This stops a RX DMA channel
+ */
+static void stmmac_stop_rx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA RX processes stopped in channel %d\n", chan);
+	priv->hw->dma->stop_rx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_stop_tx_dma - stop TX DMA channel
+ * @priv: driver private structure
+ * @chan: TX channel index
+ * Description:
+ * This stops a TX DMA channel
+ */
+static void stmmac_stop_tx_dma(struct stmmac_priv *priv, u32 chan)
+{
+	netdev_dbg(priv->dev, "DMA TX processes stopped in channel %d\n", chan);
+	priv->hw->dma->stop_tx(priv->ioaddr, chan);
+}
+
+/**
+ * stmmac_start_all_dma - start all RX and TX DMA channels
+ * @priv: driver private structure
+ * Description:
+ * This starts all the RX and TX DMA channels
+ */
+static void stmmac_start_all_dma(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->plat->rx_queues_to_use;
+	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	u32 chan = 0;
+
+	for (chan = 0; chan < rx_channels_count; chan++)
+		stmmac_start_rx_dma(priv, chan);
+
+	for (chan = 0; chan < tx_channels_count; chan++)
+		stmmac_start_tx_dma(priv, chan);
+}
+
+/**
+ * stmmac_stop_all_dma - stop all RX and TX DMA channels
+ * @priv: driver private structure
+ * Description:
+ * This stops the RX and TX DMA channels
+ */
+static void stmmac_stop_all_dma(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->plat->rx_queues_to_use;
+	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	u32 chan = 0;
+
+	for (chan = 0; chan < rx_channels_count; chan++)
+		stmmac_stop_rx_dma(priv, chan);
+
+	for (chan = 0; chan < tx_channels_count; chan++)
+		stmmac_stop_tx_dma(priv, chan);
+}
+
+/**
  *  stmmac_dma_operation_mode - HW DMA operation mode
  *  @priv: driver private structure
  *  Description: it is used for configuring the DMA operation mode register in
@@ -1440,10 +1530,11 @@ static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
  */
 static void stmmac_tx_err(struct stmmac_priv *priv)
 {
+	u32 chan = STMMAC_CHAN0;
 	int i;
 	netif_stop_queue(priv->dev);
 
-	priv->hw->dma->stop_tx(priv->ioaddr);
+	stmmac_stop_tx_dma(priv, chan);
 	dma_free_tx_skbufs(priv);
 	for (i = 0; i < DMA_TX_SIZE; i++)
 		if (priv->extend_desc)
@@ -1457,7 +1548,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 	priv->dirty_tx = 0;
 	priv->cur_tx = 0;
 	netdev_reset_queue(priv->dev);
-	priv->hw->dma->start_tx(priv->ioaddr);
+	stmmac_start_tx_dma(priv, chan);
 
 	priv->dev->stats.tx_errors++;
 	netif_wake_queue(priv->dev);
@@ -1882,9 +1973,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 			    __func__);
 #endif
 	/* Start the ball rolling... */
-	netdev_dbg(priv->dev, "DMA RX/TX processes started...\n");
-	priv->hw->dma->start_tx(priv->ioaddr);
-	priv->hw->dma->start_rx(priv->ioaddr);
+	stmmac_start_all_dma(priv);
 
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS;
 
@@ -2070,8 +2159,7 @@ static int stmmac_release(struct net_device *dev)
 		free_irq(priv->lpi_irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
-	priv->hw->dma->stop_tx(priv->ioaddr);
-	priv->hw->dma->stop_rx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	/* Release and free the Rx/Tx resources */
 	free_dma_desc_resources(priv);
@@ -3546,8 +3634,7 @@ int stmmac_dvr_remove(struct device *dev)
 
 	netdev_info(priv->dev, "%s: removing driver", __func__);
 
-	priv->hw->dma->stop_rx(priv->ioaddr);
-	priv->hw->dma->stop_tx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	stmmac_set_mac(priv->ioaddr, false);
 	netif_carrier_off(ndev);
@@ -3593,8 +3680,7 @@ int stmmac_suspend(struct device *dev)
 	napi_disable(&priv->napi);
 
 	/* Stop TX/RX DMA */
-	priv->hw->dma->stop_tx(priv->ioaddr);
-	priv->hw->dma->stop_rx(priv->ioaddr);
+	stmmac_stop_all_dma(priv);
 
 	/* Enable Power down mode by programming the PMT regs */
 	if (device_may_wakeup(priv->device)) {
-- 
2.9.3
