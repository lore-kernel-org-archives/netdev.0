From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: lockless transmit path
Date: Thu, 11 Nov 2010 10:42:00 +0100
Message-ID: <1289468520.17691.1018.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56709 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828Ab0KKJmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 04:42:04 -0500
Received: by wyb28 with SMTP id 28so466902wyb.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 01:42:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan is a stacked device, like tunnels. We should use the lockless
mechanism we are using in tunnels and loopback.

This patch completely removes locking in TX path.

tx stat counters are added into existing percpu stat structure, renamed
from vlan_rx_stats to vlan_pcpu_stats.

Note : this partially reverts commit 2e59af3dcbdf (vlan: multiqueue vlan
device)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan.c         |    4 -
 net/8021q/vlan.h         |   16 +++++--
 net/8021q/vlan_core.c    |    4 -
 net/8021q/vlan_dev.c     |   78 +++++++++++++++++++++----------------
 net/8021q/vlan_netlink.c |   20 ---------
 5 files changed, 59 insertions(+), 63 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 52077ca..2f54ce8 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -272,13 +272,11 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
-	new_dev = alloc_netdev_mq(sizeof(struct vlan_dev_info), name,
-				  vlan_setup, real_dev->num_tx_queues);
+	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name, vlan_setup);
 
 	if (new_dev == NULL)
 		return -ENOBUFS;
 
-	netif_copy_real_num_queues(new_dev, real_dev);
 	dev_net_set(new_dev, net);
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index db01b31..a2dafb1 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -19,19 +19,25 @@ struct vlan_priority_tci_mapping {
 
 
 /**
- *	struct vlan_rx_stats - VLAN percpu rx stats
+ *	struct vlan_pcpu_stats - VLAN percpu rx/tx stats
  *	@rx_packets: number of received packets
  *	@rx_bytes: number of received bytes
  *	@rx_multicast: number of received multicast packets
+ *	@tx_packets: number of transmitted packets
+ *	@tx_bytes: number of transmitted bytes
  *	@syncp: synchronization point for 64bit counters
- *	@rx_errors: number of errors
+ *	@rx_errors: number of rx errors
+ *	@tx_dropped: number of tx drops
  */
-struct vlan_rx_stats {
+struct vlan_pcpu_stats {
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
 
 /**
@@ -64,7 +70,7 @@ struct vlan_dev_info {
 	struct proc_dir_entry			*dent;
 	unsigned long				cnt_inc_headroom_on_tx;
 	unsigned long				cnt_encap_on_xmit;
-	struct vlan_rx_stats __percpu		*vlan_rx_stats;
+	struct vlan_pcpu_stats __percpu		*vlan_pcpu_stats;
 };
 
 static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 69b2f79..ce8e3ab 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -9,7 +9,7 @@ bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
 	struct sk_buff *skb = *skbp;
 	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
 	struct net_device *vlan_dev;
-	struct vlan_rx_stats *rx_stats;
+	struct vlan_pcpu_stats *rx_stats;
 
 	vlan_dev = vlan_find_dev(skb->dev, vlan_id);
 	if (!vlan_dev) {
@@ -26,7 +26,7 @@ bool vlan_hwaccel_do_receive(struct sk_buff **skbp)
 	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
-	rx_stats = this_cpu_ptr(vlan_dev_info(vlan_dev)->vlan_rx_stats);
+	rx_stats = this_cpu_ptr(vlan_dev_info(vlan_dev)->vlan_pcpu_stats);
 
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 14e3d1f..3a67483 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -141,7 +141,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
 	struct vlan_hdr *vhdr;
-	struct vlan_rx_stats *rx_stats;
+	struct vlan_pcpu_stats *rx_stats;
 	struct net_device *vlan_dev;
 	u16 vlan_id;
 	u16 vlan_tci;
@@ -177,7 +177,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	} else {
 		skb->dev = vlan_dev;
 
-		rx_stats = this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_rx_stats);
+		rx_stats = this_cpu_ptr(vlan_dev_info(skb->dev)->vlan_pcpu_stats);
 
 		u64_stats_update_begin(&rx_stats->syncp);
 		rx_stats->rx_packets++;
@@ -313,8 +313,6 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
 	unsigned int len;
 	int ret;
@@ -335,7 +333,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 		skb = __vlan_put_tag(skb, vlan_tci);
 		if (!skb) {
-			txq->tx_dropped++;
+			this_cpu_inc(vlan_dev_info(dev)->vlan_pcpu_stats->tx_dropped);
 			return NETDEV_TX_OK;
 		}
 
@@ -349,19 +347,22 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
-	} else
-		txq->tx_dropped++;
+		struct vlan_pcpu_stats *stats;
 
+		stats = this_cpu_ptr(vlan_dev_info(dev)->vlan_pcpu_stats);
+		u64_stats_update_begin(&stats->syncp);
+		stats->tx_packets++;
+		stats->tx_bytes += len;
+		u64_stats_update_begin(&stats->syncp);
+	} else {
+		this_cpu_inc(vlan_dev_info(dev)->vlan_pcpu_stats->tx_dropped);
+	}
 	return ret;
 }
 
 static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 						    struct net_device *dev)
 {
-	int i = skb_get_queue_mapping(skb);
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 	u16 vlan_tci;
 	unsigned int len;
 	int ret;
@@ -375,10 +376,16 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	ret = dev_queue_xmit(skb);
 
 	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
-		txq->tx_packets++;
-		txq->tx_bytes += len;
-	} else
-		txq->tx_dropped++;
+		struct vlan_pcpu_stats *stats;
+
+		stats = this_cpu_ptr(vlan_dev_info(dev)->vlan_pcpu_stats);
+		u64_stats_update_begin(&stats->syncp);
+		stats->tx_packets++;
+		stats->tx_bytes += len;
+		u64_stats_update_begin(&stats->syncp);
+	} else {
+		this_cpu_inc(vlan_dev_info(dev)->vlan_pcpu_stats->tx_dropped);
+	}
 
 	return ret;
 }
@@ -738,6 +745,7 @@ static int vlan_dev_init(struct net_device *dev)
 		      (1<<__LINK_STATE_PRESENT);
 
 	dev->features |= real_dev->features & real_dev->vlan_features;
+	dev->features |= NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
 
 	/* ipv6 shared card related stuff */
@@ -773,8 +781,8 @@ static int vlan_dev_init(struct net_device *dev)
 
 	vlan_dev_set_lockdep_class(dev, subclass);
 
-	vlan_dev_info(dev)->vlan_rx_stats = alloc_percpu(struct vlan_rx_stats);
-	if (!vlan_dev_info(dev)->vlan_rx_stats)
+	vlan_dev_info(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
+	if (!vlan_dev_info(dev)->vlan_pcpu_stats)
 		return -ENOMEM;
 
 	return 0;
@@ -786,8 +794,8 @@ static void vlan_dev_uninit(struct net_device *dev)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	int i;
 
-	free_percpu(vlan->vlan_rx_stats);
-	vlan->vlan_rx_stats = NULL;
+	free_percpu(vlan->vlan_pcpu_stats);
+	vlan->vlan_pcpu_stats = NULL;
 	for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
 		while ((pm = vlan->egress_priority_map[i]) != NULL) {
 			vlan->egress_priority_map[i] = pm->next;
@@ -825,33 +833,37 @@ static u32 vlan_ethtool_get_flags(struct net_device *dev)
 
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
-	dev_txq_stats_fold(dev, stats);
 
-	if (vlan_dev_info(dev)->vlan_rx_stats) {
-		struct vlan_rx_stats *p, accum = {0};
+	if (vlan_dev_info(dev)->vlan_pcpu_stats) {
+		struct vlan_pcpu_stats *p;
+		u32 rx_errors = 0, tx_dropped = 0;
 		int i;
 
 		for_each_possible_cpu(i) {
-			u64 rxpackets, rxbytes, rxmulticast;
+			u64 rxpackets, rxbytes, rxmulticast, txpackets, txbytes;
 			unsigned int start;
 
-			p = per_cpu_ptr(vlan_dev_info(dev)->vlan_rx_stats, i);
+			p = per_cpu_ptr(vlan_dev_info(dev)->vlan_pcpu_stats, i);
 			do {
 				start = u64_stats_fetch_begin_bh(&p->syncp);
 				rxpackets	= p->rx_packets;
 				rxbytes		= p->rx_bytes;
 				rxmulticast	= p->rx_multicast;
+				txpackets	= p->tx_packets;
+				txbytes		= p->tx_bytes;
 			} while (u64_stats_fetch_retry_bh(&p->syncp, start));
-			accum.rx_packets += rxpackets;
-			accum.rx_bytes   += rxbytes;
-			accum.rx_multicast += rxmulticast;
-			/* rx_errors is ulong, not protected by syncp */
-			accum.rx_errors  += p->rx_errors;
+
+			stats->rx_packets	+= rxpackets;
+			stats->rx_bytes		+= rxbytes;
+			stats->multicast	+= rxmulticast;
+			stats->tx_packets	+= txpackets;
+			stats->tx_bytes		+= txbytes;
+			/* rx_errors & tx_dropped are u32 */
+			rx_errors	+= p->rx_errors;
+			tx_dropped	+= p->tx_dropped;
 		}
-		stats->rx_packets = accum.rx_packets;
-		stats->rx_bytes   = accum.rx_bytes;
-		stats->rx_errors  = accum.rx_errors;
-		stats->multicast  = accum.rx_multicast;
+		stats->rx_errors  = rx_errors;
+		stats->tx_dropped = tx_dropped;
 	}
 	return stats;
 }
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index ddc1057..be9a5c1 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -101,25 +101,6 @@ static int vlan_changelink(struct net_device *dev,
 	return 0;
 }
 
-static int vlan_get_tx_queues(struct net *net,
-			      struct nlattr *tb[],
-			      unsigned int *num_tx_queues,
-			      unsigned int *real_num_tx_queues)
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
 static int vlan_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
@@ -237,7 +218,6 @@ struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.maxtype	= IFLA_VLAN_MAX,
 	.policy		= vlan_policy,
 	.priv_size	= sizeof(struct vlan_dev_info),
-	.get_tx_queues  = vlan_get_tx_queues,
 	.setup		= vlan_setup,
 	.validate	= vlan_validate,
 	.newlink	= vlan_newlink,


