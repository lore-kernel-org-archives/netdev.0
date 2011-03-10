From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Optimize flow initialization in input route lookup.
Date: Wed, 09 Mar 2011 20:42:49 -0800 (PST)
Message-ID: <20110309.204249.104057183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231Ab1CJEmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 23:42:12 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 964BB24C089
	for <netdev@vger.kernel.org>; Wed,  9 Mar 2011 20:42:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like in commit 44713b67db10c774f14280c129b0d5fd13c70cf2
("ipv4: Optimize flow initialization in output route lookup."
we can optimize the on-stack flow setup to only initialize
the members which are actually used.

Otherwise we bzero the entire structure, then initialize
explicitly the first half of it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92a24ea..ac32d8f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2081,12 +2081,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
-	struct flowi fl = { .fl4_dst	= daddr,
-			    .fl4_src	= saddr,
-			    .fl4_tos	= tos,
-			    .fl4_scope	= RT_SCOPE_UNIVERSE,
-			    .mark = skb->mark,
-			    .iif = dev->ifindex };
+	struct flowi fl;
 	unsigned	flags = 0;
 	u32		itag = 0;
 	struct rtable * rth;
@@ -2123,6 +2118,13 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	/*
 	 *	Now we are ready to route packet.
 	 */
+	fl.oif = 0;
+	fl.iif = dev->ifindex;
+	fl.mark = skb->mark;
+	fl.fl4_dst = daddr;
+	fl.fl4_src = saddr;
+	fl.fl4_tos = tos;
+	fl.fl4_scope = RT_SCOPE_UNIVERSE;
 	err = fib_lookup(net, &fl, &res);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
-- 
1.7.4.1

