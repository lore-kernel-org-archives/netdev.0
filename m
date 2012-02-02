From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] inetpeer: Allocate the peer metrics dynamically
Date: Thu, 2 Feb 2012 11:12:15 +0100
Message-ID: <20120202101215.GD23142@secunet.com>
References: <20120202101141.GC23142@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48751 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095Ab2BBKMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 05:12:39 -0500
Content-Disposition: inline
In-Reply-To: <20120202101141.GC23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do a dynamic allocation of the peer metrics in order
to be able to reset the peer metrics by exchanging a rcu
pointer. This is done with separate patches.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/inetpeer.h |   13 +++++++++++--
 net/ipv4/inetpeer.c    |   14 ++++++++++++--
 net/ipv4/route.c       |    7 ++++---
 net/ipv6/route.c       |    2 +-
 4 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 06b795d..6bb8060 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -27,13 +27,17 @@ struct inetpeer_addr {
 	__u16				family;
 };
 
+struct inetpeer_metrics {
+	u32		m[RTAX_MAX];
+};
+
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer __rcu	*avl_left, *avl_right;
 	struct inetpeer_addr	daddr;
 	__u32			avl_height;
 
-	u32			metrics[RTAX_MAX];
+	struct inetpeer_metrics *metrics;
 	u32			rate_tokens;	/* rate limiting for ICMP */
 	int			redirect_genid;
 	unsigned long		rate_last;
@@ -68,7 +72,12 @@ void			inet_initpeers(void) __init;
 
 static inline bool inet_metrics_new(const struct inet_peer *p)
 {
-	return p->metrics[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
+	return p->metrics->m[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
+}
+
+static inline u32 *inetpeer_metrics(const struct inet_peer *p)
+{
+	return p->metrics->m;
 }
 
 /* can be called with or without local BH being disabled */
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index bf4a9c4..92071a4 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -315,7 +315,9 @@ do {								\
 
 static void inetpeer_free_rcu(struct rcu_head *head)
 {
-	kmem_cache_free(peer_cachep, container_of(head, struct inet_peer, rcu));
+	struct inet_peer *p = container_of(head, struct inet_peer, rcu);
+	kfree(p->metrics);
+	kmem_cache_free(peer_cachep, p);
 }
 
 static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
@@ -434,6 +436,13 @@ relookup:
 	}
 	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
+		p->metrics = kmalloc(sizeof(struct inetpeer_metrics),
+				     GFP_ATOMIC);
+		if (!p->metrics) {
+			kmem_cache_free(peer_cachep, p);
+			goto out;
+		}
+
 		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
@@ -442,7 +451,7 @@ relookup:
 					secure_ip_id(daddr->addr.a4) :
 					secure_ipv6_id(daddr->addr.a6));
 		p->tcp_ts_stamp = 0;
-		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
+		p->metrics->m[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		p->rate_tokens = 0;
 		p->rate_last = 0;
 		p->pmtu_expires = 0;
@@ -455,6 +464,7 @@ relookup:
 		link_to_pool(p, base);
 		base->total++;
 	}
+out:
 	write_sequnlock_bh(&base->lock);
 
 	return p;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bcacf54..5099d35 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -169,7 +169,7 @@ static u32 *ipv4_cow_metrics(struct dst_entry *dst, unsigned long old)
 		u32 *old_p = __DST_METRICS_PTR(old);
 		unsigned long prev, new;
 
-		p = peer->metrics;
+		p = inetpeer_metrics(peer);
 		if (inet_metrics_new(peer))
 			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
 
@@ -1951,11 +1951,12 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
 
 	rt->peer = peer = inet_getpeer_v4(rt->rt_dst, create);
 	if (peer) {
+		u32 *peer_metrics = inetpeer_metrics(peer);
 		rt->rt_peer_genid = rt_peer_genid();
 		if (inet_metrics_new(peer))
-			memcpy(peer->metrics, fi->fib_metrics,
+			memcpy(peer_metrics, fi->fib_metrics,
 			       sizeof(u32) * RTAX_MAX);
-		dst_init_metrics(&rt->dst, peer->metrics, false);
+		dst_init_metrics(&rt->dst, peer_metrics, false);
 
 		check_peer_pmtu(&rt->dst, peer);
 		if (peer->redirect_genid != redirect_genid)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c2e3ab..ea13565 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -105,7 +105,7 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 		u32 *old_p = __DST_METRICS_PTR(old);
 		unsigned long prev, new;
 
-		p = peer->metrics;
+		p = inetpeer_metrics(peer);
 		if (inet_metrics_new(peer))
 			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
 
-- 
1.7.0.4
