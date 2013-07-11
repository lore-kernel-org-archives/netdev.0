From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv6: only static routes qualify for equal cost multipathing
Date: Thu, 11 Jul 2013 19:02:31 +0200
Message-ID: <20130711170231.GA11078@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39710 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab3GKRCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 13:02:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static routes in this case are non-expiring routes which did not get
configured by autoconf or by icmpv6 redirects.

The check for expiring routes is enhanced to also include the original
route. In case of autoconfiguration, this case should already be caught
by the RTF_ADDRCONF check. But this assumption may not hold in future
(and already did not in the past). So install this check as a safety net.

To make sure we actually get an ecmp route while searching for the first
one in this fib6_node's leafs, also make sure it matches the ecmp route
assumptions.

(the checkpatch error is intentional)

v2:
a) Also check RTF_ADDRCONF and RTF_DYNAMIC flags.
b) Only test rt for ecmp qualification once.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 192dd1a..2a23741 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -632,6 +632,19 @@ insert_above:
 	return ln;
 }
 
+static bool rt6_qualify_for_ecmp(struct rt6_info *rt0)
+{
+	struct rt6_info *rt;
+
+	if ((rt0->rt6i_flags & (RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC)) !=
+	    RTF_GATEWAY)
+		return false;
+
+	for (rt = rt0; rt && !(rt->rt6i_flags & RTF_EXPIRES);
+	     rt = (struct rt6_info *)rt->dst.from);
+	return !(rt && (rt->rt6i_flags & RTF_EXPIRES));
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -646,6 +659,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	int add = (!info->nlh ||
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
+	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
 
 	ins = &fn->leaf;
 
@@ -691,9 +705,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			 * To avoid long list, we only had siblings if the
 			 * route have a gateway.
 			 */
-			if (rt->rt6i_flags & RTF_GATEWAY &&
-			    !(rt->rt6i_flags & RTF_EXPIRES) &&
-			    !(iter->rt6i_flags & RTF_EXPIRES))
+			if (rt_can_ecmp &&
+			    rt6_qualify_for_ecmp(iter))
 				rt->rt6i_nsiblings++;
 		}
 
@@ -715,7 +728,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 		/* Find the first route that have the same metric */
 		sibling = fn->leaf;
 		while (sibling) {
-			if (sibling->rt6i_metric == rt->rt6i_metric) {
+			if (sibling->rt6i_metric == rt->rt6i_metric &&
+			    rt6_qualify_for_ecmp(sibling)) {
 				list_add_tail(&rt->rt6i_siblings,
 					      &sibling->rt6i_siblings);
 				break;
-- 
1.8.1.4
