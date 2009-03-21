From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 49/77] cycx: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:16 -0700
Message-ID: <20090321053716.272212792@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36656 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761010AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=cycx-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/cycx_x25.c	2009-03-20 17:04:44.887089081 -0700
+++ b/drivers/net/wan/cycx_x25.c	2009-03-20 17:06:13.508715060 -0700
@@ -355,12 +355,6 @@ static int cycx_wan_update(struct wan_de
 	return 0;
 }
 
-/* callback to initialize device */
-static void cycx_x25_chan_setup(struct net_device *dev)
-{
-	dev->init = cycx_netdevice_init;
-}
-
 /* Create new logical channel.
  * This routine is called by the router when ROUTER_IFNEW IOCTL is being
  * handled.
@@ -476,6 +470,27 @@ static const struct header_ops cycx_head
 	.rebuild = cycx_netdevice_rebuild_header,
 };
 
+static const struct net_device_ops cycx_netdev_ops = {
+	.ndo_init	= cycx_netdevice_init,
+	.ndo_open	= cycx_netdevice_open,
+	.ndo_stop	= cycx_netdevice_stop,
+	.ndo_start_xmit	= cycx_netdevice_hard_start_xmit,
+	.ndo_get_stats	= cycx_netdevice_get_stats,
+};
+
+static void cycx_x25_chan_setup(struct net_device *dev)
+{
+	/* Initialize device driver entry points */
+	dev->netdev_ops		= &cycx_netdev_ops;
+	dev->header_ops		= &cycx_header_ops;
+
+	/* Initialize media-specific parameters */
+	dev->mtu		= CYCX_X25_CHAN_MTU;
+	dev->type		= ARPHRD_HWX25;	/* ARP h/w type */
+	dev->hard_header_len	= 0;		/* media header length */
+	dev->addr_len		= 0;		/* hardware address length */
+}
+
 /* Initialize Linux network interface.
  *
  * This routine is called only once for each interface, during Linux network
@@ -487,20 +502,6 @@ static int cycx_netdevice_init(struct ne
 	struct cycx_device *card = chan->card;
 	struct wan_device *wandev = &card->wandev;
 
-	/* Initialize device driver entry points */
-	dev->open		= cycx_netdevice_open;
-	dev->stop		= cycx_netdevice_stop;
-	dev->header_ops		= &cycx_header_ops;
-
-	dev->hard_start_xmit	= cycx_netdevice_hard_start_xmit;
-	dev->get_stats		= cycx_netdevice_get_stats;
-
-	/* Initialize media-specific parameters */
-	dev->mtu		= CYCX_X25_CHAN_MTU;
-	dev->type		= ARPHRD_HWX25;	/* ARP h/w type */
-	dev->hard_header_len	= 0;		/* media header length */
-	dev->addr_len		= 0;		/* hardware address length */
-
 	if (!chan->svc)
 		*(__be16*)dev->dev_addr = htons(chan->lcn);
 

-- 

