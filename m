From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Tue, 3 Jan 2012 13:07:44 +0100
Message-ID: <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	<21734335.uCtjXOcSpA@alaris>
	<CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	<1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:45261 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752693Ab2ACMHo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 07:07:44 -0500
Received: by obcwo16 with SMTP id wo16so12352138obc.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 04:07:44 -0800 (PST)
In-Reply-To: <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will take me a while to fully comment on this... there are
all sorts of subtlties to deal with (one biggie - ledbat vs multi-queue
behavior)... but I am encouraged by the events of the past
months and my testing today....

On Tue, Jan 3, 2012 at 11:40 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 03 janvier 2012 =E0 10:36 +0100, Dave Taht a =E9crit :
>
>> I note that (as of yesterday) sfq is performing as well as qfq did
>> under most workloads, and is considerably simpler than qfq, but
>> what I have in mind for shaping in a asymmetric scenario
>> *may* involve 'weighting' - rather than strictly prioritizing -
>> small acks... and it may not - I'd like to be able to benchmark

I need to be clear that the above is a subtle problem that I'd
have to talk to in a separate mail - AND both SFQ and QFQ
do such a better job than wshaper did in the first place that
weighting small acks only wins in a limited number of
scenarios.

We have a larger problem in dealing with TSO/GSO
size superpackets that's hard to solve.

I'd prefer to think, design tests, and benchmark, and think again
for a while...

>> the various AQM approaches against a variety of workloads
>> before declaring victory.
>
>
> A QFQ setup with more than 1024 classes/qdisc is way too slow at init
> time, and consume ~384 bytes per class : ~12582912 bytes for 32768
> classes.

QFQ could be improved with some of the same techniques you
describe below.

> We also are limited to 65536 qdisc per device, so QFQ setup using has=
h
> is limited to a 32768 divisor.
>
>
> Now SFQ as implemented in Linux is very limited, with at most 127 flo=
ws
> and limit of 127 packets. [ So if 127 flows are active, we have one
> packet per flow ]

I agree SFQ can be improved upwards in scale, greatly.

My own personal goal is to evolve towards something that
can replace pfifo_fast as the default in linux.

I don't know if that goal is shared by all as yet. :)

> I plan to add to SFQ following features :

=46rom a 'doing science' perspective, I'd like it if it remained possib=
le
to continue using and benchmarking SFQ as it was, and create
this set of ideas as a new qdisc ('efq'?)

As these changes seem to require changes to userspace tc, anyway,
and (selfishly) my patching burden is great enough...

Perhaps some additional benefit could be had by losing
full backward API compatability with sfq, as well?

> - Ability to specify a per flow limit
> =A0 =A0 Its what is called the 'depth',
> =A0 =A0 currently hardcoded to min(127, limit)

Introducing per-flow buffering (as QFQ does) *re-introduces*
the overall AQM problem of managing the size of the
individual flows.

this CDF graph shows how badly wireless is currently behaving
(courtesy Albert Rafetseder of the university of vienna)

http://www.teklibre.com/~d/bloat/qfq_vs_pfifo_fast_wireless_iwl_card_vs=
_cerowrt.pdf

(I have to convince gnuplot to give me these!!)

If I were to add a larger sub-qdisc depth on QFQ than what's in there
(presently 24)
the same graph would also show the median latency increase proportionat=
ely.

The Time in Queue idea for managing that queue depth is quite
strong, there may be others.

(in fact, I'm carrying your preliminary TiQ patch in my
 bql trees, not that I've done anything with it yet)

> - Ability to have up to 65535 flows (instead of 127)
>
> - Ability to have a head drop (to drop old packets from a flow)

The head drop idea is strong, when combined with time in queue.

However: it would be useful to be able to pull forward the next packet
in that sub-queue and deliver it, so as to provide proper signalling
upstream. Packets nowadays arrive in bursts, which means that
once one time stamp has expired, many will. What I just suggested
would (worst case) deliver every other packet in a backlog and
obviously needs refinement.....

>
> example of use : No more than 20 packets per flow, max 8000 flows, ma=
x
> 20000 packets in SFQ qdisc, hash table of 65536 slots.
>
> tc qdisc add ... sfq \
> =A0 =A0 =A0 =A0flows 8000 \
> =A0 =A0 =A0 =A0depth 20 \
> =A0 =A0 =A0 =A0headdrop \
> =A0 =A0 =A0 =A0limit 20000 divisor 65536
>
> Ram usage : 32 bytes per flow, instead of 384 for QFQ, so much better
> cache hit ratio. 2 bytes per hash table slots, instead of 8 for QFQ.

I do like it!

I retain liking for QFQ because other qdiscs (red, for example)
can be attached to it, but having a simple, yet good default with SFQ
scaled up to modern requirements would also be awesome!

> (perturb timer for a huge SFQ setup would be not recommended)

no kidding!

>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
