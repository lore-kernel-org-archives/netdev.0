From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sat, 27 Mar 2010 20:31:20 -0700 (PDT)
Message-ID: <20100327.203120.98894145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751728Ab0C1Da4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 23:30:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


inetpeer: Support ipv6 addresses.

Signed-off-by: David S. Miller <davem@davemloft.net>

---

This a first step based upon the talks we were having the other week
about potentially moving the dst metrics out into the inetpeer cache.

The next step would be to move the peer pointer into dst_entry (or
some common encapsulator datastructure that ipv4 and ipv6 could
share, inet_dst_entry or something like that), and provide the
necessary rt6_bind_peer() function for ipv6.  A small set of changes
could then add timewait recycling support to ipv6 essentially for
free (commonize code, provide some wrapper for route type specific
code).

The limited dst metric usage in DecNET could then be moved into
the DecNET route entry struct.  This way we don't have to support
DecNET in the inetpeer cache just for the sake of it's metrics. :-)

Finally, we can really move the metrics array into the inetpeer
entries.

How does this sound?

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 87b1df0..2924302 100644
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
 	struct inet_peer	*avl_left, *avl_right;
-	__be32			v4daddr;	/* peer's address */
+	inet_peer_address_t	daddr;
 	__u32			avl_height;
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
@@ -31,7 +39,7 @@ struct inet_peer {
 void			inet_initpeers(void) __init;
 
 /* can be called with or without local BH being disabled */
-struct inet_peer	*inet_getpeer(__be32 daddr, int create);
+struct inet_peer	*inet_getpeer(inet_peer_address_t *daddr, int create);
 
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 6bcfe52..87066eb 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -19,6 +19,7 @@
 #include <linux/net.h>
 #include <net/ip.h>
 #include <net/inetpeer.h>
+#include <net/ipv6.h>
 
 /*
  *  Theory of operations.
@@ -136,6 +137,47 @@ static void unlink_from_unused(struct inet_peer *p)
 	spin_unlock_bh(&inet_peer_unused_lock);
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
  * _stack is known to be NULL or not at compile time,
@@ -143,15 +185,16 @@ static void unlink_from_unused(struct inet_peer *p)
  */
 #define lookup(_daddr, _stack) 					\
 ({								\
+	u32 key = inet_peer_key(_daddr);			\
 	struct inet_peer *u, **v;				\
 	if (_stack != NULL) {					\
 		stackptr = _stack;				\
 		*stackptr++ = &peer_root;			\
 	}							\
 	for (u = peer_root; u != peer_avl_empty; ) {		\
-		if (_daddr == u->v4daddr)			\
+		if (inet_peer_addr_equal(_daddr, &u->daddr))	\
 			break;					\
-		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
+		if (key < inet_peer_key(&u->daddr))		\
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
@@ -280,7 +323,7 @@ static void unlink_from_pool(struct inet_peer *p)
 	if (atomic_read(&p->refcnt) == 1) {
 		struct inet_peer **stack[PEER_MAXDEPTH];
 		struct inet_peer ***stackptr, ***delp;
-		if (lookup(p->v4daddr, stack) != p)
+		if (lookup(&p->daddr, stack) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty) {
@@ -292,7 +335,7 @@ static void unlink_from_pool(struct inet_peer *p)
 			t = lookup_rightempty(p);
 			BUG_ON(*stackptr[-1] != t);
 			**--stackptr = t->avl_left;
-			/* t is removed, t->v4daddr > x->v4daddr for any
+			/* t is removed, t->daddr > x->daddr for any
 			 * x in p->avl_left subtree.
 			 * Put t in the old place of p. */
 			*delp[0] = t;
@@ -358,7 +401,7 @@ static int cleanup_once(unsigned long ttl)
 }
 
 /* Called with or without local BH being disabled. */
-struct inet_peer *inet_getpeer(__be32 daddr, int create)
+struct inet_peer *inet_getpeer(inet_peer_address_t *daddr, int create)
 {
 	struct inet_peer *p, *n;
 	struct inet_peer **stack[PEER_MAXDEPTH], ***stackptr;
@@ -384,10 +427,11 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	n = kmem_cache_alloc(peer_cachep, GFP_ATOMIC);
 	if (n == NULL)
 		return NULL;
-	n->v4daddr = daddr;
+	n->daddr = *daddr;
 	atomic_set(&n->refcnt, 1);
 	atomic_set(&n->rid, 0);
-	atomic_set(&n->ip_id_count, secure_ip_id(daddr));
+	if (daddr->family == AF_INET)
+		atomic_set(&n->ip_id_count, secure_ip_id(daddr->a4));
 	n->tcp_ts_stamp = 0;
 
 	write_lock_bh(&peer_pool_lock);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b59430b..681c8b9 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -142,8 +142,14 @@ static void ip4_frag_init(struct inet_frag_queue *q, void *a)
 	qp->saddr = arg->iph->saddr;
 	qp->daddr = arg->iph->daddr;
 	qp->user = arg->user;
-	qp->peer = sysctl_ipfrag_max_dist ?
-		inet_getpeer(arg->iph->saddr, 1) : NULL;
+	if (sysctl_ipfrag_max_dist) {
+		inet_peer_address_t addr;
+
+		addr.a4 = arg->iph->saddr;
+		addr.family = AF_INET;
+		qp->peer = inet_getpeer(&addr, 1);
+	} else
+		qp->peer = NULL;
 }
 
 static __inline__ void ip4_frag_free(struct inet_frag_queue *q)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 32d3961..9334e29 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1287,9 +1287,12 @@ skip_hashing:
 void rt_bind_peer(struct rtable *rt, int create)
 {
 	static DEFINE_SPINLOCK(rt_peer_lock);
+	inet_peer_address_t addr;
 	struct inet_peer *peer;
 
-	peer = inet_getpeer(rt->rt_dst, create);
+	addr.a4 = rt->rt_dst;
+	addr.family = AF_INET;
+	peer = inet_getpeer(&addr, create);
 
 	spin_lock_bh(&rt_peer_lock);
 	if (rt->peer == NULL) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f4df5f9..9de6a12 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1350,7 +1350,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
-		    peer->v4daddr == saddr) {
+		    peer->daddr.a4 == saddr) {
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {
@@ -1770,7 +1770,11 @@ int tcp_v4_remember_stamp(struct sock *sk)
 	int release_it = 0;
 
 	if (!rt || rt->rt_dst != inet->inet_daddr) {
-		peer = inet_getpeer(inet->inet_daddr, 1);
+		inet_peer_address_t addr;
+
+		addr.a4 = inet->inet_daddr;
+		addr.family = AF_INET;
+		peer = inet_getpeer(&addr, 1);
 		release_it = 1;
 	} else {
 		if (!rt->peer)
@@ -1795,8 +1799,12 @@ int tcp_v4_remember_stamp(struct sock *sk)
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
-	struct inet_peer *peer = inet_getpeer(tw->tw_daddr, 1);
+	inet_peer_address_t addr;
+	struct inet_peer *peer;
 
+	addr.a4 = tw->tw_daddr;
+	addr.family = AF_INET;
+	peer = inet_getpeer(&addr, 1);
 	if (peer) {
 		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 
