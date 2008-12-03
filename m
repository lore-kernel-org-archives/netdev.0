From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] zorro8390: convert to net_device_ops
Date: Wed, 03 Dec 2008 12:10:14 -0800
Message-ID: <20081203201028.362917093@vyatta.com>
References: <20081203201013.653215120@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60566 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758547AbYLCULR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 15:11:17 -0500
Content-Disposition: inline; filename=zorro.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another device using 8390 library that needs converting.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/Makefile	2008-12-03 11:56:50.000000000 -0800
+++ b/drivers/net/Makefile	2008-12-03 11:56:59.000000000 -0800
@@ -190,7 +190,7 @@ obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
-obj-$(CONFIG_ZORRO8390) += zorro8390.o
+obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
 obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
--- a/drivers/net/zorro8390.c	2008-12-03 11:56:42.000000000 -0800
+++ b/drivers/net/zorro8390.c	2008-12-03 11:59:24.000000000 -0800
@@ -122,7 +122,7 @@ static int __devinit zorro8390_init_one(
 	    break;
     board = z->resource.start;
     ioaddr = board+cards[i].offset;
-    dev = ____alloc_ei_netdev(0);
+    dev = alloc_ei_netdev();
     if (!dev)
 	return -ENOMEM;
     if (!request_mem_region(ioaddr, NE_IO_EXTENT*2, DRV_NAME)) {
@@ -139,6 +139,20 @@ static int __devinit zorro8390_init_one(
     return 0;
 }
 
+static const struct net_device_ops zorro8390_netdev_ops = {
+	.ndo_open		= zorro8390_open,
+	.ndo_stop		= zorro8390_close,
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
 static int __devinit zorro8390_init(struct net_device *dev,
 				    unsigned long board, const char *name,
 				    unsigned long ioaddr)
@@ -230,12 +244,8 @@ static int __devinit zorro8390_init(stru
     ei_status.block_output = &zorro8390_block_output;
     ei_status.get_8390_hdr = &zorro8390_get_8390_hdr;
     ei_status.reg_offset = zorro8390_offsets;
-    dev->open = &zorro8390_open;
-    dev->stop = &zorro8390_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = __ei_poll;
-#endif
 
+    dev->netdev_ops = &zorro8390_netdev_ops;
     __NS8390_init(dev, 0);
     err = register_netdev(dev);
     if (err) {

-- 

