From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFCv2 0/3] mac80211: implement fq codel
Date: Thu, 17 Mar 2016 10:00:06 -0700
Message-ID: <CAA93jw7TuBLVi9k-+2=J27j-Qs+sS3UNaQNTMF9D2MQ13fQY9A@mail.gmail.com>
References: <1458123478-1795-1-git-send-email-michal.kazior@tieto.com>
	<CA+BoTQ=65mHN5iLnZjTE+tyEG7nfmCx4NZNbGRF6+VpRaNmOYw@mail.gmail.com>
	<CAA93jw5cUaj_qM+CYHHoRaghLDLC+BUgF4AjT=Oec+SB-zb74g@mail.gmail.com>
	<CAA93jw6tDdiYuginPbUY1DFJLiDxofHMFN6j2BvQPabPmBtuRw@mail.gmail.com>
	<20160316185531.GA1771@localhost>
	<CAGyitvMDEUiNx7HD=XKjXNHnFvZ_gxD_BbQx3AP-57_+dBeD4A@mail.gmail.com>
	<CA+BoTQnFN6VANn=5EUvHc0Dbfh4Zv0HraOto2ySN3_HdOpD7Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jasmine Strong <jas-K/XR6QsbQD0@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org" <codel-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org>,
	make-wifi-fast-JXvr2/1DY2fm6VMwtOF2vx4hnT+Y9+D1@public.gmane.org
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQnFN6VANn=5EUvHc0Dbfh4Zv0HraOto2ySN3_HdOpD7Sg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 17, 2016 at 1:55 AM, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org=
> wrote:

> I suspect the BK/BE latency difference has to do with the fact that
> there's bulk traffic going on BE queues (this isn't reflected
> explicitly in the plots). The `bursts` flent test includes short
> bursts of traffic on tid0 (BE) which is shared with ICMP and BE UDP_R=
R
> (seen as green and blue lines on the plot). Due to (intended) limited
> outflow (6mbps) BE queues build up and don't drain for the duration o=
f
> the entire test creating more opportunities for aggregating BE traffi=
c
> while other queues are near-empty and very short (time wise as well).

I agree with your explanation. Access to the media and queue length
are the two variables at play here.

I just committed a new flent test that should exercise the vo,vi,be,
and bk queues, "bursts_11e". I dropped the conventional ping from it
and just rely on netperf's udp_rr for each queue. It seems to "do the
right thing" on the ath9k....

And while I'm all in favor of getting 802.11e's behaviors more right,
and this seems like a good way to get there...

netperf's udp_rr is not how much traffic conventionally behaves. It
doesn't do tcp slow start or congestion control in particular...

In the case of the VO queue, for example, the (2004) intended behavior
was 1 isochronous packet per 10ms per voice sending station and one
from the ap, not a "ping". And at the time, VI was intended to be
unicast video. TCP was an afterthought. (wifi's original (1993) mac
was actually designed for ipx/spx!)

I long for regular "rrul" and "rrul_be" tests against the new stuff to
blow it up thoroughly as references along the way.
(tcp_upload, tcp_download, (and several of the rtt_fair tests also
between stations)). Will get formal about it here as soon as we end up
on the same kernel trees....

=46urthermore 802.11e is not widely used - in particular, not much
internet bound/sourced traffic falls into more than BE and BK,
presently. and in some cases weirder - comcast remarks a very large
percentage of to the home inbound traffic as CS1 (BK), btw, and
stations tend to use CS0. Data comes in on BK, acks go out on BE.

I/we will try to come up with intermediate tests between the burst
tests and the rrul tests as we go along the way.

> If you consider Wi-Fi is half-duplex and latency in the entire stack

In the context of this test regime...

<pedantry>
Saying wifi is "half"-duplex is a misleading way to think about it in
many respects. it is a shared medium more like early, non-switched
ethernet, with a weird mac that governs what sort of packets get
access to (a txop) the medium first, across all stations co-operating
within EDCA.

Half or full duplex is something that mostly applied to p2p serial
connections (or p2p wifi), not P2MP. Additionally characteristics like
exponential backoff make no sense were wifi any form of duplex, full
or half.

Certainly much stuff within a txop (block acks for example) can be
considered half duplex in a microcosmic context.

I wish we actually had words that accurately described wifi's actual be=
havior.
</pedantry>

> (for processing ICMP and UDP_RR) is greater than 11e contention windo=
w
> timings you can get your BE flow responses with extra delay (since
> other queues might have responses ready quicker).

yes. always having a request pending for each of the 802.11e queues is
actually not the best idea, it is better to take advantage of better
aggregation afforded by 802.11n/ac, to only have one or two of the
queues in use against any given station and promote or demote traffic
into a more-right queue.

simple example of the damage having all 4 queues always contending is
exemplified by running the rrul and rrul_be tests against nearly any
given AP.

>
> I've modified traffic-gen and re-run tests with bursts on all tested
> tids/ACs (tid0, tid1, tid5). I'm attaching the results.
>
> With bursts on all tids you can clearly see BK has much higher latenc=
y than BE.

The long term goal here, of course, is for BK (or the other queues) to
not have seconds of queuing latency but something more bounded to 2x
media access time...

> (Note, I've changed my AP to QCA988X with oldie firmware 10.1.467 for
> this test; it doesn't have the weird hiccups I was seeing on QCA99X0
> and newer QCA988X firmware reports bogus expected throughput which is
> most likely a result of my sloppy proof-of-concept change in ath10k).

So I should avoid ben greer's firmware for now?

>
>
> Micha=C5=82
>
> On 16 March 2016 at 20:48, Jasmine Strong <jas-K/XR6QsbQD0@public.gmane.org> wrote:
>> BK usually has 0 txop, so it doesn't do aggregation.
>>
>> On Wed, Mar 16, 2016 at 11:55 AM, Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org> =
wrote:
>>>
>>> On Wed, Mar 16, 2016 at 11:36:31AM -0700, Dave Taht wrote:
>>> > That is the sanest 802.11e queue behavior I have ever seen!  (at =
both
>>> > 6 and 300mbit! in the ath10k patched mac test)
>>>
>>> Out of curiosity, why does BE have larger latency than BK in that c=
hart?
>>> I'd have expected the opposite.
>>>
>>> --
>>> Bob Copeland %% http://bobcopeland.com/
>>>
>>> _______________________________________________
>>> ath10k mailing list
>>> ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>>> http://lists.infradead.org/mailman/listinfo/ath10k
>>
>>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
