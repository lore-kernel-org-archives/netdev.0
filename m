From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 3/3] net: phy: Add Loopback support in Microsemi PHYs driver
Date: Mon, 28 Nov 2016 14:24:32 +0100
Message-ID: <1480339472-5823-4-git-send-email-allan.nielsen@microsemi.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0047.outbound.protection.outlook.com ([104.47.41.47]:6784
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754594AbcK1NZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:26 -0500
In-Reply-To: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Implements the loopback functionality for MSCC PHYs.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 drivers/net/phy/mscc.c | 118 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 118 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index 7a3740c..1f9bc72 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -27,6 +27,9 @@ enum rgmii_rx_clock_delay {
 
 /* Microsemi VSC85xx PHY registers */
 /* IEEE 802. Std Registers */
+#define MSCC_PHY_BYPASS_CONTROL		  18
+#define DISABLE_PAIR_SWAP_CORR_MASK	  0x0020
+
 #define MSCC_PHY_EXT_PHY_CNTL_1           23
 #define MAC_IF_SELECTION_MASK             0x1800
 #define MAC_IF_SELECTION_GMII             0
@@ -35,6 +38,9 @@ enum rgmii_rx_clock_delay {
 #define MAC_IF_SELECTION_POS              11
 #define FAR_END_LOOPBACK_MODE_MASK        0x0008
 
+#define MSCC_PHY_EXT_PHY_CNTL_2		  24
+#define CONNECTOR_LOOPBACK_MASK		  0x0001
+
 #define MII_VSC85XX_INT_MASK		  25
 #define MII_VSC85XX_INT_MASK_MASK	  0xa000
 #define MII_VSC85XX_INT_MASK_WOL	  0x0040
@@ -110,6 +116,114 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_loopback_get(struct phy_device *phydev, u8 *type)
+{
+	u16 reg_val;
+
+	reg_val = phy_read(phydev, MII_BMCR);
+	if (BMCR_LOOPBACK & reg_val) {
+		*type = ETHTOOL_PHY_LOOPBACK_NEAR;
+		goto out;
+	}
+
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+	if (FAR_END_LOOPBACK_MODE_MASK & reg_val) {
+		*type = ETHTOOL_PHY_LOOPBACK_FAR;
+		goto out;
+	}
+
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_2);
+	if (CONNECTOR_LOOPBACK_MASK & reg_val) {
+		*type = ETHTOOL_PHY_LOOPBACK_EXTN;
+		goto out;
+	}
+	*type = ETHTOOL_PHY_LOOPBACK_DISABLE;
+
+out:
+	return 0;
+}
+
+static int vsc85xx_loopback_set(struct phy_device *phydev, u8 type)
+{
+	int rc;
+	u16 reg_val;
+
+	/* Clear/Disable all Loopbacks first */
+	/* Disable Near End Loopback */
+	reg_val = phy_read(phydev, MII_BMCR);
+	if (reg_val & BMCR_LOOPBACK && type != ETHTOOL_PHY_LOOPBACK_NEAR) {
+		reg_val &= ~BMCR_LOOPBACK;
+		rc = phy_write(phydev, MII_BMCR, reg_val);
+		if (rc != 0)
+			goto out;
+	}
+
+	/* Disable Far End Loopback */
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+	if (reg_val & FAR_END_LOOPBACK_MODE_MASK &&
+	    type != ETHTOOL_PHY_LOOPBACK_FAR) {
+		reg_val &= ~FAR_END_LOOPBACK_MODE_MASK;
+		rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
+		if (rc != 0)
+			goto out;
+	}
+
+	/* Disable Connector End Loopback */
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_2);
+	if (reg_val & CONNECTOR_LOOPBACK_MASK &&
+	    type != ETHTOOL_PHY_LOOPBACK_EXTN) {
+		reg_val &= ~CONNECTOR_LOOPBACK_MASK;
+		rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_2, reg_val);
+		if (rc != 0)
+			goto out;
+		reg_val = phy_read(phydev, MSCC_PHY_BYPASS_CONTROL);
+		reg_val &= ~DISABLE_PAIR_SWAP_CORR_MASK;
+		rc = phy_write(phydev, MSCC_PHY_BYPASS_CONTROL, reg_val);
+		if (rc != 0)
+			goto out;
+	}
+
+	switch (type) {
+	case ETHTOOL_PHY_LOOPBACK_NEAR:
+		reg_val = phy_read(phydev, MII_BMCR);
+		reg_val |= BMCR_LOOPBACK;
+		rc = phy_write(phydev, MII_BMCR, reg_val);
+		if (rc != 0)
+			goto out;
+		break;
+	case ETHTOOL_PHY_LOOPBACK_FAR:
+		reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+		reg_val |= FAR_END_LOOPBACK_MODE_MASK;
+		rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
+		if (rc != 0)
+			goto out;
+		break;
+	case ETHTOOL_PHY_LOOPBACK_EXTN:
+		reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_2);
+		reg_val |= CONNECTOR_LOOPBACK_MASK;
+		rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_2, reg_val);
+		if (rc != 0)
+			goto out;
+		reg_val = phy_read(phydev, MSCC_PHY_BYPASS_CONTROL);
+		reg_val |= DISABLE_PAIR_SWAP_CORR_MASK;
+		rc = phy_write(phydev, MSCC_PHY_BYPASS_CONTROL, reg_val);
+		if (rc != 0)
+			goto out;
+		break;
+	case ETHTOOL_PHY_LOOPBACK_DISABLE:
+		/* Already disable all Loopbacks */
+		break;
+	default:
+		phydev_err(phydev, "Invalid Loopback Type (valid only off|near|far|extn)\n");
+		rc = -ERANGE;
+		break;
+	}
+
+out:
+
+	return rc;
+}
+
 static int vsc85xx_downshift_get(struct phy_device *phydev, u8 *count)
 {
 	int rc;
@@ -398,6 +512,8 @@ static int vsc85xx_get_tunable(struct phy_device *phydev,
 	switch (tuna->id) {
 	case ETHTOOL_PHY_DOWNSHIFT:
 		return vsc85xx_downshift_get(phydev, (u8 *)data);
+	case ETHTOOL_PHY_LOOPBACK:
+		return vsc85xx_loopback_get(phydev, (u8 *)data);
 	default:
 		return -EINVAL;
 	}
@@ -410,6 +526,8 @@ static int vsc85xx_set_tunable(struct phy_device *phydev,
 	switch (tuna->id) {
 	case ETHTOOL_PHY_DOWNSHIFT:
 		return vsc85xx_downshift_set(phydev, *(u8 *)data);
+	case ETHTOOL_PHY_LOOPBACK:
+		return vsc85xx_loopback_set(phydev, *(u8 *)data);
 	default:
 		return -EINVAL;
 	}
-- 
2.7.3
