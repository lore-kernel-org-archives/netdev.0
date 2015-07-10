From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 03/22] ipv4: support for fib route lwtunnel encap attributes
Date: Fri, 10 Jul 2015 16:19:05 +0200
Message-ID: <8ebc9066754f07003d54c3ac64d8c46f9c1c570b.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40503 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177AbbGJOTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:36 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support in ipv4 fib functions to parse user
provided encap attributes and attach encap state data to fib_nh
and rtable.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/ip_fib.h     |   5 ++-
 include/net/route.h      |   1 +
 net/ipv4/fib_frontend.c  |   8 ++++
 net/ipv4/fib_semantics.c | 101 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/route.c         |  16 +++++++-
 5 files changed, 127 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 49c142b..5e01960 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -44,7 +44,9 @@ struct fib_config {
 	u32			fc_flow;
 	u32			fc_nlflags;
 	struct nl_info		fc_nlinfo;
- };
+	struct nlattr		*fc_encap;
+	u16			fc_encap_type;
+};
 
 struct fib_info;
 struct rtable;
@@ -89,6 +91,7 @@ struct fib_nh {
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	__rcu *nh_exceptions;
+	struct lwtunnel_state	*nh_lwtstate;
 };
 
 /*
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03..2d45f41 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -66,6 +66,7 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
+	struct lwtunnel_state   *rt_lwtstate;
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6bbc549..9b2019c 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -591,6 +591,8 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_FLOW]		= { .type = NLA_U32 },
+	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
+	[RTA_ENCAP]		= { .type = NLA_NESTED },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
@@ -656,6 +658,12 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 		case RTA_TABLE:
 			cfg->fc_table = nla_get_u32(attr);
 			break;
+		case RTA_ENCAP:
+			cfg->fc_encap = attr;
+			break;
+		case RTA_ENCAP_TYPE:
+			cfg->fc_encap_type = nla_get_u16(attr);
+			break;
 		}
 	}
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3bfccd8..c5d98b9 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -42,6 +42,7 @@
 #include <net/ip_fib.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
+#include <net/lwtunnel.h>
 
 #include "fib_lookup.h"
 
@@ -208,6 +209,7 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
+		lwtunnel_state_put(nexthop_nh->nh_lwtstate);
 		free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
@@ -266,6 +268,7 @@ static inline int nh_comp(const struct fib_info *fi, const struct fib_info *ofi)
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		    nh->nh_tclassid != onh->nh_tclassid ||
 #endif
+		    lwtunnel_cmp_encap(nh->nh_lwtstate, onh->nh_lwtstate) ||
 		    ((nh->nh_flags ^ onh->nh_flags) & ~RTNH_COMPARE_MASK))
 			return -1;
 		onh++;
@@ -366,6 +369,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
 
 	if (fi->fib_nhs) {
+		size_t nh_encapsize = 0;
 		/* Also handles the special case fib_nhs == 1 */
 
 		/* each nexthop is packed in an attribute */
@@ -374,8 +378,21 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 		/* may contain flow and gateway attribute */
 		nhsize += 2 * nla_total_size(4);
 
+		/* grab encap info */
+		for_nexthops(fi) {
+			if (nh->nh_lwtstate) {
+				/* RTA_ENCAP_TYPE */
+				nh_encapsize += lwtunnel_get_encap_size(
+						nh->nh_lwtstate);
+				/* RTA_ENCAP */
+				nh_encapsize +=  nla_total_size(2);
+			}
+		} endfor_nexthops(fi);
+
 		/* all nexthops are packed in a nested attribute */
-		payload += nla_total_size(fi->fib_nhs * nhsize);
+		payload += nla_total_size((fi->fib_nhs * nhsize) +
+					  nh_encapsize);
+
 	}
 
 	return payload;
@@ -452,6 +469,9 @@ static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		       int remaining, struct fib_config *cfg)
 {
+	struct net *net = cfg->fc_nlinfo.nl_net;
+	int ret;
+
 	change_nexthops(fi) {
 		int attrlen;
 
@@ -475,18 +495,71 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			if (nexthop_nh->nh_tclassid)
 				fi->fib_net->ipv4.fib_num_tclassid_users++;
 #endif
+			nla = nla_find(attrs, attrlen, RTA_ENCAP);
+			if (nla) {
+				struct lwtunnel_state *lwtstate;
+				struct net_device *dev = NULL;
+				struct nlattr *nla_entype;
+
+				nla_entype = nla_find(attrs, attrlen,
+						      RTA_ENCAP_TYPE);
+				if (!nla_entype)
+					goto err_inval;
+				if (cfg->fc_oif)
+					dev = __dev_get_by_index(net, cfg->fc_oif);
+				ret = lwtunnel_build_state(dev, nla_get_u16(
+							   nla_entype),
+							   nla, &lwtstate);
+				if (ret)
+					goto errout;
+				lwtunnel_state_get(lwtstate);
+				nexthop_nh->nh_lwtstate = lwtstate;
+			}
 		}
 
 		rtnh = rtnh_next(rtnh, &remaining);
 	} endfor_nexthops(fi);
 
 	return 0;
+
+err_inval:
+	ret = -EINVAL;
+
+errout:
+	return ret;
 }
 
 #endif
 
+int fib_encap_match(struct net *net, u16 encap_type,
+		    struct nlattr *encap,
+		    int oif, const struct fib_nh *nh)
+{
+	struct lwtunnel_state *lwtstate;
+	struct net_device *dev = NULL;
+	int ret;
+
+	if (encap_type == LWTUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (oif)
+		dev = __dev_get_by_index(net, oif);
+	ret = lwtunnel_build_state(dev, encap_type,
+				   encap, &lwtstate);
+	if (!ret) {
+		lwtunnel_state_get(lwtstate);
+		ret = lwtunnel_cmp_encap(lwtstate, nh->nh_lwtstate);
+		lwtunnel_state_put(lwtstate);
+
+		return ret;
+	}
+
+	return 0;
+}
+
 int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 {
+	struct net *net = cfg->fc_nlinfo.nl_net;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	struct rtnexthop *rtnh;
 	int remaining;
@@ -496,6 +569,12 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 		return 1;
 
 	if (cfg->fc_oif || cfg->fc_gw) {
+		if (cfg->fc_encap) {
+			if (fib_encap_match(net, cfg->fc_encap_type,
+					    cfg->fc_encap, cfg->fc_oif,
+					    fi->fib_nh))
+			    return 1;
+		}
 		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
 		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw))
 			return 0;
@@ -882,6 +961,22 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	} else {
 		struct fib_nh *nh = fi->fib_nh;
 
+		if (cfg->fc_encap) {
+			struct lwtunnel_state *lwtstate;
+			struct net_device *dev = NULL;
+
+			if (cfg->fc_encap_type == LWTUNNEL_ENCAP_NONE)
+				goto err_inval;
+			if (cfg->fc_oif)
+				dev = __dev_get_by_index(net, cfg->fc_oif);
+			err = lwtunnel_build_state(dev, cfg->fc_encap_type,
+						   cfg->fc_encap, &lwtstate);
+			if (err)
+				goto failure;
+
+			lwtunnel_state_get(lwtstate);
+			nh->nh_lwtstate = lwtstate;
+		}
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
 		nh->nh_flags = cfg->fc_flags;
@@ -1055,6 +1150,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
 			goto nla_put_failure;
 #endif
+		if (fi->fib_nh->nh_lwtstate)
+			lwtunnel_fill_encap(skb, fi->fib_nh->nh_lwtstate);
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
@@ -1090,6 +1187,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
 				goto nla_put_failure;
 #endif
+			if (nh->nh_lwtstate)
+				lwtunnel_fill_encap(skb, nh->nh_lwtstate);
 			/* length of rtnetlink header + attributes */
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d0362a2..bfc0a18 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -102,6 +102,7 @@
 #include <net/tcp.h>
 #include <net/icmp.h>
 #include <net/xfrm.h>
+#include <net/lwtunnel.h>
 #include <net/netevent.h>
 #include <net/rtnetlink.h>
 #ifdef CONFIG_SYSCTL
@@ -1355,6 +1356,7 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&ul->lock);
 	}
+	lwtunnel_state_put(rt->rt_lwtstate);
 }
 
 void rt_flush_dev(struct net_device *dev)
@@ -1403,6 +1405,12 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
+		if (nh->nh_lwtstate) {
+			lwtunnel_state_get(nh->nh_lwtstate);
+			rt->rt_lwtstate = nh->nh_lwtstate;
+		} else {
+			rt->rt_lwtstate = NULL;
+		}
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
@@ -1488,6 +1496,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	rth->rt_lwtstate = NULL;
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1618,6 +1627,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	rth->rt_lwtstate = NULL;
 	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
@@ -1792,6 +1802,8 @@ local_input:
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+	rth->rt_lwtstate = NULL;
+
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1981,7 +1993,7 @@ add:
 	rth->rt_gateway = 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-
+	rth->rt_lwtstate = NULL;
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & RTCF_LOCAL)
@@ -2261,7 +2273,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
-
+		rt->rt_lwtstate = NULL;
 		dst_free(new);
 	}
 
-- 
2.4.3
