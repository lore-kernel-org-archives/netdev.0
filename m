From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: User per-cpu 64-bit statistics
Date: Thu,  3 Aug 2017 21:33:27 -0700
Message-ID: <20170804043328.4730-1-f.fainelli@gmail.com>
Cc: davem@davemlot.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During testing with a background iperf pushing 1Gbit/sec worth of
traffic and having both ifconfig and ethtool collect statistics, we
could see quite frequent deadlocks. Convert the often accessed DSA slave
network devices statistics to per-cpu 64-bit statistics to remove these
deadlocks and provide fast efficient statistics updates.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 10 +++++---
 net/dsa/dsa_priv.h |  2 +-
 net/dsa/slave.c    | 72 +++++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 59 insertions(+), 25 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 0ba842c08dd3..a91e520e735f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -190,6 +190,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct sk_buff *nskb = NULL;
+	struct pcpu_sw_netstats *s;
 	struct dsa_slave_priv *p;
 
 	if (unlikely(dst == NULL)) {
@@ -213,10 +214,11 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	u64_stats_update_begin(&p->stats64.syncp);
-	p->stats64.rx_packets++;
-	p->stats64.rx_bytes += skb->len;
-	u64_stats_update_end(&p->stats64.syncp);
+	s = this_cpu_ptr(p->stats64);
+	u64_stats_update_begin(&s->syncp);
+	s->rx_packets++;
+	s->rx_bytes += skb->len;
+	u64_stats_update_end(&s->syncp);
 
 	netif_receive_skb(skb);
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 7aa0656296c2..306cff229def 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -77,7 +77,7 @@ struct dsa_slave_priv {
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
-	struct pcpu_sw_netstats	stats64;
+	struct pcpu_sw_netstats	*stats64;
 
 	/* DSA port data, such as switch, port index, etc. */
 	struct dsa_port		*dp;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e196562035b1..605444ced06c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -352,12 +352,14 @@ static inline netdev_tx_t dsa_netpoll_send_skb(struct dsa_slave_priv *p,
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct pcpu_sw_netstats *s;
 	struct sk_buff *nskb;
 
-	u64_stats_update_begin(&p->stats64.syncp);
-	p->stats64.tx_packets++;
-	p->stats64.tx_bytes += skb->len;
-	u64_stats_update_end(&p->stats64.syncp);
+	s = this_cpu_ptr(p->stats64);
+	u64_stats_update_begin(&s->syncp);
+	s->tx_packets++;
+	s->tx_bytes += skb->len;
+	u64_stats_update_end(&s->syncp);
 
 	/* Transmit function may have to reallocate the original SKB,
 	 * in which case it must have freed it. Only free it here on error.
@@ -596,15 +598,26 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
+	struct pcpu_sw_netstats *s;
 	unsigned int start;
-
-	do {
-		start = u64_stats_fetch_begin_irq(&p->stats64.syncp);
-		data[0] = p->stats64.tx_packets;
-		data[1] = p->stats64.tx_bytes;
-		data[2] = p->stats64.rx_packets;
-		data[3] = p->stats64.rx_bytes;
-	} while (u64_stats_fetch_retry_irq(&p->stats64.syncp, start));
+	int i;
+
+	for_each_possible_cpu(i) {
+		u64 tx_packets, tx_bytes, rx_packets, rx_bytes;
+
+		s = per_cpu_ptr(p->stats64, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&s->syncp);
+			tx_packets = s->tx_packets;
+			tx_bytes = s->tx_bytes;
+			rx_packets = s->rx_packets;
+			rx_bytes = s->rx_bytes;
+		} while (u64_stats_fetch_retry_irq(&s->syncp, start));
+		data[0] += tx_packets;
+		data[1] += tx_bytes;
+		data[2] += rx_packets;
+		data[3] += rx_bytes;
+	}
 	if (ds->ops->get_ethtool_stats)
 		ds->ops->get_ethtool_stats(ds, p->dp->index, data + 4);
 }
@@ -879,16 +892,28 @@ static void dsa_slave_get_stats64(struct net_device *dev,
 				  struct rtnl_link_stats64 *stats)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct pcpu_sw_netstats *s;
 	unsigned int start;
+	int i;
 
 	netdev_stats_to_stats64(stats, &dev->stats);
-	do {
-		start = u64_stats_fetch_begin_irq(&p->stats64.syncp);
-		stats->tx_packets = p->stats64.tx_packets;
-		stats->tx_bytes = p->stats64.tx_bytes;
-		stats->rx_packets = p->stats64.rx_packets;
-		stats->rx_bytes = p->stats64.rx_bytes;
-	} while (u64_stats_fetch_retry_irq(&p->stats64.syncp, start));
+	for_each_possible_cpu(i) {
+		u64 tx_packets, tx_bytes, rx_packets, rx_bytes;
+
+		s = per_cpu_ptr(p->stats64, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&s->syncp);
+			tx_packets = s->tx_packets;
+			tx_bytes = s->tx_bytes;
+			rx_packets = s->rx_packets;
+			rx_bytes = s->rx_bytes;
+		} while (u64_stats_fetch_retry_irq(&s->syncp, start));
+
+		stats->tx_packets += tx_packets;
+		stats->tx_bytes += tx_bytes;
+		stats->rx_packets += rx_packets;
+		stats->rx_bytes += rx_bytes;
+	}
 }
 
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
@@ -1202,7 +1227,11 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-	u64_stats_init(&p->stats64.syncp);
+	p->stats64 = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
+	if (!p->stats64) {
+		free_netdev(slave_dev);
+		return -ENOMEM;
+	}
 	p->dp = &ds->ports[port];
 	INIT_LIST_HEAD(&p->mall_tc_list);
 	p->xmit = dst->tag_ops->xmit;
@@ -1217,6 +1246,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		netdev_err(master, "error %d registering interface %s\n",
 			   ret, slave_dev->name);
 		ds->ports[port].netdev = NULL;
+		free_percpu(p->stats64);
 		free_netdev(slave_dev);
 		return ret;
 	}
@@ -1227,6 +1257,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (ret) {
 		netdev_err(master, "error %d setting up slave phy\n", ret);
 		unregister_netdev(slave_dev);
+		free_percpu(p->stats64);
 		free_netdev(slave_dev);
 		return ret;
 	}
@@ -1249,6 +1280,7 @@ void dsa_slave_destroy(struct net_device *slave_dev)
 			of_phy_deregister_fixed_link(port_dn);
 	}
 	unregister_netdev(slave_dev);
+	free_percpu(p->stats64);
 	free_netdev(slave_dev);
 }
 
-- 
2.9.3
