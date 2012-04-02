From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 38/51] ipv4: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:28 -0400
Message-ID: <1333335521-1348-39-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab2DBDAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:25 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/devinet.c       |   20 ++++++++----------
 net/ipv4/fib_rules.c     |   16 +++++++-------
 net/ipv4/fib_semantics.c |   47 +++++++++++++++++++++++++--------------------
 net/ipv4/ip_gre.c        |   23 +++++++++++----------
 net/ipv4/ipmr.c          |    9 ++++---
 net/ipv4/route.c         |   45 ++++++++++++++++++++++++++-----------------
 6 files changed, 87 insertions(+), 73 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index d4fad5c..3ffaad0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1267,17 +1267,15 @@ static int inet_fill_ifaddr(struct sk_buff *skb, struct in_ifaddr *ifa,
 	ifm->ifa_scope = ifa->ifa_scope;
 	ifm->ifa_index = ifa->ifa_dev->dev->ifindex;
 
-	if (ifa->ifa_address)
-		NLA_PUT_BE32(skb, IFA_ADDRESS, ifa->ifa_address);
-
-	if (ifa->ifa_local)
-		NLA_PUT_BE32(skb, IFA_LOCAL, ifa->ifa_local);
-
-	if (ifa->ifa_broadcast)
-		NLA_PUT_BE32(skb, IFA_BROADCAST, ifa->ifa_broadcast);
-
-	if (ifa->ifa_label[0])
-		NLA_PUT_STRING(skb, IFA_LABEL, ifa->ifa_label);
+	if ((ifa->ifa_address &&
+	     nla_put_be32(skb, IFA_ADDRESS, ifa->ifa_address)) ||
+	    (ifa->ifa_local &&
+	     nla_put_be32(skb, IFA_LOCAL, ifa->ifa_local)) ||
+	    (ifa->ifa_broadcast &&
+	     nla_put_be32(skb, IFA_BROADCAST, ifa->ifa_broadcast)) ||
+	    (ifa->ifa_label[0] &&
+	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)))
+		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 799fc79..2d043f7 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -221,15 +221,15 @@ static int fib4_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	frh->src_len = rule4->src_len;
 	frh->tos = rule4->tos;
 
-	if (rule4->dst_len)
-		NLA_PUT_BE32(skb, FRA_DST, rule4->dst);
-
-	if (rule4->src_len)
-		NLA_PUT_BE32(skb, FRA_SRC, rule4->src);
-
+	if ((rule4->dst_len &&
+	     nla_put_be32(skb, FRA_DST, rule4->dst)) ||
+	    (rule4->src_len &&
+	     nla_put_be32(skb, FRA_SRC, rule4->src)))
+		goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
-	if (rule4->tclassid)
-		NLA_PUT_U32(skb, FRA_FLOW, rule4->tclassid);
+	if (rule4->tclassid &&
+	    nla_put_u32(skb, FRA_FLOW, rule4->tclassid))
+		goto nla_put_failure;
 #endif
 	return 0;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index a8c5c1d..63aa48a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -932,33 +932,36 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 		rtm->rtm_table = tb_id;
 	else
 		rtm->rtm_table = RT_TABLE_COMPAT;
-	NLA_PUT_U32(skb, RTA_TABLE, tb_id);
+	if (nla_put_u32(skb, RTA_TABLE, tb_id))
+		goto nla_put_failure;
 	rtm->rtm_type = type;
 	rtm->rtm_flags = fi->fib_flags;
 	rtm->rtm_scope = fi->fib_scope;
 	rtm->rtm_protocol = fi->fib_protocol;
 
-	if (rtm->rtm_dst_len)
-		NLA_PUT_BE32(skb, RTA_DST, dst);
-
-	if (fi->fib_priority)
-		NLA_PUT_U32(skb, RTA_PRIORITY, fi->fib_priority);
-
+	if (rtm->rtm_dst_len &&
+	    nla_put_be32(skb, RTA_DST, dst))
+		goto nla_put_failure;
+	if (fi->fib_priority &&
+	    nla_put_u32(skb, RTA_PRIORITY, fi->fib_priority))
+		goto nla_put_failure;
 	if (rtnetlink_put_metrics(skb, fi->fib_metrics) < 0)
 		goto nla_put_failure;
 
-	if (fi->fib_prefsrc)
-		NLA_PUT_BE32(skb, RTA_PREFSRC, fi->fib_prefsrc);
-
+	if (fi->fib_prefsrc &&
+	    nla_put_be32(skb, RTA_PREFSRC, fi->fib_prefsrc))
+		goto nla_put_failure;
 	if (fi->fib_nhs == 1) {
-		if (fi->fib_nh->nh_gw)
-			NLA_PUT_BE32(skb, RTA_GATEWAY, fi->fib_nh->nh_gw);
-
-		if (fi->fib_nh->nh_oif)
-			NLA_PUT_U32(skb, RTA_OIF, fi->fib_nh->nh_oif);
+		if (fi->fib_nh->nh_gw &&
+		    nla_put_be32(skb, RTA_GATEWAY, fi->fib_nh->nh_gw))
+			goto nla_put_failure;
+		if (fi->fib_nh->nh_oif &&
+		    nla_put_u32(skb, RTA_OIF, fi->fib_nh->nh_oif))
+			goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
-		if (fi->fib_nh[0].nh_tclassid)
-			NLA_PUT_U32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid);
+		if (fi->fib_nh[0].nh_tclassid &&
+		    nla_put_u32(skb, RTA_FLOW, fi->fib_nh[0].nh_tclassid))
+			goto nla_put_failure;
 #endif
 	}
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -979,11 +982,13 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
 			rtnh->rtnh_hops = nh->nh_weight - 1;
 			rtnh->rtnh_ifindex = nh->nh_oif;
 
-			if (nh->nh_gw)
-				NLA_PUT_BE32(skb, RTA_GATEWAY, nh->nh_gw);
+			if (nh->nh_gw &&
+			    nla_put_be32(skb, RTA_GATEWAY, nh->nh_gw))
+				goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
-			if (nh->nh_tclassid)
-				NLA_PUT_U32(skb, RTA_FLOW, nh->nh_tclassid);
+			if (nh->nh_tclassid &&
+			    nla_put_u32(skb, RTA_FLOW, nh->nh_tclassid))
+				goto nla_put_failure;
 #endif
 			/* length of rtnetlink header + attributes */
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b57532d..02d07c6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1654,17 +1654,18 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm *p = &t->parms;
 
-	NLA_PUT_U32(skb, IFLA_GRE_LINK, p->link);
-	NLA_PUT_BE16(skb, IFLA_GRE_IFLAGS, p->i_flags);
-	NLA_PUT_BE16(skb, IFLA_GRE_OFLAGS, p->o_flags);
-	NLA_PUT_BE32(skb, IFLA_GRE_IKEY, p->i_key);
-	NLA_PUT_BE32(skb, IFLA_GRE_OKEY, p->o_key);
-	NLA_PUT_BE32(skb, IFLA_GRE_LOCAL, p->iph.saddr);
-	NLA_PUT_BE32(skb, IFLA_GRE_REMOTE, p->iph.daddr);
-	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);
-	NLA_PUT_U8(skb, IFLA_GRE_TOS, p->iph.tos);
-	NLA_PUT_U8(skb, IFLA_GRE_PMTUDISC, !!(p->iph.frag_off & htons(IP_DF)));
-
+	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS, p->i_flags) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
+	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
+	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
+	    nla_put_be32(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
+	    nla_put_be32(skb, IFLA_GRE_REMOTE, p->iph.daddr) ||
+	    nla_put_u8(skb, IFLA_GRE_TTL, p->iph.ttl) ||
+	    nla_put_u8(skb, IFLA_GRE_TOS, p->iph.tos) ||
+	    nla_put_u8(skb, IFLA_GRE_PMTUDISC,
+		       !!(p->iph.frag_off & htons(IP_DF))))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0518a4f..dcf4d7f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2120,15 +2120,16 @@ static int ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	rtm->rtm_src_len  = 32;
 	rtm->rtm_tos      = 0;
 	rtm->rtm_table    = mrt->id;
-	NLA_PUT_U32(skb, RTA_TABLE, mrt->id);
+	if (nla_put_u32(skb, RTA_TABLE, mrt->id))
+		goto nla_put_failure;
 	rtm->rtm_type     = RTN_MULTICAST;
 	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = RTPROT_UNSPEC;
 	rtm->rtm_flags    = 0;
 
-	NLA_PUT_BE32(skb, RTA_SRC, c->mfc_origin);
-	NLA_PUT_BE32(skb, RTA_DST, c->mfc_mcastgrp);
-
+	if (nla_put_be32(skb, RTA_SRC, c->mfc_origin) ||
+	    nla_put_be32(skb, RTA_DST, c->mfc_mcastgrp))
+		goto nla_put_failure;
 	if (__ipmr_fill_mroute(mrt, skb, c, rtm) < 0)
 		goto nla_put_failure;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3b110a4..e5647b4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2973,7 +2973,8 @@ static int rt_fill_info(struct net *net,
 	r->rtm_src_len	= 0;
 	r->rtm_tos	= rt->rt_key_tos;
 	r->rtm_table	= RT_TABLE_MAIN;
-	NLA_PUT_U32(skb, RTA_TABLE, RT_TABLE_MAIN);
+	if (nla_put_u32(skb, RTA_TABLE, RT_TABLE_MAIN))
+		goto nla_put_failure;
 	r->rtm_type	= rt->rt_type;
 	r->rtm_scope	= RT_SCOPE_UNIVERSE;
 	r->rtm_protocol = RTPROT_UNSPEC;
@@ -2981,31 +2982,38 @@ static int rt_fill_info(struct net *net,
 	if (rt->rt_flags & RTCF_NOTIFY)
 		r->rtm_flags |= RTM_F_NOTIFY;
 
-	NLA_PUT_BE32(skb, RTA_DST, rt->rt_dst);
-
+	if (nla_put_be32(skb, RTA_DST, rt->rt_dst))
+		goto nla_put_failure;
 	if (rt->rt_key_src) {
 		r->rtm_src_len = 32;
-		NLA_PUT_BE32(skb, RTA_SRC, rt->rt_key_src);
+		if (nla_put_be32(skb, RTA_SRC, rt->rt_key_src))
+			goto nla_put_failure;
 	}
-	if (rt->dst.dev)
-		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
+	if (rt->dst.dev &&
+	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
+		goto nla_put_failure;
 #ifdef CONFIG_IP_ROUTE_CLASSID
-	if (rt->dst.tclassid)
-		NLA_PUT_U32(skb, RTA_FLOW, rt->dst.tclassid);
+	if (rt->dst.tclassid &&
+	    nla_put_u32(skb, RTA_FLOW, rt->dst.tclassid))
+		goto nla_put_failure;
 #endif
-	if (rt_is_input_route(rt))
-		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_spec_dst);
-	else if (rt->rt_src != rt->rt_key_src)
-		NLA_PUT_BE32(skb, RTA_PREFSRC, rt->rt_src);
-
-	if (rt->rt_dst != rt->rt_gateway)
-		NLA_PUT_BE32(skb, RTA_GATEWAY, rt->rt_gateway);
+	if (rt_is_input_route(rt)) {
+		if (nla_put_be32(skb, RTA_PREFSRC, rt->rt_spec_dst))
+			goto nla_put_failure;
+	} else if (rt->rt_src != rt->rt_key_src) {
+		if (nla_put_be32(skb, RTA_PREFSRC, rt->rt_src))
+			goto nla_put_failure;
+	}
+	if (rt->rt_dst != rt->rt_gateway &&
+	    nla_put_be32(skb, RTA_GATEWAY, rt->rt_gateway))
+		goto nla_put_failure;
 
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
 		goto nla_put_failure;
 
-	if (rt->rt_mark)
-		NLA_PUT_BE32(skb, RTA_MARK, rt->rt_mark);
+	if (rt->rt_mark &&
+	    nla_put_be32(skb, RTA_MARK, rt->rt_mark))
+		goto nla_put_failure;
 
 	error = rt->dst.error;
 	if (peer) {
@@ -3046,7 +3054,8 @@ static int rt_fill_info(struct net *net,
 			}
 		} else
 #endif
-			NLA_PUT_U32(skb, RTA_IIF, rt->rt_iif);
+			if (nla_put_u32(skb, RTA_IIF, rt->rt_iif))
+				goto nla_put_failure;
 	}
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, id, ts, tsage,
-- 
1.7.7.6
