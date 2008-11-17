From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 22/33] cxgb2: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:29 -0800
Message-ID: <20081117234356.667397719@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55096 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752212AbYKRAAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:14 -0500
Content-Disposition: inline; filename=cxgb2-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/chelsio/cxgb2.c	2008-11-17 13:56:56.000000000 -0800
+++ b/drivers/net/chelsio/cxgb2.c	2008-11-17 14:46:24.000000000 -0800
@@ -1010,6 +1010,21 @@ void t1_fatal_err(struct adapter *adapte
 		 adapter->name);
 }
 
+static const struct net_device_ops cxgb_netdev_ops = {
+	.open = cxgb_open,
+	.stop = cxgb_close,
+	.get_stats = t1_get_stats,
+	.validate_addr	= eth_validate_addr,
+	.set_multicast_list = t1_set_rxmode,
+	.do_ioctl = t1_ioctl,
+	.change_mtu = t1_change_mtu,
+	.set_mac_address = t1_set_mac_addr,
+	.vlan_rx_register = vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = t1_netpoll,
+#endif
+};
+
 static int __devinit init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -1130,7 +1145,6 @@ static int __devinit init_one(struct pci
 			adapter->flags |= VLAN_ACCEL_CAPABLE;
 			netdev->features |=
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-			netdev->vlan_rx_register = vlan_rx_register;
 #endif
 
 			/* T204: disable TSO */
@@ -1140,19 +1154,11 @@ static int __devinit init_one(struct pci
 			}
 		}
 
-		netdev->open = cxgb_open;
-		netdev->stop = cxgb_close;
+		netdev->netdev_ops = &cxgb_netdev_ops;
 		netdev->hard_start_xmit = t1_start_xmit;
 		netdev->hard_header_len += (adapter->flags & TSO_CAPABLE) ?
 			sizeof(struct cpl_tx_pkt_lso) : sizeof(struct cpl_tx_pkt);
-		netdev->get_stats = t1_get_stats;
-		netdev->set_multicast_list = t1_set_rxmode;
-		netdev->do_ioctl = t1_ioctl;
-		netdev->change_mtu = t1_change_mtu;
-		netdev->set_mac_address = t1_set_mac_addr;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-		netdev->poll_controller = t1_netpoll;
-#endif
+
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
 
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);

-- 

