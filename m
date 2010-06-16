From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: do not use zero refcnt for
 freed entries
Date: Wed, 16 Jun 2010 11:12:36 -0700
Message-ID: <20100616181236.GD2457@linux.vnet.ibm.com>
References: <1276626194.2541.186.camel@edumazet-laptop>
 <20100615.142506.02275206.davem@davemloft.net>
 <1276656324.19249.39.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:44483 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409Ab0FPSMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 14:12:52 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5GIBLHp008971
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 14:11:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5GICc2h1110252
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 14:12:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5GICbrg019017
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 14:12:37 -0400
Content-Disposition: inline
In-Reply-To: <1276656324.19249.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 16, 2010 at 04:45:24AM +0200, Eric Dumazet wrote:
> Le mardi 15 juin 2010 =E0 14:25 -0700, David Miller a =E9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 15 Jun 2010 20:23:14 +0200
> >=20
> > > inetpeer currently uses an AVL tree protected by an rwlock.
> > >=20
> > > It's possible to make most lookups use RCU
> >  ...
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied, nice work Eric.
>=20
> Thanks David !
>=20
> Re-reading patch I realize refcnt is expected to be 0 for unused entr=
ies
> (obviously), so we should use a different marker for 'about to be fre=
ed'
> ones.
>=20
> Thanks
>=20
> [PATCH net-next-2.6] inetpeer: do not use zero refcnt for freed entri=
es
>=20
> Followup of commit aa1039e73cc2 (inetpeer: RCU conversion)
>=20
> Unused inet_peer entries have a null refcnt.
>=20
> Using atomic_inc_not_zero() in rcu lookups is not going to work for
> them, and slow path is taken.
>=20
> Fix this using -1 marker instead of 0 for deleted entries.

Based on this patch, looks good to me!  (I don't see lookup_rcu_bh() an=
d
friends in the trees I have at hand.)

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/inetpeer.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index 58fbc7e..39a14ba 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -187,7 +187,12 @@ static struct inet_peer *lookup_rcu_bh(__be32 da=
ddr)
>=20
>  	while (u !=3D peer_avl_empty) {
>  		if (daddr =3D=3D u->v4daddr) {
> -			if (unlikely(!atomic_inc_not_zero(&u->refcnt)))
> +			/* Before taking a reference, check if this entry was
> +			 * deleted, unlink_from_pool() sets refcnt=3D-1 to make
> +			 * distinction between an unused entry (refcnt=3D0) and
> +			 * a freed one.
> +			 */
> +			if (unlikely(!atomic_add_unless(&u->refcnt, 1, -1)))
>  				u =3D NULL;
>  			return u;
>  		}
> @@ -322,8 +327,9 @@ static void unlink_from_pool(struct inet_peer *p)
>  	 * in cleanup() function to prevent sudden disappearing.  If we can
>  	 * atomically (because of lockless readers) take this last referenc=
e,
>  	 * it's safe to remove the node and free it later.
> +	 * We use refcnt=3D-1 to alert lockless readers this entry is delet=
ed.
>  	 */
> -	if (atomic_cmpxchg(&p->refcnt, 1, 0) =3D=3D 1) {
> +	if (atomic_cmpxchg(&p->refcnt, 1, -1) =3D=3D 1) {
>  		struct inet_peer **stack[PEER_MAXDEPTH];
>  		struct inet_peer ***stackptr, ***delp;
>  		if (lookup(p->v4daddr, stack) !=3D p)
>=20
>=20
