From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 31/33] forcedeth: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:38 -0800
Message-ID: <20081117234357.430159266@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55124 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752303AbYKRAAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:24 -0500
Content-Disposition: inline; filename=forcedeth-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/forcedeth.c	2008-11-17 14:03:51.000000000 -0800
+++ b/drivers/net/forcedeth.c	2008-11-17 14:44:45.000000000 -0800
@@ -5408,6 +5408,21 @@ static int nv_close(struct net_device *d
 	return 0;
 }
 
+static const struct net_device_ops nv_netdev_ops = {
+	.open = nv_open,
+	.stop = nv_close,
+	.get_stats = nv_get_stats,
+	.tx_timeout = nv_tx_timeout,
+	.change_mtu = nv_change_mtu,
+	.validate_addr= eth_validate_addr,
+	.set_mac_address = nv_set_mac_address,
+	.set_multicast_list = nv_set_multicast,
+	.vlan_rx_register = nv_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = nv_poll_controller,
+#endif
+};
+
 static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device *dev;
@@ -5527,7 +5542,6 @@ static int __devinit nv_probe(struct pci
 	if (id->driver_data & DEV_HAS_VLAN) {
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
 		dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
-		dev->vlan_rx_register = nv_vlan_rx_register;
 	}
 
 	np->msi_flags = 0;
@@ -5577,25 +5591,16 @@ static int __devinit nv_probe(struct pci
 	if (!np->rx_skb || !np->tx_skb)
 		goto out_freering;
 
-	dev->open = nv_open;
-	dev->stop = nv_close;
-
 	if (!nv_optimized(np))
 		dev->hard_start_xmit = nv_start_xmit;
 	else
 		dev->hard_start_xmit = nv_start_xmit_optimized;
-	dev->get_stats = nv_get_stats;
-	dev->change_mtu = nv_change_mtu;
-	dev->set_mac_address = nv_set_mac_address;
-	dev->set_multicast_list = nv_set_multicast;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = nv_poll_controller;
-#endif
+
+	dev->netdev_ops = &nv_netdev_ops;
 #ifdef CONFIG_FORCEDETH_NAPI
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
 #endif
 	SET_ETHTOOL_OPS(dev, &ops);
-	dev->tx_timeout = nv_tx_timeout;
 	dev->watchdog_timeo = NV_WATCHDOG_TIMEO;
 
 	pci_set_drvdata(pci_dev, dev);

-- 

