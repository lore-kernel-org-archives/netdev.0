From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: optimizations
Date: Sun, 06 Dec 2009 09:47:03 +0100
Message-ID: <4B1B6F87.6050201@gmail.com>
References: <4B1A4E07.4030804@gmail.com> <4B1AD0CD.4040407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49451 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547AbZLFIrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 03:47:03 -0500
In-Reply-To: <4B1AD0CD.4040407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> Eric Dumazet wrote, On 12/05/2009 01:11 PM:
>=20
>> - Use atomic_dec_and_test() in inet_putpeer()
>=20
> atomic_dec_and_lock()?

Yes :)

>=20
>>   This takes/dirties the lock only if necessary.
> ...
>=20
>>  void inet_putpeer(struct inet_peer *p)
>>  {
>> -	spin_lock_bh(&inet_peer_unused_lock);
>> -	if (atomic_dec_and_test(&p->refcnt)) {
>> -		list_add_tail(&p->unused, &unused_peers);
>> +	local_bh_disable();
>> +	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
>=20
> Why not:
> 	if (atomic_dec_and_test(&p->refcnt)) {
> 		spin_lock_bh(&inet_peer_unused_lock);
> 		...

Because we have to take the lock before doing the final 1 -> 0 refcount=
 transition.

(Another thread could do the 0 -> 1 transition)

I'll cook a followup patch to also avoid taking the lock in the  1+ -> =
2+ transitions.

Thanks

[PATCH] inetpeer: optimizations

- Use atomic_dec_and_lock() in inet_putpeer()
  This takes/dirties the lock only if necessary.

- Group fields together, since they currently are in BSS and DATA secti=
on,
  we have to dirty two cache lines instead of one.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   78 ++++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 6bcfe52..4125ef9 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -76,11 +76,17 @@ static struct inet_peer peer_fake_node =3D {
 	.avl_height	=3D 0
 };
 #define peer_avl_empty (&peer_fake_node)
-static struct inet_peer *peer_root =3D peer_avl_empty;
-static DEFINE_RWLOCK(peer_pool_lock);
+
+static struct {
+	struct inet_peer *root;
+	rwlock_t	 lock;
+	int		 total;
+} peers =3D {
+	.root	=3D	peer_avl_empty,
+	.lock	=3D	__RW_LOCK_UNLOCKED(peers.lock),
+};
 #define PEER_MAXDEPTH 40 /* sufficient for about 227 nodes */
=20
-static int peer_total;
 /* Exported for sysctl_net_ipv4.  */
 int inet_peer_threshold __read_mostly =3D 65536 + 128;	/* start to thr=
ow entries more
 					 * aggressively at this stage */
@@ -89,8 +95,13 @@ int inet_peer_maxttl __read_mostly =3D 10 * 60 * HZ;=
	/* usual time to live: 10 min
 int inet_peer_gc_mintime __read_mostly =3D 10 * HZ;
 int inet_peer_gc_maxtime __read_mostly =3D 120 * HZ;
=20
-static LIST_HEAD(unused_peers);
-static DEFINE_SPINLOCK(inet_peer_unused_lock);
+static struct {
+	struct list_head list;
+	spinlock_t	 lock;
+} unused_peers =3D {
+	.list	=3D	LIST_HEAD_INIT(unused_peers.list),
+	.lock	=3D	__SPIN_LOCK_UNLOCKED(unused_peers.lock),
+};
=20
 static void peer_check_expire(unsigned long dummy);
 static DEFINE_TIMER(peer_periodic_timer, peer_check_expire, 0, 0);
@@ -131,9 +142,9 @@ void __init inet_initpeers(void)
 /* Called with or without local BH being disabled. */
 static void unlink_from_unused(struct inet_peer *p)
 {
-	spin_lock_bh(&inet_peer_unused_lock);
+	spin_lock_bh(&unused_peers.lock);
 	list_del_init(&p->unused);
-	spin_unlock_bh(&inet_peer_unused_lock);
+	spin_unlock_bh(&unused_peers.lock);
 }
=20
 /*
@@ -146,9 +157,9 @@ static void unlink_from_unused(struct inet_peer *p)
 	struct inet_peer *u, **v;				\
 	if (_stack !=3D NULL) {					\
 		stackptr =3D _stack;				\
-		*stackptr++ =3D &peer_root;			\
+		*stackptr++ =3D &peers.root;			\
 	}							\
-	for (u =3D peer_root; u !=3D peer_avl_empty; ) {		\
+	for (u =3D peers.root; u !=3D peer_avl_empty; ) {		\
 		if (_daddr =3D=3D u->v4daddr)			\
 			break;					\
 		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
@@ -262,7 +273,7 @@ do {								\
 	n->avl_right =3D peer_avl_empty;				\
 	**--stackptr =3D n;					\
 	peer_avl_rebalance(stack, stackptr);			\
-} while(0)
+} while (0)
=20
 /* May be called with local BH enabled. */
 static void unlink_from_pool(struct inet_peer *p)
@@ -271,7 +282,7 @@ static void unlink_from_pool(struct inet_peer *p)
=20
 	do_free =3D 0;
=20
-	write_lock_bh(&peer_pool_lock);
+	write_lock_bh(&peers.lock);
 	/* Check the reference counter.  It was artificially incremented by 1
 	 * in cleanup() function to prevent sudden disappearing.  If the
 	 * reference count is still 1 then the node is referenced only as `p'
@@ -303,10 +314,10 @@ static void unlink_from_pool(struct inet_peer *p)
 			delp[1] =3D &t->avl_left; /* was &p->avl_left */
 		}
 		peer_avl_rebalance(stack, stackptr);
-		peer_total--;
+		peers.total--;
 		do_free =3D 1;
 	}
-	write_unlock_bh(&peer_pool_lock);
+	write_unlock_bh(&peers.lock);
=20
 	if (do_free)
 		kmem_cache_free(peer_cachep, p);
@@ -326,16 +337,16 @@ static int cleanup_once(unsigned long ttl)
 	struct inet_peer *p =3D NULL;
=20
 	/* Remove the first entry from the list of unused nodes. */
-	spin_lock_bh(&inet_peer_unused_lock);
-	if (!list_empty(&unused_peers)) {
+	spin_lock_bh(&unused_peers.lock);
+	if (!list_empty(&unused_peers.list)) {
 		__u32 delta;
=20
-		p =3D list_first_entry(&unused_peers, struct inet_peer, unused);
+		p =3D list_first_entry(&unused_peers.list, struct inet_peer, unused)=
;
 		delta =3D (__u32)jiffies - p->dtime;
=20
 		if (delta < ttl) {
 			/* Do not prune fresh entries. */
-			spin_unlock_bh(&inet_peer_unused_lock);
+			spin_unlock_bh(&unused_peers.lock);
 			return -1;
 		}
=20
@@ -345,7 +356,7 @@ static int cleanup_once(unsigned long ttl)
 		 * before unlink_from_pool() call. */
 		atomic_inc(&p->refcnt);
 	}
-	spin_unlock_bh(&inet_peer_unused_lock);
+	spin_unlock_bh(&unused_peers.lock);
=20
 	if (p =3D=3D NULL)
 		/* It means that the total number of USED entries has
@@ -364,11 +375,11 @@ struct inet_peer *inet_getpeer(__be32 daddr, int =
create)
 	struct inet_peer **stack[PEER_MAXDEPTH], ***stackptr;
=20
 	/* Look up for the address quickly. */
-	read_lock_bh(&peer_pool_lock);
+	read_lock_bh(&peers.lock);
 	p =3D lookup(daddr, NULL);
 	if (p !=3D peer_avl_empty)
 		atomic_inc(&p->refcnt);
-	read_unlock_bh(&peer_pool_lock);
+	read_unlock_bh(&peers.lock);
=20
 	if (p !=3D peer_avl_empty) {
 		/* The existing node has been found. */
@@ -390,7 +401,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int cr=
eate)
 	atomic_set(&n->ip_id_count, secure_ip_id(daddr));
 	n->tcp_ts_stamp =3D 0;
=20
-	write_lock_bh(&peer_pool_lock);
+	write_lock_bh(&peers.lock);
 	/* Check if an entry has suddenly appeared. */
 	p =3D lookup(daddr, stack);
 	if (p !=3D peer_avl_empty)
@@ -399,10 +410,10 @@ struct inet_peer *inet_getpeer(__be32 daddr, int =
create)
 	/* Link the node. */
 	link_to_pool(n);
 	INIT_LIST_HEAD(&n->unused);
-	peer_total++;
-	write_unlock_bh(&peer_pool_lock);
+	peers.total++;
+	write_unlock_bh(&peers.lock);
=20
-	if (peer_total >=3D inet_peer_threshold)
+	if (peers.total >=3D inet_peer_threshold)
 		/* Remove one less-recently-used entry. */
 		cleanup_once(0);
=20
@@ -411,7 +422,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int cr=
eate)
 out_free:
 	/* The appropriate node is already in the pool. */
 	atomic_inc(&p->refcnt);
-	write_unlock_bh(&peer_pool_lock);
+	write_unlock_bh(&peers.lock);
 	/* Remove the entry from unused list if it was there. */
 	unlink_from_unused(p);
 	/* Free preallocated the preallocated node. */
@@ -425,12 +436,12 @@ static void peer_check_expire(unsigned long dummy=
)
 	unsigned long now =3D jiffies;
 	int ttl;
=20
-	if (peer_total >=3D inet_peer_threshold)
+	if (peers.total >=3D inet_peer_threshold)
 		ttl =3D inet_peer_minttl;
 	else
 		ttl =3D inet_peer_maxttl
 				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
-					peer_total / inet_peer_threshold * HZ;
+					peers.total / inet_peer_threshold * HZ;
 	while (!cleanup_once(ttl)) {
 		if (jiffies !=3D now)
 			break;
@@ -439,22 +450,23 @@ static void peer_check_expire(unsigned long dummy=
)
 	/* Trigger the timer after inet_peer_gc_mintime .. inet_peer_gc_maxti=
me
 	 * interval depending on the total number of entries (more entries,
 	 * less interval). */
-	if (peer_total >=3D inet_peer_threshold)
+	if (peers.total >=3D inet_peer_threshold)
 		peer_periodic_timer.expires =3D jiffies + inet_peer_gc_mintime;
 	else
 		peer_periodic_timer.expires =3D jiffies
 			+ inet_peer_gc_maxtime
 			- (inet_peer_gc_maxtime - inet_peer_gc_mintime) / HZ *
-				peer_total / inet_peer_threshold * HZ;
+				peers.total / inet_peer_threshold * HZ;
 	add_timer(&peer_periodic_timer);
 }
=20
 void inet_putpeer(struct inet_peer *p)
 {
-	spin_lock_bh(&inet_peer_unused_lock);
-	if (atomic_dec_and_test(&p->refcnt)) {
-		list_add_tail(&p->unused, &unused_peers);
+	local_bh_disable();
+	if (atomic_dec_and_lock(&p->refcnt, &unused_peers.lock)) {
+		list_add_tail(&p->unused, &unused_peers.list);
 		p->dtime =3D (__u32)jiffies;
+		spin_unlock(&unused_peers.lock);
 	}
-	spin_unlock_bh(&inet_peer_unused_lock);
+	local_bh_enable();
 }

