From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: remove unused list
Date: Thu, 09 Jun 2011 01:35:34 +0200
Message-ID: <1307576134.3980.23.camel@edumazet-laptop>
References: <20110607221934.GZ27166@one.firstfloor.org>
	 <1307501024.3102.1.camel@edumazet-laptop>
	 <20110608025910.GB27166@one.firstfloor.org>
	 <1307502034.3102.2.camel@edumazet-laptop>
	 <20110608030739.GC27166@one.firstfloor.org>
	 <1307504312.3102.9.camel@edumazet-laptop>
	 <1307507299.3102.15.camel@edumazet-laptop>
	 <1307509077.3102.20.camel@edumazet-laptop>
	 <20110608055933.GE27166@one.firstfloor.org>
	 <1307513916.3102.23.camel@edumazet-laptop>
	 <1307514470.3102.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, Andi Kleen <andi@firstfloor.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40967 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678Ab1FHXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 19:35:39 -0400
Received: by wwa36 with SMTP id 36so1091978wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 16:35:38 -0700 (PDT)
In-Reply-To: <1307514470.3102.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen and Tim Chen reported huge contention on inetpeer
unused_peers.lock, on memcached workload on a 40 core machine, with
disabled route cache.

It appears we constantly flip peers refcnt between 0 and 1 values, and
we must insert/remove peers from unused_peers.list, holding a contended
spinlock.

Remove this list completely and perform a garbage collection on-the-fly,
at lookup time, using the expired nodes we met during the tree
traversal.

This removes a lot of code, makes locking more standard, and obsoletes
two sysctls (inet_peer_gc_mintime and inet_peer_gc_maxtime). This also
removes two pointers in inet_peer structure.

There is still a false sharing effect because refcnt is in first cache
line of object [were the links and keys used by lookups are located], we
might move it at the end of inet_peer structure to let this first cache
line mostly read by cpus.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Tim Chen <tim.c.chen@linux.intel.com>
---
 Documentation/networking/ip-sysctl.txt |   10 
 include/net/inetpeer.h                 |    2 
 include/net/ip.h                       |    2 
 net/ipv4/inetpeer.c                    |  280 +++++------------------
 net/ipv4/sysctl_net_ipv4.c             |   14 -
 5 files changed, 74 insertions(+), 234 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d3d653a..3dcb26c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -106,16 +106,6 @@ inet_peer_maxttl - INTEGER
 	when the number of entries in the pool is very small).
 	Measured in seconds.
 
-inet_peer_gc_mintime - INTEGER
-	Minimum interval between garbage collection passes.  This interval is
-	in effect under high memory pressure on the pool.
-	Measured in seconds.
-
-inet_peer_gc_maxtime - INTEGER
-	Minimum interval between garbage collection passes.  This interval is
-	in effect under low (or absent) memory pressure on the pool.
-	Measured in seconds.
-
 TCP variables:
 
 somaxconn - INTEGER
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 8a159cc..1f0966f 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -32,7 +32,6 @@ struct inet_peer {
 	struct inet_peer __rcu	*avl_left, *avl_right;
 	struct inetpeer_addr	daddr;
 	__u32			avl_height;
-	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
@@ -56,6 +55,7 @@ struct inet_peer {
 			struct inetpeer_addr_base	redirect_learned;
 		};
 		struct rcu_head         rcu;
+		struct inet_peer	*gc_next;
 	};
 };
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 66dd491..e9ea7c7 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -228,8 +228,6 @@ extern struct ctl_path net_ipv4_ctl_path[];
 extern int inet_peer_threshold;
 extern int inet_peer_minttl;
 extern int inet_peer_maxttl;
-extern int inet_peer_gc_mintime;
-extern int inet_peer_gc_maxtime;
 
 /* From ip_output.c */
 extern int sysctl_ip_dynaddr;
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index ce616d9..dafbf2c 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -54,15 +54,11 @@
  *  1.  Nodes may appear in the tree only with the pool lock held.
  *  2.  Nodes may disappear from the tree only with the pool lock held
  *      AND reference count being 0.
- *  3.  Nodes appears and disappears from unused node list only under
- *      "inet_peer_unused_lock".
- *  4.  Global variable peer_total is modified under the pool lock.
- *  5.  struct inet_peer fields modification:
+ *  3.  Global variable peer_total is modified under the pool lock.
+ *  4.  struct inet_peer fields modification:
  *		avl_left, avl_right, avl_parent, avl_height: pool lock
- *		unused: unused node list lock
  *		refcnt: atomically against modifications on other CPU;
  *		   usually under some other lock to prevent node disappearing
- *		dtime: unused node list lock
  *		daddr: unchangeable
  *		ip_id_count: atomic value (no lock needed)
  */
@@ -104,19 +100,6 @@ int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries m
 					 * aggressively at this stage */
 int inet_peer_minttl __read_mostly = 120 * HZ;	/* TTL under high load: 120 sec */
 int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min */
-int inet_peer_gc_mintime __read_mostly = 10 * HZ;
-int inet_peer_gc_maxtime __read_mostly = 120 * HZ;
-
-static struct {
-	struct list_head	list;
-	spinlock_t		lock;
-} unused_peers = {
-	.list			= LIST_HEAD_INIT(unused_peers.list),
-	.lock			= __SPIN_LOCK_UNLOCKED(unused_peers.lock),
-};
-
-static void peer_check_expire(unsigned long dummy);
-static DEFINE_TIMER(peer_periodic_timer, peer_check_expire, 0, 0);
 
 
 /* Called from ip_output.c:ip_init  */
@@ -142,21 +125,6 @@ void __init inet_initpeers(void)
 			0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
 			NULL);
 
-	/* All the timers, started at system startup tend
-	   to synchronize. Perturb it a bit.
-	 */
-	peer_periodic_timer.expires = jiffies
-		+ net_random() % inet_peer_gc_maxtime
-		+ inet_peer_gc_maxtime;
-	add_timer(&peer_periodic_timer);
-}
-
-/* Called with or without local BH being disabled. */
-static void unlink_from_unused(struct inet_peer *p)
-{
-	spin_lock_bh(&unused_peers.lock);
-	list_del_init(&p->unused);
-	spin_unlock_bh(&unused_peers.lock);
 }
 
 static int addr_compare(const struct inetpeer_addr *a,
@@ -203,20 +171,6 @@ static int addr_compare(const struct inetpeer_addr *a,
 	u;							\
 })
 
-static bool atomic_add_unless_return(atomic_t *ptr, int a, int u, int *newv)
-{
-	int cur, old = atomic_read(ptr);
-
-	while (old != u) {
-		*newv = old + a;
-		cur = atomic_cmpxchg(ptr, old, *newv);
-		if (cur == old)
-			return true;
-		old = cur;
-	}
-	return false;
-}
-
 /*
  * Called with rcu_read_lock()
  * Because we hold no lock against a writer, its quite possible we fall
@@ -225,8 +179,7 @@ static bool atomic_add_unless_return(atomic_t *ptr, int a, int u, int *newv)
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
 static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
-				    struct inet_peer_base *base,
-				    int *newrefcnt)
+				    struct inet_peer_base *base)
 {
 	struct inet_peer *u = rcu_dereference(base->root);
 	int count = 0;
@@ -235,11 +188,9 @@ static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
 		int cmp = addr_compare(daddr, &u->daddr);
 		if (cmp == 0) {
 			/* Before taking a reference, check if this entry was
-			 * deleted, unlink_from_pool() sets refcnt=-1 to make
-			 * distinction between an unused entry (refcnt=0) and
-			 * a freed one.
+			 * deleted (refcnt=-1)
 			 */
-			if (!atomic_add_unless_return(&u->refcnt, 1, -1, newrefcnt))
+			if (!atomic_add_unless(&u->refcnt, 1, -1))
 				u = NULL;
 			return u;
 		}
@@ -366,137 +317,96 @@ static void inetpeer_free_rcu(struct rcu_head *head)
 	kmem_cache_free(peer_cachep, container_of(head, struct inet_peer, rcu));
 }
 
-/* May be called with local BH enabled. */
 static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
 			     struct inet_peer __rcu **stack[PEER_MAXDEPTH])
 {
-	int do_free;
-
-	do_free = 0;
-
-	write_seqlock_bh(&base->lock);
-	/* Check the reference counter.  It was artificially incremented by 1
-	 * in cleanup() function to prevent sudden disappearing.  If we can
-	 * atomically (because of lockless readers) take this last reference,
-	 * it's safe to remove the node and free it later.
-	 * We use refcnt=-1 to alert lockless readers this entry is deleted.
-	 */
-	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
-		struct inet_peer __rcu ***stackptr, ***delp;
-		if (lookup(&p->daddr, stack, base) != p)
-			BUG();
-		delp = stackptr - 1; /* *delp[0] == p */
-		if (p->avl_left == peer_avl_empty_rcu) {
-			*delp[0] = p->avl_right;
-			--stackptr;
-		} else {
-			/* look for a node to insert instead of p */
-			struct inet_peer *t;
-			t = lookup_rightempty(p, base);
-			BUG_ON(rcu_deref_locked(*stackptr[-1], base) != t);
-			**--stackptr = t->avl_left;
-			/* t is removed, t->daddr > x->daddr for any
-			 * x in p->avl_left subtree.
-			 * Put t in the old place of p. */
-			RCU_INIT_POINTER(*delp[0], t);
-			t->avl_left = p->avl_left;
-			t->avl_right = p->avl_right;
-			t->avl_height = p->avl_height;
-			BUG_ON(delp[1] != &p->avl_left);
-			delp[1] = &t->avl_left; /* was &p->avl_left */
-		}
-		peer_avl_rebalance(stack, stackptr, base);
-		base->total--;
-		do_free = 1;
+	struct inet_peer __rcu ***stackptr, ***delp;
+
+	if (lookup(&p->daddr, stack, base) != p)
+		BUG();
+	delp = stackptr - 1; /* *delp[0] == p */
+	if (p->avl_left == peer_avl_empty_rcu) {
+		*delp[0] = p->avl_right;
+		--stackptr;
+	} else {
+		/* look for a node to insert instead of p */
+		struct inet_peer *t;
+		t = lookup_rightempty(p, base);
+		BUG_ON(rcu_deref_locked(*stackptr[-1], base) != t);
+		**--stackptr = t->avl_left;
+		/* t is removed, t->daddr > x->daddr for any
+		 * x in p->avl_left subtree.
+		 * Put t in the old place of p. */
+		RCU_INIT_POINTER(*delp[0], t);
+		t->avl_left = p->avl_left;
+		t->avl_right = p->avl_right;
+		t->avl_height = p->avl_height;
+		BUG_ON(delp[1] != &p->avl_left);
+		delp[1] = &t->avl_left; /* was &p->avl_left */
 	}
-	write_sequnlock_bh(&base->lock);
-
-	if (do_free)
-		call_rcu(&p->rcu, inetpeer_free_rcu);
-	else
-		/* The node is used again.  Decrease the reference counter
-		 * back.  The loop "cleanup -> unlink_from_unused
-		 *   -> unlink_from_pool -> putpeer -> link_to_unused
-		 *   -> cleanup (for the same node)"
-		 * doesn't really exist because the entry will have a
-		 * recent deletion time and will not be cleaned again soon.
-		 */
-		inet_putpeer(p);
+	peer_avl_rebalance(stack, stackptr, base);
+	base->total--;
+	call_rcu(&p->rcu, inetpeer_free_rcu);
 }
 
 static struct inet_peer_base *family_to_base(int family)
 {
-	return (family == AF_INET ? &v4_peers : &v6_peers);
+	return family == AF_INET ? &v4_peers : &v6_peers;
 }
 
-static struct inet_peer_base *peer_to_base(struct inet_peer *p)
+/* perform garbage collect on all items stacked during a lookup */
+static int inet_peer_gc(struct inet_peer_base *base,
+			struct inet_peer __rcu **stack[PEER_MAXDEPTH],
+			struct inet_peer __rcu ***stackptr)
 {
-	return family_to_base(p->daddr.family);
-}
-
-/* May be called with local BH enabled. */
-static int cleanup_once(unsigned long ttl, struct inet_peer __rcu **stack[PEER_MAXDEPTH])
-{
-	struct inet_peer *p = NULL;
-
-	/* Remove the first entry from the list of unused nodes. */
-	spin_lock_bh(&unused_peers.lock);
-	if (!list_empty(&unused_peers.list)) {
-		__u32 delta;
+	struct inet_peer *p, *gchead = NULL;
+	__u32 delta, ttl;
+	int cnt = 0;
 
-		p = list_first_entry(&unused_peers.list, struct inet_peer, unused);
+	if (base->total >= inet_peer_threshold)
+		ttl = 0; /* be aggressive */
+	else
+		ttl = inet_peer_maxttl
+				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
+					base->total / inet_peer_threshold * HZ;
+	stackptr--; /* last stack slot is peer_avl_empty */
+	while (stackptr > stack) {
+		stackptr--;
+		p = rcu_deref_locked(**stackptr, base);
 		delta = (__u32)jiffies - p->dtime;
-
-		if (delta < ttl) {
-			/* Do not prune fresh entries. */
-			spin_unlock_bh(&unused_peers.lock);
-			return -1;
+		if (atomic_read(&p->refcnt) == 0 && delta >= ttl &&
+		    atomic_cmpxchg(&p->refcnt, 0, -1) == 0) {
+			p->gc_next = gchead;
+			gchead = p;
 		}
-
-		list_del_init(&p->unused);
-
-		/* Grab an extra reference to prevent node disappearing
-		 * before unlink_from_pool() call. */
-		atomic_inc(&p->refcnt);
 	}
-	spin_unlock_bh(&unused_peers.lock);
-
-	if (p == NULL)
-		/* It means that the total number of USED entries has
-		 * grown over inet_peer_threshold.  It shouldn't really
-		 * happen because of entry limits in route cache. */
-		return -1;
-
-	unlink_from_pool(p, peer_to_base(p), stack);
-	return 0;
+	while ((p = gchead) != NULL) {
+		gchead = p->gc_next;
+		cnt++;
+		unlink_from_pool(p, base, stack);
+	}
+	return cnt;
 }
 
-/* Called with or without local BH being disabled. */
 struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 {
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
 	struct inet_peer_base *base = family_to_base(daddr->family);
 	struct inet_peer *p;
 	unsigned int sequence;
-	int invalidated, newrefcnt = 0;
+	int invalidated, gccnt = 0;
 
-	/* Look up for the address quickly, lockless.
+	/* Attempt a lockless lookup first.
 	 * Because of a concurrent writer, we might not find an existing entry.
 	 */
 	rcu_read_lock();
 	sequence = read_seqbegin(&base->lock);
-	p = lookup_rcu(daddr, base, &newrefcnt);
+	p = lookup_rcu(daddr, base);
 	invalidated = read_seqretry(&base->lock, sequence);
 	rcu_read_unlock();
 
-	if (p) {
-found:		/* The existing node has been found.
-		 * Remove the entry from unused list if it was there.
-		 */
-		if (newrefcnt == 1)
-			unlink_from_unused(p);
+	if (p)
 		return p;
-	}
 
 	/* If no writer did a change during our lookup, we can return early. */
 	if (!create && !invalidated)
@@ -506,11 +416,17 @@ found:		/* The existing node has been found.
 	 * At least, nodes should be hot in our cache.
 	 */
 	write_seqlock_bh(&base->lock);
+relookup:
 	p = lookup(daddr, stack, base);
 	if (p != peer_avl_empty) {
-		newrefcnt = atomic_inc_return(&p->refcnt);
+		atomic_inc(&p->refcnt);
 		write_sequnlock_bh(&base->lock);
-		goto found;
+		return p;
+	}
+	if (!gccnt) {
+		gccnt = inet_peer_gc(base, stack, stackptr);
+		if (gccnt && create)
+			goto relookup;
 	}
 	p = create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
@@ -525,7 +441,6 @@ found:		/* The existing node has been found.
 		p->pmtu_expires = 0;
 		p->pmtu_orig = 0;
 		memset(&p->redirect_learned, 0, sizeof(p->redirect_learned));
-		INIT_LIST_HEAD(&p->unused);
 
 
 		/* Link the node. */
@@ -534,63 +449,14 @@ found:		/* The existing node has been found.
 	}
 	write_sequnlock_bh(&base->lock);
 
-	if (base->total >= inet_peer_threshold)
-		/* Remove one less-recently-used entry. */
-		cleanup_once(0, stack);
-
 	return p;
 }
-
-static int compute_total(void)
-{
-	return v4_peers.total + v6_peers.total;
-}
 EXPORT_SYMBOL_GPL(inet_getpeer);
 
-/* Called with local BH disabled. */
-static void peer_check_expire(unsigned long dummy)
-{
-	unsigned long now = jiffies;
-	int ttl, total;
-	struct inet_peer __rcu **stack[PEER_MAXDEPTH];
-
-	total = compute_total();
-	if (total >= inet_peer_threshold)
-		ttl = inet_peer_minttl;
-	else
-		ttl = inet_peer_maxttl
-				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
-					total / inet_peer_threshold * HZ;
-	while (!cleanup_once(ttl, stack)) {
-		if (jiffies != now)
-			break;
-	}
-
-	/* Trigger the timer after inet_peer_gc_mintime .. inet_peer_gc_maxtime
-	 * interval depending on the total number of entries (more entries,
-	 * less interval). */
-	total = compute_total();
-	if (total >= inet_peer_threshold)
-		peer_periodic_timer.expires = jiffies + inet_peer_gc_mintime;
-	else
-		peer_periodic_timer.expires = jiffies
-			+ inet_peer_gc_maxtime
-			- (inet_peer_gc_maxtime - inet_peer_gc_mintime) / HZ *
-				total / inet_peer_threshold * HZ;
-	add_timer(&peer_periodic_timer);
-}
-
 void inet_putpeer(struct inet_peer *p)
 {
-	local_bh_disable();
-
-	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
-		list_add_tail(&p->unused, &unused_peers.list);
-		p->dtime = (__u32)jiffies;
-		spin_unlock(&unused_peers.lock);
-	}
-
-	local_bh_enable();
+	p->dtime = (__u32)jiffies;
+	atomic_dec(&p->refcnt);
 }
 EXPORT_SYMBOL_GPL(inet_putpeer);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 57d0752..69fd720 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -398,20 +398,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.procname	= "inet_peer_gc_mintime",
-		.data		= &inet_peer_gc_mintime,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "inet_peer_gc_maxtime",
-		.data		= &inet_peer_gc_maxtime,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "tcp_orphan_retries",
 		.data		= &sysctl_tcp_orphan_retries,
 		.maxlen		= sizeof(int),


