From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] veth: reduce stat overhead
Date: Sat, 29 Dec 2012 18:02:43 -0800
Message-ID: <1356832963.21409.6156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:47453 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778Ab2L3CCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 21:02:45 -0500
Received: by mail-pb0-f48.google.com with SMTP id rq13so6575693pbb.7
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 18:02:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

veth stats are a bit bloated. There is no need to account transmit
and receive stats, since they are absolutely symmetric.

Also use a per device atomic64_t for the dropped counter, as it
should never be used in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/veth.c        |  115 ++++++++++++++----------------------
 include/linux/netdevice.h |    1 
 2 files changed, 48 insertions(+), 68 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 95814d9..c048f8d 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -25,18 +25,15 @@
 #define MIN_MTU 68		/* Min L3 MTU */
 #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
 
-struct veth_net_stats {
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			tx_packets;
-	u64			tx_bytes;
-	u64			rx_dropped;
+struct pcpu_vstats {
+	u64			packets;
+	u64			bytes;
 	struct u64_stats_sync	syncp;
 };
 
 struct veth_priv {
-	struct net_device *peer;
-	struct veth_net_stats __percpu *stats;
+	struct net_device	*peer;
+	atomic64_t		dropped;
 };
 
 /*
@@ -107,50 +104,30 @@ static const struct ethtool_ops veth_ethtool_ops = {
 	.get_ethtool_stats	= veth_get_ethtool_stats,
 };
 
-/*
- * xmit
- */
-
 static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device *rcv = NULL;
-	struct veth_priv *priv, *rcv_priv;
-	struct veth_net_stats *stats, *rcv_stats;
-	int length;
-
-	priv = netdev_priv(dev);
-	rcv = priv->peer;
-	rcv_priv = netdev_priv(rcv);
-
-	stats = this_cpu_ptr(priv->stats);
-	rcv_stats = this_cpu_ptr(rcv_priv->stats);
+	struct veth_priv *priv = netdev_priv(dev);
+	struct net_device *rcv = priv->peer;
+	int length = skb->len;
 
 	/* don't change ip_summed == CHECKSUM_PARTIAL, as that
-	   will cause bad checksum on forwarded packets */
+	 * will cause bad checksum on forwarded packets
+	 */
 	if (skb->ip_summed == CHECKSUM_NONE &&
 	    rcv->features & NETIF_F_RXCSUM)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	length = skb->len;
-	if (dev_forward_skb(rcv, skb) != NET_RX_SUCCESS)
-		goto rx_drop;
-
-	u64_stats_update_begin(&stats->syncp);
-	stats->tx_bytes += length;
-	stats->tx_packets++;
-	u64_stats_update_end(&stats->syncp);
+	if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
+		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
 
-	u64_stats_update_begin(&rcv_stats->syncp);
-	rcv_stats->rx_bytes += length;
-	rcv_stats->rx_packets++;
-	u64_stats_update_end(&rcv_stats->syncp);
-
-	return NETDEV_TX_OK;
+		u64_stats_update_begin(&stats->syncp);
+		stats->bytes += length;
+		stats->packets++;
+		u64_stats_update_end(&stats->syncp);
+	} else {
+		atomic64_inc(&priv->dropped);
+	}
 
-rx_drop:
-	u64_stats_update_begin(&rcv_stats->syncp);
-	rcv_stats->rx_dropped++;
-	u64_stats_update_end(&rcv_stats->syncp);
 	return NETDEV_TX_OK;
 }
 
@@ -158,32 +135,42 @@ rx_drop:
  * general routines
  */
 
-static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
-						  struct rtnl_link_stats64 *tot)
+static u64 veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
 {
 	struct veth_priv *priv = netdev_priv(dev);
 	int cpu;
 
+	result->packets = 0;
+	result->bytes = 0;
 	for_each_possible_cpu(cpu) {
-		struct veth_net_stats *stats = per_cpu_ptr(priv->stats, cpu);
-		u64 rx_packets, rx_bytes, rx_dropped;
-		u64 tx_packets, tx_bytes;
+		struct pcpu_vstats *stats = per_cpu_ptr(dev->vstats, cpu);
+		u64 packets, bytes;
 		unsigned int start;
 
 		do {
 			start = u64_stats_fetch_begin_bh(&stats->syncp);
-			rx_packets = stats->rx_packets;
-			tx_packets = stats->tx_packets;
-			rx_bytes = stats->rx_bytes;
-			tx_bytes = stats->tx_bytes;
-			rx_dropped = stats->rx_dropped;
+			packets = stats->packets;
+			bytes = stats->bytes;
 		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
-		tot->rx_packets += rx_packets;
-		tot->tx_packets += tx_packets;
-		tot->rx_bytes   += rx_bytes;
-		tot->tx_bytes   += tx_bytes;
-		tot->rx_dropped += rx_dropped;
+		result->packets += packets;
+		result->bytes += bytes;
 	}
+	return atomic64_read(&priv->dropped);
+}
+
+static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
+						  struct rtnl_link_stats64 *tot)
+{
+	struct veth_priv *priv = netdev_priv(dev);
+	struct pcpu_vstats one;
+
+	tot->tx_dropped = veth_stats_one(&one, dev);
+	tot->tx_bytes = one.bytes;
+	tot->tx_packets = one.packets;
+
+	tot->rx_dropped = veth_stats_one(&one, priv->peer);
+	tot->rx_bytes = one.bytes;
+	tot->rx_packets = one.packets;
 
 	return tot;
 }
@@ -228,24 +215,16 @@ static int veth_change_mtu(struct net_device *dev, int new_mtu)
 
 static int veth_dev_init(struct net_device *dev)
 {
-	struct veth_net_stats __percpu *stats;
-	struct veth_priv *priv;
-
-	stats = alloc_percpu(struct veth_net_stats);
-	if (stats == NULL)
+	dev->vstats = alloc_percpu(struct pcpu_vstats);
+	if (!dev->vstats)
 		return -ENOMEM;
 
-	priv = netdev_priv(dev);
-	priv->stats = stats;
 	return 0;
 }
 
 static void veth_dev_free(struct net_device *dev)
 {
-	struct veth_priv *priv;
-
-	priv = netdev_priv(dev);
-	free_percpu(priv->stats);
+	free_percpu(dev->vstats);
 	free_netdev(dev);
 }
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c599e47..e3f5755 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1274,6 +1274,7 @@ struct net_device {
 		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
 		struct pcpu_tstats __percpu	*tstats; /* tunnel stats */
 		struct pcpu_dstats __percpu	*dstats; /* dummy stats */
+		struct pcpu_vstats __percpu	*vstats; /* veth stats */
 	};
 	/* GARP */
 	struct garp_port __rcu	*garp_port;
