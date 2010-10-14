From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 16:28:04 -0700
Message-ID: <20101014232804.GI2447@linux.vnet.ibm.com>
References: <m11v801tfr.fsf@fess.ebiederm.org>
 <20101012.130520.48517464.davem@davemloft.net>
 <4CB62FAF.1030009@free.fr>
 <20101013.162321.183058542.davem@davemloft.net>
 <1287028631.2649.100.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, daniel.lezcano@free.fr,
	ebiederm@xmission.com, hans.schillstrom@ericsson.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:58198 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139Ab0JNX2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 19:28:06 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9ENCPjt025035
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 19:12:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9ENS5sj317606
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 19:28:05 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9ENS433010497
	for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 19:28:05 -0400
Content-Disposition: inline
In-Reply-To: <1287028631.2649.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 05:57:11AM +0200, Eric Dumazet wrote:
> Le mercredi 13 octobre 2010 =E0 16:23 -0700, David Miller a =E9crit :
> > From: Daniel Lezcano <daniel.lezcano@free.fr>

[ . . . ]

> >  	for (i =3D 0; i <=3D rt_hash_mask; i++) {
> > +		struct rtable *list =3D NULL, **pprev;
> > +
> >  		if (process_context && need_resched())
> >  			cond_resched();
> >  		rth =3D rt_hash_table[i].chain;
> > @@ -726,41 +727,27 @@ static void rt_do_flush(int process_context)
> >  			continue;
> > =20
> >  		spin_lock_bh(rt_hash_lock_addr(i));
> > -#ifdef CONFIG_NET_NS
> > -		{
> > -		struct rtable ** prev, * p;
> > =20
> > -		rth =3D rt_hash_table[i].chain;
> > +		pprev =3D &rt_hash_table[i].chain;
> > +		rth =3D *pprev;
> > +		while (rth) {
> > +			next =3D rth->dst.rt_next;
> > +			if (dev_net(rth->dst.dev) =3D=3D net) {
>=20
> 		if (net_eq(dev_net(rth->dst.dev), net)) {
>=20
>=20
> > +				*pprev =3D next;
> > =20
> > -		/* defer releasing the head of the list after spin_unlock */
> > -		for (tail =3D rth; tail; tail =3D tail->dst.rt_next)
> > -			if (!rt_is_expired(tail))
> > -				break;
> > -		if (rth !=3D tail)
> > -			rt_hash_table[i].chain =3D tail;
> > -
> > -		/* call rt_free on entries after the tail requiring flush */
> > -		prev =3D &rt_hash_table[i].chain;
> > -		for (p =3D *prev; p; p =3D next) {
> > -			next =3D p->dst.rt_next;
> > -			if (!rt_is_expired(p)) {
> > -				prev =3D &p->dst.rt_next;
> > -			} else {
> > -				*prev =3D next;
> > -				rt_free(p);
> > -			}
> > -		}
> > +				rth->dst.rt_next =3D list;
> > +				list =3D rth;
>=20
> I was wondering about RCU rules here.
> We change pointers while a reader might enter in a loop.
> It seems fine : At soon as we spin_unlock(), the loop should be close=
d.

I don't see where the structure pointed to by list came from, but
especially if it is newly allocated, we do need an rcu_assign_pointer()=
=2E

							Thanx, Paul

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> minor coding style : You should add a brace in the else clause :
>=20
> pprev =3D &rt_hash_table[i].chain;
> for (rth =3D *pprev; rth !=3D NULL; rth =3D next) {
> 	next =3D rth->dst.rt_next;
> 	if (net_eq(dev_net(rth->dst.dev), net)) {
> 		*pprev =3D next;
> 		rth->dst.rt_next =3D list;
> 		list =3D rth;
> 	} else {
> 		pprev =3D &rth->dst.rt_next;
> 	}
> }
>=20
> Thanks !
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
