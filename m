From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 06/11] net: stmmac: rx watchdog config prepared for multiple queues
Date: Tue, 14 Mar 2017 10:24:28 +0000
Message-ID: <a73e886e2fea8f60d75337bc357812a01905cd56.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:49708 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdCNKY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:24:57 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds rx watchdog configuration for all queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up the patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h         | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c  | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c     | 8 ++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    | 3 ++-
 5 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 6dfb7f3..5fa23b1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -443,7 +443,7 @@ struct stmmac_dma_ops {
 	void (*get_hw_feature)(void __iomem *ioaddr,
 			       struct dma_features *dma_cap);
 	/* Program the HW RX Watchdog */
-	void (*rx_watchdog) (void __iomem *ioaddr, u32 riwt);
+	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt, u32 number_chan);
 	void (*set_tx_ring_len)(void __iomem *ioaddr, u32 len);
 	void (*set_rx_ring_len)(void __iomem *ioaddr, u32 len);
 	void (*set_rx_tail_ptr)(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
index d3654a4..471a9aa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
@@ -247,7 +247,8 @@ static void dwmac1000_get_hw_feature(void __iomem *ioaddr,
 	dma_cap->enh_desc = (hw_cap & DMA_HW_FEAT_ENHDESSEL) >> 24;
 }
 
-static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+static void dwmac1000_rx_watchdog(void __iomem *ioaddr, u32 riwt,
+				  u32 number_chan)
 {
 	writel(riwt, ioaddr + DMA_RX_WATCHDOG);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 6285e8a..74177f9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -174,12 +174,12 @@ static void dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
 		_dwmac4_dump_dma_regs(ioaddr, i, reg_space);
 }
 
-static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+static void dwmac4_rx_watchdog(void __iomem *ioaddr, u32 riwt, u32 number_chan)
 {
-	int i;
+	u32 chan;
 
-	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
-		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(i));
+	for (chan = 0; chan < number_chan; chan++)
+		writel(riwt, ioaddr + DMA_CHAN_RX_WATCHDOG(chan));
 }
 
 static void dwmac4_dma_rx_chan_op_mode(void __iomem *ioaddr, int mode,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 61b9369..16808e4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -730,6 +730,7 @@ static int stmmac_set_coalesce(struct net_device *dev,
 			       struct ethtool_coalesce *ec)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
 	unsigned int rx_riwt;
 
 	/* Check not supported parameters  */
@@ -768,7 +769,7 @@ static int stmmac_set_coalesce(struct net_device *dev,
 	priv->tx_coal_frames = ec->tx_max_coalesced_frames;
 	priv->tx_coal_timer = ec->tx_coalesce_usecs;
 	priv->rx_riwt = rx_riwt;
-	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt);
+	priv->hw->dma->rx_watchdog(priv->ioaddr, priv->rx_riwt, rx_cnt);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 053a042..2af8589 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1915,6 +1915,7 @@ static void stmmac_mtl_configuration(struct stmmac_priv *priv)
 static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
+	u32 rx_cnt = priv->plat->rx_queues_to_use;
 	int ret;
 
 	/* DMA initialization and SW reset */
@@ -1988,7 +1989,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
 		priv->rx_riwt = MAX_DMA_RIWT;
-		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
+		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT, rx_cnt);
 	}
 
 	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
-- 
2.9.3
