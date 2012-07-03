From: David Miller <davem@davemloft.net>
Subject: [PATCH 17/19] ipv4: No need to set generic neighbour pointer.
Date: Tue, 03 Jul 2012 02:47:04 -0700 (PDT)
Message-ID: <20120703.024704.1366456224121869651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab2GCJrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:47:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BE9CA58411D
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:47:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Nobody reads it any longer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   62 +++---------------------------------------------------
 1 file changed, 3 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7453dfc..72e88c2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1111,16 +1111,6 @@ static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
 	return neigh_create(&arp_tbl, pkey, dev);
 }
 
-static int rt_bind_neighbour(struct rtable *rt)
-{
-	struct neighbour *n = ipv4_neigh_lookup(&rt->dst, NULL, &rt->rt_gateway);
-	if (IS_ERR(n))
-		return PTR_ERR(n);
-	dst_set_neighbour(&rt->dst, n);
-
-	return 0;
-}
-
 static struct rtable *rt_intern_hash(unsigned int hash, struct rtable *rt,
 				     struct sk_buff *skb, int ifindex)
 {
@@ -1129,7 +1119,6 @@ static struct rtable *rt_intern_hash(unsigned int hash, struct rtable *rt,
 	unsigned long	now;
 	u32 		min_score;
 	int		chain_length;
-	int attempts = !in_softirq();
 
 restart:
 	chain_length = 0;
@@ -1156,15 +1145,6 @@ restart:
 		 */
 
 		rt->dst.flags |= DST_NOCACHE;
-		if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-			int err = rt_bind_neighbour(rt);
-			if (err) {
-				net_warn_ratelimited("Neighbour table failure & not caching routes\n");
-				ip_rt_put(rt);
-				return ERR_PTR(err);
-			}
-		}
-
 		goto skip_hashing;
 	}
 
@@ -1247,40 +1227,6 @@ restart:
 		}
 	}
 
-	/* Try to bind route to arp only if it is output
-	   route or unicast forwarding path.
-	 */
-	if (rt->rt_type == RTN_UNICAST || rt_is_output_route(rt)) {
-		int err = rt_bind_neighbour(rt);
-		if (err) {
-			spin_unlock_bh(rt_hash_lock_addr(hash));
-
-			if (err != -ENOBUFS) {
-				rt_drop(rt);
-				return ERR_PTR(err);
-			}
-
-			/* Neighbour tables are full and nothing
-			   can be released. Try to shrink route cache,
-			   it is most likely it holds some neighbour records.
-			 */
-			if (attempts-- > 0) {
-				int saved_elasticity = ip_rt_gc_elasticity;
-				int saved_int = ip_rt_gc_min_interval;
-				ip_rt_gc_elasticity	= 1;
-				ip_rt_gc_min_interval	= 0;
-				rt_garbage_collect(&ipv4_dst_ops);
-				ip_rt_gc_min_interval	= saved_int;
-				ip_rt_gc_elasticity	= saved_elasticity;
-				goto restart;
-			}
-
-			net_warn_ratelimited("Neighbour table overflow\n");
-			rt_drop(rt);
-			return ERR_PTR(-ENOBUFS);
-		}
-	}
-
 	rt->dst.rt_next = rt_hash_table[hash].chain;
 
 	/*
@@ -1388,26 +1334,24 @@ static void check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
 {
 	struct rtable *rt = (struct rtable *) dst;
 	__be32 orig_gw = rt->rt_gateway;
-	struct neighbour *n, *old_n;
+	struct neighbour *n;
 
 	dst_confirm(&rt->dst);
 
 	rt->rt_gateway = peer->redirect_learned.a4;
 
 	n = ipv4_neigh_lookup(&rt->dst, NULL, &rt->rt_gateway);
-	if (IS_ERR(n)) {
+	if (!n) {
 		rt->rt_gateway = orig_gw;
 		return;
 	}
-	old_n = xchg(&rt->dst._neighbour, n);
-	if (old_n)
-		neigh_release(old_n);
 	if (!(n->nud_state & NUD_VALID)) {
 		neigh_event_send(n, NULL);
 	} else {
 		rt->rt_flags |= RTCF_REDIRECTED;
 		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 	}
+	neigh_release(n);
 }
 
 /* called in rcu_read_lock() section */
-- 
1.7.10
