From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 36/51] ipv6: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:26 -0400
Message-ID: <1333335521-1348-37-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab2DBDAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:17 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/addrconf.c   |   32 +++++++++++++++-----------------
 net/ipv6/fib6_rules.c |   15 +++++++--------
 net/ipv6/ip6mr.c      |    9 +++++----
 net/ipv6/ndisc.c      |    5 +++--
 net/ipv6/route.c      |   38 +++++++++++++++++++++++---------------
 5 files changed, 53 insertions(+), 46 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a3bb60..153060f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3989,14 +3989,14 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	struct nlattr *nla;
 	struct ifla_cacheinfo ci;
 
-	NLA_PUT_U32(skb, IFLA_INET6_FLAGS, idev->if_flags);
-
+	if (nla_put_u32(skb, IFLA_INET6_FLAGS, idev->if_flags))
+		goto nla_put_failure;
 	ci.max_reasm_len = IPV6_MAXPLEN;
 	ci.tstamp = cstamp_delta(idev->tstamp);
 	ci.reachable_time = jiffies_to_msecs(idev->nd_parms->reachable_time);
 	ci.retrans_time = jiffies_to_msecs(idev->nd_parms->retrans_time);
-	NLA_PUT(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci);
-
+	if (nla_put(skb, IFLA_INET6_CACHEINFO, sizeof(ci), &ci))
+		goto nla_put_failure;
 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
 	if (nla == NULL)
 		goto nla_put_failure;
@@ -4061,15 +4061,13 @@ static int inet6_fill_ifinfo(struct sk_buff *skb, struct inet6_dev *idev,
 	hdr->ifi_flags = dev_get_flags(dev);
 	hdr->ifi_change = 0;
 
-	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
-
-	if (dev->addr_len)
-		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
-
-	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
-	if (dev->ifindex != dev->iflink)
-		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
-
+	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
+	    (dev->addr_len &&
+	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
+	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
+	    (dev->ifindex != dev->iflink &&
+	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
+		goto nla_put_failure;
 	protoinfo = nla_nest_start(skb, IFLA_PROTINFO);
 	if (protoinfo == NULL)
 		goto nla_put_failure;
@@ -4182,12 +4180,12 @@ static int inet6_fill_prefix(struct sk_buff *skb, struct inet6_dev *idev,
 	if (pinfo->autoconf)
 		pmsg->prefix_flags |= IF_PREFIX_AUTOCONF;
 
-	NLA_PUT(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix);
-
+	if (nla_put(skb, PREFIX_ADDRESS, sizeof(pinfo->prefix), &pinfo->prefix))
+		goto nla_put_failure;
 	ci.preferred_time = ntohl(pinfo->prefered);
 	ci.valid_time = ntohl(pinfo->valid);
-	NLA_PUT(skb, PREFIX_CACHEINFO, sizeof(ci), &ci);
-
+	if (nla_put(skb, PREFIX_CACHEINFO, sizeof(ci), &ci))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b6c5731..01a2de1 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -215,14 +215,13 @@ static int fib6_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	frh->src_len = rule6->src.plen;
 	frh->tos = rule6->tclass;
 
-	if (rule6->dst.plen)
-		NLA_PUT(skb, FRA_DST, sizeof(struct in6_addr),
-			&rule6->dst.addr);
-
-	if (rule6->src.plen)
-		NLA_PUT(skb, FRA_SRC, sizeof(struct in6_addr),
-			&rule6->src.addr);
-
+	if ((rule6->dst.plen &&
+	     nla_put(skb, FRA_DST, sizeof(struct in6_addr),
+		     &rule6->dst.addr)) ||
+	    (rule6->src.plen &&
+	     nla_put(skb, FRA_SRC, sizeof(struct in6_addr),
+		     &rule6->src.addr)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 5aa3981..ff6ddf9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2216,14 +2216,15 @@ static int ip6mr_fill_mroute(struct mr6_table *mrt, struct sk_buff *skb,
 	rtm->rtm_src_len  = 128;
 	rtm->rtm_tos      = 0;
 	rtm->rtm_table    = mrt->id;
-	NLA_PUT_U32(skb, RTA_TABLE, mrt->id);
+	if (nla_put_u32(skb, RTA_TABLE, mrt->id))
+		goto nla_put_failure;
 	rtm->rtm_scope    = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = RTPROT_UNSPEC;
 	rtm->rtm_flags    = 0;
 
-	NLA_PUT(skb, RTA_SRC, 16, &c->mf6c_origin);
-	NLA_PUT(skb, RTA_DST, 16, &c->mf6c_mcastgrp);
-
+	if (nla_put(skb, RTA_SRC, 16, &c->mf6c_origin) ||
+	    nla_put(skb, RTA_DST, 16, &c->mf6c_mcastgrp))
+		goto nla_put_failure;
 	if (__ip6mr_fill_mroute(mrt, skb, c, rtm) < 0)
 		goto nla_put_failure;
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3dcdb81..1d6fb0c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1099,8 +1099,9 @@ static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
 
 	memcpy(ndmsg + 1, opt, opt->nd_opt_len << 3);
 
-	NLA_PUT(skb, NDUSEROPT_SRCADDR, sizeof(struct in6_addr),
-		&ipv6_hdr(ra)->saddr);
+	if (nla_put(skb, NDUSEROPT_SRCADDR, sizeof(struct in6_addr),
+		    &ipv6_hdr(ra)->saddr))
+		goto nla_put_failure;
 	nlmsg_end(skb, nlh);
 
 	rtnl_notify(skb, net, 0, RTNLGRP_ND_USEROPT, NULL, GFP_ATOMIC);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3992e26..4d70c06 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2413,7 +2413,8 @@ static int rt6_fill_node(struct net *net,
 	else
 		table = RT6_TABLE_UNSPEC;
 	rtm->rtm_table = table;
-	NLA_PUT_U32(skb, RTA_TABLE, table);
+	if (nla_put_u32(skb, RTA_TABLE, table))
+		goto nla_put_failure;
 	if (rt->rt6i_flags & RTF_REJECT)
 		rtm->rtm_type = RTN_UNREACHABLE;
 	else if (rt->rt6i_flags & RTF_LOCAL)
@@ -2436,16 +2437,20 @@ static int rt6_fill_node(struct net *net,
 		rtm->rtm_flags |= RTM_F_CLONED;
 
 	if (dst) {
-		NLA_PUT(skb, RTA_DST, 16, dst);
+		if (nla_put(skb, RTA_DST, 16, dst))
+			goto nla_put_failure;
 		rtm->rtm_dst_len = 128;
 	} else if (rtm->rtm_dst_len)
-		NLA_PUT(skb, RTA_DST, 16, &rt->rt6i_dst.addr);
+		if (nla_put(skb, RTA_DST, 16, &rt->rt6i_dst.addr))
+			goto nla_put_failure;
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src) {
-		NLA_PUT(skb, RTA_SRC, 16, src);
+		if (nla_put(skb, RTA_SRC, 16, src))
+			goto nla_put_failure;
 		rtm->rtm_src_len = 128;
-	} else if (rtm->rtm_src_len)
-		NLA_PUT(skb, RTA_SRC, 16, &rt->rt6i_src.addr);
+	} else if (rtm->rtm_src_len &&
+		   nla_put(skb, RTA_SRC, 16, &rt->rt6i_src.addr))
+		goto nla_put_failure;
 #endif
 	if (iif) {
 #ifdef CONFIG_IPV6_MROUTE
@@ -2463,17 +2468,20 @@ static int rt6_fill_node(struct net *net,
 			}
 		} else
 #endif
-			NLA_PUT_U32(skb, RTA_IIF, iif);
+			if (nla_put_u32(skb, RTA_IIF, iif))
+				goto nla_put_failure;
 	} else if (dst) {
 		struct in6_addr saddr_buf;
-		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) == 0)
-			NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		if (ip6_route_get_saddr(net, rt, dst, 0, &saddr_buf) == 0 &&
+		    nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
+			goto nla_put_failure;
 	}
 
 	if (rt->rt6i_prefsrc.plen) {
 		struct in6_addr saddr_buf;
 		saddr_buf = rt->rt6i_prefsrc.addr;
-		NLA_PUT(skb, RTA_PREFSRC, 16, &saddr_buf);
+		if (nla_put(skb, RTA_PREFSRC, 16, &saddr_buf))
+			goto nla_put_failure;
 	}
 
 	if (rtnetlink_put_metrics(skb, dst_metrics_ptr(&rt->dst)) < 0)
@@ -2489,11 +2497,11 @@ static int rt6_fill_node(struct net *net,
 	}
 	rcu_read_unlock();
 
-	if (rt->dst.dev)
-		NLA_PUT_U32(skb, RTA_OIF, rt->dst.dev->ifindex);
-
-	NLA_PUT_U32(skb, RTA_PRIORITY, rt->rt6i_metric);
-
+	if (rt->dst.dev &&
+	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
+		goto nla_put_failure;
+	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
+		goto nla_put_failure;
 	if (!(rt->rt6i_flags & RTF_EXPIRES))
 		expires = 0;
 	else if (rt->dst.expires - jiffies < INT_MAX)
-- 
1.7.7.6
