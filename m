From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/7] net: phy: bcm7xxx: enable EEE at the PHY level
Date: Fri, 22 Aug 2014 18:55:45 -0700
Message-ID: <1408758945-18908-8-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37738 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbaHWB4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:21 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so17561340pab.14
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:21 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 28nm Gigabit PHY on BCM7xxx chips comes out of reset with absolutely
no EEE capabilities, such that we would actually return that we do not
support EEE when accessing 3.20 (MDIO_PCS_EEE_ABLE) registers.

Poke through the vendor-specific C45 register to enable EEE globally at
the PHY level, and advertise supported EEE modes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 31 +++++++++++++++++++++++++++++++
 include/linux/brcmphy.h   |  3 +++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 9dcf241b62ef..1e8c611831bf 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -14,6 +14,7 @@
 #include <linux/delay.h>
 #include <linux/bitops.h>
 #include <linux/brcmphy.h>
+#include <linux/mdio.h>
 
 /* Broadcom BCM7xxx internal PHY registers */
 #define MII_BCM7XXX_CHANNEL_WIDTH	0x2000
@@ -167,6 +168,32 @@ static int bcm7xxx_apd_enable(struct phy_device *phydev)
 	return bcm54xx_shadow_write(phydev, BCM54XX_SHD_APD, val);
 }
 
+static int bcm7xxx_eee_enable(struct phy_device *phydev)
+{
+	int val;
+
+	val = phy_read_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
+				    MDIO_MMD_AN, phydev->addr);
+	if (val < 0)
+		return val;
+
+	/* Enable general EEE feature at the PHY level */
+	val |= LPI_FEATURE_EN | LPI_FEATURE_EN_DIG1000X;
+
+	phy_write_mmd_indirect(phydev, BRCM_CL45VEN_EEE_CONTROL,
+			       MDIO_MMD_AN, phydev->addr, val);
+
+	/* Advertise supported modes */
+	val = phy_read_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+				    MDIO_MMD_AN, phydev->addr);
+
+	val |= (MDIO_AN_EEE_ADV_100TX | MDIO_AN_EEE_ADV_1000T);
+	phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
+			       MDIO_MMD_AN, phydev->addr, val);
+
+	return 0;
+}
+
 static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 {
 	int ret;
@@ -179,6 +206,10 @@ static int bcm7xxx_28nm_config_init(struct phy_device *phydev)
 	if (ret)
 		return ret;
 
+	ret = bcm7xxx_eee_enable(phydev);
+	if (ret)
+		return ret;
+
 	return bcm7xxx_apd_enable(phydev);
 }
 
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index c221e6df2bc4..fcf7675d5d92 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -215,5 +215,8 @@ static inline int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow,
 			 MII_BCM54XX_SHD_DATA(val));
 }
 
+#define BRCM_CL45VEN_EEE_CONTROL	0x803d
+#define LPI_FEATURE_EN			0x8000
+#define LPI_FEATURE_EN_DIG1000X		0x4000
 
 #endif /* _LINUX_BRCMPHY_H */
-- 
1.9.1
