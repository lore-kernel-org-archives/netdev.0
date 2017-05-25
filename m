From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 3/4] net: phy: marvell: helper to get and set page
Date: Thu, 25 May 2017 21:42:07 +0200
Message-ID: <1495741328-25001-4-git-send-email-andrew@lunn.ch>
References: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44911 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763628AbdEYTmg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 15:42:36 -0400
In-Reply-To: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a common pattern of first reading the currently selected page
and then changing to another page. Add a helper to do this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/marvell.c | 75 ++++++++++++++++++++---------------------------
 1 file changed, 31 insertions(+), 44 deletions(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 3c577a177b2c..ed338af61cdd 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -199,6 +199,19 @@ static int marvell_set_page(struct phy_device *phydev, int page)
 	return phy_write(phydev, MII_MARVELL_PHY_PAGE, page);
 }
 
+static int marvell_get_set_page(struct phy_device *phydev, int page)
+{
+	int oldpage = marvell_get_page(phydev);
+
+	if (oldpage < 0)
+		return oldpage;
+
+	if (page != oldpage)
+		return marvell_set_page(phydev, page);
+
+	return 0;
+}
+
 static int marvell_ack_interrupt(struct phy_device *phydev)
 {
 	int err;
@@ -452,11 +465,9 @@ static int m88e1121_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = marvell_get_page(phydev);
-
-	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
-	if (err < 0)
-		return err;
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	if (oldpage < 0)
+		return oldpage;
 
 	if (phy_interface_is_rgmii(phydev)) {
 		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
@@ -493,11 +504,9 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 {
 	int err, oldpage, mscr;
 
-	oldpage = marvell_get_page(phydev);
-
-	err = marvell_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
-	if (err < 0)
-		return err;
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_MSCR_PAGE);
+	if (oldpage < 0)
+		return oldpage;
 
 	mscr = phy_read(phydev, MII_88E1318S_PHY_MSCR1_REG);
 	mscr |= MII_88E1318S_PHY_MSCR1_PAD_ODD;
@@ -843,11 +852,9 @@ static int m88e1121_config_init(struct phy_device *phydev)
 {
 	int err, oldpage;
 
-	oldpage = marvell_get_page(phydev);
-
-	err = marvell_set_page(phydev, MII_88E1121_PHY_LED_PAGE);
-	if (err < 0)
-		return err;
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_PHY_LED_PAGE);
+	if (oldpage < 0)
+		return oldpage;
 
 	/* Default PHY LED config: LED[0] .. Link, LED[1] .. Activity */
 	err = phy_write(phydev, MII_88E1121_PHY_LED_CTRL,
@@ -1516,12 +1523,11 @@ static u64 marvell_get_stat(struct phy_device *phydev, int i)
 {
 	struct marvell_hw_stat stat = marvell_hw_stats[i];
 	struct marvell_priv *priv = phydev->priv;
-	int err, oldpage, val;
+	int oldpage, val;
 	u64 ret;
 
-	oldpage = marvell_get_page(phydev);
-	err = marvell_set_page(phydev, stat.page);
-	if (err < 0)
+	oldpage = marvell_get_set_page(phydev, stat.page);
+	if (oldpage < 0)
 		return UINT64_MAX;
 
 	val = phy_read(phydev, stat.reg);
@@ -1558,16 +1564,12 @@ static int m88e1121_get_temp(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_page(phydev);
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
 	}
 
-	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
-	if (ret < 0)
-		goto error;
-
 	/* Enable temperature sensor */
 	ret = phy_read(phydev, MII_88E1121_MISC_TEST);
 	if (ret < 0)
@@ -1680,16 +1682,12 @@ static int m88e1510_get_temp(struct phy_device *phydev, long *temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_page(phydev);
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
 	}
 
-	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
-	if (ret < 0)
-		goto error;
-
 	ret = phy_read(phydev, MII_88E1510_TEMP_SENSOR);
 	if (ret < 0)
 		goto error;
@@ -1711,16 +1709,13 @@ int m88e1510_get_temp_critical(struct phy_device *phydev, long *temp)
 	*temp = 0;
 
 	mutex_lock(&phydev->lock);
-	oldpage = marvell_get_page(phydev);
+
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
 	}
 
-	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
-	if (ret < 0)
-		goto error;
-
 	ret = phy_read(phydev, MII_88E1121_MISC_TEST);
 	if (ret < 0)
 		goto error;
@@ -1744,16 +1739,12 @@ int m88e1510_set_temp_critical(struct phy_device *phydev, long temp)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_page(phydev);
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
 	}
 
-	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
-	if (ret < 0)
-		goto error;
-
 	ret = phy_read(phydev, MII_88E1121_MISC_TEST);
 	if (ret < 0)
 		goto error;
@@ -1780,16 +1771,12 @@ int m88e1510_get_temp_alarm(struct phy_device *phydev, long *alarm)
 
 	mutex_lock(&phydev->lock);
 
-	oldpage = marvell_get_page(phydev);
+	oldpage = marvell_get_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
 	if (oldpage < 0) {
 		mutex_unlock(&phydev->lock);
 		return oldpage;
 	}
 
-	ret = marvell_set_page(phydev, MII_88E1121_MISC_TEST_PAGE);
-	if (ret < 0)
-		goto error;
-
 	ret = phy_read(phydev, MII_88E1121_MISC_TEST);
 	if (ret < 0)
 		goto error;
-- 
2.11.0
