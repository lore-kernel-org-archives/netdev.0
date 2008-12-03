From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] hydra: convert to net_device_ops
Date: Wed, 03 Dec 2008 12:10:15 -0800
Message-ID: <20081203201028.449368463@vyatta.com>
References: <20081203201013.653215120@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60568 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757173AbYLCULR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 15:11:17 -0500
Content-Disposition: inline; filename=hydra.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another device using 8390 library that needs converting.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/Makefile	2008-12-03 12:02:31.000000000 -0800
+++ b/drivers/net/Makefile	2008-12-03 12:02:39.000000000 -0800
@@ -202,7 +202,7 @@ obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_DECLANCE) += declance.o
 obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_A2065) += a2065.o
-obj-$(CONFIG_HYDRA) += hydra.o
+obj-$(CONFIG_HYDRA) += hydra.o 8390.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
--- a/drivers/net/hydra.c	2008-12-03 12:00:55.000000000 -0800
+++ b/drivers/net/hydra.c	2008-12-03 12:02:22.000000000 -0800
@@ -94,6 +94,21 @@ static int __devinit hydra_init_one(stru
     return 0;
 }
 
+static const struct net_device_ops etherh_netdev_ops = {
+	.ndo_open		= hydra_open,
+	.ndo_stop		= hydra_close,
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
 static int __devinit hydra_init(struct zorro_dev *z)
 {
     struct net_device *dev;
@@ -109,7 +124,7 @@ static int __devinit hydra_init(struct z
 	0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e,
     };
 
-    dev = ____alloc_ei_netdev(0);
+    dev = alloc_ei_netdev();
     if (!dev)
 	return -ENOMEM;
 
@@ -144,12 +159,8 @@ static int __devinit hydra_init(struct z
     ei_status.block_output = &hydra_block_output;
     ei_status.get_8390_hdr = &hydra_get_8390_hdr;
     ei_status.reg_offset = hydra_offsets;
-    dev->open = &hydra_open;
-    dev->stop = &hydra_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = __ei_poll;
-#endif
 
+    dev->netdev_ops = &hydra_netdev_ops;
     __NS8390_init(dev, 0);
 
     err = register_netdev(dev);

-- 

