From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 2/3] drivers: net: stmmac: rework core ISR to better manage PCS and PMT
Date: Fri, 24 Jun 2016 15:16:25 +0200
Message-ID: <1466774186-2320-3-git-send-email-peppe.cavallaro@st.com>
References: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:54315 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751481AbcFXN1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:27:46 -0400
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5ODOkTv003737
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:45 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 23mw6ejaxf-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:44 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 474E331
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:44 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3049C1B88
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:44 +0000 (GMT)
In-Reply-To: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, all gmac cores disable the PCS block and always
enable the PMT.

Note that this is done in a different way by 3.x and 4.x cores.

With this rework, PCS and PMT interrupt masks can be driven by
parameters now moved inside the mac_device_info structure
and the settings follow what the HW capability register reports.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |  2 ++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    | 30 ++++++++++++++--------
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   | 24 ++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  9 +++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  |  8 +++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 11 +++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 29 ++++++++++++---------
 8 files changed, 79 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 86eba2a..51077a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -529,6 +529,8 @@ struct mac_device_info {
 	int unicast_filter_entries;
 	int mcast_bits_log2;
 	unsigned int rx_csum;
+	unsigned int pcs;
+	unsigned int pmt;
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index e671360..ff3e5ab 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -38,16 +38,26 @@
 #define GMAC_WAKEUP_FILTER	0x00000028	/* Wake-up Frame Filter */
 
 #define GMAC_INT_STATUS		0x00000038	/* interrupt status register */
-enum dwmac1000_irq_status {
-	lpiis_irq = 0x400,
-	time_stamp_irq = 0x0200,
-	mmc_rx_csum_offload_irq = 0x0080,
-	mmc_tx_irq = 0x0040,
-	mmc_rx_irq = 0x0020,
-	mmc_irq = 0x0010,
-	pmt_irq = 0x0008,
-};
-#define GMAC_INT_MASK		0x0000003c	/* interrupt mask register */
+#define GMAC_INT_STATUS_PMT	BIT(3)
+#define GMAC_INT_STATUS_MMCIS	BIT(4)
+#define GMAC_INT_STATUS_MMCRIS	BIT(5)
+#define GMAC_INT_STATUS_MMCTIS	BIT(6)
+#define GMAC_INT_STATUS_MMCCSUM	BIT(7)
+#define GMAC_INT_STATUS_TSTAMP	BIT(9)
+#define GMAC_INT_STATUS_LPIIS	BIT(10)
+
+/* interrupt mask register */
+#define	GMAC_INT_MASK		0x0000003c
+#define	GMAC_INT_DISABLE_RGMII		BIT(0)
+#define	GMAC_INT_DISABLE_PCSLINK	BIT(1)
+#define	GMAC_INT_DISABLE_PCSAN		BIT(2)
+#define	GMAC_INT_DISABLE_PMT		BIT(3)
+#define	GMAC_INT_DISABLE_TIMESTAMP	BIT(9)
+#define	GMAC_INT_DISABLE_PCS	(GMAC_INT_DISABLE_RGMII | \
+				 GMAC_INT_DISABLE_PCSLINK | \
+				 GMAC_INT_DISABLE_PCSAN)
+#define	GMAC_INT_DEFAULT_MASK	(GMAC_INT_DISABLE_TIMESTAMP | \
+				 GMAC_INT_DISABLE_PCS)
 
 /* PMT Control and Status */
 #define GMAC_PMT		0x0000002c
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 9772a43c..0d31f2f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -37,7 +37,10 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	u32 value = readl(ioaddr + GMAC_CONTROL);
+
+	/* Configure GMAC core */
 	value |= GMAC_CORE_INIT;
+
 	if (mtu > 1500)
 		value |= GMAC_CONTROL_2K;
 	if (mtu > 2000)
@@ -46,7 +49,14 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
 	writel(value, ioaddr + GMAC_CONTROL);
 
 	/* Mask GMAC interrupts */
-	writel(0x207, ioaddr + GMAC_INT_MASK);
+	value = GMAC_INT_DEFAULT_MASK;
+
+	if (hw->pmt)
+		value &= ~GMAC_INT_DISABLE_PMT;
+	if (hw->pcs)
+		value &= ~GMAC_INT_DISABLE_PCS;
+
+	writel(value, ioaddr + GMAC_INT_MASK);
 
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Tag detection without filtering */
@@ -283,20 +293,20 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
 	int ret = 0;
 
 	/* Not used events (e.g. MMC interrupts) are not handled. */
-	if ((intr_status & mmc_tx_irq))
+	if ((intr_status & GMAC_INT_STATUS_MMCTIS))
 		x->mmc_tx_irq_n++;
-	if (unlikely(intr_status & mmc_rx_irq))
+	if (unlikely(intr_status & GMAC_INT_STATUS_MMCRIS))
 		x->mmc_rx_irq_n++;
-	if (unlikely(intr_status & mmc_rx_csum_offload_irq))
+	if (unlikely(intr_status & GMAC_INT_STATUS_MMCCSUM))
 		x->mmc_rx_csum_offload_irq_n++;
-	if (unlikely(intr_status & pmt_irq)) {
+	if (unlikely(intr_status & GMAC_INT_DISABLE_PMT)) {
 		/* clear the PMT bits 5 and 6 by reading the PMT status reg */
 		readl(ioaddr + GMAC_PMT);
 		x->irq_receive_pmt_irq_n++;
 	}
 
-	/* MAC trx/rx EEE LPI entry/exit interrupts */
-	if (intr_status & lpiis_irq) {
+	/* MAC tx/rx EEE LPI entry/exit interrupts */
+	if (intr_status & GMAC_INT_STATUS_LPIIS) {
 		/* Clean LPI interrupt by reading the Reg 12 */
 		ret = readl(ioaddr + LPI_CTRL_STATUS);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
index 227fa20..6f4f5ce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
@@ -52,9 +52,18 @@
 #define GMAC_TX_FLOW_CTRL_PT_SHIFT	16
 
 /*  MAC Interrupt bitmap*/
+#define GMAC_INT_RGSMIIS		BIT(0)
+#define GMAC_INT_PCS_LINK		BIT(1)
+#define GMAC_INT_PCS_ANE		BIT(2)
+#define GMAC_INT_PCS_PHYIS		BIT(3)
 #define GMAC_INT_PMT_EN			BIT(4)
 #define GMAC_INT_LPI_EN			BIT(5)
 
+#define	GMAC_PCS_IRQ_DEFAULT	(GMAC_INT_RGSMIIS | GMAC_INT_PCS_LINK |	\
+				 GMAC_INT_PCS_ANE)
+
+#define	GMAC_INT_DEFAULT_MASK	GMAC_INT_PMT_EN
+
 enum dwmac4_irq_status {
 	time_stamp_irq = 0x00001000,
 	mmc_rx_csum_offload_irq = 0x00000800,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 207d8bb..747f3cf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -35,7 +35,13 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	writel(value, ioaddr + GMAC_CONFIG);
 
 	/* Mask GMAC interrupts */
-	writel(GMAC_INT_PMT_EN, ioaddr + GMAC_INT_EN);
+	value = GMAC_INT_DEFAULT_MASK;
+	if (hw->pmt)
+		value |= GMAC_INT_PMT_EN;
+	if (hw->pcs)
+		value |= GMAC_PCS_IRQ_DEFAULT;
+
+	writel(value, ioaddr + GMAC_INT_EN);
 }
 
 static void dwmac4_dump_regs(struct mac_device_info *hw)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 59ae608..8dc9056 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -117,7 +117,6 @@ struct stmmac_priv {
 	int eee_enabled;
 	int eee_active;
 	int tx_lpi_timer;
-	int pcs;
 	unsigned int mode;
 	int extend_desc;
 	struct ptp_clock *ptp_clock;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index a5f4f46..da2d9b5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -276,7 +276,8 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 	struct phy_device *phy = priv->phydev;
 	int rc;
 
-	if ((priv->pcs & STMMAC_PCS_RGMII) || (priv->pcs & STMMAC_PCS_SGMII)) {
+	if (priv->hw->pcs & STMMAC_PCS_RGMII ||
+	    priv->hw->pcs & STMMAC_PCS_SGMII) {
 		struct rgmii_adv adv;
 
 		if (!priv->xstats.pcs_link) {
@@ -361,7 +362,8 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 	struct phy_device *phy = priv->phydev;
 	int rc;
 
-	if ((priv->pcs & STMMAC_PCS_RGMII) || (priv->pcs & STMMAC_PCS_SGMII)) {
+	if (priv->hw->pcs & STMMAC_PCS_RGMII ||
+	    priv->hw->pcs & STMMAC_PCS_SGMII) {
 		u32 mask = ADVERTISED_Autoneg | ADVERTISED_Pause;
 
 		/* Only support ANE */
@@ -457,7 +459,7 @@ stmmac_get_pauseparam(struct net_device *netdev,
 	pause->rx_pause = 0;
 	pause->tx_pause = 0;
 
-	if (priv->pcs && priv->hw->mac->pcs_get_adv_lp) {
+	if (priv->hw->pcs && priv->hw->mac->pcs_get_adv_lp) {
 		struct rgmii_adv adv_lp;
 
 		pause->autoneg = 1;
@@ -487,7 +489,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	struct phy_device *phy = priv->phydev;
 	int new_pause = FLOW_OFF;
 
-	if (priv->pcs && priv->hw->mac->pcs_get_adv_lp) {
+	if (priv->hw->pcs && priv->hw->mac->pcs_get_adv_lp) {
 		struct rgmii_adv adv_lp;
 
 		pause->autoneg = 1;
@@ -507,6 +509,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	priv->flow_ctrl = new_pause;
 	phy->autoneg = pause->autoneg;
+
 	if (phy->autoneg) {
 		if (netif_running(netdev))
 			return phy_start_aneg(phy);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6c43d68..6142fce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -285,8 +285,9 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 	/* Using PCS we cannot dial with the phy registers at this stage
 	 * so we do not support extra feature like EEE.
 	 */
-	if ((priv->pcs == STMMAC_PCS_RGMII) || (priv->pcs == STMMAC_PCS_TBI) ||
-	    (priv->pcs == STMMAC_PCS_RTBI))
+	if ((priv->hw->pcs == STMMAC_PCS_RGMII) ||
+	    (priv->hw->pcs == STMMAC_PCS_TBI) ||
+	    (priv->hw->pcs == STMMAC_PCS_RTBI))
 		goto out;
 
 	/* MAC core supports the EEE feature. */
@@ -799,10 +800,10 @@ static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
 		    (interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
 		    (interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
 			pr_debug("STMMAC: PCS RGMII support enable\n");
-			priv->pcs = STMMAC_PCS_RGMII;
+			priv->hw->pcs = STMMAC_PCS_RGMII;
 		} else if (interface == PHY_INTERFACE_MODE_SGMII) {
 			pr_debug("STMMAC: PCS SGMII support enable\n");
-			priv->pcs = STMMAC_PCS_SGMII;
+			priv->hw->pcs = STMMAC_PCS_SGMII;
 		}
 	}
 }
@@ -1714,7 +1715,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
 	}
 
-	if (priv->pcs && priv->hw->mac->pcs_ctrl_ane)
+	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
 		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, 0, 0);
 
 	/*  set TX ring length */
@@ -1748,8 +1749,9 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_check_ether_addr(priv);
 
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI) {
+	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
+	    priv->hw->pcs != STMMAC_PCS_TBI &&
+	    priv->hw->pcs != STMMAC_PCS_RTBI) {
 		ret = stmmac_init_phy(dev);
 		if (ret) {
 			pr_err("%s: Cannot attach to PHY (error: %d)\n",
@@ -2811,7 +2813,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
 		}
 
 		/* PCS link status */
-		if (priv->pcs) {
+		if (priv->hw->pcs) {
 			if (priv->xstats.pcs_link)
 				netif_carrier_on(dev);
 			else
@@ -3138,6 +3140,7 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		 */
 		priv->plat->enh_desc = priv->dma_cap.enh_desc;
 		priv->plat->pmt = priv->dma_cap.pmt_remote_wake_up;
+		priv->hw->pmt = priv->plat->pmt;
 
 		/* TXCOE doesn't work in thresh DMA mode */
 		if (priv->plat->force_thresh_dma_mode)
@@ -3333,8 +3336,9 @@ int stmmac_dvr_probe(struct device *device,
 
 	stmmac_check_pcs_mode(priv);
 
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI) {
+	if (priv->hw->pcs != STMMAC_PCS_RGMII  &&
+	    priv->hw->pcs != STMMAC_PCS_TBI &&
+	    priv->hw->pcs != STMMAC_PCS_RTBI) {
 		/* MDIO bus Registration */
 		ret = stmmac_mdio_register(ndev);
 		if (ret < 0) {
@@ -3384,8 +3388,9 @@ int stmmac_dvr_remove(struct device *dev)
 		reset_control_assert(priv->stmmac_rst);
 	clk_disable_unprepare(priv->pclk);
 	clk_disable_unprepare(priv->stmmac_clk);
-	if (priv->pcs != STMMAC_PCS_RGMII && priv->pcs != STMMAC_PCS_TBI &&
-	    priv->pcs != STMMAC_PCS_RTBI)
+	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
+	    priv->hw->pcs != STMMAC_PCS_TBI &&
+	    priv->hw->pcs != STMMAC_PCS_RTBI)
 		stmmac_mdio_unregister(ndev);
 	free_netdev(ndev);
 
-- 
2.7.4
