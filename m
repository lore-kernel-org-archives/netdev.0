From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: seqlock optimization
Date: Fri, 04 Mar 2011 23:13:59 +0100
Message-ID: <1299276839.2758.50.camel@edumazet-laptop>
References: <20110303.003229.229764095.davem@davemloft.net>
	 <1299251348.2676.16.camel@edumazet-laptop>
	 <20110304.111705.193726268.davem@davemloft.net>
	 <20110304.124534.71142427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64821 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498Ab1CDWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 17:14:05 -0500
Received: by wwb22 with SMTP id 22so3264255wwb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 14:14:03 -0800 (PST)
In-Reply-To: <20110304.124534.71142427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 mars 2011 =C3=A0 12:45 -0800, David Miller a =C3=A9crit =
:
> From: David Miller <davem@davemloft.net>
> Date: Fri, 04 Mar 2011 11:17:05 -0800 (PST)
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Fri, 04 Mar 2011 16:09:08 +0100
> >=20
> >> Here is a patch to implement this idea.
> >=20
> > Applied, thanks Eric!
>=20
> Unfortunately, I have to revert, the lockdep annotations needs to
> be updated:
>=20
> net/ipv4/inetpeer.c: In function =E2=80=98peer_avl_rebalance=E2=80=99=
:
> net/ipv4/inetpeer.c:274:10: error: =E2=80=98seqlock_t=E2=80=99 has no=
 member named =E2=80=98dep_map=E2=80=99

Oops thats right, here is an updated version.


Thanks

[PATCH net-next-2.6] inetpeer: seqlock optimization

David noticed :

------------------
Eric, I was profiling the non-routing-cache case and something that
stuck out is the case of calling inet_getpeer() with create=3D=3D0.

If an entry is not found, we have to redo the lookup under a spinlock
to make certain that a concurrent writer rebalancing the tree does
not "hide" an existing entry from us.

This makes the case of a create=3D=3D0 lookup for a not-present entry
really expensive.  It is on the order of 600 cpu cycles on my
Niagara2.

I added a hack to not do the relookup under the lock when create=3D=3D0
and it now costs less than 300 cycles.

This is now a pretty common operation with the way we handle COW'd
metrics, so I think it's definitely worth optimizing.
-----------------

One solution is to use a seqlock instead of a spinlock to protect struc=
t
inet_peer_base.

After a failed avl tree lookup, we can easily detect if a writer did
some changes during our lookup. Taking the lock and redo the lookup is
only necessary in this case.

Note: Add one private rcu_deref_locked() macro to place in one spot the
access to spinlock included in seqlock.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: updated lockdep annotations
 net/ipv4/inetpeer.c |   75 +++++++++++++++++++-----------------------
 1 files changed, 35 insertions(+), 40 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 48f8d45..f604ffd 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -81,19 +81,19 @@ static const struct inet_peer peer_fake_node =3D {
=20
 struct inet_peer_base {
 	struct inet_peer __rcu *root;
-	spinlock_t	lock;
+	seqlock_t	lock;
 	int		total;
 };
=20
 static struct inet_peer_base v4_peers =3D {
 	.root		=3D peer_avl_empty_rcu,
-	.lock		=3D __SPIN_LOCK_UNLOCKED(v4_peers.lock),
+	.lock		=3D __SEQLOCK_UNLOCKED(v4_peers.lock),
 	.total		=3D 0,
 };
=20
 static struct inet_peer_base v6_peers =3D {
 	.root		=3D peer_avl_empty_rcu,
-	.lock		=3D __SPIN_LOCK_UNLOCKED(v6_peers.lock),
+	.lock		=3D __SEQLOCK_UNLOCKED(v6_peers.lock),
 	.total		=3D 0,
 };
=20
@@ -177,6 +177,9 @@ static int addr_compare(const struct inetpeer_addr =
*a,
 	return 0;
 }
=20
+#define rcu_deref_locked(X, BASE)				\
+	rcu_dereference_protected(X, lockdep_is_held(&(BASE)->lock.lock))
+
 /*
  * Called with local BH disabled and the pool lock held.
  */
@@ -187,8 +190,7 @@ static int addr_compare(const struct inetpeer_addr =
*a,
 								\
 	stackptr =3D _stack;					\
 	*stackptr++ =3D &_base->root;				\
-	for (u =3D rcu_dereference_protected(_base->root,		\
-			lockdep_is_held(&_base->lock));		\
+	for (u =3D rcu_deref_locked(_base->root, _base);		\
 	     u !=3D peer_avl_empty; ) {				\
 		int cmp =3D addr_compare(_daddr, &u->daddr);	\
 		if (cmp =3D=3D 0)					\
@@ -198,8 +200,7 @@ static int addr_compare(const struct inetpeer_addr =
*a,
 		else						\
 			v =3D &u->avl_right;			\
 		*stackptr++ =3D v;				\
-		u =3D rcu_dereference_protected(*v,		\
-			lockdep_is_held(&_base->lock));		\
+		u =3D rcu_deref_locked(*v, _base);		\
 	}							\
 	u;							\
 })
@@ -246,13 +247,11 @@ static struct inet_peer *lookup_rcu_bh(const stru=
ct inetpeer_addr *daddr,
 	struct inet_peer __rcu **v;				\
 	*stackptr++ =3D &start->avl_left;				\
 	v =3D &start->avl_left;					\
-	for (u =3D rcu_dereference_protected(*v,			\
-			lockdep_is_held(&base->lock));		\
+	for (u =3D rcu_deref_locked(*v, base);			\
 	     u->avl_right !=3D peer_avl_empty_rcu; ) {		\
 		v =3D &u->avl_right;				\
 		*stackptr++ =3D v;				\
-		u =3D rcu_dereference_protected(*v,		\
-			lockdep_is_held(&base->lock));		\
+		u =3D rcu_deref_locked(*v, base);			\
 	}							\
 	u;							\
 })
@@ -271,21 +270,16 @@ static void peer_avl_rebalance(struct inet_peer _=
_rcu **stack[],
=20
 	while (stackend > stack) {
 		nodep =3D *--stackend;
-		node =3D rcu_dereference_protected(*nodep,
-				lockdep_is_held(&base->lock));
-		l =3D rcu_dereference_protected(node->avl_left,
-				lockdep_is_held(&base->lock));
-		r =3D rcu_dereference_protected(node->avl_right,
-				lockdep_is_held(&base->lock));
+		node =3D rcu_deref_locked(*nodep, base);
+		l =3D rcu_deref_locked(node->avl_left, base);
+		r =3D rcu_deref_locked(node->avl_right, base);
 		lh =3D node_height(l);
 		rh =3D node_height(r);
 		if (lh > rh + 1) { /* l: RH+2 */
 			struct inet_peer *ll, *lr, *lrl, *lrr;
 			int lrh;
-			ll =3D rcu_dereference_protected(l->avl_left,
-				lockdep_is_held(&base->lock));
-			lr =3D rcu_dereference_protected(l->avl_right,
-				lockdep_is_held(&base->lock));
+			ll =3D rcu_deref_locked(l->avl_left, base);
+			lr =3D rcu_deref_locked(l->avl_right, base);
 			lrh =3D node_height(lr);
 			if (lrh <=3D node_height(ll)) {	/* ll: RH+1 */
 				RCU_INIT_POINTER(node->avl_left, lr);	/* lr: RH or RH+1 */
@@ -296,10 +290,8 @@ static void peer_avl_rebalance(struct inet_peer __=
rcu **stack[],
 				l->avl_height =3D node->avl_height + 1;
 				RCU_INIT_POINTER(*nodep, l);
 			} else { /* ll: RH, lr: RH+1 */
-				lrl =3D rcu_dereference_protected(lr->avl_left,
-					lockdep_is_held(&base->lock));	/* lrl: RH or RH-1 */
-				lrr =3D rcu_dereference_protected(lr->avl_right,
-					lockdep_is_held(&base->lock));	/* lrr: RH or RH-1 */
+				lrl =3D rcu_deref_locked(lr->avl_left, base);/* lrl: RH or RH-1 */
+				lrr =3D rcu_deref_locked(lr->avl_right, base);/* lrr: RH or RH-1 *=
/
 				RCU_INIT_POINTER(node->avl_left, lrr);	/* lrr: RH or RH-1 */
 				RCU_INIT_POINTER(node->avl_right, r);	/* r: RH */
 				node->avl_height =3D rh + 1; /* node: RH+1 */
@@ -314,10 +306,8 @@ static void peer_avl_rebalance(struct inet_peer __=
rcu **stack[],
 		} else if (rh > lh + 1) { /* r: LH+2 */
 			struct inet_peer *rr, *rl, *rlr, *rll;
 			int rlh;
-			rr =3D rcu_dereference_protected(r->avl_right,
-				lockdep_is_held(&base->lock));
-			rl =3D rcu_dereference_protected(r->avl_left,
-				lockdep_is_held(&base->lock));
+			rr =3D rcu_deref_locked(r->avl_right, base);
+			rl =3D rcu_deref_locked(r->avl_left, base);
 			rlh =3D node_height(rl);
 			if (rlh <=3D node_height(rr)) {	/* rr: LH+1 */
 				RCU_INIT_POINTER(node->avl_right, rl);	/* rl: LH or LH+1 */
@@ -328,10 +318,8 @@ static void peer_avl_rebalance(struct inet_peer __=
rcu **stack[],
 				r->avl_height =3D node->avl_height + 1;
 				RCU_INIT_POINTER(*nodep, r);
 			} else { /* rr: RH, rl: RH+1 */
-				rlr =3D rcu_dereference_protected(rl->avl_right,
-					lockdep_is_held(&base->lock));	/* rlr: LH or LH-1 */
-				rll =3D rcu_dereference_protected(rl->avl_left,
-					lockdep_is_held(&base->lock));	/* rll: LH or LH-1 */
+				rlr =3D rcu_deref_locked(rl->avl_right, base);/* rlr: LH or LH-1 *=
/
+				rll =3D rcu_deref_locked(rl->avl_left, base);/* rll: LH or LH-1 */
 				RCU_INIT_POINTER(node->avl_right, rll);	/* rll: LH or LH-1 */
 				RCU_INIT_POINTER(node->avl_left, l);	/* l: LH */
 				node->avl_height =3D lh + 1; /* node: LH+1 */
@@ -372,7 +360,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
=20
 	do_free =3D 0;
=20
-	spin_lock_bh(&base->lock);
+	write_seqlock_bh(&base->lock);
 	/* Check the reference counter.  It was artificially incremented by 1
 	 * in cleanup() function to prevent sudden disappearing.  If we can
 	 * atomically (because of lockless readers) take this last reference,
@@ -392,8 +380,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
 			/* look for a node to insert instead of p */
 			struct inet_peer *t;
 			t =3D lookup_rightempty(p, base);
-			BUG_ON(rcu_dereference_protected(*stackptr[-1],
-					lockdep_is_held(&base->lock)) !=3D t);
+			BUG_ON(rcu_deref_locked(*stackptr[-1], base) !=3D t);
 			**--stackptr =3D t->avl_left;
 			/* t is removed, t->daddr > x->daddr for any
 			 * x in p->avl_left subtree.
@@ -409,7 +396,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
 		base->total--;
 		do_free =3D 1;
 	}
-	spin_unlock_bh(&base->lock);
+	write_sequnlock_bh(&base->lock);
=20
 	if (do_free)
 		call_rcu_bh(&p->rcu, inetpeer_free_rcu);
@@ -477,12 +464,16 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
dr *daddr, int create)
 	struct inet_peer __rcu **stack[PEER_MAXDEPTH], ***stackptr;
 	struct inet_peer_base *base =3D family_to_base(daddr->family);
 	struct inet_peer *p;
+	unsigned int sequence;
+	int invalidated;
=20
 	/* Look up for the address quickly, lockless.
 	 * Because of a concurrent writer, we might not find an existing entr=
y.
 	 */
 	rcu_read_lock_bh();
+	sequence =3D read_seqbegin(&base->lock);
 	p =3D lookup_rcu_bh(daddr, base);
+	invalidated =3D read_seqretry(&base->lock, sequence);
 	rcu_read_unlock_bh();
=20
 	if (p) {
@@ -493,14 +484,18 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
dr *daddr, int create)
 		return p;
 	}
=20
+	/* If no writer did a change during our lookup, we can return early. =
*/
+	if (!create && !invalidated)
+		return NULL;
+
 	/* retry an exact lookup, taking the lock before.
 	 * At least, nodes should be hot in our cache.
 	 */
-	spin_lock_bh(&base->lock);
+	write_seqlock_bh(&base->lock);
 	p =3D lookup(daddr, stack, base);
 	if (p !=3D peer_avl_empty) {
 		atomic_inc(&p->refcnt);
-		spin_unlock_bh(&base->lock);
+		write_sequnlock_bh(&base->lock);
 		/* Remove the entry from unused list if it was there. */
 		unlink_from_unused(p);
 		return p;
@@ -524,7 +519,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr=
 *daddr, int create)
 		link_to_pool(p, base);
 		base->total++;
 	}
-	spin_unlock_bh(&base->lock);
+	write_sequnlock_bh(&base->lock);
=20
 	if (base->total >=3D inet_peer_threshold)
 		/* Remove one less-recently-used entry. */


