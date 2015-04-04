From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: neigh use-after-free
Date: Fri, 03 Apr 2015 17:44:09 -0700
Message-ID: <1428108249.25985.197.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150403202753.GF32724@Sligo.logfs.org>
	 <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
	 <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Potashnik <alexei@purestorage.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34569 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbDDAoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 20:44:13 -0400
Received: by pactp5 with SMTP id tp5so131202579pac.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 17:44:13 -0700 (PDT)
In-Reply-To: <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 17:27 -0700, Alexei Potashnik wrote:
> > -----Original Message-----
> > From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >
> > On Fri, 2015-04-03 at 13:52 -0700, Alexei Potashnik wrote:
> > > Would this be an appropriate solution:
> > >
> > > diff --git a/net/core/neighbour.c b/net/core/neighbour.c index
> > > b49e8ba..38265f2 100644
> > > --- a/net/core/neighbour.c
> > > +++ b/net/core/neighbour.c
> > > @@ -168,7 +168,8 @@ static int neigh_forced_gc(struct neigh_table
> > > *tbl)
> > >
> > >  static void neigh_add_timer(struct neighbour *n, unsigned long w=
hen)
> > > {
> > > -       neigh_hold(n);
> > > +       if (!atomic_inc_not_zero(&n->refcnt))
> > > +               return;
> > >         if (unlikely(mod_timer(&n->timer, when))) {
> > >                 printk("NEIGH: BUG, double timer add, state is %x=
\n",
> > >                        n->nud_state);
> >
> > This is a very ugly hack. Please find root cause.
> >
> > The correct way to implement refcount on a timer is :
> >
> > if (!mod_timer(&n->timer, when))
> > 	neigh_hold(&n->refcnt);
> >
> > And current code seems to do that (It dumps a printk() and stack tr=
ace
> > otherwise)
>=20
> The printk() and stack trace don't get printed because this is a diff=
erent
> case --
> it=E2=80=99s not double timer add, but rather add of the timer after =
neighbor object
> is deleted.
>=20
> > If refcnt is 0 at this point, it means there is another bug, and we=
 should
> > fix it
> > instead of trying to work around it.
>=20
> I agree. And it seems to be clear what code does it:
>=20
> ip_finish_output2
> +-> __ipv4_neigh_lookup_noref
>=20
> Lookup name is clearly indicating that noref is intentional. What's n=
ot
> clear is why.
> The change seems to have originated in
>=20
> commit a263b3093641fb1ec377582c90986a7fd0625184
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Jul 2 02:02:15 2012
>=20
>     ipv4: Make neigh lookups directly in output packet path.
>=20
>     Do not use the dst cached neigh, we'll be getting rid of that.
>=20
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Before that neigh object came from dst_get_neighbour_noref(), which u=
sed to
> return dst->_neighbour. Now, if dst->_neighbour used own a reference,=
 than
> the
> above commit has introduced the bug. Otherwise, the issue has always =
been
> there
> and, perhaps, David Miller can explain why it was deemed safe to oper=
ate on
> neigh
> object here without extra ref.
>=20
> Alexei

Your debugging code might be wrong.

At entry of neigh_add_timer(), n->refcnt can be 0 if caller holds
the correct lock, preventing the timer handler to proceed and decrement
refcnt.

neigh_timer_handler() does :

write_lock(&neigh->lock);
=2E..
write_unlock(&neigh->lock);
neigh_release(neigh);
