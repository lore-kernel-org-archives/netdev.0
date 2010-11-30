From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/8] inetpeer: Abstract out the tree root accesses.
Date: Tue, 30 Nov 2010 13:21:57 -0800 (PST)
Message-ID: <20101130.132157.246510731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751682Ab0K3VVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:30 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2D37F24C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:21:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Instead of directly accessing "peer", change to code to
operate using a "struct inet_peer_base *" pointer.

This will facilitate the addition of a seperate tree for
ipv6 peer entries.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |  119 +++++++++++++++++++++++++++++---------------------
 1 files changed, 69 insertions(+), 50 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9e94d7c..f944008 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -79,13 +79,13 @@ static const struct inet_peer peer_fake_node = {
 	.avl_height	= 0
 };
 
-static struct {
+static struct inet_peer_base {
 	struct inet_peer __rcu *root;
 	spinlock_t	lock;
 	int		total;
-} peers = {
+} v4_peers = {
 	.root		= peer_avl_empty_rcu,
-	.lock		= __SPIN_LOCK_UNLOCKED(peers.lock),
+	.lock		= __SPIN_LOCK_UNLOCKED(v4_peers.lock),
 	.total		= 0,
 };
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
@@ -155,15 +155,15 @@ static void unlink_from_unused(struct inet_peer *p)
 /*
  * Called with local BH disabled and the pool lock held.
  */
-#define lookup(_daddr, _stack) 					\
+#define lookup(_daddr, _stack, _base)				\
 ({								\
 	struct inet_peer *u;					\
 	struct inet_peer __rcu **v;				\
 								\
 	stackptr = _stack;					\
-	*stackptr++ = &peers.root;				\
-	for (u = rcu_dereference_protected(peers.root,		\
-			lockdep_is_held(&peers.lock));		\
+	*stackptr++ = &_base->root;				\
+	for (u = rcu_dereference_protected(_base->root,		\
+			lockdep_is_held(&_base->lock));		\
 	     u != peer_avl_empty; ) {				\
 		if (_daddr == u->v4daddr)			\
 			break;					\
@@ -173,7 +173,7 @@ static void unlink_from_unused(struct inet_peer *p)
 			v = &u->avl_right;			\
 		*stackptr++ = v;				\
 		u = rcu_dereference_protected(*v,		\
-			lockdep_is_held(&peers.lock));		\
+			lockdep_is_held(&_base->lock));		\
 	}							\
 	u;							\
 })
@@ -185,9 +185,9 @@ static void unlink_from_unused(struct inet_peer *p)
  * But every pointer we follow is guaranteed to be valid thanks to RCU.
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
-static struct inet_peer *lookup_rcu_bh(__be32 daddr)
+static struct inet_peer *lookup_rcu_bh(__be32 daddr, struct inet_peer_base *base)
 {
-	struct inet_peer *u = rcu_dereference_bh(peers.root);
+	struct inet_peer *u = rcu_dereference_bh(base->root);
 	int count = 0;
 
 	while (u != peer_avl_empty) {
@@ -212,19 +212,19 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr)
 }
 
 /* Called with local BH disabled and the pool lock held. */
-#define lookup_rightempty(start)				\
+#define lookup_rightempty(start, base)				\
 ({								\
 	struct inet_peer *u;					\
 	struct inet_peer __rcu **v;				\
 	*stackptr++ = &start->avl_left;				\
 	v = &start->avl_left;					\
 	for (u = rcu_dereference_protected(*v,			\
-			lockdep_is_held(&peers.lock));		\
+			lockdep_is_held(&base->lock));		\
 	     u->avl_right != peer_avl_empty_rcu; ) {		\
 		v = &u->avl_right;				\
 		*stackptr++ = v;				\
 		u = rcu_dereference_protected(*v,		\
-			lockdep_is_held(&peers.lock));		\
+			lockdep_is_held(&base->lock));		\
 	}							\
 	u;							\
 })
@@ -234,7 +234,8 @@ static struct inet_peer *lookup_rcu_bh(__be32 daddr)
  * Look into mm/map_avl.c for more detail description of the ideas.
  */
 static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
-		struct inet_peer __rcu ***stackend)
+			       struct inet_peer __rcu ***stackend,
+			       struct inet_peer_base *base)
 {
 	struct inet_peer __rcu **nodep;
 	struct inet_peer *node, *l, *r;
@@ -243,20 +244,20 @@ static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
 	while (stackend > stack) {
 		nodep = *--stackend;
 		node = rcu_dereference_protected(*nodep,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 		l = rcu_dereference_protected(node->avl_left,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 		r = rcu_dereference_protected(node->avl_right,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 		lh = node_height(l);
 		rh = node_height(r);
 		if (lh > rh + 1) { /* l: RH+2 */
 			struct inet_peer *ll, *lr, *lrl, *lrr;
 			int lrh;
 			ll = rcu_dereference_protected(l->avl_left,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 			lr = rcu_dereference_protected(l->avl_right,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 			lrh = node_height(lr);
 			if (lrh <= node_height(ll)) {	/* ll: RH+1 */
 				RCU_INIT_POINTER(node->avl_left, lr);	/* lr: RH or RH+1 */
@@ -268,9 +269,9 @@ static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
 				RCU_INIT_POINTER(*nodep, l);
 			} else { /* ll: RH, lr: RH+1 */
 				lrl = rcu_dereference_protected(lr->avl_left,
-					lockdep_is_held(&peers.lock));	/* lrl: RH or RH-1 */
+					lockdep_is_held(&base->lock));	/* lrl: RH or RH-1 */
 				lrr = rcu_dereference_protected(lr->avl_right,
-					lockdep_is_held(&peers.lock));	/* lrr: RH or RH-1 */
+					lockdep_is_held(&base->lock));	/* lrr: RH or RH-1 */
 				RCU_INIT_POINTER(node->avl_left, lrr);	/* lrr: RH or RH-1 */
 				RCU_INIT_POINTER(node->avl_right, r);	/* r: RH */
 				node->avl_height = rh + 1; /* node: RH+1 */
@@ -286,9 +287,9 @@ static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
 			struct inet_peer *rr, *rl, *rlr, *rll;
 			int rlh;
 			rr = rcu_dereference_protected(r->avl_right,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 			rl = rcu_dereference_protected(r->avl_left,
-				lockdep_is_held(&peers.lock));
+				lockdep_is_held(&base->lock));
 			rlh = node_height(rl);
 			if (rlh <= node_height(rr)) {	/* rr: LH+1 */
 				RCU_INIT_POINTER(node->avl_right, rl);	/* rl: LH or LH+1 */
@@ -300,9 +301,9 @@ static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
 				RCU_INIT_POINTER(*nodep, r);
 			} else { /* rr: RH, rl: RH+1 */
 				rlr = rcu_dereference_protected(rl->avl_right,
-					lockdep_is_held(&peers.lock));	/* rlr: LH or LH-1 */
+					lockdep_is_held(&base->lock));	/* rlr: LH or LH-1 */
 				rll = rcu_dereference_protected(rl->avl_left,
-					lockdep_is_held(&peers.lock));	/* rll: LH or LH-1 */
+					lockdep_is_held(&base->lock));	/* rll: LH or LH-1 */
 				RCU_INIT_POINTER(node->avl_right, rll);	/* rll: LH or LH-1 */
 				RCU_INIT_POINTER(node->avl_left, l);	/* l: LH */
 				node->avl_height = lh + 1; /* node: LH+1 */
@@ -321,14 +322,14 @@ static void peer_avl_rebalance(struct inet_peer __rcu **stack[],
 }
 
 /* Called with local BH disabled and the pool lock held. */
-#define link_to_pool(n)						\
+#define link_to_pool(n, base)					\
 do {								\
 	n->avl_height = 1;					\
 	n->avl_left = peer_avl_empty_rcu;			\
 	n->avl_right = peer_avl_empty_rcu;			\
 	/* lockless readers can catch us now */			\
 	rcu_assign_pointer(**--stackptr, n);			\
-	peer_avl_rebalance(stack, stackptr);			\
+	peer_avl_rebalance(stack, stackptr, base);		\
 } while (0)
 
 static void inetpeer_free_rcu(struct rcu_head *head)
@@ -337,13 +338,13 @@ static void inetpeer_free_rcu(struct rcu_head *head)
 }
 
 /* May be called with local BH enabled. */
-static void unlink_from_pool(struct inet_peer *p)
+static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 {
 	int do_free;
 
 	do_free = 0;
 
-	spin_lock_bh(&peers.lock);
+	spin_lock_bh(&base->lock);
 	/* Check the reference counter.  It was artificially incremented by 1
 	 * in cleanup() function to prevent sudden disappearing.  If we can
 	 * atomically (because of lockless readers) take this last reference,
@@ -353,7 +354,7 @@ static void unlink_from_pool(struct inet_peer *p)
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
 		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 		struct inet_peer __rcu ***stackptr, ***delp;
-		if (lookup(p->v4daddr, stack) != p)
+		if (lookup(p->v4daddr, stack, base) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty_rcu) {
@@ -362,9 +363,9 @@ static void unlink_from_pool(struct inet_peer *p)
 		} else {
 			/* look for a node to insert instead of p */
 			struct inet_peer *t;
-			t = lookup_rightempty(p);
+			t = lookup_rightempty(p, base);
 			BUG_ON(rcu_dereference_protected(*stackptr[-1],
-					lockdep_is_held(&peers.lock)) != t);
+					lockdep_is_held(&base->lock)) != t);
 			**--stackptr = t->avl_left;
 			/* t is removed, t->v4daddr > x->v4daddr for any
 			 * x in p->avl_left subtree.
@@ -376,11 +377,11 @@ static void unlink_from_pool(struct inet_peer *p)
 			BUG_ON(delp[1] != &p->avl_left);
 			delp[1] = &t->avl_left; /* was &p->avl_left */
 		}
-		peer_avl_rebalance(stack, stackptr);
-		peers.total--;
+		peer_avl_rebalance(stack, stackptr, base);
+		base->total--;
 		do_free = 1;
 	}
-	spin_unlock_bh(&peers.lock);
+	spin_unlock_bh(&base->lock);
 
 	if (do_free)
 		call_rcu_bh(&p->rcu, inetpeer_free_rcu);
@@ -395,6 +396,11 @@ static void unlink_from_pool(struct inet_peer *p)
 		inet_putpeer(p);
 }
 
+static struct inet_peer_base *peer_to_base(struct inet_peer *p)
+{
+	return &v4_peers;
+}
+
 /* May be called with local BH enabled. */
 static int cleanup_once(unsigned long ttl)
 {
@@ -428,21 +434,27 @@ static int cleanup_once(unsigned long ttl)
 		 * happen because of entry limits in route cache. */
 		return -1;
 
-	unlink_from_pool(p);
+	unlink_from_pool(p, peer_to_base(p));
 	return 0;
 }
 
+static struct inet_peer_base *family_to_base(int family)
+{
+	return &v4_peers;
+}
+
 /* Called with or without local BH being disabled. */
 struct inet_peer *inet_getpeer(__be32 daddr, int create)
 {
-	struct inet_peer *p;
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
+	struct inet_peer_base *base = family_to_base(AF_INET);
+	struct inet_peer *p;
 
 	/* Look up for the address quickly, lockless.
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
 	rcu_read_lock_bh();
-	p = lookup_rcu_bh(daddr);
+	p = lookup_rcu_bh(daddr, base);
 	rcu_read_unlock_bh();
 
 	if (p) {
@@ -456,11 +468,11 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	/* retry an exact lookup, taking the lock before.
 	 * At least, nodes should be hot in our cache.
 	 */
-	spin_lock_bh(&peers.lock);
-	p = lookup(daddr, stack);
+	spin_lock_bh(&base->lock);
+	p = lookup(daddr, stack, base);
 	if (p != peer_avl_empty) {
 		atomic_inc(&p->refcnt);
-		spin_unlock_bh(&peers.lock);
+		spin_unlock_bh(&base->lock);
 		/* Remove the entry from unused list if it was there. */
 		unlink_from_unused(p);
 		return p;
@@ -476,30 +488,36 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 
 
 		/* Link the node. */
-		link_to_pool(p);
-		peers.total++;
+		link_to_pool(p, base);
+		base->total++;
 	}
-	spin_unlock_bh(&peers.lock);
+	spin_unlock_bh(&base->lock);
 
-	if (peers.total >= inet_peer_threshold)
+	if (base->total >= inet_peer_threshold)
 		/* Remove one less-recently-used entry. */
 		cleanup_once(0);
 
 	return p;
 }
 
+static int compute_total(void)
+{
+	return v4_peers.total;
+}
+
 /* Called with local BH disabled. */
 static void peer_check_expire(unsigned long dummy)
 {
 	unsigned long now = jiffies;
-	int ttl;
+	int ttl, total;
 
-	if (peers.total >= inet_peer_threshold)
+	total = compute_total();
+	if (total >= inet_peer_threshold)
 		ttl = inet_peer_minttl;
 	else
 		ttl = inet_peer_maxttl
 				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
-					peers.total / inet_peer_threshold * HZ;
+					total / inet_peer_threshold * HZ;
 	while (!cleanup_once(ttl)) {
 		if (jiffies != now)
 			break;
@@ -508,13 +526,14 @@ static void peer_check_expire(unsigned long dummy)
 	/* Trigger the timer after inet_peer_gc_mintime .. inet_peer_gc_maxtime
 	 * interval depending on the total number of entries (more entries,
 	 * less interval). */
-	if (peers.total >= inet_peer_threshold)
+	total = compute_total();
+	if (total >= inet_peer_threshold)
 		peer_periodic_timer.expires = jiffies + inet_peer_gc_mintime;
 	else
 		peer_periodic_timer.expires = jiffies
 			+ inet_peer_gc_maxtime
 			- (inet_peer_gc_maxtime - inet_peer_gc_mintime) / HZ *
-				peers.total / inet_peer_threshold * HZ;
+				total / inet_peer_threshold * HZ;
 	add_timer(&peer_periodic_timer);
 }
 
-- 
1.7.3.2

