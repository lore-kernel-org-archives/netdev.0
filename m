From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 03/14] vxlan: Flow based tunneling
Date: Mon,  1 Jun 2015 16:27:27 +0200
Message-ID: <14e13ae66c2c38a13235b695e1f9180d2f4e6395.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50933 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbFAO1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:48 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows putting a VXLAN device into a new flow-based mode in which it
will populate a tunnel info structure for each packet received. The
metadata structure will contain the outer header and tunnel header
fields which have been stripped off. Layers further up in the stack
such as routing, tc or netfitler can later match on these fields.

On the transmit side, it allows skbs to carry their own encapsulation
instructions thus allowing encapsulations parameters to be set per
flow/route.

This prepares the VXLAN device to be steered by the routing subsystem
which will allow to support encapsulation for a large number of tunnel
endpoints and tunnel ids through a single net_device which improves
the scalability of current VXLAN tunnels.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c          | 147 ++++++++++++++++++++++++++++++++++++-------
 include/linux/skbuff.h       |   1 +
 include/net/ip_tunnels.h     |   8 +++
 include/net/route.h          |   8 +++
 include/net/vxlan.h          |   4 +-
 include/uapi/linux/if_link.h |   1 +
 6 files changed, 146 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34c519e..d5edba5 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1164,10 +1164,12 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct ip_tunnel_info *tun_info = NULL;
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
 	u32 flags, vni;
-	struct vxlan_metadata md = {0};
+	struct vxlan_metadata _md;
+	struct vxlan_metadata *md = &_md;
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1202,6 +1204,33 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		vni &= VXLAN_VNI_MASK;
 	}
 
+	if (vs->flags & VXLAN_F_FLOW_BASED) {
+		const struct iphdr *iph = ip_hdr(skb);
+
+		/* TODO: Consider optimizing by looking up in flow cache */
+		tun_info = ip_tunnel_info_alloc(sizeof(*md), GFP_ATOMIC);
+		if (!tun_info)
+			goto drop;
+
+		tun_info->key.ipv4_src = iph->saddr;
+		tun_info->key.ipv4_dst = iph->daddr;
+		tun_info->key.ipv4_tos = iph->tos;
+		tun_info->key.ipv4_ttl = iph->ttl;
+		tun_info->key.tp_src = udp_hdr(skb)->source;
+		tun_info->key.tp_dst = udp_hdr(skb)->dest;
+
+		tun_info->mode = IP_TUNNEL_INFO_RX;
+		tun_info->key.tun_flags = TUNNEL_KEY;
+		tun_info->key.tun_id = cpu_to_be64(vni >> 8);
+		if (udp_hdr(skb)->check != 0)
+			tun_info->key.tun_flags |= TUNNEL_CSUM;
+
+		md = ip_tunnel_info_opts(tun_info, sizeof(*md));
+		skb_attach_tunnel_info(skb, tun_info);
+	} else {
+		memset(md, 0, sizeof(*md));
+	}
+
 	/* For backwards compatibility, only allow reserved fields to be
 	 * used by VXLAN extensions if explicitly requested.
 	 */
@@ -1209,13 +1238,16 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		struct vxlanhdr_gbp *gbp;
 
 		gbp = (struct vxlanhdr_gbp *)vxh;
-		md.gbp = ntohs(gbp->policy_id);
+		md->gbp = ntohs(gbp->policy_id);
+
+		if (tun_info)
+			tun_info->key.tun_flags |= TUNNEL_VXLAN_OPT;
 
 		if (gbp->dont_learn)
-			md.gbp |= VXLAN_GBP_DONT_LEARN;
+			md->gbp |= VXLAN_GBP_DONT_LEARN;
 
 		if (gbp->policy_applied)
-			md.gbp |= VXLAN_GBP_POLICY_APPLIED;
+			md->gbp |= VXLAN_GBP_POLICY_APPLIED;
 
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
@@ -1233,8 +1265,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	md.vni = vxh->vx_vni;
-	vs->rcv(vs, skb, &md);
+	md->vni = vxh->vx_vni;
+	vs->rcv(vs, skb, md);
 	return 0;
 
 drop:
@@ -1254,6 +1286,7 @@ error:
 static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		      struct vxlan_metadata *md)
 {
+	struct ip_tunnel_info *tun_info = skb_shinfo(skb)->tun_info;
 	struct iphdr *oip = NULL;
 	struct ipv6hdr *oip6 = NULL;
 	struct vxlan_dev *vxlan;
@@ -1263,7 +1296,12 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	int err = 0;
 	union vxlan_addr *remote_ip;
 
-	vni = ntohl(md->vni) >> 8;
+	/* For flow based devices, map all packets to VNI 0 */
+	if (vs->flags & VXLAN_F_FLOW_BASED)
+		vni = 0;
+	else
+		vni = ntohl(md->vni) >> 8;
+
 	/* Is this VNI defined? */
 	vxlan = vxlan_vs_find_vni(vs, vni);
 	if (!vxlan)
@@ -1284,11 +1322,20 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		oip = ip_hdr(skb);
 		saddr.sin.sin_addr.s_addr = oip->saddr;
 		saddr.sa.sa_family = AF_INET;
+
+		if (tun_info) {
+			tun_info->key.ipv4_src = oip->saddr;
+			tun_info->key.ipv4_dst = oip->daddr;
+			tun_info->key.ipv4_tos = oip->tos;
+			tun_info->key.ipv4_ttl = oip->ttl;
+		}
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		oip6 = ipv6_hdr(skb);
 		saddr.sin6.sin6_addr = oip6->saddr;
 		saddr.sa.sa_family = AF_INET6;
+
+		/* TODO : Fill IPv6 tunnel info */
 #endif
 	}
 
@@ -1297,7 +1344,8 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		goto drop;
 
 	skb_reset_network_header(skb);
-	skb->mark = md->gbp;
+	if (!(vs->flags & VXLAN_F_FLOW_BASED))
+		skb->mark = md->gbp;
 
 	if (oip6)
 		err = IP6_ECN_decapsulate(oip6, skb);
@@ -1875,25 +1923,44 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	}
 }
 
+/* If called with rdst=NULL, use tun_info instructions */
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
+	struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct rtable *rt = NULL;
 	const struct iphdr *old_iph;
 	struct flowi4 fl4;
 	union vxlan_addr *dst;
-	struct vxlan_metadata md;
+	union vxlan_addr remote_ip;
+	struct vxlan_metadata _md;
+	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
 	u32 vni;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
+	u32 flags = vxlan->flags;
 
-	dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
-	vni = rdst->remote_vni;
-	dst = &rdst->remote_ip;
+	if (rdst) {
+		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
+		vni = rdst->remote_vni;
+		dst = &rdst->remote_ip;
+	} else {
+		if (!tun_info) {
+			WARN_ONCE(1, "%s: Packet transmission with tunnel information\n",
+				  dev->name);
+			goto drop;
+		}
+
+		dst_port = tun_info->key.tp_dst ? : vxlan->dst_port;
+		vni = be64_to_cpu(tun_info->key.tun_id);
+		remote_ip.sin.sin_family = AF_INET;
+		remote_ip.sin.sin_addr.s_addr = tun_info->key.ipv4_dst;
+		dst = &remote_ip;
+	}
 
 	if (vxlan_addr_any(dst)) {
 		if (did_rsc) {
@@ -1918,8 +1985,25 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     vxlan->port_max, true);
 
 	if (dst->sa.sa_family == AF_INET) {
+		if (tun_info) {
+			if (tun_info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
+				df = htons(IP_DF);
+			if (tun_info->key.tun_flags & TUNNEL_CSUM)
+				flags |= VXLAN_F_UDP_CSUM;
+			else
+				flags &= ~VXLAN_F_UDP_CSUM;
+
+			ttl = tun_info->key.ipv4_ttl;
+			tos = tun_info->key.ipv4_tos;
+
+			if (tun_info->options_len)
+				md = ip_tunnel_info_opts(tun_info, sizeof(*md));
+		} else {
+			md->gbp = skb->mark;
+		}
+
 		memset(&fl4, 0, sizeof(fl4));
-		fl4.flowi4_oif = rdst->remote_ifindex;
+		fl4.flowi4_oif = rdst ? rdst->remote_ifindex : 0;
 		fl4.flowi4_tos = RT_TOS(tos);
 		fl4.flowi4_mark = skb->mark;
 		fl4.flowi4_proto = IPPROTO_UDP;
@@ -1958,14 +2042,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
 		ttl = ttl ? : ip4_dst_hoplimit(&rt->dst);
-		md.vni = htonl(vni << 8);
-		md.gbp = skb->mark;
-
+		md->vni = htonl(vni << 8);
 		err = vxlan_xmit_skb(rt, sk, skb, fl4.saddr,
 				     dst->sin.sin_addr.s_addr, tos, ttl, df,
-				     src_port, dst_port, &md,
+				     src_port, dst_port, md,
 				     !net_eq(vxlan->net, dev_net(vxlan->dev)),
-				     vxlan->flags);
+				     flags);
 		if (err < 0) {
 			/* skb is already freed. */
 			skb = NULL;
@@ -1980,7 +2062,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		u32 flags;
 
 		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_oif = rdst->remote_ifindex;
+		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
 		fl6.daddr = dst->sin6.sin6_addr;
 		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
 		fl6.flowi6_mark = skb->mark;
@@ -2018,11 +2100,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		ttl = ttl ? : ip6_dst_hoplimit(ndst);
-		md.vni = htonl(vni << 8);
-		md.gbp = skb->mark;
+		md->vni = htonl(vni << 8);
+		md->gbp = skb->mark;
 
 		err = vxlan6_xmit_skb(ndst, sk, skb, dev, &fl6.saddr, &fl6.daddr,
-				      0, ttl, src_port, dst_port, &md,
+				      0, ttl, src_port, dst_port, md,
 				      !net_eq(vxlan->net, dev_net(vxlan->dev)),
 				      vxlan->flags);
 #endif
@@ -2051,6 +2133,7 @@ tx_free:
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	const struct ip_tunnel_info *tun_info = skb_tunnel_info(skb);
 	struct ethhdr *eth;
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst, *fdst = NULL;
@@ -2078,6 +2161,13 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	}
 
+	if (vxlan->flags & VXLAN_F_FLOW_BASED &&
+	    tun_info && tun_info->key.ipv4_dst &&
+	    tun_info->mode == IP_TUNNEL_INFO_TX) {
+		vxlan_xmit_one(skb, dev, NULL, false);
+		return NETDEV_TX_OK;
+	}
+
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;
 
@@ -2373,6 +2463,12 @@ static void vxlan_setup(struct net_device *dev)
 	netif_keep_dst(dev);
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
+	/* If in flow based mode, keep the dst including encapsulation
+	 * instructions for vxlan_xmit().
+	 */
+	if (vxlan->flags & VXLAN_F_FLOW_BASED)
+		netif_keep_dst(dev);
+
 	INIT_LIST_HEAD(&vxlan->next);
 	spin_lock_init(&vxlan->hash_lock);
 
@@ -2405,6 +2501,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_FLOWBASED]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
@@ -2681,6 +2778,9 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_LIMIT])
 		vxlan->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
+	if (data[IFLA_VXLAN_FLOWBASED] && nla_get_u8(data[IFLA_VXLAN_FLOWBASED]))
+		vxlan->flags |= VXLAN_F_FLOW_BASED;
+
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *p
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
@@ -2777,6 +2877,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_RSC */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L2MISS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L3MISS */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_FLOWBASED */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
@@ -2843,6 +2944,8 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			!!(vxlan->flags & VXLAN_F_L2MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_FLOWBASED,
+			!!(vxlan->flags & VXLAN_F_FLOW_BASED)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
 	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port) ||
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 83f9a59..6286b05 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3463,5 +3463,6 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
 			       skb_network_header(skb);
 	return hdr_len + skb_gso_transport_seglen(skb);
 }
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 3968705..8b76ba1 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -329,6 +329,14 @@ static inline void skb_release_tunnel_info(struct sk_buff *skb)
 	skb_shinfo(skb)->tun_info = NULL;
 }
 
+static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info,
+					size_t expect_len)
+{
+	WARN_ON(info->options_len != expect_len);
+
+	return info + 1;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03..6ede321 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -315,4 +315,12 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 	return hoplimit;
 }
 
+static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
+{
+	if (skb_shinfo(skb)->tun_info)
+		return skb_shinfo(skb)->tun_info;
+
+	return NULL;
+}
+
 #endif	/* _ROUTE_H */
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0082b5d..4e73df5 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -130,6 +130,7 @@ struct vxlan_sock {
 #define VXLAN_F_REMCSUM_RX		0x400
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
+#define VXLAN_F_FLOW_BASED		0x2000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -137,7 +138,8 @@ struct vxlan_sock {
 #define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
 					 VXLAN_F_REMCSUM_RX |		\
-					 VXLAN_F_REMCSUM_NOPARTIAL)
+					 VXLAN_F_REMCSUM_NOPARTIAL |	\
+					 VXLAN_F_FLOW_BASED)
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index afccc93..374df97 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -381,6 +381,7 @@ enum {
 	IFLA_VXLAN_REMCSUM_RX,
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
+	IFLA_VXLAN_FLOWBASED,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.3.5
