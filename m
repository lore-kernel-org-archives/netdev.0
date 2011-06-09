From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 8/9] niu: support 64 bit stats interface
Date: Wed, 08 Jun 2011 17:54:04 -0700
Message-ID: <20110609005417.753634050@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab1FIBQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:29 -0400
Content-Disposition: inline; filename=niu-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/niu.c	2011-06-07 16:58:31.333079418 -0700
+++ b/drivers/net/niu.c	2011-06-07 17:29:17.234232746 -0700
@@ -6249,9 +6249,10 @@ static void niu_sync_mac_stats(struct ni
 		niu_sync_bmac_stats(np);
 }
 
-static void niu_get_rx_stats(struct niu *np)
+static void niu_get_rx_stats(struct niu *np,
+			     struct rtnl_link_stats64 *stats)
 {
-	unsigned long pkts, dropped, errors, bytes;
+	u64 pkts, dropped, errors, bytes;
 	struct rx_ring_info *rx_rings;
 	int i;
 
@@ -6273,15 +6274,16 @@ static void niu_get_rx_stats(struct niu
 	}
 
 no_rings:
-	np->dev->stats.rx_packets = pkts;
-	np->dev->stats.rx_bytes = bytes;
-	np->dev->stats.rx_dropped = dropped;
-	np->dev->stats.rx_errors = errors;
+	stats->rx_packets = pkts;
+	stats->rx_bytes = bytes;
+	stats->rx_dropped = dropped;
+	stats->rx_errors = errors;
 }
 
-static void niu_get_tx_stats(struct niu *np)
+static void niu_get_tx_stats(struct niu *np,
+			     struct rtnl_link_stats64 *stats)
 {
-	unsigned long pkts, errors, bytes;
+	u64 pkts, errors, bytes;
 	struct tx_ring_info *tx_rings;
 	int i;
 
@@ -6300,20 +6302,22 @@ static void niu_get_tx_stats(struct niu
 	}
 
 no_rings:
-	np->dev->stats.tx_packets = pkts;
-	np->dev->stats.tx_bytes = bytes;
-	np->dev->stats.tx_errors = errors;
+	stats->tx_packets = pkts;
+	stats->tx_bytes = bytes;
+	stats->tx_errors = errors;
 }
 
-static struct net_device_stats *niu_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *niu_get_stats(struct net_device *dev,
+					       struct rtnl_link_stats64 *stats)
 {
 	struct niu *np = netdev_priv(dev);
 
 	if (netif_running(dev)) {
-		niu_get_rx_stats(np);
-		niu_get_tx_stats(np);
+		niu_get_rx_stats(np, stats);
+		niu_get_tx_stats(np, stats);
 	}
-	return &dev->stats;
+
+	return stats;
 }
 
 static void niu_load_hash_xmac(struct niu *np, u16 *hash)
@@ -9711,7 +9715,7 @@ static const struct net_device_ops niu_n
 	.ndo_open		= niu_open,
 	.ndo_stop		= niu_close,
 	.ndo_start_xmit		= niu_start_xmit,
-	.ndo_get_stats		= niu_get_stats,
+	.ndo_get_stats64	= niu_get_stats,
 	.ndo_set_multicast_list	= niu_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= niu_set_mac_addr,


