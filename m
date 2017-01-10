From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [next-queue v3 PATCH 6/7] i40e: Add support for exposing VF port statistics via VFPR netdev on the host.
Date: Mon,  9 Jan 2017 16:59:49 -0800
Message-ID: <1484009990-3018-7-git-send-email-sridhar.samudrala@intel.com>
References: <1484009990-3018-1-git-send-email-sridhar.samudrala@intel.com>
To: alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, scott.d.peterson@intel.com,
        gerlitz.or@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:18951 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755084AbdAJA74 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 19:59:56 -0500
In-Reply-To: <1484009990-3018-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sridhar.samudrala@intel.com>

By default stats counted by HW are returned via the original ndo_get_stats64()
api. Stats counted in SW are returned via ndo_get_offload_stats() api.

Small script to demonstrate vfpr stats in switchdev mode.
PF: enp5s0f0, VFs: enp5s2,enp5s2f1 VFPRs:enp5s0f0-vf0, enp5s0f0-vf1

# rmmod i40e; modprobe i40e
# devlink dev eswitch set pci/0000:05:00.0 mode switchdev
# echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
# ip link set enp5s0f0 vf 0 mac 00:11:22:33:44:55
# ip link set enp5s0f0 vf 1 mac 00:11:22:33:44:56
# rmmod i40evf; modprobe i40evf

/* Create 2 namespaces and move the VFs to the corresponding ns */
# ip netns add ns0
# ip link set enp5s2 netns ns0
# ip netns exec ns0 ip addr add 192.168.1.10/24 dev enp5s2
# ip netns exec ns0 ip link set enp5s2 up
# ip netns add ns1
# ip link set enp5s2f1 netns ns1
# ip netns exec ns1 ip addr add 192.168.1.11/24 dev enp5s2f1
# ip netns exec ns1 ip link set enp5s2f1 up

/* bring up pf and vfpr netdevs */
# ip link set enp5s0f0 up
# ip link set enp5s0f0-vf0 up
# ip link set enp5s0f0-vf1 up

/* Create a linux bridge and add vfpr netdevs to it. */
# ip link add vfpr-br type bridge
# ip link set enp5s0f0-vf0 master vfpr-br
# ip link set enp5s0f0-vf1 master vfpr-br
# ip addr add 192.168.1.1/24 dev vfpr-br
# ip link set vfpr-br up

# ip netns exec ns0 ping -c3 192.168.1.11
# ip netns exec ns1 ping -c3 192.168.1.10

# ip netns exec ns0 ip -s l show enp5s2
56: enp5s2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1468       18       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1398       17       0       0       0       0
# ip -s l show enp5s0f0-vf0
52: enp5s0f0-vf0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vfpr-br state UP mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1398       17       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1468       18       0       0       0       0
# ip netns exec ns1 ip -s l show enp5s2f1
57: enp5s2f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 00:11:22:33:44:56 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1486       18       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1538       19       0       0       0       0
# ip -s l show enp5s0f0-vf1
53: enp5s0f0-vf1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel master vfpr-br state UP mode DEFAULT group default qlen 1000
    link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1538       19       0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1486       18       0       0       0       0

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  44 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 110 +++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |  10 ++
 3 files changed, 162 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f43d1df..d1583ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1279,6 +1279,32 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 }
 
 /**
+ * i40e_vfpr_receive_skb
+ * @vf: pointer to VF
+ * @skb: packet to send up
+ *
+ * Update skb dev to vfpr netdev and rx stats.
+ **/
+static void i40e_vfpr_receive_skb(struct i40e_vf *vf, struct sk_buff *skb)
+{
+	struct i40e_vfpr_netdev_priv *priv;
+	struct vfpr_pcpu_stats *vfpr_stats;
+
+	if (!vf->vfpr_netdev)
+		return;
+
+	skb->dev = vf->vfpr_netdev;
+
+	priv = netdev_priv(vf->vfpr_netdev);
+	vfpr_stats = this_cpu_ptr(priv->vfpr_stats);
+
+	u64_stats_update_begin(&vfpr_stats->syncp);
+	vfpr_stats->rx_packets++;
+	vfpr_stats->rx_bytes += skb->len;
+	u64_stats_update_end(&vfpr_stats->syncp);
+}
+
+/**
  * i40e_receive_skb - Send a completed packet up the stack
  * @rx_ring:  rx ring in play
  * @skb: packet to send up
@@ -1310,7 +1336,7 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
 		vf = &pf->vf[vf_id];
 		if (ether_addr_equal(eth->h_source,
 				     vf->default_lan_addr.addr)) {
-			skb->dev = vf->vfpr_netdev;
+			i40e_vfpr_receive_skb(vf, skb);
 			break;
 		}
 	}
@@ -3428,11 +3454,25 @@ netdev_tx_t i40e_vfpr_netdev_start_xmit(struct sk_buff *skb,
 	struct i40e_vf *vf = priv->vf;
 	struct i40e_pf *pf = vf->pf;
 	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	int ret;
 
 	skb_dst_drop(skb);
 	dst_hold(&priv->vfpr_dst->dst);
 	skb_dst_set(skb, &priv->vfpr_dst->dst);
 	skb->dev = vsi->netdev;
 
-	return dev_queue_xmit(skb);
+	ret = dev_queue_xmit(skb);
+	if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
+		struct vfpr_pcpu_stats *vfpr_stats;
+
+		vfpr_stats = this_cpu_ptr(priv->vfpr_stats);
+		u64_stats_update_begin(&vfpr_stats->syncp);
+		vfpr_stats->tx_packets++;
+		vfpr_stats->tx_bytes += skb->len;
+		u64_stats_update_end(&vfpr_stats->syncp);
+	} else {
+		this_cpu_inc(priv->vfpr_stats->tx_drops);
+	}
+
+	return ret;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 7211fba..5915280 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1057,10 +1057,112 @@ static int i40e_vfpr_netdev_stop(struct net_device *dev)
 	return 0;
 }
 
+/**
+ * i40e_vfpr_netdev_get_stats64
+ * @dev: network interface device structure
+ * @stats: netlink stats structure
+ *
+ * Returns the hw statistics from the VSI corresponding to the associated VFPR
+ **/
+static struct rtnl_link_stats64 *
+i40e_vfpr_netdev_get_stats64(struct net_device *netdev,
+			     struct rtnl_link_stats64 *stats)
+{
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(netdev);
+	struct i40e_vf *vf = priv->vf;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi;
+	struct i40e_eth_stats *estats;
+
+	vsi = pf->vsi[vf->lan_vsi_idx];
+	i40e_update_stats(vsi);
+
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
+
+	return stats;
+}
+
+/**
+ * i40e_vfpr_get_cpu_hit_stats64
+ * @dev: network interface device structure
+ * @stats: netlink stats structure
+ *
+ * stats are filled from the priv structure. correspond to the packets
+ * that are seen by the cpu and sent/received via vfpr netdev.
+ **/
+static int
+i40e_vfpr_get_cpu_hit_stats64(const struct net_device *dev,
+			      struct rtnl_link_stats64 *stats)
+{
+	struct i40e_vfpr_netdev_priv *priv = netdev_priv(dev);
+	int i;
+
+	for_each_possible_cpu(i) {
+		struct vfpr_pcpu_stats *vfpr_stats;
+		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
+		unsigned int start;
+
+		vfpr_stats = per_cpu_ptr(priv->vfpr_stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&vfpr_stats->syncp);
+			tbytes = vfpr_stats->tx_bytes;
+			tpkts = vfpr_stats->tx_packets;
+			tdrops = vfpr_stats->tx_drops;
+			rbytes = vfpr_stats->rx_bytes;
+			rpkts = vfpr_stats->rx_packets;
+		} while (u64_stats_fetch_retry_irq(&vfpr_stats->syncp, start));
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
+i40e_vfpr_netdev_has_offload_stats(const struct net_device *dev, int attr_id)
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
+i40e_vfpr_netdev_get_offload_stats(int attr_id, const struct net_device *dev,
+				   void *sp)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return i40e_vfpr_get_cpu_hit_stats64(dev, sp);
+	}
+
+	return -EINVAL;
+}
+
 static const struct net_device_ops i40e_vfpr_netdev_ops = {
 	.ndo_open		= i40e_vfpr_netdev_open,
 	.ndo_stop		= i40e_vfpr_netdev_stop,
 	.ndo_start_xmit         = i40e_vfpr_netdev_start_xmit,
+	.ndo_get_stats64        = i40e_vfpr_netdev_get_stats64,
+	.ndo_has_offload_stats  = i40e_vfpr_netdev_has_offload_stats,
+	.ndo_get_offload_stats  = i40e_vfpr_netdev_get_offload_stats,
 };
 
 /**
@@ -1119,6 +1221,13 @@ int i40e_alloc_vfpr_netdev(struct i40e_vf *vf, u16 vf_num)
 	pf->vf[vf_num].vfpr_netdev = vfpr_netdev;
 
 	priv = netdev_priv(vfpr_netdev);
+	priv->vfpr_stats = netdev_alloc_pcpu_stats(struct vfpr_pcpu_stats);
+	if (!priv->vfpr_stats) {
+		dev_err(&pf->pdev->dev, "alloc_pcpu_stats failed for vf:%d\n",
+			vf_num);
+		free_netdev(vfpr_netdev);
+		return -ENOMEM;
+	}
 	priv->vf = &pf->vf[vf_num];
 	priv->vfpr_dst = metadata_dst_alloc(0, METADATA_HW_PORT_MUX,
 					    GFP_KERNEL);
@@ -1175,6 +1284,7 @@ void i40e_free_vfpr_netdev(struct i40e_vf *vf)
 
 	priv = netdev_priv(vf->vfpr_netdev);
 	dst_release((struct dst_entry *)priv->vfpr_dst);
+	free_percpu(priv->vfpr_stats);
 	unregister_netdev(vf->vfpr_netdev);
 	free_netdev(vf->vfpr_netdev);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
index 3dea207..52ba9d5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h
@@ -72,10 +72,20 @@ enum i40e_vf_capabilities {
 	I40E_VIRTCHNL_VF_CAP_IWARP,
 };
 
+struct vfpr_pcpu_stats {
+	u64                     tx_packets;
+	u64                     tx_bytes;
+	u64                     tx_drops;
+	u64                     rx_packets;
+	u64                     rx_bytes;
+	struct u64_stats_sync   syncp;
+};
+
 /* VF Port representator netdev private structure */
 struct i40e_vfpr_netdev_priv {
 	struct metadata_dst *vfpr_dst;
 	struct i40e_vf *vf;
+	struct vfpr_pcpu_stats *vfpr_stats;
 };
 
 /* VF information structure */
-- 
2.5.5
