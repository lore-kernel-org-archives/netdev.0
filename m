From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight tunnel encap attributes
Date: Thu, 18 Jun 2015 21:49:14 -0700
Message-ID: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33656 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731AbbFSEtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 00:49:22 -0400
Received: by pdjn11 with SMTP id n11so82177435pdj.0
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 21:49:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Introduces two netlink attributes RTA_ENCAP_TYPE and
RTA_ENCAP to support attaching encap information to ipv4 routes.

RTA_ENCAP is a nested attribute as suggested by Thomas
(and also as Robert had it in his series). RTA_ENCAP
netlink policy is declared by the light weight tunnel
drivers that support this encap type.

fib code calls the following for each nexthop:
	- new route handler:
		lwt build state (that parses RTA_ENCAP and returns
	  	lwt state that lives in every fib_nh)
	- del dump hanlder:
		lwt release handler to release lwt state data
	- route dump hanlder:
		lwt dump encap to fill RTA_ENCAP data
	- during input route lookup
		sets dst->output to lwtunnel_output which
		in turn calls the corresponding lwt tunnel
		output function which applies the required
		encap and xmits the packet

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/ip_fib.h           |    7 ++-
 include/net/route.h            |    3 ++
 include/uapi/linux/rtnetlink.h |    3 +-
 net/ipv4/fib_frontend.c        |    8 ++++
 net/ipv4/fib_semantics.c       |   93 +++++++++++++++++++++++++++++++++++++++-
 net/ipv4/route.c               |   33 +++++++++++++-
 6 files changed, 142 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..49f18d7 100644
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
@@ -89,6 +91,9 @@ struct fib_nh {
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	__rcu *nh_exceptions;
+#ifdef CONFIG_LWTUNNEL
+	struct lwtunnel_state	*nh_lwtstate;
+#endif
 };
 
 /*
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03..39a6495 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -66,6 +66,9 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
+#ifdef CONFIG_LWTUNNEL
+	struct lwtunnel_state   *rt_lwtstate;
+#endif
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 17fb02f..6c089ad 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -308,6 +308,8 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_ENCAP_TYPE,
+	RTA_ENCAP,
 	__RTA_MAX
 };
 
@@ -357,7 +359,6 @@ struct rtvia {
 };
 
 /* RTM_CACHEINFO */
-
 struct rta_cacheinfo {
 	__u32	rta_clntref;
 	__u32	rta_lastuse;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 872494e..fbe0630 100644
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
index 28ec3c1..54dd287 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -42,6 +42,7 @@
 #include <net/ip_fib.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
+#include <net/lwtunnel.h>
 
 #include "fib_lookup.h"
 
@@ -208,6 +209,10 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
+#ifdef CONFIG_LWTUNNEL
+		if (nexthop_nh->nh_lwtstate)
+			lwtunnel_state_put(nexthop_nh->nh_lwtstate);
+#endif
 		free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
@@ -366,6 +371,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
 
 	if (fi->fib_nhs) {
+		size_t nh_encapsize = 0;
 		/* Also handles the special case fib_nhs == 1 */
 
 		/* each nexthop is packed in an attribute */
@@ -374,8 +380,23 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 		/* may contain flow and gateway attribute */
 		nhsize += 2 * nla_total_size(4);
 
+#ifdef CONFIG_LWTUNNEL
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
+#endif
+
 		/* all nexthops are packed in a nested attribute */
-		payload += nla_total_size(fi->fib_nhs * nhsize);
+		payload += nla_total_size((fi->fib_nhs * nhsize) +
+					  nh_encapsize);
+
 	}
 
 	return payload;
@@ -452,6 +473,9 @@ static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 		       int remaining, struct fib_config *cfg)
 {
+	struct net *net = cfg->fc_nlinfo.nl_net;
+	int ret;
+
 	change_nexthops(fi) {
 		int attrlen;
 
@@ -475,12 +499,40 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			if (nexthop_nh->nh_tclassid)
 				fi->fib_net->ipv4.fib_num_tclassid_users++;
 #endif
+#ifdef CONFIG_LWTUNNEL
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
+#endif
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
@@ -875,6 +927,25 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	} else {
 		struct fib_nh *nh = fi->fib_nh;
 
+#ifdef CONFIG_LWTUNNEL
+		if (cfg->fc_encap) {
+			struct lwtunnel_state *lwtstate;
+			struct net_device *dev = NULL;
+			int ret;
+
+			if (cfg->fc_encap_type == LWTUNNEL_ENCAP_NONE)
+				goto err_inval;
+			if (cfg->fc_oif)
+				dev = __dev_get_by_index(net, cfg->fc_oif);
+			ret = lwtunnel_build_state(dev, cfg->fc_encap_type,
+						   cfg->fc_encap, &lwtstate);
+			if (ret)
+				goto err_inval;
+
+			lwtunnel_state_get(lwtstate);
+			nh->nh_lwtstate = lwtstate;
+		}
+#endif
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
 		nh->nh_flags = cfg->fc_flags;
@@ -1034,7 +1105,17 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
 			goto nla_put_failure;
 #endif
+#ifdef CONFIG_LWTUNNEL
+		if (fi->fib_nh->nh_lwtstate) {
+			struct lwtunnel_state *lwtstate;
+
+			lwtstate = fi->fib_nh->nh_lwtstate;
+			if (nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type))
+				goto nla_put_failure;
+			lwtunnel_fill_encap(skb, lwtstate);
+		}
 	}
+#endif
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
 		struct rtnexthop *rtnh;
@@ -1061,6 +1142,16 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
 				goto nla_put_failure;
 #endif
+#ifdef CONFIG_LWTUNNEL
+			if (nh->nh_lwtstate) {
+				struct lwtunnel_state *lwtstate;
+
+				lwtstate = nh->nh_lwtstate;
+				if (nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type))
+					goto nla_put_failure;
+				lwtunnel_fill_encap(skb, lwtstate);
+			}
+#endif
 			/* length of rtnetlink header + attributes */
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f605598..c6549f9 100644
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
@@ -1355,6 +1356,9 @@ static void ipv4_dst_destroy(struct dst_entry *dst)
 		list_del(&rt->rt_uncached);
 		spin_unlock_bh(&ul->lock);
 	}
+#ifdef CONFIG_LWTUNNEL
+	lwtunnel_state_put(rt->rt_lwtstate);
+#endif
 }
 
 void rt_flush_dev(struct net_device *dev)
@@ -1403,6 +1407,14 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
+#ifdef CONFIG_LWTUNNEL
+		if (nh->nh_lwtstate) {
+			lwtunnel_state_get(nh->nh_lwtstate);
+			rt->rt_lwtstate = nh->nh_lwtstate;
+		} else {
+			rt->rt_lwtstate = NULL;
+		}
+#endif
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
@@ -1488,6 +1500,9 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+#ifdef CONFIG_LWTUNNEL
+	rth->rt_lwtstate = NULL;
+#endif
 	if (our) {
 		rth->dst.input= ip_local_deliver;
 		rth->rt_flags |= RTCF_LOCAL;
@@ -1618,12 +1633,19 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+#ifdef CONFIG_LWTUNNEL
+	rth->rt_lwtstate = NULL;
+#endif
 	RT_CACHE_STAT_INC(in_slow_tot);
 
 	rth->dst.input = ip_forward;
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
+#ifdef CONFIG_LWTUNNEL
+	if (lwtunnel_output_redirect(rth->rt_lwtstate))
+		rth->dst.output = lwtunnel_output;
+#endif
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
@@ -1792,6 +1814,9 @@ local_input:
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
+#ifdef CONFIG_LWTUNNEL
+	rth->rt_lwtstate = NULL;
+#endif
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
 		rth->dst.input= ip_error;
@@ -1981,7 +2006,9 @@ add:
 	rth->rt_gateway = 0;
 	rth->rt_uses_gateway = 0;
 	INIT_LIST_HEAD(&rth->rt_uncached);
-
+#ifdef CONFIG_LWTUNNEL
+	rth->rt_lwtstate = NULL;
+#endif
 	RT_CACHE_STAT_INC(out_slow_tot);
 
 	if (flags & RTCF_LOCAL)
@@ -2261,7 +2288,9 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_uses_gateway = ort->rt_uses_gateway;
 
 		INIT_LIST_HEAD(&rt->rt_uncached);
-
+#ifdef CONFIG_LWTUNNEL
+		rt->rt_lwtstate = NULL;
+#endif
 		dst_free(new);
 	}
 
-- 
1.7.10.4
