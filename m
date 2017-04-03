From: Florian Larysch <fl@n621.de>
Subject: [PATCH] net: ipv4: fix multipath RTM_GETROUTE behavior when iif is given
Date: Mon,  3 Apr 2017 16:46:09 +0200
Message-ID: <20170403144609.18716-1-fl@n621.de>
Cc: netdev@vger.kernel.org, Florian Larysch <fl@n621.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nyx.n621.de ([176.9.182.227]:41457 "EHLO nyx.n621.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752170AbdDCPLF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 11:11:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_rtm_getroute synthesizes a skeletal ICMP skb, which is passed to
ip_route_input when iif is given. If a multipath route is present for
the designated destination, ip_multipath_icmp_hash ends up being called,
which uses the source/destination addresses within the skb to calculate
a hash. However, those are not set in the synthetic skb, causing it to
return an arbitrary and incorrect result.

Instead, use UDP, which gets no such special treatment.

Signed-off-by: Florian Larysch <fl@n621.de>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8471dd116771..acd69cfe2951 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2620,7 +2620,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	skb_reset_network_header(skb);
 
 	/* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
-	ip_hdr(skb)->protocol = IPPROTO_ICMP;
+	ip_hdr(skb)->protocol = IPPROTO_UDP;
 	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
 
 	src = tb[RTA_SRC] ? nla_get_in_addr(tb[RTA_SRC]) : 0;
-- 
2.12.0
