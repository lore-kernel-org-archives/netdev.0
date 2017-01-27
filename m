From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 3/4] net: ipv6: Add support to dump multipath routes via RTA_MULTIPATH attribute
Date: Fri, 27 Jan 2017 15:20:57 -0800
Message-ID: <1485559258-4856-4-git-send-email-dsa@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34823 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
Received: by mail-pf0-f172.google.com with SMTP id f144so76354720pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:21:06 -0800 (PST)
In-Reply-To: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
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
    2001:db8::/120 metric 1024
            nexthop via 2001:db8:1::62  dev eth1 weight 1
            nexthop via 2001:db8:1::61  dev eth1 weight 1
            nexthop via 2001:db8:1::60  dev eth1 weight 1
            nexthop via 2001:db8:1::59  dev eth1 weight 1
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    ...

Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- dropped user API to opt-in to change

v2
- changed user api to opt in to new behavior from attribute appended to
  the request to requiring an rtmsg struct with the RTM_F_ALL_NEXTHOPS
  set

 include/net/netlink.h |   1 +
 net/ipv6/ip6_fib.c    |  16 ++++++-
 net/ipv6/route.c      | 127 +++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 126 insertions(+), 18 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index d3938f11ae52..b239fcd33d80 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -229,6 +229,7 @@ struct nl_info {
 	struct nlmsghdr		*nlh;
 	struct net		*nl_net;
 	u32			portid;
+	bool			skip_notify;
 };
 
 int netlink_rcv_skb(struct sk_buff *skb,
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index bcaf247232d7..2542794b2c64 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -318,6 +318,16 @@ static int fib6_dump_node(struct fib6_walker *w)
 			w->leaf = rt;
 			return 1;
 		}
+
+		/* if multipath routes are dumped in one route with
+		 * the RTA_MULTIPATH attribute, then jump rt to point
+		 * to the last sibling of this route (no need to dump
+		 * the sibling routes again)
+		 */
+		if (rt->rt6i_nsiblings)
+			rt = list_last_entry(&rt->rt6i_siblings,
+					     struct rt6_info,
+					     rt6i_siblings);
 	}
 	w->leaf = NULL;
 	return 0;
@@ -871,7 +881,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
+		if (!info->skip_notify)
+			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
 		if (!(fn->fn_flags & RTN_RTINFO)) {
@@ -897,7 +908,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		rt->rt6i_node = fn;
 		rt->dst.rt6_next = iter->dst.rt6_next;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
+		if (!info->skip_notify)
+			inet6_rt_notify(RTM_NEWROUTE, rt, info, NLM_F_REPLACE);
 		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 81e2b2a28806..747f333ae006 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3010,19 +3010,25 @@ static int ip6_route_info_append(struct list_head *rt6_nh_list,
 
 static int ip6_route_multipath_add(struct fib6_config *cfg)
 {
+	struct rt6_info *rt, *rt_first = NULL;
 	struct fib6_config r_cfg;
 	struct rtnexthop *rtnh;
-	struct rt6_info *rt;
 	struct rt6_nh *err_nh;
 	struct rt6_nh *nh, *nh_safe;
+	__u16 nlflags;
 	int remaining;
 	int attrlen;
 	int err = 1;
 	int nhn = 0;
+	int append = cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_APPEND;
 	int replace = (cfg->fc_nlinfo.nlh &&
 		       (cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_REPLACE));
 	LIST_HEAD(rt6_nh_list);
 
+	nlflags = replace ? NLM_F_REPLACE : NLM_F_CREATE;
+	if (append)
+		nlflags |= NLM_F_APPEND;
+
 	remaining = cfg->fc_mp_len;
 	rtnh = (struct rtnexthop *)cfg->fc_mp;
 
@@ -3065,9 +3071,20 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
+	/* for route append want to send separate notifications on
+	 * each add; for add and replace send one notification with
+	 * all nexthops
+	 */
+	if (!append)
+		cfg->fc_nlinfo.skip_notify = 1;
+
 	err_nh = NULL;
 	list_for_each_entry(nh, &rt6_nh_list, next) {
 		err = __ip6_ins_rt(nh->rt6_info, &cfg->fc_nlinfo, &nh->mxc);
+		/* save reference to first route for notification */
+		if (!rt_first && !err && !append)
+			rt_first = nh->rt6_info;
+
 		/* nh->rt6_info is used or freed at this point, reset to NULL*/
 		nh->rt6_info = NULL;
 		if (err) {
@@ -3089,9 +3106,21 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 		nhn++;
 	}
 
+	if (rt_first)
+		inet6_rt_notify(RTM_NEWROUTE, rt_first, &cfg->fc_nlinfo,
+				nlflags);
+
 	goto cleanup;
 
 add_errout:
+	/* send notification for routes that were added so far so
+	 * that the delete notifications sent by ip6_route_del in
+	 * the next block are coherent
+	 */
+	if (rt_first)
+		inet6_rt_notify(RTM_NEWROUTE, rt_first, &cfg->fc_nlinfo,
+				nlflags);
+
 	/* Delete routes that were already added */
 	list_for_each_entry(nh, &rt6_nh_list, next) {
 		if (err_nh == nh)
@@ -3198,6 +3227,60 @@ static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
 	       + lwtunnel_get_encap_size(rt->dst.lwtstate);
 }
 
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
+}
+
 static int rt6_fill_node(struct net *net,
 			 struct sk_buff *skb, struct rt6_info *rt,
 			 struct in6_addr *dst, struct in6_addr *src,
@@ -3249,11 +3332,6 @@ static int rt6_fill_node(struct net *net,
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
@@ -3317,17 +3395,36 @@ static int rt6_fill_node(struct net *net,
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
+	 * each as a nexthop within RTA_MULTIPATH. If this route
+	 * is an append, then only send the route that is added.
+	 */
+	if (rt->rt6i_nsiblings && !(flags & NLM_F_APPEND)) {
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
@@ -3336,8 +3433,6 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-	if (lwtunnel_fill_encap(skb, rt->dst.lwtstate) < 0)
-		goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
-- 
2.1.4
