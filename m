From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Mon, 8 Feb 2016 12:04:40 +0200
Message-ID: <CANUX_P2qi6JANV4f47uzW9v=bQkbp6UZMuczBM5e2=cQ_8N6ZA@mail.gmail.com>
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
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQm+xTU6o7CMbCHr=bSgp7WE5btE4pMki5XJWiXaOG4SdA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 5, 2016 at 10:44 AM, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org=
> wrote:
> On 4 February 2016 at 22:14, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org> wro=
te:
>> On 02/04/2016 12:56 PM, Grumbach, Emmanuel wrote:
>>> On 02/04/2016 10:46 PM, Ben Greear wrote:
>>>> On 02/04/2016 12:16 PM, Emmanuel Grumbach wrote:
>>>>>
>>>>> As many (all?) WiFi devices, Intel WiFi devices have
>>>>> transmit queues which have 256 transmit descriptors
>>>>> each and each descriptor corresponds to an MPDU.
>>>>> This means that when it is full, the queue contains
>>>>> 256 * ~1500 bytes to be transmitted (if we don't have
>>>>> A-MSDUs). The purpose of those queues is to have enough
>>>>> packets to be ready for transmission so that when the device
>>>>> gets an opportunity to transmit (TxOP), it can take as many
>>>>> packets as the spec allows and aggregate them into one
>>>>> A-MPDU or even several A-MPDUs if we are using bursts.
>>>>
>>>> I guess this is only really usable if you have exactly one
>>>> peer connected (ie, in station mode)?
>>>>
>>>> Otherwise, you could have one slow peer and one fast one,
>>>> and then I suspect this would not work so well?
>>>
>>>
>>> Yes. I guess this one (big) limitation. I guess that what would hap=
pen
>>> in this case is that the the latency would constantly jitter. But I=
 also
>
> Hmm.. You'd probably need to track per-station packet sojourn time as
> well and make it possible to stop/wake queues per station.

Clearly here comes the difference between the devices you work on, and
the devices I work on. Intel devices are more client oriented. Our AP
mode doesn't handle many clients etc..

>
>
>>> noticed that I could reduce the transmit queue to 130 descriptors
>>> (instead of 256) and still reach maximal throughput because we can
>>> refill the queues quickly enough.
>>> In iwlwifi, we have plans to have one queue for each peer.
>>> This is under development. Not sure when it'll be ready. It also re=
quires
>>> firmware change obviously.
>>
>> Per-peer queues will probably be nice, especially if we can keep the
>> buffer bloat manageable.
>
> Per-station queues sound tricky if you consider bufferbloat.

iwlwifi's A-MPDU model is different from athXk's I guess. In iwlwifi
(the Intel devices really since it is mostly firmware) the firmware
will try to use a TxOP whenever there is data in the queue. Then, once
we have a chance to transmit, we will look at what we have in the
queue and send the biggest aggregates we can (and bursts if allowed).
But we will not defer packets' transmission to get bigger aggregates.
Testing shows that under ideal conditions, we can have enough packets
in the queue to build big aggregates without creating artificial
latency.

>
> To maximize use of airtime (i.e. txop) you need to send big
> aggregates. Since aggregates are per station-tid to maximize
> multi-station performance (in AP mode) you'll need to queue a lot of
> frames, per each station, depending on the chosen tx rate.

Sure.

>
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
> you want more to actually make MU pay off). The rule of thumb is the
> longer you wait the bigger capacity you can get.

I am not an expert about MU-MIMO, but I'll believe you :)
We can chat about this in a few days :)

Queueing frames under good conditions is fine in a way that it is a
"Good queue" (hey Stephen), you need those queues to maximize the
throughput because of the bursty nature of WiFi and the queue "moves"
quickly since you have high throughput so that the sojourn time in
your queue is relatively small, but when the link conditions gets less
good you need to reduce the queue length because it doesn't really
help you anyway.  This is what my patch aims at fixing.
All this is true when you have a small number of stations...
I understand from your comment that even in ideal conditions you still
need to create a lot of latency to gain TPT. Then there isn't much we
can do without impacting either TPT or latency. Then, there is a real
tradeoff.
I guess that again you are facing a classic AP problem that a station
or an AP with a small number of concurrent associated clients will
likely not have.

All this encourages me in my belief that I should do something in
iwlwifi for iwlwifi and at mac80211's level since there seem to be
very different problems / use cases. But this code can still suit
those use cases can all fit and we'd just (...) have to give different
parameters to the "algorithm"?

>
> Apparently there's interest in maximizing throughput but it stands in
> direct opposition of keeping the latency down so I've been thinking
> how to satisfy both.

In your case, then yes. I guess I should limit my patch for queues
that serve vif of type BSS for now. It'll still help us for 99% of
iwlwifi's usages.

>
> The current approach ath10k is taking (patches in review [1][2]) is t=
o
> use mac80211 software queues for per-station queuing, exposing queue
> state to firmware (it decides where frames should be dequeued from)
> and making it possible to stop/wake per-station tx subqueue with fake
> netdev queues. I'm starting to think this is not the right way though
> because it's inherently hard to control latency and there's a huge
> memory overhead associated with the fake netdev queues. Also fq_codel
> is a less effective with this kind of setup.

I'd love to hear more the reasons of fq_codel efficiency's problem
here (just for education).
I saw these patches. This makes the firmware much more actively
involved in the scheduling. As I said, in iwlwifi we plan to have one
hardware queue per-sta-per-tid so that the firmware would be able to
choose what station it wants to send frames to. The main purpose is to
improve uAPSD response time as an AP, but it will also make it easier
to choose the right frames to add to a MU-MIMO transmission.

>
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

Interesting. Not sure that 100-200ms is acceptable for all the use
cases though. Bursts can be achieved by TSO maybe? I did that to get
A-MSDU. But... that won't help for bridged traffic which is your
primary use case.

>
>
> [1]: https://www.spinics.net/lists/linux-wireless/msg146187.html
> [2]: https://www.spinics.net/lists/linux-wireless/msg146512.html
>
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
