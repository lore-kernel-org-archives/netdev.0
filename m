From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Sun, 26 Aug 2012 21:06:07 -0700
Message-ID: <1346040367.2420.22.camel@edumazet-glaptop>
References: <5038215E.60403@opensuse.org>
	 <1345885186.19483.109.camel@edumazet-glaptop>
	 <1345886085.19483.141.camel@edumazet-glaptop>
	 <1345895225.19483.447.camel@edumazet-glaptop>
	 <CADVnQymYXHcqJEgcgH0OHHFfCe6LAMSBZ0E68NWzDZQNTqB+Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>,
	Netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49798 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928Ab2H0EGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 00:06:10 -0400
Received: by pbbrr13 with SMTP id rr13so6699993pbb.19
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 21:06:10 -0700 (PDT)
In-Reply-To: <CADVnQymYXHcqJEgcgH0OHHFfCe6LAMSBZ0E68NWzDZQNTqB+Sg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-27 at 00:02 -0400, Neal Cardwell wrote:
> On Sat, Aug 25, 2012 at 7:47 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > On Sat, 2012-08-25 at 11:14 +0200, Eric Dumazet wrote:
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> On Sat, 2012-08-25 at 10:59 +0200, Eric Dumazet wrote:
> >> > On Fri, 2012-08-24 at 20:50 -0400, Cristian Rodr=C3=ADguez wrote=
:
> >> > > Hi, the issue I reported with IPV6 few weeks ago seems to be g=
one, but
> >> > > now I am getting the following crash..
> >>
> >> > Oh, I now see the bug, I'll send a patch asap
> >>
> >> Please try the following fix.
> >>
> >> Thanks !
> >
> > Well, this v2 seems cleaner :
> >
> > [PATCH v2] tcp: tcp_slow_start() should not decrease snd_cwnd
> >
> > Cristian Rodr=C3=ADguez reported various lockups in TCP stack,
> > introduced by commit 9dc274151a548 (tcp: fix ABC in tcp_slow_start(=
))
> >
> > We could exit tcp_slow_start() with a zeroed snd_cwnd,
> > and next time we enter tcp_slow_start(), we run an infinite loop.
> >
> > Reported-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
> > Cc: Yuchung Cheng <ycheng@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/ipv4/tcp_cong.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> > index 1432cdb..e656c72 100644
> > --- a/net/ipv4/tcp_cong.c
> > +++ b/net/ipv4/tcp_cong.c
> > @@ -337,7 +337,7 @@ void tcp_slow_start(struct tcp_sock *tp)
> >                 tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
> >                 delta++;
> >         }
> > -       tp->snd_cwnd =3D min(tp->snd_cwnd + delta, tp->snd_cwnd_cla=
mp);
> > +       tp->snd_cwnd =3D clamp(tp->snd_cwnd + delta, tp->snd_cwnd, =
tp->snd_cwnd_clamp);
>=20
> AFAICT if tcp_slow_start() is changing snd_cwnd from non-zero to zero
> then this is because snd_cwnd_clamp is zero here, as you theorize may
> be happening to races somewhere.
>=20
> However, AFAICT from reading the min() and clamp() macros, this code
> with clamp() will still have the same problem as the existing code
> that uses min: if snd_cwnd_clamp is 0 then snd_cwnd will end up 0
> here. (This is because the clamp() macro implicitly assumes that the
> max value is above the min value, and filters agains the max last.)
>=20

Indeed, so the first patch was better...

Not sure I can investigate this problem this week, as I attend LKS/LPC
in San Diego.

Could be that snd_cwnd is zero as well so we have this infinite loop...

        while (tp->snd_cwnd_cnt >=3D tp->snd_cwnd) {
                tp->snd_cwnd_cnt -=3D tp->snd_cwnd;
                delta++;
        }
