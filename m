From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Subject: [PATCH net-next v3 2/6] vxlan: get rid of redundant
	vxlan_dev.flags
Date: Mon, 19 Jun 2017 10:03:56 +0200
Message-ID: <0cbe59e93d13ca0934177b9e6417224297bb0ecd.1497825555.git.mschiffer@universe-factory.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	pshelar-LZ6Gd1LRuIk@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
In-Reply-To: <cover.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
References: <cover.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no good reason to keep the flags twice in vxlan_dev and
vxlan_config.

Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
---

Notes:
    v2: new patch
    v3: rebase

 drivers/net/vxlan.c           | 76 +++++++++++++++++++++----------------------
 include/net/vxlan.h           |  1 -
 net/openvswitch/vport-vxlan.c |  4 +--
 3 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9139f15a2ec1..b4fce3b29647 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -305,7 +305,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	if (rdst->remote_vni != vxlan->default_dst.remote_vni &&
 	    nla_put_u32(skb, NDA_VNI, be32_to_cpu(rdst->remote_vni)))
 		goto nla_put_failure;
-	if ((vxlan->flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
+	if ((vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) && fdb->vni &&
 	    nla_put_u32(skb, NDA_SRC_VNI,
 			be32_to_cpu(fdb->vni)))
 		goto nla_put_failure;
@@ -419,7 +419,7 @@ static u32 eth_vni_hash(const unsigned char *addr, __be32 vni)
 static inline struct hlist_head *vxlan_fdb_head(struct vxlan_dev *vxlan,
 						const u8 *mac, __be32 vni)
 {
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA)
+	if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA)
 		return &vxlan->fdb_head[eth_vni_hash(mac, vni)];
 	else
 		return &vxlan->fdb_head[eth_hash(mac)];
@@ -434,7 +434,7 @@ static struct vxlan_fdb *__vxlan_find_mac(struct vxlan_dev *vxlan,
 
 	hlist_for_each_entry_rcu(f, head, hlist) {
 		if (ether_addr_equal(mac, f->eth_addr)) {
-			if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+			if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) {
 				if (vni == f->vni)
 					return f;
 			} else {
@@ -1284,7 +1284,7 @@ static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 #endif
 	}
 
-	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	if ((vxlan->cfg.flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source, vni))
 		return false;
 
@@ -1507,7 +1507,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
-	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+	} else if (vxlan->cfg.flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin.sin_addr.s_addr = tip,
 			.sin.sin_family = AF_INET,
@@ -1665,7 +1665,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 		if (netif_rx_ni(reply) == NET_RX_DROP)
 			dev->stats.rx_dropped++;
 
-	} else if (vxlan->flags & VXLAN_F_L3MISS) {
+	} else if (vxlan->cfg.flags & VXLAN_F_L3MISS) {
 		union vxlan_addr ipa = {
 			.sin6.sin6_addr = msg->target,
 			.sin6.sin6_family = AF_INET6,
@@ -1698,7 +1698,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip = ip_hdr(skb);
 		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
-		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
+		if (!n && (vxlan->cfg.flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin.sin_addr.s_addr = pip->daddr,
 				.sin.sin_family = AF_INET,
@@ -1719,7 +1719,7 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
 			return false;
 		pip6 = ipv6_hdr(skb);
 		n = neigh_lookup(ipv6_stub->nd_tbl, &pip6->daddr, dev);
-		if (!n && (vxlan->flags & VXLAN_F_L3MISS)) {
+		if (!n && (vxlan->cfg.flags & VXLAN_F_L3MISS)) {
 			union vxlan_addr ipa = {
 				.sin6.sin6_addr = pip6->daddr,
 				.sin6.sin6_family = AF_INET6,
@@ -1993,7 +1993,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 #endif
 	}
 
-	if (dst_vxlan->flags & VXLAN_F_LEARN)
+	if (dst_vxlan->cfg.flags & VXLAN_F_LEARN)
 		vxlan_snoop(skb->dev, &loopback, eth_hdr(skb)->h_source, vni);
 
 	u64_stats_update_begin(&tx_stats->syncp);
@@ -2031,7 +2031,7 @@ static int encap_bypass_if_local(struct sk_buff *skb, struct net_device *dev,
 		dst_release(dst);
 		dst_vxlan = vxlan_find_vni(vxlan->net, vni,
 					   daddr->sa.sa_family, dst_port,
-					   vxlan->flags);
+					   vxlan->cfg.flags);
 		if (!dst_vxlan) {
 			dev->stats.tx_errors++;
 			kfree_skb(skb);
@@ -2062,7 +2062,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	__be32 vni, label;
 	__u8 tos, ttl;
 	int err;
-	u32 flags = vxlan->flags;
+	u32 flags = vxlan->cfg.flags;
 	bool udp_sum = false;
 	bool xnet = !net_eq(vxlan->net, dev_net(vxlan->dev));
 
@@ -2244,7 +2244,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_reset_mac_header(skb);
 
-	if (vxlan->flags & VXLAN_F_COLLECT_METADATA) {
+	if (vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA) {
 		if (info && info->mode & IP_TUNNEL_INFO_BRIDGE &&
 		    info->mode & IP_TUNNEL_INFO_TX) {
 			vni = tunnel_id_to_key32(info->key.tun_id);
@@ -2257,7 +2257,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	if (vxlan->flags & VXLAN_F_PROXY) {
+	if (vxlan->cfg.flags & VXLAN_F_PROXY) {
 		eth = eth_hdr(skb);
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
 			return arp_reduce(dev, skb, vni);
@@ -2277,7 +2277,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	f = vxlan_find_mac(vxlan, eth->h_dest, vni);
 	did_rsc = false;
 
-	if (f && (f->flags & NTF_ROUTER) && (vxlan->flags & VXLAN_F_RSC) &&
+	if (f && (f->flags & NTF_ROUTER) && (vxlan->cfg.flags & VXLAN_F_RSC) &&
 	    (ntohs(eth->h_proto) == ETH_P_IP ||
 	     ntohs(eth->h_proto) == ETH_P_IPV6)) {
 		did_rsc = route_shortcircuit(dev, skb);
@@ -2288,7 +2288,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (f == NULL) {
 		f = vxlan_find_mac(vxlan, all_zeros_mac, vni);
 		if (f == NULL) {
-			if ((vxlan->flags & VXLAN_F_L2MISS) &&
+			if ((vxlan->cfg.flags & VXLAN_F_L2MISS) &&
 			    !is_multicast_ether_addr(eth->h_dest))
 				vxlan_fdb_miss(vxlan, eth->h_dest);
 
@@ -2832,7 +2832,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 	if (!vxlan->cfg.no_share) {
 		spin_lock(&vn->sock_lock);
 		vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
-				     vxlan->cfg.dst_port, vxlan->flags);
+				     vxlan->cfg.dst_port, vxlan->cfg.flags);
 		if (vs && !atomic_add_unless(&vs->refcnt, 1, 0)) {
 			spin_unlock(&vn->sock_lock);
 			return -EBUSY;
@@ -2841,7 +2841,7 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 	}
 	if (!vs)
 		vs = vxlan_socket_create(vxlan->net, ipv6,
-					 vxlan->cfg.dst_port, vxlan->flags);
+					 vxlan->cfg.dst_port, vxlan->cfg.flags);
 	if (IS_ERR(vs))
 		return PTR_ERR(vs);
 #if IS_ENABLED(CONFIG_IPV6)
@@ -2856,8 +2856,8 @@ static int __vxlan_sock_add(struct vxlan_dev *vxlan, bool ipv6)
 
 static int vxlan_sock_add(struct vxlan_dev *vxlan)
 {
-	bool metadata = vxlan->flags & VXLAN_F_COLLECT_METADATA;
-	bool ipv6 = vxlan->flags & VXLAN_F_IPV6 || metadata;
+	bool metadata = vxlan->cfg.flags & VXLAN_F_COLLECT_METADATA;
+	bool ipv6 = vxlan->cfg.flags & VXLAN_F_IPV6 || metadata;
 	bool ipv4 = !ipv6 || metadata;
 	int ret = 0;
 
@@ -2952,7 +2952,7 @@ static int vxlan_config_validate(struct net *src_net, struct vxlan_config *conf,
 		    (tmp->default_dst.remote_ip.sa.sa_family == AF_INET6 ||
 		     tmp->cfg.saddr.sa.sa_family == AF_INET6) == use_ipv6 &&
 		    tmp->cfg.dst_port == conf->dst_port &&
-		    (tmp->flags & VXLAN_F_RCV_FLAGS) ==
+		    (tmp->cfg.flags & VXLAN_F_RCV_FLAGS) ==
 		    (conf->flags & VXLAN_F_RCV_FLAGS))
 			return -EEXIST;
 	}
@@ -3006,7 +3006,6 @@ static void vxlan_config_apply(struct net_device *dev,
 	dev->needed_headroom = needed_headroom;
 
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
-	vxlan->flags |= conf->flags;
 }
 
 static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
@@ -3120,12 +3119,10 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
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
@@ -3408,43 +3405,44 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
index 869acb3b3d3f..7e6301b2ec4d 100644
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
2.13.1
