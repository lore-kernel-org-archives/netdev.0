From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/22] efx: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:49 -0800
Message-ID: <20081121232239.826434876@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57037 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754873AbYKUXXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:23 -0500
Content-Disposition: inline; filename=efx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sfc/efx.c	2008-11-21 13:57:58.000000000 -0800
+++ b/drivers/net/sfc/efx.c	2008-11-21 14:09:48.000000000 -0800
@@ -1433,12 +1433,28 @@ static void efx_set_multicast_list(struc
 	falcon_set_multicast_hash(efx);
 }
 
+static const struct net_device_ops efx_netdev_ops = {
+	.ndo_open		= efx_net_open,
+	.ndo_stop		= efx_net_stop,
+	.ndo_get_stats		= efx_net_stats,
+	.ndo_tx_timeout		= efx_watchdog,
+	.ndo_start_xmit		= efx_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= efx_ioctl,
+	.ndo_change_mtu		= efx_change_mtu,
+	.ndo_set_mac_address	= efx_set_mac_address,
+	.ndo_set_multicast_list = efx_set_multicast_list,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = efx_netpoll,
+#endif
+};
+
 static int efx_netdev_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
 	struct net_device *net_dev = ptr;
 
-	if (net_dev->open == efx_net_open && event == NETDEV_CHANGENAME) {
+	if (net_dev->netdev_ops == &efx_netdev_ops && event == NETDEV_CHANGENAME) {
 		struct efx_nic *efx = netdev_priv(net_dev);
 
 		strcpy(efx->name, net_dev->name);
@@ -1459,18 +1475,7 @@ static int efx_register_netdev(struct ef
 
 	net_dev->watchdog_timeo = 5 * HZ;
 	net_dev->irq = efx->pci_dev->irq;
-	net_dev->open = efx_net_open;
-	net_dev->stop = efx_net_stop;
-	net_dev->get_stats = efx_net_stats;
-	net_dev->tx_timeout = &efx_watchdog;
-	net_dev->hard_start_xmit = efx_hard_start_xmit;
-	net_dev->do_ioctl = efx_ioctl;
-	net_dev->change_mtu = efx_change_mtu;
-	net_dev->set_mac_address = efx_set_mac_address;
-	net_dev->set_multicast_list = efx_set_multicast_list;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	net_dev->poll_controller = efx_netpoll;
-#endif
+	net_dev->netdev_ops = &efx_netdev_ops;
 	SET_NETDEV_DEV(net_dev, &efx->pci_dev->dev);
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
 

-- 

