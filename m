From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 13:44:03 -0800 (PST)
Message-ID: <20101129.134403.179947389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753493Ab0K2Vnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 16:43:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D26E524C088
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 13:44:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |   21 ++++++++++++++-
 net/ipv4/inetpeer.c    |   66 ++++++++++++++++++++++++++++++++++++++++-------
 net/ipv4/ip_fragment.c |    2 +-
 net/ipv4/route.c       |    2 +-
 net/ipv4/tcp_ipv4.c    |    6 ++--
 5 files changed, 80 insertions(+), 17 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index fe239bf..834f045 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -13,10 +13,18 @@
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
 
+typedef struct {
+	union {
+		__be32		a4;
+		__be32		a6[4];
+	};
+	__u16	family;
+} inet_peer_address_t;
+
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer __rcu	*avl_left, *avl_right;
-	__be32			v4daddr;	/* peer's address */
+	inet_peer_address_t	daddr;
 	__u32			avl_height;
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
@@ -42,7 +50,16 @@ struct inet_peer {
 void			inet_initpeers(void) __init;
 
 /* can be called with or without local BH being disabled */
-struct inet_peer	*inet_getpeer(__be32 daddr, int create);
+struct inet_peer	*inet_getpeer(inet_peer_address_t *daddr, int create);
+
+static inline struct inet_peer *inet_getpeer_v4(__be32 v4daddr, int create)
+{
+	inet_peer_address_t daddr;
+
+	daddr.a4 = v4daddr;
+	daddr.family = AF_INET;
+	return inet_getpeer(&daddr, create);
+}
 
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9e94d7c..39f18c5 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -19,6 +19,7 @@
 #include <linux/net.h>
 #include <net/ip.h>
 #include <net/inetpeer.h>
+#include <net/ipv6.h>
 
 /*
  *  Theory of operations.
@@ -152,11 +153,53 @@ static void unlink_from_unused(struct inet_peer *p)
 	}
 }
 
+static inline bool inet_peer_addr_equal(inet_peer_address_t *a, inet_peer_address_t *b)
+{
+	if (a->family == b->family) {
+		switch (a->family) {
+		case AF_INET:
+			if (a->a4 == b->a4)
+				return true;
+			break;
+		case AF_INET6:
+			if (!ipv6_addr_cmp((struct in6_addr *)a,
+					   (struct in6_addr *)b))
+				return true;
+			break;
+		default:
+			break;
+		}
+	}
+	return false;
+}
+
+static inline u32 inet_peer_key(inet_peer_address_t *a)
+{
+	u32 key;
+
+	switch (a->family) {
+	case AF_INET:
+		key = (__force __u32) a->a4;
+		break;
+	case AF_INET6:
+		key = ((__force __u32)a->a6[0] ^
+		       (__force __u32)a->a6[1] ^
+		       (__force __u32)a->a6[2] ^
+		       (__force __u32)a->a6[3]);
+		break;
+	default:
+		key = 0;
+		break;
+	}
+	return key;
+}
+
 /*
  * Called with local BH disabled and the pool lock held.
  */
 #define lookup(_daddr, _stack) 					\
 ({								\
+	u32 key = inet_peer_key(_daddr);			\
 	struct inet_peer *u;					\
 	struct inet_peer __rcu **v;				\
 								\
@@ -165,9 +208,9 @@ static void unlink_from_unused(struct inet_peer *p)
 	for (u = rcu_dereference_protected(peers.root,		\
 			lockdep_is_held(&peers.lock));		\
 	     u != peer_avl_empty; ) {				\
-		if (_daddr == u->v4daddr)			\
+		if (inet_peer_addr_equal(_daddr, &u->daddr))	\
 			break;					\
-		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
+		if (key < inet_peer_key(&u->daddr))		\
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
@@ -185,13 +228,14 @@ static void unlink_from_unused(struct inet_peer *p)
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu_bh(__be32 daddr)
+static struct inet_peer *lookup_rcu_bh(inet_peer_address_t *daddr)
 {
 	struct inet_peer *u = rcu_dereference_bh(peers.root);
+	u32 key = inet_peer_key(daddr);
 	int count = 0;
 
 	while (u != peer_avl_empty) {
-		if (daddr == u->v4daddr) {
+		if (inet_peer_addr_equal(daddr, &u->daddr)) {
 			/* Before taking a reference, check if this entry was
 			 * deleted, unlink_from_pool() sets refcnt=-1 to make
 			 * distinction between an unused entry (refcnt=0) and
@@ -201,7 +245,7 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr)
 				u = NULL;
 			return u;
 		}
-		if ((__force __u32)daddr < (__force __u32)u->v4daddr)
+		if (key < inet_peer_key(&u->daddr))
 			u = rcu_dereference_bh(u->avl_left);
 		else
 			u = rcu_dereference_bh(u->avl_right);
@@ -353,7 +397,7 @@ static void unlink_from_pool(struct inet_peer *p)
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
 		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 		struct inet_peer __rcu ***stackptr, ***delp;
-		if (lookup(p->v4daddr, stack) != p)
+		if (lookup(&p->daddr, stack) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty_rcu) {
@@ -366,7 +410,7 @@ static void unlink_from_pool(struct inet_peer *p)
 			BUG_ON(rcu_dereference_protected(*stackptr[-1],
 					lockdep_is_held(&peers.lock)) != t);
 			**--stackptr = t->avl_left;
-			/* t is removed, t->v4daddr > x->v4daddr for any
+			/* t is removed, t->daddr > x->daddr for any
 			 * x in p->avl_left subtree.
 			 * Put t in the old place of p. */
 			RCU_INIT_POINTER(*delp[0], t);
@@ -433,7 +477,7 @@ static int cleanup_once(unsigned long ttl)
 }
 
 /* Called with or without local BH being disabled. */
-struct inet_peer *inet_getpeer(__be32 daddr, int create)
+struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 {
 	struct inet_peer *p;
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
@@ -467,10 +511,12 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	}
 	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
-		p->v4daddr = daddr;
+		p->daddr = *daddr;
 		atomic_set(&p->refcnt, 1);
 		atomic_set(&p->rid, 0);
-		atomic_set(&p->ip_id_count, secure_ip_id(daddr));
+		atomic_set(&p->ip_id_count,
+			   (daddr->family == AF_INET) ?
+			   secure_ip_id(daddr->a4) : 0);
 		p->tcp_ts_stamp = 0;
 		INIT_LIST_HEAD(&p->unused);
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 1684408..e6215bd 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -141,7 +141,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 	qp->daddr = arg->iph->daddr;
 	qp->user = arg->user;
 	qp->peer = sysctl_ipfrag_max_dist ?
-		inet_getpeer(arg->iph->saddr, 1) : NULL;
+		inet_getpeer_v4(arg->iph->saddr, 1) : NULL;
 }
 
 static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ec2333f..3843c2d 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1289,7 +1289,7 @@ void rt_bind_peer(struct rtable *rt, int create)
 {
 	struct inet_peer *peer;
 
-	peer = inet_getpeer(rt->rt_dst, create);
+	peer = inet_getpeer_v4(rt->rt_dst, create);
 
 	if (peer && cmpxchg(&rt->peer, NULL, peer) != NULL)
 		inet_putpeer(peer);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 69ccbc1..00285fc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1347,7 +1347,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
-		    peer->v4daddr == saddr) {
+		    peer->daddr.a4 == saddr) {
 			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
@@ -1778,7 +1778,7 @@ int tcp_v4_remember_stamp(struct sock *sk)
 	int release_it = 0;
 
 	if (!rt || rt->rt_dst != inet->inet_daddr) {
-		peer = inet_getpeer(inet->inet_daddr, 1);
+		peer = inet_getpeer_v4(inet->inet_daddr, 1);
 		release_it = 1;
 	} else {
 		if (!rt->peer)
@@ -1804,7 +1804,7 @@ EXPORT_SYMBOL(tcp_v4_remember_stamp);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
-	struct inet_peer *peer = inet_getpeer(tw->tw_daddr, 1);
+	struct inet_peer *peer = inet_getpeer_v4(tw->tw_daddr, 1);
 
 	if (peer) {
 		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
-- 
1.7.3.2

