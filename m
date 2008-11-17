From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 18/33] tun: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:25 -0800
Message-ID: <20081117234356.327503270@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55085 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbYKRAAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:11 -0500
Content-Disposition: inline; filename=tun-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the TUN/TAP tunnel driver to net_device_ops.
Split the ops in two, and retain compatability.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tun.c	2008-11-17 14:03:49.000000000 -0800
+++ b/drivers/net/tun.c	2008-11-17 14:43:57.000000000 -0800
@@ -305,6 +305,22 @@ tun_net_change_mtu(struct net_device *de
 	return 0;
 }
 
+static const struct net_device_ops tun_netdev_ops = {
+	.open	            = tun_net_open,
+	.stop 	    	    = tun_net_close,
+	.change_mtu  	    = tun_net_change_mtu,
+
+};
+
+static const struct net_device_ops tap_netdev_ops = {
+	.open		    = tun_net_open,
+	.stop		    = tun_net_close,
+	.change_mtu	    = tun_net_change_mtu,
+	.set_multicast_list = tun_net_mclist,
+	.set_mac_address    = eth_mac_addr,
+	.validate_addr	    = eth_validate_addr,
+};
+
 /* Initialize net device. */
 static void tun_net_init(struct net_device *dev)
 {
@@ -312,11 +328,12 @@ static void tun_net_init(struct net_devi
 
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
+		dev->netdev_ops = &tun_netdev_ops;
+
 		/* Point-to-Point TUN Device */
 		dev->hard_header_len = 0;
 		dev->addr_len = 0;
 		dev->mtu = 1500;
-		dev->change_mtu = tun_net_change_mtu;
 
 		/* Zero header length */
 		dev->type = ARPHRD_NONE;
@@ -325,10 +342,9 @@ static void tun_net_init(struct net_devi
 		break;
 
 	case TUN_TAP_DEV:
+		dev->netdev_ops = &tun_netdev_ops;
 		/* Ethernet TAP Device */
 		ether_setup(dev);
-		dev->change_mtu         = tun_net_change_mtu;
-		dev->set_multicast_list = tun_net_mclist;
 
 		random_ether_addr(dev->dev_addr);
 
@@ -675,9 +691,7 @@ static void tun_setup(struct net_device 
 	tun->owner = -1;
 	tun->group = -1;
 
-	dev->open = tun_net_open;
 	dev->hard_start_xmit = tun_net_xmit;
-	dev->stop = tun_net_close;
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = free_netdev;
 	dev->features |= NETIF_F_NETNS_LOCAL;
@@ -749,6 +763,7 @@ static int tun_set_iff(struct net *net, 
 			return -ENOMEM;
 
 		dev_net_set(dev, net);
+
 		tun = netdev_priv(dev);
 		tun->dev = dev;
 		tun->flags = flags;

-- 

