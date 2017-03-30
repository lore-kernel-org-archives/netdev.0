From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v6 PATCH 6/7] i40e: Add support for exposing switch port statistics via port netdevs
Date: Wed, 29 Mar 2017 17:22:54 -0700
Message-ID: <1490833375-2788-7-git-send-email-sridhar.samudrala@intel.com>
References: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
To: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, anjali.singhai@intel.com,
        jakub.kicinski@netronome.com, gerlitz.or@gmail.com,
        jiri@resnulli.us, sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:37844 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933112AbdC3AXA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:23:00 -0400
In-Reply-To: <1490833375-2788-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default stats counted by HW are returned via the original
ndo_get_stats64() api. Stats counted in SW are returned via
ndo_get_offload_stats() api.

Small script to demonstrate port stats in switchdev mode.
PF: p4p1, VFs: p4p1_0,p4p1_1 VF Port Reps:p4p1-vf0, p4p1-vf1
PF Port rep: p4p1-pf

# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip link set p4p1 vf 0 mac 00:11:22:33:44:55
# ip link set p4p1 vf 1 mac 00:11:22:33:44:56
# rmmod i40evf; modprobe i40evf

/* Create 2 namespaces and move the VFs to the corresponding ns */
# ip netns add ns0
# ip link set p4p1_0 netns ns0
# ip netns exec ns0 ip addr add 192.168.1.10/24 dev p4p1_0
# ip netns exec ns0 ip link set p4p1_0 up
# ip netns add ns1
# ip link set p4p1_1 netns ns1
# ip netns exec ns1 ip addr add 192.168.1.11/24 dev p4p1_1
# ip netns exec ns1 ip link set p4p1_1 up

/* bring up pf and port netdevs */
# ip addr add 192.168.1.1/24 dev p4p1
# ip link set p4p1 up
# ip link set p4p1-vf0 up
# ip link set p4p1-vf1 up
# ip link set p4p1-pf up

# ip netns exec ns0 ping -c3 192.168.1.11  /* VF0 -> VF1 */
# ip netns exec ns1 ping -c3 192.168.1.10  /* VF1 -> VF0 */
# ping -c3 192.168.1.10   /* PF -> VF0 */
# ping -c3 192.168.1.11   /* PF -> VF1 */

/* VF0 -> IP in same subnet - broadcasts will be seen on p4p1-vf0 */
# ip netns exec ns0 ping -c1 -W1 192.168.1.200
/* VF1 -> IP in same subnet-  broadcasts will be seen on p4p1-vf1 */
# ip netns exec ns0 ping -c1 -W1 192.168.1.200
/* port rep VF0 -> IP in same subnet - broadcasts will be seen on p4p1_0 */
# ping -I p4p1-vf0 -c1 -W1 192.168.1.200
/* port rep VF1 -> IP in same subnet  - broadcasts will be seen on p4p1_1 */
# ping -I p4p1-vf1 -c1 -W1 192.168.1.200

HW STATS
# ip netns exec ns0 ip -s l show p4p1_0
41: p4p1_0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1274       21       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    980        14       0       0       0       0
# ip -s l show p4p1-vf0
37: p4p1-vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether f6:07:98:0e:cd:97 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    980        14       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1274       21       0       0       0       0
# ip netns exec ns1 ip -s l show p4p1_1
42: p4p1_1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 00:11:22:33:44:56 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1246       19       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1078       15       0       0       0       0
# ip -s l show p4p1-vf1
38: p4p1-vf1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether 2a:cf:ff:6a:f3:66 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1078       15       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1246       19       0       0       0       0
# ip -s l show p4p1
34: p4p1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT qlen 1000
    link/ether 3c:fd:fe:a3:18:f8 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1134       17       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    966        19       0       0       0       0
# ip -s l show p4p1-pf
36: p4p1-pf: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT qlen 1000
    link/ether da:0f:67:fe:2e:66 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    966        19       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    882        17       0       0       0       0

SW STATS
# ifstat -a -x c
#kernel
Interface        RX Pkts/Rate    TX Pkts/Rate    RX Data/Rate    TX Data/Rate
                 RX Errs/Drop    TX Errs/Drop    RX Over/Rate    TX Coll/Rate
p4p1-pf                0 0             3 0             0 0           126 0
                       0 0             0 0             0 0             0 0
p4p1-vf0               4 0             6 0           184 0           252 0
                       0 0             0 0             0 0             0 0
p4p1-vf1               3 0             3 0           138 0           126 0
                       0 0             0 0             0 0             0 0

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  10 +++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 125 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |  24 +++++-
 3 files changed, 158 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ac11005..72e11b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -328,8 +328,18 @@ enum i40e_port_netdev_type {
 	I40E_PORT_NETDEV_VF
 };
 
+struct port_netdev_pcpu_stats {
+	u64			tx_packets;
+	u64			tx_bytes;
+	u64			tx_drops;
+	u64			rx_packets;
+	u64			rx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
 /* Port representor netdev private structure */
 struct i40e_port_netdev_priv {
+	struct port_netdev_pcpu_stats __percpu *stats;
 	enum i40e_port_netdev_type type;	/* type - PF or VF */
 	struct metadata_dst *dst;		/* port id */
 	void *f;				/* ptr to PF or VF struct */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e9c5c6b..4f0eebc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11001,10 +11001,123 @@ static int i40e_port_netdev_stop(struct net_device *dev)
 	return err;
 }
 
+/**
+ * i40e_port_netdev_get_stats64
+ * @dev: network interface device structure
+ * @stats: netlink stats structure
+ *
+ * Fills the hw statistics from the VSI corresponding to the associated port
+ * netdev
+ **/
+static void
+i40e_port_netdev_get_stats64(struct net_device *netdev,
+			     struct rtnl_link_stats64 *stats)
+{
+	struct i40e_port_netdev_priv *priv = netdev_priv(netdev);
+	struct i40e_vf *vf;
+	struct i40e_pf *pf;
+	struct i40e_vsi *vsi;
+	struct i40e_eth_stats *estats;
+
+	switch (priv->type) {
+	case I40E_PORT_NETDEV_VF:
+		vf = (struct i40e_vf *)priv->f;
+		pf = vf->pf;
+		vsi = pf->vsi[vf->lan_vsi_idx];
+		break;
+	case I40E_PORT_NETDEV_PF:
+		pf = (struct i40e_pf *)priv->f;
+		vsi = pf->vsi[pf->lan_vsi];
+		break;
+	default:
+		return;
+	}
+
+	i40e_update_stats(vsi);
+	estats = &vsi->eth_stats;
+
+	/* TX and RX stats are flipped as we are returning the stats as seen
+	 * at the switch port corresponding to the VF.
+	 */
+	stats->rx_packets = estats->tx_unicast + estats->tx_multicast +
+			    estats->tx_broadcast;
+	stats->tx_packets = estats->rx_unicast + estats->rx_multicast +
+			    estats->rx_broadcast;
+	stats->rx_bytes = estats->tx_bytes;
+	stats->tx_bytes = estats->rx_bytes;
+	stats->rx_dropped = estats->tx_discards;
+	stats->tx_dropped = estats->rx_discards;
+}
+
+/**
+ * i40e_port_netdev_get_cpu_hit_stats64
+ * @dev: network interface device structure
+ * @stats: netlink stats structure
+ *
+ * stats are filled from the priv structure. correspond to the packets
+ * that are seen by the cpu and sent/received via port netdev.
+ **/
+static int
+i40e_port_netdev_get_cpu_hit_stats64(const struct net_device *dev,
+				     struct rtnl_link_stats64 *stats)
+{
+	struct i40e_port_netdev_priv *priv = netdev_priv(dev);
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct port_netdev_pcpu_stats *port_netdev_stats;
+		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
+		unsigned int start;
+
+		port_netdev_stats = per_cpu_ptr(priv->stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&port_netdev_stats->syncp);
+			tbytes = port_netdev_stats->tx_bytes;
+			tpkts = port_netdev_stats->tx_packets;
+			tdrops = port_netdev_stats->tx_drops;
+			rbytes = port_netdev_stats->rx_bytes;
+			rpkts = port_netdev_stats->rx_packets;
+		} while (u64_stats_fetch_retry_irq(&port_netdev_stats->syncp, start));
+		stats->tx_bytes += tbytes;
+		stats->tx_packets += tpkts;
+		stats->tx_dropped += tdrops;
+		stats->rx_bytes += rbytes;
+		stats->rx_packets += rpkts;
+	}
+
+	return 0;
+}
+
+static bool
+i40e_port_netdev_has_offload_stats(const struct net_device *dev, int attr_id)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return true;
+	}
+
+	return false;
+}
+
+static int
+i40e_port_netdev_get_offload_stats(int attr_id, const struct net_device *dev,
+				   void *sp)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return i40e_port_netdev_get_cpu_hit_stats64(dev, sp);
+	}
+
+	return -EINVAL;
+}
+
 static const struct net_device_ops i40e_port_netdev_ops = {
 	.ndo_open		= i40e_port_netdev_open,
 	.ndo_stop		= i40e_port_netdev_stop,
 	.ndo_start_xmit		= i40e_port_netdev_start_xmit,
+	.ndo_get_stats64	= i40e_port_netdev_get_stats64,
+	.ndo_has_offload_stats	= i40e_port_netdev_has_offload_stats,
+	.ndo_get_offload_stats	= i40e_port_netdev_get_offload_stats,
 };
 
 /**
@@ -11077,6 +11190,16 @@ int i40e_alloc_port_netdev(void *f, enum i40e_port_netdev_type type)
 		return -EINVAL;
 	}
 
+	priv->stats = netdev_alloc_pcpu_stats(struct port_netdev_pcpu_stats);
+	if (!priv->stats) {
+		dev_err(&pf->pdev->dev,
+			"alloc_pcpu_stats failed for port netdev: %s\n",
+			port_netdev->name);
+		dst_release((struct dst_entry *)priv->dst);
+		free_netdev(port_netdev);
+		return -ENOMEM;
+	}
+
 	port_netdev->netdev_ops = &i40e_port_netdev_ops;
 	eth_hw_addr_random(port_netdev);
 
@@ -11144,6 +11267,7 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 			 pf->port_netdev->name);
 		priv = netdev_priv(pf->port_netdev);
 		dst_release((struct dst_entry *)priv->dst);
+		free_percpu(priv->stats);
 		unregister_netdev(pf->port_netdev);
 		free_netdev(pf->port_netdev);
 		pf->port_netdev = NULL;
@@ -11163,6 +11287,7 @@ void i40e_free_port_netdev(void *f, enum i40e_port_netdev_type type)
 			 vf->port_netdev->name);
 		priv = netdev_priv(vf->port_netdev);
 		dst_release((struct dst_entry *)priv->dst);
+		free_percpu(priv->stats);
 		unregister_netdev(vf->port_netdev);
 		free_netdev(vf->port_netdev);
 		vf->port_netdev = NULL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 86d2510..449a35c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1309,7 +1309,9 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 static void i40e_handle_lpbk_skb(struct i40e_ring *rx_ring, struct sk_buff *skb)
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
+	struct port_netdev_pcpu_stats *port_netdev_stats;
 	struct i40e_pf *pf = rx_ring->vsi->back;
+	struct i40e_port_netdev_priv *priv;
 	struct sk_buff *nskb;
 	struct i40e_vf *vf;
 	struct ethhdr *eth;
@@ -1334,6 +1336,12 @@ static void i40e_handle_lpbk_skb(struct i40e_ring *rx_ring, struct sk_buff *skb)
 				break;
 			nskb->offload_fwd_mark = 1;
 			nskb->dev = vf->port_netdev;
+			priv = netdev_priv(vf->port_netdev);
+			port_netdev_stats = this_cpu_ptr(priv->stats);
+			u64_stats_update_begin(&port_netdev_stats->syncp);
+			port_netdev_stats->rx_packets++;
+			port_netdev_stats->rx_bytes += nskb->len;
+			u64_stats_update_end(&port_netdev_stats->syncp);
 			napi_gro_receive(&q_vector->napi, nskb);
 			break;
 		}
@@ -3283,6 +3291,7 @@ netdev_tx_t i40e_port_netdev_start_xmit(struct sk_buff *skb,
 	struct i40e_vsi *vsi;
 	struct i40e_pf *pf;
 	struct i40e_vf *vf;
+	int ret;
 
 	switch (priv->type) {
 	case I40E_PORT_NETDEV_VF:
@@ -3302,5 +3311,18 @@ netdev_tx_t i40e_port_netdev_start_xmit(struct sk_buff *skb,
 	skb_dst_set(skb, &priv->dst->dst);
 	skb->dev = vsi->netdev;
 
-	return dev_queue_xmit(skb);
+	ret = dev_queue_xmit(skb);
+	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
+		struct port_netdev_pcpu_stats *port_netdev_stats;
+
+		port_netdev_stats = this_cpu_ptr(priv->stats);
+		u64_stats_update_begin(&port_netdev_stats->syncp);
+		port_netdev_stats->tx_packets++;
+		port_netdev_stats->tx_bytes += skb->len;
+		u64_stats_update_end(&port_netdev_stats->syncp);
+	} else {
+		this_cpu_inc(priv->stats->tx_drops);
+	}
+
+	return ret;
 }
-- 
1.8.3.1
