From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 39/77] pcnet: convert driver to net_device_ops
Date: Fri, 20 Mar 2009 22:36:06 -0700
Message-ID: <20090321053715.495183543@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36621 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760983AbZCUFsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:17 -0400
Content-Disposition: inline; filename=pcnet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/pcmcia/pcnet_cs.c	2009-03-20 15:39:43.604652177 -0700
+++ b/drivers/net/pcmcia/pcnet_cs.c	2009-03-20 15:55:15.727714742 -0700
@@ -39,6 +39,7 @@
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
 #include <linux/log2.h>
+#include <linux/etherdevice.h>
 #include "../8390.h"
 
 #include <pcmcia/cs_types.h>
@@ -233,6 +234,23 @@ static inline pcnet_dev_t *PRIV(struct n
 	return (pcnet_dev_t *)(p + sizeof(struct ei_device));
 }
 
+static const struct net_device_ops pcnet_netdev_ops = {
+	.ndo_open		= pcnet_open,
+	.ndo_stop		= pcnet_close,
+	.ndo_set_config		= set_config,
+	.ndo_start_xmit 	= ei_start_xmit,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_do_ioctl 		= ei_ioctl,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_tx_timeout 	= ei_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller 	= ei_poll,
+#endif
+};
+
 /*======================================================================
 
     pcnet_attach() creates an "instance" of the driver, allocating
@@ -260,9 +278,7 @@ static int pcnet_probe(struct pcmcia_dev
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
-    dev->open = &pcnet_open;
-    dev->stop = &pcnet_close;
-    dev->set_config = &set_config;
+    dev->netdev_ops = &pcnet_netdev_ops;
 
     return pcnet_config(link);
 } /* pcnet_attach */
@@ -640,18 +656,12 @@ static int pcnet_config(struct pcmcia_de
 
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
-    if (info->flags & (IS_DL10019|IS_DL10022)) {
-	dev->do_ioctl = &ei_ioctl;
+    if (info->flags & (IS_DL10019|IS_DL10022))
 	mii_phy_probe(dev);
-    }
 
     link->dev_node = &info->node;
     SET_NETDEV_DEV(dev, &handle_to_dev(link));
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
-#endif
-
     if (register_netdev(dev) != 0) {
 	printk(KERN_NOTICE "pcnet_cs: register_netdev() failed\n");
 	link->dev_node = NULL;
@@ -1183,6 +1193,10 @@ static int ei_ioctl(struct net_device *d
     pcnet_dev_t *info = PRIV(dev);
     u16 *data = (u16 *)&rq->ifr_ifru;
     unsigned int mii_addr = dev->base_addr + DLINK_GPIO;
+
+    if (!(info->flags & (IS_DL10019|IS_DL10022)))
+	return -EINVAL;
+
     switch (cmd) {
     case SIOCGMIIPHY:
 	data[0] = info->phy_id;

-- 

