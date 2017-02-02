From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 2/5] net: ipv6: Add support to dump multipath routes via RTA_MULTIPATH attribute
Date: Thu,  2 Feb 2017 12:37:09 -0800
Message-ID: <1486067832-16350-3-git-send-email-dsa@cumulusnetworks.com>
References: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36062 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdBBUhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:21 -0500
Received: by mail-pf0-f174.google.com with SMTP id 189so7691260pfu.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:21 -0800 (PST)
In-Reply-To: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 returns multipath routes as a series of individual routes making
their display and handling by userspace different and more complicated
than IPv4, putting the burden on the user to see that a route is part of
a multipath route and internally creating a multipath route if desired
(e.g., libnl does this as of commit 29b71371e764). This patch addresses
this difference, allowing multipath routes to be returned using the
RTA_MULTIPATH attribute.

The end result is that IPv6 multipath routes can be treated and displayed
in a format similar to IPv4:

    $ ip -6 ro ls vrf red
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:200::/120 metric 1024
	    nexthop via 2001:db8:1::2  dev eth1 weight 1
	    nexthop via 2001:db8:2::2  dev eth2 weight 1

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- reduced this patch to just RT_MULTIPATH encoding
- account for RT_MULTIPATH in rt6_nlmsg_size

v3
- dropped RTM_F_ALL_NEXTHOPS

v2
- changed user api to opt in to new behavior from attribute appended to
  the request to requiring an rtmsg struct with the RTM_F_ALL_NEXTHOPS
  set

 net/ipv6/ip6_fib.c |  10 +++++
 net/ipv6/route.c   | 112 +++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 105 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index febde6c112bf..1bf5e22fb95d 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -318,6 +318,16 @@ static int fib6_dump_node(struct fib6_walker *w)
 			w->leaf = rt;
 			return 1;
 		}
+
+		/* Multipath routes are dumped in one route with the
+		 * RTA_MULTIPATH attribute. Jump 'rt' to point to the
+		 * last sibling of this route (no need to dump the
+		 * sibling routes again)
+		 */
+		if (rt->rt6i_nsiblings)
+			rt = list_last_entry(&rt->rt6i_siblings,
+					     struct rt6_info,
+					     rt6i_siblings);
 	}
 	w->leaf = NULL;
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 466199cab8cc..8d9970163e33 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3194,8 +3194,20 @@ static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return ip6_route_add(&cfg);
 }
 
-static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
+static size_t rt6_nlmsg_size(struct rt6_info *rt)
 {
+	int nexthop_len = 0;
+
+	if (rt->rt6i_nsiblings) {
+		nexthop_len = nla_total_size(0)	 /* RTA_MULTIPATH */
+			    + NLA_ALIGN(sizeof(struct rtnexthop))
+			    + nla_total_size(16) /* RTA_GATEWAY */
+			    + nla_total_size(4)  /* RTA_OIF */
+			    + lwtunnel_get_encap_size(rt->dst.lwtstate);
+
+		nexthop_len *= rt->rt6i_nsiblings;
+	}
+
 	return NLMSG_ALIGN(sizeof(struct rtmsg))
 	       + nla_total_size(16) /* RTA_SRC */
 	       + nla_total_size(16) /* RTA_DST */
@@ -3209,7 +3221,62 @@ static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
 	       + nla_total_size(sizeof(struct rta_cacheinfo))
 	       + nla_total_size(TCP_CA_NAME_MAX) /* RTAX_CC_ALGO */
 	       + nla_total_size(1) /* RTA_PREF */
-	       + lwtunnel_get_encap_size(rt->dst.lwtstate);
+	       + lwtunnel_get_encap_size(rt->dst.lwtstate)
+	       + nexthop_len;
+}
+
+static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
+			    unsigned int *flags)
+{
+	if (!netif_running(rt->dst.dev) || !netif_carrier_ok(rt->dst.dev)) {
+		*flags |= RTNH_F_LINKDOWN;
+		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
+			*flags |= RTNH_F_DEAD;
+	}
+
+	if (rt->rt6i_flags & RTF_GATEWAY) {
+		if (nla_put_in6_addr(skb, RTA_GATEWAY, &rt->rt6i_gateway) < 0)
+			goto nla_put_failure;
+	}
+
+	if (rt->dst.dev &&
+	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
+		goto nla_put_failure;
+
+	if (rt->dst.lwtstate &&
+	    lwtunnel_fill_encap(skb, rt->dst.lwtstate) < 0)
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int rt6_add_nexthop(struct sk_buff *skb, struct rt6_info *rt)
+{
+	struct rtnexthop *rtnh;
+	unsigned int flags = 0;
+
+	rtnh = nla_reserve_nohdr(skb, sizeof(*rtnh));
+	if (!rtnh)
+		goto nla_put_failure;
+
+	rtnh->rtnh_hops = 0;
+	rtnh->rtnh_ifindex = rt->dst.dev ? rt->dst.dev->ifindex : 0;
+
+	if (rt6_nexthop_info(skb, rt, &flags) < 0)
+		goto nla_put_failure;
+
+	rtnh->rtnh_flags = flags;
+
+	/* length of rtnetlink header + attributes */
+	rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *)rtnh;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
 }
 
 static int rt6_fill_node(struct net *net,
@@ -3263,11 +3330,6 @@ static int rt6_fill_node(struct net *net,
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
-	if (!netif_running(rt->dst.dev) || !netif_carrier_ok(rt->dst.dev)) {
-		rtm->rtm_flags |= RTNH_F_LINKDOWN;
-		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
-			rtm->rtm_flags |= RTNH_F_DEAD;
-	}
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
@@ -3331,17 +3393,35 @@ static int rt6_fill_node(struct net *net,
 	if (rtnetlink_put_metrics(skb, metrics) < 0)
 		goto nla_put_failure;
 
-	if (rt->rt6i_flags & RTF_GATEWAY) {
-		if (nla_put_in6_addr(skb, RTA_GATEWAY, &rt->rt6i_gateway) < 0)
-			goto nla_put_failure;
-	}
-
-	if (rt->dst.dev &&
-	    nla_put_u32(skb, RTA_OIF, rt->dst.dev->ifindex))
-		goto nla_put_failure;
 	if (nla_put_u32(skb, RTA_PRIORITY, rt->rt6i_metric))
 		goto nla_put_failure;
 
+	/* For multipath routes, walk the siblings list and add
+	 * each as a nexthop within RTA_MULTIPATH.
+	 */
+	if (rt->rt6i_nsiblings) {
+		struct rt6_info *sibling, *next_sibling;
+		struct nlattr *mp;
+
+		mp = nla_nest_start(skb, RTA_MULTIPATH);
+		if (!mp)
+			goto nla_put_failure;
+
+		if (rt6_add_nexthop(skb, rt) < 0)
+			goto nla_put_failure;
+
+		list_for_each_entry_safe(sibling, next_sibling,
+					 &rt->rt6i_siblings, rt6i_siblings) {
+			if (rt6_add_nexthop(skb, sibling) < 0)
+				goto nla_put_failure;
+		}
+
+		nla_nest_end(skb, mp);
+	} else {
+		if (rt6_nexthop_info(skb, rt, &rtm->rtm_flags) < 0)
+			goto nla_put_failure;
+	}
+
 	expires = (rt->rt6i_flags & RTF_EXPIRES) ? rt->dst.expires - jiffies : 0;
 
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
@@ -3350,8 +3430,6 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-	if (lwtunnel_fill_encap(skb, rt->dst.lwtstate) < 0)
-		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
-- 
2.1.4
