From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/22] r6040: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:52 -0800
Message-ID: <20081121232240.080345224@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57049 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755036AbYKUXX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:27 -0500
Content-Disposition: inline; filename=r6040.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/r6040.c	2008-11-21 14:22:06.000000000 -0800
+++ b/drivers/net/r6040.c	2008-11-21 14:25:01.000000000 -0800
@@ -1029,13 +1029,28 @@ static u32 netdev_get_link(struct net_de
 	return mii_link_ok(&rp->mii_if);
 }
 
-static struct ethtool_ops netdev_ethtool_ops = {
+static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
 	.set_settings		= netdev_set_settings,
 	.get_link		= netdev_get_link,
 };
 
+static const struct net_device_ops r6040_netdev_ops = {
+	.ndo_open		= r6040_open,
+	.ndo_stop		= r6040_close,
+	.ndo_start_xmit		= r6040_start_xmit,
+	.ndo_get_stats		= r6040_get_stats,
+	.ndo_set_multicast_list = r6040_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= r6040_ioctl,
+	.ndo_tx_timeout		= r6040_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= r6040_poll_controller,
+#endif
+};
+
 static int __devinit r6040_init_one(struct pci_dev *pdev,
 					 const struct pci_device_id *ent)
 {
@@ -1127,18 +1142,10 @@ static int __devinit r6040_init_one(stru
 	lp->switch_sig = 0;
 
 	/* The RDC-specific entries in the device structure. */
-	dev->open = &r6040_open;
-	dev->hard_start_xmit = &r6040_start_xmit;
-	dev->stop = &r6040_close;
-	dev->get_stats = r6040_get_stats;
-	dev->set_multicast_list = &r6040_multicast_list;
-	dev->do_ioctl = &r6040_ioctl;
+	dev->netdev_ops = &r6040_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = &r6040_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = r6040_poll_controller;
-#endif
+
 	netif_napi_add(dev, &lp->napi, r6040_poll, 64);
 	lp->mii_if.dev = dev;
 	lp->mii_if.mdio_read = r6040_mdio_read;

-- 

