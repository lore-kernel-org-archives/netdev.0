From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] ipv6: reject locally assigned nexthop addresses
Date: Thu, 21 May 2015 00:25:41 +0200
Message-ID: <1432160741-3588-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:32975 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751882AbbETW0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:26:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip -6 addr add dead::1/128 dev eth0
sleep 5
ip -6 route add default via dead::1/128
-> fails
ip -6 addr add dead::1/128 dev eth0
ip -6 route add default via dead::1/128
-> succeeds

reason is that if (nonsensensical) route above is added,
dead::1 is still subject to DAD, so the route lookup will
pick eth0 as outdev due to the prefix route that is added before
DAD work is started.

Add explicit test that checks if nexthop gateway is a local address.

Link: https://bugzilla.redhat.com/show_bug.cgi?id=1167969
Signed-off-by: Florian Westphal <fw@strlen.de>
---
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6f4a350..98fce6f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1624,6 +1624,16 @@ int ip6_route_add(struct fib6_config *cfg)
 		int gwa_type;
 
 		gw_addr = &cfg->fc_gateway;
+
+		/* if gw_addr is local we will fail to detect this in case
+		 * address is still TENTATIVE (DAD in progress). rt6_lookup()
+		 * will return already-added prefix route via interface that
+		 * prefix route was assigned to, which might be non-loopback.
+		 */
+		err = -EINVAL;
+		if (ipv6_chk_addr_and_flags(net, gw_addr, NULL, 0, 0))
+			goto out;
+
 		rt->rt6i_gateway = *gw_addr;
 		gwa_type = ipv6_addr_type(gw_addr);
 
@@ -1637,7 +1647,6 @@ int ip6_route_add(struct fib6_config *cfg)
 			   (SIT, PtP, NBMA NOARP links) it is handy to allow
 			   some exceptions. --ANK
 			 */
-			err = -EINVAL;
 			if (!(gwa_type & IPV6_ADDR_UNICAST))
 				goto out;
 
-- 
2.0.5
