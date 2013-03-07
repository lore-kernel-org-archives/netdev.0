From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 7/9] stmmac: start adding pcs and rgmii core irq
Date: Thu,  7 Mar 2013 11:50:17 +0100
Message-ID: <1362653419-1047-8-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Udit Kumar <udit-dlh.kumar@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:35338 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756218Ab3CGKwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:52:21 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch starts adding in the main ISR the management of the PCS and
RGMII/SGMII core interrupts. This is to help further development
on this area. Currently the core irq handler only clears the
PCS and S-R_MII interrupts and reports the event in the ethtool stats.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Byungho An <bh74.an@samsung.com>
Cc: Udit Kumar <udit-dlh.kumar@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   25 ++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    5 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   44 ++++++++++++-------
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    3 +-
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    3 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   24 ++---------
 6 files changed, 54 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index f5965b6..42e2a87 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -117,6 +117,10 @@ struct stmmac_extra_stats {
 	unsigned long irq_rx_path_in_lpi_mode_n;
 	unsigned long irq_rx_path_exit_lpi_mode_n;
 	unsigned long phy_eee_wakeup_error_n;
+	/* PCS */
+	unsigned long irq_pcs_ane_n;
+	unsigned long irq_pcs_link_n;
+	unsigned long irq_rgmii_n;
 #ifdef CONFIG_STMMAC_EXTENDED_DESC
 	/* Extended RDES status */
 	unsigned long ip_hdr_err;
@@ -219,16 +223,14 @@ enum dma_irq_status {
 	handle_tx = 0x8,
 };
 
-enum core_specific_irq_mask {
-	core_mmc_tx_irq = 1,
-	core_mmc_rx_irq = 2,
-	core_mmc_rx_csum_offload_irq = 4,
-	core_irq_receive_pmt_irq = 8,
-	core_irq_tx_path_in_lpi_mode = 16,
-	core_irq_tx_path_exit_lpi_mode = 32,
-	core_irq_rx_path_in_lpi_mode = 64,
-	core_irq_rx_path_exit_lpi_mode = 128,
-};
+#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 1)
+#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 2)
+#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 3)
+#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 4)
+
+#define	CORE_PCS_ANE_COMPLETE		(1 << 5)
+#define	CORE_PCS_LINK_STATUS		(1 << 6)
+#define	CORE_RGMII_IRQ			(1 << 7)
 
 /* DMA HW capabilities */
 struct dma_features {
@@ -364,7 +366,8 @@ struct stmmac_ops {
 	/* Dump MAC registers */
 	void (*dump_regs) (void __iomem *ioaddr);
 	/* Handle extra events on specific interrupts hw dependent */
-	int (*host_irq_status) (void __iomem *ioaddr);
+	int (*host_irq_status) (void __iomem *ioaddr,
+				struct stmmac_extra_stats *x);
 	/* Multicast filter setting */
 	void (*set_filter) (struct net_device *dev, int id);
 	/* Flow control setting */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 85466e5..6dd689e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -89,13 +89,14 @@ enum power_event {
 				(reg * 8))
 #define GMAC_MAX_PERFECT_ADDRESSES	32
 
+/* PCS registers (AN/TBI/SGMII/RGMII) offset */
 #define GMAC_AN_CTRL	0x000000c0	/* AN control */
 #define GMAC_AN_STATUS	0x000000c4	/* AN status */
 #define GMAC_ANE_ADV	0x000000c8	/* Auto-Neg. Advertisement */
-#define GMAC_ANE_LINK	0x000000cc	/* Auto-Neg. link partener ability */
+#define GMAC_ANE_LPA	0x000000cc	/* Auto-Neg. link partener ability */
 #define GMAC_ANE_EXP	0x000000d0	/* ANE expansion */
 #define GMAC_TBI	0x000000d4	/* TBI extend status */
-#define GMAC_GMII_STATUS 0x000000d8	/* S/R-GMII status */
+#define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
 
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index bfe0226..ff4c79e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -194,58 +194,70 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 }
 
 
-static int dwmac1000_irq_status(void __iomem *ioaddr)
+static int dwmac1000_irq_status(void __iomem *ioaddr,
+				struct stmmac_extra_stats *x)
 {
 	u32 intr_status = readl(ioaddr + GMAC_INT_STATUS);
-	int status = 0;
+	int ret = 0;
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
 	if ((intr_status & mmc_tx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC tx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_TX_INTR));
-		status |= core_mmc_tx_irq;
+		x->mmc_tx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx interrupt: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_INTR));
-		status |= core_mmc_rx_irq;
+		x->mmc_rx_irq_n++;
 	}
 	if (unlikely(intr_status & mmc_rx_csum_offload_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: MMC rx csum offload: 0x%08x\n",
 		    readl(ioaddr + GMAC_MMC_RX_CSUM_OFFLOAD));
-		status |= core_mmc_rx_csum_offload_irq;
+		x->mmc_rx_csum_offload_irq_n++;
 	}
 	if (unlikely(intr_status & pmt_irq)) {
 		CHIP_DBG(KERN_INFO "GMAC: received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT
 		 * status register. */
 		readl(ioaddr + GMAC_PMT);
-		status |= core_irq_receive_pmt_irq;
+		x->irq_receive_pmt_irq_n++;
 	}
 	/* MAC trx/rx EEE LPI entry/exit interrupts */
 	if (intr_status & lpiis_irq) {
 		/* Clean LPI interrupt by reading the Reg 12 */
-		u32 lpi_status = readl(ioaddr + LPI_CTRL_STATUS);
+		ret = readl(ioaddr + LPI_CTRL_STATUS);
 
-		if (lpi_status & LPI_CTRL_STATUS_TLPIEN) {
+		if (ret & LPI_CTRL_STATUS_TLPIEN) {
 			CHIP_DBG(KERN_INFO "GMAC TX entered in LPI\n");
-			status |= core_irq_tx_path_in_lpi_mode;
+			x->irq_tx_path_in_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_TLPIEX) {
+		if (ret & LPI_CTRL_STATUS_TLPIEX) {
 			CHIP_DBG(KERN_INFO "GMAC TX exit from LPI\n");
-			status |= core_irq_tx_path_exit_lpi_mode;
+			x->irq_tx_path_exit_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_RLPIEN) {
+		if (ret & LPI_CTRL_STATUS_RLPIEN) {
 			CHIP_DBG(KERN_INFO "GMAC RX entered in LPI\n");
-			status |= core_irq_rx_path_in_lpi_mode;
+			x->irq_rx_path_in_lpi_mode_n++;
 		}
-		if (lpi_status & LPI_CTRL_STATUS_RLPIEX) {
+		if (ret & LPI_CTRL_STATUS_RLPIEX) {
 			CHIP_DBG(KERN_INFO "GMAC RX exit from LPI\n");
-			status |= core_irq_rx_path_exit_lpi_mode;
+			x->irq_rx_path_exit_lpi_mode_n++;
 		}
 	}
 
-	return status;
+	if ((intr_status & pcs_ane_irq) || (intr_status & pcs_link_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC PCS ANE IRQ\n");
+		readl(ioaddr + GMAC_AN_STATUS);
+		x->irq_pcs_ane_n++;
+	}
+	if (intr_status & rgmii_irq) {
+		CHIP_DBG(KERN_INFO "GMAC RGMII IRQ status\n");
+		readl(ioaddr + GMAC_S_R_GMII);
+		x->irq_rgmii_n++;
+	}
+
+	return ret;
 }
 
 static void  dwmac1000_set_eee_mode(void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
index f83210e..cb86a58 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
@@ -72,7 +72,8 @@ static int dwmac100_rx_ipc_enable(void __iomem *ioaddr)
 	return 0;
 }
 
-static int dwmac100_irq_status(void __iomem *ioaddr)
+static int dwmac100_irq_status(void __iomem *ioaddr,
+			       struct stmmac_extra_stats *x)
 {
 	return 0;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 88d2d25..d78234e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -108,6 +108,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(irq_rx_path_in_lpi_mode_n),
 	STMMAC_STAT(irq_rx_path_exit_lpi_mode_n),
 	STMMAC_STAT(phy_eee_wakeup_error_n),
+	/* PCS */
+	STMMAC_STAT(irq_pcs_ane_n),
+	STMMAC_STAT(irq_rgmii_n),
 #ifdef CONFIG_STMMAC_EXTENDED_DESC
 	/* Extended RDES status */
 	STMMAC_STAT(ip_hdr_err),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8786939..7d2ee6f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1998,30 +1998,14 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 	/* To handle GMAC own interrupts */
 	if (priv->plat->has_gmac) {
 		int status = priv->hw->mac->host_irq_status((void __iomem *)
-							    dev->base_addr);
+							    dev->base_addr,
+							    &priv->xstats);
 		if (unlikely(status)) {
-			if (status & core_mmc_tx_irq)
-				priv->xstats.mmc_tx_irq_n++;
-			if (status & core_mmc_rx_irq)
-				priv->xstats.mmc_rx_irq_n++;
-			if (status & core_mmc_rx_csum_offload_irq)
-				priv->xstats.mmc_rx_csum_offload_irq_n++;
-			if (status & core_irq_receive_pmt_irq)
-				priv->xstats.irq_receive_pmt_irq_n++;
-
 			/* For LPI we need to save the tx status */
-			if (status & core_irq_tx_path_in_lpi_mode) {
-				priv->xstats.irq_tx_path_in_lpi_mode_n++;
+			if (status & CORE_IRQ_TX_PATH_IN_LPI_MODE)
 				priv->tx_path_in_lpi_mode = true;
-			}
-			if (status & core_irq_tx_path_exit_lpi_mode) {
-				priv->xstats.irq_tx_path_exit_lpi_mode_n++;
+			if (status & CORE_IRQ_TX_PATH_EXIT_LPI_MODE)
 				priv->tx_path_in_lpi_mode = false;
-			}
-			if (status & core_irq_rx_path_in_lpi_mode)
-				priv->xstats.irq_rx_path_in_lpi_mode_n++;
-			if (status & core_irq_rx_path_exit_lpi_mode)
-				priv->xstats.irq_rx_path_exit_lpi_mode_n++;
 		}
 	}
 
-- 
1.7.4.4
