From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/4] amd-xgbe-phy: Check device for current speed
 mode (KR/KX)
Date: Wed, 3 Sep 2014 12:14:16 -0500
Message-ID: <20140903171416.9710.7686.stgit@tlendack-t1.amdoffice.net>
References: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0146.outbound.protection.outlook.com ([157.56.110.146]:22561
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756455AbaICR2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:28:49 -0400
In-Reply-To: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since device resets can change the current mode it's possible to think
the device is in a different mode than it actually is.  Rather than
trying to determine every place that is needed to set/save the current
mode, be safe and check the devices actual mode when needed rather than
trying to track it.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |  135 +++++++++++++++++++++-------------------
 1 file changed, 72 insertions(+), 63 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index f3230ee..b3cef20 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -331,7 +331,6 @@ struct amd_xgbe_phy_priv {
 
 	/* Maintain link status for re-starting auto-negotiation */
 	unsigned int link;
-	enum amd_xgbe_phy_mode mode;
 	unsigned int speed_set;
 
 	/* Auto-negotiation state machine support */
@@ -468,8 +467,6 @@ static int amd_xgbe_phy_xgmii_mode(struct phy_device *phydev)
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
-	priv->mode = AMD_XGBE_MODE_KR;
-
 	return 0;
 }
 
@@ -518,8 +515,6 @@ static int amd_xgbe_phy_gmii_2500_mode(struct phy_device *phydev)
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
-	priv->mode = AMD_XGBE_MODE_KX;
-
 	return 0;
 }
 
@@ -568,18 +563,43 @@ static int amd_xgbe_phy_gmii_mode(struct phy_device *phydev)
 
 	amd_xgbe_phy_serdes_complete_ratechange(phydev);
 
-	priv->mode = AMD_XGBE_MODE_KX;
+	return 0;
+}
+
+static int amd_xgbe_phy_cur_mode(struct phy_device *phydev,
+				 enum amd_xgbe_phy_mode *mode)
+{
+	int ret;
+
+	ret = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL2);
+	if (ret < 0)
+		return ret;
+
+	if ((ret & MDIO_PCS_CTRL2_TYPE) == MDIO_PCS_CTRL2_10GBR)
+		*mode = AMD_XGBE_MODE_KR;
+	else
+		*mode = AMD_XGBE_MODE_KX;
 
 	return 0;
 }
 
+static bool amd_xgbe_phy_in_kr_mode(struct phy_device *phydev)
+{
+	enum amd_xgbe_phy_mode mode;
+
+	if (amd_xgbe_phy_cur_mode(phydev, &mode))
+		return false;
+
+	return (mode == AMD_XGBE_MODE_KR);
+}
+
 static int amd_xgbe_phy_switch_mode(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	int ret;
 
 	/* If we are in KR switch to KX, and vice-versa */
-	if (priv->mode == AMD_XGBE_MODE_KR) {
+	if (amd_xgbe_phy_in_kr_mode(phydev)) {
 		if (priv->speed_set == AMD_XGBE_PHY_SPEEDSET_1000_10000)
 			ret = amd_xgbe_phy_gmii_mode(phydev);
 		else
@@ -591,27 +611,31 @@ static int amd_xgbe_phy_switch_mode(struct phy_device *phydev)
 	return ret;
 }
 
-static enum amd_xgbe_phy_an amd_xgbe_an_switch_mode(struct phy_device *phydev)
+static int amd_xgbe_phy_set_mode(struct phy_device *phydev,
+				 enum amd_xgbe_phy_mode mode)
 {
+	enum amd_xgbe_phy_mode cur_mode;
 	int ret;
 
-	ret = amd_xgbe_phy_switch_mode(phydev);
-	if (ret < 0)
-		return AMD_XGBE_AN_ERROR;
+	ret = amd_xgbe_phy_cur_mode(phydev, &cur_mode);
+	if (ret)
+		return ret;
 
-	return AMD_XGBE_AN_START;
+	if (mode != cur_mode)
+		ret = amd_xgbe_phy_switch_mode(phydev);
+
+	return ret;
 }
 
 static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 						    enum amd_xgbe_phy_rx *state)
 {
-	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	int ad_reg, lp_reg, ret;
 
 	*state = AMD_XGBE_RX_COMPLETE;
 
-	/* If we're in KX mode then we're done */
-	if (priv->mode == AMD_XGBE_MODE_KX)
+	/* If we're not in KR mode then we're done */
+	if (!amd_xgbe_phy_in_kr_mode(phydev))
 		return AMD_XGBE_AN_EVENT;
 
 	/* Enable/Disable FEC */
@@ -669,7 +693,6 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_xnp(struct phy_device *phydev,
 static enum amd_xgbe_phy_an amd_xgbe_an_rx_bpa(struct phy_device *phydev,
 					       enum amd_xgbe_phy_rx *state)
 {
-	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	unsigned int link_support;
 	int ret, ad_reg, lp_reg;
 
@@ -679,9 +702,9 @@ static enum amd_xgbe_phy_an amd_xgbe_an_rx_bpa(struct phy_device *phydev,
 		return AMD_XGBE_AN_ERROR;
 
 	/* Check for a supported mode, otherwise restart in a different one */
-	link_support = (priv->mode == AMD_XGBE_MODE_KR) ? 0x80 : 0x20;
+	link_support = amd_xgbe_phy_in_kr_mode(phydev) ? 0x80 : 0x20;
 	if (!(ret & link_support))
-		return amd_xgbe_an_switch_mode(phydev);
+		return AMD_XGBE_AN_INCOMPAT_LINK;
 
 	/* Check Extended Next Page support */
 	ad_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
@@ -722,7 +745,7 @@ static enum amd_xgbe_phy_an amd_xgbe_an_start(struct phy_device *phydev)
 	int ret;
 
 	/* Be sure we aren't looping trying to negotiate */
-	if (priv->mode == AMD_XGBE_MODE_KR) {
+	if (amd_xgbe_phy_in_kr_mode(phydev)) {
 		if (priv->kr_state != AMD_XGBE_RX_READY)
 			return AMD_XGBE_AN_NO_LINK;
 		priv->kr_state = AMD_XGBE_RX_BPA;
@@ -825,8 +848,8 @@ static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
 	enum amd_xgbe_phy_rx *state;
 	int ret;
 
-	state = (priv->mode == AMD_XGBE_MODE_KR) ? &priv->kr_state
-						 : &priv->kx_state;
+	state = amd_xgbe_phy_in_kr_mode(phydev) ? &priv->kr_state
+						: &priv->kx_state;
 
 	switch (*state) {
 	case AMD_XGBE_RX_BPA:
@@ -846,7 +869,13 @@ static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
 
 static enum amd_xgbe_phy_an amd_xgbe_an_incompat_link(struct phy_device *phydev)
 {
-	return amd_xgbe_an_switch_mode(phydev);
+	int ret;
+
+	ret = amd_xgbe_phy_switch_mode(phydev);
+	if (ret)
+		return AMD_XGBE_AN_ERROR;
+
+	return AMD_XGBE_AN_START;
 }
 
 static void amd_xgbe_an_state_machine(struct work_struct *work)
@@ -1018,7 +1047,6 @@ static int amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	u32 mmd_mask = phydev->c45_ids.devices_in_package;
-	int ret;
 
 	if (phydev->autoneg != AUTONEG_ENABLE)
 		return amd_xgbe_phy_setup_forced(phydev);
@@ -1027,11 +1055,6 @@ static int amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 	if (!(mmd_mask & MDIO_DEVS_AN))
 		return -EINVAL;
 
-	/* Get the current speed mode */
-	ret = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL2);
-	if (ret < 0)
-		return ret;
-
 	/* Start/Restart the auto-negotiation state machine */
 	mutex_lock(&priv->an_mutex);
 	priv->an_result = AMD_XGBE_AN_READY;
@@ -1121,17 +1144,12 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	u32 mmd_mask = phydev->c45_ids.devices_in_package;
-	int ret, mode, ad_ret, lp_ret;
+	int ret, ad_ret, lp_ret;
 
 	ret = amd_xgbe_phy_update_link(phydev);
 	if (ret)
 		return ret;
 
-	mode = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL2);
-	if (mode < 0)
-		return mode;
-	mode &= MDIO_PCS_CTRL2_TYPE;
-
 	if (phydev->autoneg == AUTONEG_ENABLE) {
 		if (!(mmd_mask & MDIO_DEVS_AN))
 			return -EINVAL;
@@ -1163,40 +1181,39 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 		ad_ret &= lp_ret;
 		if (ad_ret & 0x80) {
 			phydev->speed = SPEED_10000;
-			if (mode != MDIO_PCS_CTRL2_10GBR) {
-				ret = amd_xgbe_phy_xgmii_mode(phydev);
-				if (ret < 0)
-					return ret;
-			}
+			ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KR);
+			if (ret)
+				return ret;
 		} else {
-			int (*mode_fcn)(struct phy_device *);
-
-			if (priv->speed_set ==
-			    AMD_XGBE_PHY_SPEEDSET_1000_10000) {
+			switch (priv->speed_set) {
+			case AMD_XGBE_PHY_SPEEDSET_1000_10000:
 				phydev->speed = SPEED_1000;
-				mode_fcn = amd_xgbe_phy_gmii_mode;
-			} else {
+				break;
+
+			case AMD_XGBE_PHY_SPEEDSET_2500_10000:
 				phydev->speed = SPEED_2500;
-				mode_fcn = amd_xgbe_phy_gmii_2500_mode;
+				break;
 			}
 
-			if (mode == MDIO_PCS_CTRL2_10GBR) {
-				ret = mode_fcn(phydev);
-				if (ret < 0)
-					return ret;
-			}
+			ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX);
+			if (ret)
+				return ret;
 		}
 
 		phydev->duplex = DUPLEX_FULL;
 	} else {
-		if (mode == MDIO_PCS_CTRL2_10GBR) {
+		if (amd_xgbe_phy_in_kr_mode(phydev)) {
 			phydev->speed = SPEED_10000;
 		} else {
-			if (priv->speed_set ==
-			    AMD_XGBE_PHY_SPEEDSET_1000_10000)
+			switch (priv->speed_set) {
+			case AMD_XGBE_PHY_SPEEDSET_1000_10000:
 				phydev->speed = SPEED_1000;
-			else
+				break;
+
+			case AMD_XGBE_PHY_SPEEDSET_2500_10000:
 				phydev->speed = SPEED_2500;
+				break;
+			}
 		}
 		phydev->duplex = DUPLEX_FULL;
 		phydev->pause = 0;
@@ -1329,14 +1346,6 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 
 	priv->link = 1;
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL2);
-	if (ret < 0)
-		goto err_sir1;
-	if ((ret & MDIO_PCS_CTRL2_TYPE) == MDIO_PCS_CTRL2_10GBR)
-		priv->mode = AMD_XGBE_MODE_KR;
-	else
-		priv->mode = AMD_XGBE_MODE_KX;
-
 	mutex_init(&priv->an_mutex);
 	INIT_WORK(&priv->an_work, amd_xgbe_an_state_machine);
 	priv->an_workqueue = create_singlethread_workqueue(wq_name);
