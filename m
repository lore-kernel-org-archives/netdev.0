From: Florian Larysch <fl@n621.de>
Subject: [PATCH net-next] net: ipv4: fix multipath RTM_GETROUTE behavior when iif is given
Date: Fri,  7 Apr 2017 14:42:20 +0200
Message-ID: <20170407124220.17483-1-fl@n621.de>
Cc: netdev@vger.kernel.org, Florian Larysch <fl@n621.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nyx.n621.de ([176.9.182.227]:60473 "EHLO nyx.n621.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754338AbdDGMnD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 08:43:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_rtm_getroute synthesizes a skeletal ICMP skb, which is passed to
ip_route_input when iif is given. If a multipath route is present for
the designated destination, fib_multipath_hash ends up being called with
that skb. However, as that skb contains no information beyond the
protocol type, the calculated hash does not match the one we would see
for a real packet.

There is currently no way to fix this for layer 4 hashing, as
RTM_GETROUTE doesn't have the necessary information to create layer 4
headers. To fix this for layer 3 hashing, set appropriate saddr/daddrs
in the skb and also change the protocol to UDP to avoid special
treatment for ICMP.

Signed-off-by: Florian Larysch <fl@n621.de>
---
 net/ipv4/route.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5dda1ef81c7e..5e1e60546fce 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2667,10 +2667,6 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 
-	/* Bugfix: need to give ip_route_input enough of an IP header to not gag. */
-	ip_hdr(skb)->protocol = IPPROTO_ICMP;
-	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
-
 	src = tb[RTA_SRC] ? nla_get_in_addr(tb[RTA_SRC]) : 0;
 	dst = tb[RTA_DST] ? nla_get_in_addr(tb[RTA_DST]) : 0;
 	iif = tb[RTA_IIF] ? nla_get_u32(tb[RTA_IIF]) : 0;
@@ -2680,6 +2676,15 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	else
 		uid = (iif ? INVALID_UID : current_uid());
 
+	/* Bugfix: need to give ip_route_input enough of an IP header to
+	 * not gag.
+	 */
+	ip_hdr(skb)->protocol = IPPROTO_UDP;
+	ip_hdr(skb)->saddr = src;
+	ip_hdr(skb)->daddr = dst;
+
+	skb_reserve(skb, MAX_HEADER + sizeof(struct iphdr));
+
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = dst;
 	fl4.saddr = src;
-- 
2.12.1
