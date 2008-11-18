From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 22/33] cxgb2: convert to net_device_ops
Date: Mon, 17 Nov 2008 17:40:20 -0800
Message-ID: <20081117174020.3a888ff6@extreme>
References: <20081117234207.854110282@vyatta.com>
	<20081117234356.667397719@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36854 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751875AbYKRBkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 20:40:22 -0500
In-Reply-To: <20081117234356.667397719@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile teseted only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Need to handle non-vlan cas as well.

--- a/drivers/net/chelsio/cxgb2.c	2008-11-17 17:21:58.000000000 -0800
+++ b/drivers/net/chelsio/cxgb2.c	2008-11-17 17:26:09.000000000 -0800
@@ -1010,6 +1010,23 @@ void t1_fatal_err(struct adapter *adapte
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
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	.vlan_rx_register = vlan_rx_register,
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = t1_netpoll,
+#endif
+};
+
 static int __devinit init_one(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -1130,7 +1147,6 @@ static int __devinit init_one(struct pci
 			adapter->flags |= VLAN_ACCEL_CAPABLE;
 			netdev->features |=
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-			netdev->vlan_rx_register = vlan_rx_register;
 #endif
 
 			/* T204: disable TSO */
@@ -1140,19 +1156,11 @@ static int __devinit init_one(struct pci
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
