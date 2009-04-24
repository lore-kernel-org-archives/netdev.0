From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] veth: prevent oops caused by netdev destructor
Date: Thu, 23 Apr 2009 21:41:20 -0700
Message-ID: <20090423214120.22bcc680@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50360 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038AbZDXEl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 00:41:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth driver will oops if sysfs hooks are open while module is removed.

The net device destructor can not point to code in a module; basically
there are only two possible safe values: NULL - no destructor, or
free_netdev - free on last use


Index: linux-2.6/drivers/net/veth.c
===================================================================
--- linux-2.6.orig/drivers/net/veth.c	2009-04-22 14:28:28.074579878 -0700
+++ linux-2.6/drivers/net/veth.c	2009-04-22 14:36:35.947231135 -0700
@@ -210,14 +210,11 @@
 
 static struct net_device_stats *veth_get_stats(struct net_device *dev)
 {
-	struct veth_priv *priv;
-	struct net_device_stats *dev_stats;
-	int cpu;
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device_stats *dev_stats = &dev->stats;
+	unsigned int cpu;
 	struct veth_net_stats *stats;
 
-	priv = netdev_priv(dev);
-	dev_stats = &dev->stats;
-
 	dev_stats->rx_packets = 0;
 	dev_stats->tx_packets = 0;
 	dev_stats->rx_bytes = 0;
@@ -225,16 +222,17 @@
 	dev_stats->tx_dropped = 0;
 	dev_stats->rx_dropped = 0;
 
-	for_each_online_cpu(cpu) {
-		stats = per_cpu_ptr(priv->stats, cpu);
-
-		dev_stats->rx_packets += stats->rx_packets;
-		dev_stats->tx_packets += stats->tx_packets;
-		dev_stats->rx_bytes += stats->rx_bytes;
-		dev_stats->tx_bytes += stats->tx_bytes;
-		dev_stats->tx_dropped += stats->tx_dropped;
-		dev_stats->rx_dropped += stats->rx_dropped;
-	}
+	if (priv->stats) 
+		for_each_online_cpu(cpu) {
+			stats = per_cpu_ptr(priv->stats, cpu);
+
+			dev_stats->rx_packets += stats->rx_packets;
+			dev_stats->tx_packets += stats->tx_packets;
+			dev_stats->rx_bytes += stats->rx_bytes;
+			dev_stats->tx_bytes += stats->tx_bytes;
+			dev_stats->tx_dropped += stats->tx_dropped;
+			dev_stats->rx_dropped += stats->rx_dropped;
+		}
 
 	return dev_stats;
 }
@@ -261,6 +259,8 @@
 	netif_carrier_off(dev);
 	netif_carrier_off(priv->peer);
 
+	free_percpu(priv->stats);
+	priv->stats = NULL;
 	return 0;
 }
 
@@ -291,15 +291,6 @@
 	return 0;
 }
 
-static void veth_dev_free(struct net_device *dev)
-{
-	struct veth_priv *priv;
-
-	priv = netdev_priv(dev);
-	free_percpu(priv->stats);
-	free_netdev(dev);
-}
-
 static const struct net_device_ops veth_netdev_ops = {
 	.ndo_init            = veth_dev_init,
 	.ndo_open            = veth_open,
@@ -317,7 +308,7 @@
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
 	dev->features |= NETIF_F_LLTX;
-	dev->destructor = veth_dev_free;
+	dev->destructor = free_netdev;
 }
 
 /*
