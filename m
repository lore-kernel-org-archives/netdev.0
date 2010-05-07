From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: avoid one atomic in
 enqueue_to_backlog
Date: Fri, 07 May 2010 12:05:58 +0200
Message-ID: <1273226758.2261.44.camel@edumazet-laptop>
References: <1273136322.2357.15.camel@edumazet-laptop>
	 <20100506.220759.25136752.davem@davemloft.net>
	 <1273209375.2222.37.camel@edumazet-laptop>
	 <1273225881.2261.39.camel@edumazet-laptop>
	 <m2x412e6f7f1005070301h627d5c76z35b3277f3a369c69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44208 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0EGKGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 06:06:02 -0400
Received: by bwz19 with SMTP id 19so471896bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 03:06:01 -0700 (PDT)
In-Reply-To: <m2x412e6f7f1005070301h627d5c76z35b3277f3a369c69@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 18:01 +0800, Changli Gao a =C3=A9crit :
> On Fri, May 7, 2010 at 5:51 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le vendredi 07 mai 2010 =C3=A0 07:16 +0200, Eric Dumazet a =C3=A9cr=
it :
> >> Le jeudi 06 mai 2010 =C3=A0 22:07 -0700, David Miller a =C3=A9crit=
 :
> >>
> >> > Looks great, applied, thanks Eric.
> >>
> >> Thanks, I have a followup to avoid one atomic in enqueue phase too=
 ;)
> >>
> >
> > [PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog
> >
> > If CONFIG_SMP=3Dy, then we own a queue spinlock, we can avoid the a=
tomic
> > test_and_set_bit() from napi_schedule_prep().
> >
> > We now have same number of atomic ops per netif_rx() calls than wit=
h
> > pre-RPS kernel.
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 32611c8..49fa5a6 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2426,8 +2426,10 @@ enqueue:
> >                        return NET_RX_SUCCESS;
> >                }
> >
> > -               /* Schedule NAPI for backlog device */
> > -               if (napi_schedule_prep(&sd->backlog)) {
> > +               /* Schedule NAPI for backlog device
> > +                * We can use non atomic operation since we own the=
 queue lock
> > +                */
> > +               if (!__test_and_set_bit(NAPI_STATE_SCHED, &sd->back=
log.state)) {
> >                        if (!rps_ipi_queued(sd))
> >                                ____napi_schedule(sd, &sd->backlog);
> >                }
> >
>=20
> Why not use a wrapper function?
>=20
> sth. like:
>=20
> static inline int __napi_schedule_prep(struct napi_struct *n)
> {
>    return (!__test_and_set_bit(NAPI_STATE_SCHED, &n->state)
> }
>=20


=46or one user ?=20
Not sure it helps code readability.

Right now we all have our minds knowing every bit of this code, but nex=
t
year ?



