From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 1/5] net: ipv6: Allow shorthand delete of all nexthops in multipath route
Date: Thu,  2 Feb 2017 12:37:08 -0800
Message-ID: <1486067832-16350-2-git-send-email-dsa@cumulusnetworks.com>
References: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36060 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdBBUhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:20 -0500
Received: by mail-pf0-f181.google.com with SMTP id 189so7691184pfu.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:20 -0800 (PST)
In-Reply-To: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
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
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    2001:db8:200::/120 via 2001:db8:1::2 dev eth1 metric 1024  pref medium
    2001:db8:200::/120 via 2001:db8:2::2 dev eth2 metric 1024  pref medium
    ...

    $ ip -6 ro del vrf red 2001:db8:200::/120

    $ ip -6 ro ls vrf red
    2001:db8:1::/120 dev eth1 proto kernel metric 256  pref medium
    2001:db8:2::/120 dev eth2 proto kernel metric 256  pref medium
    ...

Because IPv6 allows individual nexthops to be deleted without deleting
the entire route, the ip6_route_multipath_del and non-multipath code
path (ip6_route_del) have to be discriminated so that all nexthops are
only deleted for the latter case. This is done by making the existing
fc_type in fib6_config a u16 and then adding a new u16 field with
fc_delete_all_nh as the first bit.

Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- handle the case where a single nexthop is deleted without the
  RTA_MULTIPATH encoding:
     ip -6 ro del vrf red 2001:db8:200::/120 via 2001:db8:1::2

v3
- removed need for RTM_F_ALL_NEXTHOPS user api

v2
- fixed locking deleting route and its siblings as noted by DaveM

v2' (patch originally submitted standalone)
- switched examples to rfc 3849 documentation address per request
- changed delete loop to explicitly look at siblings list for
  first route matching specs given (metric, protocol, etc)

 include/net/ip6_fib.h |  4 +++-
 net/ipv6/route.c      | 38 ++++++++++++++++++++++++++++++++++++--
 2 files changed, 39 insertions(+), 3 deletions(-)

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
index 2563331b0532..466199cab8cc 100644
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
@@ -2179,7 +2207,11 @@ static int ip6_route_del(struct fib6_config *cfg)
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 
-			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
+			/* if gateway was specified only delete the one hop */
+			if (cfg->fc_flags & RTF_GATEWAY)
+				return __ip6_del_rt(rt, &cfg->fc_nlinfo);
+
+			return __ip6_del_rt_siblings(rt, cfg);
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
@@ -3141,8 +3173,10 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 
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
