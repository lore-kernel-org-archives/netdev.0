From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 2/6] vxlan: get rid of redundant vxlan_dev.flags
Date: Fri, 14 Apr 2017 18:44:42 +0200
Message-ID: <cedacf775ad839730b30815084318b190104eace.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1492187126.git.mschiffer@universe-factory.net>
References: <cover.1492187126.git.mschiffer@universe-factory.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no good reason to keep the flags twice in vxlan_dev and
vxlan_config.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

v2: new patch

 drivers/net/vxlan.c           | 76 +++++++++++++++++++++----------------------
 include/net/vxlan.h           |  1 -
 net/openvswitch/vport-vxlan.c |  4 +--
 3 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 86471e961708..bdd19e5037b0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -303,7 +303,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
 	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
 		goto nla_put_failure;
-	if ((vxlan->flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
+	if ((vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
 	    nla_put_u32(skb, NDA_SRC_VNI,
 			be32_to_cpu(fdb->vni)))
 		goto nla_put_failure;
@@ -417,7 +417,7 @@ static u32 eth_vni_hash(const unsigned char *addr, __be32 vni)
 static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
 						const u8 *mac, __be32 vni)
 {
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA)
+	if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA)
 		return &vxlan->fdb_head[eth_vni_hash(mac, vni)];
 	else
 		return &vxlan->fdb_head[eth_hash(mac)];
@@ -432,7 +432,7 @@ static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
 
 	hlist_for_each_entry_rcu(f, head, hlist) {
 		if (ether_addr_equal(mac, f->eth_addr)) {
-			if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+			if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) {
 				if (vni == f->vni)
 					return f;
 			} else {
@@ -1266,7 +1266,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 #endif
 	}
 
-	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	if ((vxlan->cfg.flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source, vni))
 		return false;
 
@@ -1489,7 +1489,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+	} else if (vxlan->cfg.flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin.sin_addr.s_addr = tip,
 			.sin.sin_family = AF_INET,
@@ -1649,7 +1649,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
 
-	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+	} else if (vxlan->cfg.flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin6.sin6_addr = msg->target,
 			.sin6.sin6_family = AF_INET6,
@@ -1682,7 +1682,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip = ip_hdr(skb);
 		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
-		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
+		if (!n && (vxlan->cfg.flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin.sin_addr.s_addr = pip->daddr,
 				.sin.sin_family = AF_INET,
@@ -1703,7 +1703,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip6 = ipv6_hdr(skb);
 		n = neigh_lookup(ipv6_stub->nd_tbl, &pip6->daddr, dev);
-		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
+		if (!n && (vxlan->cfg.flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin6.sin6_addr = pip6->daddr,
 				.sin6.sin6_family = AF_INET6,
@@ -1977,7 +1977,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 #endif
 	}
 
-	if (dst_vxlan->flags & VXLAN_F_LEARN)
+	if (dst_vxlan->cfg.flags & VXLAN_F_LEARN)
 		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source, vni);
 
 	u64_stats_update_begin(&tx_stats->syncp);
@@ -2015,7 +2015,7 @@ static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 		dst_release(dst);
 		dst_vxlan = vxlan_find_vni(vxlan->net, vni,
 					   daddr->sa.sa_family, dst_port,
-					   vxlan->flags);
+					   vxlan->cfg.flags);
 		if (!dst_vxlan) {
 			dev->stats.tx_errors++;
 			kfree_skb(skb);
@@ -2046,7 +2046,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__be32 vni, label;
 	__u8 tos, ttl;
 	int err;
-	u32 flags = vxlan->flags;
+	u32 flags = vxlan->cfg.flags;
 	bool udp_sum = false;
 	bool xnet = !net_eq(vxlan->net, dev_net(vxlan->dev));
 
@@ -2228,7 +2228,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_reset_mac_header(skb);
 
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+	if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) {
 		if (info && info->mode & IP_TUNNEL_INFO_BRIDGE &&
 		    info->mode & IP_TUNNEL_INFO_TX) {
 			vni = tunnel_id_to_key32(info->key.tun_id);
@@ -2241,7 +2241,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	if (vxlan->flags & VXLAN_F_PROXY) {
+	if (vxlan->cfg.flags & VXLAN_F_PROXY) {
 		eth = eth_hdr(skb);
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
 			return arp_reduce(dev, skb, vni);
@@ -2261,7 +2261,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	f = vxlan_find_mac(vxlan, eth->h_dest, vni);
 	did_rsc = false;
 
-	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
+	if (f && (f->flags & NTF_ROUTER) && (vxlan->cfg.flags & VXLAN_F_RSC) &&
 	    (ntohs(eth->h_proto) == ETH_P_IP ||
 	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
 		did_rsc = route_shortcircuit(dev, skb);
@@ -2272,7 +2272,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (f == NULL) {
 		f = vxlan_find_mac(vxlan, all_zeros_mac, vni);
 		if (f == NULL) {
-			if ((vxlan->flags & VXLAN_F_L2MISS) &&
+			if ((vxlan->cfg.flags & VXLAN_F_L2MISS) &&
 			    !is_multicast_ether_addr(eth->h_dest))
 				vxlan_fdb_miss(vxlan, eth->h_dest);
 
@@ -2809,7 +2809,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 	if (!vxlan->cfg.no_share) {
 		spin_lock(&vn->sock_lock);
 		vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
-				     vxlan->cfg.dst_port, vxlan->flags);
+				     vxlan->cfg.dst_port, vxlan->cfg.flags);
 		if (vs && !atomic_add_unless(&vs->refcnt, 1, 0)) {
 			spin_unlock(&vn->sock_lock);
 			return -EBUSY;
@@ -2818,7 +2818,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 	}
 	if (!vs)
 		vs = vxlan_socket_create(vxlan->net, ipv6,
-					 vxlan->cfg.dst_port, vxlan->flags);
+					 vxlan->cfg.dst_port, vxlan->cfg.flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2833,8 +2833,8 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 
 static int vxlan_sock_add(struct vxlan_dev *vxlan)
 {
-	bool ipv6 = vxlan->flags & VXLAN_F_IPV6;
-	bool metadata = vxlan->flags & VXLAN_F_COLLECT_METADATA;
+	bool ipv6 = vxlan->cfg.flags & VXLAN_F_IPV6;
+	bool metadata = vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA;
 	int ret = 0;
 
 	RCU_INIT_POINTER(vxlan->vn4_sock, NULL);
@@ -2935,7 +2935,7 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
 		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
 		    tmp->cfg.dst_port == conf->dst_port &&
-		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
+		    (tmp->cfg.flags & VXLAN_F_RCV_FLAGS) ==
 		    (conf->flags & VXLAN_F_RCV_FLAGS)) {
 			pr_info("duplicate VNI %u\n", be32_to_cpu(conf->vni));
 			return -EEXIST;
@@ -2991,7 +2991,6 @@ static void vxlan_config_apply(struct net_device *dev,
 	dev->needed_headroom = needed_headroom;
 
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
-	vxlan->flags |= conf->flags;
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
@@ -3105,12 +3104,10 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 			     IPV6_FLOWLABEL_MASK;
 
 	if (data[IFLA_VXLAN_LEARNING]) {
-		if (nla_get_u8(data[IFLA_VXLAN_LEARNING])) {
+		if (nla_get_u8(data[IFLA_VXLAN_LEARNING]))
 			conf->flags |= VXLAN_F_LEARN;
-		} else {
+		else
 			conf->flags &= ~VXLAN_F_LEARN;
-			vxlan->flags &= ~VXLAN_F_LEARN;
-		}
 	} else if (!changelink) {
 		/* default to learn on a new device */
 		conf->flags |= VXLAN_F_LEARN;
@@ -3399,43 +3396,44 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->cfg.tos) ||
 	    nla_put_be32(skb, IFLA_VXLAN_LABEL, vxlan->cfg.label) ||
 	    nla_put_u8(skb, IFLA_VXLAN_LEARNING,
-			!!(vxlan->flags & VXLAN_F_LEARN)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_LEARN)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_PROXY,
-			!!(vxlan->flags & VXLAN_F_PROXY)) ||
-	    nla_put_u8(skb, IFLA_VXLAN_RSC, !!(vxlan->flags & VXLAN_F_RSC)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_PROXY)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_RSC,
+		       !!(vxlan->cfg.flags & VXLAN_F_RSC)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_L2MISS,
-			!!(vxlan->flags & VXLAN_F_L2MISS)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_L2MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
-			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_L3MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_COLLECT_METADATA,
-		       !!(vxlan->flags & VXLAN_F_COLLECT_METADATA)) ||
+		       !!(vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->cfg.age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->cfg.addrmax) ||
 	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->cfg.dst_port) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_CSUM,
-			!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM_TX)) ||
+			!(vxlan->cfg.flags & VXLAN_F_UDP_ZERO_CSUM_TX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
-			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_UDP_ZERO_CSUM6_TX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
-			!!(vxlan->flags & VXLAN_F_UDP_ZERO_CSUM6_RX)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_UDP_ZERO_CSUM6_RX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_REMCSUM_TX,
-			!!(vxlan->flags & VXLAN_F_REMCSUM_TX)) ||
+			!!(vxlan->cfg.flags & VXLAN_F_REMCSUM_TX)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_REMCSUM_RX,
-			!!(vxlan->flags & VXLAN_F_REMCSUM_RX)))
+			!!(vxlan->cfg.flags & VXLAN_F_REMCSUM_RX)))
 		goto nla_put_failure;
 
 	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
 		goto nla_put_failure;
 
-	if (vxlan->flags & VXLAN_F_GBP &&
+	if (vxlan->cfg.flags & VXLAN_F_GBP &&
 	    nla_put_flag(skb, IFLA_VXLAN_GBP))
 		goto nla_put_failure;
 
-	if (vxlan->flags & VXLAN_F_GPE &&
+	if (vxlan->cfg.flags & VXLAN_F_GPE &&
 	    nla_put_flag(skb, IFLA_VXLAN_GPE))
 		goto nla_put_failure;
 
-	if (vxlan->flags & VXLAN_F_REMCSUM_NOPARTIAL &&
+	if (vxlan->cfg.flags & VXLAN_F_REMCSUM_NOPARTIAL &&
 	    nla_put_flag(skb, IFLA_VXLAN_REMCSUM_NOPARTIAL))
 		goto nla_put_failure;
 
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 49a59202f85e..479bb75789ea 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -232,7 +232,6 @@ struct vxlan_dev {
 	struct net_device *dev;
 	struct net	  *net;		/* netns for packet i/o */
 	struct vxlan_rdst default_dst;	/* default destination */
-	u32		  flags;	/* VXLAN_F_* in vxlan.h */
 
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 7eb955e453e6..23594d93ad54 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -40,14 +40,14 @@ static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
 		return -EMSGSIZE;
 
-	if (vxlan->flags & VXLAN_F_GBP) {
+	if (vxlan->cfg.flags & VXLAN_F_GBP) {
 		struct nlattr *exts;
 
 		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
 		if (!exts)
 			return -EMSGSIZE;
 
-		if (vxlan->flags & VXLAN_F_GBP &&
+		if (vxlan->cfg.flags & VXLAN_F_GBP &&
 		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
 			return -EMSGSIZE;
 
-- 
2.12.2
