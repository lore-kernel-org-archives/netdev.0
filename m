From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/16] ipv4: Maintain redirect and PMTU info in struct
 rtable again.
Date: Tue, 10 Jul 2012 08:07:46 -0700 (PDT)
Message-ID: <20120710.080746.694016763983176902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab2GJPHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:47 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D2F5058662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Maintaining this in the inetpeer entries was not the right way to do
this at all.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h  |    4 -
 include/net/route.h     |    2 +-
 net/ipv4/inetpeer.c     |    3 -
 net/ipv4/route.c        |  185 ++++++++++-------------------------------------
 net/ipv4/xfrm4_policy.c |    1 +
 5 files changed, 41 insertions(+), 154 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 1119f6f..53f464d 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -36,10 +36,6 @@ struct inet_peer {
 	u32			metrics[RTAX_MAX];
 	u32			rate_tokens;	/* rate limiting for ICMP */
 	unsigned long		rate_last;
-	unsigned long		pmtu_expires;
-	u32			pmtu_orig;
-	u32			pmtu_learned;
-	struct inetpeer_addr_base redirect_learned;
 	union {
 		struct list_head	gc_list;
 		struct rcu_head     gc_rcu;
diff --git a/include/net/route.h b/include/net/route.h
index 635d7a9..c274494 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -65,7 +65,7 @@ struct rtable {
 	__be32			rt_gateway;
 
 	/* Miscellaneous cached information */
-	u32			rt_peer_genid;
+	u32			rt_pmtu;
 	unsigned long		_peer; /* long-living peer info */
 	struct fib_info		*fi; /* for client ref to shared metrics */
 };
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index f457bcb..e1e0a4e 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -511,9 +511,6 @@ relookup:
 		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		p->rate_last = 0;
-		p->pmtu_expires = 0;
-		p->pmtu_orig = 0;
-		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
 		INIT_LIST_HEAD(&p->gc_list);
 
 		/* Link the node. */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 67b0874..677d652 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -669,7 +669,7 @@ static inline int rt_fast_clean(struct rtable *rth)
 static inline int rt_valuable(struct rtable *rth)
 {
 	return (rth->rt_flags & (RTCF_REDIRECTED | RTCF_NOTIFY)) ||
-		(rt_has_peer(rth) && rt_peer_ptr(rth)->pmtu_expires);
+		rth->dst.expires;
 }
 
 static int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
@@ -1242,13 +1242,6 @@ skip_hashing:
 	return rt;
 }
 
-static atomic_t __rt_peer_genid = ATOMIC_INIT(0);
-
-static u32 rt_peer_genid(void)
-{
-	return atomic_read(&__rt_peer_genid);
-}
-
 void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 {
 	struct inet_peer_base *base;
@@ -1262,8 +1255,6 @@ void rt_bind_peer(struct rtable *rt, __be32 daddr, int create)
 	if (peer) {
 		if (!rt_set_peer(rt, peer))
 			inet_putpeer(peer);
-		else
-			rt->rt_peer_genid = rt_peer_genid();
 	}
 }
 
@@ -1323,30 +1314,6 @@ static void rt_del(unsigned int hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
-static void check_peer_redir(struct dst_entry *dst, struct inet_peer *peer)
-{
-	struct rtable *rt = (struct rtable *) dst;
-	__be32 orig_gw = rt->rt_gateway;
-	struct neighbour *n;
-
-	dst_confirm(&rt->dst);
-
-	rt->rt_gateway = peer->redirect_learned.a4;
-
-	n = ipv4_neigh_lookup(&rt->dst, NULL, &rt->rt_gateway);
-	if (!n) {
-		rt->rt_gateway = orig_gw;
-		return;
-	}
-	if (!(n->nud_state & NUD_VALID)) {
-		neigh_event_send(n, NULL);
-	} else {
-		rt->rt_flags |= RTCF_REDIRECTED;
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-	}
-	neigh_release(n);
-}
-
 /* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
@@ -1355,7 +1322,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	__be32 skeys[2] = { saddr, 0 };
 	int    ikeys[2] = { dev->ifindex, 0 };
-	struct inet_peer *peer;
 	struct net *net;
 
 	if (!in_dev)
@@ -1388,6 +1354,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			rthp = &rt_hash_table[hash].chain;
 
 			while ((rt = rcu_dereference(*rthp)) != NULL) {
+				struct neighbour *n;
+
 				rthp = &rt->dst.rt_next;
 
 				if (rt->rt_key_dst != daddr ||
@@ -1401,13 +1369,16 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				    rt->rt_gateway != old_gw)
 					continue;
 
-				peer = rt_get_peer_create(rt, rt->rt_dst);
-				if (peer) {
-					if (peer->redirect_learned.a4 != new_gw) {
-						peer->redirect_learned.a4 = new_gw;
-						atomic_inc(&__rt_peer_genid);
+				n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
+				if (n) {
+					if (!(n->nud_state & NUD_VALID)) {
+						neigh_event_send(n, NULL);
+					} else {
+						rt->rt_gateway = new_gw;
+						rt->rt_flags |= RTCF_REDIRECTED;
+						call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
 					}
-					check_peer_redir(&rt->dst, peer);
+					neigh_release(n);
 				}
 			}
 		}
@@ -1425,23 +1396,6 @@ reject_redirect:
 	;
 }
 
-static bool peer_pmtu_expired(struct inet_peer *peer)
-{
-	unsigned long orig = ACCESS_ONCE(peer->pmtu_expires);
-
-	return orig &&
-	       time_after_eq(jiffies, orig) &&
-	       cmpxchg(&peer->pmtu_expires, orig, 0) == orig;
-}
-
-static bool peer_pmtu_cleaned(struct inet_peer *peer)
-{
-	unsigned long orig = ACCESS_ONCE(peer->pmtu_expires);
-
-	return orig &&
-	       cmpxchg(&peer->pmtu_expires, orig, 0) == orig;
-}
-
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 {
 	struct rtable *rt = (struct rtable *)dst;
@@ -1451,16 +1405,13 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 		if (dst->obsolete > 0) {
 			ip_rt_put(rt);
 			ret = NULL;
-		} else if (rt->rt_flags & RTCF_REDIRECTED) {
+		} else if ((rt->rt_flags & RTCF_REDIRECTED) ||
+			   rt->dst.expires) {
 			unsigned int hash = rt_hash(rt->rt_key_dst, rt->rt_key_src,
 						rt->rt_oif,
 						rt_genid(dev_net(dst->dev)));
 			rt_del(hash, rt);
 			ret = NULL;
-		} else if (rt_has_peer(rt)) {
-			struct inet_peer *peer = rt_peer_ptr(rt);
-			if (peer_pmtu_expired(peer))
-				dst_metric_set(dst, RTAX_MTU, peer->pmtu_orig);
 		}
 	}
 	return ret;
@@ -1604,50 +1555,17 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
-{
-	unsigned long expires = ACCESS_ONCE(peer->pmtu_expires);
-
-	if (!expires)
-		return;
-	if (time_before(jiffies, expires)) {
-		u32 orig_dst_mtu = dst_mtu(dst);
-		if (peer->pmtu_learned < orig_dst_mtu) {
-			if (!peer->pmtu_orig)
-				peer->pmtu_orig = dst_metric_raw(dst, RTAX_MTU);
-			dst_metric_set(dst, RTAX_MTU, peer->pmtu_learned);
-		}
-	} else if (cmpxchg(&peer->pmtu_expires, expires, 0) == expires)
-		dst_metric_set(dst, RTAX_MTU, peer->pmtu_orig);
-}
-
 static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 	struct rtable *rt = (struct rtable *) dst;
-	struct inet_peer *peer;
 
 	dst_confirm(dst);
 
-	peer = rt_get_peer_create(rt, rt->rt_dst);
-	if (peer) {
-		unsigned long pmtu_expires = ACCESS_ONCE(peer->pmtu_expires);
-
-		if (mtu < ip_rt_min_pmtu)
-			mtu = ip_rt_min_pmtu;
-		if (!pmtu_expires || mtu < peer->pmtu_learned) {
-
-			pmtu_expires = jiffies + ip_rt_mtu_expires;
-			if (!pmtu_expires)
-				pmtu_expires = 1UL;
-
-			peer->pmtu_learned = mtu;
-			peer->pmtu_expires = pmtu_expires;
+	if (mtu < ip_rt_min_pmtu)
+		mtu = ip_rt_min_pmtu;
 
-			atomic_inc(&__rt_peer_genid);
-			rt->rt_peer_genid = rt_peer_genid();
-		}
-		check_peer_pmtu(dst, peer);
-	}
+	rt->rt_pmtu = mtu;
+	dst_set_expires(&rt->dst, ip_rt_mtu_expires);
 }
 
 void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
@@ -1679,30 +1597,12 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
-static void ipv4_validate_peer(struct rtable *rt)
-{
-	if (rt->rt_peer_genid != rt_peer_genid()) {
-		struct inet_peer *peer = rt_get_peer(rt, rt->rt_dst);
-
-		if (peer) {
-			check_peer_pmtu(&rt->dst, peer);
-
-			if (peer->redirect_learned.a4 &&
-			    peer->redirect_learned.a4 != rt->rt_gateway)
-				check_peer_redir(&rt->dst, peer);
-		}
-
-		rt->rt_peer_genid = rt_peer_genid();
-	}
-}
-
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rtable *rt = (struct rtable *) dst;
 
 	if (rt_is_expired(rt))
 		return NULL;
-	ipv4_validate_peer(rt);
 	return dst;
 }
 
@@ -1728,11 +1628,8 @@ static void ipv4_link_failure(struct sk_buff *skb)
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_HOST_UNREACH, 0);
 
 	rt = skb_rtable(skb);
-	if (rt && rt_has_peer(rt)) {
-		struct inet_peer *peer = rt_peer_ptr(rt);
-		if (peer_pmtu_cleaned(peer))
-			dst_metric_set(&rt->dst, RTAX_MTU, peer->pmtu_orig);
-	}
+	if (rt)
+		dst_set_expires(&rt->dst, 0);
 }
 
 static int ip_rt_bug(struct sk_buff *skb)
@@ -1812,7 +1709,13 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
 static unsigned int ipv4_mtu(const struct dst_entry *dst)
 {
 	const struct rtable *rt = (const struct rtable *) dst;
-	unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
+	unsigned int mtu = rt->rt_pmtu;
+
+	if (mtu && time_after_eq(jiffies, rt->dst.expires))
+		mtu = 0;
+
+	if (!mtu)
+		mtu = dst_metric_raw(dst, RTAX_MTU);
 
 	if (mtu && rt_is_output_route(rt))
 		return mtu;
@@ -1843,19 +1746,10 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 	peer = inet_getpeer_v4(base, rt->rt_dst, 0);
 	if (peer) {
 		__rt_set_peer(rt, peer);
-		rt->rt_peer_genid = rt_peer_genid();
 		if (inet_metrics_new(peer))
 			memcpy(peer->metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
 		dst_init_metrics(&rt->dst, peer->metrics, false);
-
-		check_peer_pmtu(&rt->dst, peer);
-
-		if (peer->redirect_learned.a4 &&
-		    peer->redirect_learned.a4 != rt->rt_gateway) {
-			rt->rt_gateway = peer->redirect_learned.a4;
-			rt->rt_flags |= RTCF_REDIRECTED;
-		}
 	} else {
 		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
 			rt->fi = fi;
@@ -1955,8 +1849,8 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_mark    = skb->mark;
+	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, dev_net(dev)->ipv4.peers);
 	rth->fi = NULL;
 	if (our) {
@@ -2081,8 +1975,8 @@ static int __mkroute_input(struct sk_buff *skb,
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->rt_oif 	= 0;
 	rth->rt_mark    = skb->mark;
+	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, &res->table->tb_peers);
 	rth->fi = NULL;
 
@@ -2260,8 +2154,8 @@ local_input:
 	rth->rt_iif	= dev->ifindex;
 	rth->rt_oif	= 0;
 	rth->rt_mark    = skb->mark;
+	rth->rt_pmtu	= 0;
 	rth->rt_gateway	= daddr;
-	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, net->ipv4.peers);
 	rth->fi = NULL;
 	if (res.type == RTN_UNREACHABLE) {
@@ -2337,7 +2231,6 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			ipv4_validate_peer(rth);
 			if (noref) {
 				dst_use_noref(&rth->dst, jiffies);
 				skb_dst_set_noref(skb, &rth->dst);
@@ -2459,8 +2352,8 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	rth->rt_iif	= orig_oif ? : dev_out->ifindex;
 	rth->rt_oif	= orig_oif;
 	rth->rt_mark    = fl4->flowi4_mark;
+	rth->rt_pmtu	= 0;
 	rth->rt_gateway = fl4->daddr;
-	rth->rt_peer_genid = 0;
 	rt_init_peer(rth, (res->table ?
 			   &res->table->tb_peers :
 			   dev_net(dev_out)->ipv4.peers));
@@ -2717,7 +2610,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 			    (IPTOS_RT_MASK | RTO_ONLINK)) &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			ipv4_validate_peer(rth);
 			dst_use(&rth->dst, jiffies);
 			RT_CACHE_STAT_INC(out_hit);
 			rcu_read_unlock_bh();
@@ -2794,6 +2686,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
 		rt->rt_mark = ort->rt_mark;
+		rt->rt_pmtu = ort->rt_pmtu;
 
 		rt->rt_genid = rt_genid(net);
 		rt->rt_flags = ort->rt_flags;
@@ -2896,13 +2789,13 @@ static int rt_fill_info(struct net *net,
 		const struct inet_peer *peer = rt_peer_ptr(rt);
 		inet_peer_refcheck(peer);
 		id = atomic_read(&peer->ip_id_count) & 0xffff;
-		expires = ACCESS_ONCE(peer->pmtu_expires);
-		if (expires) {
-			if (time_before(jiffies, expires))
-				expires -= jiffies;
-			else
-				expires = 0;
-		}
+	}
+	expires = rt->dst.expires;
+	if (expires) {
+		if (time_before(jiffies, expires))
+			expires -= jiffies;
+		else
+			expires = 0;
 	}
 
 	if (rt_is_input_route(rt)) {
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 9815ea0..951bcf3 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -100,6 +100,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 	xdst->u.rt.rt_src = rt->rt_src;
 	xdst->u.rt.rt_dst = rt->rt_dst;
 	xdst->u.rt.rt_gateway = rt->rt_gateway;
+	xdst->u.rt.rt_pmtu = rt->rt_pmtu;
 
 	return 0;
 }
-- 
1.7.10.4
