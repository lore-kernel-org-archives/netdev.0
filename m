From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid frag allocation for small frames
Date: Tue, 29 Nov 2011 08:51:50 +0100
Message-ID: <1322553110.2970.79.camel@edumazet-laptop>
References: <1319286237.6180.49.camel@edumazet-laptop>
	 <CAGK4HS_Nryz6jWuqcHPu8AK1Rp6kFRp6M_y-yaGFcnX+pjX47Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49704 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab1K2Hv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 02:51:56 -0500
Received: by bkas6 with SMTP id s6so134112bka.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 23:51:55 -0800 (PST)
In-Reply-To: <CAGK4HS_Nryz6jWuqcHPu8AK1Rp6kFRp6M_y-yaGFcnX+pjX47Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 17:04 -0800, Vijay Subramanian a =C3=A9=
crit :
> On 22 October 2011 05:23, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> > tcp_sendmsg() uses select_size() helper to choose skb head size whe=
n a
> > new skb must be allocated.
> >
> > If GSO is enabled for the socket, current strategy is to force all
> > payload data to be outside of headroom, in PAGE fragments.
> >
> > This strategy is not welcome for small packets, wasting memory.
> >
> > Experiments show that best results are obtained when using 2048 byt=
es
> > for skb head (This includes the skb overhead and various headers)
> >
> > This patch provides better len/truesize ratios for packets sent to
> > loopback device, and reduce memory needs for in-flight loopback pac=
kets,
> > particularly on arches with big pages.
> >
> > If a sender sends many 1-byte packets to an unresponsive applicatio=
n,
> > receiver rmem_alloc will grow faster and will stop queuing these pa=
ckets
> > sooner, or will collapse its receive queue to free excess memory.
> >
> > netperf -t TCP_RR results are improved by ~4 %, and many workloads =
are
> > improved as well (tbench, mysql...)
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/ipv4/tcp.c |    9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 704adad..cd45b44 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -897,9 +897,12 @@ static inline int select_size(const struct soc=
k *sk, int sg)
> >        int tmp =3D tp->mss_cache;
> >
> >        if (sg) {
> > -               if (sk_can_gso(sk))
> > -                       tmp =3D 0;
> > -               else {
> > +               if (sk_can_gso(sk)) {
> > +                       /* Small frames wont use a full page:
> > +                        * Payload will immediately follow tcp head=
er.
> > +                        */
> > +                       tmp =3D SKB_WITH_OVERHEAD(2048 - MAX_TCP_HE=
ADER);
> > +               } else {
> >                        int pgbreak =3D SKB_MAX_HEAD(MAX_TCP_HEADER)=
;
> >
> >                        if (tmp >=3D pgbreak &&
> >
> >
>=20
>=20
>=20
> This patch from Eric fixing select_size in tcp.c was queued to be
> applied but does not seem to be in net-next tree. Was this somehow
> overlooked or have I missed something?
>=20

Good catch Vijay, thanks for noticing !

David, do you want me to respin this ?
