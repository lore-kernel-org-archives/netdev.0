From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Perform peer validation on cached route lookup.
Date: Mon, 05 Dec 2011 13:22:06 -0500 (EST)
Message-ID: <20111205.132206.2106501085910587511.davem@davemloft.net>
References: <20111205132714.GA27452@elgon.mountain>
	<20111205133153.GC3374@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565Ab1LESWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 13:22:12 -0500
In-Reply-To: <20111205133153.GC3374@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 5 Dec 2011 16:31:54 +0300

> The continue in __ip_route_output_key() has the same issue as well.

Thanks Dan.

The best thing to do is simply to not let ipv4_validate_peer()
fail, and just return void.

The only case that could "fail" is when we check the redirect state
and can't lookup a new valid neighbour for the new gateway.  We can
just restore the original gateway, and use that this time, and the
next use of this route will try again to get the neighbour anyways.

--------------------
ipv4: Fix peer validation on cached lookup.

If ipv4_valdiate_peer() fails during a cached entry lookup,
we'll NULL derer since the loop iterator assumes rth is not
NULL.

Letting this be handled as a failure is just bogus, so just make it
not fail.  If we have trouble getting a non-NULL neighbour for the
redirected gateway, just restore the original gateway and continue.

The very next use of this cached route will try again.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   35 +++++++++++++----------------------
 1 files changed, 13 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 588d971..46af623 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1310,7 +1310,7 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
+static void check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
@@ -1321,21 +1321,19 @@ static int check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 	rt->rt_gateway = peer->redirect_learned.a4;
 
 	n = ipv4_neigh_lookup(&rt->dst, &rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
+	if (IS_ERR(n)) {
+		rt->rt_gateway = orig_gw;
+		return;
+	}
 	old_n = xchg(&rt->dst._neighbour, n);
 	if (old_n)
 		neigh_release(old_n);
-	if (!n || !(n->nud_state & NUD_VALID)) {
-		if (n)
-			neigh_event_send(n, NULL);
-		rt->rt_gateway = orig_gw;
-		return -EAGAIN;
+	if (!(n->nud_state & NUD_VALID)) {
+		neigh_event_send(n, NULL);
 	} else {
 		rt->rt_flags |= RTCF_REDIRECTED;
 		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 	}
-	return 0;
 }
 
 /* called in rcu_read_lock() section */
@@ -1693,7 +1691,7 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 }
 
 
-static struct rtable *ipv4_validate_peer(struct rtable *rt)
+static void ipv4_validate_peer(struct rtable *rt)
 {
 	if (rt->rt_peer_genid != rt_peer_genid()) {
 		struct inet_peer *peer;
@@ -1708,15 +1706,12 @@ static struct rtable *ipv4_validate_peer(struct rtable *rt)
 			if (peer->redirect_genid != redirect_genid)
 				peer->redirect_learned.a4 = 0;
 			if (peer->redirect_learned.a4 &&
-			    peer->redirect_learned.a4 != rt->rt_gateway) {
-				if (check_peer_redir(&rt->dst, peer))
-					return NULL;
-			}
+			    peer->redirect_learned.a4 != rt->rt_gateway)
+				check_peer_redir(&rt->dst, peer);
 		}
 
 		rt->rt_peer_genid = rt_peer_genid();
 	}
-	return rt;
 }
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
@@ -1725,7 +1720,7 @@ static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 
 	if (rt_is_expired(rt))
 		return NULL;
-	dst = (struct dst_entry *) ipv4_validate_peer(rt);
+	ipv4_validate_peer(rt);
 	return dst;
 }
 
@@ -2380,9 +2375,7 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			rth = ipv4_validate_peer(rth);
-			if (!rth)
-				continue;
+			ipv4_validate_peer(rth);
 			if (noref) {
 				dst_use_noref(&rth->dst, jiffies);
 				skb_dst_set_noref(skb, &rth->dst);
@@ -2758,9 +2751,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			rth = ipv4_validate_peer(rth);
-			if (!rth)
-				continue;
+			ipv4_validate_peer(rth);
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
-- 
1.7.7.3
