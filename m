From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] mac8390: update to net_device_ops
Date: Tue, 2 Dec 2008 08:14:37 -0800
Message-ID: <20081202081437.7c884ede@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45573 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbYLBQOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 11:14:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another related 8390 driver. Since this is for nubus, not sure if anyone
still has the hardware?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/Makefile	2008-12-02 07:58:02.000000000 -0800
+++ b/drivers/net/Makefile	2008-12-02 07:56:15.000000000 -0800
@@ -97,7 +97,7 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_MAC8390) += mac8390.o
+obj-$(CONFIG_MAC8390) += mac8390.o 8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_HP100) += hp100.o
--- a/drivers/net/mac8390.c	2008-12-02 07:58:07.000000000 -0800
+++ b/drivers/net/mac8390.c	2008-12-02 07:56:24.000000000 -0800
@@ -304,7 +304,7 @@ struct net_device * __init mac8390_probe
 	if (!MACH_IS_MAC)
 		return ERR_PTR(-ENODEV);
 
-	dev = ____alloc_ei_netdev(0);
+	dev = alloc_ei_netdev();
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -478,6 +478,20 @@ void cleanup_module(void)
 
 #endif /* MODULE */
 
+static const struct net_device_ops mac8390_netdev_ops = {
+	.ndo_open 		= mac8390_open,
+	.ndo_stop		= mac8390_close,
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
 static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			    enum mac8390_type type)
 {
@@ -503,11 +517,7 @@ static int __init mac8390_initdev(struct
 	int access_bitmode = 0;
 
 	/* Now fill in our stuff */
-	dev->open = &mac8390_open;
-	dev->stop = &mac8390_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = __ei_poll;
-#endif
+	dev->netdev_ops = &mac8390_netdev_ops;
 
 	/* GAR, ei_status is actually a macro even though it looks global */
 	ei_status.name = cardname[type];
