From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/9] myricom: update to 64 bit stats
Date: Wed, 08 Jun 2011 17:54:03 -0700
Message-ID: <20110609005417.688902862@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab1FIBQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:38 -0400
Content-Disposition: inline; filename=myricom-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver was already keeping 64 bit counters, just not using the new interface.

Ps: IMHO drivers should not be duplicating network device
stats into ethtool stats. It is useless duplication.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/myri10ge/myri10ge.c	2011-06-07 16:58:31.333079418 -0700
+++ b/drivers/net/myri10ge/myri10ge.c	2011-06-07 17:29:13.298213223 -0700
@@ -377,7 +377,8 @@ static inline void put_be32(__be32 val,
 	__raw_writel((__force __u32) val, (__force void __iomem *)p);
 }
 
-static struct net_device_stats *myri10ge_get_stats(struct net_device *dev);
+static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
+						    struct rtnl_link_stats64 *stats);
 
 static void set_fw_name(struct myri10ge_priv *mgp, char *name, bool allocated)
 {
@@ -1831,13 +1832,14 @@ myri10ge_get_ethtool_stats(struct net_de
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 	struct myri10ge_slice_state *ss;
+	struct rtnl_link_stats64 link_stats;
 	int slice;
 	int i;
 
 	/* force stats update */
-	(void)myri10ge_get_stats(netdev);
+	(void)myri10ge_get_stats(netdev, &link_stats);
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
-		data[i] = ((unsigned long *)&netdev->stats)[i];
+		data[i] = ((u64 *)&link_stats)[i];
 
 	data[i++] = (unsigned int)mgp->tx_boundary;
 	data[i++] = (unsigned int)mgp->wc_enabled;
@@ -2976,11 +2978,11 @@ drop:
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *myri10ge_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
+						    struct rtnl_link_stats64 *stats)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	struct myri10ge_slice_netstats *slice_stats;
-	struct net_device_stats *stats = &dev->stats;
 	int i;
 
 	spin_lock(&mgp->stats_lock);
@@ -3790,7 +3792,7 @@ static const struct net_device_ops myri1
 	.ndo_open		= myri10ge_open,
 	.ndo_stop		= myri10ge_close,
 	.ndo_start_xmit		= myri10ge_xmit,
-	.ndo_get_stats		= myri10ge_get_stats,
+	.ndo_get_stats64	= myri10ge_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= myri10ge_change_mtu,
 	.ndo_fix_features	= myri10ge_fix_features,


