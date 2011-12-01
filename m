From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Thu, 01 Dec 2011 13:40:45 -0500 (EST)
Message-ID: <20111201.134045.1083297991862286043.davem@davemloft.net>
References: <20111108.143302.907625740390232791.davem@davemloft.net>
	<20111109120851.GA10138@secunet.com>
	<20111121075621.GF20943@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709Ab1LASlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 13:41:01 -0500
In-Reply-To: <20111121075621.GF20943@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Nov 2011 08:56:21 +0100

> I still don't see any problems with both of the patches.
> So I assume that both patches would fix the issue. However, 
> your patch is probaply less fragile as this does not depend
> on a certain value of dst->obsolete.

Great, thanks for checking it out.

I'll add the following to the net tree and queue it up for -stable
too.

--------------------
ipv4: Perform peer validation on cached route lookup.

Otherwise we won't notice the peer GENID change.

Reported-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 57e01bc..ca5e237 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1693,12 +1693,8 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 }
 
 
-static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
+static struct rtable *ipv4_validate_peer(struct rtable *rt)
 {
-	struct rtable *rt = (struct rtable *) dst;
-
-	if (rt_is_expired(rt))
-		return NULL;
 	if (rt->rt_peer_genid != rt_peer_genid()) {
 		struct inet_peer *peer;
 
@@ -1707,19 +1703,29 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 
 		peer = rt->peer;
 		if (peer) {
-			check_peer_pmtu(dst, peer);
+			check_peer_pmtu(&rt->dst, peer);
 
 			if (peer->redirect_genid != redirect_genid)
 				peer->redirect_learned.a4 = 0;
 			if (peer->redirect_learned.a4 &&
 			    peer->redirect_learned.a4 != rt->rt_gateway) {
-				if (check_peer_redir(dst, peer))
+				if (check_peer_redir(&rt->dst, peer))
 					return NULL;
 			}
 		}
 
 		rt->rt_peer_genid = rt_peer_genid();
 	}
+	return rt;
+}
+
+static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
+{
+	struct rtable *rt = (struct rtable *) dst;
+
+	if (rt_is_expired(rt))
+		return NULL;
+	dst = (struct dst_entry *) ipv4_validate_peer(rt);
 	return dst;
 }
 
@@ -2374,6 +2380,9 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			rth = ipv4_validate_peer(rth);
+			if (!rth)
+				continue;
 			if (noref) {
 				dst_use_noref(&rth->dst, jiffies);
 				skb_dst_set_noref(skb, &rth->dst);
@@ -2749,6 +2758,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			rth = ipv4_validate_peer(rth);
+			if (!rth)
+				continue;
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
-- 
1.7.7.3
