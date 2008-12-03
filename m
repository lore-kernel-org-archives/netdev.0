From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] ne-h8300: convert to net_device_ops
Date: Wed, 03 Dec 2008 12:10:16 -0800
Message-ID: <20081203201028.533294548@vyatta.com>
References: <20081203201013.653215120@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60571 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214AbYLCULS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 15:11:18 -0500
Content-Disposition: inline; filename=ne-h300.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another device using 8390 library that needs converting.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/Makefile	2008-12-03 12:04:17.000000000 -0800
+++ b/drivers/net/Makefile	2008-12-03 12:07:25.000000000 -0800
@@ -124,7 +124,7 @@ obj-$(CONFIG_NE3210) += ne3210.o 8390.o
 obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
-obj-$(CONFIG_NE_H8300) += ne-h8300.o
+obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
 obj-$(CONFIG_AX88796) += ax88796.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
--- a/drivers/net/ne-h8300.c	2008-12-03 12:04:13.000000000 -0800
+++ b/drivers/net/ne-h8300.c	2008-12-03 12:07:17.000000000 -0800
@@ -167,7 +167,7 @@ static void cleanup_card(struct net_devi
 #ifndef MODULE
 struct net_device * __init ne_probe(int unit)
 {
-	struct net_device *dev = ____alloc_ei_netdev(0);
+	struct net_device *dev = alloc_ei_netdev();
 	int err;
 
 	if (!dev)
@@ -193,6 +193,21 @@ out:
 }
 #endif
 
+static const struct net_device_ops ne_netdev_ops = {
+	.ndo_open		= ne_open,
+	.ndo_stop		= ne_close,
+
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ei_poll,
+#endif
+};
+
 static int __init ne_probe1(struct net_device *dev, int ioaddr)
 {
 	int i;
@@ -319,11 +334,9 @@ static int __init ne_probe1(struct net_d
 	ei_status.block_output = &ne_block_output;
 	ei_status.get_8390_hdr = &ne_get_8390_hdr;
 	ei_status.priv = 0;
-	dev->open = &ne_open;
-	dev->stop = &ne_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = __ei_poll;
-#endif
+
+	dev->netdev_ops = &ne_netdev_ops;
+
 	__NS8390_init(dev, 0);
 
 	ret = register_netdev(dev);
@@ -624,7 +637,7 @@ int init_module(void)
 	int err;
 
 	for (this_dev = 0; this_dev < MAX_NE_CARDS; this_dev++) {
-		struct net_device *dev = ____alloc_ei_netdev(0);
+		struct net_device *dev = alloc_ei_netdev();
 		if (!dev)
 			break;
 		if (io[this_dev]) {

-- 

