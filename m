From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 15/33] skge: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:22 -0800
Message-ID: <20081117234356.067098322@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55076 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbYKRAAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:08 -0500
Content-Disposition: inline; filename=skge-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/skge.c	2008-11-04 13:58:06.000000000 -0800
+++ b/drivers/net/skge.c	2008-11-17 10:30:05.000000000 -0800
@@ -104,6 +104,7 @@ static void yukon_get_stats(struct skge_
 static void yukon_init(struct skge_hw *hw, int port);
 static void genesis_mac_init(struct skge_hw *hw, int port);
 static void genesis_link_up(struct skge_port *skge);
+static void skge_set_multicast(struct net_device *dev);
 
 /* Avoid conditionals by using array */
 static const int txqaddr[] = { Q_XA1, Q_XA2 };
@@ -2463,7 +2464,7 @@ static void skge_phy_reset(struct skge_p
 	}
 	spin_unlock_bh(&hw->phy_lock);
 
-	dev->set_multicast_list(dev);
+	skge_set_multicast(dev);
 }
 
 /* Basic MII support */
@@ -3031,6 +3032,18 @@ static inline int bad_phy_status(const s
 			(status & GMR_FS_RX_OK) == 0;
 }
 
+static void skge_set_multicast(struct net_device *dev)
+{
+	struct skge_port *skge = netdev_priv(dev);
+	struct skge_hw *hw = skge->hw;
+
+	if (hw->chip_id == CHIP_ID_GENESIS)
+		genesis_set_multicast(dev);
+	else
+		yukon_set_multicast(dev);
+
+}
+
 
 /* Get receive buffer from descriptor.
  * Handles copy of small buffers and reallocation failures
@@ -3715,7 +3728,7 @@ static int skge_device_event(struct noti
 	struct skge_port *skge;
 	struct dentry *d;
 
-	if (dev->open != &skge_up || !skge_debug)
+	if (dev->netdev_ops->open != &skge_up || !skge_debug)
 		goto done;
 
 	skge = netdev_priv(dev);
@@ -3789,6 +3802,22 @@ static __exit void skge_debug_cleanup(vo
 #define skge_debug_cleanup()
 #endif
 
+static const struct net_device_ops skge_netdev_ops = {
+	.open		= skge_up,
+	.stop		= skge_down,
+	.do_ioctl	= skge_ioctl,
+	.get_stats	= skge_get_stats,
+	.tx_timeout	= skge_tx_timeout,
+	.change_mtu	= skge_change_mtu,
+	.validate_addr	= eth_validate_addr,
+	.set_multicast_list = skge_set_multicast,
+	.set_mac_address = skge_set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = skge_netpoll,
+#endif
+};
+
+
 /* Initialize network device */
 static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 				       int highmem)
@@ -3802,24 +3831,10 @@ static struct net_device *skge_devinit(s
 	}
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
-	dev->open = skge_up;
-	dev->stop = skge_down;
-	dev->do_ioctl = skge_ioctl;
 	dev->hard_start_xmit = skge_xmit_frame;
-	dev->get_stats = skge_get_stats;
-	if (hw->chip_id == CHIP_ID_GENESIS)
-		dev->set_multicast_list = genesis_set_multicast;
-	else
-		dev->set_multicast_list = yukon_set_multicast;
-
-	dev->set_mac_address = skge_set_mac_address;
-	dev->change_mtu = skge_change_mtu;
-	SET_ETHTOOL_OPS(dev, &skge_ethtool_ops);
-	dev->tx_timeout = skge_tx_timeout;
+	dev->netdev_ops = &skge_netdev_ops;
+	dev->ethtool_ops = &skge_ethtool_ops;
 	dev->watchdog_timeo = TX_WATCHDOG;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = skge_netpoll;
-#endif
 	dev->irq = hw->pdev->irq;
 
 	if (highmem)

-- 

