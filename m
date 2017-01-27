From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/4] net: ipv6: Allow shorthand delete of all nexthops in multipath route
Date: Fri, 27 Jan 2017 15:20:56 -0800
Message-ID: <1485559258-4856-3-git-send-email-dsa@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36759 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so76466877pfu.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:21:05 -0800 (PST)
In-Reply-To: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 allows multipath routes to be deleted using just the prefix and
length. For example:
    $ ip ro ls vrf red
    unreachable default metric 8192
    1.1.1.0/24
        nexthop via 10.100.1.254  dev eth1 weight 1
        nexthop via 10.11.200.2  dev eth11.200 weight 1
    10.11.200.0/24 dev eth11.200 proto kernel scope link src 10.11.200.3
    10.100.1.0/24 dev eth1 proto kernel scope link src 10.100.1.3

    $ ip ro del 1.1.1.0/24 vrf red

    $ ip ro ls vrf red
    unreachable default metric 8192
    10.11.200.0/24 dev eth11.200 proto kernel scope link src 10.11.200.3
    10.100.1.0/24 dev eth1 proto kernel scope link src 10.100.1.3

The same notation does not work with IPv6 because of how multipath routes
are implemented for IPv6. For IPv6 only the first nexthop of a multipath
route is deleted if the request contains only a prefix and length. This
leads to unnecessary complexity in userspace dealing with IPv6 multipath
routes.

This patch allows all nexthops to be deleted without specifying each one
in the delete request. Internally, this is done by walking the sibling
list of the route matching the specifications given (prefix, length,
metric, protocol, etc).

    $  ip -6 ro ls vrf red
    2001:db8::/120 via 2001:db8:1::62 dev eth1 metric 256  pref medium
    2001:db8::/120 via 2001:db8:1::61 dev eth1 metric 256  pref medium
    2001:db8::/120 via 2001:db8:1::60 dev eth1 metric 256  pref medium
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    ...

    $ ip -6 ro del vrf red 1111::1/120
    $ ip -6 ro ls vrf red
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    ...

Because IPv6 allows individual nexthops to be deleted without deleting
the entire route, the mutipath and non-multipath code paths have to be
discriminated so that all nexthops are only deleted for the latter case.
This is done by making the existing fc_type in fib6_config a u16 and then
adding a new u16 field with fc_delete_all_nh as the first bit.

Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- removed need for RTM_F_ALL_NEXTHOPS user api

v2
- fixed locking deleting route and its siblings as noted by DaveM

v2' (patch originally submitted standalone)
- switched examples to rfc 3849 documentation address per request
- changed delete loop to explicitly look at siblings list for
  first route matching specs given (metric, protocol, etc)

 include/net/ip6_fib.h |  4 +++-
 net/ipv6/route.c      | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a74e2aa40ef4..c979c878df1c 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -37,7 +37,9 @@ struct fib6_config {
 	int		fc_ifindex;
 	u32		fc_flags;
 	u32		fc_protocol;
-	u32		fc_type;	/* only 8 bits are used */
+	u16		fc_type;        /* only 8 bits are used */
+	u16		fc_delete_all_nh : 1,
+			__unused : 15;
 
 	struct in6_addr	fc_dst;
 	struct in6_addr	fc_src;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5046d2b24004..81e2b2a28806 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2143,6 +2143,34 @@ int ip6_del_rt(struct rt6_info *rt)
 	return __ip6_del_rt(rt, &info);
 }
 
+static int __ip6_del_rt_siblings(struct rt6_info *rt, struct fib6_config *cfg)
+{
+	struct nl_info *info = &cfg->fc_nlinfo;
+	struct fib6_table *table;
+	int err;
+
+	table = rt->rt6i_table;
+	write_lock_bh(&table->tb6_lock);
+
+	if (rt->rt6i_nsiblings && cfg->fc_delete_all_nh) {
+		struct rt6_info *sibling, *next_sibling;
+
+		list_for_each_entry_safe(sibling, next_sibling,
+					 &rt->rt6i_siblings,
+					 rt6i_siblings) {
+			err = fib6_del(sibling, info);
+			if (err)
+				goto out;
+		}
+	}
+
+	err = fib6_del(rt, info);
+out:
+	write_unlock_bh(&table->tb6_lock);
+	ip6_rt_put(rt);
+	return err;
+}
+
 static int ip6_route_del(struct fib6_config *cfg)
 {
 	struct fib6_table *table;
@@ -2179,7 +2207,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 
-			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
+			return __ip6_del_rt_siblings(rt, cfg);
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
@@ -3131,8 +3159,10 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	if (cfg.fc_mp)
 		return ip6_route_multipath_del(&cfg);
-	else
+	else {
+		cfg.fc_delete_all_nh = 1;
 		return ip6_route_del(&cfg);
+	}
 }
 
 static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
-- 
2.1.4
