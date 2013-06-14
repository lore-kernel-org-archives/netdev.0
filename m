From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2] ipv6: fix ecmp lookup when oif is specified
Date: Fri, 14 Jun 2013 10:32:58 +0200
Message-ID: <1371198778-26099-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20130613.173829.683328203745717078.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41460 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3FNIdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 04:33:25 -0400
In-Reply-To: <20130613.173829.683328203745717078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to skip ECMP lookup when oif is specified, but this implies
to check oif given by user when selecting another route.
When the new route does not match oif requirement, we simply keep the initial
one.

Spotted-by: dingzhi <zhi.ding@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: check oif requirement in rt6_multipath_select()

 net/ipv6/route.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad0aa6b..4a5d259 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -83,6 +83,7 @@ static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
 static void		rt6_do_redirect(struct dst_entry *dst, struct sock *sk,
 					struct sk_buff *skb);
+static int rt6_score_route(struct rt6_info *rt, int oif, int strict);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
 static struct rt6_info *rt6_add_route_info(struct net *net,
@@ -394,7 +395,8 @@ static int rt6_info_hash_nhsfn(unsigned int candidate_count,
 }
 
 static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
-					     struct flowi6 *fl6)
+					     struct flowi6 *fl6, int oif,
+					     int strict)
 {
 	struct rt6_info *sibling, *next_sibling;
 	int route_choosen;
@@ -408,6 +410,8 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 				&match->rt6i_siblings, rt6i_siblings) {
 			route_choosen--;
 			if (route_choosen == 0) {
+				if (rt6_score_route(sibling, oif, strict) < 0)
+					break;
 				match = sibling;
 				break;
 			}
@@ -742,8 +746,8 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 restart:
 	rt = fn->leaf;
 	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
-	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
-		rt = rt6_multipath_select(rt, fl6);
+	if (rt->rt6i_nsiblings)
+		rt = rt6_multipath_select(rt, fl6, fl6->flowi6_oif, flags);
 	BACKTRACK(net, &fl6->saddr);
 out:
 	dst_use(&rt->dst, jiffies);
@@ -875,8 +879,8 @@ restart_2:
 
 restart:
 	rt = rt6_select(fn, oif, strict | reachable);
-	if (rt->rt6i_nsiblings && oif == 0)
-		rt = rt6_multipath_select(rt, fl6);
+	if (rt->rt6i_nsiblings)
+		rt = rt6_multipath_select(rt, fl6, oif, strict | reachable);
 	BACKTRACK(net, &fl6->saddr);
 	if (rt == net->ipv6.ip6_null_entry ||
 	    rt->rt6i_flags & RTF_CACHE)
-- 
1.8.2.1
