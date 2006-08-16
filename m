From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 2/2] Add support for LAN8187 and LAN8700 PHYs
Date: Wed, 16 Aug 2006 16:48:18 +0100
Message-ID: <1155743298447-git-send-email-steve.glendinning@smsc.com>
References: <1155743298275-git-send-email-steve.glendinning@smsc.com>
Reply-To: Steve Glendinning <steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.8.5] ([86.54.8.5]:57480 "EHLO drevil.shawell.net")
	by vger.kernel.org with ESMTP id S932086AbWHPPsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 11:48:41 -0400
To: netdev@vger.kernel.org
In-Reply-To: <1155743298275-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make functions and constants generic, add support for two more
SMSC PHY models with identical interrupt source and mask registers

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/smsc.c |  112 ++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 89 insertions(+), 23 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 2119bd7..22785fb 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -12,6 +12,7 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  *
+ * Support added for SMSC LAN8187 and LAN8700 by steve.glendinning@smsc.com
  */
 
 #include <linux/config.h>
@@ -22,42 +23,42 @@ #include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/netdevice.h>
 
-#define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
-#define MII_LAN83C185_IM  30 /* Interrupt Mask */
+#define MII_SMSC_ISF 29 /* Interrupt Source Flags */
+#define MII_SMSC_IM  30 /* Interrupt Mask */
 
-#define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
-#define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
-#define MII_LAN83C185_ISF_INT3 (1<<3) /* Auto-Negotiation LP Ack */
-#define MII_LAN83C185_ISF_INT4 (1<<4) /* Link Down */
-#define MII_LAN83C185_ISF_INT5 (1<<5) /* Remote Fault Detected */
-#define MII_LAN83C185_ISF_INT6 (1<<6) /* Auto-Negotiation complete */
-#define MII_LAN83C185_ISF_INT7 (1<<7) /* ENERGYON */
+#define MII_SMSC_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
+#define MII_SMSC_ISF_INT2 (1<<2) /* Parallel Detection Fault */
+#define MII_SMSC_ISF_INT3 (1<<3) /* Auto-Negotiation LP Ack */
+#define MII_SMSC_ISF_INT4 (1<<4) /* Link Down */
+#define MII_SMSC_ISF_INT5 (1<<5) /* Remote Fault Detected */
+#define MII_SMSC_ISF_INT6 (1<<6) /* Auto-Negotiation complete */
+#define MII_SMSC_ISF_INT7 (1<<7) /* ENERGYON */
 
-#define MII_LAN83C185_ISF_INT_ALL (0x0e)
+#define MII_SMSC_ISF_INT_ALL (0x0e)
 
-#define MII_LAN83C185_ISF_INT_PHYLIB_EVENTS \
-	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4)
+#define MII_SMSC_ISF_INT_PHYLIB_EVENTS \
+	(MII_SMSC_ISF_INT6 | MII_SMSC_ISF_INT4)
 
 
-static int lan83c185_config_intr(struct phy_device *phydev)
+static int smsc_phy_config_intr(struct phy_device *phydev)
 {
-	int rc = phy_write(phydev, MII_LAN83C185_IM,
+	int rc = phy_write(phydev, MII_SMSC_IM,
 			   ((PHY_INTERRUPT_ENABLED == phydev->interrupts)
-			    ? MII_LAN83C185_ISF_INT_PHYLIB_EVENTS : 0));
+			    ? MII_SMSC_ISF_INT_PHYLIB_EVENTS : 0));
 
 	return rc < 0 ? rc : 0;
 }
 
-static int lan83c185_ack_interrupt(struct phy_device *phydev)
+static int smsc_phy_ack_interrupt(struct phy_device *phydev)
 {
-	int rc = phy_read(phydev, MII_LAN83C185_ISF);
+	int rc = phy_read(phydev, MII_SMSC_ISF);
 
 	return rc < 0 ? rc : 0;
 }
 
-static int lan83c185_config_init(struct phy_device *phydev)
+static int smsc_phy_config_init(struct phy_device *phydev)
 {
-	return lan83c185_ack_interrupt(phydev);
+	return smsc_phy_ack_interrupt(phydev);
 }
 
 
@@ -73,22 +74,87 @@ static struct phy_driver lan83c185_drive
 	/* basic functions */
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-	.config_init	= lan83c185_config_init,
+	.config_init	= smsc_phy_config_init,
 
 	/* IRQ related */
-	.ack_interrupt	= lan83c185_ack_interrupt,
-	.config_intr	= lan83c185_config_intr,
+	.ack_interrupt	= smsc_phy_ack_interrupt,
+	.config_intr	= smsc_phy_config_intr,
+
+	.driver		= { .owner = THIS_MODULE, }
+};
+
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
 
 	.driver		= { .owner = THIS_MODULE, }
 };
 
 static int __init smsc_init(void)
 {
-	return phy_driver_register(&lan83c185_driver);
+	int ret;
+
+	ret = phy_driver_register(&lan83c185_driver);
+	if (ret)
+		goto err1;
+
+	ret = phy_driver_register(&lan8187_driver);
+	if (ret)
+		goto err2;
+
+	ret = phy_driver_register(&lan8700_driver);
+	if (ret)
+		goto err3;
+
+	return 0;
+
+err3:
+	phy_driver_unregister(&lan8187_driver);
+err2:
+	phy_driver_unregister(&lan83c185_driver);
+err1:
+	return ret;
 }
 
 static void __exit smsc_exit(void)
 {
+	phy_driver_unregister(&lan8700_driver);
+	phy_driver_unregister(&lan8187_driver);
 	phy_driver_unregister(&lan83c185_driver);
 }
 
-- 
1.4.1

