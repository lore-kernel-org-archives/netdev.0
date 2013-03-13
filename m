From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/6] VXLAN: Fix vxlan stats handling.
Date: Wed, 13 Mar 2013 15:48:43 -0700
Message-ID: <1363214923-3353-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:36302 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934342Ab3CMWtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:49:22 -0400
Received: by mail-pb0-f72.google.com with SMTP id wz12so2786851pbc.7
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:49:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes bug in VXLAN code where is iptunnel_xmit() called with NULL
dev->tstats.
This bug was introduced in commit 6aed0c8bf7d2f389b (tunnel: use
iptunnel_xmit() again).

Following patch fixes bug by setting dev->tstats. It uses ip_tunnel
module code to share stats function.

CC: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   72 +++++----------------------------------------------
 1 files changed, 7 insertions(+), 65 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 338d44e..d844168 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -92,20 +92,10 @@ struct vxlan_fdb {
 	u8		  eth_addr[ETH_ALEN];
 };
 
-/* Per-cpu network traffic stats */
-struct vxlan_stats {
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			tx_packets;
-	u64			tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 /* Pseudo network device */
 struct vxlan_dev {
 	struct hlist_node hlist;
 	struct net_device *dev;
-	struct vxlan_stats __percpu *stats;
 	__u32		  vni;		/* virtual network id */
 	__be32	          gaddr;	/* multicast group */
 	__be32		  saddr;	/* source address */
@@ -556,7 +546,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	struct iphdr *oip;
 	struct vxlanhdr *vxh;
 	struct vxlan_dev *vxlan;
-	struct vxlan_stats *stats;
+	struct pcpu_tstats *stats;
 	__u32 vni;
 	int err;
 
@@ -632,7 +622,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	stats = this_cpu_ptr(vxlan->stats);
+	stats = this_cpu_ptr(vxlan->dev->tstats);
 	u64_stats_update_begin(&stats->syncp);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
@@ -884,8 +874,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 			/* short-circuited back to local bridge */
 			if (netif_rx(skb) == NET_RX_SUCCESS) {
-				struct vxlan_stats *stats =
-						this_cpu_ptr(vxlan->stats);
+				struct pcpu_tstats *stats = this_cpu_ptr(dev->tstats);
 
 				u64_stats_update_begin(&stats->syncp);
 				stats->tx_packets++;
@@ -1035,10 +1024,8 @@ static void vxlan_cleanup(unsigned long arg)
 /* Setup stats when device is created */
 static int vxlan_init(struct net_device *dev)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-
-	vxlan->stats = alloc_percpu(struct vxlan_stats);
-	if (!vxlan->stats)
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
 		return -ENOMEM;
 
 	return 0;
@@ -1094,49 +1081,6 @@ static int vxlan_stop(struct net_device *dev)
 	return 0;
 }
 
-/* Merge per-cpu statistics */
-static struct rtnl_link_stats64 *vxlan_stats64(struct net_device *dev,
-					       struct rtnl_link_stats64 *stats)
-{
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_stats tmp, sum = { 0 };
-	unsigned int cpu;
-
-	for_each_possible_cpu(cpu) {
-		unsigned int start;
-		const struct vxlan_stats *stats
-			= per_cpu_ptr(vxlan->stats, cpu);
-
-		do {
-			start = u64_stats_fetch_begin_bh(&stats->syncp);
-			memcpy(&tmp, stats, sizeof(tmp));
-		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
-
-		sum.tx_bytes   += tmp.tx_bytes;
-		sum.tx_packets += tmp.tx_packets;
-		sum.rx_bytes   += tmp.rx_bytes;
-		sum.rx_packets += tmp.rx_packets;
-	}
-
-	stats->tx_bytes   = sum.tx_bytes;
-	stats->tx_packets = sum.tx_packets;
-	stats->rx_bytes   = sum.rx_bytes;
-	stats->rx_packets = sum.rx_packets;
-
-	stats->multicast = dev->stats.multicast;
-	stats->rx_length_errors = dev->stats.rx_length_errors;
-	stats->rx_frame_errors = dev->stats.rx_frame_errors;
-	stats->rx_errors = dev->stats.rx_errors;
-
-	stats->tx_dropped = dev->stats.tx_dropped;
-	stats->tx_carrier_errors  = dev->stats.tx_carrier_errors;
-	stats->tx_aborted_errors  = dev->stats.tx_aborted_errors;
-	stats->collisions  = dev->stats.collisions;
-	stats->tx_errors = dev->stats.tx_errors;
-
-	return stats;
-}
-
 /* Stub, nothing needs to be done. */
 static void vxlan_set_multicast_list(struct net_device *dev)
 {
@@ -1147,7 +1091,7 @@ static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_open		= vxlan_open,
 	.ndo_stop		= vxlan_stop,
 	.ndo_start_xmit		= vxlan_xmit,
-	.ndo_get_stats64	= vxlan_stats64,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
 	.ndo_set_rx_mode	= vxlan_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1164,9 +1108,7 @@ static struct device_type vxlan_type = {
 
 static void vxlan_free(struct net_device *dev)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-
-	free_percpu(vxlan->stats);
+	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
 
-- 
1.7.1
