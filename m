From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 26/33] e100: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:33 -0800
Message-ID: <20081117234357.003576785@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55108 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752342AbYKRAAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:18 -0500
Content-Disposition: inline; filename=e100-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/e100.c	2008-11-17 13:56:53.000000000 -0800
+++ b/drivers/net/e100.c	2008-11-17 14:07:06.000000000 -0800
@@ -2612,6 +2612,20 @@ static int e100_close(struct net_device 
 	return 0;
 }
 
+static const struct net_device_ops e100_netdev_ops = {
+	.open			= e100_open,
+	.stop			= e100_close,
+	.validate_addr		= eth_validate_addr,
+	.set_multicast_list	= e100_set_multicast_list,
+	.set_mac_address	= e100_set_mac_address,
+	.change_mtu		= e100_change_mtu,
+	.do_ioctl		= e100_do_ioctl,
+	.tx_timeout		= e100_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= e100_netpoll,
+#endif
+};
+
 static int __devinit e100_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
@@ -2625,19 +2639,10 @@ static int __devinit e100_probe(struct p
 		return -ENOMEM;
 	}
 
-	netdev->open = e100_open;
-	netdev->stop = e100_close;
+	netdev->netdev_ops = &e100_netdev_ops;
 	netdev->hard_start_xmit = e100_xmit_frame;
-	netdev->set_multicast_list = e100_set_multicast_list;
-	netdev->set_mac_address = e100_set_mac_address;
-	netdev->change_mtu = e100_change_mtu;
-	netdev->do_ioctl = e100_do_ioctl;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
-	netdev->tx_timeout = e100_tx_timeout;
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = e100_netpoll;
-#endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	nic = netdev_priv(netdev);
@@ -2845,7 +2850,7 @@ static pci_ers_result_t e100_io_error_de
 	struct nic *nic = netdev_priv(netdev);
 
 	/* Similar to calling e100_down(), but avoids adapter I/O. */
-	netdev->stop(netdev);
+	e100_close(netdev);
 
 	/* Detach; put netif into a state similar to hotplug unplug. */
 	napi_enable(&nic->napi);

-- 

