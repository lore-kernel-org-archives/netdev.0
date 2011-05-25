From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Wed, 25 May 2011 04:44:29 +0200
Message-ID: <1306291469.3305.11.camel@edumazet-laptop>
References: <201104250033.03401.maxi@daemonizer.de>
	 <1303878240.2699.41.camel@edumazet-laptop>
	 <1303878771.2699.44.camel@edumazet-laptop>
	 <201104271352.00601.maxi@daemonizer.de>
	 <20110512211033.GA3468@dev1756.snc6.facebook.com>
	 <1305234953.2831.2.camel@edumazet-laptop>
	 <20110524213327.GA3917@dev1756.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110524213327.GA3917@dev1756.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 mai 2011 =C3=A0 14:33 -0700, Arun Sharma a =C3=A9crit :
> On Thu, May 12, 2011 at 11:15:53PM +0200, Eric Dumazet wrote:
> >=20
> > Probably not.
> >=20
> > What gives slub_nomerge=3D1   for you ?
> >=20
>=20
> It took me a while to get a new kernel on a large enough sample
> of machines to get some data.
>=20
> Like you observed in the other thread, this is unlikely to be a rando=
m
> memory corruption.
>=20
> The panics stopped after we moved the list_empty() check under the lo=
ck.
>=20
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -154,11 +154,11 @@ void __init inet_initpeers(void)
>  /* Called with or without local BH being disabled. */
>  static void unlink_from_unused(struct inet_peer *p)
>  {
> +	spin_lock_bh(&unused_peers.lock);
>  	if (!list_empty(&p->unused)) {
> -		spin_lock_bh(&unused_peers.lock);
>  		list_del_init(&p->unused);
> -		spin_unlock_bh(&unused_peers.lock);
>  	}
> +	spin_unlock_bh(&unused_peers.lock);
>  }
> =20
>  static int addr_compare(const struct inetpeer_addr *a,
>=20
> The idea being that the list gets corrupted under some kind of a race
> condition. Two threads racing on list_empty() and executing
> list_del_init() seems harmless.
>=20
> There is probably a different race condition that is mitigated by doi=
ng
> the list_empty() check under the lock.
>=20

Hmm, thanks for the report. Are you running x86 or another arch ?

We probably need some sort of memory barrier.

However, locking this central lock makes the thing too slow, I'll try t=
o
use an atomic_inc_return on p->refcnt instead. (and then lock
unused_peers.lock if we got a 0->1 transition)

I am testing following patch :


diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 9df4e63..43aacbf 100644
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
@@ -213,10 +211,11 @@ static int addr_compare(const struct inetpeer_add=
r *a,
  * We exit from this function if number of links exceeds PEER_MAXDEPTH
  */
 static struct inet_peer *lookup_rcu(const struct inetpeer_addr *daddr,
-				    struct inet_peer_base *base)
+				    struct inet_peer_base *base,
+				    int *newrefcnt)
 {
 	struct inet_peer *u =3D rcu_dereference(base->root);
-	int count =3D 0;
+	int old, new, count =3D 0;
=20
 	while (u !=3D peer_avl_empty) {
 		int cmp =3D addr_compare(daddr, &u->daddr);
@@ -226,8 +225,16 @@ static struct inet_peer *lookup_rcu(const struct i=
netpeer_addr *daddr,
 			 * distinction between an unused entry (refcnt=3D0) and
 			 * a freed one.
 			 */
-			if (unlikely(!atomic_add_unless(&u->refcnt, 1, -1)))
-				u =3D NULL;
+			while (1) {
+				old =3D atomic_read(&u->refcnt);
+				if (old =3D=3D -1)
+					return NULL;
+				new =3D old + 1;
+				if (atomic_cmpxchg(&u->refcnt,
+						   old, new) =3D=3D old)
+					break;
+			}
+			*newrefcnt =3D new;
 			return u;
 		}
 		if (cmp =3D=3D -1)
@@ -465,14 +472,14 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
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
@@ -480,7 +487,8 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr=
 *daddr, int create)
 		/* The existing node has been found.
 		 * Remove the entry from unused list if it was there.
 		 */
-		unlink_from_unused(p);
+		if (newrefcnt =3D=3D 1)
+			unlink_from_unused(p);
 		return p;
 	}
=20
@@ -494,10 +502,11 @@ struct inet_peer *inet_getpeer(struct inetpeer_ad=
dr *daddr, int create)
 	write_seqlock_bh(&base->lock);
 	p =3D lookup(daddr, stack, base);
 	if (p !=3D peer_avl_empty) {
-		atomic_inc(&p->refcnt);
+		newrefcnt =3D atomic_inc_return(&p->refcnt);
 		write_sequnlock_bh(&base->lock);
 		/* Remove the entry from unused list if it was there. */
-		unlink_from_unused(p);
+		if (newrefcnt =3D=3D 1)
+			unlink_from_unused(p);
 		return p;
 	}
 	p =3D create ? kmem_cache_alloc(peer_cachep, GFP_ATOMIC) : NULL;
