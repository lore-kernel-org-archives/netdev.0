From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 14:02:53 -0700
Message-ID: <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2011 at 4:27 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> I've just read this thread:
>
> http://marc.info/?t=131277868500001&r=1&w=2
>
> Since its not linux-wireless I'll chime in here. It seems that you are
> trying to write an algorithm that will work for all networking and
> 802.11 devices. For networking is seems tough given driver
> architecture and structure and the hope that all drivers will report
> things in a fairly similar way. For 802.11 it was pointed out how we
> have varying bandwidths and depending on the technology used for
> connection (AP, 802.11s, IBSS) a different number of possible peers
> need to be considered. 802.11 faced similar algorithmic complexities
> with rate control and the way Andrew and Derek resolved this was to
> not assume you could solve this problem and simply test out the water
> by trial and error, that gave birth to the minstrel rate control
> algorithm which Felix later rewrote for mac80211 with 802.11n support
> [1]. Can the BQL algorithm make use of the same trial and error
> mechanism and simply try different values and and use EWMA [2] to pick
> the best size for the queue ?
>
> [1] http://wireless.kernel.org/en/developers/Documentation/mac80211/RateControl/minstrel
> [2] http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average

Let me elaborate on 802.11 and bufferbloat as so far I see only crap
documentation on this and also random crap adhoc patches. Given that I
see effort on netdev to try to help with latency issues its important
for netdev developers to be aware of what issues we do face today and
what stuff is being mucked with.

As far as I see it I break down the issues into two categories:

 * 1. High latencies on ping
 * 2. Constant small drops in throughput

 1. High latencies on ping
===================

It seems the bufferbloat folks are blaming the high latencies on our
obsession on modern hardware to create huge queues and also with
software retries. They assert that reducing the queue length
(ATH_MAX_QDEPTH on ath9k) and software retries (ATH_MAX_SW_RETRIES on
ath9k) helps with latencies. They have at least empirically tested
this with ath9k with
a simple patch:

https://www.bufferbloat.net/attachments/43/580-ath9k_lowlatency.patch

The obvious issue with this approach is it assumes STA mode of
operation, with an AP you do not want to reduce the queue size like
that. In fact because of the dynamic nature of 802.11 and the
different modes of operation it is a hard question to solve on what
queue size you should have. The BQL effort seems to try to unify a
solution but obviously did not consider 802.11's complexities. 802.11
makes this very complicated given the PtP and PtMP support we have and
random number of possible peers.

Then -- we have Aggregation. At least AMPDU Aggregation seems to
empirically deteriorate latency and bufferbloat guys seem to hate it.
Of course their statements are baseless and they are ignoring a lot of
effort that went into this. Their current efforts have been to reduce
segment size of a aggregates and this seems to help but the same
problem looms over this resolution -- the optimal aggregation segment
size should be dynamic and my instincts tell me we likely need to also
rely on a minstrel-like based algorithm for finding the optimal length.

2. Constant small drops in throughput
=============================

How to explain this? I have no clue. Two current theories:

a. Dynamic Power save
b. Offchannel operations on bgscans
c. Bufferbloat: large hw queue size and sw retries

One can rule out (a) and (b) by disabling Dynamic Power Save (iw dev
wlan0 power_save off) and also bg scans. If its (c) then we can work
our way up to proving a solution with the same fixes for the first
latency issue. But there are more subtle issues here. Bufferbloat
folks talk about "ants" and "elephants". They call "Elephants" as
frames that are just data, but "ants" are small frames that build make
the networks work -- so consider 802.11 management frames, and TCP
ACKs, and so forth. They argue we should prioritize these more and
ensure we use whatever techniques we can to ensure we reduce latency
for them. At least on ath9k we only aggregate data frames, but that
doesn't mean we are not aggregating other "ant" frames. We at least
now have in place code to not aggregate Voice Traffic -- that's good
but we can do more. For example we can use AMSDU TX support for small
frame. This means we'd need to prioritize AMSDU TX support, which we
do not have support for in mac80211. I think this will help here, but
consider queue size too -- we can likely get even better results here
by ensuring we reduce latency further for them.

Hope this helps sum up the issue for 802.11 and what we are faced with.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
