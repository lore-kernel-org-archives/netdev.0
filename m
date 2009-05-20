From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: fix rtable leak in net/ipv4/route.c
Date: Wed, 20 May 2009 06:48:38 -0400
Message-ID: <20090520104838.GB25492@hmsreliant.think-freely.org>
References: <20090519162048.GB28034@hmsreliant.think-freely.org> <4A12FEDA.7040806@cosmosbay.com> <20090519192450.GF28034@hmsreliant.think-freely.org> <20090519.150517.62361946.davem@davemloft.net> <4A138CFE.5070901@cosmosbay.com> <4A139FC4.7030309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com, lav@yar.ru,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42403 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755556AbZETKsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 06:48:53 -0400
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
Acked-by: Neil Horman <nhorman@tuxdriver.com>

