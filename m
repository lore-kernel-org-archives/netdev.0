From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v2] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 08:14:04 +0100
Message-ID: <1289459644.17691.1011.camel@edumazet-laptop>
References: <1289403709.2860.216.camel@edumazet-laptop>
	 <4CDAD8C8.20807@candelatech.com>
	 <1289411027.2860.248.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34009 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757725Ab0KKHOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 02:14:09 -0500
Received: by wwb28 with SMTP id 28so223679wwb.1
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 23:14:07 -0800 (PST)
In-Reply-To: <1289411027.2860.248.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macvlan is a stacked device, like tunnels. We should use the lockless
mechanism we are using in tunnels and loopback.

This patch completely removes locking in TX path.

tx stat counters are added into existing percpu stat structure, renamed
from rx_stats to pcpu_stats.

Note : this reverts commit 2c11455321f37 (macvlan: add multiqueue
capability)

Note : rx_errors converted to a 32bit counter, like tx_dropped, since
they dont need 64bit range.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Ben Greear <greearb@candelatech.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
V2: correct kerneldoc
    u32 for tx_dropped and rx_errors

 drivers/net/macvlan.c      |   80 +++++++++++++++--------------------
 include/linux/if_macvlan.h |   34 ++++++++------
 2 files changed, 55 insertions(+), 59 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0fc9dc7..93f0ba2 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -243,18 +243,22 @@ xmit_world:
 netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
 			       struct net_device *dev)
 {
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	unsigned int len = skb->len;
 	int ret;
+	const struct macvlan_dev *vlan = netdev_priv(dev);
 
 	ret = macvlan_queue_xmit(skb, dev);
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
-	} else
-		txq->tx_dropped++;
+		struct macvlan_pcpu_stats *pcpu_stats;
 
+		pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
+		u64_stats_update_begin(&pcpu_stats->syncp);
+		pcpu_stats->tx_packets++;
+		pcpu_stats->tx_bytes += len;
+		u64_stats_update_end(&pcpu_stats->syncp);
+	} else {
+		this_cpu_inc(vlan->pcpu_stats->tx_dropped);
+	}
 	return ret;
 }
 EXPORT_SYMBOL_GPL(macvlan_start_xmit);
@@ -414,14 +418,15 @@ static int macvlan_init(struct net_device *dev)
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
@@ -431,7 +436,7 @@ static void macvlan_uninit(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
-	free_percpu(vlan->rx_stats);
+	free_percpu(vlan->pcpu_stats);
 }
 
 static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
@@ -439,33 +444,38 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
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
+		u32 rx_errors = 0, tx_dropped = 0;
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
+
+			stats->rx_packets	+= rx_packets;
+			stats->rx_bytes		+= rx_bytes;
+			stats->multicast	+= rx_multicast;
+			stats->tx_packets	+= tx_packets;
+			stats->tx_bytes		+= tx_bytes;
+			/* rx_errors & tx_dropped are u32, updated
+			 * without syncp protection.
+			 */
+			rx_errors	+= p->rx_errors;
+			tx_dropped	+= p->tx_dropped;
 		}
-		stats->rx_packets = accum.rx_packets;
-		stats->rx_bytes   = accum.rx_bytes;
-		stats->rx_errors  = accum.rx_errors;
-		stats->rx_dropped = accum.rx_errors;
-		stats->multicast  = accum.rx_multicast;
+		stats->rx_errors	= rx_errors;
+		stats->rx_dropped	= rx_errors;
+		stats->tx_dropped	= tx_dropped;
 	}
 	return stats;
 }
@@ -601,25 +611,6 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
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
@@ -743,7 +734,6 @@ int macvlan_link_register(struct rtnl_link_ops *ops)
 {
 	/* common fields */
 	ops->priv_size		= sizeof(struct macvlan_dev);
-	ops->get_tx_queues	= macvlan_get_tx_queues;
 	ops->validate		= macvlan_validate;
 	ops->maxtype		= IFLA_MACVLAN_MAX;
 	ops->policy		= macvlan_policy;
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 8a2fd66..e28b2e4 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -25,19 +25,25 @@ struct macvlan_port;
 struct macvtap_queue;
 
 /**
- *	struct macvlan_rx_stats - MACVLAN percpu rx stats
+ *	struct macvlan_pcpu_stats - MACVLAN percpu stats
  *	@rx_packets: number of received packets
  *	@rx_bytes: number of received bytes
  *	@rx_multicast: number of received multicast packets
+ *	@tx_packets: number of transmitted packets
+ *	@tx_bytes: number of transmitted bytes
  *	@syncp: synchronization point for 64bit counters
- *	@rx_errors: number of errors
+ *	@rx_errors: number of rx errors
+ *	@tx_dropped: number of tx dropped packets
  */
-struct macvlan_rx_stats {
+struct macvlan_pcpu_stats {
 	u64			rx_packets;
 	u64			rx_bytes;
 	u64			rx_multicast;
+	u64			tx_packets;
+	u64			tx_bytes;
 	struct u64_stats_sync	syncp;
-	unsigned long		rx_errors;
+	u32			rx_errors;
+	u32			tx_dropped;
 };
 
 /*
@@ -52,7 +58,7 @@ struct macvlan_dev {
 	struct hlist_node	hlist;
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
-	struct macvlan_rx_stats __percpu *rx_stats;
+	struct macvlan_pcpu_stats __percpu *pcpu_stats;
 	enum macvlan_mode	mode;
 	int (*receive)(struct sk_buff *skb);
 	int (*forward)(struct net_device *dev, struct sk_buff *skb);
@@ -64,18 +70,18 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 				    unsigned int len, bool success,
 				    bool multicast)
 {
-	struct macvlan_rx_stats *rx_stats;
-
-	rx_stats = this_cpu_ptr(vlan->rx_stats);
 	if (likely(success)) {
-		u64_stats_update_begin(&rx_stats->syncp);
-		rx_stats->rx_packets++;;
-		rx_stats->rx_bytes += len;
+		struct macvlan_pcpu_stats *pcpu_stats;
+
+		pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
+		u64_stats_update_begin(&pcpu_stats->syncp);
+		pcpu_stats->rx_packets++;
+		pcpu_stats->rx_bytes += len;
 		if (multicast)
-			rx_stats->rx_multicast++;
-		u64_stats_update_end(&rx_stats->syncp);
+			pcpu_stats->rx_multicast++;
+		u64_stats_update_end(&pcpu_stats->syncp);
 	} else {
-		rx_stats->rx_errors++;
+		this_cpu_inc(vlan->pcpu_stats->rx_errors);
 	}
 }
 


