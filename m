From: Alexei Potashnik <alexei@purestorage.com>
Subject: RE: neigh use-after-free
Date: Fri, 3 Apr 2015 17:27:16 -0700
Message-ID: <5f0a512c725fbaf8f38dbc1bdd9d1b47@mail.gmail.com>
References: <20150403202753.GF32724@Sligo.logfs.org>	 <35adab927f1bade6afd57e62a8720205@mail.gmail.com>
 <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joern Engel <joern@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog105.obsmtp.com ([74.125.245.78]:47945 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751897AbbDDA1T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 20:27:19 -0400
Received: by wgra20 with SMTP id a20so121448070wgr.3
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 17:27:17 -0700 (PDT)
In-Reply-To: <1428104053.25985.192.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>
> On Fri, 2015-04-03 at 13:52 -0700, Alexei Potashnik wrote:
> > Would this be an appropriate solution:
> >
> > diff --git a/net/core/neighbour.c b/net/core/neighbour.c index
> > b49e8ba..38265f2 100644
> > --- a/net/core/neighbour.c
> > +++ b/net/core/neighbour.c
> > @@ -168,7 +168,8 @@ static int neigh_forced_gc(struct neigh_table
> > *tbl)
> >
> >  static void neigh_add_timer(struct neighbour *n, unsigned long whe=
n)
> > {
> > -       neigh_hold(n);
> > +       if (!atomic_inc_not_zero(&n->refcnt))
> > +               return;
> >         if (unlikely(mod_timer(&n->timer, when))) {
> >                 printk("NEIGH: BUG, double timer add, state is %x\n=
",
> >                        n->nud_state);
>
> This is a very ugly hack. Please find root cause.
>
> The correct way to implement refcount on a timer is :
>
> if (!mod_timer(&n->timer, when))
> 	neigh_hold(&n->refcnt);
>
> And current code seems to do that (It dumps a printk() and stack trac=
e
> otherwise)

The printk() and stack trace don't get printed because this is a differ=
ent
case --
it=E2=80=99s not double timer add, but rather add of the timer after ne=
ighbor object
is deleted.

> If refcnt is 0 at this point, it means there is another bug, and we s=
hould
> fix it
> instead of trying to work around it.

I agree. And it seems to be clear what code does it:

ip_finish_output2
+-> __ipv4_neigh_lookup_noref

Lookup name is clearly indicating that noref is intentional. What's not
clear is why.
The change seems to have originated in

commit a263b3093641fb1ec377582c90986a7fd0625184
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jul 2 02:02:15 2012

    ipv4: Make neigh lookups directly in output packet path.

    Do not use the dst cached neigh, we'll be getting rid of that.

    Signed-off-by: David S. Miller <davem@davemloft.net>

Before that neigh object came from dst_get_neighbour_noref(), which use=
d to
return dst->_neighbour. Now, if dst->_neighbour used own a reference, t=
han
the
above commit has introduced the bug. Otherwise, the issue has always be=
en
there
and, perhaps, David Miller can explain why it was deemed safe to operat=
e on
neigh
object here without extra ref.

Alexei
