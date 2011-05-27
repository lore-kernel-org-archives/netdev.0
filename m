From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Fri, 27 May 2011 05:27:11 +0200
Message-ID: <1306466831.2543.58.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
	 <1305234953.2831.2.camel@edumazet-laptop>
	 <20110524213327.GA3917@dev1756.snc6.facebook.com>
	 <1306291469.3305.11.camel@edumazet-laptop>
	 <20110525060609.GA32244@dev1756.snc6.facebook.com>
	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com>
	 <1306439246.2543.10.camel@edumazet-laptop>  <4DDECA9B.8080206@fb.com>
	 <1306447292.2543.32.camel@edumazet-laptop>  <4DDEEBC5.80804@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>
To: Arun Sharma <asharma@fb.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DDEEBC5.80804@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 mai 2011 =C3=A0 17:09 -0700, Arun Sharma a =C3=A9crit :
> On 5/26/11 3:01 PM, Eric Dumazet wrote:
>=20
>=20
> >> Yeah - using the refcnt seems better than list_empty(), but I'm no=
t sure
> >> that your patch addresses the race above.
> >
> > It does.
>=20
> True. I can't find any holes in this method and it resolves the "fail=
ure=20
> to unlink from unused" case.
>=20
> Perhaps wrap the while(1) loop into its own primitive in atomic.h or =
use=20
> an existing primitive?
>=20

Sure, here is a formal submission I cooked.

Thanks

[PATCH] inetpeer: fix race in unused_list manipulations

Several crashes in cleanup_once() were reported in recent kernels.

Commit d6cc1d642de9 (inetpeer: various changes) added a race in
unlink_from_unused().

One way to avoid taking unused_peers.lock before doing the list_empty()
test is to catch 0->1 refcnt transitions, using full barrier atomic
operations variants (atomic_cmpxchg() and atomic_inc_return()) instead
of previous atomic_inc() and atomic_add_unless() variants.

We then call unlink_from_unused() only for the owner of the 0->1
transition.

Add a new atomic_add_unless_return() static helper

With help from Arun Sharma.

Refs: https://bugzilla.kernel.org/show_bug.cgi?id=3D32772

Reported-by: Arun Sharma <asharma@fb.com>
Reported-by: Maximilian Engelhardt <maxi@daemonizer.de>
Reported-by: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   42 +++++++++++++++++++++++++++---------------
 1 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9df4e63..ce616d9 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -154,11 +154,9 @@ void __init inet_initpeers(void)
 /* Called with or without local BH being disabled. */
 static void unlink_from_unused(struct inet_peer *p)
 {
-	if (!list_empty(&p->unused)) {
-		spin_lock_bh(&unused_peers.lock);
-		list_del_init(&p->unused);
-		spin_unlock_bh(&unused_peers.lock);
-	}
+	spin_lock_bh(&unused_peers.lock);
+	list_del_init(&p->unused);
+	spin_unlock_bh(&unused_peers.lock);
 }
=20
 static int addr_compare(const struct inetpeer_addr *a,
@@ -205,6 +203,20 @@ static int addr_compare(const struct inetpeer_addr=
 *a,
 	u;							\
 })
=20
+static bool atomic_add_unless_return(atomic_t *ptr, int a, int u, int =
*newv)
+{
+	int cur, old =3D atomic_read(ptr);
+
+	while (old !=3D u) {
+		*newv =3D old + a;
+		cur =3D atomic_cmpxchg(ptr, old, *newv);
+		if (cur =3D=3D old)
+			return true;
+		old =3D cur;
+	}
+	return false;
+}
+
 /*
  * Called with rcu_read_lock()
  * Because we hold no lock against a writer, its quite possible we fal=
l
@@ -213,7 +225,8 @@ static int addr_compare(const struct inetpeer_addr =
*a,
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
 static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
-				    struct inet_peer_base *base)
+				    struct inet_peer_base *base,
+				    int *newrefcnt)
 {
 	struct inet_peer *u =3D rcu_dereference(base->root);
 	int count =3D 0;
@@ -226,7 +239,7 @@ static struct inet_peer *lookup_rcu(const struct in=
etpeer_addr *daddr,
 			 * distinction between an unused entry (refcnt=3D0) and
 			 * a freed one.
 			 */
-			if (unlikely(!atomic_add_unless(&u->refcnt, 1, -1)))
+			if (!atomic_add_unless_return(&u->refcnt, 1, -1, newrefcnt))
 				u =3D NULL;
 			return u;
 		}
@@ -465,22 +478,23 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
dr *daddr, int create)
 	struct inet_peer_base *base =3D family_to_base(daddr->family);
 	struct inet_peer *p;
 	unsigned int sequence;
-	int invalidated;
+	int invalidated, newrefcnt =3D 0;
=20
 	/* Look up for the address quickly, lockless.
 	 * Because of a concurrent writer, we might not find an existing entr=
y.
 	 */
 	rcu_read_lock();
 	sequence =3D read_seqbegin(&base->lock);
-	p =3D lookup_rcu(daddr, base);
+	p =3D lookup_rcu(daddr, base, &newrefcnt);
 	invalidated =3D read_seqretry(&base->lock, sequence);
 	rcu_read_unlock();
=20
 	if (p) {
-		/* The existing node has been found.
+found:		/* The existing node has been found.
 		 * Remove the entry from unused list if it was there.
 		 */
-		unlink_from_unused(p);
+		if (newrefcnt =3D=3D 1)
+			unlink_from_unused(p);
 		return p;
 	}
=20
@@ -494,11 +508,9 @@ struct inet_peer *inet_getpeer(struct inetpeer_add=
r *daddr, int create)
 	write_seqlock_bh(&base->lock);
 	p =3D lookup(daddr, stack, base);
 	if (p !=3D peer_avl_empty) {
-		atomic_inc(&p->refcnt);
+		newrefcnt =3D atomic_inc_return(&p->refcnt);
 		write_sequnlock_bh(&base->lock);
-		/* Remove the entry from unused list if it was there. */
-		unlink_from_unused(p);
-		return p;
+		goto found;
 	}
 	p =3D create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
 	if (p) {
