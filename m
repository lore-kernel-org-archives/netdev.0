From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v2 net-next 02/11] net: stmmac: enable/disable dma irq prepared for multiple queues
Date: Tue, 14 Mar 2017 10:24:24 +0000
Message-ID: <66db000115cf6e9afb16b637134274c5f2decddb.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:45437 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdCNKZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:25:02 -0400
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489485739.git.jpinto@synopsys.com>
References: <cover.1489485739.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares the DMA IRQ enable/disable process for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
changes v1->v2:
- Just to keep up the patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h  |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c  | 12 ++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h   |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c   |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 13 +++++++------
 6 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 13bd3d4..0351b54 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -431,8 +431,8 @@ struct stmmac_dma_ops {
 	void (*dma_diagnostic_fr) (void *data, struct stmmac_extra_stats *x,
 				   void __iomem *ioaddr);
 	void (*enable_dma_transmission) (void __iomem *ioaddr);
-	void (*enable_dma_irq) (void __iomem *ioaddr);
-	void (*disable_dma_irq) (void __iomem *ioaddr);
+	void (*enable_dma_irq)(void __iomem *ioaddr, u32 chan);
+	void (*disable_dma_irq)(void __iomem *ioaddr, u32 chan);
 	void (*start_tx) (void __iomem *ioaddr);
 	void (*stop_tx) (void __iomem *ioaddr);
 	void (*start_rx) (void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
index 1b06df7..393a657 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -185,9 +185,9 @@
 
 int dwmac4_dma_reset(void __iomem *ioaddr);
 void dwmac4_enable_dma_transmission(void __iomem *ioaddr, u32 tail_ptr);
-void dwmac4_enable_dma_irq(void __iomem *ioaddr);
-void dwmac410_enable_dma_irq(void __iomem *ioaddr);
-void dwmac4_disable_dma_irq(void __iomem *ioaddr);
+void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac410_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan);
 void dwmac4_dma_start_tx(void __iomem *ioaddr);
 void dwmac4_dma_stop_tx(void __iomem *ioaddr);
 void dwmac4_dma_start_rx(void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index c7326d5..c932791 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -104,21 +104,21 @@ void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len)
 	writel(len, ioaddr + DMA_CHAN_RX_RING_LEN(STMMAC_CHAN0));
 }
 
-void dwmac4_enable_dma_irq(void __iomem *ioaddr)
+void dwmac4_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK, ioaddr +
-	       DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	       DMA_CHAN_INTR_ENA(chan));
 }
 
-void dwmac410_enable_dma_irq(void __iomem *ioaddr)
+void dwmac410_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_CHAN_INTR_DEFAULT_MASK_4_10,
-	       ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	       ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
-void dwmac4_disable_dma_irq(void __iomem *ioaddr)
+void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
-	writel(0, ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+	writel(0, ioaddr + DMA_CHAN_INTR_ENA(chan));
 }
 
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 56e485f..dec0816 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -137,8 +137,8 @@
 #define DMA_CONTROL_FTF		0x00100000	/* Flush transmit FIFO */
 
 void dwmac_enable_dma_transmission(void __iomem *ioaddr);
-void dwmac_enable_dma_irq(void __iomem *ioaddr);
-void dwmac_disable_dma_irq(void __iomem *ioaddr);
+void dwmac_enable_dma_irq(void __iomem *ioaddr, u32 chan);
+void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan);
 void dwmac_dma_start_tx(void __iomem *ioaddr);
 void dwmac_dma_stop_tx(void __iomem *ioaddr);
 void dwmac_dma_start_rx(void __iomem *ioaddr);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index e60bfca..285cfc9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -47,12 +47,12 @@ void dwmac_enable_dma_transmission(void __iomem *ioaddr)
 	writel(1, ioaddr + DMA_XMT_POLL_DEMAND);
 }
 
-void dwmac_enable_dma_irq(void __iomem *ioaddr)
+void dwmac_enable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(DMA_INTR_DEFAULT_MASK, ioaddr + DMA_INTR_ENA);
 }
 
-void dwmac_disable_dma_irq(void __iomem *ioaddr)
+void dwmac_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 {
 	writel(0, ioaddr + DMA_INTR_ENA);
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 660eef0..77d1b38 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1422,14 +1422,14 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	netif_tx_unlock(priv->dev);
 }
 
-static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv)
+static inline void stmmac_enable_dma_irq(struct stmmac_priv *priv, u32 chan)
 {
-	priv->hw->dma->enable_dma_irq(priv->ioaddr);
+	priv->hw->dma->enable_dma_irq(priv->ioaddr, chan);
 }
 
-static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv)
+static inline void stmmac_disable_dma_irq(struct stmmac_priv *priv, u32 chan)
 {
-	priv->hw->dma->disable_dma_irq(priv->ioaddr);
+	priv->hw->dma->disable_dma_irq(priv->ioaddr, chan);
 }
 
 /**
@@ -1506,7 +1506,7 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
 	if (likely((status & handle_rx)) || (status & handle_tx)) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			stmmac_disable_dma_irq(priv);
+			stmmac_disable_dma_irq(priv, chan);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -2832,6 +2832,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 {
 	struct stmmac_priv *priv = container_of(napi, struct stmmac_priv, napi);
 	int work_done = 0;
+	u32 chan = STMMAC_CHAN0;
 
 	priv->xstats.napi_poll++;
 	stmmac_tx_clean(priv);
@@ -2839,7 +2840,7 @@ static int stmmac_poll(struct napi_struct *napi, int budget)
 	work_done = stmmac_rx(priv, budget);
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
-		stmmac_enable_dma_irq(priv);
+		stmmac_enable_dma_irq(priv, chan);
 	}
 	return work_done;
 }
-- 
2.9.3
