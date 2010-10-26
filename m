From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inetpeer: __rcu annotations
Date: Tue, 26 Oct 2010 11:55:38 +0200
Message-ID: <1288086938.3169.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48364 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755093Ab0JZJzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 05:55:42 -0400
Received: by wwe15 with SMTP id 15so4545537wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 02:55:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds __rcu annotations to inetpeer
	(struct inet_peer)->avl_left
	(struct inet_peer)->avl_right

This is a tedious cleanup, but removes one smp_wmb() from link_to_pool()
since we now use more self documenting rcu_assign_pointer().

Note the use of RCU_INIT_POINTER() instead of rcu_assign_pointer() in
all cases we dont need a memory barrier.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |    2 
 net/ipv4/inetpeer.c    |  138 ++++++++++++++++++++++-----------------
 2 files changed, 81 insertions(+), 59 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 417d0c8..fe239bf 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -15,7 +15,7 @@
 
 struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
-	struct inet_peer	*avl_left, *avl_right;
+	struct inet_peer __rcu	*avl_left, *avl_right;
 	__be32			v4daddr;	/* peer's address */
 	__u32			avl_height;
 	struct list_head	unused;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9ffa24b..ccf01c9 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -72,18 +72,19 @@ static struct kmem_cache *peer_cachep __read_mostly;
 #define node_height(x) x->avl_height
 
 #define peer_avl_empty ((struct inet_peer *)&peer_fake_node)
+#define peer_avl_empty_rcu ((struct inet_peer __rcu __force *)&peer_fake_node)
 static const struct inet_peer peer_fake_node = {
-	.avl_left	= peer_avl_empty,
-	.avl_right	= peer_avl_empty,
+	.avl_left	= peer_avl_empty_rcu,
+	.avl_right	= peer_avl_empty_rcu,
 	.avl_height	= 0
 };
 
 static struct {
-	struct inet_peer *root;
+	struct inet_peer __rcu *root;
 	spinlock_t	lock;
 	int		total;
 } peers = {
-	.root		= peer_avl_empty,
+	.root		= peer_avl_empty_rcu,
 	.lock		= __SPIN_LOCK_UNLOCKED(peers.lock),
 	.total		= 0,
 };
@@ -156,11 +157,14 @@ static void unlink_from_unused(struct inet_peer *p)
  */
 #define lookup(_daddr, _stack) 					\
 ({								\
-	struct inet_peer *u, **v;				\
+	struct inet_peer *u;					\
+	struct inet_peer __rcu **v;				\
 								\
 	stackptr = _stack;					\
 	*stackptr++ = &peers.root;				\
-	for (u = peers.root; u != peer_avl_empty; ) {		\
+	for (u = rcu_dereference_protected(peers.root,		\
+			lockdep_is_held(&peers.lock));		\
+	     u != peer_avl_empty; ) {				\
 		if (_daddr == u->v4daddr)			\
 			break;					\
 		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
@@ -168,7 +172,8 @@ static void unlink_from_unused(struct inet_peer *p)
 		else						\
 			v = &u->avl_right;			\
 		*stackptr++ = v;				\
-		u = *v;						\
+		u = rcu_dereference_protected(*v,		\
+			lockdep_is_held(&peers.lock));		\
 	}							\
 	u;							\
 })
@@ -209,13 +214,17 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr)
 /* Called with local BH disabled and the pool lock held. */
 #define lookup_rightempty(start)				\
 ({								\
-	struct inet_peer *u, **v;				\
+	struct inet_peer *u;					\
+	struct inet_peer __rcu **v;				\
 	*stackptr++ = &start->avl_left;				\
 	v = &start->avl_left;					\
-	for (u = *v; u->avl_right != peer_avl_empty; ) {	\
+	for (u = rcu_dereference_protected(*v,			\
+			lockdep_is_held(&peers.lock));		\
+	     u->avl_right != peer_avl_empty_rcu; ) {		\
 		v = &u->avl_right;				\
 		*stackptr++ = v;				\
-		u = *v;						\
+		u = rcu_dereference_protected(*v,		\
+			lockdep_is_held(&peers.lock));		\
 	}							\
 	u;							\
 })
@@ -224,74 +233,86 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr)
  * Variable names are the proof of operation correctness.
  * Look into mm/map_avl.c for more detail description of the ideas.
  */
-static void peer_avl_rebalance(struct inet_peer **stack[],
-		struct inet_peer ***stackend)
+static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
+		struct inet_peer __rcu ***stackend)
 {
-	struct inet_peer **nodep, *node, *l, *r;
+	struct inet_peer __rcu **nodep;
+	struct inet_peer *node, *l, *r;
 	int lh, rh;
 
 	while (stackend > stack) {
 		nodep = *--stackend;
-		node = *nodep;
-		l = node->avl_left;
-		r = node->avl_right;
+		node = rcu_dereference_protected(*nodep,
+				lockdep_is_held(&peers.lock));
+		l = rcu_dereference_protected(node->avl_left,
+				lockdep_is_held(&peers.lock));
+		r = rcu_dereference_protected(node->avl_right,
+				lockdep_is_held(&peers.lock));
 		lh = node_height(l);
 		rh = node_height(r);
 		if (lh > rh + 1) { /* l: RH+2 */
 			struct inet_peer *ll, *lr, *lrl, *lrr;
 			int lrh;
-			ll = l->avl_left;
-			lr = l->avl_right;
+			ll = rcu_dereference_protected(l->avl_left,
+				lockdep_is_held(&peers.lock));
+			lr = rcu_dereference_protected(l->avl_right,
+				lockdep_is_held(&peers.lock));
 			lrh = node_height(lr);
 			if (lrh <= node_height(ll)) {	/* ll: RH+1 */
-				node->avl_left = lr;	/* lr: RH or RH+1 */
-				node->avl_right = r;	/* r: RH */
+				RCU_INIT_POINTER(node->avl_left, lr);	/* lr: RH or RH+1 */
+				RCU_INIT_POINTER(node->avl_right, r);	/* r: RH */
 				node->avl_height = lrh + 1; /* RH+1 or RH+2 */
-				l->avl_left = ll;	/* ll: RH+1 */
-				l->avl_right = node;	/* node: RH+1 or RH+2 */
+				RCU_INIT_POINTER(l->avl_left, ll);       /* ll: RH+1 */
+				RCU_INIT_POINTER(l->avl_right, node);	/* node: RH+1 or RH+2 */
 				l->avl_height = node->avl_height + 1;
-				*nodep = l;
+				RCU_INIT_POINTER(*nodep, l);
 			} else { /* ll: RH, lr: RH+1 */
-				lrl = lr->avl_left;	/* lrl: RH or RH-1 */
-				lrr = lr->avl_right;	/* lrr: RH or RH-1 */
-				node->avl_left = lrr;	/* lrr: RH or RH-1 */
-				node->avl_right = r;	/* r: RH */
+				lrl = rcu_dereference_protected(lr->avl_left,
+					lockdep_is_held(&peers.lock));	/* lrl: RH or RH-1 */
+				lrr = rcu_dereference_protected(lr->avl_right,
+					lockdep_is_held(&peers.lock));	/* lrr: RH or RH-1 */
+				RCU_INIT_POINTER(node->avl_left, lrr);	/* lrr: RH or RH-1 */
+				RCU_INIT_POINTER(node->avl_right, r);	/* r: RH */
 				node->avl_height = rh + 1; /* node: RH+1 */
-				l->avl_left = ll;	/* ll: RH */
-				l->avl_right = lrl;	/* lrl: RH or RH-1 */
+				RCU_INIT_POINTER(l->avl_left, ll);	/* ll: RH */
+				RCU_INIT_POINTER(l->avl_right, lrl);	/* lrl: RH or RH-1 */
 				l->avl_height = rh + 1;	/* l: RH+1 */
-				lr->avl_left = l;	/* l: RH+1 */
-				lr->avl_right = node;	/* node: RH+1 */
+				RCU_INIT_POINTER(lr->avl_left, l);	/* l: RH+1 */
+				RCU_INIT_POINTER(lr->avl_right, node);	/* node: RH+1 */
 				lr->avl_height = rh + 2;
-				*nodep = lr;
+				RCU_INIT_POINTER(*nodep, lr);
 			}
 		} else if (rh > lh + 1) { /* r: LH+2 */
 			struct inet_peer *rr, *rl, *rlr, *rll;
 			int rlh;
-			rr = r->avl_right;
-			rl = r->avl_left;
+			rr = rcu_dereference_protected(r->avl_right,
+				lockdep_is_held(&peers.lock));
+			rl = rcu_dereference_protected(r->avl_left,
+				lockdep_is_held(&peers.lock));
 			rlh = node_height(rl);
 			if (rlh <= node_height(rr)) {	/* rr: LH+1 */
-				node->avl_right = rl;	/* rl: LH or LH+1 */
-				node->avl_left = l;	/* l: LH */
+				RCU_INIT_POINTER(node->avl_right, rl);	/* rl: LH or LH+1 */
+				RCU_INIT_POINTER(node->avl_left, l);	/* l: LH */
 				node->avl_height = rlh + 1; /* LH+1 or LH+2 */
-				r->avl_right = rr;	/* rr: LH+1 */
-				r->avl_left = node;	/* node: LH+1 or LH+2 */
+				RCU_INIT_POINTER(r->avl_right, rr);	/* rr: LH+1 */
+				RCU_INIT_POINTER(r->avl_left, node);	/* node: LH+1 or LH+2 */
 				r->avl_height = node->avl_height + 1;
-				*nodep = r;
+				RCU_INIT_POINTER(*nodep, r);
 			} else { /* rr: RH, rl: RH+1 */
-				rlr = rl->avl_right;	/* rlr: LH or LH-1 */
-				rll = rl->avl_left;	/* rll: LH or LH-1 */
-				node->avl_right = rll;	/* rll: LH or LH-1 */
-				node->avl_left = l;	/* l: LH */
+				rlr = rcu_dereference_protected(rl->avl_right,
+					lockdep_is_held(&peers.lock));	/* rlr: LH or LH-1 */
+				rll = rcu_dereference_protected(rl->avl_left,
+					lockdep_is_held(&peers.lock));	/* rll: LH or LH-1 */
+				RCU_INIT_POINTER(node->avl_right, rll);	/* rll: LH or LH-1 */
+				RCU_INIT_POINTER(node->avl_left, l);	/* l: LH */
 				node->avl_height = lh + 1; /* node: LH+1 */
-				r->avl_right = rr;	/* rr: LH */
-				r->avl_left = rlr;	/* rlr: LH or LH-1 */
+				RCU_INIT_POINTER(r->avl_right, rr);	/* rr: LH */
+				RCU_INIT_POINTER(r->avl_left, rlr);	/* rlr: LH or LH-1 */
 				r->avl_height = lh + 1;	/* r: LH+1 */
-				rl->avl_right = r;	/* r: LH+1 */
-				rl->avl_left = node;	/* node: LH+1 */
+				RCU_INIT_POINTER(rl->avl_right, r);	/* r: LH+1 */
+				RCU_INIT_POINTER(rl->avl_left, node);	/* node: LH+1 */
 				rl->avl_height = lh + 2;
-				*nodep = rl;
+				RCU_INIT_POINTER(*nodep, rl);
 			}
 		} else {
 			node->avl_height = (lh > rh ? lh : rh) + 1;
@@ -303,10 +324,10 @@ static void peer_avl_rebalance(struct inet_peer **stack[],
 #define link_to_pool(n)						\
 do {								\
 	n->avl_height = 1;					\
-	n->avl_left = peer_avl_empty;				\
-	n->avl_right = peer_avl_empty;				\
-	smp_wmb(); /* lockless readers can catch us now */	\
-	**--stackptr = n;					\
+	n->avl_left = peer_avl_empty_rcu;			\
+	n->avl_right = peer_avl_empty_rcu;			\
+	/* lockless readers can catch us now */			\
+	rcu_assign_pointer(**--stackptr, n);			\
 	peer_avl_rebalance(stack, stackptr);			\
 } while (0)
 
@@ -330,24 +351,25 @@ static void unlink_from_pool(struct inet_peer *p)
 	 * We use refcnt=-1 to alert lockless readers this entry is deleted.
 	 */
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
-		struct inet_peer **stack[PEER_MAXDEPTH];
-		struct inet_peer ***stackptr, ***delp;
+		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
+		struct inet_peer __rcu ***stackptr, ***delp;
 		if (lookup(p->v4daddr, stack) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
-		if (p->avl_left == peer_avl_empty) {
+		if (p->avl_left == peer_avl_empty_rcu) {
 			*delp[0] = p->avl_right;
 			--stackptr;
 		} else {
 			/* look for a node to insert instead of p */
 			struct inet_peer *t;
 			t = lookup_rightempty(p);
-			BUG_ON(*stackptr[-1] != t);
+			BUG_ON(rcu_dereference_protected(*stackptr[-1],
+					lockdep_is_held(&peers.lock)) != t);
 			**--stackptr = t->avl_left;
 			/* t is removed, t->v4daddr > x->v4daddr for any
 			 * x in p->avl_left subtree.
 			 * Put t in the old place of p. */
-			*delp[0] = t;
+			RCU_INIT_POINTER(*delp[0], t);
 			t->avl_left = p->avl_left;
 			t->avl_right = p->avl_right;
 			t->avl_height = p->avl_height;
@@ -414,7 +436,7 @@ static int cleanup_once(unsigned long ttl)
 struct inet_peer *inet_getpeer(__be32 daddr, int create)
 {
 	struct inet_peer *p;
-	struct inet_peer **stack[PEER_MAXDEPTH], ***stackptr;
+	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
 
 	/* Look up for the address quickly, lockless.
 	 * Because of a concurrent writer, we might not find an existing entry.


