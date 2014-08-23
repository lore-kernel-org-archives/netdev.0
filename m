From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/7] net: phy: bcm7xxx: enable auto power down
Date: Fri, 22 Aug 2014 18:55:41 -0700
Message-ID: <1408758945-18908-4-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34332 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751841AbaHWB4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:17 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so16489914pdj.15
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:17 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 28nm process BCM7xxx internal Gigabit PHYs all support automatic
power down, turn on that feature as part of the configuration
initialization callback.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 526b94cea569..9dcf241b62ef 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -146,6 +146,27 @@ static int bcm7xxx_28nm_afe_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm7xxx_apd_enable(struct phy_device *phydev)
+{
+	int val;
+
+	/* Enable powering down of the DLL during auto-power down */
+	val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_SCR3);
+	if (val < 0)
+		return val;
+
+	val |= BCM54XX_SHD_SCR3_DLLAPD_DIS;
+	bcm54xx_shadow_write(phydev, BCM54XX_SHD_SCR3, val);
+
+	/* Enable auto-power down */
+	val = bcm54xx_shadow_read(phydev, BCM54XX_SHD_APD);
+	if (val < 0)
+		return val;
+
+	val |= BCM54XX_SHD_APD_EN;
+	return bcm54xx_shadow_write(phydev, BCM54XX_SHD_APD, val);
+}
+
 static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -154,7 +175,11 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
-	return bcm7xxx_28nm_afe_config_init(phydev);
+	ret = bcm7xxx_28nm_afe_config_init(phydev);
+	if (ret)
+		return ret;
+
+	return bcm7xxx_apd_enable(phydev);
 }
 
 static int phy_set_clr_bits(struct phy_device *dev, int location,
-- 
1.9.1
