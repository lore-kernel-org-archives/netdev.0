From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] ipv6: don't reject link-local nexthop on other interface
Date: Fri,  7 Aug 2015 10:54:28 +0200
Message-ID: <1438937668-12757-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45901 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751837AbbHGIyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 04:54:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

48ed7b26faa7 ("ipv6: reject locally assigned nexthop addresses") is too
strict; it rejects following corner-case:

ip -6 route add default via fe80::1:2:3 dev eth1

[ where fe80::1:2:3 is assigned to a local interface, but not eth1 ]

Fix this by restricting search to given device if nh is linklocal.

Joint work with Hannes Frederic Sowa.

Fixes: 48ed7b26faa7 ("ipv6: reject locally assigned nexthop addresses")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv6/route.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6090969..9de4d2b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1831,6 +1831,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		int gwa_type;
 
 		gw_addr = &cfg->fc_gateway;
+		gwa_type = ipv6_addr_type(gw_addr);
 
 		/* if gw_addr is local we will fail to detect this in case
 		 * address is still TENTATIVE (DAD in progress). rt6_lookup()
@@ -1838,11 +1839,12 @@ int ip6_route_add(struct fib6_config *cfg)
 		 * prefix route was assigned to, which might be non-loopback.
 		 */
 		err = -EINVAL;
-		if (ipv6_chk_addr_and_flags(net, gw_addr, NULL, 0, 0))
+		if (ipv6_chk_addr_and_flags(net, gw_addr,
+					    gwa_type & IPV6_ADDR_LINKLOCAL ?
+					    dev : NULL, 0, 0))
 			goto out;
 
 		rt->rt6i_gateway = *gw_addr;
-		gwa_type = ipv6_addr_type(gw_addr);
 
 		if (gwa_type != (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST)) {
 			struct rt6_info *grt;
-- 
2.0.5
