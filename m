From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Thu, 1 Dec 2011 22:35:31 +0100
Message-ID: <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
References: <1322684749.2602.3.camel@edumazet-laptop>
	<20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
	<1322773594.2750.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>, Jim Gettys <jg@freedesktop.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37377 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab1LAVfc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:35:32 -0500
Received: by iage36 with SMTP id e36so3068097iag.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 13:35:31 -0800 (PST)
In-Reply-To: <1322773594.2750.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2011 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mercredi 30 novembre 2011 =E0 14:36 -0800, Stephen Hemminger a =E9=
crit :
>
>> (Almost) nobody uses RED because they can't figure it out.
>> According to Wikipedia, VJ says that:
>> =A0"there are not one, but two bugs in classic RED."

Heh. "There were not two, but four bugs in Linux red".

Now reduced to 2. :)

> RED is useful for high throughput routers, I doubt many linux machine=
s
> act as such devices.

"High throughput" at the time red was designed was not much faster
than a T1 line.

RED appears to be used by default in both gargoyle's and openwrt's QoS =
systems,
underneath unholy combinations of HTB, HSFC, and SFQ
so it's more widely used than you might think. Not that works well.

RED doesn't work worth beans on variable bandwidth links (cable
modems/wireless).

Once you are simulating a fixed rate link (e.g with HTB), then it sort =
of
kinda maybe can apply.

RED was also designed at a time when long distance traffic was fixed ra=
te
and bidirectional, so the 'average packet' parameter made sense.
Modern day traffic is far more asymmetric.

RED might still be fairly effective on a modern day fixed rate line,
such as DSL,
and on DSLAMS and the like.

Linux's red has an additional problem in that it seems byte oriented
rather than packet
oriented, and most folk even trying to do simulations with red seem to =
be
choosing packet oriented - which ties into the asymmetric problem noted=
 above
mildly better.

All that said, it's time came, and is rapidly ending.

I do look forward to a replacement for the algorithm one day soon.

> I was considering adding Adaptative RED (Sally Floyd, Ramakrishna
> Gummadi, Scott Shender), August 2001
>
> In this version, maxp is dynamic (from 1% to 50%), and user only have=
 to
> setup min_th (target average queue size)
> (max_th and wq (burst in linux RED) are automatically setup)

I currently have no opinion. There are hundreds of papers on red
and red-like algorithms. cc'ing jim for an opinion. Will read paper.

I'd like to find something that dealt with superpackets sanely.

>
> By the way it seems we have a small bug in red_change()
>
> if (skb_queue_empty(&sch->q))
> =A0 =A0 =A0 =A0red_end_of_idle_period(&q->parms);
>
> First, if queue is empty, we should call
> red_start_of_idle_period(&q->parms);
>
> Second, since we dont use anymore sch->q, but q->qdisc, the test is
> meaningless.
>
> Oh well...
>
> [PATCH] sch_red: fix red_change()
>
> Now RED is classful, we must check q->qdisc->q.qlen, and if queue is =
empty,
> we start an idle period, not end it.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
> index 6649463..d617161 100644
> --- a/net/sched/sch_red.c
> +++ b/net/sched/sch_red.c
> @@ -209,8 +209,8 @@ static int red_change(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctl->=
Plog, ctl->Scell_log,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla_d=
ata(tb[TCA_RED_STAB]));
>
> - =A0 =A0 =A0 if (skb_queue_empty(&sch->q))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 red_end_of_idle_period(&q->parms);
> + =A0 =A0 =A0 if (!q->qdisc->q.qlen)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 red_start_of_idle_period(&q->parms);
>
> =A0 =A0 =A0 =A0sch_tree_unlock(sch);
> =A0 =A0 =A0 =A0return 0;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
