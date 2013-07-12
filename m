From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v3] ipv6: only static routes qualify for equal cost multipathing
Date: Fri, 12 Jul 2013 23:46:33 +0200
Message-ID: <20130712214633.GQ12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42391 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab3GLVqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 17:46:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static routes in this case are non-expiring routes which did not get
configured by autoconf or by icmpv6 redirects.

To make sure we actually get an ecmp route while searching for the first
one in this fib6_node's leafs, also make sure it matches the ecmp route
assumptions.

v2:
a) Removed RTF_EXPIRE check in dst.from chain. The check of RTF_ADDRCONF
   already ensures that this route, even if added again without
   RTF_EXPIRES (in case of a RA announcement with infinite timeout),
   does not cause the rt6i_nsiblings logic to go wrong if a later RA
   updates the expiration time later.

v3:
a) Allow RTF_EXPIRES routes to enter the ecmp route set. We have to do so,
   because an pmtu event could update the RTF_EXPIRES flag and we would
   not count this route, if another route joins this set. We now filter
   only for RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC, which are flags that
   don't get changed after rt6_info construction.

Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 192dd1a..5fc9c7a 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -632,6 +632,12 @@ insert_above:
 	return ln;
 }
 
+static inline bool rt6_qualify_for_ecmp(struct rt6_info *rt)
+{
+	return (rt->rt6i_flags & (RTF_GATEWAY|RTF_ADDRCONF|RTF_DYNAMIC)) ==
+	       RTF_GATEWAY;
+}
+
 /*
  *	Insert routing information in a node.
  */
@@ -646,6 +652,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	int add = (!info->nlh ||
 		   (info->nlh->nlmsg_flags & NLM_F_CREATE));
 	int found = 0;
+	bool rt_can_ecmp = rt6_qualify_for_ecmp(rt);
 
 	ins = &fn->leaf;
 
@@ -691,9 +698,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
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
 
@@ -715,7 +721,8 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
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
