From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCHv2 2/4] net: phy: at803x: Allow specifying the RGMII RX clock delay via phy mode
Date: Fri, 15 Jan 2016 01:55:22 +0100
Message-ID: <1452819324-4527-2-git-send-email-martin.blumenstingl@googlemail.com>
References: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, daniel@zonque.org, festevam@gmail.com,
	mans@mansr.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34024 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757314AbcAOAzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 19:55:45 -0500
Received: by mail-wm0-f47.google.com with SMTP id u188so4511090wmu.1
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 16:55:45 -0800 (PST)
In-Reply-To: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
In-Reply-To: 1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

at803x currently automatically enables the RGMII TX clock delay when the
phy interface mode is PHY_INTERFACE_MODE_RGMII_TXID. The same should be
done when PHY_INTERFACE_MODE_RGMII_ID is specified.
Use a similar logic to enable the RGMII RX clock delay as well.
at803x_context_{save,restore} were not touched because these are only
used on AR8030 which is a RMII phy (RGMII clock delays are irrelevant).

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
v2: renamed at803x_set_{rx,tx}_delay to at803x_enable_{rx,tx}_delay and
    drop the "bool enable".

 drivers/net/phy/at803x.c | 63 +++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 54 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 3589447..333c1bc 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -36,8 +36,10 @@
 #define AT803X_INSR				0x0013
 #define AT803X_DEBUG_ADDR			0x1D
 #define AT803X_DEBUG_DATA			0x1E
-#define AT803X_DEBUG_SYSTEM_MODE_CTRL		0x05
-#define AT803X_DEBUG_RGMII_TX_CLK_DLY		BIT(8)
+#define AT803X_DEBUG_REG_0			0x00
+#define AT803X_DEBUG_RX_CLK_DLY_EN		BIT(15)
+#define AT803X_DEBUG_REG_5			0x05
+#define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
 
 #define ATH8030_PHY_ID 0x004dd076
 #define ATH8031_PHY_ID 0x004dd074
@@ -61,6 +63,46 @@ struct at803x_context {
 	u16 led_control;
 };
 
+static int at803x_debug_reg_read(struct phy_device *phydev, u16 reg)
+{
+	int ret;
+
+	ret = phy_write(phydev, AT803X_DEBUG_ADDR, reg);
+	if (ret < 0)
+		return ret;
+
+	return phy_read(phydev, AT803X_DEBUG_DATA);
+}
+
+static int at803x_debug_reg_mask(struct phy_device *phydev, u16 reg,
+				 u16 clear, u16 set)
+{
+	u16 val;
+	int ret;
+
+	ret = at803x_debug_reg_read(phydev, reg);
+	if (ret < 0)
+		return ret;
+
+	val = ret & 0xffff;
+	val &= ~clear;
+	val |= set;
+
+	return phy_write(phydev, AT803X_DEBUG_DATA, val);
+}
+
+static inline int at803x_enable_rx_delay(struct phy_device *phydev)
+{
+	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0, 0,
+					AT803X_DEBUG_RX_CLK_DLY_EN);
+}
+
+static inline int at803x_enable_tx_delay(struct phy_device *phydev)
+{
+	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5, 0,
+					AT803X_DEBUG_TX_CLK_DLY_EN);
+}
+
 /* save relevant PHY registers to private copy */
 static void at803x_context_save(struct phy_device *phydev,
 				struct at803x_context *context)
@@ -217,14 +259,17 @@ static int at803x_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
-		ret = phy_write(phydev, AT803X_DEBUG_ADDR,
-				AT803X_DEBUG_SYSTEM_MODE_CTRL);
-		if (ret)
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+		ret = at803x_enable_rx_delay(phydev);
+		if (ret < 0)
 			return ret;
-		ret = phy_write(phydev, AT803X_DEBUG_DATA,
-				AT803X_DEBUG_RGMII_TX_CLK_DLY);
-		if (ret)
+	}
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID ||
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+		ret = at803x_enable_tx_delay(phydev);
+		if (ret < 0)
 			return ret;
 	}
 
-- 
2.7.0
