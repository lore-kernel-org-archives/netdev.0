From: roy.qing.li@gmail.com
Subject: [PATCH net-next v2] net: unify the pcpu_tstats and br_cpu_netstats as one
Date: Sat,  4 Jan 2014 13:57:59 +0800
Message-ID: <1388815080-5408-1-git-send-email-roy.qing.li@gmail.com>
Cc: xiyou.wangcong@gmail.com, stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:33477 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754859AbaADF6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 00:58:09 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so16344390pbc.26
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 21:58:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

They are same, so unify them as one, pcpu_sw_netstats.

Define pcpu_sw_netstat in netdevice.h, remove pcpu_tstats
from if_tunnel and remove br_cpu_netstats from br_private.h

Cc: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c       |   11 ++++++-----
 include/linux/if_tunnel.h |    9 ---------
 include/linux/netdevice.h |   11 ++++++++++-
 include/net/ip6_tunnel.h  |    2 +-
 include/net/ip_tunnels.h  |    4 ++--
 net/bridge/br_device.c    |   10 +++++-----
 net/bridge/br_input.c     |    2 +-
 net/bridge/br_private.h   |   10 +---------
 net/ipv4/ip_tunnel.c      |    9 +++++----
 net/ipv4/ip_vti.c         |    2 +-
 net/ipv6/ip6_gre.c        |   10 +++++-----
 net/ipv6/ip6_tunnel.c     |   12 ++++++------
 net/ipv6/ip6_vti.c        |   10 +++++-----
 net/ipv6/sit.c            |   10 +++++-----
 net/openvswitch/vport.c   |   12 ++++++------
 net/openvswitch/vport.h   |    2 +-
 16 files changed, 60 insertions(+), 66 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index aef44aa..474a99e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1081,7 +1081,7 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 	struct iphdr *oip = NULL;
 	struct ipv6hdr *oip6 = NULL;
 	struct vxlan_dev *vxlan;
-	struct pcpu_tstats *stats;
+	struct pcpu_sw_netstats *stats;
 	union vxlan_addr saddr;
 	__u32 vni;
 	int err = 0;
@@ -1587,11 +1587,12 @@ EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 			       struct vxlan_dev *dst_vxlan)
 {
-	struct pcpu_tstats *tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
-	struct pcpu_tstats *rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
+	struct pcpu_sw_netstats *tx_stats, *rx_stats;
 	union vxlan_addr loopback;
 	union vxlan_addr *remote_ip = &dst_vxlan->default_dst.remote_ip;
 
+	tx_stats = this_cpu_ptr(src_vxlan->dev->tstats);
+	rx_stats = this_cpu_ptr(dst_vxlan->dev->tstats);
 	skb->pkt_type = PACKET_HOST;
 	skb->encapsulation = 0;
 	skb->dev = dst_vxlan->dev;
@@ -1897,12 +1898,12 @@ static int vxlan_init(struct net_device *dev)
 	struct vxlan_sock *vs;
 	int i;
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *vxlan_stats;
+		struct pcpu_sw_netstats *vxlan_stats;
 		vxlan_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&vxlan_stats->syncp);
 	}
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index f4e56ec..712710b 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -13,13 +13,4 @@
 #define for_each_ip_tunnel_rcu(pos, start) \
 	for (pos = rcu_dereference(start); pos; pos = rcu_dereference(pos->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88afa80..7eecca2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1409,7 +1409,7 @@ struct net_device {
 	union {
 		void				*ml_priv;
 		struct pcpu_lstats __percpu	*lstats; /* loopback stats */
-		struct pcpu_tstats __percpu	*tstats; /* tunnel stats */
+		struct pcpu_sw_netstats __percpu	*tstats;
 		struct pcpu_dstats __percpu	*dstats; /* dummy stats */
 		struct pcpu_vstats __percpu	*vstats; /* veth stats */
 	};
@@ -1685,6 +1685,15 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct pcpu_sw_netstats {
+	u64     rx_packets;
+	u64     rx_bytes;
+	u64     tx_packets;
+	u64     tx_bytes;
+	struct u64_stats_sync   syncp;
+};
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 6d1549c..a5593da 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -79,7 +79,7 @@ static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	err = ip6_local_out(skb);
 
 	if (net_xmit_eval(err) == 0) {
-		struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
+		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->tx_bytes += pkt_len;
 		tstats->tx_packets++;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 732f8c6..c26ff28 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -155,10 +155,10 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
 
 static inline void iptunnel_xmit_stats(int err,
 				       struct net_device_stats *err_stats,
-				       struct pcpu_tstats __percpu *stats)
+				       struct pcpu_sw_netstats __percpu *stats)
 {
 	if (err > 0) {
-		struct pcpu_tstats *tstats = this_cpu_ptr(stats);
+		struct pcpu_sw_netstats *tstats = this_cpu_ptr(stats);
 
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->tx_bytes += err;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f00cfd2..e4401a5 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -32,7 +32,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	const unsigned char *dest = skb->data;
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
-	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
 	u16 vid = 0;
 
 	rcu_read_lock();
@@ -90,12 +90,12 @@ static int br_dev_init(struct net_device *dev)
 	struct net_bridge *br = netdev_priv(dev);
 	int i;
 
-	br->stats = alloc_percpu(struct br_cpu_netstats);
+	br->stats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!br->stats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct br_cpu_netstats *br_dev_stats;
+		struct pcpu_sw_netstats *br_dev_stats;
 		br_dev_stats = per_cpu_ptr(br->stats, i);
 		u64_stats_init(&br_dev_stats->syncp);
 	}
@@ -135,12 +135,12 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 						struct rtnl_link_stats64 *stats)
 {
 	struct net_bridge *br = netdev_priv(dev);
-	struct br_cpu_netstats tmp, sum = { 0 };
+	struct pcpu_sw_netstats tmp, sum = { 0 };
 	unsigned int cpu;
 
 	for_each_possible_cpu(cpu) {
 		unsigned int start;
-		const struct br_cpu_netstats *bstats
+		const struct pcpu_sw_netstats *bstats
 			= per_cpu_ptr(br->stats, cpu);
 		do {
 			start = u64_stats_fetch_begin_bh(&bstats->syncp);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7e73c32..bf8dc7d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -28,7 +28,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(brdev);
-	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2e77d92..3733f15 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -210,21 +210,13 @@ static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *
 		rtnl_dereference(dev->rx_handler_data) : NULL;
 }
 
-struct br_cpu_netstats {
-	u64			rx_packets;
-	u64			rx_bytes;
-	u64			tx_packets;
-	u64			tx_bytes;
-	struct u64_stats_sync	syncp;
-};
-
 struct net_bridge
 {
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
 
-	struct br_cpu_netstats __percpu *stats;
+	struct pcpu_sw_netstats		__percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 #ifdef CONFIG_BRIDGE_NETFILTER
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 90ff957..181fc83 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -75,7 +75,8 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 	int i;
 
 	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		const struct pcpu_sw_netstats *tstats =
+						   per_cpu_ptr(dev->tstats, i);
 		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
 		unsigned int start;
 
@@ -405,7 +406,7 @@ static struct ip_tunnel *ip_tunnel_create(struct net *net,
 int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
 {
-	struct pcpu_tstats *tstats;
+	struct pcpu_sw_netstats *tstats;
 	const struct iphdr *iph = ip_hdr(skb);
 	int err;
 
@@ -979,12 +980,12 @@ int ip_tunnel_init(struct net_device *dev)
 	int i, err;
 
 	dev->destructor	= ip_tunnel_dev_free;
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ipt_stats;
+		struct pcpu_sw_netstats *ipt_stats;
 		ipt_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ipt_stats->syncp);
 	}
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 52b802a..0783200 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -60,7 +60,7 @@ static int vti_rcv(struct sk_buff *skb)
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 				  iph->saddr, iph->daddr, 0);
 	if (tunnel != NULL) {
-		struct pcpu_tstats *tstats;
+		struct pcpu_sw_netstats *tstats;
 		u32 oldmark = skb->mark;
 		int ret;
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index e27fb78..e7a440d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -498,7 +498,7 @@ static int ip6gre_rcv(struct sk_buff *skb)
 					  &ipv6h->saddr, &ipv6h->daddr, key,
 					  gre_proto);
 	if (tunnel) {
-		struct pcpu_tstats *tstats;
+		struct pcpu_sw_netstats *tstats;
 
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
@@ -1265,12 +1265,12 @@ static int ip6gre_tunnel_init(struct net_device *dev)
 	if (ipv6_addr_any(&tunnel->parms.raddr))
 		dev->header_ops = &ip6gre_header_ops;
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ip6gre_tunnel_stats;
+		struct pcpu_sw_netstats *ip6gre_tunnel_stats;
 		ip6gre_tunnel_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ip6gre_tunnel_stats->syncp);
 	}
@@ -1466,12 +1466,12 @@ static int ip6gre_tap_init(struct net_device *dev)
 
 	ip6gre_tnl_link_config(tunnel, 1);
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ip6gre_tap_stats;
+		struct pcpu_sw_netstats *ip6gre_tap_stats;
 		ip6gre_tap_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ip6gre_tap_stats->syncp);
 	}
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8d7c986..0289421 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -29,7 +29,6 @@
 #include <linux/if.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/if_tunnel.h>
 #include <linux/net.h>
 #include <linux/in6.h>
 #include <linux/netdevice.h>
@@ -102,11 +101,12 @@ struct ip6_tnl_net {
 
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 {
-	struct pcpu_tstats sum = { 0 };
+	struct pcpu_sw_netstats sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		const struct pcpu_sw_netstats *tstats =
+						   per_cpu_ptr(dev->tstats, i);
 
 		sum.rx_packets += tstats->rx_packets;
 		sum.rx_bytes   += tstats->rx_bytes;
@@ -784,7 +784,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	if ((t = ip6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 					&ipv6h->daddr)) != NULL) {
-		struct pcpu_tstats *tstats;
+		struct pcpu_sw_netstats *tstats;
 
 		if (t->parms.proto != ipproto && t->parms.proto != 0) {
 			rcu_read_unlock();
@@ -1497,12 +1497,12 @@ ip6_tnl_dev_init_gen(struct net_device *dev)
 
 	t->dev = dev;
 	t->net = dev_net(dev);
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ip6_tnl_stats;
+		struct pcpu_sw_netstats *ip6_tnl_stats;
 		ip6_tnl_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ip6_tnl_stats->syncp);
 	}
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed94ba6..b1a81c4 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -24,7 +24,6 @@
 #include <linux/if.h>
 #include <linux/in.h>
 #include <linux/ip.h>
-#include <linux/if_tunnel.h>
 #include <linux/net.h>
 #include <linux/in6.h>
 #include <linux/netdevice.h>
@@ -77,11 +76,12 @@ struct vti6_net {
 
 static struct net_device_stats *vti6_get_stats(struct net_device *dev)
 {
-	struct pcpu_tstats sum = { 0 };
+	struct pcpu_sw_netstats sum = { 0 };
 	int i;
 
 	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		const struct pcpu_sw_netstats *tstats =
+						   per_cpu_ptr(dev->tstats, i);
 
 		sum.rx_packets += tstats->rx_packets;
 		sum.rx_bytes   += tstats->rx_bytes;
@@ -312,7 +312,7 @@ static int vti6_rcv(struct sk_buff *skb)
 
 	if ((t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
 				 &ipv6h->daddr)) != NULL) {
-		struct pcpu_tstats *tstats;
+		struct pcpu_sw_netstats *tstats;
 
 		if (t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) {
 			rcu_read_unlock();
@@ -753,7 +753,7 @@ static inline int vti6_dev_init_gen(struct net_device *dev)
 
 	t->dev = dev;
 	t->net = dev_net(dev);
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 	return 0;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba..9937b26 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -671,7 +671,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
-		struct pcpu_tstats *tstats;
+		struct pcpu_sw_netstats *tstats;
 
 		if (tunnel->parms.iph.protocol != IPPROTO_IPV6 &&
 		    tunnel->parms.iph.protocol != 0)
@@ -1361,12 +1361,12 @@ static int ipip6_tunnel_init(struct net_device *dev)
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
 	ipip6_tunnel_bind_dev(dev);
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ipip6_tunnel_stats;
+		struct pcpu_sw_netstats *ipip6_tunnel_stats;
 		ipip6_tunnel_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ipip6_tunnel_stats->syncp);
 	}
@@ -1391,12 +1391,12 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	iph->ihl		= 5;
 	iph->ttl		= 64;
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	dev->tstats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *ipip6_fb_stats;
+		struct pcpu_sw_netstats *ipip6_fb_stats;
 		ipip6_fb_stats = per_cpu_ptr(dev->tstats, i);
 		u64_stats_init(&ipip6_fb_stats->syncp);
 	}
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index d830a95f..f5275dd 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -136,14 +136,14 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
-	vport->percpu_stats = alloc_percpu(struct pcpu_tstats);
+	vport->percpu_stats = alloc_percpu(struct pcpu_sw_netstats);
 	if (!vport->percpu_stats) {
 		kfree(vport);
 		return ERR_PTR(-ENOMEM);
 	}
 
 	for_each_possible_cpu(i) {
-		struct pcpu_tstats *vport_stats;
+		struct pcpu_sw_netstats *vport_stats;
 		vport_stats = per_cpu_ptr(vport->percpu_stats, i);
 		u64_stats_init(&vport_stats->syncp);
 	}
@@ -275,8 +275,8 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 	spin_unlock_bh(&vport->stats_lock);
 
 	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *percpu_stats;
-		struct pcpu_tstats local_stats;
+		const struct pcpu_sw_netstats *percpu_stats;
+		struct pcpu_sw_netstats local_stats;
 		unsigned int start;
 
 		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
@@ -344,7 +344,7 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 		       struct ovs_key_ipv4_tunnel *tun_key)
 {
-	struct pcpu_tstats *stats;
+	struct pcpu_sw_netstats *stats;
 
 	stats = this_cpu_ptr(vport->percpu_stats);
 	u64_stats_update_begin(&stats->syncp);
@@ -370,7 +370,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 	int sent = vport->ops->send(vport, skb);
 
 	if (likely(sent > 0)) {
-		struct pcpu_tstats *stats;
+		struct pcpu_sw_netstats *stats;
 
 		stats = this_cpu_ptr(vport->percpu_stats);
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1a9fbce..bc97ef7 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -87,7 +87,7 @@ struct vport {
 	struct hlist_node dp_hash_node;
 	const struct vport_ops *ops;
 
-	struct pcpu_tstats __percpu *percpu_stats;
+	struct pcpu_sw_netstats __percpu *percpu_stats;
 
 	spinlock_t stats_lock;
 	struct vport_err_stats err_stats;
-- 
1.7.10.4
