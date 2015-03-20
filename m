From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v3 1/9] amd-xgbe-phy: Use phydev advertising field
 vs supported
Date: Fri, 20 Mar 2015 11:49:42 -0500
Message-ID: <20150320164942.13799.63065.stgit@tlendack-t1.amdoffice.net>
References: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0122.outbound.protection.outlook.com ([65.55.169.122]:37120
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751585AbbCTQtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 12:49:53 -0400
In-Reply-To: <20150320164936.13799.13796.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With ethtool being able to control what is advertised, the advertising
field is what should be used for priming the auto-negotiation registers
and for various other checks, instead of the supported field.

Also, move the initial setting of the supported and advertising fields
into the probe function so that they are not reset each time the device
is brought up, thus allowing the user to set as desired before bringing
the device up.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   77 ++++++++++++++++++++--------------------
 1 file changed, 38 insertions(+), 39 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 32efbd4..acb4449 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -932,8 +932,8 @@ static enum amd_xgbe_phy_an amd_xgbe_an_incompat_link(struct phy_device *phydev)
 	if (amd_xgbe_phy_in_kr_mode(phydev)) {
 		priv->kr_state = AMD_XGBE_RX_ERROR;
 
-		if (!(phydev->supported & SUPPORTED_1000baseKX_Full) &&
-		    !(phydev->supported & SUPPORTED_2500baseX_Full))
+		if (!(phydev->advertising & SUPPORTED_1000baseKX_Full) &&
+		    !(phydev->advertising & SUPPORTED_2500baseX_Full))
 			return AMD_XGBE_AN_NO_LINK;
 
 		if (priv->kx_state != AMD_XGBE_RX_BPA)
@@ -941,7 +941,7 @@ static enum amd_xgbe_phy_an amd_xgbe_an_incompat_link(struct phy_device *phydev)
 	} else {
 		priv->kx_state = AMD_XGBE_RX_ERROR;
 
-		if (!(phydev->supported & SUPPORTED_10000baseKR_Full))
+		if (!(phydev->advertising & SUPPORTED_10000baseKR_Full))
 			return AMD_XGBE_AN_NO_LINK;
 
 		if (priv->kr_state != AMD_XGBE_RX_BPA)
@@ -1101,7 +1101,7 @@ static int amd_xgbe_an_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->supported & SUPPORTED_10000baseR_FEC)
+	if (phydev->advertising & SUPPORTED_10000baseR_FEC)
 		ret |= 0xc000;
 	else
 		ret &= ~0xc000;
@@ -1113,13 +1113,13 @@ static int amd_xgbe_an_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+	if (phydev->advertising & SUPPORTED_10000baseKR_Full)
 		ret |= 0x80;
 	else
 		ret &= ~0x80;
 
-	if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
-	    (phydev->supported & SUPPORTED_2500baseX_Full))
+	if ((phydev->advertising & SUPPORTED_1000baseKX_Full) ||
+	    (phydev->advertising & SUPPORTED_2500baseX_Full))
 		ret |= 0x20;
 	else
 		ret &= ~0x20;
@@ -1131,12 +1131,12 @@ static int amd_xgbe_an_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->supported & SUPPORTED_Pause)
+	if (phydev->advertising & SUPPORTED_Pause)
 		ret |= 0x400;
 	else
 		ret &= ~0x400;
 
-	if (phydev->supported & SUPPORTED_Asym_Pause)
+	if (phydev->advertising & SUPPORTED_Asym_Pause)
 		ret |= 0x800;
 	else
 		ret &= ~0x800;
@@ -1212,38 +1212,14 @@ static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 		priv->an_irq_allocated = 1;
 	}
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_FEC_ABILITY);
-	if (ret < 0)
-		return ret;
-	priv->fec_ability = ret & XGBE_PHY_FEC_MASK;
-
-	/* Initialize supported features */
-	phydev->supported = SUPPORTED_Autoneg;
-	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	phydev->supported |= SUPPORTED_Backplane;
-	phydev->supported |= SUPPORTED_10000baseKR_Full;
-	switch (priv->speed_set) {
-	case AMD_XGBE_PHY_SPEEDSET_1000_10000:
-		phydev->supported |= SUPPORTED_1000baseKX_Full;
-		break;
-	case AMD_XGBE_PHY_SPEEDSET_2500_10000:
-		phydev->supported |= SUPPORTED_2500baseX_Full;
-		break;
-	}
-
-	if (priv->fec_ability & XGBE_PHY_FEC_ENABLE)
-		phydev->supported |= SUPPORTED_10000baseR_FEC;
-
-	phydev->advertising = phydev->supported;
-
 	/* Set initial mode - call the mode setting routines
 	 * directly to insure we are properly configured
 	 */
-	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+	if (phydev->advertising & SUPPORTED_10000baseKR_Full)
 		ret = amd_xgbe_phy_xgmii_mode(phydev);
-	else if (phydev->supported & SUPPORTED_1000baseKX_Full)
+	else if (phydev->advertising & SUPPORTED_1000baseKX_Full)
 		ret = amd_xgbe_phy_gmii_mode(phydev);
-	else if (phydev->supported & SUPPORTED_2500baseX_Full)
+	else if (phydev->advertising & SUPPORTED_2500baseX_Full)
 		ret = amd_xgbe_phy_gmii_2500_mode(phydev);
 	else
 		ret = -EINVAL;
@@ -1315,10 +1291,10 @@ static int __amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 	disable_irq(priv->an_irq);
 
 	/* Start auto-negotiation in a supported mode */
-	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+	if (phydev->advertising & SUPPORTED_10000baseKR_Full)
 		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KR);
-	else if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
-		 (phydev->supported & SUPPORTED_2500baseX_Full))
+	else if ((phydev->advertising & SUPPORTED_1000baseKX_Full) ||
+		 (phydev->advertising & SUPPORTED_2500baseX_Full))
 		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX);
 	else
 		ret = -EINVAL;
@@ -1746,6 +1722,29 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		       sizeof(priv->serdes_dfe_tap_ena));
 	}
 
+	/* Initialize supported features */
+	phydev->supported = SUPPORTED_Autoneg;
+	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	phydev->supported |= SUPPORTED_Backplane;
+	phydev->supported |= SUPPORTED_10000baseKR_Full;
+	switch (priv->speed_set) {
+	case AMD_XGBE_PHY_SPEEDSET_1000_10000:
+		phydev->supported |= SUPPORTED_1000baseKX_Full;
+		break;
+	case AMD_XGBE_PHY_SPEEDSET_2500_10000:
+		phydev->supported |= SUPPORTED_2500baseX_Full;
+		break;
+	}
+
+	ret = phy_read_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_FEC_ABILITY);
+	if (ret < 0)
+		return ret;
+	priv->fec_ability = ret & XGBE_PHY_FEC_MASK;
+	if (priv->fec_ability & XGBE_PHY_FEC_ENABLE)
+		phydev->supported |= SUPPORTED_10000baseR_FEC;
+
+	phydev->advertising = phydev->supported;
+
 	phydev->priv = priv;
 
 	if (!priv->adev || acpi_disabled)
