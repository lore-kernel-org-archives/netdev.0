From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/4] openvswitch: Remove vport stats.
Date: Sat, 29 Aug 2015 17:44:07 -0700
Message-ID: <1440895448-16363-4-git-send-email-pshelar@nicira.com>
References: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35025 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbbH3AoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 20:44:19 -0400
Received: by pacdd16 with SMTP id dd16so99798115pac.2
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 17:44:18 -0700 (PDT)
In-Reply-To: <1440895448-16363-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since all vport types are now backed by netdev, we can directly
use netdev stats. Following patch removes redundant stat
from vport.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-internal_dev.c |   57 ++++++++----------
 net/openvswitch/vport-netdev.c       |   22 +++----
 net/openvswitch/vport-netdev.h       |    2 +-
 net/openvswitch/vport.c              |  109 ++++------------------------------
 net/openvswitch/vport.h              |   36 +++--------
 5 files changed, 56 insertions(+), 170 deletions(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 80b3e12..388b8a6 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -43,35 +43,26 @@ static struct internal_dev *internal_dev_priv(struct net_device *netdev)
 	return netdev_priv(netdev);
 }
 
-/* This function is only called by the kernel network layer.*/
-static struct rtnl_link_stats64 *internal_dev_get_stats(struct net_device *netdev,
-							struct rtnl_link_stats64 *stats)
-{
-	struct vport *vport = ovs_internal_dev_get_vport(netdev);
-	struct ovs_vport_stats vport_stats;
-
-	ovs_vport_get_stats(vport, &vport_stats);
-
-	/* The tx and rx stats need to be swapped because the
-	 * switch and host OS have opposite perspectives. */
-	stats->rx_packets	= vport_stats.tx_packets;
-	stats->tx_packets	= vport_stats.rx_packets;
-	stats->rx_bytes		= vport_stats.tx_bytes;
-	stats->tx_bytes		= vport_stats.rx_bytes;
-	stats->rx_errors	= vport_stats.tx_errors;
-	stats->tx_errors	= vport_stats.rx_errors;
-	stats->rx_dropped	= vport_stats.tx_dropped;
-	stats->tx_dropped	= vport_stats.rx_dropped;
-
-	return stats;
-}
-
 /* Called with rcu_read_lock_bh. */
 static int internal_dev_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
+	int len, err;
+
+	len = skb->len;
 	rcu_read_lock();
-	ovs_vport_receive(internal_dev_priv(netdev)->vport, skb, NULL);
+	err = ovs_vport_receive(internal_dev_priv(netdev)->vport, skb, NULL);
 	rcu_read_unlock();
+
+	if (likely(!err)) {
+		struct pcpu_sw_netstats *tstats = this_cpu_ptr(netdev->tstats);
+
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		netdev->stats.tx_errors++;
+	}
 	return 0;
 }
 
@@ -121,7 +112,6 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_start_xmit = internal_dev_xmit,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_change_mtu = internal_dev_change_mtu,
-	.ndo_get_stats64 = internal_dev_get_stats,
 };
 
 static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
@@ -212,18 +202,17 @@ static void internal_dev_destroy(struct vport *vport)
 	rtnl_unlock();
 }
 
-static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
+static void internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 {
 	struct net_device *netdev = vport->dev;
-	int len;
+	struct pcpu_sw_netstats *stats;
 
 	if (unlikely(!(netdev->flags & IFF_UP))) {
 		kfree_skb(skb);
-		return 0;
+		netdev->stats.rx_dropped++;
+		return;
 	}
 
-	len = skb->len;
-
 	skb_dst_drop(skb);
 	nf_reset(skb);
 	secpath_reset(skb);
@@ -233,9 +222,13 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	skb->protocol = eth_type_trans(skb, netdev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
-	netif_rx(skb);
+	stats = this_cpu_ptr(netdev->tstats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+	u64_stats_update_end(&stats->syncp);
 
-	return len;
+	netif_rx(skb);
 }
 
 static struct vport_ops ovs_internal_vport_ops = {
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index a750115..f7e8dcc 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -39,8 +39,11 @@
 static struct vport_ops ovs_netdev_vport_ops;
 
 /* Must be called with rcu_read_lock. */
-static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
+static void netdev_port_receive(struct sk_buff *skb)
 {
+	struct vport *vport;
+
+	vport = ovs_netdev_get_vport(skb->dev);
 	if (unlikely(!vport))
 		goto error;
 
@@ -56,10 +59,8 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 
 	skb_push(skb, ETH_HLEN);
 	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
-
 	ovs_vport_receive(vport, skb, skb_tunnel_info(skb));
 	return;
-
 error:
 	kfree_skb(skb);
 }
@@ -68,15 +69,11 @@ error:
 static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	struct vport *vport;
 
 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
 		return RX_HANDLER_PASS;
 
-	vport = ovs_netdev_get_vport(skb->dev);
-
-	netdev_port_receive(vport, skb);
-
+	netdev_port_receive(skb);
 	return RX_HANDLER_CONSUMED;
 }
 
@@ -203,27 +200,24 @@ static unsigned int packet_length(const struct sk_buff *skb)
 	return length;
 }
 
-int ovs_netdev_send(struct vport *vport, struct sk_buff *skb)
+void ovs_netdev_send(struct vport *vport, struct sk_buff *skb)
 {
 	int mtu = vport->dev->mtu;
-	int len;
 
 	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
 				     vport->dev->name,
 				     packet_length(skb), mtu);
+		vport->dev->stats.tx_errors++;
 		goto drop;
 	}
 
 	skb->dev = vport->dev;
-	len = skb->len;
 	dev_queue_xmit(skb);
-
-	return len;
+	return;
 
 drop:
 	kfree_skb(skb);
-	return 0;
 }
 EXPORT_SYMBOL_GPL(ovs_netdev_send);
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 497cc81..bf22fce 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -27,7 +27,7 @@
 struct vport *ovs_netdev_get_vport(struct net_device *dev);
 
 struct vport *ovs_netdev_link(struct vport *vport, const char *name);
-int ovs_netdev_send(struct vport *vport, struct sk_buff *skb);
+void ovs_netdev_send(struct vport *vport, struct sk_buff *skb);
 void ovs_netdev_detach_dev(struct vport *);
 
 int __init ovs_netdev_init(void);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index bd118f2..c5895d5 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -34,9 +34,6 @@
 #include "vport.h"
 #include "vport-internal_dev.h"
 
-static void ovs_vport_record_error(struct vport *,
-				   enum vport_err_type err_type);
-
 static LIST_HEAD(vport_ops_list);
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
@@ -157,12 +154,6 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 		return ERR_PTR(-EINVAL);
 	}
 
-	vport->percpu_stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
-	if (!vport->percpu_stats) {
-		kfree(vport);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	return vport;
 }
 EXPORT_SYMBOL_GPL(ovs_vport_alloc);
@@ -183,7 +174,6 @@ void ovs_vport_free(struct vport *vport)
 	 * it is safe to use raw dereference.
 	 */
 	kfree(rcu_dereference_raw(vport->upcall_portids));
-	free_percpu(vport->percpu_stats);
 	kfree(vport);
 }
 EXPORT_SYMBOL_GPL(ovs_vport_free);
@@ -290,30 +280,24 @@ void ovs_vport_del(struct vport *vport)
  */
 void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 {
+	struct net_device *dev = vport->dev;
 	int i;
 
 	memset(stats, 0, sizeof(*stats));
+	stats->rx_errors  = dev->stats.rx_errors;
+	stats->tx_errors  = dev->stats.tx_errors;
+	stats->tx_dropped = dev->stats.tx_dropped;
+	stats->rx_dropped = dev->stats.rx_dropped;
 
-	/* We potentially have 2 sources of stats that need to be combined:
-	 * those we have collected (split into err_stats and percpu_stats) from
-	 * set_stats() and device error stats from netdev->get_stats() (for
-	 * errors that happen  downstream and therefore aren't reported through
-	 * our vport_record_error() function).
-	 * Stats from first source are reported by ovs (OVS_VPORT_ATTR_STATS).
-	 * netdev-stats can be directly read over netlink-ioctl.
-	 */
-
-	stats->rx_errors  = atomic_long_read(&vport->err_stats.rx_errors);
-	stats->tx_errors  = atomic_long_read(&vport->err_stats.tx_errors);
-	stats->tx_dropped = atomic_long_read(&vport->err_stats.tx_dropped);
-	stats->rx_dropped = atomic_long_read(&vport->err_stats.rx_dropped);
+	stats->rx_dropped += atomic_long_read(&dev->rx_dropped);
+	stats->tx_dropped += atomic_long_read(&dev->tx_dropped);
 
 	for_each_possible_cpu(i) {
 		const struct pcpu_sw_netstats *percpu_stats;
 		struct pcpu_sw_netstats local_stats;
 		unsigned int start;
 
-		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
+		percpu_stats = per_cpu_ptr(dev->tstats, i);
 
 		do {
 			start = u64_stats_fetch_begin_irq(&percpu_stats->syncp);
@@ -468,94 +452,25 @@ u32 ovs_vport_find_upcall_portid(const struct vport *vport, struct sk_buff *skb)
  * Must be called with rcu_read_lock.  The packet cannot be shared and
  * skb->data should point to the Ethernet header.
  */
-void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
-		       const struct ip_tunnel_info *tun_info)
+int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
+		      const struct ip_tunnel_info *tun_info)
 {
-	struct pcpu_sw_netstats *stats;
 	struct sw_flow_key key;
 	int error;
 
-	stats = this_cpu_ptr(vport->percpu_stats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len +
-			   (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
-	u64_stats_update_end(&stats->syncp);
-
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->mru = 0;
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
 		kfree_skb(skb);
-		return;
+		return error;
 	}
 	ovs_dp_process_packet(skb, &key);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(ovs_vport_receive);
 
-/**
- *	ovs_vport_send - send a packet on a device
- *
- * @vport: vport on which to send the packet
- * @skb: skb to send
- *
- * Sends the given packet and returns the length of data sent.  Either ovs
- * lock or rcu_read_lock must be held.
- */
-int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
-{
-	int sent = vport->ops->send(vport, skb);
-
-	if (likely(sent > 0)) {
-		struct pcpu_sw_netstats *stats;
-
-		stats = this_cpu_ptr(vport->percpu_stats);
-
-		u64_stats_update_begin(&stats->syncp);
-		stats->tx_packets++;
-		stats->tx_bytes += sent;
-		u64_stats_update_end(&stats->syncp);
-	} else if (sent < 0) {
-		ovs_vport_record_error(vport, VPORT_E_TX_ERROR);
-	} else {
-		ovs_vport_record_error(vport, VPORT_E_TX_DROPPED);
-	}
-	return sent;
-}
-
-/**
- *	ovs_vport_record_error - indicate device error to generic stats layer
- *
- * @vport: vport that encountered the error
- * @err_type: one of enum vport_err_type types to indicate the error type
- *
- * If using the vport generic stats layer indicate that an error of the given
- * type has occurred.
- */
-static void ovs_vport_record_error(struct vport *vport,
-				   enum vport_err_type err_type)
-{
-	switch (err_type) {
-	case VPORT_E_RX_DROPPED:
-		atomic_long_inc(&vport->err_stats.rx_dropped);
-		break;
-
-	case VPORT_E_RX_ERROR:
-		atomic_long_inc(&vport->err_stats.rx_errors);
-		break;
-
-	case VPORT_E_TX_DROPPED:
-		atomic_long_inc(&vport->err_stats.tx_dropped);
-		break;
-
-	case VPORT_E_TX_ERROR:
-		atomic_long_inc(&vport->err_stats.tx_errors);
-		break;
-	}
-
-}
-
 static void free_vport_rcu(struct rcu_head *rcu)
 {
 	struct vport *vport = container_of(rcu, struct vport, rcu);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index a36aef2..30615ed 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -57,8 +57,6 @@ int ovs_vport_set_upcall_portids(struct vport *, const struct nlattr *pids);
 int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
 u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
-int ovs_vport_send(struct vport *, struct sk_buff *);
-
 int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 			       struct net *net,
 			       struct sk_buff *,
@@ -68,14 +66,6 @@ int ovs_tunnel_get_egress_info(struct ip_tunnel_info *egress_tun_info,
 int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
 				  struct ip_tunnel_info *info);
 
-/* The following definitions are for implementers of vport devices: */
-
-struct vport_err_stats {
-	atomic_long_t rx_dropped;
-	atomic_long_t rx_errors;
-	atomic_long_t tx_dropped;
-	atomic_long_t tx_errors;
-};
 /**
  * struct vport_portids - array of netlink portids of a vport.
  *                        must be protected by rcu.
@@ -101,8 +91,6 @@ struct vport_portids {
  * @hash_node: Element in @dev_table hash table in vport.c.
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
- * @percpu_stats: Points to per-CPU statistics used and maintained by vport
- * @err_stats: Points to error statistics used and maintained by vport
  * @detach_list: list used for detaching vport in net-exit call.
  */
 struct vport {
@@ -115,9 +103,6 @@ struct vport {
 	struct hlist_node dp_hash_node;
 	const struct vport_ops *ops;
 
-	struct pcpu_sw_netstats __percpu *percpu_stats;
-
-	struct vport_err_stats err_stats;
 	struct list_head detach_list;
 	struct rcu_head rcu;
 };
@@ -156,7 +141,7 @@ struct vport_parms {
  * @get_options: Appends vport-specific attributes for the configuration of an
  * existing vport to a &struct sk_buff.  May be %NULL for a vport that does not
  * have any configuration.
- * @send: Send a packet on the device.  Returns the length of the packet sent,
+ * @send: Send a packet on the device.
  * zero for dropped packets or negative for error.
  * @get_egress_tun_info: Get the egress tunnel 5-tuple and other info for
  * a packet.
@@ -171,7 +156,7 @@ struct vport_ops {
 	int (*set_options)(struct vport *, struct nlattr *);
 	int (*get_options)(const struct vport *, struct sk_buff *);
 
-	int (*send)(struct vport *, struct sk_buff *);
+	void (*send)(struct vport *, struct sk_buff *);
 	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
 				   struct ip_tunnel_info *);
 
@@ -179,13 +164,6 @@ struct vport_ops {
 	struct list_head list;
 };
 
-enum vport_err_type {
-	VPORT_E_RX_DROPPED,
-	VPORT_E_RX_ERROR,
-	VPORT_E_TX_DROPPED,
-	VPORT_E_TX_ERROR,
-};
-
 struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *,
 			      const struct vport_parms *);
 void ovs_vport_free(struct vport *);
@@ -222,8 +200,8 @@ static inline struct vport *vport_from_priv(void *priv)
 	return (struct vport *)((u8 *)priv - ALIGN(sizeof(struct vport), VPORT_ALIGN));
 }
 
-void ovs_vport_receive(struct vport *, struct sk_buff *,
-		       const struct ip_tunnel_info *);
+int ovs_vport_receive(struct vport *, struct sk_buff *,
+		      const struct ip_tunnel_info *);
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
@@ -258,4 +236,10 @@ static inline struct rtable *ovs_tunnel_route_lookup(struct net *net,
 	rt = ip_route_output_key(net, fl);
 	return rt;
 }
+
+static inline void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
+{
+	vport->ops->send(vport, skb);
+}
+
 #endif /* vport.h */
-- 
1.7.1
