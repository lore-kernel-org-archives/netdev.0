From: Avery Pennarun <apenwarr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Mon, 7 Mar 2016 09:05:18 -0500
Message-ID: <CAPp0ZBYP9UzUTtPz=vivUQkE2FiGSsJjDaecQtPuK8y_d3ccqA@mail.gmail.com>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
 <E1abfnE-0000VS-00@www.xplot.org> <CA+BoTQk6J7kgdie9aX24MB+8PxN3oFUh0eVdmVrdyptW5RxQXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Andrew Mcgregor <andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+BoTQk6J7kgdie9aX24MB+8PxN3oFUh0eVdmVrdyptW5RxQXg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 4, 2016 at 1:32 AM, Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org> wrote:
> On 4 March 2016 at 03:48, Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org> wrote:
> [...]
>> (I am interested in knowing what other mac80211 drivers have been
>>  modified to use the mac80211 intermediate software queues.   I know
>>  Michal mentioned he has patches for ath10k that are not yet released,
>>  and I know Felix is finishing up the mt76 driver which uses them.)
>
> Patches for ath10k are under review since quite some time now (but are
> not merged yet). The latest re-spin is:
>
>   http://lists.infradead.org/pipermail/ath10k/2016-March/006923.html

Hi all, on Friday I had a chance to experiment with some of these
patches, specifically Tim's ath9k patch (to use intermediate queues),
plus MIchal's patch to use fq_codel with the intermediate queues.  I
didn't attempt any fine tuning; I just slapped them together to see
what happens.  (I tried applying Michal's ath10k patches too, but got
stuck since they seem to be applied against the upstream v4.4 kernel
and didn't merge cleanly with the latest mac80211 branch.  Maybe I was
doing something wrong.)

Test setup:
   AP (ath9k) -> 2x2 strong signal -> STA1 (mwifiex)
        -> attenuator (-40 dB) -> 1x1 weak signal  -> STA2 (mwifiex)

STA2 generally gets modulation levels around MCS0-2 and STA1 usually
gets something like MCS12-15.

With or without this patch, results with TCP iperf were fishy - I
think packet loss patterns were particularly bad and caused 2-second
TCP retry timeouts occasionally - so I removed TCP from the test and
switched the UDP iperf instead.

I ran isoping (https://gfiber.googlesource.com/vendor/google/platform/+/master/cmds/isoping.c)
from the AP to both stations to measure two-way latency during all
tests.  (I used -r2 for two packets/sec in each direction in order not
to affect the test results too much.)

Overall results:

- Running one iperf at a time, I saw ~45 Mbps to STA1 and ~7 Mbps to STA2.

- Running both iperfs at once, without the patches, latencies got
extremely high (~600ms sometimes) and results were closer to
byte-fairness than airtime-fairness (ie. ~7 Mbps each).

- Running both iperfs at once, with the patches, latencies were still
high (usually high 2-digit, sometimes low 3-digit latencies) but we
got closer to airtime-fairness than byte-fairness (~17 Mbps and ~2
Mbps).

- With only one iperf running, without the patches, latencies were
high to both stations.  With the patches, latency was
mid-double-digits to the non-iperf station (pretty good!) while being
low-mid triple-digits to the busy iperf station.  This suggests that
we are getting per-station queuing (yay!) but does make me question
whether the fq_ in fq_codel was working.

- More generally, the latencies were all still higher than expected.
I didn't investigate why this might be, but the obvious guess (which
Tim has agreed with) is that we need something BQL-like in addition to
the fq_codel layer.  The BQL-like thing is what Emmanuel's earlier
latency patch did with iwlwifi, with apparently good results.  If
someone wants to try making a similar patch for ath9k, I'd be happy to
help test it out.

Although things aren't yet nearly as good as I'd like to see them,
I'll note that Tim's and Michal's patches don't seem to make things
*worse*, at least in my setup, and do improve results in my test.  So
if they pass code review, it may make sense to apply them as one small
step forward to reducing wifi latency under load.

Have fun,

Avery
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
