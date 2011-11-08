From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Tue, 08 Nov 2011 14:33:02 -0500 (EST)
Message-ID: <20111108.143302.907625740390232791.davem@davemloft.net>
References: <4E9E9366.1050702@cn.fujitsu.com>
	<20111019.153208.1743995025598236810.davem@davemloft.net>
	<20111108.141950.1576262997640523669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1KHTdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:33:16 -0500
In-Reply-To: <20111108.141950.1576262997640523669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 08 Nov 2011 14:19:50 -0500 (EST)

> I suspect that your real problem has nothing to do with UDP or RAW,
> but rather the issue is that entries already in the routing cache
> with a NULL peer need to be refreshed with peer information created
> in another context.

So you want something like this patch:

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 155138d..2966631 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1677,12 +1677,8 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	return 0;
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
 
@@ -1691,17 +1687,27 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 
 		peer = rt->peer;
 		if (peer) {
-			check_peer_pmtu(dst, peer);
+			check_peer_pmtu(&rt->dst, peer);
 
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
 
@@ -2349,6 +2355,9 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			rth = ipv4_validate_peer(rth);
+			if (!rth)
+				continue;
 			if (noref) {
 				dst_use_noref(&rth->dst, jiffies);
 				skb_dst_set_noref(skb, &rth->dst);
@@ -2724,6 +2733,9 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
+			rth = ipv4_validate_peer(rth);
+			if (!rth)
+				continue;
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
