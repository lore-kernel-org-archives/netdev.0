From: Alexandru Gagniuc <alex.g@adaptrum.com>
Subject: [PATCH] net/phy/vitesse: Configure RGMII skew on VSC8601, if needed
Date: Sat, 12 Nov 2016 15:32:13 -0800
Message-ID: <1478993533-1936-1-git-send-email-alex.g@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gokhan@adaptrum.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Alexandru Gagniuc <alex.g@adaptrum.com>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0049.outbound.protection.outlook.com ([104.47.40.49]:54592
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750776AbcKLXs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 18:48:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With RGMII, we need a 1.5 to 2ns skew between clock and data lines. The
VSC8601 can handle this internally. While the VSC8601 can set more
fine-grained delays, the standard skew settings work out of the box.
The same heuristic is used to determine when this skew should be enabled
as in vsc824x_config_init().

Tested on custom board with AM3352 SOC and VSC801 PHY.

Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
---
 drivers/net/phy/vitesse.c | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
index 2e37eb3..7923831 100644
--- a/drivers/net/phy/vitesse.c
+++ b/drivers/net/phy/vitesse.c
@@ -62,6 +62,10 @@
 /* Vitesse Extended Page Access Register */
 #define MII_VSC82X4_EXT_PAGE_ACCESS	0x1f
 
+/* Vitesse VSC8601 Extended PHY Control Register 1 */
+#define MII_VSC8601_EPHY_CTL		0x17
+#define MII_VSC8601_EPHY_CTL_RGMII_SKEW	(1 << 8)
+
 #define PHY_ID_VSC8234			0x000fc620
 #define PHY_ID_VSC8244			0x000fc6c0
 #define PHY_ID_VSC8514			0x00070670
@@ -111,6 +115,31 @@ static int vsc824x_config_init(struct phy_device *phydev)
 	return err;
 }
 
+static int vsc8601_add_skew(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = phy_read(phydev, MII_VSC8601_EPHY_CTL);
+	if (ret < 0)
+		return ret;
+
+	ret |= MII_VSC8601_EPHY_CTL_RGMII_SKEW;
+	return phy_write(phydev, MII_VSC8601_EPHY_CTL, ret);
+}
+
+static int vsc8601_config_init(struct phy_device *phydev)
+{
+	int ret = 0;
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
+		ret = vsc8601_add_skew(phydev);
+
+	if (ret < 0)
+		return ret;
+
+	return genphy_config_init(phydev);
+}
+
 static int vsc824x_ack_interrupt(struct phy_device *phydev)
 {
 	int err = 0;
@@ -275,7 +304,7 @@ static struct phy_driver vsc82xx_driver[] = {
 	.phy_id_mask    = 0x000ffff0,
 	.features       = PHY_GBIT_FEATURES,
 	.flags          = PHY_HAS_INTERRUPT,
-	.config_init    = &genphy_config_init,
+	.config_init    = &vsc8601_config_init,
 	.config_aneg    = &genphy_config_aneg,
 	.read_status    = &genphy_read_status,
 	.ack_interrupt  = &vsc824x_ack_interrupt,
-- 
2.7.4
