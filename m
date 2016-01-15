From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCHv2 4/4] net: phy: at803x: Add the interrupt register bit definitions
Date: Fri, 15 Jan 2016 01:55:24 +0100
Message-ID: <1452819324-4527-4-git-send-email-martin.blumenstingl@googlemail.com>
References: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, daniel@zonque.org, festevam@gmail.com,
	mans@mansr.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38621 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912AbcAOAzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 19:55:48 -0500
Received: by mail-wm0-f51.google.com with SMTP id b14so2264876wmb.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 16:55:47 -0800 (PST)
In-Reply-To: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
In-Reply-To: 1451089622-14957-5-git-send-email-martin.blumenstingl@googlemail.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also use them instead of a magic value when enabling the interrupts.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
v2: refreshed patch

 drivers/net/phy/at803x.c | 32 +++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f2c4e8d..2174ec9 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -20,13 +20,21 @@
 #include <linux/gpio/consumer.h>
 
 #define AT803X_INTR_ENABLE			0x12
-#define AT803X_INTR_ENABLE_INIT			0xec00
+#define AT803X_INTR_ENABLE_AUTONEG_ERR		BIT(15)
+#define AT803X_INTR_ENABLE_SPEED_CHANGED	BIT(14)
+#define AT803X_INTR_ENABLE_DUPLEX_CHANGED	BIT(13)
+#define AT803X_INTR_ENABLE_PAGE_RECEIVED	BIT(12)
+#define AT803X_INTR_ENABLE_LINK_FAIL		BIT(11)
+#define AT803X_INTR_ENABLE_LINK_SUCCESS		BIT(10)
+#define AT803X_INTR_ENABLE_WIRESPEED_DOWNGRADE	BIT(5)
+#define AT803X_INTR_ENABLE_POLARITY_CHANGED	BIT(1)
+#define AT803X_INTR_ENABLE_WOL			BIT(0)
+
 #define AT803X_INTR_STATUS			0x13
 
 #define AT803X_SMART_SPEED			0x14
 #define AT803X_LED_CONTROL			0x18
 
-#define AT803X_WOL_ENABLE			0x01
 #define AT803X_DEVICE_ADDR			0x03
 #define AT803X_LOC_MAC_ADDR_0_15_OFFSET		0x804C
 #define AT803X_LOC_MAC_ADDR_16_31_OFFSET	0x804B
@@ -164,14 +172,14 @@ static int at803x_set_wol(struct phy_device *phydev,
 		}
 
 		value = phy_read(phydev, AT803X_INTR_ENABLE);
-		value |= AT803X_WOL_ENABLE;
+		value |= AT803X_INTR_ENABLE_WOL;
 		ret = phy_write(phydev, AT803X_INTR_ENABLE, value);
 		if (ret)
 			return ret;
 		value = phy_read(phydev, AT803X_INTR_STATUS);
 	} else {
 		value = phy_read(phydev, AT803X_INTR_ENABLE);
-		value &= (~AT803X_WOL_ENABLE);
+		value &= (~AT803X_INTR_ENABLE_WOL);
 		ret = phy_write(phydev, AT803X_INTR_ENABLE, value);
 		if (ret)
 			return ret;
@@ -190,7 +198,7 @@ static void at803x_get_wol(struct phy_device *phydev,
 	wol->wolopts = 0;
 
 	value = phy_read(phydev, AT803X_INTR_ENABLE);
-	if (value & AT803X_WOL_ENABLE)
+	if (value & AT803X_INTR_ENABLE_WOL)
 		wol->wolopts |= WAKE_MAGIC;
 }
 
@@ -202,7 +210,7 @@ static int at803x_suspend(struct phy_device *phydev)
 	mutex_lock(&phydev->lock);
 
 	value = phy_read(phydev, AT803X_INTR_ENABLE);
-	wol_enabled = value & AT803X_WOL_ENABLE;
+	wol_enabled = value & AT803X_INTR_ENABLE_WOL;
 
 	value = phy_read(phydev, MII_BMCR);
 
@@ -295,9 +303,15 @@ static int at803x_config_intr(struct phy_device *phydev)
 
 	value = phy_read(phydev, AT803X_INTR_ENABLE);
 
-	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
-		err = phy_write(phydev, AT803X_INTR_ENABLE,
-				value | AT803X_INTR_ENABLE_INIT);
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		value |= AT803X_INTR_ENABLE_AUTONEG_ERR;
+		value |= AT803X_INTR_ENABLE_SPEED_CHANGED;
+		value |= AT803X_INTR_ENABLE_DUPLEX_CHANGED;
+		value |= AT803X_INTR_ENABLE_LINK_FAIL;
+		value |= AT803X_INTR_ENABLE_LINK_SUCCESS;
+
+		err = phy_write(phydev, AT803X_INTR_ENABLE, value);
+	}
 	else
 		err = phy_write(phydev, AT803X_INTR_ENABLE, 0);
 
-- 
2.7.0
