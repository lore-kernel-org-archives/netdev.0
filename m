From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 16:41:49 +0100
Message-ID: <1289403709.2860.216.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38434 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756623Ab0KJPl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 10:41:56 -0500
Received: by eye27 with SMTP id 27so380276eye.19
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 07:41:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvlan is a stacked device, like tunnels. We should use the lockless
mechanism we are using in tunnels and loopback.

This patch completely removes locking in TX path.

tx stat counters are added into existing percpu stat structure, renamed
from rx_stats to pcpu_stats.

Note : this reverts commit 2c11455321f37 (macvlan: add multiqueue
capability)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/macvlan.c      |   72 +++++++++++++----------------------
 include/linux/if_macvlan.h |   26 +++++++-----
 2 files changed, 43 insertions(+), 55 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0fc9dc7..fce80a7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -243,17 +243,19 @@ xmit_world:
 netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 			       struct net_device *dev)
 {
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	unsigned int len = skb->len;
 	int ret;
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_pcpu_stats *pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
 
 	ret = macvlan_queue_xmit(skb, dev);
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
+		u64_stats_update_begin(&pcpu_stats->syncp);
+		pcpu_stats->tx_packets++;
+		pcpu_stats->tx_bytes += len;
+		u64_stats_update_end(&pcpu_stats->syncp);
 	} else
-		txq->tx_dropped++;
+		pcpu_stats->tx_dropped++;
 
 	return ret;
 }
@@ -414,14 +416,15 @@ static int macvlan_init(struct net_device *dev)
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
+	dev->features		|= NETIF_F_LLTX;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
 
 	macvlan_set_lockdep_class(dev);
 
-	vlan->rx_stats = alloc_percpu(struct macvlan_rx_stats);
-	if (!vlan->rx_stats)
+	vlan->pcpu_stats = alloc_percpu(struct macvlan_pcpu_stats);
+	if (!vlan->pcpu_stats)
 		return -ENOMEM;
 
 	return 0;
@@ -431,7 +434,7 @@ static void macvlan_uninit(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	free_percpu(vlan->rx_stats);
+	free_percpu(vlan->pcpu_stats);
 }
 
 static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
@@ -439,33 +442,34 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	dev_txq_stats_fold(dev, stats);
-
-	if (vlan->rx_stats) {
-		struct macvlan_rx_stats *p, accum = {0};
-		u64 rx_packets, rx_bytes, rx_multicast;
+	if (vlan->pcpu_stats) {
+		struct macvlan_pcpu_stats *p;
+		u64 rx_packets, rx_bytes, rx_multicast, tx_packets, tx_bytes;
 		unsigned int start;
 		int i;
 
 		for_each_possible_cpu(i) {
-			p = per_cpu_ptr(vlan->rx_stats, i);
+			p = per_cpu_ptr(vlan->pcpu_stats, i);
 			do {
 				start = u64_stats_fetch_begin_bh(&p->syncp);
 				rx_packets	= p->rx_packets;
 				rx_bytes	= p->rx_bytes;
 				rx_multicast	= p->rx_multicast;
+				tx_packets	= p->tx_packets;
+				tx_bytes	= p->tx_bytes;
 			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
-			accum.rx_packets	+= rx_packets;
-			accum.rx_bytes		+= rx_bytes;
-			accum.rx_multicast	+= rx_multicast;
-			/* rx_errors is an ulong, updated without syncp protection */
-			accum.rx_errors		+= p->rx_errors;
+			stats->rx_packets	+= rx_packets;
+			stats->rx_bytes		+= rx_bytes;
+			stats->multicast	+= rx_multicast;
+			stats->tx_packets	+= tx_packets;
+			stats->tx_bytes		+= tx_bytes;
+			/* rx_errors & tx_dropped are ulong, updated
+			 * without syncp protection
+			 */
+			stats->rx_errors	+= p->rx_errors;
+			stats->tx_dropped	+= p->tx_dropped;
 		}
-		stats->rx_packets = accum.rx_packets;
-		stats->rx_bytes   = accum.rx_bytes;
-		stats->rx_errors  = accum.rx_errors;
-		stats->rx_dropped = accum.rx_errors;
-		stats->multicast  = accum.rx_multicast;
+		stats->rx_dropped = stats->rx_errors;
 	}
 	return stats;
 }
@@ -601,25 +605,6 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int macvlan_get_tx_queues(struct net *net,
-				 struct nlattr *tb[],
-				 unsigned int *num_tx_queues,
-				 unsigned int *real_num_tx_queues)
-{
-	struct net_device *real_dev;
-
-	if (!tb[IFLA_LINK])
-		return -EINVAL;
-
-	real_dev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
-	if (!real_dev)
-		return -ENODEV;
-
-	*num_tx_queues      = real_dev->num_tx_queues;
-	*real_num_tx_queues = real_dev->real_num_tx_queues;
-	return 0;
-}
-
 int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[],
 			   int (*receive)(struct sk_buff *skb),
@@ -743,7 +728,6 @@ int macvlan_link_register(struct rtnl_link_ops *ops)
 {
 	/* common fields */
 	ops->priv_size		= sizeof(struct macvlan_dev);
-	ops->get_tx_queues	= macvlan_get_tx_queues;
 	ops->validate		= macvlan_validate;
 	ops->maxtype		= IFLA_MACVLAN_MAX;
 	ops->policy		= macvlan_policy;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 8a2fd66..3779b5f 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -25,19 +25,23 @@ struct macvlan_port;
 struct macvtap_queue;
 
 /**
- *	struct macvlan_rx_stats - MACVLAN percpu rx stats
+ *	struct macvlan_pcpu_stats - MACVLAN percpu stats
  *	@rx_packets: number of received packets
  *	@rx_bytes: number of received bytes
  *	@rx_multicast: number of received multicast packets
+ *	@tx_
  *	@syncp: synchronization point for 64bit counters
  *	@rx_errors: number of errors
  */
-struct macvlan_rx_stats {
+struct macvlan_pcpu_stats {
 	u64			rx_packets;
 	u64			rx_bytes;
 	u64			rx_multicast;
+	u64			tx_packets;
+	u64			tx_bytes;
 	struct u64_stats_sync	syncp;
 	unsigned long		rx_errors;
+	unsigned long		tx_dropped;
 };
 
 /*
@@ -52,7 +56,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
-	struct macvlan_rx_stats __percpu *rx_stats;
+	struct macvlan_pcpu_stats __percpu *pcpu_stats;
 	enum macvlan_mode	mode;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
@@ -64,18 +68,18 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 				    unsigned int len, bool success,
 				    bool multicast)
 {
-	struct macvlan_rx_stats *rx_stats;
+	struct macvlan_pcpu_stats *pcpu_stats;
 
-	rx_stats = this_cpu_ptr(vlan->rx_stats);
+	pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
 	if (likely(success)) {
-		u64_stats_update_begin(&rx_stats->syncp);
-		rx_stats->rx_packets++;;
-		rx_stats->rx_bytes += len;
+		u64_stats_update_begin(&pcpu_stats->syncp);
+		pcpu_stats->rx_packets++;;
+		pcpu_stats->rx_bytes += len;
 		if (multicast)
-			rx_stats->rx_multicast++;
-		u64_stats_update_end(&rx_stats->syncp);
+			pcpu_stats->rx_multicast++;
+		u64_stats_update_end(&pcpu_stats->syncp);
 	} else {
-		rx_stats->rx_errors++;
+		pcpu_stats->rx_errors++;
 	}
 }
 


