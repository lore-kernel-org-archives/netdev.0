From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Mon, 17 Jan 2011 08:17:49 +0100
Message-ID: <1295248669.12859.23.camel@edumazet-laptop>
References: <1295021808.3937.110.camel@edumazet-laptop>
	 <20110114095201.4fc58a45@nehalam>
	 <1295028502.3937.116.camel@edumazet-laptop>
	 <20110114110342.4d95ad5b@nehalam> <20110116223540.GA1861@del.dom.local>
	 <AANLkTim14h+6k6nt+UWP5gDcT5NmAGLU_S+wG6VhDn-O@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61732 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab1AQHSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 02:18:00 -0500
Received: by wwa36 with SMTP id 36so5107511wwa.1
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 23:17:59 -0800 (PST)
In-Reply-To: <AANLkTim14h+6k6nt+UWP5gDcT5NmAGLU_S+wG6VhDn-O@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 08:09 +0800, Changli Gao a =C3=A9crit :
> On Mon, Jan 17, 2011 at 6:35 AM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
> > On Fri, Jan 14, 2011 at 11:03:42AM -0800, Stephen Hemminger wrote:
> >> From Eric Dumazet <eric.dumazet@gmail.com>
> >>
> >> In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we =
fixed
> >> a problem with pfifo_head drops that incorrectly decreased
> >> sch->bstats.bytes and sch->bstats.packets
> >>
> >> Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
> >> previously enqueued packet, and bstats cannot be changed, so
> >> bstats/rates are not accurate (over estimated)
> >>
> >> This patch changes the qdisc_bstats updates to be done at dequeue(=
) time
> >> instead of enqueue() time. bstats counters no longer account for d=
ropped
> >> frames, and rates are more correct, since enqueue() bursts dont ha=
ve
> >> effect on dequeue() rate.
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> >>
> >> CC: Patrick McHardy <kaber@trash.net>
> >> CC: Jarek Poplawski <jarkao2@gmail.com>
> >> CC: jamal <hadi@cyberus.ca>
> > ...
> >> --- a/net/sched/sch_drr.c     2011-01-14 09:19:00.830857886 -0800
> >> +++ b/net/sched/sch_drr.c     2011-01-14 09:28:20.398631228 -0800
> >> @@ -376,7 +376,6 @@ static int drr_enqueue(struct sk_buff *s
> >>       }
> >>
> >>       bstats_update(&cl->bstats, skb);
> >
> > Why leave leaf classes with different stats?
> >
>=20
> HTB also has the same problem, and I have fixed in my own product, bu=
t
> the patch was rejected.
>=20
> http://patchwork.ozlabs.org/patch/6227/
>=20

Hmm, considering qdisc stats are not used in kernel (only updated and
reported to tc users) it seems to me counting arrival instead of
departure rates is mostly useless for the user, if drops are ignored.

(I am not speaking of direct drops, when we try to enqueue() this skb,
but later ones, when another skb is enqueued and we drop a previously
enqueued skb)

User really wants to see the effective departure rate, to check its
qdisc parameters in respect with kernel ones (HZ=3D100/1000, HIGH res
timers off/on, ...)

Arrival rates are of litle use. However, it might be good to have a
second "bstats" only for dropped packets/bytes, or extend bstats in a
compatible way (maybe adding fields to the end of structure)



