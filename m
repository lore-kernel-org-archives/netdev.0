From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 05/14] route: Per route tunnel metadata with RTA_TUNNEL
Date: Mon,  1 Jun 2015 16:27:29 +0200
Message-ID: <3b333ab393de268323c1eaa1d18169ec9c36f86b.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50976 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbbFAO1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:48 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduces a new Netlink attribute RTA_TUNNEL which allows routes
to set tunnel transmit metadata and specify the tunnel endpoint or
tunnel id on a per route basis. The route must point to a tunnel
device which understands per skb tunnel metadata and has been put
into the respective mode.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/ip_fib.h           |  3 +++
 include/net/ip_tunnels.h       |  1 -
 include/net/route.h            | 10 ++++++++
 include/uapi/linux/rtnetlink.h | 16 ++++++++++++
 net/ipv4/fib_frontend.c        | 57 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/fib_semantics.c       | 45 +++++++++++++++++++++++++++++++++
 net/ipv4/route.c               | 30 +++++++++++++++++++++-
 net/openvswitch/vport.h        |  1 +
 8 files changed, 161 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..1cd7cf8 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -22,6 +22,7 @@
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
 #include <linux/percpu.h>
+#include <net/ip_tunnels.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -44,6 +45,7 @@ struct fib_config {
 	u32			fc_flow;
 	u32			fc_nlflags;
 	struct nl_info		fc_nlinfo;
+	struct ip_tunnel_info	fc_tunnel;
  };
 
 struct fib_info;
@@ -117,6 +119,7 @@ struct fib_info {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_power;
 #endif
+	struct ip_tunnel_info	*fib_tunnel;
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
 #define fib_dev		fib_nh[0].nh_dev
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index df8cfd3..b4ab930 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -9,7 +9,6 @@
 #include <net/dsfield.h>
 #include <net/gro_cells.h>
 #include <net/inet_ecn.h>
-#include <net/ip.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/flow.h>
diff --git a/include/net/route.h b/include/net/route.h
index 6ede321..dbda603 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -28,6 +28,7 @@
 #include <net/inetpeer.h>
 #include <net/flow.h>
 #include <net/inet_sock.h>
+#include <net/ip_tunnels.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/rcupdate.h>
@@ -66,6 +67,7 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
+	struct ip_tunnel_info	*rt_tun_info;
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
@@ -198,6 +200,8 @@ struct in_ifaddr;
 void fib_add_ifaddr(struct in_ifaddr *);
 void fib_del_ifaddr(struct in_ifaddr *, struct in_ifaddr *);
 
+int fib_dump_tun_info(struct sk_buff *skb, struct ip_tunnel_info *tun_info);
+
 static inline void ip_rt_put(struct rtable *rt)
 {
 	/* dst_release() accepts a NULL parameter.
@@ -317,9 +321,15 @@ static inline int ip4_dst_hoplimit(const struct dst_entry *dst)
 
 static inline struct ip_tunnel_info *skb_tunnel_info(struct sk_buff *skb)
 {
+	struct rtable *rt;
+
 	if (skb_shinfo(skb)->tun_info)
 		return skb_shinfo(skb)->tun_info;
 
+	rt = skb_rtable(skb);
+	if (rt)
+		return rt->rt_tun_info;
+
 	return NULL;
 }
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 17fb02f..1f7aa68 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -286,6 +286,21 @@ enum rt_class_t {
 
 /* Routing message attributes */
 
+enum rta_tunnel_t {
+	RTA_TUN_UNSPEC,
+	RTA_TUN_ID,
+	RTA_TUN_DST,
+	RTA_TUN_SRC,
+	RTA_TUN_TTL,
+	RTA_TUN_TOS,
+	RTA_TUN_SPORT,
+	RTA_TUN_DPORT,
+	RTA_TUN_FLAGS,
+	__RTA_TUN_MAX,
+};
+
+#define RTA_TUN_MAX (__RTA_TUN_MAX - 1)
+
 enum rtattr_type_t {
 	RTA_UNSPEC,
 	RTA_DST,
@@ -308,6 +323,7 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_TUNNEL,	/* destination VTEP */
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 872494e..bfa77a6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -580,6 +580,57 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	return -EINVAL;
 }
 
+static const struct nla_policy tunnel_policy[RTA_TUN_MAX + 1] = {
+	[RTA_TUN_ID]		= { .type = NLA_U64 },
+	[RTA_TUN_DST]		= { .type = NLA_U32 },
+	[RTA_TUN_SRC]		= { .type = NLA_U32 },
+	[RTA_TUN_TTL]		= { .type = NLA_U8 },
+	[RTA_TUN_TOS]		= { .type = NLA_U8 },
+	[RTA_TUN_SPORT]		= { .type = NLA_U16 },
+	[RTA_TUN_DPORT]		= { .type = NLA_U16 },
+	[RTA_TUN_FLAGS]		= { .type = NLA_U16 },
+};
+
+static int parse_rta_tunnel(struct fib_config *cfg, struct nlattr *attr)
+{
+	struct nlattr *tb[RTA_TUN_MAX+1];
+	int err;
+
+	err = nla_parse_nested(tb, RTA_TUN_MAX, attr, tunnel_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[RTA_TUN_ID])
+		cfg->fc_tunnel.key.tun_id = nla_get_u64(tb[RTA_TUN_ID]);
+
+	if (tb[RTA_TUN_DST])
+		cfg->fc_tunnel.key.ipv4_dst = nla_get_be32(tb[RTA_TUN_DST]);
+
+	if (tb[RTA_TUN_SRC])
+		cfg->fc_tunnel.key.ipv4_src = nla_get_be32(tb[RTA_TUN_SRC]);
+
+	if (tb[RTA_TUN_TTL])
+		cfg->fc_tunnel.key.ipv4_ttl = nla_get_u8(tb[RTA_TUN_TTL]);
+
+	if (tb[RTA_TUN_TOS])
+		cfg->fc_tunnel.key.ipv4_tos = nla_get_u8(tb[RTA_TUN_TOS]);
+
+	if (tb[RTA_TUN_SPORT])
+		cfg->fc_tunnel.key.tp_src = nla_get_be16(tb[RTA_TUN_SPORT]);
+
+	if (tb[RTA_TUN_DPORT])
+		cfg->fc_tunnel.key.tp_dst = nla_get_be16(tb[RTA_TUN_DPORT]);
+
+	if (tb[RTA_TUN_FLAGS])
+		cfg->fc_tunnel.key.tun_flags = nla_get_u16(tb[RTA_TUN_FLAGS]);
+
+	cfg->fc_tunnel.mode = IP_TUNNEL_INFO_TX;
+	cfg->fc_tunnel.options = NULL;
+	cfg->fc_tunnel.options_len = 0;
+
+	return 0;
+}
+
 const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_DST]		= { .type = NLA_U32 },
 	[RTA_SRC]		= { .type = NLA_U32 },
@@ -591,6 +642,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_FLOW]		= { .type = NLA_U32 },
+	[RTA_TUNNEL]		= { .type = NLA_NESTED },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
@@ -656,6 +708,11 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 		case RTA_TABLE:
 			cfg->fc_table = nla_get_u32(attr);
 			break;
+		case RTA_TUNNEL:
+			err = parse_rta_tunnel(cfg, attr);
+			if (err < 0)
+				goto errout;
+			break;
 		}
 	}
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 28ec3c1..1e94c81 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -215,6 +215,9 @@ static void free_fib_info_rcu(struct rcu_head *head)
 
 	if (fi->fib_metrics != (u32 *) dst_default_metrics)
 		kfree(fi->fib_metrics);
+
+	ip_tunnel_info_put(fi->fib_tunnel);
+
 	kfree(fi);
 }
 
@@ -760,6 +763,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	struct fib_info *ofi;
 	int nhs = 1;
 	struct net *net = cfg->fc_nlinfo.nl_net;
+	struct ip_tunnel_info *tun_info = NULL;
 
 	if (cfg->fc_type > RTN_MAX)
 		goto err_inval;
@@ -856,6 +860,19 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		}
 	}
 
+	if (cfg->fc_tunnel.mode) {
+		/* TODO: Allow specification of options */
+		tun_info = ip_tunnel_info_alloc(0, GFP_KERNEL);
+		if (!tun_info) {
+			err = -ENOMEM;
+			goto failure;
+		}
+
+		memcpy(tun_info, &cfg->fc_tunnel, sizeof(*tun_info));
+		ip_tunnel_info_get(tun_info);
+		fi->fib_tunnel = tun_info;
+	}
+
 	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
@@ -975,6 +992,8 @@ err_inval:
 	err = -EINVAL;
 
 failure:
+	kfree(tun_info);
+
 	if (fi) {
 		fi->fib_dead = 1;
 		free_fib_info(fi);
@@ -983,6 +1002,29 @@ failure:
 	return ERR_PTR(err);
 }
 
+int fib_dump_tun_info(struct sk_buff *skb, struct ip_tunnel_info *tun_info)
+{
+	struct nlattr *tun_attr;
+
+	tun_attr = nla_nest_start(skb, RTA_TUNNEL);
+	if (!tun_attr)
+		return -ENOMEM;
+
+	if (nla_put_u64(skb, RTA_TUN_ID, tun_info->key.tun_id) ||
+	    nla_put_be32(skb, RTA_TUN_DST, tun_info->key.ipv4_dst) ||
+	    nla_put_be32(skb, RTA_TUN_SRC, tun_info->key.ipv4_src) ||
+	    nla_put_u8(skb, RTA_TUN_TOS, tun_info->key.ipv4_tos) ||
+	    nla_put_u8(skb, RTA_TUN_TTL, tun_info->key.ipv4_ttl) ||
+	    nla_put_u16(skb, RTA_TUN_SPORT, tun_info->key.tp_src) ||
+	    nla_put_u16(skb, RTA_TUN_DPORT, tun_info->key.tp_dst) ||
+	    nla_put_u16(skb, RTA_TUN_FLAGS, tun_info->key.tun_flags))
+		return -ENOMEM;
+
+	nla_nest_end(skb, tun_attr);
+
+	return 0;
+}
+
 int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		  u32 tb_id, u8 type, __be32 dst, int dst_len, u8 tos,
 		  struct fib_info *fi, unsigned int flags)
@@ -1068,6 +1110,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		nla_nest_end(skb, mp);
 	}
 #endif
+	if (fi->fib_tunnel && fib_dump_tun_info(skb, fi->fib_tunnel))
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6e8e1be..f53c62f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1356,6 +1356,8 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&ul->lock);
 	}
+
+	ip_tunnel_info_put(rt->rt_tun_info);
 }
 
 void rt_flush_dev(struct net_device *dev)
@@ -1489,6 +1491,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	rth->rt_tun_info = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1543,6 +1546,7 @@ static int __mkroute_input(struct sk_buff *skb,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos)
 {
+	struct fib_info *fi = res->fi;
 	struct fib_nh_exception *fnhe;
 	struct rtable *rth;
 	int err;
@@ -1590,7 +1594,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	}
 
 	fnhe = find_exception(&FIB_RES_NH(*res), daddr);
-	if (do_cache) {
+	if (do_cache && !(fi && fi->fib_tunnel)) {
 		if (fnhe)
 			rth = rcu_dereference(fnhe->fnhe_rth_input);
 		else
@@ -1621,6 +1625,13 @@ static int __mkroute_input(struct sk_buff *skb,
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	RT_CACHE_STAT_INC(in_slow_tot);
 
+	if (fi && fi->fib_tunnel) {
+		ip_tunnel_info_get(fi->fib_tunnel);
+		rth->rt_tun_info = fi->fib_tunnel;
+	} else {
+		rth->rt_tun_info = NULL;
+	}
+
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
@@ -1794,6 +1805,7 @@ local_input:
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	rth->rt_tun_info = NULL;
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1940,6 +1952,11 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 
 	fnhe = NULL;
 	do_cache &= fi != NULL;
+
+	/* Force dst for flows with tunnel encapsulation */
+	if (fi && fi->fib_tunnel)
+		goto add;
+
 	if (do_cache) {
 		struct rtable __rcu **prth;
 		struct fib_nh *nh = &FIB_RES_NH(*res);
@@ -1984,6 +2001,13 @@ add:
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
 
+	if (fi && fi->fib_tunnel) {
+		ip_tunnel_info_get(fi->fib_tunnel);
+		rth->rt_tun_info = fi->fib_tunnel;
+	} else {
+		rth->rt_tun_info = NULL;
+	}
+
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & RTCF_LOCAL)
@@ -2263,6 +2287,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
+		rt->rt_tun_info = NULL;
 
 		dst_free(new);
 	}
@@ -2394,6 +2419,9 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, error) < 0)
 		goto nla_put_failure;
 
+	if (rt->rt_tun_info && fib_dump_tun_info(skb, rt->rt_tun_info))
+		goto nla_put_failure;
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
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
2.3.5
