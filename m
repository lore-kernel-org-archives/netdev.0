From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: [PATCH 1/2] Revert "at803x: fix suspend/resume for SGMII link"
Date: Mon, 24 Oct 2016 12:40:53 +0200
Message-ID: <1477305654-11328-2-git-send-email-zefir.kurtisi@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Cc: timur@codeaurora.org, andrew@lunn.ch, f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:45843 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752171AbcJXKlD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 06:41:03 -0400
In-Reply-To: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 98267311fe3b334ae7c107fa0e2413adcf3ba735.

Suspending the SGMII alongside the copper side
made the at803x inaccessable while powered down,
e.g. it can't be re-probed after suspend.

Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
---
 drivers/net/phy/at803x.c | 26 --------------------------
 1 file changed, 26 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f279a89..cf74d10 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -52,9 +52,6 @@
 #define AT803X_DEBUG_REG_5			0x05
 #define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
 
-#define AT803X_REG_CHIP_CONFIG			0x1f
-#define AT803X_BT_BX_REG_SEL			0x8000
-
 #define ATH8030_PHY_ID 0x004dd076
 #define ATH8031_PHY_ID 0x004dd074
 #define ATH8035_PHY_ID 0x004dd072
@@ -209,7 +206,6 @@ static int at803x_suspend(struct phy_device *phydev)
 {
 	int value;
 	int wol_enabled;
-	int ccr;
 
 	mutex_lock(&phydev->lock);
 
@@ -225,16 +221,6 @@ static int at803x_suspend(struct phy_device *phydev)
 
 	phy_write(phydev, MII_BMCR, value);
 
-	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
-		goto done;
-
-	/* also power-down SGMII interface */
-	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
-	phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
-
-done:
 	mutex_unlock(&phydev->lock);
 
 	return 0;
@@ -243,7 +229,6 @@ static int at803x_suspend(struct phy_device *phydev)
 static int at803x_resume(struct phy_device *phydev)
 {
 	int value;
-	int ccr;
 
 	mutex_lock(&phydev->lock);
 
@@ -251,17 +236,6 @@ static int at803x_resume(struct phy_device *phydev)
 	value &= ~(BMCR_PDOWN | BMCR_ISOLATE);
 	phy_write(phydev, MII_BMCR, value);
 
-	if (phydev->interface != PHY_INTERFACE_MODE_SGMII)
-		goto done;
-
-	/* also power-up SGMII interface */
-	ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
-	value = phy_read(phydev, MII_BMCR) & ~(BMCR_PDOWN | BMCR_ISOLATE);
-	phy_write(phydev, MII_BMCR, value);
-	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
-
-done:
 	mutex_unlock(&phydev->lock);
 
 	return 0;
-- 
2.7.4
