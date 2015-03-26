From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [RFC net-next 1/2] net: allow user to set IPv6 nexthop for IPv4 route
Date: Thu, 26 Mar 2015 17:05:27 -0400
Message-ID: <1427403928-1342-2-git-send-email-gospo@cumulusnetworks.com>
References: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, Bjornar Ness <bjornar.ness@gmail.com>,
	Sowmini Varadhan <sowmini05@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:33276 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbbCZVGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 17:06:31 -0400
Received: by ykek76 with SMTP id k76so34008652yke.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 14:06:31 -0700 (PDT)
In-Reply-To: <1427403928-1342-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds kernel infrastructure to allow userspace (read: routing protocols) to
support adding IPv6 next-hops to IPv4 routes.  This is essentially added to
support a feature of MP-BGP outlined in RFC-5549.  

Thise does not encompass all that is needed to support RFC-5549, but this
demonstrates the netlink infrastructure needed to correctly enable the kernel
infrastructure that would support this RFC.  For more informtion the full RFC
is here: http://www.ietf.org/rfc/rfc5549.txt.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---

I still consider this an RFC as I need to work out details when IPv6 is not
enabled, but I wanted to get eyes on this as quickly as possible to allow
others to comment on the general implementation.

 include/net/ip_fib.h           |  3 +++
 include/net/route.h            |  2 ++
 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv4/fib_frontend.c        |  4 ++++
 net/ipv4/fib_semantics.c       | 24 +++++++++++++++++++-----
 net/ipv4/ip_output.c           | 30 +++++++++++++++++++++++++-----
 net/ipv4/route.c               | 12 ++++++++++++
 7 files changed, 66 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..a45fbe0 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -22,6 +22,7 @@
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
 #include <linux/percpu.h>
+#include <linux/in6.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -44,6 +45,7 @@ struct fib_config {
 	u32			fc_flow;
 	u32			fc_nlflags;
 	struct nl_info		fc_nlinfo;
+	struct in6_addr		fc_gw6;
  };
 
 struct fib_info;
@@ -89,6 +91,7 @@ struct fib_nh {
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	__rcu *nh_exceptions;
+	struct in6_addr		nh_gw6;
 };
 
 /*
diff --git a/include/net/route.h b/include/net/route.h
index fe22d03..b66a6c4 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -35,6 +35,7 @@
 #include <linux/ip.h>
 #include <linux/cache.h>
 #include <linux/security.h>
+#include <linux/in6.h>
 
 /* IPv4 datagram length is stored into 16bit field (tot_len) */
 #define IP_MAX_MTU	0xFFFFU
@@ -66,6 +67,7 @@ struct rtable {
 
 	struct list_head	rt_uncached;
 	struct uncached_list	*rt_uncached_list;
+	struct in6_addr		rt_gateway6;
 };
 
 static inline bool rt_is_input_route(const struct rtable *rt)
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index bea910f..26cdd01 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -306,6 +306,7 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_GATEWAY6,
 	__RTA_MAX
 };
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e5b6b05..3775b05 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -591,6 +591,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 	[RTA_METRICS]		= { .type = NLA_NESTED },
 	[RTA_MULTIPATH]		= { .len = sizeof(struct rtnexthop) },
 	[RTA_FLOW]		= { .type = NLA_U32 },
+	[RTA_GATEWAY6]		= { .len = sizeof(struct in6_addr) },
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
@@ -636,6 +637,9 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 		case RTA_GATEWAY:
 			cfg->fc_gw = nla_get_be32(attr);
 			break;
+		case RTA_GATEWAY6:
+			nla_memcpy(&cfg->fc_gw6, attr, sizeof(struct in6_addr));
+			break;
 		case RTA_PRIORITY:
 			cfg->fc_priority = nla_get_u32(attr);
 			break;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 66c1e4f..7de2924 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -468,7 +468,11 @@ static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
 			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 
 			nla = nla_find(attrs, attrlen, RTA_GATEWAY);
-			nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
+			if (nla_len(nla) == 4) {
+				nexthop_nh->nh_gw = nla ? nla_get_be32(nla) : 0;
+			} else if (nla_len(nla) == 16) {
+				nla_memcpy(&nexthop_nh->nh_gw6, nla, nla_len(nla));
+			} else return -EINVAL;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			nla = nla_find(attrs, attrlen, RTA_FLOW);
 			nexthop_nh->nh_tclassid = nla ? nla_get_u32(nla) : 0;
@@ -495,9 +499,10 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
 	if (cfg->fc_priority && cfg->fc_priority != fi->fib_priority)
 		return 1;
 
-	if (cfg->fc_oif || cfg->fc_gw) {
+	if (cfg->fc_oif || cfg->fc_gw || !ipv6_addr_any(&cfg->fc_gw6)) {
 		if ((!cfg->fc_oif || cfg->fc_oif == fi->fib_nh->nh_oif) &&
-		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw))
+		    (!cfg->fc_gw  || cfg->fc_gw == fi->fib_nh->nh_gw) &&
+		    (ipv6_addr_any(&cfg->fc_gw6) || !ipv6_addr_cmp(&cfg->fc_gw6, &fi->fib_nh->nh_gw6)))
 			return 0;
 		return 1;
 	}
@@ -759,7 +764,7 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
 
 struct fib_info *fib_create_info(struct fib_config *cfg)
 {
-	int err;
+	int err = 0;
 	struct fib_info *fi = NULL;
 	struct fib_info *ofi;
 	int nhs = 1;
@@ -869,6 +874,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			goto err_inval;
 		if (cfg->fc_gw && fi->fib_nh->nh_gw != cfg->fc_gw)
 			goto err_inval;
+		if (!ipv6_addr_any(&cfg->fc_gw6) && ipv6_addr_cmp(&cfg->fc_gw6, &fi->fib_nh->nh_gw6))
+			goto err_inval;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		if (cfg->fc_flow && fi->fib_nh->nh_tclassid != cfg->fc_flow)
 			goto err_inval;
@@ -882,6 +889,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
 		nh->nh_flags = cfg->fc_flags;
+		memcpy(&nh->nh_gw6,&cfg->fc_gw6,sizeof(struct in6_addr));
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		nh->nh_tclassid = cfg->fc_flow;
 		if (nh->nh_tclassid)
@@ -893,7 +901,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	if (fib_props[cfg->fc_type].error) {
-		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
+		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp || !ipv6_addr_any(&cfg->fc_gw6))
 			goto err_inval;
 		goto link_it;
 	} else {
@@ -1033,6 +1041,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		if (fi->fib_nh->nh_oif &&
 		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
 			goto nla_put_failure;
+		if (!ipv6_addr_any(&fi->fib_nh->nh_gw6) &&
+		    nla_put(skb, RTA_GATEWAY, 16, &fi->fib_nh->nh_gw6))
+			goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		if (fi->fib_nh[0].nh_tclassid &&
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
@@ -1060,6 +1071,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			if (nh->nh_gw &&
 			    nla_put_be32(skb, RTA_GATEWAY, nh->nh_gw))
 				goto nla_put_failure;
+			if (!ipv6_addr_any(&nh->nh_gw6) &&
+			    nla_put(skb, RTA_GATEWAY, 16, &nh->nh_gw6))
+				goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
 			if (nh->nh_tclassid &&
 			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8259e77..1b63e6a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -79,6 +79,9 @@
 #include <linux/mroute.h>
 #include <linux/netlink.h>
 #include <linux/tcp.h>
+#include <net/ndisc.h>
+#include <linux/in6.h>
+#include <net/ipv6.h>
 
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
@@ -169,7 +172,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
-	struct neighbour *neigh;
+	struct neighbour *neigh = NULL;
 	u32 nexthop;
 
 	if (rt->rt_type == RTN_MULTICAST) {
@@ -193,10 +196,27 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	}
 
 	rcu_read_lock_bh();
-	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
-	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
-	if (unlikely(!neigh))
-		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	/* If there is an ipv6 gateway specified, use it */
+	if (!rt->rt_gateway && !ipv6_addr_any(&rt->rt_gateway6)) {
+		neigh = __ipv6_neigh_lookup_noref(dst->dev, &rt->rt_gateway6);
+
+		if (unlikely(!neigh)) {
+			neigh = __neigh_create(&nd_tbl, &rt->rt_gateway6, dst->dev, false);
+		}
+	}
+#endif
+	/* No ipv6 gateway created, so use ipv4 */
+	if (likely(!neigh)) {
+		nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
+		neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
+
+		if (unlikely(!neigh)) {
+			neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
+		}
+	}
+
 	if (!IS_ERR(neigh)) {
 		int res = dst_neigh_output(dst, neigh, skb);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index be8703d..c654b41 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1400,6 +1400,10 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			rt->rt_gateway = nh->nh_gw;
 			rt->rt_uses_gateway = 1;
 		}
+		if (!ipv6_addr_any(&nh->nh_gw6)) {
+			memcpy(&rt->rt_gateway6, &nh->nh_gw6, sizeof(struct in6_addr));
+			rt->rt_uses_gateway = 1;
+		}
 		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
@@ -1417,6 +1421,10 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 			rt->dst.flags |= DST_NOCACHE;
 			if (!rt->rt_gateway)
 				rt->rt_gateway = daddr;
+			if (ipv6_addr_any(&rt->rt_gateway6)) {
+				memcpy(&rt->rt_gateway6, &nh->nh_gw6, sizeof(struct in6_addr));
+				rt->rt_uses_gateway = 1;
+			}
 			rt_add_uncached_list(rt);
 		}
 	} else
@@ -1488,6 +1496,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
+	memset(&rth->rt_gateway6, 0, sizeof(struct in6_addr));
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	if (our) {
 		rth->dst.input= ip_local_deliver;
@@ -1618,6 +1627,7 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
+	memset(&rth->rt_gateway6, 0, sizeof(struct in6_addr));
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	RT_CACHE_STAT_INC(in_slow_tot);
 
@@ -1792,6 +1802,7 @@ local_input:
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= 0;
 	rth->rt_uses_gateway = 0;
+	memset(&rth->rt_gateway6, 0, sizeof(struct in6_addr));
 	INIT_LIST_HEAD(&rth->rt_uncached);
 	RT_CACHE_STAT_INC(in_slow_tot);
 	if (res.type == RTN_UNREACHABLE) {
@@ -1981,6 +1992,7 @@ add:
 	rth->rt_pmtu	= 0;
 	rth->rt_gateway = 0;
 	rth->rt_uses_gateway = 0;
+	memset(&rth->rt_gateway6, 0, sizeof(struct in6_addr));
 	INIT_LIST_HEAD(&rth->rt_uncached);
 
 	RT_CACHE_STAT_INC(out_slow_tot);
-- 
1.9.3
