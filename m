From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 2/4] net: phy: marvell: More hidden page changes refactored
Date: Thu, 25 May 2017 21:42:06 +0200
Message-ID: <1495741328-25001-3-git-send-email-andrew@lunn.ch>
References: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44920 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762536AbdEYTnX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 15:43:23 -0400
In-Reply-To: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EXT_ADDR_PAGE is the same meaning as MII_MARVELL_PHY_PAGE, i.e. change
page. Replace it will calls to the helpers.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 62 +++++++++++++++++++++++++++++++++++------------
 1 file changed, 46 insertions(+), 16 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index bb067026353a..3c577a177b2c 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -54,7 +54,6 @@
 #define MII_M1011_PHY_SCR_MDI_X		0x0020
 #define MII_M1011_PHY_SCR_AUTO_CROSS	0x0060
 
-#define MII_M1145_PHY_EXT_ADDR_PAGE	0x16
 #define MII_M1145_PHY_EXT_SR		0x1b
 #define MII_M1145_PHY_EXT_CR		0x14
 #define MII_M1145_RGMII_RX_DELAY	0x0080
@@ -92,6 +91,7 @@
 #define MII_88E1121_PHY_MSCR_TX_DELAY	BIT(4)
 #define MII_88E1121_PHY_MSCR_DELAY_MASK	(~(0x3 << 4))
 
+#define MII_88E1121_MISC_TEST_PAGE			6
 #define MII_88E1121_MISC_TEST				0x1a
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_MASK	0x1f00
 #define MII_88E1510_MISC_TEST_TEMP_THRESHOLD_SHIFT	8
@@ -760,11 +760,7 @@ static int m88e1111_config_init_sgmii(struct phy_device *phydev)
 		return err;
 
 	/* make sure copper is selected */
-	err = phy_read(phydev, MII_M1145_PHY_EXT_ADDR_PAGE);
-	if (err < 0)
-		return err;
-
-	return phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, err & (~0xff));
+	return marvell_set_page(phydev, MII_M1111_COPPER);
 }
 
 static int m88e1111_config_init_rtbi(struct phy_device *phydev)
@@ -1554,6 +1550,7 @@ static void marvell_get_stats(struct phy_device *phydev,
 #ifdef CONFIG_HWMON
 static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
 {
+	int oldpage;
 	int ret;
 	int val;
 
@@ -1561,7 +1558,13 @@ static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	ret = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x6);
+	oldpage = marvell_get_page(phydev);
+	if (oldpage < 0) {
+		mutex_unlock(&phydev->lock);
+		return oldpage;
+	}
+
+	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (ret < 0)
 		goto error;
 
@@ -1593,7 +1596,7 @@ static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
 	*temp = ((val & MII_88E1121_MISC_TEST_TEMP_MASK) - 5) * 5000;
 
 error:
-	phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x0);
+	marvell_set_page(phydev, oldpage);
 	mutex_unlock(&phydev->lock);
 
 	return ret;
@@ -1670,13 +1673,20 @@ static const struct hwmon_chip_info m88e1121_hwmon_chip_info = {
 
 static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
 {
+	int oldpage;
 	int ret;
 
 	*temp = 0;
 
 	mutex_lock(&phydev->lock);
 
-	ret = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x6);
+	oldpage = marvell_get_page(phydev);
+	if (oldpage < 0) {
+		mutex_unlock(&phydev->lock);
+		return oldpage;
+	}
+
+	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (ret < 0)
 		goto error;
 
@@ -1687,7 +1697,7 @@ static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
 	*temp = ((ret & MII_88E1510_TEMP_SENSOR_MASK) - 25) * 1000;
 
 error:
-	phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x0);
+	marvell_set_page(phydev, oldpage);
 	mutex_unlock(&phydev->lock);
 
 	return ret;
@@ -1695,13 +1705,19 @@ static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
 
 int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
 {
+	int oldpage;
 	int ret;
 
 	*temp = 0;
 
 	mutex_lock(&phydev->lock);
+	oldpage = marvell_get_page(phydev);
+	if (oldpage < 0) {
+		mutex_unlock(&phydev->lock);
+		return oldpage;
+	}
 
-	ret = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x6);
+	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (ret < 0)
 		goto error;
 
@@ -1715,7 +1731,7 @@ int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
 	*temp *= 1000;
 
 error:
-	phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x0);
+	marvell_set_page(phydev, oldpage);
 	mutex_unlock(&phydev->lock);
 
 	return ret;
@@ -1723,11 +1739,18 @@ int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
 
 int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
 {
+	int oldpage;
 	int ret;
 
 	mutex_lock(&phydev->lock);
 
-	ret = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x6);
+	oldpage = marvell_get_page(phydev);
+	if (oldpage < 0) {
+		mutex_unlock(&phydev->lock);
+		return oldpage;
+	}
+
+	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (ret < 0)
 		goto error;
 
@@ -1742,7 +1765,7 @@ int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
 			(temp << MII_88E1510_MISC_TEST_TEMP_THRESHOLD_SHIFT));
 
 error:
-	phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x0);
+	marvell_set_page(phydev, oldpage);
 	mutex_unlock(&phydev->lock);
 
 	return ret;
@@ -1750,13 +1773,20 @@ int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
 
 int m88e1510_get_temp_alarm(struct phy_device *phydev, long *alarm)
 {
+	int oldpage;
 	int ret;
 
 	*alarm = false;
 
 	mutex_lock(&phydev->lock);
 
-	ret = phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x6);
+	oldpage = marvell_get_page(phydev);
+	if (oldpage < 0) {
+		mutex_unlock(&phydev->lock);
+		return oldpage;
+	}
+
+	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (ret < 0)
 		goto error;
 
@@ -1766,7 +1796,7 @@ int m88e1510_get_temp_alarm(struct phy_device *phydev, long *alarm)
 	*alarm = !!(ret & MII_88E1510_MISC_TEST_TEMP_IRQ);
 
 error:
-	phy_write(phydev, MII_M1145_PHY_EXT_ADDR_PAGE, 0x0);
+	marvell_set_page(phydev, oldpage);
 	mutex_unlock(&phydev->lock);
 
 	return ret;
-- 
2.11.0
