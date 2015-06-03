From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH WIP RFC 2/3] ipv4 fib: lwtunnel handling
Date: Wed,  3 Jun 2015 07:21:45 -0700
Message-ID: <1433341306-29288-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35388 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932790AbbFCOV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 10:21:56 -0400
Received: by qgg60 with SMTP id 60so4292904qgg.2
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 07:21:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

- parse RTA_ENCAP
- store lwtstate in every nexthop
- set dst->output to point to lwtunnel output

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/dst.h        |    2 ++
 include/net/ip_fib.h     |    5 ++++-
 net/ipv4/fib_frontend.c  |    6 ++++++
 net/ipv4/fib_semantics.c |   34 +++++++++++++++++++++++++++++++++-
 net/ipv4/route.c         |    5 +++++
 5 files changed, 50 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2bc73f8a..111d128 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -103,6 +103,8 @@ struct dst_entry {
 		struct rt6_info		*rt6_next;
 		struct dn_route __rcu	*dn_next;
 	};
+
+	struct lwtunnel_state __rcu      *lwtstate;
 };
 
 u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 54271ed..506a87e 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -44,7 +44,9 @@ struct fib_config {
 	u32			fc_flow;
 	u32			fc_nlflags;
 	struct nl_info		fc_nlinfo;
- };
+	struct rtencap		*fc_encap;
+	int			fc_encap_len;
+};
 
 struct fib_info;
 struct rtable;
@@ -89,6 +91,7 @@ struct fib_nh {
 	struct rtable __rcu * __percpu *nh_pcpu_rth_output;
 	struct rtable __rcu	*nh_rth_input;
 	struct fnhe_hash_bucket	__rcu *nh_exceptions;
+	struct lw_tunnel_state __rcu *lwtstate;
 };
 
 /*
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 872494e..3f0a70e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -656,6 +656,12 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 		case RTA_TABLE:
 			cfg->fc_table = nla_get_u32(attr);
 			break;
+		case RTA_ENCAP:
+		{
+			cfg->fc_encap = nla_data(attr);
+			cfg->fc_encap_len = nla_len(attr);
+			break;
+		}
 		}
 	}
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 28ec3c1..b69312f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -42,6 +42,7 @@
 #include <net/ip_fib.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
+#include <net/lwtunnel.h>
 
 #include "fib_lookup.h"
 
@@ -208,6 +209,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 	change_nexthops(fi) {
 		if (nexthop_nh->nh_dev)
 			dev_put(nexthop_nh->nh_dev);
+		if (nexthop_nh->lwtstate)
+			lwtunnel_state_free(nexthop_nh->lwtstate);
 		free_nh_exceptions(nexthop_nh);
 		rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
 		rt_fibinfo_free(&nexthop_nh->nh_rth_input);
@@ -366,6 +369,7 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 	payload += nla_total_size((RTAX_MAX * nla_total_size(4)));
 
 	if (fi->fib_nhs) {
+		size_t nh_encapsize = 0;
 		/* Also handles the special case fib_nhs == 1 */
 
 		/* each nexthop is packed in an attribute */
@@ -374,8 +378,19 @@ static inline size_t fib_nlmsg_size(struct fib_info *fi)
 		/* may contain flow and gateway attribute */
 		nhsize += 2 * nla_total_size(4);
 
+		/* grab encap info */
+		for_nexthops(fi) {
+			if (fi->fib_nh[0].lwtstate)
+				nh_encapsize += nla_total_size(
+						lw_tunnel_encap_size(
+						fi->fib_nh[0].lwtstate) + 2);
+
+		} endfor_nexthops(fi);
+
 		/* all nexthops are packed in a nested attribute */
-		payload += nla_total_size(fi->fib_nhs * nhsize);
+		payload += nla_total_size((fi->fib_nhs * nhsize) +
+					  nh_encapsize);
+
 	}
 
 	return payload;
@@ -875,6 +890,19 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	} else {
 		struct fib_nh *nh = fi->fib_nh;
 
+		if (cfg->fc_encap) {
+			struct lw_tunnel_state *lwtstate;
+			struct rtencap *encap = cfg->fc_encap;
+			int ret;
+
+			ret = lw_tunnel_build_state(encap, cfg->fc_encap_len,
+						    &lwtstate);
+			if (ret)
+				goto err_inval;
+
+			nh->lwtstate = lwtstate;
+		}
+
 		nh->nh_oif = cfg->fc_oif;
 		nh->nh_gw = cfg->fc_gw;
 		nh->nh_flags = cfg->fc_flags;
@@ -1034,6 +1062,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
 			goto nla_put_failure;
 #endif
+		if (fi->fib_nh->lwtstate)
+			lw_tunnel_dump_encap(skb,  fi->fib_nh->lwtstate);
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (fi->fib_nhs > 1) {
@@ -1061,6 +1091,8 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
 				goto nla_put_failure;
 #endif
+			if (nh->lwtstate)
+				lw_tunnel_dump_encap(skb, nh->lwtstate);
 			/* length of rtnetlink header + attributes */
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f605598..0ed7da0 100644
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
@@ -1403,6 +1404,8 @@ static void rt_set_nexthop(struct rtable *rt, __be32 daddr,
 #ifdef CONFIG_IP_ROUTE_CLASSID
 		rt->dst.tclassid = nh->nh_tclassid;
 #endif
+		if (nh->lwtstate)
+			rt->dst.lwtstate = nh->lwtstate;
 		if (unlikely(fnhe))
 			cached = rt_bind_exception(rt, fnhe, daddr);
 		else if (!(rt->dst.flags & DST_NOCACHE))
@@ -1624,6 +1627,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->dst.output = ip_output;
 
 	rt_set_nexthop(rth, daddr, res, fnhe, res->fi, res->type, itag);
+	if (rth->dst.lwtstate)
+		lwtunnel_dst_set_output(rth->dst.lwtstate, &rth->dst);
 	skb_dst_set(skb, &rth->dst);
 out:
 	err = 0;
-- 
1.7.10.4
