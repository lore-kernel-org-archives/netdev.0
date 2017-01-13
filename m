From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv6: Allow shorthand delete of all nexthops in multipath route
Date: Fri, 13 Jan 2017 15:54:28 -0800
Message-ID: <1484351668-8962-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ddutt@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36513 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdAMXye (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:54:34 -0500
Received: by mail-pf0-f170.google.com with SMTP id 189so38203966pfu.3
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:54:34 -0800 (PST)
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
in the delete request by passing a new flag, RTM_F_ALL_NEXTHOPS, in
rtm_flags.

With this patch (and an updated iproute2 command):
    $  ip -6 ro ls vrf red
    1111::/120 via 2100:1::62 dev eth1 metric 1024  pref medium
    1111::/120 via 2100:1::61 dev eth1 metric 1024  pref medium
    1111::/120 via 2100:1::60 dev eth1 metric 1024  pref medium
    2100:1::/120 dev eth1 proto kernel metric 256  pref medium
    2100:1::/64 dev eth1 proto kernel metric 256  expires 86386sec pref medium
    ...

    $ ip -6 ro del vrf red 1111::1/120
    $ ip -6 ro ls vrf red
    2100:1::/120 dev eth1 proto kernel metric 256  pref medium
    2100:1::/64 dev eth1 proto kernel metric 256  expires 86382sec pref medium
    ...

The flag is added to fib6_config by converting fc_type to a u16 (as
noted fc_type only uses 8 bits). The new u16 hole is a bitmap with
fc_delete_all_nexthop as the first bit.

Suggested-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip6_fib.h          |  4 +++-
 include/uapi/linux/rtnetlink.h |  1 +
 net/ipv6/route.c               | 10 +++++++++-
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index a74e2aa40ef4..11ab99e87c5f 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -37,7 +37,9 @@ struct fib6_config {
 	int		fc_ifindex;
 	u32		fc_flags;
 	u32		fc_protocol;
-	u32		fc_type;	/* only 8 bits are used */
+	u16		fc_type;	/* only 8 bits are used */
+	u16		fc_delete_all_nexthop : 1,
+			__unused : 15;
 
 	struct in6_addr	fc_dst;
 	struct in6_addr	fc_src;
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 8c93ad1ef9ab..7fb206bc42f9 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -276,6 +276,7 @@ enum rt_scope_t {
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
 #define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
+#define RTM_F_ALL_NEXTHOPS	0x2000	/* delete all nexthops (IPv6) */
 
 /* Reserved table identifiers */
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ce5aaf448c54..8bb5f6a35ba8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2154,6 +2154,7 @@ static int ip6_route_del(struct fib6_config *cfg)
 	if (!table)
 		return err;
 
+again:
 	read_lock_bh(&table->tb6_lock);
 
 	fn = fib6_locate(&table->tb6_root,
@@ -2179,7 +2180,11 @@ static int ip6_route_del(struct fib6_config *cfg)
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 
-			return __ip6_del_rt(rt, &cfg->fc_nlinfo);
+			err = __ip6_del_rt(rt, &cfg->fc_nlinfo);
+			if (err || !cfg->fc_delete_all_nexthop)
+				return err;
+
+			goto again;
 		}
 	}
 	read_unlock_bh(&table->tb6_lock);
@@ -2849,6 +2854,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (rtm->rtm_flags & RTM_F_CLONED)
 		cfg->fc_flags |= RTF_CACHE;
 
+	if (rtm->rtm_flags & RTM_F_ALL_NEXTHOPS)
+		cfg->fc_delete_all_nexthop = 1;
+
 	cfg->fc_nlinfo.portid = NETLINK_CB(skb).portid;
 	cfg->fc_nlinfo.nlh = nlh;
 	cfg->fc_nlinfo.nl_net = sock_net(skb->sk);
-- 
2.1.4
