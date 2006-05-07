From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: [PATCH] phy: new SMSC LAN83C185 PHY driver
Date: Sun, 7 May 2006 13:13:46 +0000 (UTC)
Message-ID: <E1Fcj4p-00061b-3o@fencepost.gnu.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:6836 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932135AbWEGNNh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 09:13:37 -0400
To: afleming@freescale.com
Date: Sun May 7 15:00:23 2006 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

new SMSC LAN83C185 10BaseT/100BaseTX PHY driver for the PHY subsystem

Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>


---

 drivers/net/phy/Kconfig  |    6 ++
 drivers/net/phy/Makefile |    1 
 drivers/net/phy/smsc.c   |  134 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 141 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/smsc.c

15ab98f0ecaf1fb161d0832a118c93976531af66
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index fa39b94..cda3e53 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -45,5 +45,11 @@ config CICADA_PHY
 	---help---
 	  Currently supports the cis8204
 
+config SMSC_PHY
+	tristate "Drivers for SMSC PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the LAN83C185 PHY
+
 endmenu
 
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e4116a5..d961413 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
 obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
+obj-$(CONFIG_SMSC_PHY)		+= smsc.o
diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
new file mode 100644
index 0000000..b96eb52
--- /dev/null
+++ b/drivers/net/phy/smsc.c
@@ -0,0 +1,134 @@
+/*
+ * drivers/net/phy/smsc.c
+ *
+ * Driver for SMSC PHYs
+ *
+ * Author: Herbert Valerio Riedel
+ *
+ * Copyright (c) 2006 Herbert Valerio Riedel <hvr@gnu.org>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+#define MII_LAN83C185_ISF 29 /* Interrupt Source Flags */
+#define MII_LAN83C185_IM  30 /* Interrupt Mask */
+
+#define MII_LAN83C185_ISF_INT1 (1<<1) /* Auto-Negotiation Page Received */
+#define MII_LAN83C185_ISF_INT2 (1<<2) /* Parallel Detection Fault */
+#define MII_LAN83C185_ISF_INT3 (1<<3) /* Auto-Negotiation LP Ack */
+#define MII_LAN83C185_ISF_INT4 (1<<4) /* Link Down */
+#define MII_LAN83C185_ISF_INT5 (1<<5) /* Remote Fault Detected */
+#define MII_LAN83C185_ISF_INT6 (1<<6) /* Auto-Negotiation complete */
+#define MII_LAN83C185_ISF_INT7 (1<<7) /* ENERGYON */
+
+#define MII_LAN83C185_ISF_INT_ALL (0x0e)
+
+#define MII_LAN83C185_ISF_INT_PHYLIB_EVENTS \
+	(MII_LAN83C185_ISF_INT6 | MII_LAN83C185_ISF_INT4)
+
+/* prototypes */
+static int lan83c185_config_init(struct phy_device *);
+static int lan83c185_config_intr(struct phy_device *);
+static int lan83c185_ack_interrupt(struct phy_device *);
+
+
+static int lan83c185_config_init(struct phy_device *phydev)
+{
+	pr_debug ("%s: config_init\n", phydev->attached_dev->name);
+
+	return lan83c185_ack_interrupt (phydev);
+}
+
+static int lan83c185_config_intr(struct phy_device *phydev)
+{
+	int rc = phy_write (phydev, MII_LAN83C185_IM,
+			    ((PHY_INTERRUPT_ENABLED == phydev->interrupts) 
+			     ?  MII_LAN83C185_ISF_INT_PHYLIB_EVENTS 
+			     : 0));
+
+	pr_debug ("%s: config_intr %x (rc=%.4x)\n",
+		  phydev->attached_dev->name, phydev->interrupts, rc);
+
+	return rc < 0 ? rc : 0;
+}
+
+static int lan83c185_ack_interrupt(struct phy_device *phydev)
+{
+	int rc = phy_read (phydev, MII_LAN83C185_ISF);
+
+	pr_debug ("%s: ack_interrupt (masked ISF=%.4x, raw ISF: %.4x)\n", 
+		  phydev->attached_dev->name, 
+		  rc & MII_LAN83C185_ISF_INT_PHYLIB_EVENTS, rc);
+
+	return rc < 0 ? rc : 0;
+}
+
+static struct phy_driver lan83c185_driver = {
+	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
+	.phy_id_mask    = 0xfffffff0,
+	.name		= "SMSC LAN83C185",
+	
+	.features       = (PHY_BASIC_FEATURES | SUPPORTED_Pause 
+			   | SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	/* basic functions */
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.config_init	= lan83c185_config_init,
+
+	/* IRQ related */
+	.ack_interrupt  = lan83c185_ack_interrupt,
+        .config_intr    = lan83c185_config_intr,
+	
+	.driver		= { .owner = THIS_MODULE, }
+};
+
+static int __init smsc_init(void)
+{
+        int rc;
+
+        if ((rc = phy_driver_register (&lan83c185_driver)))
+                goto err_register_lan83c185_driver;
+
+        return 0;
+	
+	/* phy_driver_unregister (&lan83c185_driver); */
+ err_register_lan83c185_driver:
+        return rc;
+}
+
+static void __exit smsc_exit(void)
+{
+	phy_driver_unregister (&lan83c185_driver);
+}
+
+MODULE_DESCRIPTION("SMSC PHY driver");
+MODULE_AUTHOR("Herbert Valerio Riedel");
+MODULE_LICENSE("GPL");
+
+module_init(smsc_init);
+module_exit(smsc_exit);
+
+/*
+ * Overrides for Emacs so that we follow Linus's tabbing style.
+ * Emacs will notice this stuff at the end of the file and automatically
+ * adjust the settings for this buffer only.  This must remain at the end
+ * of the file.
+ * ---------------------------------------------------------------------------
+ * Local variables:
+ * c-file-style: "linux"
+ * End:
+ */
-- 
1.2.6

