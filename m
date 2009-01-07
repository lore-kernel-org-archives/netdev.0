From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 22/42] starfire: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:38 -0800
Message-ID: <20090107003347.845370286@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59040 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685AbZAGAxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:50 -0500
Content-Disposition: inline; filename=starfire.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/starfire.c	2009-01-05 16:37:40.967072819 -0800
+++ b/drivers/net/starfire.c	2009-01-05 16:54:24.702569118 -0800
@@ -642,6 +642,24 @@ static void netdev_vlan_rx_kill_vid(stru
 #endif /* VLAN_SUPPORT */
 
 
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= netdev_open,
+	.ndo_stop		= netdev_close,
+	.ndo_start_xmit		= start_tx,
+	.ndo_tx_timeout 	= tx_timeout,
+	.ndo_get_stats 		= get_stats,
+	.ndo_set_multicast_list = &set_rx_mode,
+	.ndo_do_ioctl 		= netdev_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef VLAN_SUPPORT
+	.ndo_vlan_rx_register	= netdev_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= netdev_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	= netdev_vlan_rx_kill_vid,
+#endif
+};
+
 static int __devinit starfire_init_one(struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
 {
@@ -704,11 +722,9 @@ static int __devinit starfire_init_one(s
 	if (enable_hw_cksum)
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 #endif /* ZEROCOPY */
+
 #ifdef VLAN_SUPPORT
 	dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
-	dev->vlan_rx_register = netdev_vlan_rx_register;
-	dev->vlan_rx_add_vid = netdev_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid = netdev_vlan_rx_kill_vid;
 #endif /* VLAN_RX_KILL_VID */
 #ifdef ADDR_64BITS
 	dev->features |= NETIF_F_HIGHDMA;
@@ -804,18 +820,12 @@ static int __devinit starfire_init_one(s
 		}
 	}
 
-	/* The chip-specific entries in the device structure. */
-	dev->open = &netdev_open;
-	dev->hard_start_xmit = &start_tx;
-	dev->tx_timeout = tx_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	netif_napi_add(dev, &np->napi, netdev_poll, max_interrupt_work);
-	dev->stop = &netdev_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
 	SET_ETHTOOL_OPS(dev, &ethtool_ops);
 
+	netif_napi_add(dev, &np->napi, netdev_poll, max_interrupt_work);
+
 	if (mtu)
 		dev->mtu = mtu;
 

-- 

