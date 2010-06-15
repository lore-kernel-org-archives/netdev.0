From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: various changes
Date: Tue, 15 Jun 2010 07:35:21 +0200
Message-ID: <1276580121.30434.322.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64551 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab0FOFf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 01:35:28 -0400
Received: by wyb40 with SMTP id 40so4465737wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 22:35:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to reduce cache line contentions in peer management, to reduce IP
defragmentation overhead.

- peer_fake_node is marked 'const' to make sure its not modified.
  (tested with CONFIG_DEBUG_RODATA=y)

- Group variables in two structures to reduce number of dirtied cache
lines. One named "peers" for avl tree root, its number of entries, and
associated lock. (candidate for RCU conversion)

- A second one named "unused_peers" for unused list and its lock 

- Add a !list_empty() test in unlink_from_unused() to avoid taking lock
when entry is not unused.

- Use atomic_dec_and_lock() in inet_putpeer() to avoid taking lock in
some cases.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   94 +++++++++++++++++++++++++-----------------
 1 file changed, 56 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 6bcfe52..035673f 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -70,17 +70,25 @@
 static struct kmem_cache *peer_cachep __read_mostly;
 
 #define node_height(x) x->avl_height
-static struct inet_peer peer_fake_node = {
-	.avl_left	= &peer_fake_node,
-	.avl_right	= &peer_fake_node,
+
+#define peer_avl_empty ((struct inet_peer *)&peer_fake_node)
+static const struct inet_peer peer_fake_node = {
+	.avl_left	= peer_avl_empty,
+	.avl_right	= peer_avl_empty,
 	.avl_height	= 0
 };
-#define peer_avl_empty (&peer_fake_node)
-static struct inet_peer *peer_root = peer_avl_empty;
-static DEFINE_RWLOCK(peer_pool_lock);
+
+static struct {
+	struct inet_peer *root;
+	rwlock_t	lock;
+	int		total;
+} peers = {
+	.root		= peer_avl_empty,
+	.lock		= __RW_LOCK_UNLOCKED(peers.lock),
+	.total		= 0,
+};
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
-static int peer_total;
 /* Exported for sysctl_net_ipv4.  */
 int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries more
 					 * aggressively at this stage */
@@ -89,8 +97,13 @@ int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min
 int inet_peer_gc_mintime __read_mostly = 10 * HZ;
 int inet_peer_gc_maxtime __read_mostly = 120 * HZ;
 
-static LIST_HEAD(unused_peers);
-static DEFINE_SPINLOCK(inet_peer_unused_lock);
+static struct {
+	struct list_head	list;
+	spinlock_t		lock;
+} unused_peers = {
+	.list			= LIST_HEAD_INIT(unused_peers.list),
+	.lock			= __SPIN_LOCK_UNLOCKED(unused_peers.lock),
+};
 
 static void peer_check_expire(unsigned long dummy);
 static DEFINE_TIMER(peer_periodic_timer, peer_check_expire, 0, 0);
@@ -131,9 +144,11 @@ void __init inet_initpeers(void)
 /* Called with or without local BH being disabled. */
 static void unlink_from_unused(struct inet_peer *p)
 {
-	spin_lock_bh(&inet_peer_unused_lock);
-	list_del_init(&p->unused);
-	spin_unlock_bh(&inet_peer_unused_lock);
+	if (!list_empty(&p->unused)) {
+		spin_lock_bh(&unused_peers.lock);
+		list_del_init(&p->unused);
+		spin_unlock_bh(&unused_peers.lock);
+	}
 }
 
 /*
@@ -146,9 +161,9 @@ static void unlink_from_unused(struct inet_peer *p)
 	struct inet_peer *u, **v;				\
 	if (_stack != NULL) {					\
 		stackptr = _stack;				\
-		*stackptr++ = &peer_root;			\
+		*stackptr++ = &peers.root;			\
 	}							\
-	for (u = peer_root; u != peer_avl_empty; ) {		\
+	for (u = peers.root; u != peer_avl_empty; ) {		\
 		if (_daddr == u->v4daddr)			\
 			break;					\
 		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
@@ -262,7 +277,7 @@ do {								\
 	n->avl_right = peer_avl_empty;				\
 	**--stackptr = n;					\
 	peer_avl_rebalance(stack, stackptr);			\
-} while(0)
+} while (0)
 
 /* May be called with local BH enabled. */
 static void unlink_from_pool(struct inet_peer *p)
@@ -271,7 +286,7 @@ static void unlink_from_pool(struct inet_peer *p)
 
 	do_free = 0;
 
-	write_lock_bh(&peer_pool_lock);
+	write_lock_bh(&peers.lock);
 	/* Check the reference counter.  It was artificially incremented by 1
 	 * in cleanup() function to prevent sudden disappearing.  If the
 	 * reference count is still 1 then the node is referenced only as `p'
@@ -303,10 +318,10 @@ static void unlink_from_pool(struct inet_peer *p)
 			delp[1] = &t->avl_left; /* was &p->avl_left */
 		}
 		peer_avl_rebalance(stack, stackptr);
-		peer_total--;
+		peers.total--;
 		do_free = 1;
 	}
-	write_unlock_bh(&peer_pool_lock);
+	write_unlock_bh(&peers.lock);
 
 	if (do_free)
 		kmem_cache_free(peer_cachep, p);
@@ -326,16 +341,16 @@ static int cleanup_once(unsigned long ttl)
 	struct inet_peer *p = NULL;
 
 	/* Remove the first entry from the list of unused nodes. */
-	spin_lock_bh(&inet_peer_unused_lock);
-	if (!list_empty(&unused_peers)) {
+	spin_lock_bh(&unused_peers.lock);
+	if (!list_empty(&unused_peers.list)) {
 		__u32 delta;
 
-		p = list_first_entry(&unused_peers, struct inet_peer, unused);
+		p = list_first_entry(&unused_peers.list, struct inet_peer, unused);
 		delta = (__u32)jiffies - p->dtime;
 
 		if (delta < ttl) {
 			/* Do not prune fresh entries. */
-			spin_unlock_bh(&inet_peer_unused_lock);
+			spin_unlock_bh(&unused_peers.lock);
 			return -1;
 		}
 
@@ -345,7 +360,7 @@ static int cleanup_once(unsigned long ttl)
 		 * before unlink_from_pool() call. */
 		atomic_inc(&p->refcnt);
 	}
-	spin_unlock_bh(&inet_peer_unused_lock);
+	spin_unlock_bh(&unused_peers.lock);
 
 	if (p == NULL)
 		/* It means that the total number of USED entries has
@@ -364,11 +379,11 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	struct inet_peer **stack[PEER_MAXDEPTH], ***stackptr;
 
 	/* Look up for the address quickly. */
-	read_lock_bh(&peer_pool_lock);
+	read_lock_bh(&peers.lock);
 	p = lookup(daddr, NULL);
 	if (p != peer_avl_empty)
 		atomic_inc(&p->refcnt);
-	read_unlock_bh(&peer_pool_lock);
+	read_unlock_bh(&peers.lock);
 
 	if (p != peer_avl_empty) {
 		/* The existing node has been found. */
@@ -390,7 +405,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	atomic_set(&n->ip_id_count, secure_ip_id(daddr));
 	n->tcp_ts_stamp = 0;
 
-	write_lock_bh(&peer_pool_lock);
+	write_lock_bh(&peers.lock);
 	/* Check if an entry has suddenly appeared. */
 	p = lookup(daddr, stack);
 	if (p != peer_avl_empty)
@@ -399,10 +414,10 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	/* Link the node. */
 	link_to_pool(n);
 	INIT_LIST_HEAD(&n->unused);
-	peer_total++;
-	write_unlock_bh(&peer_pool_lock);
+	peers.total++;
+	write_unlock_bh(&peers.lock);
 
-	if (peer_total >= inet_peer_threshold)
+	if (peers.total >= inet_peer_threshold)
 		/* Remove one less-recently-used entry. */
 		cleanup_once(0);
 
@@ -411,7 +426,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 out_free:
 	/* The appropriate node is already in the pool. */
 	atomic_inc(&p->refcnt);
-	write_unlock_bh(&peer_pool_lock);
+	write_unlock_bh(&peers.lock);
 	/* Remove the entry from unused list if it was there. */
 	unlink_from_unused(p);
 	/* Free preallocated the preallocated node. */
@@ -425,12 +440,12 @@ static void peer_check_expire(unsigned long dummy)
 	unsigned long now = jiffies;
 	int ttl;
 
-	if (peer_total >= inet_peer_threshold)
+	if (peers.total >= inet_peer_threshold)
 		ttl = inet_peer_minttl;
 	else
 		ttl = inet_peer_maxttl
 				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
-					peer_total / inet_peer_threshold * HZ;
+					peers.total / inet_peer_threshold * HZ;
 	while (!cleanup_once(ttl)) {
 		if (jiffies != now)
 			break;
@@ -439,22 +454,25 @@ static void peer_check_expire(unsigned long dummy)
 	/* Trigger the timer after inet_peer_gc_mintime .. inet_peer_gc_maxtime
 	 * interval depending on the total number of entries (more entries,
 	 * less interval). */
-	if (peer_total >= inet_peer_threshold)
+	if (peers.total >= inet_peer_threshold)
 		peer_periodic_timer.expires = jiffies + inet_peer_gc_mintime;
 	else
 		peer_periodic_timer.expires = jiffies
 			+ inet_peer_gc_maxtime
 			- (inet_peer_gc_maxtime - inet_peer_gc_mintime) / HZ *
-				peer_total / inet_peer_threshold * HZ;
+				peers.total / inet_peer_threshold * HZ;
 	add_timer(&peer_periodic_timer);
 }
 
 void inet_putpeer(struct inet_peer *p)
 {
-	spin_lock_bh(&inet_peer_unused_lock);
-	if (atomic_dec_and_test(&p->refcnt)) {
-		list_add_tail(&p->unused, &unused_peers);
+	local_bh_disable();
+
+	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
+		list_add_tail(&p->unused, &unused_peers.list);
 		p->dtime = (__u32)jiffies;
+		spin_unlock(&unused_peers.lock);
 	}
-	spin_unlock_bh(&inet_peer_unused_lock);
+
+	local_bh_enable();
 }


