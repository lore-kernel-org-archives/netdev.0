From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH] at803x: fix suspend/resume for SGMII link
Date: Fri, 11 Mar 2016 15:31:53 +0100
Message-ID: <1457706713-13779-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, chunkeey@googlemail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:39312 "EHLO mail.neratec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbcCKOku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 09:40:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When operating the at803x in SGMII mode, resuming the chip
from power down brings up the copper-side link but leaves
the SGMII link in unconnected state (tested with at8031
attached to gianfar). In effect, this caused a permanent
link loss once the related interface was put down.

This patch ensures that power down handling in supspend()
and resume() is also applied to the SGMII link.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/phy/at803x.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 2174ec9..1e901c7 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -52,6 +52,9 @@
 #define AT803X_DEBUG_REG_5			0x05
 #define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
 
+#define AT803X_REG_CHIP_CONFIG			0x1f
+#define AT803X_BT_BX_REG_SEL			0x8000
+
 #define ATH8030_PHY_ID 0x004dd076
 #define ATH8031_PHY_ID 0x004dd074
 #define ATH8035_PHY_ID 0x004dd072
@@ -206,6 +209,7 @@ static int at803x_suspend(struct phy_device *phydev)
 {
 	int value;
 	int wol_enabled;
+	int ccr;
 
 	mutex_lock(&phydev->lock);
 
@@ -221,6 +225,16 @@ static int at803x_suspend(struct phy_device *phydev)
 
 	phy_write(phydev, MII_BMCR, value);
 
+	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
+		goto done;
+
+	/* also power-down SGMII interface */
+	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
+	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
+
+done:
 	mutex_unlock(&phydev->lock);
 
 	return 0;
@@ -229,6 +243,7 @@ static int at803x_suspend(struct phy_device *phydev)
 static int at803x_resume(struct phy_device *phydev)
 {
 	int value;
+	int ccr;
 
 	mutex_lock(&phydev->lock);
 
@@ -236,6 +251,17 @@ static int at803x_resume(struct phy_device *phydev)
 	value &= ~(BMCR_PDOWN | BMCR_ISOLATE);
 	phy_write(phydev, MII_BMCR, value);
 
+	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
+		goto done;
+
+	/* also power-up SGMII interface */
+	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
+	value = phy_read(phydev, MII_BMCR) & ~(BMCR_PDOWN | BMCR_ISOLATE);
+	phy_write(phydev, MII_BMCR, value);
+	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
+
+done:
 	mutex_unlock(&phydev->lock);
 
 	return 0;
-- 
2.7.0
