From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Remove redundant RTA_OIF in multipath routes
Date: Mon,  6 Mar 2017 15:57:31 -0800
Message-ID: <1488844651-12737-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36035 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdCGAG4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 19:06:56 -0500
Received: by mail-pf0-f173.google.com with SMTP id o126so19514116pfb.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 16:06:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dinesh reported that RTA_MULTIPATH nexthops are 8-bytes larger with IPv6
than IPv4. The recent refactoring for multipath support in netlink
messages does discriminate between non-multipath which needs the OIF
and multipath which adds a rtnexthop struct for each hop making the
RTA_OIF attribute redundant. Resolve by adding a flag to the info
function to skip the oif for multipath.

Fixes: beb1afac518d ("net: ipv6: Add support to dump multipath routes
       via RTA_MULTIPATH attribute")
Reported-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 229bfcc451ef..35c58b669ebd 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3299,7 +3299,6 @@ static size_t rt6_nlmsg_size(struct rt6_info *rt)
 		nexthop_len = nla_total_size(0)	 /* RTA_MULTIPATH */
 			    + NLA_ALIGN(sizeof(struct rtnexthop))
 			    + nla_total_size(16) /* RTA_GATEWAY */
-			    + nla_total_size(4)  /* RTA_OIF */
 			    + lwtunnel_get_encap_size(rt->dst.lwtstate);
 
 		nexthop_len *= rt->rt6i_nsiblings;
@@ -3323,7 +3322,7 @@ static size_t rt6_nlmsg_size(struct rt6_info *rt)
 }
 
 static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
-			    unsigned int *flags)
+			    unsigned int *flags, bool skip_oif)
 {
 	if (!netif_running(rt->dst.dev) || !netif_carrier_ok(rt->dst.dev)) {
 		*flags |= RTNH_F_LINKDOWN;
@@ -3336,7 +3335,8 @@ static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
 			goto nla_put_failure;
 	}
 
-	if (rt->dst.dev &&
+	/* not needed for multipath encoding b/c it has a rtnexthop struct */
+	if (!skip_oif && rt->dst.dev &&
 	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
 		goto nla_put_failure;
 
@@ -3350,6 +3350,7 @@ static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
 	return -EMSGSIZE;
 }
 
+/* add multipath next hop */
 static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt)
 {
 	struct rtnexthop *rtnh;
@@ -3362,7 +3363,7 @@ static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt)
 	rtnh->rtnh_hops = 0;
 	rtnh->rtnh_ifindex = rt->dst.dev ? rt->dst.dev->ifindex : 0;
 
-	if (rt6_nexthop_info(skb, rt, &flags) < 0)
+	if (rt6_nexthop_info(skb, rt, &flags, true) < 0)
 		goto nla_put_failure;
 
 	rtnh->rtnh_flags = flags;
@@ -3515,7 +3516,7 @@ static int rt6_fill_node(struct net *net,
 
 		nla_nest_end(skb, mp);
 	} else {
-		if (rt6_nexthop_info(skb, rt, &rtm->rtm_flags) < 0)
+		if (rt6_nexthop_info(skb, rt, &rtm->rtm_flags, false) < 0)
 			goto nla_put_failure;
 	}
 
-- 
2.1.4
