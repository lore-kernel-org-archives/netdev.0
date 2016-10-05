From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next] net: phy: Add Wake-on-LAN driver for Microsemi PHYs.
Date: Wed, 5 Oct 2016 14:19:27 +0530
Message-ID: <1475657367-13600-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0069.outbound.protection.outlook.com ([104.47.38.69]:9813
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752005AbcJEItg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 04:49:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Wake-on-LAN (WoL) is an Ethernet networking standard that allows 
a computer/device to be turned on or awakened by a network message.

VSC8531 PHY can support this feature configure by driver set function.
WoL status get by driver get function.

Tested on Beaglebone Black with VSC 8531 PHY.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

---

All the review comments updated and resending for review.

Change set:
v1:
- Initial version of Wake-on-LAN (WoL) driver.
v2:
- As per review comments, code optimized.

---

 drivers/net/phy/mscc.c | 128 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 128 insertions(+)

diff --git a/drivers/net/phy/mscc.c b/drivers/net/phy/mscc.c
index a17573e..77a6671 100644
--- a/drivers/net/phy/mscc.c
+++ b/drivers/net/phy/mscc.c
@@ -13,6 +13,7 @@
 #include <linux/phy.h>
 #include <linux/of.h>
 #include <dt-bindings/net/mscc-phy-vsc8531.h>
+#include <linux/netdevice.h>
 
 enum rgmii_rx_clock_delay {
 	RGMII_RX_CLK_DELAY_0_2_NS = 0,
@@ -37,6 +38,7 @@ enum rgmii_rx_clock_delay {
 
 #define MII_VSC85XX_INT_MASK		  25
 #define MII_VSC85XX_INT_MASK_MASK	  0xa000
+#define MII_VSC85XX_INT_MASK_WOL	  0x0040
 #define MII_VSC85XX_INT_STATUS		  26
 
 #define MSCC_PHY_WOL_MAC_CONTROL          27
@@ -52,6 +54,17 @@ enum rgmii_rx_clock_delay {
 #define RGMII_RX_CLK_DELAY_MASK		  0x0070
 #define RGMII_RX_CLK_DELAY_POS		  4
 
+#define MSCC_PHY_WOL_LOWER_MAC_ADDR	  21
+#define MSCC_PHY_WOL_MID_MAC_ADDR	  22
+#define MSCC_PHY_WOL_UPPER_MAC_ADDR	  23
+#define MSCC_PHY_WOL_LOWER_PASSWD	  24
+#define MSCC_PHY_WOL_MID_PASSWD		  25
+#define MSCC_PHY_WOL_UPPER_PASSWD	  26
+
+#define MSCC_PHY_WOL_MAC_CONTROL	  27
+#define SECURE_ON_ENABLE		  0x8000
+#define SECURE_ON_PASSWD_LEN_4		  0x4000
+
 /* Microsemi PHY ID's */
 #define PHY_ID_VSC8531			  0x00070570
 #define PHY_ID_VSC8541			  0x00070770
@@ -81,6 +94,117 @@ static int vsc85xx_phy_page_set(struct phy_device *phydev, u8 page)
 	return rc;
 }
 
+static int vsc85xx_wol_set(struct phy_device *phydev,
+			   struct ethtool_wolinfo *wol)
+{
+	int rc;
+	u16 reg_val;
+	u8  i;
+	u16 pwd[3] = {0, 0, 0};
+	struct ethtool_wolinfo *wol_conf = wol;
+	u8 *mac_addr = phydev->attached_dev->dev_addr;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		/* Store the device address for the magic packet */
+		for (i = 0; i < ARRAY_SIZE(pwd); i++)
+			pwd[i] = mac_addr[5 - (i * 2 + 1)] << 8 |
+				 mac_addr[5 - i * 2];
+		phy_write(phydev, MSCC_PHY_WOL_LOWER_MAC_ADDR, pwd[0]);
+		phy_write(phydev, MSCC_PHY_WOL_MID_MAC_ADDR, pwd[1]);
+		phy_write(phydev, MSCC_PHY_WOL_UPPER_MAC_ADDR, pwd[2]);
+	} else {
+		phy_write(phydev, MSCC_PHY_WOL_LOWER_MAC_ADDR, 0);
+		phy_write(phydev, MSCC_PHY_WOL_MID_MAC_ADDR, 0);
+		phy_write(phydev, MSCC_PHY_WOL_UPPER_MAC_ADDR, 0);
+	}
+
+	if (wol_conf->wolopts & WAKE_MAGICSECURE) {
+		for (i = 0; i < ARRAY_SIZE(pwd); i++)
+			pwd[i] = wol_conf->sopass[5 - (i * 2 + 1)] << 8 |
+				 wol_conf->sopass[5 - i * 2];
+		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, pwd[0]);
+		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, pwd[1]);
+		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, pwd[2]);
+	} else {
+		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, 0);
+		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, 0);
+		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, 0);
+	}
+
+	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+	if (wol_conf->wolopts & WAKE_MAGICSECURE)
+		reg_val |= SECURE_ON_ENABLE;
+	else
+		reg_val &= ~SECURE_ON_ENABLE;
+	phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+	if (rc != 0)
+		goto out_unlock;
+
+	if (wol->wolopts & WAKE_MAGIC) {
+		/* Enable the WOL interrupt */
+		reg_val = phy_read(phydev, MII_VSC85XX_INT_MASK);
+		reg_val |= MII_VSC85XX_INT_MASK_WOL;
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, reg_val);
+		if (rc != 0)
+			goto out_unlock;
+	} else {
+		/* Disable the WOL interrupt */
+		reg_val = phy_read(phydev, MII_VSC85XX_INT_MASK);
+		reg_val &= (~MII_VSC85XX_INT_MASK_WOL);
+		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, reg_val);
+		if (rc != 0)
+			goto out_unlock;
+	}
+	/* Clear WOL iterrupt status */
+	reg_val = phy_read(phydev, MII_VSC85XX_INT_STATUS);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+
+	return rc;
+}
+
+static void vsc85xx_wol_get(struct phy_device *phydev,
+			    struct ethtool_wolinfo *wol)
+{
+	int rc;
+	u16 reg_val;
+	u8  i;
+	u16 pwd[3] = {0, 0, 0};
+	struct ethtool_wolinfo *wol_conf = wol;
+
+	mutex_lock(&phydev->lock);
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
+	if (rc != 0)
+		goto out_unlock;
+
+	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
+	if (reg_val & SECURE_ON_ENABLE)
+		wol_conf->wolopts |= WAKE_MAGICSECURE;
+	if (wol_conf->wolopts & WAKE_MAGICSECURE) {
+		pwd[0] = phy_read(phydev, MSCC_PHY_WOL_LOWER_PASSWD);
+		pwd[1] = phy_read(phydev, MSCC_PHY_WOL_MID_PASSWD);
+		pwd[2] = phy_read(phydev, MSCC_PHY_WOL_UPPER_PASSWD);
+		for (i = 0; i < ARRAY_SIZE(pwd); i++) {
+			wol_conf->sopass[5 - i * 2] = pwd[i] & 0x00ff;
+			wol_conf->sopass[5 - (i * 2 + 1)] = (pwd[i] & 0xff00)
+							    >> 8;
+		}
+	}
+
+	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
+
+out_unlock:
+	mutex_unlock(&phydev->lock);
+}
+
 static u8 edge_rate_magic_get(u16 vddmac,
 			      int slowdown)
 {
@@ -301,6 +425,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
 	.probe          = &vsc85xx_probe,
+	.set_wol        = &vsc85xx_wol_set,
+	.get_wol        = &vsc85xx_wol_get,
 },
 {
 	.phy_id		= PHY_ID_VSC8541,
@@ -318,6 +444,8 @@ static struct phy_driver vsc85xx_driver[] = {
 	.suspend	= &genphy_suspend,
 	.resume		= &genphy_resume,
 	.probe          = &vsc85xx_probe,
+	.set_wol        = &vsc85xx_wol_set,
+	.get_wol        = &vsc85xx_wol_get,
 }
 
 };
-- 
2.7.4
