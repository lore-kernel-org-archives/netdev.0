From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 10:03:18 +0000
Message-ID: <20090520100318.GA5789@ff.dom.local>
References: <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com> <20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com> <4A139FC4.7030309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	lav@yar.ru, shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:47919 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197AbZETKJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 06:09:41 -0400
Received: by wa-out-1112.google.com with SMTP id j5so77942wah.21
        for <netdev@vger.kernel.org>; Wed, 20 May 2009 03:09:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A139FC4.7030309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 08:14:28AM +0200, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> > David Miller a =E9crit :
> >> From: Neil Horman <nhorman@tuxdriver.com>
> >> Date: Tue, 19 May 2009 15:24:50 -0400
> >>
> >>>> Moving whole group in front would defeat the purpose of move, ac=
tually,
> >>>> since rank in chain is used to decay the timeout in garbage coll=
ector.
> >>>> (search for tmo >>=3D 1; )
> >>>>
> >>> Argh, so the list is implicitly ordered by expiration time.  That
> >>> really defeats the entire purpose of doing grouping in the ilst a=
t
> >>> all.  If thats the case, then I agree, its probably better to to
> >>> take the additional visitation hit in in check_expire above than =
to
> >>> try and preserve ordering.
> >> Yes, this seems best.
> >>
> >> I was worried that somehow the ordering also influences lookups,
> >> because the TOS bits don't go into the hash so I worried that it w=
ould
> >> be important that explicit TOS values appear before wildcard ones.
> >> But it doesn't appear that this is an issue, we don't have wildcar=
d
> >> TOSs in the rtable entries, they are always explicit.
> >>
> >> So I would like to see an explicit final patch from Eric so we can=
 get
> >> this fixed now.
> >>
> >=20
> > I would like to split patches because we have two bugs indeed, and
> > I prefer to get attention for both problems, I dont remember Neil a=
cknowledged
> > the length computation problem.
> >=20
> > First and small patch, candidate for net-2.6 and stable (for 2.6.29=
) :
> >=20
>=20
> Then here is the patch on top on previous one.
>=20
> Thanks to all
>=20
> [PATCH] net: fix rtable leak in net/ipv4/route.c
>=20
> Alexander V. Lukyanov found a regression in 2.6.29 and made a complet=
e
> analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=3D13339
> Quoted here because its a perfect one :
>=20
> begin_of_quotation=20
>  2.6.29 patch has introduced flexible route cache rebuilding. Unfortu=
nately the
>  patch has at least one critical flaw, and another problem.
>=20
>  rt_intern_hash calculates rthi pointer, which is later used for new =
entry
>  insertion. The same loop calculates cand pointer which is used to cl=
ean the
>  list. If the pointers are the same, rtable leak occurs, as first the=
 cand is
>  removed then the new entry is appended to it.
>=20
>  This leak leads to unregister_netdevice problem (usage count > 0).
>=20
>  Another problem of the patch is that it tries to insert the entries =
in certain
>  order, to facilitate counting of entries distinct by all but QoS par=
ameters.
>  Unfortunately, referencing an existing rtable entry moves it to list=
 beginning,
>  to speed up further lookups, so the carefully built order is destroy=
ed.
>=20
>  For the first problem the simplest patch it to set rthi=3D0 when rth=
i=3D=3Dcand, but
>  it will also destroy the ordering.
> end_of_quotation
>=20
>=20
> Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
> (net: implement emergency route cache rebulds when gc_elasticity is e=
xceeded)
>=20
> Trying to keep dst_entries ordered is too complex and breaks the fact=
 that
> order should depend on the frequency of use for garbage collection.
>=20
> A possible fix is to make rt_intern_hash() simpler, and only makes
> rt_check_expire() a litle bit smarter, being able to cope with an arb=
itrary
> entries order. The added loop is running on cache hot data, while cpu
> is prefetching next object, so should be unnoticied.
>=20
> Reported-and-analyzed-by: Alexander V. Lukyanov <lav@yar.ru>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  net/ipv4/route.c |   55 +++++++++++++-------------------------------=
-
>  1 files changed, 17 insertions(+), 38 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 869cf1c..28205e5 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -784,7 +784,7 @@ static void rt_check_expire(void)
>  {
>  	static unsigned int rover;
>  	unsigned int i =3D rover, goal;
> -	struct rtable *rth, **rthp;
> +	struct rtable *rth, *aux, **rthp;
>  	unsigned long samples =3D 0;
>  	unsigned long sum =3D 0, sum2 =3D 0;
>  	u64 mult;
> @@ -812,6 +812,7 @@ static void rt_check_expire(void)
>  		length =3D 0;
>  		spin_lock_bh(rt_hash_lock_addr(i));
>  		while ((rth =3D *rthp) !=3D NULL) {
> +			prefetch(rth->u.dst.rt_next);
>  			if (rt_is_expired(rth)) {
>  				*rthp =3D rth->u.dst.rt_next;
>  				rt_free(rth);
> @@ -820,33 +821,30 @@ static void rt_check_expire(void)
>  			if (rth->u.dst.expires) {
>  				/* Entry is expired even if it is in use */
>  				if (time_before_eq(jiffies, rth->u.dst.expires)) {
> +nofree:
>  					tmo >>=3D 1;
>  					rthp =3D &rth->u.dst.rt_next;
>  					/*
> -					 * Only bump our length if the hash
> -					 * inputs on entries n and n+1 are not
> -					 * the same, we only count entries on
> +					 * We only count entries on
>  					 * a chain with equal hash inputs once
>  					 * so that entries for different QOS
>  					 * levels, and other non-hash input
>  					 * attributes don't unfairly skew
>  					 * the length computation
>  					 */
> -					if ((*rthp =3D=3D NULL) ||
> -					    !compare_hash_inputs(&(*rthp)->fl,
> -								 &rth->fl))
> -						length +=3D ONE;
> +					for (aux =3D rt_hash_table[i].chain;;) {
> +						if (aux =3D=3D rth) {
> +							length +=3D ONE;
> +							break;
> +						}
> +						if (compare_hash_inputs(&aux->fl, &rth->fl))
> +							break;
> +						aux =3D aux->u.dst.rt_next;
> +					}

Very "interesting" for() usage, but isn't it more readable like this?:

					aux =3D rt_hash_table[i].chain;
					while (aux !=3D rth) {
						if (compare_hash_inputs(&aux->fl, &rth->fl))
							break;
						aux =3D aux->u.dst.rt_next;
					}

					if (aux =3D=3D rth)
						length +=3D ONE;

Jarek P.

>  					continue;
>  				}
> -			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
> -				tmo >>=3D 1;
> -				rthp =3D &rth->u.dst.rt_next;
> -				if ((*rthp =3D=3D NULL) ||
> -				    !compare_hash_inputs(&(*rthp)->fl,
> -							 &rth->fl))
> -					length +=3D ONE;
> -				continue;
> -			}
> +			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout))
> +				goto nofree;
> =20
>  			/* Cleanup aged off entries. */
>  			*rthp =3D rth->u.dst.rt_next;
> @@ -1069,7 +1067,6 @@ out:	return 0;
>  static int rt_intern_hash(unsigned hash, struct rtable *rt, struct r=
table **rp)
>  {
>  	struct rtable	*rth, **rthp;
> -	struct rtable	*rthi;
>  	unsigned long	now;
>  	struct rtable *cand, **candp;
>  	u32 		min_score;
> @@ -1089,7 +1086,6 @@ restart:
>  	}
> =20
>  	rthp =3D &rt_hash_table[hash].chain;
> -	rthi =3D NULL;
> =20
>  	spin_lock_bh(rt_hash_lock_addr(hash));
>  	while ((rth =3D *rthp) !=3D NULL) {
> @@ -1135,17 +1131,6 @@ restart:
>  		chain_length++;
> =20
>  		rthp =3D &rth->u.dst.rt_next;
> -
> -		/*
> -		 * check to see if the next entry in the chain
> -		 * contains the same hash input values as rt.  If it does
> -		 * This is where we will insert into the list, instead of
> -		 * at the head.  This groups entries that differ by aspects not
> -		 * relvant to the hash function together, which we use to adjust
> -		 * our chain length
> -		 */
> -		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
> -			rthi =3D rth;
>  	}
> =20
>  	if (cand) {
> @@ -1206,10 +1191,7 @@ restart:
>  		}
>  	}
> =20
> -	if (rthi)
> -		rt->u.dst.rt_next =3D rthi->u.dst.rt_next;
> -	else
> -		rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
> +	rt->u.dst.rt_next =3D rt_hash_table[hash].chain;
> =20
>  #if RT_CACHE_DEBUG >=3D 2
>  	if (rt->u.dst.rt_next) {
> @@ -1225,10 +1207,7 @@ restart:
>  	 * previous writes to rt are comitted to memory
>  	 * before making rt visible to other CPUS.
>  	 */
> -	if (rthi)
> -		rcu_assign_pointer(rthi->u.dst.rt_next, rt);
> -	else
> -		rcu_assign_pointer(rt_hash_table[hash].chain, rt);
> +	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
> =20
>  	spin_unlock_bh(rt_hash_lock_addr(hash));
>  	*rp =3D rt;
>=20
