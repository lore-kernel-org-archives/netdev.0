From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: seqlock optimization
Date: Fri, 04 Mar 2011 16:09:08 +0100
Message-ID: <1299251348.2676.16.camel@edumazet-laptop>
References: <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
	 <20110302.224220.179921025.davem@davemloft.net>
	 <1299137977.2456.15.camel@edumazet-laptop>
	 <20110303.003229.229764095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44205 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759200Ab1CDPJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 10:09:13 -0500
Received: by bwz15 with SMTP id 15so2123733bwz.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 07:09:12 -0800 (PST)
In-Reply-To: <20110303.003229.229764095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 00:32 -0800, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Mar 2011 08:39:37 +0100
>=20
> > Le mercredi 02 mars 2011 =C3=A0 22:42 -0800, David Miller a =C3=A9c=
rit :
> >> Actually, back to the original topic, I wonder how bad it is to si=
mply
> >> elide the recheck in the create=3D=3D0 case anyways.  Except for t=
he ipv4
> >> fragmentation wraparound protection values, perfect inetpeer findi=
ng
> >> is not necessary for correctness.  And IPv4 fragmentation always c=
alls
> >> inetpeer with create!=3D0.
> >=20
> > We could use a seqlock, to detect that a writer might have changed
> > things while we did our RCU lookup ?
>=20
> That would certainly work.

Here is a patch to implement this idea.

Thanks !

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

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 48f8d45..7fd9fab 100644
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
@@ -372,7 +372,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
=20
 	do_free =3D 0;
=20
-	spin_lock_bh(&base->lock);
+	write_seqlock_bh(&base->lock);
 	/* Check the reference counter.  It was artificially incremented by 1
 	 * in cleanup() function to prevent sudden disappearing.  If we can
 	 * atomically (because of lockless readers) take this last reference,
@@ -409,7 +409,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
 		base->total--;
 		do_free =3D 1;
 	}
-	spin_unlock_bh(&base->lock);
+	write_sequnlock_bh(&base->lock);
=20
 	if (do_free)
 		call_rcu_bh(&p->rcu, inetpeer_free_rcu);
@@ -477,12 +477,16 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
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
@@ -493,14 +497,18 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
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
@@ -524,7 +532,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr=
 *daddr, int create)
 		link_to_pool(p, base);
 		base->total++;
 	}
-	spin_unlock_bh(&base->lock);
+	write_sequnlock_bh(&base->lock);
=20
 	if (base->total >=3D inet_peer_threshold)
 		/* Remove one less-recently-used entry. */


