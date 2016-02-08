From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Mon, 8 Feb 2016 11:00:18 +0100
Message-ID: <CA+BoTQ=BMsXHEcg0LTEcsVLVUBYLmQ2F_oRghFPLty1XD-L9wQ@mail.gmail.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
	<1454616988-21901-1-git-send-email-emmanuel.grumbach@intel.com>
	<56B3B885.1050409@candelatech.com>
	<0BA3FCBA62E2DC44AF3030971E174FB32EA02656@hasmsx107.ger.corp.intel.com>
	<56B3BF25.8080509@candelatech.com>
	<CA+BoTQm+xTU6o7CMbCHr=bSgp7WE5btE4pMki5XJWiXaOG4SdA@mail.gmail.com>
	<CAA93jw7M3j8WYPTGx=V6yQKa_hpcg435GV4O4ZbfxiR8S9VVuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jonathan Corbet <corbet@lwn.net>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37106 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbcBHKAU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 05:00:20 -0500
Received: by mail-wm0-f52.google.com with SMTP id g62so108392336wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 02:00:19 -0800 (PST)
In-Reply-To: <CAA93jw7M3j8WYPTGx=V6yQKa_hpcg435GV4O4ZbfxiR8S9VVuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2016 at 17:47, Dave Taht <dave.taht@gmail.com> wrote:
>> A bursted txop can be as big as 5-10ms. If you consider you want to
>> queue 5-10ms worth of data for *each* station at any given time you
>> obviously introduce a lot of lag. If you have 10 stations you might
>> end up with service period at 10*10ms =3D 100ms. This gets even wors=
e if
>> you consider MU-MIMO because you need to do an expensive sounding
>> procedure before transmitting. So while SU aggregation can probably
>> still work reasonably well with shorter bursts (1-2ms) MU needs at
>> least 3ms to get *any* gain when compared to SU (which obviously mea=
ns
>> you want more to actually make MU pay off).
>
> I am not sure where you get these numbers. Got a spreadsheet?

Here's a nice summary on some of it:

  http://chimera.labs.oreilly.com/books/1234000001739/ch03.html#figure-=
mac-ampdu

Even if your single A-MPDU can be shorter than a txop you can burst a
few of them if my understanding is correct.

The overhead associated with MU sounding is something I've been told
only. Apparently for MU to pay off you need fairly big bursts. This
implies that the more stations you have to service the less it makes
sense to attempt MU if you consider latency.


> Gradually reducing the maximum sized txop as a function of the number
> of stations makes sense. If you have 10 stations pending delivery and
> reduced the max txop to 1ms, you hurt bandwidth at that instant, but
> by offering more service to more stations, in less time, they will
> converge on a reasonable share of the bandwidth for each, faster[1].
> And I'm sure that the person videoconferencing on a link like that
> would appreciate getting some service inside of a 10ms interval,
> rather than a 100ms.
>
> yes, there's overhead, and that's not the right number, which would
> vary as to g,n,ac and successors.
>
> You will also get more opportunities to use mu-mimo with shorter
> bursts extant and more stations being regularly serviced.
>
> [1] https://www.youtube.com/watch?v=3DRb-UnHDw02o at about 13:50

This is my thinking as well, at least for most common use cases.

If you try to optimize for throughput by introducing extra induced
latency you might end up not being able to use aggregation in practice
anyway because you won't be able to start up connections and ask for
enough data - or at least that's what my intuition tells me.

But, like I've mentioned, there's interest in making it possible to
maximize for throughput (regardless of latency). This surely makes
sense for synthetic UDP benchmarks. But does it make sense for any
real-world application? No idea.


>> The rule of thumb is the
>> longer you wait the bigger capacity you can get.
>
> This is not strictly true as the "fountain" of packets is regulated b=
y
> acks on the other side of the link, and ramp up or down as a function
> of service time and loss.

Yes, if you consider real world cases, i.e. TCP, web traffic, etc.
then you're correct.


>> Apparently there's interest in maximizing throughput but it stands i=
n
>> direct opposition of keeping the latency down so I've been thinking
>> how to satisfy both.
>>
>> The current approach ath10k is taking (patches in review [1][2]) is =
to
>> use mac80211 software queues for per-station queuing, exposing queue
>> state to firmware (it decides where frames should be dequeued from)
>> and making it possible to stop/wake per-station tx subqueue with fak=
e
>> netdev queues. I'm starting to think this is not the right way thoug=
h
>> because it's inherently hard to control latency and there's a huge
>> memory overhead associated with the fake netdev queues.
>
> What is this overhead?

E.g. if you want to be able to maximize throughput for 50 MU clients
you need to be able to queue, in theory, 50*200 (roughly) frames. This
translates to both huge memory usage and latency *and* renders
(fq_)codel qdisc rather.. moot.


> Applying things  like codel tend to dramatically shorten the amount o=
f
> skbs extant...

> modern 802.11ac capable hardware has tons more
> memory...

I don't think it does. QCA988x is able to handle "only" 1424 tx
descriptors (IOW 1500-byte long MSDUs) in the driver-to-firmware tx
queue (it's a flat queue). QCA99x0 is able to handle 2500 if asked
politely.

This is still not enough to satisfy the insane "maximize the
capacity/throughput" expectations though.

You could actually argue it's too much from the bufferbloat problem
point of view anyway and Emmanuel's patch proves it is beneficial to
buffer less in driver depending on the sojourn packet time.


>> Also fq_codel
>> is a less effective with this kind of setup.
>
> fq_codel's principal problems with working with wifi are long and
> documented in the talk above.
>
>> My current thinking is that the entire problem should be solved via
>> (per-AC) qdiscs, e.g. fq_codel. I guess one could use
>> limit/target/interval/quantum knobs to tune it for higher latency of
>> aggregation-oriented Wi-Fi links where long service time (think
>> 100-200ms) is acceptable. However fq_codel is oblivious to how Wi-Fi
>> works in the first place, i.e. Wi-Fi gets better throughput if you
>> deliver bursts of packets destined to the same station. Moreover thi=
s
>> gets even more complicated with MU-MIMO where you may want to consid=
er
>> spatial location (which influences signal quality when grouped) of
>> each station when you decide which set of stations you're going to
>> aggregate to in parallel. Since drivers have a finite tx ring this i=
t
>> is important to deliver bursts that can actually be aggregated
>> efficiently. This means driver would need to be able to tell qdisc
>> about per-flow conditions to influence the RR scheme in some way
>> (assuming a qdiscs even understands flows; do we need a unified way =
of
>> talking about flows between qdiscs and drivers?).
>
> This is a very good summary of the problems in layering fq_codel as i=
t
> exists today on top of wifi as it exists today. :/ Our conclusion
> several years ago was that as the information needed to do things mor=
e
> right was in the mac80211 layer that we could not evolve the qdisc
> layer to suit, and needed to move the core ideas into the mac80211
> layer.
>
> Things have evolved since, but I still think we can't get enough info
> up to the qdisc layer (locks and so on) to use it sanely.

The current per-station queue implementation in mac80211 doesn't seem
sufficient. Each of these queues use a simple flat fifo queue
(sk_buff_head) limited by packet count only with somewhat broken
behavior when packet limit is reached as you end up with unfairly
populated queues a lot. They need to have codel applied on them
somehow. You'll eventually end up re-inventing fq_codel in mac80211
making the qdisc redundant.

Moreover these queues aren't per-station only. They are
per-station-per-tid giving 16 queues per station. This is important
because you can't aggregate traffic going out on different tids.

Even without explicit air conditions feedback from mac80211 to
fq_codel I suspect it'd be still beneficial if fq_codel was able to
group (sub-)flows into per-station-tid and burst them out them in
subsequent dequeue() calls so the chance they get aggregated is
higher.


Micha=C5=82
