From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 07/11] net: stmmac: rx and tx ring length prepared for multiple queues
Date: Tue, 14 Mar 2017 10:24:29 +0000
Message-ID: <c4f9a1781247f9ed2a52859bb3a19101336c187f.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:49714 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdCNKYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:24:55 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares tx and rx ring length configuration for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up the patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  4 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h  |  4 +--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c  |  8 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 32 +++++++++++++++++------
 4 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 5fa23b1..bef1fc6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -444,8 +444,8 @@ struct stmmac_dma_ops {
 			       struct dma_features *dma_cap);
 	/* Program the HW RX Watchdog */
 	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt, u32 number_chan);
-	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len);
-	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len);
+	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len, u32 chan);
+	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len, u32 chan);
 	void (*set_rx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*set_tx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 	void (*enable_tso)(void __iomem *ioaddr, bool en, u32 chan);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
index 946dc14..8474bf9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -194,8 +194,8 @@ void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan);
 void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan);
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
 			 struct stmmac_extra_stats *x, u32 chan);
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len);
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len, u32 chan);
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len, u32 chan);
 void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 void dwmac4_set_tx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index fcd8ec8..da54c0b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -94,14 +94,14 @@ void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan)
 	writel(value, ioaddr + GMAC_CONFIG);
 }
 
-void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len)
+void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len, u32 chan)
 {
-	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(STMMAC_CHAN0));
+	writel(len, ioaddr + DMA_CHAN_TX_RING_LEN(chan));
 }
 
-void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len)
+void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len, u32 chan)
 {
-	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(STMMAC_CHAN0));
+	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(chan));
 }
 
 void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2af8589..e60e077 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1802,6 +1802,27 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
 	add_timer(&priv->txtimer);
 }
 
+static void stmmac_set_rings_length(struct stmmac_priv *priv)
+{
+	u32 rx_channels_count = priv->plat->rx_queues_to_use;
+	u32 tx_channels_count = priv->plat->tx_queues_to_use;
+	u32 chan;
+
+	/* set TX ring length */
+	if (priv->hw->dma->set_tx_ring_len) {
+		for (chan = 0; chan < tx_channels_count; chan++)
+			priv->hw->dma->set_tx_ring_len(priv->ioaddr,
+						       (DMA_TX_SIZE - 1), chan);
+	}
+
+	/* set RX ring length */
+	if (priv->hw->dma->set_rx_ring_len) {
+		for (chan = 0; chan < rx_channels_count; chan++)
+			priv->hw->dma->set_rx_ring_len(priv->ioaddr,
+						       (DMA_RX_SIZE - 1), chan);
+	}
+}
+
 /**
  *  stmmac_set_tx_queue_weight - Set TX queue weight
  *  @priv: driver private structure
@@ -1995,14 +2016,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
 		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, priv->hw->ps, 0);
 
-	/*  set TX ring length */
-	if (priv->hw->dma->set_tx_ring_len)
-		priv->hw->dma->set_tx_ring_len(priv->ioaddr,
-					       (DMA_TX_SIZE - 1));
-	/*  set RX ring length */
-	if (priv->hw->dma->set_rx_ring_len)
-		priv->hw->dma->set_rx_ring_len(priv->ioaddr,
-					       (DMA_RX_SIZE - 1));
+	/* set TX and RX rings length */
+	stmmac_set_rings_length(priv);
+
 	/* Enable TSO */
 	if (priv->tso)
 		priv->hw->dma->enable_tso(priv->ioaddr, 1, STMMAC_CHAN0);
-- 
2.9.3
