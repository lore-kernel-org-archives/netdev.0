From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 3/8] amd-xgbe: Update/fix 2.5GbE support
Date: Fri, 25 Jul 2014 16:11:09 -0500
Message-ID: <20140725211109.32358.53556.stgit@tlendack-t1.amdoffice.net>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0144.outbound.protection.outlook.com ([207.46.163.144]:48917
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933337AbaGYVLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 17:11:15 -0400
In-Reply-To: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the amd-xgbe driver and phylib driver to better support
the 2.5GbE mode for the hardware. In order to be able establish
2.5GbE using clause 73 auto negotiation the device will support
speed sets of 1GbE/10GbE and 2.5GbE/10GbE.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 .../devicetree/bindings/net/amd-xgbe-phy.txt       |    6 +
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   17 +++-
 drivers/net/phy/amd-xgbe-phy.c                     |   92 +++++++++++++++++---
 3 files changed, 96 insertions(+), 19 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
index d01ed63..42409bf 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
@@ -8,10 +8,16 @@ Required properties:
    - SerDes integration registers (1/2)
    - SerDes integration registers (2/2)
 
+Optional properties:
+- amd,speed-set: Speed capabilities of the device
+    0 - 1GbE and 10GbE (default)
+    1 - 2.5GbE and 10GbE
+
 Example:
 	xgbe_phy@e1240800 {
 		compatible = "amd,xgbe-phy-seattle-v1a", "ethernet-phy-ieee802.3-c45";
 		reg = <0 0xe1240800 0 0x00400>,
 		      <0 0xe1250000 0 0x00060>,
 		      <0 0xe1250080 0 0x00004>;
+		amd,speed-set = <0>;
 	};
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 9a48668..711b577 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -327,10 +327,19 @@ static int xgbe_set_settings(struct net_device *netdev,
 	    (cmd->autoneg != AUTONEG_DISABLE))
 		goto unlock;
 
-	if ((cmd->autoneg == AUTONEG_DISABLE) &&
-	    (((speed != SPEED_10000) && (speed != SPEED_1000)) ||
-	     (cmd->duplex != DUPLEX_FULL)))
-		goto unlock;
+	if (cmd->autoneg == AUTONEG_DISABLE) {
+		switch (speed) {
+		case SPEED_10000:
+		case SPEED_2500:
+		case SPEED_1000:
+			break;
+		default:
+			goto unlock;
+		}
+
+		if (cmd->duplex != DUPLEX_FULL)
+			goto unlock;
+	}
 
 	cmd->advertising &= phydev->supported;
 	if ((cmd->autoneg == AUTONEG_ENABLE) && !cmd->advertising)
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index b57c224..b35293d 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -74,7 +74,6 @@
 #include <linux/of_platform.h>
 #include <linux/of_device.h>
 #include <linux/uaccess.h>
-#include <asm/irq.h>
 
 
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
@@ -85,6 +84,8 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_PHY_ID	0x000162d0
 #define XGBE_PHY_MASK	0xfffffff0
 
+#define XGBE_PHY_SPEEDSET_PROPERTY	"amd,speed-set"
+
 #define XGBE_AN_INT_CMPLT		0x01
 #define XGBE_AN_INC_LINK		0x02
 #define XGBE_AN_PG_RCV			0x04
@@ -145,7 +146,7 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 
 #define SPEED_2500_CDR			0x2
 #define SPEED_2500_PLL			0x0
-#define SPEED_2500_RATE			0x2
+#define SPEED_2500_RATE			0x1
 #define SPEED_2500_TXAMP		0xf
 #define SPEED_2500_WORD			0x1
 
@@ -292,6 +293,11 @@ enum amd_xgbe_phy_mode {
 	AMD_XGBE_MODE_KX,
 };
 
+enum amd_xgbe_phy_speedset {
+	AMD_XGBE_PHY_SPEEDSET_1000_10000,
+	AMD_XGBE_PHY_SPEEDSET_2500_10000,
+};
+
 struct amd_xgbe_phy_priv {
 	struct platform_device *pdev;
 	struct device *dev;
@@ -311,6 +317,7 @@ struct amd_xgbe_phy_priv {
 	/* Maintain link status for re-starting auto-negotiation */
 	unsigned int link;
 	enum amd_xgbe_phy_mode mode;
+	unsigned int speed_set;
 
 	/* Auto-negotiation state machine support */
 	struct mutex an_mutex;
@@ -546,10 +553,14 @@ static int amd_xgbe_phy_switch_mode(struct phy_device *phydev)
 	int ret;
 
 	/* If we are in KR switch to KX, and vice-versa */
-	if (priv->mode == AMD_XGBE_MODE_KR)
-		ret = amd_xgbe_phy_gmii_mode(phydev);
-	else
+	if (priv->mode == AMD_XGBE_MODE_KR) {
+		if (priv->speed_set == AMD_XGBE_PHY_SPEEDSET_1000_10000)
+			ret = amd_xgbe_phy_gmii_mode(phydev);
+		else
+			ret = amd_xgbe_phy_gmii_2500_mode(phydev);
+	} else {
 		ret = amd_xgbe_phy_xgmii_mode(phydev);
+	}
 
 	return ret;
 }
@@ -713,7 +724,8 @@ static enum amd_xgbe_phy_an amd_xgbe_an_start(struct phy_device *phydev)
 	else
 		ret &= ~0x80;
 
-	if (phydev->supported & SUPPORTED_1000baseKX_Full)
+	if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
+	    (phydev->supported & SUPPORTED_2500baseX_Full))
 		ret |= 0x20;
 	else
 		ret &= ~0x20;
@@ -896,14 +908,22 @@ static int amd_xgbe_phy_soft_reset(struct phy_device *phydev)
 
 static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 {
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
+
 	/* Initialize supported features */
 	phydev->supported = SUPPORTED_Autoneg;
 	phydev->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
 	phydev->supported |= SUPPORTED_Backplane;
-	phydev->supported |= SUPPORTED_1000baseKX_Full |
-			     SUPPORTED_2500baseX_Full;
 	phydev->supported |= SUPPORTED_10000baseKR_Full |
 			     SUPPORTED_10000baseR_FEC;
+	switch (priv->speed_set) {
+	case AMD_XGBE_PHY_SPEEDSET_1000_10000:
+		phydev->supported |= SUPPORTED_1000baseKX_Full;
+		break;
+	case AMD_XGBE_PHY_SPEEDSET_2500_10000:
+		phydev->supported |= SUPPORTED_2500baseX_Full;
+		break;
+	}
 	phydev->advertising = phydev->supported;
 
 	/* Turn off and clear interrupts */
@@ -1020,9 +1040,9 @@ static int amd_xgbe_phy_update_link(struct phy_device *phydev)
 	 * (re-)established (cable connected after the interface is
 	 * up, etc.), the link status may report no link. If there
 	 * is no link, try switching modes and checking the status
-	 * again.
+	 * again if auto negotiation is enabled.
 	 */
-	check_again = 1;
+	check_again = (phydev->autoneg == AUTONEG_ENABLE) ? 1 : 0;
 again:
 	/* Link status is latched low, so read once to clear
 	 * and then read again to get current state
@@ -1038,8 +1058,10 @@ again:
 	phydev->link = (ret & MDIO_STAT1_LSTATUS) ? 1 : 0;
 
 	if (!phydev->link) {
-		ret = amd_xgbe_phy_switch_mode(phydev);
 		if (check_again) {
+			ret = amd_xgbe_phy_switch_mode(phydev);
+			if (ret < 0)
+				return ret;
 			check_again = 0;
 			goto again;
 		}
@@ -1059,6 +1081,7 @@ again:
 
 static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 {
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	u32 mmd_mask = phydev->c45_ids.devices_in_package;
 	int ret, mode, ad_ret, lp_ret;
 
@@ -1108,9 +1131,19 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 					return ret;
 			}
 		} else {
-			phydev->speed = SPEED_1000;
+			int (*mode_fcn)(struct phy_device *);
+
+			if (priv->speed_set ==
+			    AMD_XGBE_PHY_SPEEDSET_1000_10000) {
+				phydev->speed = SPEED_1000;
+				mode_fcn = amd_xgbe_phy_gmii_mode;
+			} else {
+				phydev->speed = SPEED_2500;
+				mode_fcn = amd_xgbe_phy_gmii_2500_mode;
+			}
+
 			if (mode == MDIO_PCS_CTRL2_10GBR) {
-				ret = amd_xgbe_phy_gmii_mode(phydev);
+				ret = mode_fcn(phydev);
 				if (ret < 0)
 					return ret;
 			}
@@ -1118,8 +1151,15 @@ static int amd_xgbe_phy_read_status(struct phy_device *phydev)
 
 		phydev->duplex = DUPLEX_FULL;
 	} else {
-		phydev->speed = (mode == MDIO_PCS_CTRL2_10GBR) ? SPEED_10000
-							       : SPEED_1000;
+		if (mode == MDIO_PCS_CTRL2_10GBR) {
+			phydev->speed = SPEED_10000;
+		} else {
+			if (priv->speed_set ==
+			    AMD_XGBE_PHY_SPEEDSET_1000_10000)
+				phydev->speed = SPEED_1000;
+			else
+				phydev->speed = SPEED_2500;
+		}
 		phydev->duplex = DUPLEX_FULL;
 		phydev->pause = 0;
 		phydev->asym_pause = 0;
@@ -1176,6 +1216,8 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 	struct platform_device *pdev;
 	struct device *dev;
 	char *wq_name;
+	const __be32 *property;
+	unsigned int speed_set;
 	int ret;
 
 	if (!phydev->dev.of_node)
@@ -1227,6 +1269,26 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		goto err_sir0;
 	}
 
+	/* Get the device speed set property */
+	speed_set = 0;
+	property = of_get_property(dev->of_node, XGBE_PHY_SPEEDSET_PROPERTY,
+				   NULL);
+	if (property)
+		speed_set = be32_to_cpu(*property);
+
+	switch (speed_set) {
+	case 0:
+		priv->speed_set = AMD_XGBE_PHY_SPEEDSET_1000_10000;
+		break;
+	case 1:
+		priv->speed_set = AMD_XGBE_PHY_SPEEDSET_2500_10000;
+		break;
+	default:
+		dev_err(dev, "invalid amd,speed-set property\n");
+		ret = -EINVAL;
+		goto err_sir1;
+	}
+
 	priv->link = 1;
 
 	ret = phy_read_mmd(phydev, MDIO_MMD_PCS, MDIO_CTRL2);
