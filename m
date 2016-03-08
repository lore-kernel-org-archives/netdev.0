From: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Tue, 8 Mar 2016 08:41:13 +0100
Message-ID: <CA+BoTQnrxk+CVBesrhCQSXtQiXk0LA2sjU6WorD5c18OM=W0OA@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<E1abfnE-0000VS-00@www.xplot.org>
	<CA+BoTQk6J7kgdie9aX24MB+8PxN3oFUh0eVdmVrdyptW5RxQXg@mail.gmail.com>
	<CAPp0ZBYP9UzUTtPz=vivUQkE2FiGSsJjDaecQtPuK8y_d3ccqA@mail.gmail.com>
	<56DD99AA.8050403@openwrt.org>
	<CAHqTa-2-uZ0PUdwp33E588EU2a7T6KnTYs8RWfNDEzgOLseG9g@mail.gmail.com>
	<CAA93jw4JG_uEZaxk1JDKndq9K0+QPwKaAmK6=gZ8e-7qNmc=Cw@mail.gmail.com>
	<CAHqTa-1m3209qqLO19diB5ONd1o3whEnBGJkbPpV1m3UfSGJvA@mail.gmail.com>
	<CAA93jw5fvGQ5L7dQupFX4ymhxquswSit1ZiATKmLp4+O4Mwbrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avery Pennarun <apenwarr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrew Mcgregor <andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke-LJ9M9ZcSy1A@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAA93jw5fvGQ5L7dQupFX4ymhxquswSit1ZiATKmLp4+O4Mwbrw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7 March 2016 at 19:28, Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Mar 7, 2016 at 9:14 AM, Avery Pennarun <apenwarr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> w=
rote:
>> On Mon, Mar 7, 2016 at 11:54 AM, Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
[...]
>>> the underlying code needs to be striving successfully for per-stati=
on
>>> airtime fairness for this to work at all, and the driver/card
>>> interface nearly as tight as BQL is for the fq portion to behave
>>> sanely. I'd configure codel at a higher target and try to observe w=
hat
>>> is going on at the fq level til that got saner.
>>
>> That seems like two good goals.  So Emmanuel's BQL-like thing seems
>> like we'll need it soon.
>>
>> As for per-station airtime fairness, what's a good approximation of
>> that?  Perhaps round-robin between stations, one aggregate per turn,
>> where each aggregate has a maximum allowed latency?
>
> Strict round robin is a start, and simplest, yes. Sure.
>
> "Oldest station queues first" on a round (probably) has higher
> potential for maximizing txops, but requires more overhead. (shortest
> queue first would be bad). There's another algo based on last receive=
d
> packets from a station possibly worth fiddling with in the long run..=
=2E
>
> as "maximum allowed latency" - well, to me that is eventually also a
> variable, based on the number of stations that have to be scheduled o=
n
> that round. Trying to get away from 10 stations eating 5.7ms each +
> return traffic on a round would be nicer. If you want a constant, for
> now, aim for 2048us or 1TU.

The "one aggregate per turn" is a tricky.

I guess you can guarantee this sort of thing on ath9k/mt76.

This isn't the case for other drivers, e.g. ath10k has a flat tx
queue. You don't really know if the 40 frames you submitted will be
sent with 1, 2 or 3 aggregates. They might not be aggregated at all.

Best thing you can do is to estimate how much bytes can you fit into a
txop on target sta-tid/ac assuming you can get last/avg tx rate to
given station (should be doable on ath10k at least).

Moreover, for MU-MIMO you typically want to burst a few aggregates in
txop to make the sounding to pay off. And this is again tricky on flat
tx queue where you don't really know if target stations can do an
efficient MU transmission and worst case you'll end up with stacking
up 3 txops worth of data in queues.


Oh, and the unfortunate thing is ath10k does offloaded powersaving
which means some frames can clog up tx queues unnecessarily until next
TBTT. This is something that will need to be addressed as well in tx
scheduling. Not sure how yet.

A quick idea - perhaps we could unify ps_tx_buf with txqs and make use
of txqs internally regardless of wake_tx_queue implementation?


[...]
> [1] I've published a lot of stuff showing how damaging 802.11e's edca
> scheduling can be - I lean towards, at most, 2-3 aggregates being in
> the hardware, essentially disabling the VO queue on 802.11n (not sure
> on ac), in favor of VI, promoting or demoting an assembled aggregate
> from BE to BK or VI as needed at the last second before submitting it
> to the hardware, trying harder to only have one aggregate outstanding
> to one station at a time, etc.

Makes sense, but (again) tricky for drivers such as ath10k which have
a flat tx queue. Perhaps I could maintain a simulation of aggregates
or some sort of barriers and hope it's "good enough".


Micha=C5=82
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
