From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: RCU conversion
Date: Tue, 15 Jun 2010 20:23:14 +0200
Message-ID: <1276626194.2541.186.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33514 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab0FOSXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:23:20 -0400
Received: by wyb40 with SMTP id 40so5066904wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 11:23:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer currently uses an AVL tree protected by an rwlock.

It's possible to make most lookups use RCU

1) Add a struct rcu_head to struct inet_peer

2) add a lookup_rcu_bh() helper to perform lockless and opportunistic
lookup. This is a normal function, not a macro like lookup().

3) Add a limit to number of links followed by lookup_rcu_bh(). This is
needed in case we fall in a loop.

4) add an smp_wmb() in link_to_pool() right before node insert.

5) make unlink_from_pool() use atomic_cmpxchg() to make sure it can take
last reference to an inet_peer, since lockless readers could increase
refcount, even while we hold peers.lock.

6) Delay struct inet_peer freeing after rcu grace period so that
lookup_rcu_bh() cannot crash.

7) inet_getpeer() first attempts lockless lookup.
   Note this lookup can fail even if target is in AVL tree, but a
concurrent writer can let tree in a non correct form.
   If this attemps fails, lock is taken a regular lookup is performed
again.

8) convert peers.lock from rwlock to a spinlock

9) Remove SLAB_HWCACHE_ALIGN when peer_cachep is created, because
rcu_head adds 16 bytes on 64bit arches, doubling effective size (64 ->
128 bytes)
In a future patch, this is probably possible to revert this part, if rcu
field is put in an union to share space with rid, ip_id_count, tcp_ts &
tcp_ts_stamp. These fields being manipulated only with refcnt > 0.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |    1 
 net/ipv4/inetpeer.c    |  164 ++++++++++++++++++++++-----------------
 2 files changed, 96 insertions(+), 69 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 87b1df0..6174047 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -26,6 +26,7 @@ struct inet_peer {
 	atomic_t		ip_id_count;	/* IP ID for the next packet */
 	__u32			tcp_ts;
 	__u32			tcp_ts_stamp;
+	struct rcu_head		rcu;
 };
 
 void			inet_initpeers(void) __init;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 035673f..5f3846c 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -51,8 +51,8 @@
  *  lookups performed with disabled BHs.
  *
  *  Serialisation issues.
- *  1.  Nodes may appear in the tree only with the pool write lock held.
- *  2.  Nodes may disappear from the tree only with the pool write lock held
+ *  1.  Nodes may appear in the tree only with the pool lock held.
+ *  2.  Nodes may disappear from the tree only with the pool lock held
  *      AND reference count being 0.
  *  3.  Nodes appears and disappears from unused node list only under
  *      "inet_peer_unused_lock".
@@ -80,11 +80,11 @@ static const struct inet_peer peer_fake_node = {
 
 static struct {
 	struct inet_peer *root;
-	rwlock_t	lock;
+	spinlock_t	lock;
 	int		total;
 } peers = {
 	.root		= peer_avl_empty,
-	.lock		= __RW_LOCK_UNLOCKED(peers.lock),
+	.lock		= __SPIN_LOCK_UNLOCKED(peers.lock),
 	.total		= 0,
 };
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
@@ -129,7 +129,7 @@ void __init inet_initpeers(void)
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
-			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
+			0, SLAB_PANIC,
 			NULL);
 
 	/* All the timers, started at system startup tend
@@ -153,16 +153,13 @@ static void unlink_from_unused(struct inet_peer *p)
 
 /*
  * Called with local BH disabled and the pool lock held.
- * _stack is known to be NULL or not at compile time,
- * so compiler will optimize the if (_stack) tests.
  */
 #define lookup(_daddr, _stack) 					\
 ({								\
 	struct inet_peer *u, **v;				\
-	if (_stack != NULL) {					\
-		stackptr = _stack;				\
-		*stackptr++ = &peers.root;			\
-	}							\
+								\
+	stackptr = _stack;					\
+	*stackptr++ = &peers.root;				\
 	for (u = peers.root; u != peer_avl_empty; ) {		\
 		if (_daddr == u->v4daddr)			\
 			break;					\
@@ -170,14 +167,41 @@ static void unlink_from_unused(struct inet_peer *p)
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
-		if (_stack != NULL)				\
-			*stackptr++ = v;			\
+		*stackptr++ = v;				\
 		u = *v;						\
 	}							\
 	u;							\
 })
 
-/* Called with local BH disabled and the pool write lock held. */
+/*
+ * Called with rcu_read_lock_bh()
+ * Because we hold no lock against a writer, its quite possible we fall
+ * in an endless loop.
+ * But every pointer we follow is guaranteed to be valid thanks to RCU.
+ * We exit from this function if number of links exceeds PEER_MAXDEPTH
+ */
+static struct inet_peer *lookup_rcu_bh(__be32 daddr)
+{
+	struct inet_peer *u = rcu_dereference_bh(peers.root);
+	int count = 0;
+
+	while (u != peer_avl_empty) {
+		if (daddr == u->v4daddr) {
+			if (unlikely(!atomic_inc_not_zero(&u->refcnt)))
+				u = NULL;
+			return u;
+		}
+		if ((__force __u32)daddr < (__force __u32)u->v4daddr)
+			u = rcu_dereference_bh(u->avl_left);
+		else
+			u = rcu_dereference_bh(u->avl_right);
+		if (unlikely(++count == PEER_MAXDEPTH))
+			break;
+	}
+	return NULL;
+}
+
+/* Called with local BH disabled and the pool lock held. */
 #define lookup_rightempty(start)				\
 ({								\
 	struct inet_peer *u, **v;				\
@@ -191,9 +215,10 @@ static void unlink_from_unused(struct inet_peer *p)
 	u;							\
 })
 
-/* Called with local BH disabled and the pool write lock held.
+/* Called with local BH disabled and the pool lock held.
  * Variable names are the proof of operation correctness.
- * Look into mm/map_avl.c for more detail description of the ideas.  */
+ * Look into mm/map_avl.c for more detail description of the ideas.
+ */
 static void peer_avl_rebalance(struct inet_peer **stack[],
 		struct inet_peer ***stackend)
 {
@@ -269,16 +294,22 @@ static void peer_avl_rebalance(struct inet_peer **stack[],
 	}
 }
 
-/* Called with local BH disabled and the pool write lock held. */
+/* Called with local BH disabled and the pool lock held. */
 #define link_to_pool(n)						\
 do {								\
 	n->avl_height = 1;					\
 	n->avl_left = peer_avl_empty;				\
 	n->avl_right = peer_avl_empty;				\
+	smp_wmb(); /* lockless readers can catch us now */	\
 	**--stackptr = n;					\
 	peer_avl_rebalance(stack, stackptr);			\
 } while (0)
 
+static void inetpeer_free_rcu(struct rcu_head *head)
+{
+	kmem_cache_free(peer_cachep, container_of(head, struct inet_peer, rcu));
+}
+
 /* May be called with local BH enabled. */
 static void unlink_from_pool(struct inet_peer *p)
 {
@@ -286,13 +317,13 @@ static void unlink_from_pool(struct inet_peer *p)
 
 	do_free = 0;
 
-	write_lock_bh(&peers.lock);
+	spin_lock_bh(&peers.lock);
 	/* Check the reference counter.  It was artificially incremented by 1
-	 * in cleanup() function to prevent sudden disappearing.  If the
-	 * reference count is still 1 then the node is referenced only as `p'
-	 * here and from the pool.  So under the exclusive pool lock it's safe
-	 * to remove the node and free it later. */
-	if (atomic_read(&p->refcnt) == 1) {
+	 * in cleanup() function to prevent sudden disappearing.  If we can
+	 * atomically (because of lockless readers) take this last reference,
+	 * it's safe to remove the node and free it later.
+	 */
+	if (atomic_cmpxchg(&p->refcnt, 1, 0) == 1) {
 		struct inet_peer **stack[PEER_MAXDEPTH];
 		struct inet_peer ***stackptr, ***delp;
 		if (lookup(p->v4daddr, stack) != p)
@@ -321,17 +352,18 @@ static void unlink_from_pool(struct inet_peer *p)
 		peers.total--;
 		do_free = 1;
 	}
-	write_unlock_bh(&peers.lock);
+	spin_unlock_bh(&peers.lock);
 
 	if (do_free)
-		kmem_cache_free(peer_cachep, p);
+		call_rcu_bh(&p->rcu, inetpeer_free_rcu);
 	else
 		/* The node is used again.  Decrease the reference counter
 		 * back.  The loop "cleanup -> unlink_from_unused
 		 *   -> unlink_from_pool -> putpeer -> link_to_unused
 		 *   -> cleanup (for the same node)"
 		 * doesn't really exist because the entry will have a
-		 * recent deletion time and will not be cleaned again soon. */
+		 * recent deletion time and will not be cleaned again soon.
+		 */
 		inet_putpeer(p);
 }
 
@@ -375,62 +407,56 @@ static int cleanup_once(unsigned long ttl)
 /* Called with or without local BH being disabled. */
 struct inet_peer *inet_getpeer(__be32 daddr, int create)
 {
-	struct inet_peer *p, *n;
+	struct inet_peer *p;
 	struct inet_peer **stack[PEER_MAXDEPTH], ***stackptr;
 
-	/* Look up for the address quickly. */
-	read_lock_bh(&peers.lock);
-	p = lookup(daddr, NULL);
-	if (p != peer_avl_empty)
-		atomic_inc(&p->refcnt);
-	read_unlock_bh(&peers.lock);
+	/* Look up for the address quickly, lockless.
+	 * Because of a concurrent writer, we might not find an existing entry.
+	 */
+	rcu_read_lock_bh();
+	p = lookup_rcu_bh(daddr);
+	rcu_read_unlock_bh();
+
+	if (p) {
+		/* The existing node has been found.
+		 * Remove the entry from unused list if it was there.
+		 */
+		unlink_from_unused(p);
+		return p;
+	}
 
+	/* retry an exact lookup, taking the lock before.
+	 * At least, nodes should be hot in our cache.
+	 */
+	spin_lock_bh(&peers.lock);
+	p = lookup(daddr, stack);
 	if (p != peer_avl_empty) {
-		/* The existing node has been found. */
+		atomic_inc(&p->refcnt);
+		spin_unlock_bh(&peers.lock);
 		/* Remove the entry from unused list if it was there. */
 		unlink_from_unused(p);
 		return p;
 	}
-
-	if (!create)
-		return NULL;
-
-	/* Allocate the space outside the locked region. */
-	n = kmem_cache_alloc(peer_cachep, GFP_ATOMIC);
-	if (n == NULL)
-		return NULL;
-	n->v4daddr = daddr;
-	atomic_set(&n->refcnt, 1);
-	atomic_set(&n->rid, 0);
-	atomic_set(&n->ip_id_count, secure_ip_id(daddr));
-	n->tcp_ts_stamp = 0;
-
-	write_lock_bh(&peers.lock);
-	/* Check if an entry has suddenly appeared. */
-	p = lookup(daddr, stack);
-	if (p != peer_avl_empty)
-		goto out_free;
-
-	/* Link the node. */
-	link_to_pool(n);
-	INIT_LIST_HEAD(&n->unused);
-	peers.total++;
-	write_unlock_bh(&peers.lock);
+	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
+	if (p) {
+		p->v4daddr = daddr;
+		atomic_set(&p->refcnt, 1);
+		atomic_set(&p->rid, 0);
+		atomic_set(&p->ip_id_count, secure_ip_id(daddr));
+		p->tcp_ts_stamp = 0;
+		INIT_LIST_HEAD(&p->unused);
+
+
+		/* Link the node. */
+		link_to_pool(p);
+		peers.total++;
+	}
+	spin_unlock_bh(&peers.lock);
 
 	if (peers.total >= inet_peer_threshold)
 		/* Remove one less-recently-used entry. */
 		cleanup_once(0);
 
-	return n;
-
-out_free:
-	/* The appropriate node is already in the pool. */
-	atomic_inc(&p->refcnt);
-	write_unlock_bh(&peers.lock);
-	/* Remove the entry from unused list if it was there. */
-	unlink_from_unused(p);
-	/* Free preallocated the preallocated node. */
-	kmem_cache_free(peer_cachep, n);
 	return p;
 }
 


