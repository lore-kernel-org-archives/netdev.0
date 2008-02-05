From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 07/24 for-2.6.25] DM9000: Add initial ethtool support
Date: Tue, 05 Feb 2008 00:02:06 +0000
Message-ID: <20080205000815.759244139@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58749 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758825AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-ethtool.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ethtool operations for the DM9000.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -63,6 +63,7 @@
 #include <linux/spinlock.h>
 #include <linux/crc32.h>
 #include <linux/mii.h>
+#include <linux/ethtool.h>
 #include <linux/dm9000.h>
 #include <linux/delay.h>
 #include <linux/platform_device.h>
@@ -80,6 +81,7 @@
 
 #define CARDNAME "dm9000"
 #define PFX CARDNAME ": "
+#define DRV_VERSION	"1.30"
 
 #ifdef CONFIG_BLACKFIN
 #define readsb	insb
@@ -145,6 +147,11 @@ typedef struct board_info {
 	}						\
 } while (0)
 
+static inline board_info_t *to_dm9000_board(struct net_device *dev)
+{
+	return dev->priv;
+}
+
 /* function declaration ------------------------------------- */
 static int dm9000_probe(struct platform_device *);
 static int dm9000_open(struct net_device *);
@@ -342,6 +349,64 @@ static void dm9000_poll_controller(struc
 }
 #endif
 
+/* ethtool ops */
+
+static void dm9000_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	strcpy(info->driver, CARDNAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, to_platform_device(dm->dev)->name);
+}
+
+static int dm9000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&dm->lock, flags);
+	mii_ethtool_gset(&dm->mii, cmd);
+	spin_lock_irqsave(&dm->lock, flags);
+
+	return 0;
+}
+
+static int dm9000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
+	int rc;
+
+	spin_lock_irqsave(&dm->lock, flags);
+	rc = mii_ethtool_sset(&dm->mii, cmd);
+	spin_lock_irqsave(&dm->lock, flags);
+
+	return rc;
+}
+
+static int dm9000_nway_reset(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	return mii_nway_restart(&dm->mii);
+}
+
+static u32 dm9000_get_link(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	return mii_link_ok(&dm->mii);
+}
+
+static const struct ethtool_ops dm9000_ethtool_ops = {
+	.get_drvinfo		= dm9000_get_drvinfo,
+	.get_settings		= dm9000_get_settings,
+	.set_settings		= dm9000_set_settings,
+	.nway_reset		= dm9000_nway_reset,
+	.get_link		= dm9000_get_link,
+};
+
+
 /* dm9000_release_board
  *
  * release a board, and any mapped resources
@@ -546,6 +611,8 @@ dm9000_probe(struct platform_device *pde
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	ndev->stop		 = &dm9000_stop;
 	ndev->set_multicast_list = &dm9000_hash_table;
+	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	ndev->poll_controller	 = &dm9000_poll_controller;
 #endif
@@ -1170,7 +1237,7 @@ static struct platform_driver dm9000_dri
 static int __init
 dm9000_init(void)
 {
-	printk(KERN_INFO "%s Ethernet Driver\n", CARDNAME);
+	printk(KERN_INFO "%s Ethernet Driver, V%s\n", CARDNAME, DRV_VERSION);
 
 	return platform_driver_register(&dm9000_driver);	/* search board and register */
 }

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
