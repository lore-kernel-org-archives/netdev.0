From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 3/3] drivers: net: stmmac: add port selection programming
Date: Fri, 24 Jun 2016 15:16:26 +0200
Message-ID: <1466774186-2320-4-git-send-email-peppe.cavallaro@st.com>
References: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:64494 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751482AbcFXN1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:27:47 -0400
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5ODQmtF013864
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:46 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 23mue5tqrg-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:27:46 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6C9D03F
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:45 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2E3151B88
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:27:45 +0000 (GMT)
In-Reply-To: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of SGMII more, for example when a MAC2MAC connection
is needed, the port selection bits (inside the MAC configuration
registers) have to be programmed according to the link selected.
So the patch adds a new DT parameter to pass the port selection
and to programmed related PCS and CORE to use it.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt      |  3 +++
 drivers/net/ethernet/stmicro/stmmac/common.h          |  1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  | 15 +++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c     | 15 +++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c  |  3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 15 ++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |  2 ++
 include/linux/stmmac.h                                |  1 +
 8 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 95816c5..41b49e6 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -47,6 +47,9 @@ Optional properties:
 				supported by this device instance
 - snps,perfect-filter-entries:	Number of perfect filter entries supported
 				by this device instance
+- snps,ps-speed: port selection speed that can be passed to the core when
+		 PCS is supported. For example, this is used in case of SGMII
+		 and MAC2MAC connection.
 - AXI BUS Mode parameters: below the list of all the parameters to program the
 			   AXI register inside the DMA module:
 	- snps,lpi_en: enable Low Power Interface
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 51077a8..2533b91 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -531,6 +531,7 @@ struct mac_device_info {
 	unsigned int rx_csum;
 	unsigned int pcs;
 	unsigned int pmt;
+	unsigned int ps;
 };
 
 struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr, int mcbins,
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index 0d31f2f..cbefe9e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -46,6 +46,21 @@ static void dwmac1000_core_init(struct mac_device_info *hw, int mtu)
 	if (mtu > 2000)
 		value |= GMAC_CONTROL_JE;
 
+	if (hw->ps) {
+		value |= GMAC_CONTROL_TE;
+
+		if (hw->ps == SPEED_1000) {
+			value &= ~GMAC_CONTROL_PS;
+		} else {
+			value |= GMAC_CONTROL_PS;
+
+			if (hw->ps == SPEED_10)
+				value &= ~GMAC_CONTROL_FES;
+			else
+				value |= GMAC_CONTROL_FES;
+		}
+	}
+
 	writel(value, ioaddr + GMAC_CONTROL);
 
 	/* Mask GMAC interrupts */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 747f3cf..df5580d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -32,6 +32,21 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
 	if (mtu > 2000)
 		value |= GMAC_CONFIG_JE;
 
+	if (hw->ps) {
+		value |= GMAC_CONFIG_TE;
+
+		if (hw->ps == SPEED_1000) {
+			value &= ~GMAC_CONFIG_PS;
+		} else {
+			value |= GMAC_CONFIG_PS;
+
+			if (hw->ps == SPEED_10)
+				value &= ~GMAC_CONFIG_FES;
+			else
+				value |= GMAC_CONFIG_FES;
+		}
+	}
+
 	writel(value, ioaddr + GMAC_CONFIG);
 
 	/* Mask GMAC interrupts */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index da2d9b5..1e06173 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -380,7 +380,8 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 		spin_lock(&priv->lock);
 
 		if (priv->hw->mac->pcs_ctrl_ane)
-			priv->hw->mac->pcs_ctrl_ane(priv->ioaddr, 1, 0, 0);
+			priv->hw->mac->pcs_ctrl_ane(priv->ioaddr, 1,
+						    priv->hw->ps, 0);
 
 		spin_unlock(&priv->lock);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 6142fce..aab777c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1666,6 +1666,19 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	if (priv->plat->bus_setup)
 		priv->plat->bus_setup(priv->ioaddr);
 
+	/* PS and related bits will be programmed according to the speed */
+	if (priv->hw->pcs) {
+		int speed = priv->plat->mac_port_sel_speed;
+
+		if ((speed == SPEED_10) || (speed == SPEED_100) ||
+		    (speed == SPEED_1000)) {
+			priv->hw->ps = speed;
+		} else {
+			dev_warn(priv->device, "invalid port speed\n");
+			priv->hw->ps = 0;
+		}
+	}
+
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->hw, dev->mtu);
 
@@ -1716,7 +1729,7 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 	}
 
 	if (priv->hw->pcs && priv->hw->mac->pcs_ctrl_ane)
-		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, 0, 0);
+		priv->hw->mac->pcs_ctrl_ane(priv->hw, 1, priv->hw->ps, 0);
 
 	/*  set TX ring length */
 	if (priv->hw->dma->set_tx_ring_len)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index a96714d..f7dfc0a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -319,6 +319,8 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 		pr_warn("force_sf_dma_mode is ignored if force_thresh_dma_mode is set.");
 	}
 
+	of_property_read_u32(np, "snps,ps-speed", &plat->mac_port_sel_speed);
+
 	plat->axi = stmmac_axi_setup(pdev);
 
 	return plat;
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0507dbf..705840e 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -141,5 +141,6 @@ struct plat_stmmacenet_data {
 	struct stmmac_axi *axi;
 	int has_gmac4;
 	bool tso_en;
+	int mac_port_sel_speed;
 };
 #endif
-- 
2.7.4
