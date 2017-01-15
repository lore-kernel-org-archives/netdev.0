From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: ipv6: Add option to dump multipath routes via RTA_MULTIPATH attribute
Date: Sun, 15 Jan 2017 12:07:06 -0800
Message-ID: <1484510826-2723-4-git-send-email-dsa@cumulusnetworks.com>
References: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ddutt@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34426 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdAOUHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 15:07:25 -0500
Received: by mail-pf0-f173.google.com with SMTP id e4so9247613pfg.1
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 12:07:25 -0800 (PST)
In-Reply-To: <1484510826-2723-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 returns multipath routes as a series of individual routes making
their display different than IPv4 and putting the burden on the user to
see that a route is part of a multipath route. This patch addresses this
difference, allowing users to request multipath routes to be returned
using the RTA_MULTIPATH attribute.

To maintain backwards compatibility, a user has to request the change
in behavior. Unfortunately, adding a flag to the header similar to a
previous patch does not work here as the netlink header for route dumps
can be either rtgenmsg or ifinfomsg. sysctl is the other commonly used
option for backwards compatibility but it is overly abused and is not
really appropriate for this situation since each request should be able
to specify the preference for the RTA_MULTIPATH attribute (e.g, one
command may understand RTA_MULTIPATH for IPv6 while another may not).

This patch relies on the existence of the RTA_MULTIPATH attribute
appeneded to the dump request -- similar to how attributes can be appended
to link dumps. Kernel side if the RTA_MULTIPATH attribute exists in the
dump request then the RTM_F_ALL_NEXTHOPS is set in a new rtm_flags
variable added to rt6_rtnl_dump_arg. The rtm_flags is then used by
rt6_dump_route to decided if the RTA_MULTIPATH attribute is used.

If it is enabled then rt6_fill_node walks the sibling list for a route
and encodes each as a next hop within RTA_MULTIPATH, and then
fib6_dump_node advances its cursor to the last sibling route in the
current route.

The end result is that IPv6 multipath routes can be displayed in a format
similar to IPv4:

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
 include/net/ip6_route.h |   1 +
 net/ipv6/ip6_fib.c      |  29 ++++++++++++-
 net/ipv6/route.c        | 107 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 116 insertions(+), 21 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 9dc2c182a263..7620974826a5 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -154,6 +154,7 @@ struct rt6_rtnl_dump_arg {
 	struct sk_buff *skb;
 	struct netlink_callback *cb;
 	struct net *net;
+	unsigned int rtm_flags;
 };
 
 int rt6_dump_route(struct rt6_info *rt, void *p_arg);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ef5485204522..429713819c9f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -308,16 +308,27 @@ static void __net_init fib6_tables_init(struct net *net)
 
 static int fib6_dump_node(struct fib6_walker *w)
 {
+	struct rt6_rtnl_dump_arg *arg = (struct rt6_rtnl_dump_arg *)w->args;
 	int res;
 	struct rt6_info *rt;
 
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
-		res = rt6_dump_route(rt, w->args);
+		res = rt6_dump_route(rt, arg);
 		if (res < 0) {
 			/* Frame is full, suspend walking */
 			w->leaf = rt;
 			return 1;
 		}
+
+		/* if multipath routes are dumped in one route with
+		 * the RTA_MULTIPATH attribute, then jump rt to point
+		 * to the last sibling of this route (no need to dump
+		 * the sibling routes again)
+		 */
+		if ((arg->rtm_flags & RTM_F_ALL_NEXTHOPS) && rt->rt6i_nsiblings)
+			rt = list_last_entry(&rt->rt6i_siblings,
+					     struct rt6_info,
+					     rt6i_siblings);
 	}
 	w->leaf = NULL;
 	return 0;
@@ -392,13 +403,16 @@ static int fib6_dump_table(struct fib6_table *table, struct sk_buff *skb,
 static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct nlattr *nlattr[RTA_MAX + 1];
 	unsigned int h, s_h;
 	unsigned int e = 0, s_e;
 	struct rt6_rtnl_dump_arg arg;
 	struct fib6_walker *w;
 	struct fib6_table *tb;
 	struct hlist_head *head;
+	unsigned int flags = 0;
 	int res = 0;
+	int hdrlen;
 
 	s_h = cb->args[0];
 	s_e = cb->args[1];
@@ -422,9 +436,22 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 		cb->args[2] = (long)w;
 	}
 
+	hdrlen = nlmsg_len(cb->nlh) < sizeof(struct ifinfomsg) ?
+		 sizeof(struct rtgenmsg) : sizeof(struct ifinfomsg);
+
+	if (nlmsg_parse(cb->nlh, hdrlen, nlattr, RTA_MAX, NULL) >= 0) {
+		/* existence of RTA_MULTIPATH attribute in dump
+		 * request means user wants multipath routes
+		 * returned using RTA_MULTIPATH attribute
+		 */
+		if (nlattr[RTA_MULTIPATH])
+			flags |= RTM_F_ALL_NEXTHOPS;
+	}
+
 	arg.skb = skb;
 	arg.cb = cb;
 	arg.net = net;
+	arg.rtm_flags = flags;
 	w->args = &arg;
 
 	rcu_read_lock();
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9f6f28ecd065..041ff245ba03 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3187,11 +3187,66 @@ static inline size_t rt6_nlmsg_size(struct rt6_info *rt)
 	       + lwtunnel_get_encap_size(rt->dst.lwtstate);
 }
 
+static int rt6_nexthop_info(struct sk_buff *skb, struct rt6_info *rt,
+			    unsigned int *flags)
+{
+	if (!netif_carrier_ok(rt->dst.dev)) {
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
 			 int iif, int type, u32 portid, u32 seq,
-			 int prefix, unsigned int flags)
+			 int prefix, unsigned int nlm_flags,
+			 unsigned int rtm_flags)
 {
 	u32 metrics[RTAX_MAX];
 	struct rtmsg *rtm;
@@ -3206,7 +3261,7 @@ static int rt6_fill_node(struct net *net,
 		}
 	}
 
-	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*rtm), flags);
+	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*rtm), nlm_flags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -3245,11 +3300,6 @@ static int rt6_fill_node(struct net *net,
 	else
 		rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
-	if (!netif_carrier_ok(rt->dst.dev)) {
-		rtm->rtm_flags |= RTNH_F_LINKDOWN;
-		if (rt->rt6i_idev->cnf.ignore_routes_with_linkdown)
-			rtm->rtm_flags |= RTNH_F_DEAD;
-	}
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_protocol = rt->rt6i_protocol;
 	if (rt->rt6i_flags & RTF_DYNAMIC)
@@ -3313,17 +3363,36 @@ static int rt6_fill_node(struct net *net,
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
 
+	/* if user wants nexthops included via the RTA_MULTIPATH
+	 * attribute, then walk the siblings list and add each
+	 * as a nexthop
+	 */
+	if ((rtm_flags & RTM_F_ALL_NEXTHOPS) && rt->rt6i_nsiblings) {
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
@@ -3332,8 +3401,6 @@ static int rt6_fill_node(struct net *net,
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-	lwtunnel_fill_encap(skb, rt->dst.lwtstate);
-
 	nlmsg_end(skb, nlh);
 	return 0;
 
@@ -3356,7 +3423,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 	return rt6_fill_node(arg->net,
 		     arg->skb, rt, NULL, NULL, 0, RTM_NEWROUTE,
 		     NETLINK_CB(arg->cb->skb).portid, arg->cb->nlh->nlmsg_seq,
-		     prefix, NLM_F_MULTI);
+		     prefix, NLM_F_MULTI, arg->rtm_flags);
 }
 
 static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
@@ -3447,7 +3514,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 
 	err = rt6_fill_node(net, skb, rt, &fl6.daddr, &fl6.saddr, iif,
 			    RTM_NEWROUTE, NETLINK_CB(in_skb).portid,
-			    nlh->nlmsg_seq, 0, 0);
+			    nlh->nlmsg_seq, 0, 0, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -3474,7 +3541,7 @@ void inet6_rt_notify(int event, struct rt6_info *rt, struct nl_info *info,
 		goto errout;
 
 	err = rt6_fill_node(net, skb, rt, NULL, NULL, 0,
-				event, info->portid, seq, 0, nlm_flags);
+			    event, info->portid, seq, 0, nlm_flags, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in rt6_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
-- 
2.1.4
