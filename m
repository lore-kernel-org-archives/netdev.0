From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 3/5] net: ipv6: Change notifications for multipath add to RTA_MULTIPATH
Date: Thu,  2 Feb 2017 12:37:10 -0800
Message-ID: <1486067832-16350-4-git-send-email-dsa@cumulusnetworks.com>
References: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36064 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdBBUhW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:22 -0500
Received: by mail-pf0-f176.google.com with SMTP id 189so7691350pfu.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:22 -0800 (PST)
In-Reply-To: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ip6_route_multipath_add to send one notifciation with the full
route encoded with RTA_MULTIPATH instead of a series of individual routes.
This is done by adding a skip_notify flag to the nl_info struct. The
flag is used to skip sending of the notification in the fib code that
actually inserts the route. Once the full route has been added, a
notification is generated with all nexthops.

ip6_route_multipath_add handles 3 use cases: new routes, route replace,
and route append. The multipath notification generated needs to be
consistent with the order of the nexthops and it should be consistent
with the order in a FIB dump which means the route with the first nexthop
needs to be used as the route reference. For the first 2 cases (new and
replace), a reference to the route used to send the notification is
obtained by saving the first route added. For the append case, the last
route added is used to loop back to its first sibling route which is
the first nexthop in the multipath route.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- new standalone patch in v4 of set

 include/net/netlink.h |  1 +
 net/ipv6/ip6_fib.c    |  6 ++++--
 net/ipv6/route.c      | 50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 54 insertions(+), 3 deletions(-)

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
index 1bf5e22fb95d..99c68ce6ef78 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -881,7 +881,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		*ins = rt;
 		rt->rt6i_node = fn;
 		atomic_inc(&rt->rt6i_ref);
-		inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
+		if (!info->skip_notify)
+			inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
 
 		if (!(fn->fn_flags & RTN_RTINFO)) {
@@ -907,7 +908,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
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
index 8d9970163e33..b2f5c6f18e1d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3022,13 +3022,37 @@ static int ip6_route_info_append(struct list_head *rt6_nh_list,
 	return 0;
 }
 
+static void ip6_route_mpath_notify(struct rt6_info *rt,
+				   struct rt6_info *rt_last,
+				   struct nl_info *info,
+				   __u16 nlflags)
+{
+	/* if this is an APPEND route, then rt points to the first route
+	 * inserted and rt_last points to last route inserted. Userspace
+	 * wants a consistent dump of the route which starts at the first
+	 * nexthop. Since sibling routes are always added at the end of
+	 * the list, find the first sibling of the last route appended
+	 */
+	if ((nlflags & NLM_F_APPEND) && rt_last && rt_last->rt6i_nsiblings) {
+		rt = list_first_entry(&rt_last->rt6i_siblings,
+				      struct rt6_info,
+				      rt6i_siblings);
+	}
+
+	if (rt)
+		inet6_rt_notify(RTM_NEWROUTE, rt, info, nlflags);
+}
+
 static int ip6_route_multipath_add(struct fib6_config *cfg)
 {
+	struct rt6_info *rt_notif = NULL, *rt_last = NULL;
+	struct nl_info *info = &cfg->fc_nlinfo;
 	struct fib6_config r_cfg;
 	struct rtnexthop *rtnh;
 	struct rt6_info *rt;
 	struct rt6_nh *err_nh;
 	struct rt6_nh *nh, *nh_safe;
+	__u16 nlflags;
 	int remaining;
 	int attrlen;
 	int err = 1;
@@ -3037,6 +3061,10 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 		       (cfg->fc_nlinfo.nlh->nlmsg_flags & NLM_F_REPLACE));
 	LIST_HEAD(rt6_nh_list);
 
+	nlflags = replace ? NLM_F_REPLACE : NLM_F_CREATE;
+	if (info->nlh && info->nlh->nlmsg_flags & NLM_F_APPEND)
+		nlflags |= NLM_F_APPEND;
+
 	remaining = cfg->fc_mp_len;
 	rtnh = (struct rtnexthop *)cfg->fc_mp;
 
@@ -3079,9 +3107,20 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 		rtnh = rtnh_next(rtnh, &remaining);
 	}
 
+	/* for add and replace send one notification with all nexthops.
+	 * Skip the notification in fib6_add_rt2node and send one with
+	 * the full route when done
+	 */
+	info->skip_notify = 1;
+
 	err_nh = NULL;
 	list_for_each_entry(nh, &rt6_nh_list, next) {
-		err = __ip6_ins_rt(nh->rt6_info, &cfg->fc_nlinfo, &nh->mxc);
+		rt_last = nh->rt6_info;
+		err = __ip6_ins_rt(nh->rt6_info, info, &nh->mxc);
+		/* save reference to first route for notification */
+		if (!rt_notif && !err)
+			rt_notif = nh->rt6_info;
+
 		/* nh->rt6_info is used or freed at this point, reset to NULL*/
 		nh->rt6_info = NULL;
 		if (err) {
@@ -3103,9 +3142,18 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 		nhn++;
 	}
 
+	/* success ... tell user about new route */
+	ip6_route_mpath_notify(rt_notif, rt_last, info, nlflags);
 	goto cleanup;
 
 add_errout:
+	/* send notification for routes that were added so that
+	 * the delete notifications sent by ip6_route_del are
+	 * coherent
+	 */
+	if (rt_notif)
+		ip6_route_mpath_notify(rt_notif, rt_last, info, nlflags);
+
 	/* Delete routes that were already added */
 	list_for_each_entry(nh, &rt6_nh_list, next) {
 		if (err_nh == nh)
-- 
2.1.4
