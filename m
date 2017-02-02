From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 4/5] net: ipv6: Change notifications for multipath delete to RTA_MULTIPATH
Date: Thu,  2 Feb 2017 12:37:11 -0800
Message-ID: <1486067832-16350-5-git-send-email-dsa@cumulusnetworks.com>
References: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34133 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751670AbdBBUhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:23 -0500
Received: by mail-pf0-f179.google.com with SMTP id e4so7675610pfg.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:23 -0800 (PST)
In-Reply-To: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an entire multipath route is deleted using prefix and len (without any
nexthops), send a single RTM_DELROUTE notification with the full route
using RTA_MULTIPATH. This is done by generating the skb before the route
delete when all of the sibling routes are still present but sending it
after the route has been removed from the FIB. The skip_notify flag
is used to tell the lower fib code not to send notifications for the
individual nexthop routes.

If a route is deleted using RTA_MULTIPATH for any nexthops or a single
nexthop entry is deleted, then the nexthops are deleted one at a time with
notifications sent as each hop is deleted. This is necessary given that
IPv6 allows individual hops within a route to be deleted.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- new standalone patch for v4

 net/ipv6/ip6_fib.c |  3 ++-
 net/ipv6/route.c   | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 99c68ce6ef78..e4266746e4a2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1454,7 +1454,8 @@ static void fib6_del_route(struct fib6_node *fn, struct rt6_info **rtp,
 
 	fib6_purge_rt(rt, fn, net);
 
-	inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
+	if (!info->skip_notify)
+		inet6_rt_notify(RTM_DELROUTE, rt, info, 0);
 	rt6_release(rt);
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index b2f5c6f18e1d..d229c17118e5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -98,6 +98,12 @@ static void		rt6_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
 static void		rt6_dst_from_metrics_check(struct rt6_info *rt);
 static int rt6_score_route(struct rt6_info *rt, int oif, int strict);
+static size_t rt6_nlmsg_size(struct rt6_info *rt);
+static int rt6_fill_node(struct net *net,
+			 struct sk_buff *skb, struct rt6_info *rt,
+			 struct in6_addr *dst, struct in6_addr *src,
+			 int iif, int type, u32 portid, u32 seq,
+			 unsigned int flags);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
@@ -2146,6 +2152,7 @@ int ip6_del_rt(struct rt6_info *rt)
 static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 {
 	struct nl_info *info = &cfg->fc_nlinfo;
+	struct sk_buff *skb = NULL;
 	struct fib6_table *table;
 	int err;
 
@@ -2155,6 +2162,20 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 	if (rt->rt6i_nsiblings && cfg->fc_delete_all_nh) {
 		struct rt6_info *sibling, *next_sibling;
 
+		/* prefer to send a single notification with all hops */
+		skb = nlmsg_new(rt6_nlmsg_size(rt), gfp_any());
+		if (skb) {
+			u32 seq = info->nlh ? info->nlh->nlmsg_seq : 0;
+
+			if (rt6_fill_node(info->nl_net, skb, rt,
+					  NULL, NULL, 0, RTM_DELROUTE,
+					  info->portid, seq, 0) < 0) {
+				kfree_skb(skb);
+				skb = NULL;
+			} else
+				info->skip_notify = 1;
+		}
+
 		list_for_each_entry_safe(sibling, next_sibling,
 					 &rt->rt6i_siblings,
 					 rt6i_siblings) {
@@ -2168,6 +2189,11 @@ static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
 out:
 	write_unlock_bh(&table->tb6_lock);
 	ip6_rt_put(rt);
+
+	if (skb) {
+		rtnl_notify(skb, info->nl_net, info->portid, RTNLGRP_IPV6_ROUTE,
+			    info->nlh, gfp_any());
+	}
 	return err;
 }
 
-- 
2.1.4
