From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neighbour table RCU
Date: Tue, 01 Sep 2009 18:14:37 +0200
Message-ID: <4A9D486D.4020408@gmail.com>
References: <20090831150453.3437a65c@nehalam> <4A9CC429.5020803@gmail.com> <200909011855.34175.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44653 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbZIAQOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:14:37 -0400
In-Reply-To: <200909011855.34175.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Tuesday 01 September 2009 09:50:17 Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>> Looking at the neighbour table, it should be possible to get
>>> rid of the two reader/writer locks.  The hash table lock is pretty
>>> amenable to RCU, but the dynamic resizing makes it non-trivial.
>>> Thinking of using a combination of RCU and sequence counts so that =
the
>>> reader would just rescan if resize was in progress.
>> I am not sure neigh_tbl_lock rwlock should be changed, I did not
>> see any contention on it.
>>
>=20
> Speaking about neighbour optimizations, here is a RFC patch which mak=
es the=20
> tables double linked, for constant time deletion. It has given us a s=
ignificant=20
> performance improvement - in less then usual setups though, with lots=
 of=20
> neighbours.

How many "struct neigh_parms" do you have in your setups, and
what is the frequency of neigh_parms_release() calls ???

>=20
> Would something like this be acceptable for upstream? (pardon the p4 =
diff dump=20
> :) - but I think it will give a rough idea, if acceptable will clean =
it up and=20
> properly submit it)

Seems straightforward

>=20
> BTW, would switching to list_head be better?

Yes, definitly :)

>=20
> Thanks,
> tavi
>=20
> =3D=3D=3D=3D //packages/linux-2.6.7/main/src/include/net/neighbour.h#=
2 (text) =3D=3D=3D=3D
>=20
> @@ -56,6 +56,7 @@
>  struct neigh_parms
>  {
>         struct neigh_parms *next;
> +       struct neigh_parms **pprev;
>         int     (*neigh_setup)(struct neighbour *);
>         struct neigh_table *tbl;
>         int     entries;
>=20
> =3D=3D=3D=3D //packages/linux-2.6.7/main/src/net/core/neighbour.c#3 (=
text) =3D=3D=3D=3D
>=20
> @@ -1127,8 +1127,10 @@
>                 }
>                 p->sysctl_table =3D NULL;
>                 write_lock_bh(&tbl->lock);
> -               p->next         =3D tbl->parms.next;
> +               if ((p->next =3D tbl->parms.next))
> +                       p->next->pprev =3D &p->next;
>                 tbl->parms.next =3D p;
> +               p->pprev =3D &tbl->parms.next;
>                 write_unlock_bh(&tbl->lock);
>         }
>         return p;
> @@ -1136,21 +1138,14 @@
> =20
>  void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms=
 *parms)
>  {
> -       struct neigh_parms **p;
> -
>         if (!parms || parms =3D=3D &tbl->parms)
>                 return;
>         write_lock_bh(&tbl->lock);
> -       for (p =3D &tbl->parms.next; *p; p =3D &(*p)->next) {
> -               if (*p =3D=3D parms) {
> -                       *p =3D parms->next;
> -                       write_unlock_bh(&tbl->lock);
> -                       kfree(parms);
> -                       return;
> -               }
> -       }
> +       if ((*parms->pprev =3D parms->next))
> +               parms->next->pprev =3D parms->pprev;
>         write_unlock_bh(&tbl->lock);
> -       NEIGH_PRINTK1("neigh_parms_release: not found\n");
> +       kfree(parms);
> +       return;
>  }
> --
