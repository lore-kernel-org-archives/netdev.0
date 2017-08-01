From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Add support for 64-bit statistics
Date: Tue,  1 Aug 2017 15:00:36 -0700
Message-ID: <20170801220036.11355-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DSA slave network devices maintain a pair of bytes and packets counters
for each directions, but these are not 64-bit capable. Re-use
pcpu_sw_netstats which contains exactly what we need for that purpose
and update the code path to report 64-bit capable statistics.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      |  8 ++++++--
 net/dsa/dsa_priv.h |  2 ++
 net/dsa/slave.c    | 38 +++++++++++++++++++++++++++++++-------
 3 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index a55e2e4087a4..0ba842c08dd3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -190,6 +190,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 {
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct sk_buff *nskb = NULL;
+	struct dsa_slave_priv *p;
 
 	if (unlikely(dst == NULL)) {
 		kfree_skb(skb);
@@ -207,12 +208,15 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 
 	skb = nskb;
+	p = netdev_priv(skb->dev);
 	skb_push(skb, ETH_HLEN);
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
-	skb->dev->stats.rx_packets++;
-	skb->dev->stats.rx_bytes += skb->len;
+	u64_stats_update_begin(&p->stats64.syncp);
+	p->stats64.rx_packets++;
+	p->stats64.rx_bytes += skb->len;
+	u64_stats_update_end(&p->stats64.syncp);
 
 	netif_receive_skb(skb);
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 55982cc39b24..7aa0656296c2 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -77,6 +77,8 @@ struct dsa_slave_priv {
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
+	struct pcpu_sw_netstats	stats64;
+
 	/* DSA port data, such as switch, port index, etc. */
 	struct dsa_port		*dp;
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9507bd38cf04..65f3cef85976 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -354,8 +354,10 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct sk_buff *nskb;
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	u64_stats_update_begin(&p->stats64.syncp);
+	p->stats64.tx_packets++;
+	p->stats64.tx_bytes += skb->len;
+	u64_stats_update_end(&p->stats64.syncp);
 
 	/* Transmit function may have to reallocate the original SKB,
 	 * in which case it must have freed it. Only free it here on error.
@@ -594,11 +596,15 @@ static void dsa_slave_get_ethtool_stats(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
-
-	data[0] = dev->stats.tx_packets;
-	data[1] = dev->stats.tx_bytes;
-	data[2] = dev->stats.rx_packets;
-	data[3] = dev->stats.rx_bytes;
+	unsigned int start;
+
+	do {
+		start = u64_stats_fetch_begin_irq(&p->stats64.syncp);
+		data[0] = p->stats64.tx_packets;
+		data[1] = p->stats64.tx_bytes;
+		data[2] = p->stats64.rx_packets;
+		data[3] = p->stats64.rx_bytes;
+	} while (u64_stats_fetch_retry_irq(&p->stats64.syncp, start));
 	if (ds->ops->get_ethtool_stats)
 		ds->ops->get_ethtool_stats(ds, p->dp->index, data + 4);
 }
@@ -861,6 +867,22 @@ static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
 	}
 }
 
+static void dsa_slave_get_stats64(struct net_device *dev,
+				  struct rtnl_link_stats64 *stats)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	unsigned int start;
+
+	netdev_stats_to_stats64(stats, &dev->stats);
+	do {
+		start = u64_stats_fetch_begin_irq(&p->stats64.syncp);
+		stats->tx_packets = p->stats64.tx_packets;
+		stats->tx_bytes = p->stats64.tx_bytes;
+		stats->rx_packets = p->stats64.rx_packets;
+		stats->rx_bytes = p->stats64.rx_bytes;
+	} while (u64_stats_fetch_retry_irq(&p->stats64.syncp, start));
+}
+
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
 {
 	ops->get_sset_count = dsa_cpu_port_get_sset_count;
@@ -936,6 +958,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
 	.ndo_get_phys_port_name	= dsa_slave_get_phys_port_name,
 	.ndo_setup_tc		= dsa_slave_setup_tc,
+	.ndo_get_stats64	= dsa_slave_get_stats64,
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
@@ -1171,6 +1194,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
+	u64_stats_init(&p->stats64.syncp);
 	p->dp = &ds->ports[port];
 	INIT_LIST_HEAD(&p->mall_tc_list);
 	p->xmit = dst->tag_ops->xmit;
-- 
2.9.3
