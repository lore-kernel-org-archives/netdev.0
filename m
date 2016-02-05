From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Fri, 5 Feb 2016 08:47:34 -0800
Message-ID: <CAA93jw7M3j8WYPTGx=V6yQKa_hpcg435GV4O4ZbfxiR8S9VVuQ@mail.gmail.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
	<1454616988-21901-1-git-send-email-emmanuel.grumbach@intel.com>
	<56B3B885.1050409@candelatech.com>
	<0BA3FCBA62E2DC44AF3030971E174FB32EA02656@hasmsx107.ger.corp.intel.com>
	<56B3BF25.8080509@candelatech.com>
	<CA+BoTQm+xTU6o7CMbCHr=bSgp7WE5btE4pMki5XJWiXaOG4SdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQm+xTU6o7CMbCHr=bSgp7WE5btE4pMki5XJWiXaOG4SdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> A bursted txop can be as big as 5-10ms. If you consider you want to
> queue 5-10ms worth of data for *each* station at any given time you
> obviously introduce a lot of lag. If you have 10 stations you might
> end up with service period at 10*10ms =3D 100ms. This gets even worse=
 if
> you consider MU-MIMO because you need to do an expensive sounding
> procedure before transmitting. So while SU aggregation can probably
> still work reasonably well with shorter bursts (1-2ms) MU needs at
> least 3ms to get *any* gain when compared to SU (which obviously mean=
s
> you want more to actually make MU pay off).

I am not sure where you get these numbers. Got a spreadsheet?

Gradually reducing the maximum sized txop as a function of the number
of stations makes sense. If you have 10 stations pending delivery and
reduced the max txop to 1ms, you hurt bandwidth at that instant, but
by offering more service to more stations, in less time, they will
converge on a reasonable share of the bandwidth for each, faster[1].
And I'm sure that the person videoconferencing on a link like that
would appreciate getting some service inside of a 10ms interval,
rather than a 100ms.

yes, there's overhead, and that's not the right number, which would
vary as to g,n,ac and successors.

You will also get more opportunities to use mu-mimo with shorter
bursts extant and more stations being regularly serviced.

[1] https://www.youtube.com/watch?v=3DRb-UnHDw02o at about 13:50

> The rule of thumb is the
> longer you wait the bigger capacity you can get.

This is not strictly true as the "fountain" of packets is regulated by
acks on the other side of the link, and ramp up or down as a function
of service time and loss.

>
> Apparently there's interest in maximizing throughput but it stands in
> direct opposition of keeping the latency down so I've been thinking
> how to satisfy both.
>
> The current approach ath10k is taking (patches in review [1][2]) is t=
o
> use mac80211 software queues for per-station queuing, exposing queue
> state to firmware (it decides where frames should be dequeued from)
> and making it possible to stop/wake per-station tx subqueue with fake
> netdev queues. I'm starting to think this is not the right way though
> because it's inherently hard to control latency and there's a huge
> memory overhead associated with the fake netdev queues.

What is this overhead?

Applying things  like codel tend to dramatically shorten the amount of
skbs extant... modern 802.11ac capable hardware has tons more
memory...

> Also fq_codel
> is a less effective with this kind of setup.

fq_codel's principal problems with working with wifi are long and
documented in the talk above.

> My current thinking is that the entire problem should be solved via
> (per-AC) qdiscs, e.g. fq_codel. I guess one could use
> limit/target/interval/quantum knobs to tune it for higher latency of
> aggregation-oriented Wi-Fi links where long service time (think
> 100-200ms) is acceptable. However fq_codel is oblivious to how Wi-Fi
> works in the first place, i.e. Wi-Fi gets better throughput if you
> deliver bursts of packets destined to the same station. Moreover this
> gets even more complicated with MU-MIMO where you may want to conside=
r
> spatial location (which influences signal quality when grouped) of
> each station when you decide which set of stations you're going to
> aggregate to in parallel. Since drivers have a finite tx ring this it
> is important to deliver bursts that can actually be aggregated
> efficiently. This means driver would need to be able to tell qdisc
> about per-flow conditions to influence the RR scheme in some way
> (assuming a qdiscs even understands flows; do we need a unified way o=
f
> talking about flows between qdiscs and drivers?).

This is a very good summary of the problems in layering fq_codel as it
exists today on top of wifi as it exists today. :/ Our conclusion
several years ago was that as the information needed to do things more
right was in the mac80211 layer that we could not evolve the qdisc
layer to suit, and needed to move the core ideas into the mac80211
layer.

Things have evolved since, but I still think we can't get enough info
up to the qdisc layer (locks and so on) to use it sanely.

>
> [1]: https://www.spinics.net/lists/linux-wireless/msg146187.html
> [2]: https://www.spinics.net/lists/linux-wireless/msg146512.html

I will review!

>
>>>> For reference, ath10k has around 1400 tx descriptors, though
>>>> in practice not all are usable, and in stock firmware, I'm guessin=
g
>>>> the NIC will never be able to actually fill up it's tx descriptors
>>>> and stop traffic.  Instead, it just allows the stack to try to
>>>> TX, then drops the frame...
>>>
>>>
>>> 1400 descriptors, ok... but they are not organised in queues?
>>> (forgive my ignorance of athX drivers)
>>
>>
>> I think all the details are in the firmware, at least for now.
>
> Yeah. Basically ath10k has a flat set of tx descriptors which are
> AC-agnostic. Firmware classifies them internally to per-AC HW queues.
>
>
> Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
