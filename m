From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] phy/micrel: add ability to support 50MHz RMII clock on KZS8051RNL
Date: Mon, 14 Feb 2011 14:05:33 +0200
Message-ID: <e426eef4b15c4e1c77981094c3c8020012aaca42.1297685030.git.baruch@tkos.co.il>
Cc: Baruch Siach <baruch@tkos.co.il>,
	"David J. Choi" <david.choi@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:42223 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921Ab1BNMGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 07:06:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Platform code can now set the MICREL_PHY_50MHZ_CLK bit of dev_flags in a fixup
routine (registered with phy_register_fixup_for_uid()), to make the KZS8051RNL
PHY work with 50MHz RMII reference clock.

Cc: David J. Choi <david.choi@micrel.com>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/phy/micrel.c   |   24 ++++++++++++++++--------
 include/linux/micrel_phy.h |   16 ++++++++++++++++
 2 files changed, 32 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/micrel_phy.h

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 8bb7db6..a6c3bf5 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -19,13 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/phy.h>
-
-#define	PHY_ID_KSZ9021			0x00221611
-#define	PHY_ID_KS8737			0x00221720
-#define	PHY_ID_KS8041			0x00221510
-#define	PHY_ID_KS8051			0x00221550
-/* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
-#define	PHY_ID_KS8001			0x0022161A
+#include <linux/micrel_phy.h>
 
 /* general Interrupt control/status reg in vendor specific block. */
 #define MII_KSZPHY_INTCS			0x1B
@@ -46,6 +40,7 @@
 #define KSZPHY_CTRL_INT_ACTIVE_HIGH		(1 << 9)
 #define KSZ9021_CTRL_INT_ACTIVE_HIGH		(1 << 14)
 #define KS8737_CTRL_INT_ACTIVE_HIGH		(1 << 14)
+#define KSZ8051_RMII_50MHZ_CLK			(1 << 7)
 
 static int kszphy_ack_interrupt(struct phy_device *phydev)
 {
@@ -106,6 +101,19 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int ks8051_config_init(struct phy_device *phydev)
+{
+	int regval;
+
+	if (phydev->dev_flags & MICREL_PHY_50MHZ_CLK) {
+		regval = phy_read(phydev, MII_KSZPHY_CTRL);
+		regval |= KSZ8051_RMII_50MHZ_CLK;
+		phy_write(phydev, MII_KSZPHY_CTRL, regval);
+	}
+
+	return 0;
+}
+
 static struct phy_driver ks8737_driver = {
 	.phy_id		= PHY_ID_KS8737,
 	.phy_id_mask	= 0x00fffff0,
@@ -142,7 +150,7 @@ static struct phy_driver ks8051_driver = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= ks8051_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
new file mode 100644
index 0000000..dd8da34
--- /dev/null
+++ b/include/linux/micrel_phy.h
@@ -0,0 +1,16 @@
+#ifndef _MICREL_PHY_H
+#define _MICREL_PHY_H
+
+#define MICREL_PHY_ID_MASK	0x00fffff0
+
+#define PHY_ID_KSZ9021		0x00221611
+#define PHY_ID_KS8737		0x00221720
+#define PHY_ID_KS8041		0x00221510
+#define PHY_ID_KS8051		0x00221550
+/* both for ks8001 Rev. A/B, and for ks8721 Rev 3. */
+#define PHY_ID_KS8001		0x0022161A
+
+/* struct phy_device dev_flags definitions */
+#define MICREL_PHY_50MHZ_CLK	0x00000001
+
+#endif /* _MICREL_PHY_H */
-- 
1.7.2.3

