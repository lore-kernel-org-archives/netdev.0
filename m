From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 16/22] route: Per route IP tunnel metadata via lightweight tunnel
Date: Fri, 17 Jul 2015 14:55:35 +0200
Message-ID: <8f6d80b8479e4af7eb3ba1f73e65f41df228c96d.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
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
Received: from casper.infradead.org ([85.118.1.10]:49631 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758016AbbGQM4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 08:56:05 -0400
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
In-Reply-To: <cover.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces a new IP tunnel lightweight tunnel type which allows
to specify IP tunnel instructions per route. Only IPv4 is supported
at this point.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c            |  10 +++-
 include/net/dst_metadata.h     |  12 ++++-
 include/net/ip_tunnels.h       |   7 ++-
 include/uapi/linux/lwtunnel.h  |   1 +
 include/uapi/linux/rtnetlink.h |  15 ++++++
 net/ipv4/ip_tunnel_core.c      | 114 +++++++++++++++++++++++++++++++++++++++++
 net/ipv4/route.c               |   2 +-
 net/openvswitch/vport.h        |   1 +
 8 files changed, 157 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 994d89c..a350afb 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1935,7 +1935,7 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 			   struct vxlan_rdst *rdst, bool did_rsc)
 {
-	struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	struct ip_tunnel_info *info;
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct sock *sk = vxlan->vn_sock->sock->sk;
 	struct rtable *rt = NULL;
@@ -1952,6 +1952,9 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 	int err;
 	u32 flags = vxlan->flags;
 
+	/* FIXME: Support IPv6 */
+	info = skb_tunnel_info(skb, AF_INET);
+
 	if (rdst) {
 		dst_port = rdst->remote_port ? rdst->remote_port : vxlan->dst_port;
 		vni = rdst->remote_vni;
@@ -2141,12 +2144,15 @@ tx_free:
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	const struct ip_tunnel_info *info;
 	struct ethhdr *eth;
 	bool did_rsc = false;
 	struct vxlan_rdst *rdst, *fdst = NULL;
 	struct vxlan_fdb *f;
 
+	/* FIXME: Support IPv6 */
+	info = skb_tunnel_info(skb, AF_INET);
+
 	skb_reset_mac_header(skb);
 	eth = eth_hdr(skb);
 
diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index e843937..7b03068 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -23,13 +23,23 @@ static inline struct metadata_dst *skb_metadata_dst(struct sk_buff *skb)
 	return NULL;
 }
 
-static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
+static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb,
+						     int family)
 {
 	struct metadata_dst *md_dst = skb_metadata_dst(skb);
+	struct rtable *rt;
 
 	if (md_dst)
 		return &md_dst->u.tun_info;
 
+	switch (family) {
+	case AF_INET:
+		rt = (struct rtable *)skb_dst(skb);
+		if (rt && rt->rt_lwtstate)
+			return lwt_tun_info(rt->rt_lwtstate);
+		break;
+	}
+
 	return NULL;
 }
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d11530f..0b7e18c 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -9,9 +9,9 @@
 #include <net/dsfield.h>
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
-#include <net/ip.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/lwtunnel.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -298,6 +298,11 @@ static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info, size_t n)
 	return info + 1;
 }
 
+static inline struct ip_tunnel_info *lwt_tun_info(struct lwtunnel_state *lwtstate)
+{
+	return (struct ip_tunnel_info *)lwtstate->data;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index aa611d9..31377bb 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -6,6 +6,7 @@
 enum lwtunnel_encap_types {
 	LWTUNNEL_ENCAP_NONE,
 	LWTUNNEL_ENCAP_MPLS,
+	LWTUNNEL_ENCAP_IP,
 	__LWTUNNEL_ENCAP_MAX,
 };
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 0d3d3cc..47d24cb 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -286,6 +286,21 @@ enum rt_class_t {
 
 /* Routing message attributes */
 
+enum ip_tunnel_t {
+	IP_TUN_UNSPEC,
+	IP_TUN_ID,
+	IP_TUN_DST,
+	IP_TUN_SRC,
+	IP_TUN_TTL,
+	IP_TUN_TOS,
+	IP_TUN_SPORT,
+	IP_TUN_DPORT,
+	IP_TUN_FLAGS,
+	__IP_TUN_MAX,
+};
+
+#define IP_TUN_MAX (__IP_TUN_MAX - 1)
+
 enum rtattr_type_t {
 	RTA_UNSPEC,
 	RTA_DST,
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6a51a71..025b76e 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -190,3 +190,117 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 	return tot;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_get_stats64);
+
+static const struct nla_policy ip_tun_policy[IP_TUN_MAX + 1] = {
+	[IP_TUN_ID]		= { .type = NLA_U64 },
+	[IP_TUN_DST]		= { .type = NLA_U32 },
+	[IP_TUN_SRC]		= { .type = NLA_U32 },
+	[IP_TUN_TTL]		= { .type = NLA_U8 },
+	[IP_TUN_TOS]		= { .type = NLA_U8 },
+	[IP_TUN_SPORT]		= { .type = NLA_U16 },
+	[IP_TUN_DPORT]		= { .type = NLA_U16 },
+	[IP_TUN_FLAGS]		= { .type = NLA_U16 },
+};
+
+static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
+			      struct lwtunnel_state **ts)
+{
+	struct ip_tunnel_info *tun_info;
+	struct lwtunnel_state *new_state;
+	struct nlattr *tb[IP_TUN_MAX + 1];
+	int err;
+
+	err = nla_parse_nested(tb, IP_TUN_MAX, attr, ip_tun_policy);
+	if (err < 0)
+		return err;
+
+	new_state = lwtunnel_state_alloc(sizeof(*tun_info));
+	if (!new_state)
+		return -ENOMEM;
+
+	new_state->type = LWTUNNEL_ENCAP_IP;
+
+	tun_info = lwt_tun_info(new_state);
+
+	if (tb[IP_TUN_ID])
+		tun_info->key.tun_id = nla_get_u64(tb[IP_TUN_ID]);
+
+	if (tb[IP_TUN_DST])
+		tun_info->key.ipv4_dst = nla_get_be32(tb[IP_TUN_DST]);
+
+	if (tb[IP_TUN_SRC])
+		tun_info->key.ipv4_src = nla_get_be32(tb[IP_TUN_SRC]);
+
+	if (tb[IP_TUN_TTL])
+		tun_info->key.ipv4_ttl = nla_get_u8(tb[IP_TUN_TTL]);
+
+	if (tb[IP_TUN_TOS])
+		tun_info->key.ipv4_tos = nla_get_u8(tb[IP_TUN_TOS]);
+
+	if (tb[IP_TUN_SPORT])
+		tun_info->key.tp_src = nla_get_be16(tb[IP_TUN_SPORT]);
+
+	if (tb[IP_TUN_DPORT])
+		tun_info->key.tp_dst = nla_get_be16(tb[IP_TUN_DPORT]);
+
+	if (tb[IP_TUN_FLAGS])
+		tun_info->key.tun_flags = nla_get_u16(tb[IP_TUN_FLAGS]);
+
+	tun_info->mode = IP_TUNNEL_INFO_TX;
+	tun_info->options = NULL;
+	tun_info->options_len = 0;
+
+	*ts = new_state;
+
+	return 0;
+}
+
+static int ip_tun_fill_encap_info(struct sk_buff *skb,
+				  struct lwtunnel_state *lwtstate)
+{
+	struct ip_tunnel_info *tun_info = lwt_tun_info(lwtstate);
+
+	if (nla_put_u64(skb, IP_TUN_ID, tun_info->key.tun_id) ||
+	    nla_put_be32(skb, IP_TUN_DST, tun_info->key.ipv4_dst) ||
+	    nla_put_be32(skb, IP_TUN_SRC, tun_info->key.ipv4_src) ||
+	    nla_put_u8(skb, IP_TUN_TOS, tun_info->key.ipv4_tos) ||
+	    nla_put_u8(skb, IP_TUN_TTL, tun_info->key.ipv4_ttl) ||
+	    nla_put_u16(skb, IP_TUN_SPORT, tun_info->key.tp_src) ||
+	    nla_put_u16(skb, IP_TUN_DPORT, tun_info->key.tp_dst) ||
+	    nla_put_u16(skb, IP_TUN_FLAGS, tun_info->key.tun_flags))
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
+{
+	return nla_total_size(8)	/* IP_TUN_ID */
+		+ nla_total_size(4)	/* IP_TUN_DST */
+		+ nla_total_size(4)	/* IP_TUN_SRC */
+		+ nla_total_size(1)	/* IP_TUN_TOS */
+		+ nla_total_size(1)	/* IP_TUN_TTL */
+		+ nla_total_size(2)	/* IP_TUN_SPORT */
+		+ nla_total_size(2)	/* IP_TUN_DPORT */
+		+ nla_total_size(2);	/* IP_TUN_FLAGS */
+}
+
+static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
+	.build_state = ip_tun_build_state,
+	.fill_encap = ip_tun_fill_encap_info,
+	.get_encap_size = ip_tun_encap_nlsize,
+};
+
+static int __init ip_tunnel_core_init(void)
+{
+	lwtunnel_encap_add_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
+
+	return 0;
+}
+module_init(ip_tunnel_core_init);
+
+static void __exit ip_tunnel_core_exit(void)
+{
+	lwtunnel_encap_del_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
+}
+module_exit(ip_tunnel_core_exit);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 931015c..2380208 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1693,7 +1693,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
-	tun_info = skb_tunnel_info(skb);
+	tun_info = skb_tunnel_info(skb, AF_INET);
 	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
 		fl4.flowi4_tun_key.tun_id = tun_info->key.tun_id;
 	skb_dst_drop(skb);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 4750fb6..75d6824 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -27,6 +27,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/u64_stats_sync.h>
+#include <net/route.h>
 
 #include "datapath.h"
 
-- 
2.4.3
