From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Tue, 21 Jul 2015 10:43:58 +0200
Message-ID: <67f2a7c6de2b8829cc41b73a037cf7631c21e483.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40091 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbbGUIo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:28 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allows putting a VXLAN device into a new flow-based mode in which
skbs with a ip_tunnel_info dst metadata attached will be encapsulated
according to the instructions stored in there with the VXLAN device
defaults taken into consideration.

Similar on the receive side, if the VXLAN_F_COLLECT_METADATA flag is
set, the packet processing will populate a ip_tunnel_info struct for
each packet received and attach it to the skb using the new metadata
dst.  The metadata structure will contain the outer header and tunnel
header fields which have been stripped off. Layers further up in the
stack such as routing, tc or netfitler can later match on these fields
and perform forwarding. It is the responsibility of upper layers to
ensure that the flag is set if the metadata is needed. The flag limits
the additional cost of metadata collecting based on demand.

This prepares the VXLAN device to be steered by the routing and other
subsystems which allows to support encapsulation for a large number
of tunnel endpoints and tunnel ids through a single net_device which
improves the scalability.

It also allows for OVS to leverage this mode which in turn allows for
the removal of the OVS specific VXLAN code.

Because the skb is currently scrubed in vxlan_rcv(), the attachment of
the new dst metadata is postponed until after scrubing which requires
the temporary addition of a new member to vxlan_metadata. This member
is removed again in a later commit after the indirect VXLAN receive API
has been removed.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c          | 149 ++++++++++++++++++++++++++++++++++++-------
 include/linux/skbuff.h       |   1 +
 include/net/dst_metadata.h   |  13 ++++
 include/net/ip_tunnels.h     |  14 ++++
 include/net/vxlan.h          |  10 ++-
 include/uapi/linux/if_link.h |   1 +
 6 files changed, 165 insertions(+), 23 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ec86a11..06c092b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -49,6 +49,7 @@
 #include <net/ip6_tunnel.h>
 #include <net/ip6_checksum.h>
 #endif
+#include <net/dst_metadata.h>
 
 #define VXLAN_VERSION	"0.1"
 
@@ -140,6 +141,11 @@ struct vxlan_dev {
 static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
+static inline bool vxlan_collect_metadata(struct vxlan_sock *vs)
+{
+	return vs->flags & VXLAN_F_COLLECT_METADATA;
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
 static inline
 bool vxlan_addr_equal(const union vxlan_addr *a, const union vxlan_addr *b)
@@ -1164,10 +1170,13 @@ static struct vxlanhdr *vxlan_remcsum(struct sk_buff *skb, struct vxlanhdr *vh,
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct metadata_dst *tun_dst = NULL;
+	struct ip_tunnel_info *info;
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
 	u32 flags, vni;
-	struct vxlan_metadata md = {0};
+	struct vxlan_metadata _md;
+	struct vxlan_metadata *md = &_md;
 
 	/* Need Vxlan and inner Ethernet header to be present */
 	if (!pskb_may_pull(skb, VXLAN_HLEN))
@@ -1202,6 +1211,33 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		vni &= VXLAN_VNI_MASK;
 	}
 
+	if (vxlan_collect_metadata(vs)) {
+		const struct iphdr *iph = ip_hdr(skb);
+
+		tun_dst = metadata_dst_alloc(sizeof(*md), GFP_ATOMIC);
+		if (!tun_dst)
+			goto drop;
+
+		info = &tun_dst->u.tun_info;
+		info->key.ipv4_src = iph->saddr;
+		info->key.ipv4_dst = iph->daddr;
+		info->key.ipv4_tos = iph->tos;
+		info->key.ipv4_ttl = iph->ttl;
+		info->key.tp_src = udp_hdr(skb)->source;
+		info->key.tp_dst = udp_hdr(skb)->dest;
+
+		info->mode = IP_TUNNEL_INFO_RX;
+		info->key.tun_flags = TUNNEL_KEY;
+		info->key.tun_id = cpu_to_be64(vni >> 8);
+		if (udp_hdr(skb)->check != 0)
+			info->key.tun_flags |= TUNNEL_CSUM;
+
+		md = ip_tunnel_info_opts(info, sizeof(*md));
+		md->tun_dst = tun_dst;
+	} else {
+		memset(md, 0, sizeof(*md));
+	}
+
 	/* For backwards compatibility, only allow reserved fields to be
 	 * used by VXLAN extensions if explicitly requested.
 	 */
@@ -1209,13 +1245,16 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		struct vxlanhdr_gbp *gbp;
 
 		gbp = (struct vxlanhdr_gbp *)vxh;
-		md.gbp = ntohs(gbp->policy_id);
+		md->gbp = ntohs(gbp->policy_id);
+
+		if (tun_dst)
+			info->key.tun_flags |= TUNNEL_VXLAN_OPT;
 
 		if (gbp->dont_learn)
-			md.gbp |= VXLAN_GBP_DONT_LEARN;
+			md->gbp |= VXLAN_GBP_DONT_LEARN;
 
 		if (gbp->policy_applied)
-			md.gbp |= VXLAN_GBP_POLICY_APPLIED;
+			md->gbp |= VXLAN_GBP_POLICY_APPLIED;
 
 		flags &= ~VXLAN_GBP_USED_BITS;
 	}
@@ -1233,8 +1272,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto bad_flags;
 	}
 
-	md.vni = vxh->vx_vni;
-	vs->rcv(vs, skb, &md);
+	md->vni = vxh->vx_vni;
+	vs->rcv(vs, skb, md);
 	return 0;
 
 drop:
@@ -1247,6 +1286,9 @@ bad_flags:
 		   ntohl(vxh->vx_flags), ntohl(vxh->vx_vni));
 
 error:
+	if (tun_dst)
+		dst_release((struct dst_entry *)tun_dst);
+
 	/* Return non vxlan pkt */
 	return 1;
 }
@@ -1263,7 +1305,12 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
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
@@ -1292,12 +1339,19 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 #endif
 	}
 
+	if (md->tun_dst) {
+		skb_dst_set(skb, (struct dst_entry *)md->tun_dst);
+		md->tun_dst = NULL;
+	}
+
 	if ((vxlan->flags & VXLAN_F_LEARN) &&
 	    vxlan_snoop(skb->dev, &saddr, eth_hdr(skb)->h_source))
 		goto drop;
 
 	skb_reset_network_header(skb);
-	skb->mark = md->gbp;
+	/* In flow-based mode, GBP is carried in dst_metadata */
+	if (!(vs->flags & VXLAN_F_FLOW_BASED))
+		skb->mark = md->gbp;
 
 	if (oip6)
 		err = IP6_ECN_decapsulate(oip6, skb);
@@ -1330,6 +1384,9 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 
 	return;
 drop:
+	if (md->tun_dst)
+		dst_release((struct dst_entry *)md->tun_dst);
+
 	/* Consume bad packet */
 	kfree_skb(skb);
 }
@@ -1878,22 +1935,40 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
+	struct ip_tunnel_info *info = skb_tunnel_info(skb);
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
+		if (!info) {
+			WARN_ONCE(1, "%s: Missing encapsulation instructions\n",
+				  dev->name);
+			goto drop;
+		}
+
+		dst_port = info->key.tp_dst ? : vxlan->dst_port;
+		vni = be64_to_cpu(info->key.tun_id);
+		remote_ip.sin.sin_family = AF_INET;
+		remote_ip.sin.sin_addr.s_addr = info->key.ipv4_dst;
+		dst = &remote_ip;
+	}
 
 	if (vxlan_addr_any(dst)) {
 		if (did_rsc) {
@@ -1918,8 +1993,25 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				     vxlan->port_max, true);
 
 	if (dst->sa.sa_family == AF_INET) {
+		if (info) {
+			if (info->key.tun_flags & TUNNEL_DONT_FRAGMENT)
+				df = htons(IP_DF);
+			if (info->key.tun_flags & TUNNEL_CSUM)
+				flags |= VXLAN_F_UDP_CSUM;
+			else
+				flags &= ~VXLAN_F_UDP_CSUM;
+
+			ttl = info->key.ipv4_ttl;
+			tos = info->key.ipv4_tos;
+
+			if (info->options_len)
+				md = ip_tunnel_info_opts(info, sizeof(*md));
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
@@ -1958,14 +2050,12 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
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
@@ -1980,7 +2070,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		u32 flags;
 
 		memset(&fl6, 0, sizeof(fl6));
-		fl6.flowi6_oif = rdst->remote_ifindex;
+		fl6.flowi6_oif = rdst ? rdst->remote_ifindex : 0;
 		fl6.daddr = dst->sin6.sin6_addr;
 		fl6.saddr = vxlan->saddr.sin6.sin6_addr;
 		fl6.flowi6_mark = skb->mark;
@@ -2018,11 +2108,11 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
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
@@ -2051,6 +2141,7 @@ tx_free:
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
+	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	struct ethhdr *eth;
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst, *fdst = NULL;
@@ -2078,6 +2169,12 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 	}
 
+	if (vxlan->flags & VXLAN_F_FLOW_BASED &&
+	    info && info->mode == IP_TUNNEL_INFO_TX) {
+		vxlan_xmit_one(skb, dev, NULL, false);
+		return NETDEV_TX_OK;
+	}
+
 	f = vxlan_find_mac(vxlan, eth->h_dest);
 	did_rsc = false;
 
@@ -2405,6 +2502,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_FLOWBASED]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_PORT]	= { .type = NLA_U16 },
 	[IFLA_VXLAN_UDP_CSUM]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
@@ -2681,6 +2779,10 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_LIMIT])
 		vxlan->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
+	if (data[IFLA_VXLAN_FLOWBASED] &&
+	    nla_get_u8(data[IFLA_VXLAN_FLOWBASED]))
+		vxlan->flags |= VXLAN_F_FLOW_BASED;
+
 	if (data[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *p
 			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
@@ -2777,6 +2879,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_RSC */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L2MISS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_L3MISS */
+		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_FLOWBASED */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
@@ -2843,6 +2946,8 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			!!(vxlan->flags & VXLAN_F_L2MISS)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_L3MISS,
 			!!(vxlan->flags & VXLAN_F_L3MISS)) ||
+	    nla_put_u8(skb, IFLA_VXLAN_FLOWBASED,
+		       !!(vxlan->flags & VXLAN_F_FLOW_BASED)) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax) ||
 	    nla_put_be16(skb, IFLA_VXLAN_PORT, vxlan->dst_port) ||
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6bd96fe..648a2c2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3469,5 +3469,6 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
 			       skb_network_header(skb);
 	return hdr_len + skb_gso_transport_seglen(skb);
 }
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 4f7694f..e843937 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -8,6 +8,9 @@
 struct metadata_dst {
 	struct dst_entry		dst;
 	size_t				opts_len;
+	union {
+		struct ip_tunnel_info	tun_info;
+	} u;
 };
 
 static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
@@ -20,6 +23,16 @@ static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
 	return NULL;
 }
 
+static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
+{
+	struct metadata_dst *md_dst = skb_metadata_dst(skb);
+
+	if (md_dst)
+		return &md_dst->u.tun_info;
+
+	return NULL;
+}
+
 static inline bool skb_valid_dst(const struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 6b9d559..d11530f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -38,10 +38,19 @@ struct ip_tunnel_key {
 	__be16			tp_dst;
 } __packed __aligned(4); /* Minimize padding. */
 
+/* Indicates whether the tunnel info structure represents receive
+ * or transmit tunnel parameters.
+ */
+enum {
+	IP_TUNNEL_INFO_RX,
+	IP_TUNNEL_INFO_TX,
+};
+
 struct ip_tunnel_info {
 	struct ip_tunnel_key	key;
 	const void		*options;
 	u8			options_len;
+	u8			mode;
 };
 
 /* 6rd prefix/relay information */
@@ -284,6 +293,11 @@ static inline void iptunnel_xmit_stats(int err,
 	}
 }
 
+static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info, size_t n)
+{
+	return info + 1;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0082b5d..80a2da2 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -7,6 +7,7 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/udp.h>
+#include <net/dst_metadata.h>
 
 #define VNI_HASH_BITS	10
 #define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
@@ -97,6 +98,9 @@ struct vxlanhdr {
 struct vxlan_metadata {
 	__be32		vni;
 	u32		gbp;
+
+	/* Temporary until vxlan_rcv() API is gone */
+	struct metadata_dst *tun_dst;
 };
 
 struct vxlan_sock;
@@ -130,6 +134,8 @@ struct vxlan_sock {
 #define VXLAN_F_REMCSUM_RX		0x400
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
+#define VXLAN_F_COLLECT_METADATA	0x2000
+#define VXLAN_F_FLOW_BASED		0x4000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -137,7 +143,9 @@ struct vxlan_sock {
 #define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
 					 VXLAN_F_REMCSUM_RX |		\
-					 VXLAN_F_REMCSUM_NOPARTIAL)
+					 VXLAN_F_REMCSUM_NOPARTIAL |	\
+					 VXLAN_F_COLLECT_METADATA |	\
+					 VXLAN_F_FLOW_BASED)
 
 struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 				  vxlan_rcv_t *rcv, void *data,
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 24d68b7..9eeb5d9 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -382,6 +382,7 @@ enum {
 	IFLA_VXLAN_REMCSUM_RX,
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
+	IFLA_VXLAN_FLOWBASED,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
2.4.3
