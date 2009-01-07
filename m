From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 30/42] windbond: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:46 -0800
Message-ID: <20090107003348.708279619@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52740 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757808AbZAGA7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:59:16 -0500
Content-Disposition: inline; filename=tulip-winb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/winbond-840.c	2009-01-06 16:08:31.185364727 -0800
+++ b/drivers/net/tulip/winbond-840.c	2009-01-06 16:13:50.845109956 -0800
@@ -343,7 +343,18 @@ static int netdev_ioctl(struct net_devic
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  netdev_close(struct net_device *dev);
 
-
+static const struct net_device_ops netdev_ops = {
+	.ndo_open		= netdev_open,
+	.ndo_stop		= netdev_close,
+	.ndo_start_xmit		= start_tx,
+	.ndo_get_stats		= get_stats,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_do_ioctl		= netdev_ioctl,
+	.ndo_tx_timeout		= tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 static int __devinit w840_probe1 (struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
@@ -420,14 +431,8 @@ static int __devinit w840_probe1 (struct
 		np->mii_if.force_media = 1;
 
 	/* The chip-specific entries in the device structure. */
-	dev->open = &netdev_open;
-	dev->hard_start_xmit = &start_tx;
-	dev->stop = &netdev_close;
-	dev->get_stats = &get_stats;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->do_ioctl = &netdev_ioctl;
+	dev->netdev_ops = &netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = &tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	i = register_netdev(dev);
@@ -1555,7 +1560,7 @@ static void __devexit w840_remove1 (stru
  * 	rtnl_lock, & netif_device_detach after the rtnl_unlock.
  * - get_stats:
  * 	spin_lock_irq(np->lock), doesn't touch hw if not present
- * - hard_start_xmit:
+ * - start_xmit:
  * 	synchronize_irq + netif_tx_disable;
  * - tx_timeout:
  * 	netif_device_detach + netif_tx_disable;

-- 

