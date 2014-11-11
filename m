From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: phy: bcm7xxx: drop A0 revision workaround and fix B0 workaround
Date: Tue, 11 Nov 2014 14:55:11 -0800
Message-ID: <1415746514-11189-3-git-send-email-f.fainelli@gmail.com>
References: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:53512 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbaKKWzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:55:22 -0500
Received: by mail-pd0-f169.google.com with SMTP id y10so10931573pdj.28
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 14:55:22 -0800 (PST)
In-Reply-To: <1415746514-11189-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm7445_config_init() was working around non-production version of the
PHY HW block, so just remove it entirely.

bcm7xxx_28nm_afe_config_init() was running for all PHY revisions greater
than B0, but this workaround sequence is really specific to the B0 PHY
revision, so rename the function accordingly and update the GPHY macro
to use the generic config_init callback.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 41 +++--------------------------------------
 1 file changed, 3 insertions(+), 38 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 25b07a4d31f8..417e16c618fa 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -45,39 +45,6 @@
 
 #define CORE_EXPB0			0xb0
 
-static int bcm7445_config_init(struct phy_device *phydev)
-{
-	int ret;
-	const struct bcm7445_regs {
-		int reg;
-		u16 value;
-	} bcm7445_regs_cfg[] = {
-		/* increases ADC latency by 24ns */
-		{ MII_BCM54XX_EXP_SEL, 0x0038 },
-		{ MII_BCM54XX_EXP_DATA, 0xAB95 },
-		/* increases internal 1V LDO voltage by 5% */
-		{ MII_BCM54XX_EXP_SEL, 0x2038 },
-		{ MII_BCM54XX_EXP_DATA, 0xBB22 },
-		/* reduce RX low pass filter corner frequency */
-		{ MII_BCM54XX_EXP_SEL, 0x6038 },
-		{ MII_BCM54XX_EXP_DATA, 0xFFC5 },
-		/* reduce RX high pass filter corner frequency */
-		{ MII_BCM54XX_EXP_SEL, 0x003a },
-		{ MII_BCM54XX_EXP_DATA, 0x2002 },
-	};
-	unsigned int i;
-
-	for (i = 0; i < ARRAY_SIZE(bcm7445_regs_cfg); i++) {
-		ret = phy_write(phydev,
-				bcm7445_regs_cfg[i].reg,
-				bcm7445_regs_cfg[i].value);
-		if (ret)
-			return ret;
-	}
-
-	return 0;
-}
-
 static void phy_write_exp(struct phy_device *phydev,
 					u16 reg, u16 value)
 {
@@ -102,7 +69,7 @@ static void phy_write_misc(struct phy_device *phydev,
 	phy_write(phydev, MII_BCM54XX_EXP_DATA, value);
 }
 
-static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
+static int bcm7xxx_28nm_b0_afe_config_init(struct phy_device *phydev)
 {
 	/* Increase VCO range to prevent unlocking problem of PLL at low
 	 * temp
@@ -204,12 +171,10 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 		     dev_name(&phydev->dev), phydev->drv->name, rev, patch);
 
 	switch (rev) {
-	case 0xa0:
 	case 0xb0:
-		ret = bcm7445_config_init(phydev);
+		ret = bcm7xxx_28nm_b0_afe_config_init(phydev);
 		break;
 	default:
-		ret = bcm7xxx_28nm_afe_config_init(phydev);
 		break;
 	}
 
@@ -337,7 +302,7 @@ static int bcm7xxx_dummy_config_init(struct phy_device *phydev)
 	.features	= PHY_GBIT_FEATURES |				\
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,	\
 	.flags		= PHY_IS_INTERNAL,				\
-	.config_init	= bcm7xxx_28nm_afe_config_init,			\
+	.config_init	= bcm7xxx_28nm_config_init,			\
 	.config_aneg	= genphy_config_aneg,				\
 	.read_status	= genphy_read_status,				\
 	.resume		= bcm7xxx_28nm_resume,				\
-- 
1.9.1
