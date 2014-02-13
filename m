From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: introduce netdev_alloc_pcpu_stats() for drivers
Date: Thu, 13 Feb 2014 11:46:28 -0800
Message-ID: <1392320788-17962-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57654 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbaBMTqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 14:46:40 -0500
Received: by mail-pa0-f41.google.com with SMTP id fa1so11282780pad.28
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 11:46:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many drivers calling alloc_percpu() to allocate pcpu stats
and then initializing ->syncp. So just introduce a helper function for them.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index bd8f84b..1656317 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -88,16 +88,10 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static int dummy_dev_init(struct net_device *dev)
 {
-	int i;
-	dev->dstats = alloc_percpu(struct pcpu_dstats);
+	dev->dstats = netdev_alloc_pcpu_stats(struct pcpu_dstats);
 	if (!dev->dstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_dstats *dstats;
-		dstats = per_cpu_ptr(dev->dstats, i);
-		u64_stats_init(&dstats->syncp);
-	}
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f418f4f..12c6a66 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2784,7 +2784,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	const char *mac_from;
 	int phy_mode;
 	int err;
-	int cpu;
 
 	/* Our multiqueue support is not complete, so for now, only
 	 * allow the usage of the first RX queue
@@ -2845,18 +2844,12 @@ static int mvneta_probe(struct platform_device *pdev)
 	}
 
 	/* Alloc per-cpu stats */
-	pp->stats = alloc_percpu(struct mvneta_pcpu_stats);
+	pp->stats = netdev_alloc_pcpu_stats(struct mvneta_pcpu_stats);
 	if (!pp->stats) {
 		err = -ENOMEM;
 		goto err_unmap;
 	}
 
-	for_each_possible_cpu(cpu) {
-		struct mvneta_pcpu_stats *stats;
-		stats = per_cpu_ptr(pp->stats, cpu);
-		u64_stats_init(&stats->syncp);
-	}
-
 	dt_mac_addr = of_get_mac_address(dn);
 	if (dt_mac_addr) {
 		mac_from = "device tree";
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c5011e0..36bc504 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -136,16 +136,9 @@ static const struct ethtool_ops loopback_ethtool_ops = {
 
 static int loopback_dev_init(struct net_device *dev)
 {
-	int i;
-	dev->lstats = alloc_percpu(struct pcpu_lstats);
+	dev->lstats = netdev_alloc_pcpu_stats(struct pcpu_lstats);
 	if (!dev->lstats)
 		return -ENOMEM;
-
-	for_each_possible_cpu(i) {
-		struct pcpu_lstats *lb_stats;
-		lb_stats = per_cpu_ptr(dev->lstats, i);
-		u64_stats_init(&lb_stats->syncp);
-	}
 	return 0;
 }
 
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8433de4..25685e3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -534,7 +534,6 @@ static int macvlan_init(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	const struct net_device *lowerdev = vlan->lowerdev;
-	int i;
 
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
@@ -546,16 +545,10 @@ static int macvlan_init(struct net_device *dev)
 
 	macvlan_set_lockdep_class(dev);
 
-	vlan->pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
+	vlan->pcpu_stats = netdev_alloc_pcpu_stats(struct vlan_pcpu_stats);
 	if (!vlan->pcpu_stats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct vlan_pcpu_stats *mvlstats;
-		mvlstats = per_cpu_ptr(vlan->pcpu_stats, i);
-		u64_stats_init(&mvlstats->syncp);
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index d2bb12b..14ce7de 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -47,16 +47,7 @@ static int nlmon_change_mtu(struct net_device *dev, int new_mtu)
 
 static int nlmon_dev_init(struct net_device *dev)
 {
-	int i;
-
-	dev->lstats = alloc_percpu(struct pcpu_lstats);
-
-	for_each_possible_cpu(i) {
-		struct pcpu_lstats *nlmstats;
-		nlmstats = per_cpu_ptr(dev->lstats, i);
-		u64_stats_init(&nlmstats->syncp);
-	}
-
+	dev->lstats = netdev_alloc_pcpu_stats(struct pcpu_lstats);
 	return dev->lstats == NULL ? -ENOMEM : 0;
 }
 
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2840742..adb46de 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1540,16 +1540,10 @@ static int team_init(struct net_device *dev)
 	mutex_init(&team->lock);
 	team_set_no_mode(team);
 
-	team->pcpu_stats = alloc_percpu(struct team_pcpu_stats);
+	team->pcpu_stats = netdev_alloc_pcpu_stats(struct team_pcpu_stats);
 	if (!team->pcpu_stats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct team_pcpu_stats *team_stats;
-		team_stats = per_cpu_ptr(team->pcpu_stats, i);
-		u64_stats_init(&team_stats->syncp);
-	}
-
 	for (i = 0; i < TEAM_PORT_HASHENTRIES; i++)
 		INIT_HLIST_HEAD(&team->en_port_hlist[i]);
 	INIT_LIST_HEAD(&team->port_list);
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 2ec2041..91c33c1 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -235,18 +235,9 @@ static int veth_change_mtu(struct net_device *dev, int new_mtu)
 
 static int veth_dev_init(struct net_device *dev)
 {
-	int i;
-
-	dev->vstats = alloc_percpu(struct pcpu_vstats);
+	dev->vstats = netdev_alloc_pcpu_stats(struct pcpu_vstats);
 	if (!dev->vstats)
 		return -ENOMEM;
-
-	for_each_possible_cpu(i) {
-		struct pcpu_vstats *veth_stats;
-		veth_stats = per_cpu_ptr(dev->vstats, i);
-		u64_stats_init(&veth_stats->syncp);
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b0f705c..dec9820b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1978,19 +1978,11 @@ static int vxlan_init(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 	struct vxlan_sock *vs;
-	int i;
 
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *vxlan_stats;
-		vxlan_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&vxlan_stats->syncp);
-	}
-
-
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(dev_net(dev), vxlan->dst_port);
 	if (vs) {
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f9daa9e..2b62d79 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1281,16 +1281,10 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	np->rx_refill_timer.function = rx_refill_timeout;
 
 	err = -ENOMEM;
-	np->stats = alloc_percpu(struct netfront_stats);
+	np->stats = netdev_alloc_pcpu_stats(struct netfront_stats);
 	if (np->stats == NULL)
 		goto exit;
 
-	for_each_possible_cpu(i) {
-		struct netfront_stats *xen_nf_stats;
-		xen_nf_stats = per_cpu_ptr(np->stats, i);
-		u64_stats_init(&xen_nf_stats->syncp);
-	}
-
 	/* Initialise tx_skbs as a free chain containing every entry. */
 	np->tx_skb_freelist = 0;
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 440a02e..430c51a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1726,6 +1726,20 @@ struct pcpu_sw_netstats {
 	struct u64_stats_sync   syncp;
 };
 
+#define netdev_alloc_pcpu_stats(type)				\
+({								\
+	typeof(type) *pcpu_stats = alloc_percpu(type);		\
+	if (pcpu_stats)	{					\
+		int i;						\
+		for_each_possible_cpu(i) {			\
+			typeof(type) *stat;			\
+			stat = per_cpu_ptr(pcpu_stats, i);	\
+			u64_stats_init(&stat->syncp);		\
+		}						\
+	}							\
+	pcpu_stats;						\
+})
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index de51c48..566adbf 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -556,7 +556,7 @@ static const struct net_device_ops vlan_netdev_ops;
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
-	int subclass = 0, i;
+	int subclass = 0;
 
 	netif_carrier_off(dev);
 
@@ -606,17 +606,10 @@ static int vlan_dev_init(struct net_device *dev)
 
 	vlan_dev_set_lockdep_class(dev, subclass);
 
-	vlan_dev_priv(dev)->vlan_pcpu_stats = alloc_percpu(struct vlan_pcpu_stats);
+	vlan_dev_priv(dev)->vlan_pcpu_stats = netdev_alloc_pcpu_stats(struct vlan_pcpu_stats);
 	if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct vlan_pcpu_stats *vlan_stat;
-		vlan_stat = per_cpu_ptr(vlan_dev_priv(dev)->vlan_pcpu_stats, i);
-		u64_stats_init(&vlan_stat->syncp);
-	}
-
-
 	return 0;
 }
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 63f0455..bf34451 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -88,18 +88,11 @@ out:
 static int br_dev_init(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	int i;
 
-	br->stats = alloc_percpu(struct pcpu_sw_netstats);
+	br->stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!br->stats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *br_dev_stats;
-		br_dev_stats = per_cpu_ptr(br->stats, i);
-		u64_stats_init(&br_dev_stats->syncp);
-	}
-
 	return 0;
 }
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 50228be..3400d73 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -1041,19 +1041,13 @@ int ip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
-	int i, err;
+	int err;
 
 	dev->destructor	= ip_tunnel_dev_free;
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ipt_stats;
-		ipt_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ipt_stats->syncp);
-	}
-
 	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
 	if (!tunnel->dst_cache) {
 		free_percpu(dev->tstats);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f3ffb43..c98338b 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1454,7 +1454,6 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 static int ip6gre_tap_init(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
-	int i;
 
 	tunnel = netdev_priv(dev);
 
@@ -1464,16 +1463,10 @@ static int ip6gre_tap_init(struct net_device *dev)
 
 	ip6gre_tnl_link_config(tunnel, 1);
 
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ip6gre_tap_stats;
-		ip6gre_tap_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ip6gre_tap_stats->syncp);
-	}
-
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 5db8d31..8ad59f4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1502,19 +1502,12 @@ static inline int
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	int i;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
-
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ip6_tnl_stats;
-		ip6_tnl_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ip6_tnl_stats->syncp);
-	}
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 2d19272..8649143 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -731,18 +731,12 @@ static void vti6_dev_setup(struct net_device *dev)
 static inline int vti6_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	int i;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *stats;
-		stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&stats->syncp);
-	}
 	return 0;
 }
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3dfbcf1..958027b 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1356,7 +1356,6 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 static int ipip6_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	int i;
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
@@ -1365,16 +1364,10 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip6_tunnel_bind_dev(dev);
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ipip6_tunnel_stats;
-		ipip6_tunnel_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ipip6_tunnel_stats->syncp);
-	}
-
 	return 0;
 }
 
@@ -1384,7 +1377,6 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	struct iphdr *iph = &tunnel->parms.iph;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
-	int i;
 
 	tunnel->dev = dev;
 	tunnel->net = dev_net(dev);
@@ -1395,16 +1387,10 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 	iph->ttl		= 64;
 
-	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
+	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *ipip6_fb_stats;
-		ipip6_fb_stats = per_cpu_ptr(dev->tstats, i);
-		u64_stats_init(&ipip6_fb_stats->syncp);
-	}
-
 	dev_hold(dev);
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 	return 0;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e9a48ba..3a95406 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1215,18 +1215,12 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_free_dp;
 
-	dp->stats_percpu = alloc_percpu(struct dp_stats_percpu);
+	dp->stats_percpu = netdev_alloc_pcpu_stats(struct dp_stats_percpu);
 	if (!dp->stats_percpu) {
 		err = -ENOMEM;
 		goto err_destroy_table;
 	}
 
-	for_each_possible_cpu(i) {
-		struct dp_stats_percpu *dpath_stats;
-		dpath_stats = per_cpu_ptr(dp->stats_percpu, i);
-		u64_stats_init(&dpath_stats->sync);
-	}
-
 	dp->ports = kmalloc(DP_VPORT_HASH_BUCKETS * sizeof(struct hlist_head),
 			    GFP_KERNEL);
 	if (!dp->ports) {
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 208dd9a..3b4db32 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -121,7 +121,6 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 {
 	struct vport *vport;
 	size_t alloc_size;
-	int i;
 
 	alloc_size = sizeof(struct vport);
 	if (priv_size) {
@@ -139,19 +138,12 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
-	vport->percpu_stats = alloc_percpu(struct pcpu_sw_netstats);
+	vport->percpu_stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!vport->percpu_stats) {
 		kfree(vport);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	for_each_possible_cpu(i) {
-		struct pcpu_sw_netstats *vport_stats;
-		vport_stats = per_cpu_ptr(vport->percpu_stats, i);
-		u64_stats_init(&vport_stats->syncp);
-	}
-
-
 	spin_lock_init(&vport->stats_lock);
 
 	return vport;
