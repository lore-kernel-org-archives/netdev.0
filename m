From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH 05/11] net: stmmac: prepare dma interrupt treatment for multiple queues
Date: Mon, 13 Mar 2017 16:12:36 +0000
Message-ID: <4a216b7f0ae9944d0a272a3bfdee5e67867e4ab6.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:57377 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753932AbdCMQM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:12:59 -0400
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489419356.git.jpinto@synopsys.com>
References: <cover.1489419356.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares DMA interrupts treatment for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h      |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h  |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c  |  8 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h   |  3 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c   |  2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 55 +++++++++++++----------
 6 files changed, 41 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 042b482..6dfb7f3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -438,7 +438,7 @@ struct stmmac_dma_ops {
 	void (*start_rx)(void __iomem *ioaddr, u32 chan);
 	void (*stop_rx)(void __iomem *ioaddr, u32 chan);
 	int (*dma_interrupt) (void __iomem *ioaddr,
-			      struct stmmac_extra_stats *x);
+			      struct stmmac_extra_stats *x, u32 chan);
 	/* If supported then get the optional core features */
 	void (*get_hw_feature)(void __iomem *ioaddr,
 			       struct dma_features *dma_cap);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
index 2c19042..946dc14 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.h
@@ -193,7 +193,7 @@ void dwmac4_dma_stop_tx(void __iomem *ioaddr, u32 chan);
 void dwmac4_dma_start_rx(void __iomem *ioaddr, u32 chan);
 void dwmac4_dma_stop_rx(void __iomem *ioaddr, u32 chan);
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
-			 struct stmmac_extra_stats *x);
+			 struct stmmac_extra_stats *x, u32 chan);
 void dwmac4_set_rx_ring_len(void __iomem *ioaddr, u32 len);
 void dwmac4_set_tx_ring_len(void __iomem *ioaddr, u32 len);
 void dwmac4_set_rx_tail_ptr(void __iomem *ioaddr, u32 tail_ptr, u32 chan);
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
index 3512d18..fcd8ec8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_lib.c
@@ -122,11 +122,11 @@ void dwmac4_disable_dma_irq(void __iomem *ioaddr, u32 chan)
 }
 
 int dwmac4_dma_interrupt(void __iomem *ioaddr,
-			 struct stmmac_extra_stats *x)
+			 struct stmmac_extra_stats *x, u32 chan)
 {
 	int ret = 0;
 
-	u32 intr_status = readl(ioaddr + DMA_CHAN_STATUS(0));
+	u32 intr_status = readl(ioaddr + DMA_CHAN_STATUS(chan));
 
 	/* ABNORMAL interrupts */
 	if (unlikely(intr_status & DMA_CHAN_STATUS_AIS)) {
@@ -153,7 +153,7 @@ int dwmac4_dma_interrupt(void __iomem *ioaddr,
 		if (likely(intr_status & DMA_CHAN_STATUS_RI)) {
 			u32 value;
 
-			value = readl(ioaddr + DMA_CHAN_INTR_ENA(STMMAC_CHAN0));
+			value = readl(ioaddr + DMA_CHAN_INTR_ENA(chan));
 			/* to schedule NAPI on real RIE event. */
 			if (likely(value & DMA_CHAN_INTR_ENA_RIE)) {
 				x->rx_normal_irq_n++;
@@ -172,7 +172,7 @@ int dwmac4_dma_interrupt(void __iomem *ioaddr,
 	 * status [21-0] expect reserved bits [5-3]
 	 */
 	writel((intr_status & 0x3fffc7),
-	       ioaddr + DMA_CHAN_STATUS(STMMAC_CHAN0));
+	       ioaddr + DMA_CHAN_STATUS(chan));
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index 6c6cc71..9091df8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -143,7 +143,8 @@ void dwmac_dma_start_tx(void __iomem *ioaddr, u32 chan);
 void dwmac_dma_stop_tx(void __iomem *ioaddr, u32 chan);
 void dwmac_dma_start_rx(void __iomem *ioaddr, u32 chan);
 void dwmac_dma_stop_rx(void __iomem *ioaddr, u32 chan);
-int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x);
+int dwmac_dma_interrupt(void __iomem *ioaddr, struct stmmac_extra_stats *x,
+			u32 chan);
 int dwmac_dma_reset(void __iomem *ioaddr);
 
 #endif /* __DWMAC_DMA_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 7be60c3..38f9430 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -156,7 +156,7 @@ static void show_rx_process_state(unsigned int status)
 #endif
 
 int dwmac_dma_interrupt(void __iomem *ioaddr,
-			struct stmmac_extra_stats *x)
+			struct stmmac_extra_stats *x, u32 chan)
 {
 	int ret = 0;
 	/* read the status register (CSR5) */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 9b64f2e..053a042 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1591,32 +1591,41 @@ static void stmmac_set_dma_operation_mode(struct stmmac_priv *priv, u32 txmode,
  */
 static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 {
-	u32 chan = STMMAC_CHAN0;
+	u32 tx_channel_count = priv->plat->tx_queues_to_use;
 	int status;
+	u32 chan;
 
-	status = priv->hw->dma->dma_interrupt(priv->ioaddr, &priv->xstats);
-	if (likely((status & handle_rx)) || (status & handle_tx)) {
-		if (likely(napi_schedule_prep(&priv->napi))) {
-			stmmac_disable_dma_irq(priv, chan);
-			__napi_schedule(&priv->napi);
-		}
+	for (chan = 0; chan < tx_channel_count; chan++) {
+		status = priv->hw->dma->dma_interrupt(priv->ioaddr,
+						      &priv->xstats, chan);
+		if (likely((status & handle_rx)) || (status & handle_tx)) {
+			if (likely(napi_schedule_prep(&priv->napi))) {
+				stmmac_disable_dma_irq(priv, chan);
+				__napi_schedule(&priv->napi);
+			}
+		}
+
+		if (unlikely(status & tx_hard_error_bump_tc)) {
+			/* Try to bump up the dma threshold on this failure */
+			if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
+			    (tc <= 256)) {
+				tc += 64;
+				if (priv->plat->force_thresh_dma_mode)
+					stmmac_set_dma_operation_mode(priv,
+								      tc,
+								      tc,
+								      chan);
+				else
+					stmmac_set_dma_operation_mode(priv,
+								    tc,
+								    SF_DMA_MODE,
+								    chan);
+				priv->xstats.threshold = tc;
+			}
+		} else if (unlikely(status == tx_hard_error)) {
+			stmmac_tx_err(priv, chan);
+		}
 	}
-	if (unlikely(status & tx_hard_error_bump_tc)) {
-		/* Try to bump up the dma threshold on this failure */
-		if (unlikely(priv->xstats.threshold != SF_DMA_MODE) &&
-		    (tc <= 256)) {
-			tc += 64;
-			if (priv->plat->force_thresh_dma_mode)
-				stmmac_set_dma_operation_mode(priv->ioaddr,
-							      tc, tc, chan);
-			else
-				stmmac_set_dma_operation_mode(priv->ioaddr, tc,
-							      SF_DMA_MODE, chan);
-
-			priv->xstats.threshold = tc;
-		}
-	} else if (unlikely(status == tx_hard_error))
-		stmmac_tx_err(priv, chan);
 }
 
 /**
-- 
2.9.3
