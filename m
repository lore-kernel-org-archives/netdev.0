From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] Add support for SMSC LAN8187 and LAN8700 PHYs
Date: Mon, 28 Apr 2008 18:37:29 +0100
Message-ID: <1209404249-32572-1-git-send-email-steve.glendinning@smsc.com>
Cc: Jeff Garzik <jeff@garzik.org>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:42421 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755163AbYD1XhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 19:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for two additional SMSC PHY models with identical interrupt
source and mask registers to the LAN83C185

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/Kconfig |    2 +-
 drivers/net/phy/smsc.c  |   69 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 3ac8529..6bf9e76 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -48,7 +48,7 @@ config VITESSE_PHY
 config SMSC_PHY
 	tristate "Drivers for SMSC PHYs"
 	---help---
-	  Currently supports the LAN83C185 PHY
+	  Currently supports the LAN83C185, LAN8187 and LAN8700 PHYs
 
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 6a901f0..73baa7a 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -12,6 +12,8 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  *
+ * Support added for SMSC LAN8187 and LAN8700 by steve.glendinning@smsc.com
+ *
  */
 
 #include <linux/kernel.h>
@@ -82,13 +84,78 @@ static struct phy_driver lan83c185_driver = {
 	.driver		= { .owner = THIS_MODULE, }
 };
 
+static struct phy_driver lan8187_driver = {
+	.phy_id		= 0x0007c0b0, /* OUI=0x00800f, Model#=0x0b */
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "SMSC LAN8187",
+
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.config_init	= smsc_phy_config_init,
+
+	/* IRQ related */
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.driver		= { .owner = THIS_MODULE, }
+};
+
+static struct phy_driver lan8700_driver = {
+	.phy_id		= 0x0007c0c0, /* OUI=0x00800f, Model#=0x0c */
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "SMSC LAN8700",
+
+	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
+				| SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.config_init	= smsc_phy_config_init,
+
+	/* IRQ related */
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.driver		= { .owner = THIS_MODULE, }
+};
+
 static int __init smsc_init(void)
 {
-	return phy_driver_register (&lan83c185_driver);
+	int ret;
+
+	ret = phy_driver_register (&lan83c185_driver);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register (&lan8187_driver);
+	if (ret)
+		goto err2;
+
+	ret = phy_driver_register (&lan8700_driver);
+	if (ret)
+		goto err3;
+
+	return 0;
+
+err3:
+	phy_driver_unregister (&lan8187_driver);
+err2:
+	phy_driver_unregister (&lan83c185_driver);
+err1:
+	return ret;
 }
 
 static void __exit smsc_exit(void)
 {
+	phy_driver_unregister (&lan8700_driver);
+	phy_driver_unregister (&lan8187_driver);
 	phy_driver_unregister (&lan83c185_driver);
 }
 
-- 
1.5.4.1

