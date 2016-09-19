From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v3 net-next] net: phy: Add MAC-IF driver for Microsemi PHYs.
Date: Mon, 19 Sep 2016 15:33:54 +0530
Message-ID: <1474279434-14583-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0079.outbound.protection.outlook.com ([104.47.37.79]:43424
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754687AbcISKEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 06:04:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

All the review comments updated and resending for review.

This is MAC interface feature.
Microsemi PHY can support RGMII, RMII or GMII/MII interface between MAC and PHY.
MAC-IF function program the right value based on Device tree configuration.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/mscc.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index c09cc4a..d350deb 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -23,6 +23,16 @@ enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_3_4_NS = 7
 };
 
+/* Microsemi VSC85xx PHY registers */
+/* IEEE 802. Std Registers */
+#define MSCC_PHY_EXT_PHY_CNTL_1           23
+#define MAC_IF_SELECTION_MASK             0x1800
+#define MAC_IF_SELECTION_GMII             0
+#define MAC_IF_SELECTION_RMII             1
+#define MAC_IF_SELECTION_RGMII            2
+#define MAC_IF_SELECTION_POS              11
+#define FAR_END_LOOPBACK_MODE_MASK        0x0008
+
 #define MII_VSC85XX_INT_MASK		  25
 #define MII_VSC85XX_INT_MASK_MASK	  0xa000
 #define MII_VSC85XX_INT_STATUS		  26
@@ -48,6 +58,42 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_mac_if_set(struct phy_device *phydev,
+			      phy_interface_t interface)
+{
+	int rc;
+	u16 reg_val;
+
+	mutex_lock(&phydev->lock);
+	reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
+	reg_val &= ~(MAC_IF_SELECTION_MASK);
+	switch (interface) {
+	case PHY_INTERFACE_MODE_RGMII:
+		reg_val |= (MAC_IF_SELECTION_RGMII << MAC_IF_SELECTION_POS);
+		break;
+	case PHY_INTERFACE_MODE_RMII:
+		reg_val |= (MAC_IF_SELECTION_RMII << MAC_IF_SELECTION_POS);
+		break;
+	case PHY_INTERFACE_MODE_MII:
+	case PHY_INTERFACE_MODE_GMII:
+		reg_val |= (MAC_IF_SELECTION_GMII << MAC_IF_SELECTION_POS);
+		break;
+	default:
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
+	if (rc != 0)
+		goto out_unlock;
+
+	rc = genphy_soft_reset(phydev);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
 static int vsc85xx_default_config(struct phy_device *phydev)
 {
 	int rc;
@@ -77,6 +123,11 @@ static int vsc85xx_config_init(struct phy_device *phydev)
 	rc = vsc85xx_default_config(phydev);
 	if (rc)
 		return rc;
+
+	rc = vsc85xx_mac_if_set(phydev, phydev->interface);
+	if (rc)
+		return rc;
+
 	rc = genphy_config_init(phydev);
 
 	return rc;
-- 
2.7.4
