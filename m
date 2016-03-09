From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] vxlan: support setting IPv6 flow label
Date: Wed,  9 Mar 2016 03:00:03 +0100
Message-ID: <7775042611e823098fd14d2929fb6b12cc0b3f98.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45221 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbcCICAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:00:10 -0500
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds support for setting the IPv6 flow label for vxlan per
device and through collect metadata (ip_tunnel_key) frontends. The
vxlan dst cache does not need any special considerations here, for
the cases where caches can be used, the label is static per cache.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/vxlan.c          | 26 +++++++++++++++++++++-----
 include/net/vxlan.h          |  1 +
 include/uapi/linux/if_link.h |  1 +
 3 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8bdcd5e..8eda76f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1790,6 +1790,7 @@ static struct rtable *vxlan_get_route(struct vxlan_dev *vxlan,
 #if IS_ENABLED(CONFIG_IPV6)
 static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 					  struct sk_buff *skb, int oif, u8 tos,
+					  __be32 label,
 					  const struct in6_addr *daddr,
 					  struct in6_addr *saddr,
 					  struct dst_cache *dst_cache,
@@ -1813,6 +1814,7 @@ static struct dst_entry *vxlan6_get_route(struct vxlan_dev *vxlan,
 	fl6.flowi6_tos = RT_TOS(tos);
 	fl6.daddr = *daddr;
 	fl6.saddr = vxlan->cfg.saddr.sin6.sin6_addr;
+	fl6.flowlabel = label;
 	fl6.flowi6_mark = skb->mark;
 	fl6.flowi6_proto = IPPROTO_UDP;
 
@@ -1888,7 +1890,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	struct vxlan_metadata _md;
 	struct vxlan_metadata *md = &_md;
 	__be16 src_port = 0, dst_port;
-	__be32 vni;
+	__be32 vni, label;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
@@ -1939,12 +1941,14 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	if (tos == 1)
 		tos = ip_tunnel_get_dsfield(old_iph, skb);
 
+	label = vxlan->cfg.label;
 	src_port = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
 				     vxlan->cfg.port_max, true);
 
 	if (info) {
 		ttl = info->key.ttl;
 		tos = info->key.tos;
+		label = info->key.label;
 		udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
 
 		if (info->options_len)
@@ -2020,7 +2024,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		ndst = vxlan6_get_route(vxlan, skb,
 					rdst ? rdst->remote_ifindex : 0, tos,
-					&dst->sin6.sin6_addr, &saddr,
+					label, &dst->sin6.sin6_addr, &saddr,
 					dst_cache, info);
 		if (IS_ERR(ndst)) {
 			netdev_dbg(dev, "no route to %pI6\n",
@@ -2066,8 +2070,8 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			return;
 		}
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
-				     &saddr, &dst->sin6.sin6_addr, tos, ttl, 0,
-				     src_port, dst_port, !udp_sum);
+				     &saddr, &dst->sin6.sin6_addr, tos, ttl,
+				     label, src_port, dst_port, !udp_sum);
 #endif
 	}
 
@@ -2390,7 +2394,7 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 		if (!vxlan->vn6_sock)
 			return -EINVAL;
 		ndst = vxlan6_get_route(vxlan, skb, 0, info->key.tos,
-					&info->key.u.ipv6.dst,
+					info->key.label, &info->key.u.ipv6.dst,
 					&info->key.u.ipv6.src, NULL, info);
 		if (IS_ERR(ndst))
 			return PTR_ERR(ndst);
@@ -2505,6 +2509,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_LOCAL6]	= { .len = sizeof(struct in6_addr) },
 	[IFLA_VXLAN_TOS]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_TTL]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_LABEL]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_AGEING]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LIMIT]	= { .type = NLA_U32 },
@@ -2739,6 +2744,11 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		vxlan->flags |= VXLAN_F_IPV6;
 	}
 
+	if (conf->label && !use_ipv6) {
+		pr_info("label only supported in use with IPv6\n");
+		return -EINVAL;
+	}
+
 	if (conf->remote_ifindex) {
 		lowerdev = __dev_get_by_index(src_net, conf->remote_ifindex);
 		dst->remote_ifindex = conf->remote_ifindex;
@@ -2887,6 +2897,10 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_TTL])
 		conf.ttl = nla_get_u8(data[IFLA_VXLAN_TTL]);
 
+	if (data[IFLA_VXLAN_LABEL])
+		conf.label = nla_get_be32(data[IFLA_VXLAN_LABEL]) &
+			     IPV6_FLOWLABEL_MASK;
+
 	if (!data[IFLA_VXLAN_LEARNING] || nla_get_u8(data[IFLA_VXLAN_LEARNING]))
 		conf.flags |= VXLAN_F_LEARN;
 
@@ -2990,6 +3004,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_LOCAL{6} */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
+		nla_total_size(sizeof(__be32)) + /* IFLA_VXLAN_LABEL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_PROXY */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_RSC */
@@ -3053,6 +3068,7 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->cfg.ttl) ||
 	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->cfg.tos) ||
+	    nla_put_be32(skb, IFLA_VXLAN_LABEL, vxlan->cfg.label) ||
 	    nla_put_u8(skb, IFLA_VXLAN_LEARNING,
 			!!(vxlan->flags & VXLAN_F_LEARN)) ||
 	    nla_put_u8(skb, IFLA_VXLAN_PROXY,
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 6eda4ed..a763c96 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -162,6 +162,7 @@ struct vxlan_config {
 	u16			port_max;
 	u8			tos;
 	u8			ttl;
+	__be32			label;
 	u32			flags;
 	unsigned long		age_interval;
 	unsigned int		addrmax;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d452cea..6bebc97 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -456,6 +456,7 @@ enum {
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_COLLECT_METADATA,
+	IFLA_VXLAN_LABEL,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
-- 
1.9.3
