From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] net: phy: at803x: add suspend/resume callbacks
Date: Sat, 21 Sep 2013 16:53:02 +0200
Message-ID: <1379775182-1271-2-git-send-email-zonque@gmail.com>
References: <1379775182-1271-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, ujhelyi.m@gmail.com,
	sergei.shtylyov@cogentembedded.com, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:56359 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577Ab3IUOxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Sep 2013 10:53:16 -0400
In-Reply-To: <1379775182-1271-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When WOL is enabled, the chip can't be put into power-down (BMCR_PDOWN)
mode, as that will also switch off the MAC, which consequently leads to
a link loss.

Use BMCR_ISOLATE in that case, which will at least save us some
milliamperes in comparison to normal operation mode.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/phy/at803x.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 4179228..bc71947 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -100,6 +100,45 @@ static void at803x_get_wol(struct phy_device *phydev,
 		wol->wolopts |= WAKE_MAGIC;
 }
 
+static int at803x_suspend(struct phy_device *phydev)
+{
+	int value;
+	int wol_enabled;
+
+	mutex_lock(&phydev->lock);
+
+	value = phy_read(phydev, AT803X_INTR_ENABLE);
+	wol_enabled = value & AT803X_WOL_ENABLE;
+
+	value = phy_read(phydev, MII_BMCR);
+
+	if (wol_enabled)
+		value |= BMCR_ISOLATE;
+	else
+		value |= BMCR_PDOWN;
+
+	phy_write(phydev, MII_BMCR, value);
+
+	mutex_unlock(&phydev->lock);
+
+	return 0;
+}
+
+static int at803x_resume(struct phy_device *phydev)
+{
+	int value;
+
+	mutex_lock(&phydev->lock);
+
+	value = phy_read(phydev, MII_BMCR);
+	value &= ~(BMCR_PDOWN | BMCR_ISOLATE);
+	phy_write(phydev, MII_BMCR, value);
+
+	mutex_unlock(&phydev->lock);
+
+	return 0;
+}
+
 static int at803x_config_init(struct phy_device *phydev)
 {
 	int val;
@@ -161,6 +200,8 @@ static struct phy_driver at803x_driver[] = {
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
+	.suspend	= at803x_suspend,
+	.resume		= at803x_resume,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
@@ -176,6 +217,8 @@ static struct phy_driver at803x_driver[] = {
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
+	.suspend	= at803x_suspend,
+	.resume		= at803x_resume,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
@@ -191,6 +234,8 @@ static struct phy_driver at803x_driver[] = {
 	.config_init	= at803x_config_init,
 	.set_wol	= at803x_set_wol,
 	.get_wol	= at803x_get_wol,
+	.suspend	= at803x_suspend,
+	.resume		= at803x_resume,
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_INTERRUPT,
 	.config_aneg	= genphy_config_aneg,
-- 
1.8.3.1
