From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/22] netxen: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:48 -0800
Message-ID: <20081121232239.740282588@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57036 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851AbYKUXXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:23 -0500
Content-Disposition: inline; filename=netxen-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.
Had to do some refactoring on multicast_list.
Fix ethtool restart to propogate error code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/netxen/netxen_nic_main.c	2008-11-21 13:51:09.000000000 -0800
+++ b/drivers/net/netxen/netxen_nic_main.c	2008-11-21 13:57:01.000000000 -0800
@@ -469,6 +469,31 @@ netxen_read_mac_addr(struct netxen_adapt
 	return 0;
 }
 
+static void netxen_set_multicast_list(struct net_device *dev)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_p3_nic_set_multi(dev);
+	else
+		netxen_p2_nic_set_multi(dev);
+}
+
+static const struct net_device_ops netxen_netdev_ops = {
+	.ndo_open	   = netxen_nic_open,
+	.ndo_stop	   = netxen_nic_close,
+	.ndo_start_xmit    = netxen_nic_xmit_frame,
+	.ndo_get_stats	   = netxen_nic_get_stats,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_set_multicast_list = netxen_set_multicast_list,
+	.ndo_set_mac_address    = netxen_nic_set_mac,
+	.ndo_change_mtu	   = netxen_nic_change_mtu,
+	.ndo_tx_timeout	   = netxen_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = netxen_nic_poll_controller,
+#endif
+};
+
 /*
  * netxen_nic_probe()
  *
@@ -680,25 +705,13 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	else
 		adapter->max_mc_count = 16;
 
-	netdev->open		   = netxen_nic_open;
-	netdev->stop		   = netxen_nic_close;
-	netdev->hard_start_xmit    = netxen_nic_xmit_frame;
-	netdev->get_stats	   = netxen_nic_get_stats;
-	if (NX_IS_REVISION_P3(revision_id))
-		netdev->set_multicast_list = netxen_p3_nic_set_multi;
-	else
-		netdev->set_multicast_list = netxen_p2_nic_set_multi;
-	netdev->set_mac_address    = netxen_nic_set_mac;
-	netdev->change_mtu	   = netxen_nic_change_mtu;
-	netdev->tx_timeout	   = netxen_tx_timeout;
+	netdev->netdev_ops	   = &netxen_netdev_ops;
 	netdev->watchdog_timeo     = 2*HZ;
 
 	netxen_nic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	netdev->poll_controller = netxen_nic_poll_controller;
-#endif
+
 	/* ScatterGather support */
 	netdev->features = NETIF_F_SG;
 	netdev->features |= NETIF_F_IP_CSUM;
@@ -1075,7 +1088,7 @@ static int netxen_nic_open(struct net_de
 
 	netxen_nic_set_link_parameters(adapter);
 
-	netdev->set_multicast_list(netdev);
+	netxen_set_multicast_list(netdev);
 	if (adapter->set_mtu)
 		adapter->set_mtu(adapter, netdev->mtu);
 
--- a/drivers/net/netxen/netxen_nic_ethtool.c	2008-11-21 13:51:09.000000000 -0800
+++ b/drivers/net/netxen/netxen_nic_ethtool.c	2008-11-21 13:57:20.000000000 -0800
@@ -275,11 +275,11 @@ netxen_nic_set_settings(struct net_devic
 	} else
 		return -EOPNOTSUPP;
 
-	if (netif_running(dev)) {
-		dev->stop(dev);
-		dev->open(dev);
-	}
-	return 0;
+	if (!netif_running(dev))
+		return 0;
+
+	dev->netdev_ops->ndo_stop(dev);
+	return dev->netdev_ops->ndo_open(dev);
 }
 
 static int netxen_nic_get_regs_len(struct net_device *dev)

-- 

