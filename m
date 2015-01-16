From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 09/12] amd-xgbe-phy: Properly support the FEC
 auto-negotiation
Date: Fri, 16 Jan 2015 12:47:05 -0600
Message-ID: <20150116184705.18809.97069.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44024 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756796AbbAPSy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:29 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advertise and apply the Forward Error Correction capabilities of the
device based on the FEC ability of the device. Also, remove the use
of some hard coded values related to KR and FEC in preference of some
#defines.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   44 ++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 11 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 7fde508..7207f36 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -99,10 +99,21 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 
 #define XGBE_PHY_RATECHANGE_COUNT	500
 
+#define XGBE_PHY_KR_TRAINING_START	0x01
+#define XGBE_PHY_KR_TRAINING_ENABLE	0x02
+
+#define XGBE_PHY_FEC_ENABLE		0x01
+#define XGBE_PHY_FEC_FORWARD		0x02
+#define XGBE_PHY_FEC_MASK		0x03
+
 #ifndef MDIO_PMA_10GBR_PMD_CTRL
 #define MDIO_PMA_10GBR_PMD_CTRL		0x0096
 #endif
 
+#ifndef MDIO_PMA_10GBR_FEC_ABILITY
+#define MDIO_PMA_10GBR_FEC_ABILITY	0x00aa
+#endif
+
 #ifndef MDIO_PMA_10GBR_FEC_CTRL
 #define MDIO_PMA_10GBR_FEC_CTRL		0x00ab
 #endif
@@ -345,6 +356,7 @@ struct amd_xgbe_phy_priv {
 	struct workqueue_struct *an_workqueue;
 	unsigned int an_supported;
 	unsigned int parallel_detect;
+	unsigned int fec_ability;
 
 	unsigned int lpm_ctrl;		/* CTRL1 for resume */
 };
@@ -357,7 +369,7 @@ static int amd_xgbe_an_enable_kr_training(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	ret |= 0x02;
+	ret |= XGBE_PHY_KR_TRAINING_ENABLE;
 	phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_PMD_CTRL, ret);
 
 	return 0;
@@ -371,7 +383,7 @@ static int amd_xgbe_an_disable_kr_training(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	ret &= ~0x02;
+	ret &= ~XGBE_PHY_KR_TRAINING_ENABLE;
 	phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_PMD_CTRL, ret);
 
 	return 0;
@@ -690,10 +702,9 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 	if (ret < 0)
 		return AMD_XGBE_AN_ERROR;
 
+	ret &= ~XGBE_PHY_FEC_MASK;
 	if ((ad_reg & 0xc000) && (lp_reg & 0xc000))
-		ret |= 0x01;
-	else
-		ret &= ~0x01;
+		ret |= priv->fec_ability;
 
 	phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_FEC_CTRL, ret);
 
@@ -702,12 +713,15 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 	if (ret < 0)
 		return AMD_XGBE_AN_ERROR;
 
-	XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 1);
+	if (ret & XGBE_PHY_KR_TRAINING_ENABLE) {
+		XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 1);
 
-	ret |= 0x01;
-	phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_PMD_CTRL, ret);
+		ret |= XGBE_PHY_KR_TRAINING_START;
+		phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_PMD_CTRL,
+			      ret);
 
-	XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 0);
+		XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 0);
+	}
 
 	return AMD_XGBE_AN_PAGE_RECEIVED;
 }
@@ -1092,12 +1106,16 @@ static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 		priv->an_irq_allocated = 1;
 	}
 
+	ret = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_FEC_ABILITY);
+	if (ret < 0)
+		return ret;
+	priv->fec_ability = ret & XGBE_PHY_FEC_MASK;
+
 	/* Initialize supported features */
 	phydev->supported = SUPPORTED_Autoneg;
 	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 	phydev->supported |= SUPPORTED_Backplane;
-	phydev->supported |= SUPPORTED_10000baseKR_Full |
-			     SUPPORTED_10000baseR_FEC;
+	phydev->supported |= SUPPORTED_10000baseKR_Full;
 	switch (priv->speed_set) {
 	case AMD_XGBE_PHY_SPEEDSET_1000_10000:
 		phydev->supported |= SUPPORTED_1000baseKX_Full;
@@ -1106,6 +1124,10 @@ static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 		phydev->supported |= SUPPORTED_2500baseX_Full;
 		break;
 	}
+
+	if (priv->fec_ability & XGBE_PHY_FEC_ENABLE)
+		phydev->supported |= SUPPORTED_10000baseR_FEC;
+
 	phydev->advertising = phydev->supported;
 
 	/* Set initial mode - call the mode setting routines
