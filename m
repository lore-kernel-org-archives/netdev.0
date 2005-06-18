From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/9] orinoco: basic ethtool support
Date: Sun, 19 Jun 2005 01:27:40 +0200
Message-ID: <20050618232740.GE9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I completely reimplemented this based on ethtool_ops, CVS has an
ioctl-based version.

Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 01:03:42.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:03:43.000000000 +0200
@@ -462,6 +462,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211.h>
@@ -542,6 +543,7 @@
 #define MAX_RID_LEN 1024
 
 static const struct iw_handler_def orinoco_handler_def;
+static struct ethtool_ops orinoco_ethtool_ops;
 
 /********************************************************************/
 /* Data tables                                                      */
@@ -2412,6 +2414,7 @@
 	dev->tx_timeout = orinoco_tx_timeout;
 	dev->watchdog_timeo = HZ; /* 1 second timeout */
 	dev->get_stats = orinoco_get_stats;
+	dev->ethtool_ops = &orinoco_ethtool_ops;
 	dev->get_wireless_stats = orinoco_get_wireless_stats;
 	dev->wireless_handlers = (struct iw_handler_def *)&orinoco_handler_def;
 	dev->change_mtu = orinoco_change_mtu;
@@ -3930,6 +3933,27 @@
 	.private_args = orinoco_privtab,
 };
 
+static void orinoco_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *info)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	strncpy(info->driver, DRIVER_NAME, sizeof(info->driver) - 1);
+	strncpy(info->version, DRIVER_VERSION, sizeof(info->version) - 1);
+	strncpy(info->fw_version, priv->fw_name, sizeof(info->fw_version) - 1);
+	if (dev->class_dev.dev)
+		strncpy(info->bus_info, dev->class_dev.dev->bus_id,
+			sizeof(info->bus_info) - 1);
+	else
+		snprintf(info->bus_info, sizeof(info->bus_info) - 1,
+			 "PCMCIA %p", priv->hw.iobase);
+}
+
+static struct ethtool_ops orinoco_ethtool_ops = {
+	.get_drvinfo = orinoco_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
+
 /********************************************************************/
 /* Debugging                                                        */
 /********************************************************************/
