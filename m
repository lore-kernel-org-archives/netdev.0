From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH v4 net-next 7/9] net: stmicro: prepare irq_status for mtl
Date: Fri, 10 Mar 2017 12:18:32 +0000
Message-ID: <c08449eacd133302f4eeafe0b8333330be766251.1489146580.git.jpinto@synopsys.com>
References: <cover.1489146580.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:50676 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936388AbdCJMTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 07:19:02 -0500
In-Reply-To: <cover.1489146580.git.jpinto@synopsys.com>
In-Reply-To: <cover.1489146580.git.jpinto@synopsys.com>
References: <cover.1489146580.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares mac irq status treatment for multiple queues.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
Changes v3->v4:
- Build error in dwmac4_irq_mtl_status()
- variable init simplified in some functions
changes v2->v3:
- local variable declarations from longest to shortest line
changes v1->v2:
- Just to keep up with patch-set version

 drivers/net/ethernet/stmicro/stmmac/common.h      |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h      |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 40 ++++++++++++++---------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  5 +++
 4 files changed, 33 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 5532633..6a348d3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -469,6 +469,8 @@ struct stmmac_ops {
 	/* Handle extra events on specific interrupts hw dependent */
 	int (*host_irq_status)(struct mac_device_info *hw,
 			       struct stmmac_extra_stats *x);
+	/* Handle MTL interrupts */
+	int (*host_mtl_irq_status)(struct mac_device_info *hw, u32 chan);
 	/* Multicast filter setting */
 	void (*set_filter)(struct mac_device_info *hw, struct net_device *dev);
 	/* Flow control setting */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 9dd8ac1..5ca4d64 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -172,7 +172,7 @@ enum power_event {
 #define MTL_OPERATION_RAA_WSP		(0x1 << 2)
 
 #define MTL_INT_STATUS			0x00000c20
-#define MTL_INT_Q0			BIT(0)
+#define MTL_INT_QX(x)			BIT(x)
 
 #define MTL_RXQ_DMA_MAP0		0x00000c30 /* queue 0 to 3 */
 #define MTL_RXQ_DMA_MAP1		0x00000c34 /* queue 4 to 7 */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 3069def..f0f2dce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -416,11 +416,34 @@ static void dwmac4_phystatus(void __iomem *ioaddr, struct stmmac_extra_stats *x)
 	}
 }
 
+static int dwmac4_irq_mtl_status(struct mac_device_info *hw, u32 chan)
+{
+	void __iomem *ioaddr = hw->pcsr;
+	u32 mtl_int_qx_status;
+	int ret = 0;
+
+	mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
+
+	/* Check MTL Interrupt */
+	if (mtl_int_qx_status & MTL_INT_QX(chan)) {
+		/* read Queue x Interrupt status */
+		u32 status = readl(ioaddr + MTL_CHAN_INT_CTRL(chan));
+
+		if (status & MTL_RX_OVERFLOW_INT) {
+			/*  clear Interrupt */
+			writel(status | MTL_RX_OVERFLOW_INT,
+			       ioaddr + MTL_CHAN_INT_CTRL(chan));
+			ret = CORE_IRQ_MTL_RX_OVERFLOW;
+		}
+	}
+
+	return ret;
+}
+
 static int dwmac4_irq_status(struct mac_device_info *hw,
 			     struct stmmac_extra_stats *x)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	u32 mtl_int_qx_status;
 	u32 intr_status;
 	int ret = 0;
 
@@ -439,20 +462,6 @@ static int dwmac4_irq_status(struct mac_device_info *hw,
 		x->irq_receive_pmt_irq_n++;
 	}
 
-	mtl_int_qx_status = readl(ioaddr + MTL_INT_STATUS);
-	/* Check MTL Interrupt: Currently only one queue is used: Q0. */
-	if (mtl_int_qx_status & MTL_INT_Q0) {
-		/* read Queue 0 Interrupt status */
-		u32 status = readl(ioaddr + MTL_CHAN_INT_CTRL(STMMAC_CHAN0));
-
-		if (status & MTL_RX_OVERFLOW_INT) {
-			/*  clear Interrupt */
-			writel(status | MTL_RX_OVERFLOW_INT,
-			       ioaddr + MTL_CHAN_INT_CTRL(STMMAC_CHAN0));
-			ret = CORE_IRQ_MTL_RX_OVERFLOW;
-		}
-	}
-
 	dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
 	if (intr_status & PCS_RGSMIIIS_IRQ)
 		dwmac4_phystatus(ioaddr, x);
@@ -554,6 +563,7 @@ static const struct stmmac_ops dwmac4_ops = {
 	.map_mtl_to_dma = dwmac4_map_mtl_dma,
 	.dump_regs = dwmac4_dump_regs,
 	.host_irq_status = dwmac4_irq_status,
+	.host_mtl_irq_status = dwmac4_irq_mtl_status,
 	.flow_ctrl = dwmac4_flow_ctrl,
 	.pmt = dwmac4_pmt,
 	.set_umac_addr = dwmac4_set_umac_addr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ed57409..3be77d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2880,6 +2880,11 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	if ((priv->plat->has_gmac) || (priv->plat->has_gmac4)) {
 		int status = priv->hw->mac->host_irq_status(priv->hw,
 							    &priv->xstats);
+
+		if (priv->synopsys_id >= DWMAC_CORE_4_00)
+			status |= priv->hw->mac->host_mtl_irq_status(priv->hw,
+								STMMAC_CHAN0);
+
 		if (unlikely(status)) {
 			/* For LPI we need to save the tx status */
 			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
-- 
2.9.3
