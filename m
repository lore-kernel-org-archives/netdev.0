From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Do not consider link state for nexthop validation
Date: Mon, 24 Oct 2016 12:27:23 -0700
Message-ID: <1477337243-10650-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36539 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753095AbcJXT1a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 15:27:30 -0400
Received: by mail-pf0-f176.google.com with SMTP id e6so103851453pfk.3
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 12:27:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to IPv4, do not consider link state when validating next hops.

Currently, if the link is down default routes can fail to insert:
 $ ip -6 ro add vrf blue default via 2100:2::64 dev eth2
 RTNETLINK answers: No route to host

With this patch the command succeeds.

Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip6_route.h | 1 +
 net/ipv6/route.c        | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index e0cd318d5103..f83e78d071a3 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -32,6 +32,7 @@ struct route_info {
 #define RT6_LOOKUP_F_SRCPREF_TMP	0x00000008
 #define RT6_LOOKUP_F_SRCPREF_PUBLIC	0x00000010
 #define RT6_LOOKUP_F_SRCPREF_COA	0x00000020
+#define RT6_LOOKUP_F_IGNORE_LINKSTATE	0x00000040
 
 /* We do not (yet ?) support IPv6 jumbograms (RFC 2675)
  * Unlike IPv4, hdr->seg_len doesn't include the IPv6 header
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3ac19eb81a86..947ed1ded026 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -658,7 +658,8 @@ static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
 	struct net_device *dev = rt->dst.dev;
 
 	if (dev && !netif_carrier_ok(dev) &&
-	    idev->cnf.ignore_routes_with_linkdown)
+	    idev->cnf.ignore_routes_with_linkdown &&
+	    !(strict & RT6_LOOKUP_F_IGNORE_LINKSTATE))
 		goto out;
 
 	if (rt6_check_expired(rt))
@@ -1052,6 +1053,7 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	int strict = 0;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
+	strict |= flags & RT6_LOOKUP_F_IGNORE_LINKSTATE;
 	if (net->ipv6.devconf_all->forwarding == 0)
 		strict |= RT6_LOOKUP_F_REACHABLE;
 
@@ -1791,7 +1793,7 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
 	};
 	struct fib6_table *table;
 	struct rt6_info *rt;
-	int flags = RT6_LOOKUP_F_IFACE;
+	int flags = RT6_LOOKUP_F_IFACE | RT6_LOOKUP_F_IGNORE_LINKSTATE;
 
 	table = fib6_get_table(net, cfg->fc_table);
 	if (!table)
-- 
2.1.4
