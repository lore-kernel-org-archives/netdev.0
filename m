From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH 2/4] net: phy: at803x: Allow specifying the RGMII RX clock delay via phy mode
Date: Sat, 26 Dec 2015 01:27:00 +0100
Message-ID: <1451089622-14957-3-git-send-email-martin.blumenstingl@googlemail.com>
References: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
Cc: f.fainelli@gmail.com, slash.tmp@free.fr,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37537 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbbLZA1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2015 19:27:39 -0500
Received: by mail-wm0-f42.google.com with SMTP id p187so214732009wmp.0
        for <netdev@vger.kernel.org>; Fri, 25 Dec 2015 16:27:39 -0800 (PST)
In-Reply-To: <1451089622-14957-1-git-send-email-martin.blumenstingl@googlemail.com>
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
 drivers/net/phy/at803x.c | 78 ++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 69 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f566b6e..0b262a2 100644
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
@@ -61,6 +63,61 @@ struct at803x_context {
 	u16 led_control;
 };
 
+static int _at803x_debug_reg_read(struct phy_device *phydev, u16 reg)
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
+	mutex_lock(&phydev->lock);
+
+	ret = _at803x_debug_reg_read(phydev, reg);
+	if (ret < 0)
+		goto out;
+
+	val = ret & 0xffff;
+	val &= ~clear;
+	val |= set;
+
+	ret = phy_write(phydev, AT803X_DEBUG_DATA, val);
+
+out:
+	mutex_unlock(&phydev->lock);
+
+	return ret;
+}
+
+static int at803x_set_rx_delay(struct phy_device *phydev, bool enable)
+{
+	if (enable)
+		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0, 0,
+					     AT803X_DEBUG_RX_CLK_DLY_EN);
+	else
+		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_0,
+					     AT803X_DEBUG_RX_CLK_DLY_EN, 0);
+}
+
+static int at803x_set_tx_delay(struct phy_device *phydev, bool enable)
+{
+	if (enable)
+		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5, 0,
+					     AT803X_DEBUG_TX_CLK_DLY_EN);
+	else
+		return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_5,
+					     AT803X_DEBUG_TX_CLK_DLY_EN, 0);
+}
+
 /* save relevant PHY registers to private copy */
 static void at803x_context_save(struct phy_device *phydev,
 				struct at803x_context *context)
@@ -217,14 +274,17 @@ static int at803x_config_init(struct phy_device *phydev)
 	if (ret < 0)
 		return ret;
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
-		ret = phy_write(phydev, AT803X_DEBUG_ADDR,
-				AT803X_DEBUG_SYSTEM_MODE_CTRL);
-		if (ret)
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID ||
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+		ret = at803x_set_rx_delay(phydev, true);
+		if (ret < 0)
 			return ret;
-		ret = phy_write(phydev, AT803X_DEBUG_DATA,
-				AT803X_DEBUG_RGMII_TX_CLK_DLY);
-		if (ret)
+	}
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID ||
+			phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
+		ret = at803x_set_tx_delay(phydev, true);
+		if (ret < 0)
 			return ret;
 	}
 
-- 
2.6.4
