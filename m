From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 8/9] stmmac: initial support to manage pcs modes
Date: Thu,  7 Mar 2013 11:50:18 +0100
Message-ID: <1362653419-1047-9-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:46020 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755293Ab3CGKze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:55:34 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the minimal support to manage the PCS
modes (RGMII/SGMII) and restart the ANE.
Both TBI and RTBI are not yet supported.

Thanks to Byungho that wrote some part of this code
and tested SGMII too.

The only thing to be fixed is the get/set pause in
ethtool.

Signed-off-by: Byungho An <bh74.an@samsung.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |   21 +++++
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   34 +++++++
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   64 +++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   94 ++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   59 ++++++++++---
 6 files changed, 257 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 42e2a87..a9f8e77 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -121,6 +121,9 @@ struct stmmac_extra_stats {
 	unsigned long irq_pcs_ane_n;
 	unsigned long irq_pcs_link_n;
 	unsigned long irq_rgmii_n;
+	unsigned long pcs_link;
+	unsigned long pcs_duplex;
+	unsigned long pcs_speed;
 #ifdef CONFIG_STMMAC_EXTENDED_DESC
 	/* Extended RDES status */
 	unsigned long ip_hdr_err;
@@ -167,6 +170,12 @@ struct stmmac_extra_stats {
 #define FLOW_TX		2
 #define FLOW_AUTO	(FLOW_TX | FLOW_RX)
 
+/* PCS defines */
+#define STMMAC_PCS_RGMII	(1 << 0)
+#define STMMAC_PCS_SGMII	(1 << 1)
+#define STMMAC_PCS_TBI		(1 << 2)
+#define STMMAC_PCS_RTBI		(1 << 3)
+
 #define SF_DMA_MODE 1 /* DMA STORE-AND-FORWARD Operation Mode */
 
 /* DAM HW feature register fields */
@@ -232,6 +241,16 @@ enum dma_irq_status {
 #define	CORE_PCS_LINK_STATUS		(1 << 6)
 #define	CORE_RGMII_IRQ			(1 << 7)
 
+struct rgmii_adv {
+	unsigned int pause;
+	unsigned int duplex;
+	unsigned int lp_pause;
+	unsigned int lp_duplex;
+};
+
+#define STMMAC_PCS_PAUSE	1
+#define STMMAC_PCS_ASYM_PAUSE	2
+
 /* DMA HW capabilities */
 struct dma_features {
 	unsigned int mbps_10_100;
@@ -384,6 +403,8 @@ struct stmmac_ops {
 	void (*reset_eee_mode) (void __iomem *ioaddr);
 	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int tw);
 	void (*set_eee_pls) (void __iomem *ioaddr, int link);
+	void (*ctrl_ane) (void __iomem *ioaddr, bool restart);
+	void (*get_adv) (void __iomem *ioaddr, struct rgmii_adv *adv);
 };
 
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 6dd689e..57f4e8f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -98,6 +98,38 @@ enum power_event {
 #define GMAC_TBI	0x000000d4	/* TBI extend status */
 #define GMAC_S_R_GMII	0x000000d8	/* SGMII RGMII status */
 
+/* AN Configuration defines */
+#define GMAC_AN_CTRL_RAN	0x00000200 /* Restart Auto-Negotiation */
+#define GMAC_AN_CTRL_ANE	0x00001000 /* Auto-Negotiation Enable */
+#define GMAC_AN_CTRL_ELE	0x00004000 /* External Loopback Enable */
+#define GMAC_AN_CTRL_ECD	0x00010000 /* Enable Comma Detect */
+#define GMAC_AN_CTRL_LR	0x00020000 /* Lock to Reference */
+#define GMAC_AN_CTRL_SGMRAL	0x00040000 /* SGMII RAL Control */
+
+/* AN Status defines */
+#define GMAC_AN_STATUS_LS	0x00000004 /* Link Status 0:down 1:up */
+#define GMAC_AN_STATUS_ANA	0x00000008 /* Auto-Negotiation Ability */
+#define GMAC_AN_STATUS_ANC	0x00000020 /* Auto-Negotiation Complete */
+#define GMAC_AN_STATUS_ES	0x00000100 /* Extended Status */
+
+/* Register 54 (SGMII/RGMII status register) */
+#define GMAC_S_R_GMII_LINK		0x8
+#define GMAC_S_R_GMII_SPEED		0x5
+#define GMAC_S_R_GMII_SPEED_SHIFT	0x1
+#define GMAC_S_R_GMII_MODE		0x1
+#define GMAC_S_R_GMII_SPEED_125		2
+#define GMAC_S_R_GMII_SPEED_25		1
+
+/* Common ADV and LPA defines */
+#define GMAC_ANE_FD		(1 << 5)
+#define GMAC_ANE_HD		(1 << 6)
+#define GMAC_ANE_PSE		(3 << 7)
+#define GMAC_ANE_PSE_SHIFT	7
+
+ /* GMAC Configuration defines */
+#define GMAC_CONTROL_TC	0x01000000 /* Transmit Conf. in RGMII/SGMII */
+#define GMAC_CONTROL_WD	0x00800000 /* Disable Watchdog on receive */
+
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC	0x01000000	/* Transmit Conf. in RGMII/SGMII */
 #define GMAC_CONTROL_WD	0x00800000	/* Disable Watchdog on receive */
@@ -232,5 +264,7 @@ enum rtc_control {
 #define GMAC_MMC_TX_INTR   0x108
 #define GMAC_MMC_RX_CSUM_OFFLOAD   0x208
 
+
+
 extern const struct stmmac_dma_ops dwmac1000_dma_ops;
 #endif /* __DWMAC1000_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index ff4c79e..29138da 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -28,6 +28,7 @@
 
 #include <linux/crc32.h>
 #include <linux/slab.h>
+#include <linux/ethtool.h>
 #include <asm/io.h>
 #include "dwmac1000.h"
 
@@ -193,7 +194,6 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
-
 static int dwmac1000_irq_status(void __iomem *ioaddr,
 				struct stmmac_extra_stats *x)
 {
@@ -252,9 +252,30 @@ static int dwmac1000_irq_status(void __iomem *ioaddr,
 		x->irq_pcs_ane_n++;
 	}
 	if (intr_status & rgmii_irq) {
-		CHIP_DBG(KERN_INFO "GMAC RGMII IRQ status\n");
-		readl(ioaddr + GMAC_S_R_GMII);
+		u32 status  = readl(ioaddr + GMAC_S_R_GMII);
+		CHIP_DBG(KERN_INFO "GMAC RGMII/SGMII interrupt\n");
 		x->irq_rgmii_n++;
+
+		/* Save and dump the link status. */
+		if (status & GMAC_S_R_GMII_LINK) {
+			int speed_value = (status & GMAC_S_R_GMII_SPEED) >>
+					  GMAC_S_R_GMII_SPEED_SHIFT;
+			x->pcs_duplex = (status & GMAC_S_R_GMII_MODE);
+
+			if (speed_value == GMAC_S_R_GMII_SPEED_125)
+				x->pcs_speed = SPEED_1000;
+			else if (speed_value == GMAC_S_R_GMII_SPEED_25)
+				x->pcs_speed = SPEED_100;
+			else
+				x->pcs_speed = SPEED_10;
+
+			x->pcs_link = 1;
+			pr_debug("Link is Up - %d/%s\n", (int) x->pcs_speed,
+				 x->pcs_duplex ? "Full" : "Half");
+		} else {
+			x->pcs_link = 0;
+			pr_debug("Link is Down\n");
+		}
 	}
 
 	return ret;
@@ -309,6 +330,41 @@ static void  dwmac1000_set_eee_timer(void __iomem *ioaddr, int ls, int tw)
 	writel(value, ioaddr + LPI_TIMER_CTRL);
 }
 
+static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
+{
+	u32 value;
+
+	value = readl(ioaddr + GMAC_AN_CTRL);
+	/* auto negotiation enable and External Loopback enable */
+	value = GMAC_AN_CTRL_ANE | GMAC_AN_CTRL_ELE;
+
+	if (restart)
+		value |= GMAC_AN_CTRL_RAN;
+
+	writel(value, ioaddr + GMAC_AN_CTRL);
+}
+
+static void dwmac1000_get_adv(void __iomem *ioaddr, struct rgmii_adv *adv)
+{
+	u32 value = readl(ioaddr + GMAC_ANE_ADV);
+
+	if (value & GMAC_ANE_FD)
+		adv->duplex = DUPLEX_FULL;
+	if (value & GMAC_ANE_HD)
+		adv->duplex |= DUPLEX_HALF;
+
+	adv->pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
+
+	value = readl(ioaddr + GMAC_ANE_LPA);
+
+	if (value & GMAC_ANE_FD)
+		adv->lp_duplex = DUPLEX_FULL;
+	if (value & GMAC_ANE_HD)
+		adv->lp_duplex = DUPLEX_HALF;
+
+	adv->lp_pause = (value & GMAC_ANE_PSE) >> GMAC_ANE_PSE_SHIFT;
+}
+
 static const struct stmmac_ops dwmac1000_ops = {
 	.core_init = dwmac1000_core_init,
 	.rx_ipc = dwmac1000_rx_ipc_enable,
@@ -323,6 +379,8 @@ static const struct stmmac_ops dwmac1000_ops = {
 	.reset_eee_mode =  dwmac1000_reset_eee_mode,
 	.set_eee_timer =  dwmac1000_set_eee_timer,
 	.set_eee_pls =  dwmac1000_set_eee_pls,
+	.ctrl_ane = dwmac1000_ctrl_ane,
+	.get_adv = dwmac1000_get_adv,
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index a9a10dd..200011d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -99,6 +99,7 @@ struct stmmac_priv {
 	u32 tx_coal_timer;
 	int use_riwt;
 	u32 rx_riwt;
+	int pcs;
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
 	int hwts_tx_en;
 	int hwts_rx_en;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index d78234e..f5cc5ce 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -247,6 +247,70 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = priv->phydev;
 	int rc;
+
+	if ((priv->pcs & STMMAC_PCS_RGMII) || (priv->pcs & STMMAC_PCS_SGMII)) {
+		struct rgmii_adv adv;
+
+		if (!priv->xstats.pcs_link) {
+			ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+			cmd->duplex = DUPLEX_UNKNOWN;
+			return 0;
+		}
+		cmd->duplex = priv->xstats.pcs_duplex;
+
+		ethtool_cmd_speed_set(cmd, priv->xstats.pcs_speed);
+
+		/* Get and convert ADV/LP_ADV from the HW AN registers */
+		if (priv->hw->mac->get_adv)
+			priv->hw->mac->get_adv(priv->ioaddr, &adv);
+		else
+			return -EOPNOTSUPP;	/* should never happen indeed */
+
+		/* Encoding of PSE bits is defined in 802.3z, 37.2.1.4 */
+
+		if (adv.pause & STMMAC_PCS_PAUSE)
+			cmd->advertising |= ADVERTISED_Pause;
+		if (adv.pause & STMMAC_PCS_ASYM_PAUSE)
+			cmd->advertising |= ADVERTISED_Asym_Pause;
+		if (adv.lp_pause & STMMAC_PCS_PAUSE)
+			cmd->lp_advertising |= ADVERTISED_Pause;
+		if (adv.lp_pause & STMMAC_PCS_ASYM_PAUSE)
+			cmd->lp_advertising |= ADVERTISED_Asym_Pause;
+
+		/* Reg49[3] always set because ANE is always supported */
+		cmd->autoneg = ADVERTISED_Autoneg;
+		cmd->supported |= SUPPORTED_Autoneg;
+		cmd->advertising |= ADVERTISED_Autoneg;
+		cmd->lp_advertising |= ADVERTISED_Autoneg;
+
+		if (adv.duplex) {
+			cmd->supported |= (SUPPORTED_1000baseT_Full |
+					   SUPPORTED_100baseT_Full |
+					   SUPPORTED_10baseT_Full);
+			cmd->advertising |= (ADVERTISED_1000baseT_Full |
+					     ADVERTISED_100baseT_Full |
+					     ADVERTISED_10baseT_Full);
+		} else {
+			cmd->supported |= (SUPPORTED_1000baseT_Half |
+					   SUPPORTED_100baseT_Half |
+					   SUPPORTED_10baseT_Half);
+			cmd->advertising |= (ADVERTISED_1000baseT_Half |
+					     ADVERTISED_100baseT_Half |
+					     ADVERTISED_10baseT_Half);
+		}
+		if (adv.lp_duplex)
+			cmd->lp_advertising |= (ADVERTISED_1000baseT_Full |
+						ADVERTISED_100baseT_Full |
+						ADVERTISED_10baseT_Full);
+		else
+			cmd->lp_advertising |= (ADVERTISED_1000baseT_Half |
+						ADVERTISED_100baseT_Half |
+						ADVERTISED_10baseT_Half);
+		cmd->port = PORT_OTHER;
+
+		return 0;
+	}
+
 	if (phy == NULL) {
 		pr_err("%s: %s: PHY is not registered\n",
 		       __func__, dev->name);
@@ -271,6 +335,30 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 	struct phy_device *phy = priv->phydev;
 	int rc;
 
+	if ((priv->pcs & STMMAC_PCS_RGMII) || (priv->pcs & STMMAC_PCS_SGMII)) {
+		u32 mask = ADVERTISED_Autoneg | ADVERTISED_Pause;
+
+		/* Only support ANE */
+		if (cmd->autoneg != AUTONEG_ENABLE)
+			return -EINVAL;
+
+		if (cmd->autoneg == AUTONEG_ENABLE) {
+			mask &= (ADVERTISED_1000baseT_Half |
+			ADVERTISED_1000baseT_Full |
+			ADVERTISED_100baseT_Half |
+			ADVERTISED_100baseT_Full |
+			ADVERTISED_10baseT_Half |
+			ADVERTISED_10baseT_Full);
+
+			spin_lock(&priv->lock);
+			if (priv->hw->mac->ctrl_ane)
+				priv->hw->mac->ctrl_ane(priv->ioaddr, 1);
+			spin_unlock(&priv->lock);
+		}
+
+		return 0;
+	}
+
 	spin_lock(&priv->lock);
 	rc = phy_ethtool_sset(phy, cmd);
 	spin_unlock(&priv->lock);
@@ -340,6 +428,9 @@ stmmac_get_pauseparam(struct net_device *netdev,
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
 
+	if (priv->pcs)	/* FIXME */
+		return;
+
 	spin_lock(&priv->lock);
 
 	pause->rx_pause = 0;
@@ -363,6 +454,9 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	int new_pause = FLOW_OFF;
 	int ret = 0;
 
+	if (priv->pcs)	/* FIXME */
+		return -EOPNOTSUPP;
+
 	spin_lock(&priv->lock);
 
 	if (pause->rx_pause)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7d2ee6f..a25b54c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -733,6 +733,24 @@ static void stmmac_adjust_link(struct net_device *dev)
 	DBG(probe, DEBUG, "stmmac_adjust_link: exiting\n");
 }
 
+static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
+{
+	int interface = priv->plat->interface;
+
+	if (priv->dma_cap.pcs) {
+		if ((interface & PHY_INTERFACE_MODE_RGMII) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_ID) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_RXID) ||
+		    (interface & PHY_INTERFACE_MODE_RGMII_TXID)) {
+			pr_debug("STMMAC: PCS RGMII support enable\n");
+			priv->pcs = STMMAC_PCS_RGMII;
+		} else if (interface & PHY_INTERFACE_MODE_SGMII) {
+			pr_debug("STMMAC: PCS SGMII support enable\n");
+			priv->pcs = STMMAC_PCS_SGMII;
+		}
+	}
+}
+
 /**
  * stmmac_init_phy - PHY initialization
  * @dev: net device structure
@@ -1372,13 +1390,15 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_check_ether_addr(priv);
 
-	ret = stmmac_init_phy(dev);
-	if (unlikely(ret)) {
-		pr_err("%s: Cannot attach to PHY (error: %d)\n", __func__, ret);
-		goto open_error;
+	if (!priv->pcs) {
+		ret = stmmac_init_phy(dev);
+		if (unlikely(ret)) {
+			pr_err("%s: Cannot attach to PHY (error: %d)\n",
+			       __func__, ret);
+			goto open_error;
+		}
 	}
 
-
 	/* Create and initialize the TX/RX descriptors chains. */
 	priv->dma_tx_size = STMMAC_ALIGN(dma_txsize);
 	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
@@ -1469,7 +1489,12 @@ static int stmmac_open(struct net_device *dev)
 		phy_start(priv->phydev);
 
 	priv->tx_lpi_timer = STMMAC_DEFAULT_TWT_LS_TIMER;
-	priv->eee_enabled = stmmac_eee_init(priv);
+
+	/* Using PCS we cannot dial with the phy registers at this stage
+	 * so we do not support extra feature like EEE.
+	 */
+	if (!priv->pcs)
+		priv->eee_enabled = stmmac_eee_init(priv);
 
 	stmmac_init_tx_coalesce(priv);
 
@@ -1478,6 +1503,9 @@ static int stmmac_open(struct net_device *dev)
 		priv->hw->dma->rx_watchdog(priv->ioaddr, MAX_DMA_RIWT);
 	}
 
+	if (priv->pcs && priv->hw->mac->ctrl_ane)
+		priv->hw->mac->ctrl_ane(priv->ioaddr, 0);
+
 	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
@@ -2437,12 +2465,16 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	else
 		priv->clk_csr = priv->plat->clk_csr;
 
-	/* MDIO bus Registration */
-	ret = stmmac_mdio_register(ndev);
-	if (ret < 0) {
-		pr_debug("%s: MDIO bus (id: %d) registration failed",
-			 __func__, priv->plat->bus_id);
-		goto error_mdio_register;
+	stmmac_check_pcs_mode(priv);
+
+	if (!priv->pcs) {
+		/* MDIO bus Registration */
+		ret = stmmac_mdio_register(ndev);
+		if (ret < 0) {
+			pr_debug("%s: MDIO bus (id: %d) registration failed",
+				 __func__, priv->plat->bus_id);
+			goto error_mdio_register;
+		}
 	}
 
 	return priv;
@@ -2475,7 +2507,8 @@ int stmmac_dvr_remove(struct net_device *ndev)
 	priv->hw->dma->stop_tx(priv->ioaddr);
 
 	stmmac_set_mac(priv->ioaddr, false);
-	stmmac_mdio_unregister(ndev);
+	if (!priv->pcs)
+		stmmac_mdio_unregister(ndev);
 	netif_carrier_off(ndev);
 	unregister_netdev(ndev);
 	free_netdev(ndev);
-- 
1.7.4.4
