From: Jim Gettys <jg@freedesktop.org>
Subject: Re: [PATCH] sch_red: fix red_change
Date: Thu, 01 Dec 2011 16:48:11 -0500
Message-ID: <4ED7F61B.2020907@freedesktop.org>
References: <1322684749.2602.3.camel@edumazet-laptop> <20111130143642.7130aa2b@nehalam.linuxnetplumber.net> <1322773594.2750.28.camel@edumazet-laptop> <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Thomas Graf <tgraf@infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46479 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754406Ab1LAVsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:48:15 -0500
Received: by vcbfk14 with SMTP id fk14so1881602vcb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 13:48:14 -0800 (PST)
In-Reply-To: <CAA93jw7wAL75pVrB-q+xGAcpQtiZz4iVW0Z2W9E8VGSyUFOo-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2011 04:35 PM, Dave Taht wrote:
> On Thu, Dec 1, 2011 at 10:06 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le mercredi 30 novembre 2011 =E0 14:36 -0800, Stephen Hemminger a =E9=
crit :
>>
>>> (Almost) nobody uses RED because they can't figure it out.
>>> According to Wikipedia, VJ says that:
>>>  "there are not one, but two bugs in classic RED."
> Heh. "There were not two, but four bugs in Linux red".
>
> Now reduced to 2. :)

That's good.  There may be enough use to be worth fixing...  RED itself
is buggy in a couple ways, including it's fundamental idea of keying of=
f
the queue length.

>
>> RED is useful for high throughput routers, I doubt many linux machin=
es
>> act as such devices.
> "High throughput" at the time red was designed was not much faster
> than a T1 line.
>
> RED appears to be used by default in both gargoyle's and openwrt's Qo=
S systems,
> underneath unholy combinations of HTB, HSFC, and SFQ
> so it's more widely used than you might think. Not that works well.
>
> RED doesn't work worth beans on variable bandwidth links (cable
> modems/wireless).
>
> Once you are simulating a fixed rate link (e.g with HTB), then it sor=
t of
> kinda maybe can apply.
>
> RED was also designed at a time when long distance traffic was fixed =
rate
> and bidirectional, so the 'average packet' parameter made sense.
> Modern day traffic is far more asymmetric.

Not to mention is that RED is fundamentally flawed: there is almost no
information in the instantaneous length of the queue.   You can see how
variable bandwidth screws this idea to the wall, can't you?

So the closer to the edge you get (where BDP variation in flows will
dominate), the worse classic RED can possibly work.  In the home, you
are at the extreme, along with variable bandwidth now with Powerboost
and wireless.


>
> RED might still be fairly effective on a modern day fixed rate line,
> such as DSL,
> and on DSLAMS and the like.

Might is the operative word; the resurrection of using N TCP connection=
s
in the web, and the ICW change to 10 makes me highly skeptical.

>
> Linux's red has an additional problem in that it seems byte oriented
> rather than packet
> oriented, and most folk even trying to do simulations with red seem t=
o be
> choosing packet oriented - which ties into the asymmetric problem not=
ed above
> mildly better.
>
> All that said, it's time came, and is rapidly ending.
>
> I do look forward to a replacement for the algorithm one day soon.

Kathie and Van have been simulating their new algorithm;  hopeful
results, but still too soon to tell as not enough situations have been
simulated.  And they need to talk to Eben Moglen yet about ensuring
proper publication so that no one can patent it out from under them.=20
They want no barriers to widespread adoption in free software (and
anywhere else).

I get the sense that maybe there might be something to try in a couple
months; probably first best to do it on ethernet rather than wireless.
                        - Jim


>
>> I was considering adding Adaptative RED (Sally Floyd, Ramakrishna
>> Gummadi, Scott Shender), August 2001
>>
>> In this version, maxp is dynamic (from 1% to 50%), and user only hav=
e to
>> setup min_th (target average queue size)
>> (max_th and wq (burst in linux RED) are automatically setup)
> I currently have no opinion. There are hundreds of papers on red
> and red-like algorithms. cc'ing jim for an opinion. Will read paper.
>
> I'd like to find something that dealt with superpackets sanely.
>
>> By the way it seems we have a small bug in red_change()
>>
>> if (skb_queue_empty(&sch->q))
>>        red_end_of_idle_period(&q->parms);
>>
>> First, if queue is empty, we should call
>> red_start_of_idle_period(&q->parms);
>>
>> Second, since we dont use anymore sch->q, but q->qdisc, the test is
>> meaningless.
>>
>> Oh well...
>>
>> [PATCH] sch_red: fix red_change()
>>
>> Now RED is classful, we must check q->qdisc->q.qlen, and if queue is=
 empty,
>> we start an idle period, not end it.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>> diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
>> index 6649463..d617161 100644
>> --- a/net/sched/sch_red.c
>> +++ b/net/sched/sch_red.c
>> @@ -209,8 +209,8 @@ static int red_change(struct Qdisc *sch, struct =
nlattr *opt)
>>                                 ctl->Plog, ctl->Scell_log,
>>                                 nla_data(tb[TCA_RED_STAB]));
>>
>> -       if (skb_queue_empty(&sch->q))
>> -               red_end_of_idle_period(&q->parms);
>> +       if (!q->qdisc->q.qlen)
>> +               red_start_of_idle_period(&q->parms);
>>
>>        sch_tree_unlock(sch);
>>        return 0;
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
