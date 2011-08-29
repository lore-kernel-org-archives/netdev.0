From: Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Tue, 30 Aug 2011 11:18:08 +1200
Message-ID: <D14BF0EF-D8AE-49AA-91A2-3BEDFD757759@gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 30/08/2011, at 9:02 AM, Luis R. Rodriguez wrote:

> On Fri, Aug 26, 2011 at 4:27 PM, Luis R. Rodriguez <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> I've just read this thread:
>> 
>> http://marc.info/?t=131277868500001&r=1&w=2
>> 
>> Since its not linux-wireless I'll chime in here. It seems that you are
>> trying to write an algorithm that will work for all networking and
>> 802.11 devices. For networking is seems tough given driver
>> architecture and structure and the hope that all drivers will report
>> things in a fairly similar way. For 802.11 it was pointed out how we
>> have varying bandwidths and depending on the technology used for
>> connection (AP, 802.11s, IBSS) a different number of possible peers
>> need to be considered. 802.11 faced similar algorithmic complexities
>> with rate control and the way Andrew and Derek resolved this was to
>> not assume you could solve this problem and simply test out the water
>> by trial and error, that gave birth to the minstrel rate control
>> algorithm which Felix later rewrote for mac80211 with 802.11n support
>> [1]. Can the BQL algorithm make use of the same trial and error
>> mechanism and simply try different values and and use EWMA [2] to pick
>> the best size for the queue ?
>> 
>> [1] http://wireless.kernel.org/en/developers/Documentation/mac80211/RateControl/minstrel
>> [2] http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average
> 
> Let me elaborate on 802.11 and bufferbloat as so far I see only crap
> documentation on this and also random crap adhoc patches. Given that I
> see effort on netdev to try to help with latency issues its important
> for netdev developers to be aware of what issues we do face today and
> what stuff is being mucked with.
> 
> As far as I see it I break down the issues into two categories:
> 
> * 1. High latencies on ping
> * 2. Constant small drops in throughput
> 
> 1. High latencies on ping
> ===================
> 
> It seems the bufferbloat folks are blaming the high latencies on our
> obsession on modern hardware to create huge queues and also with
> software retries. They assert that reducing the queue length
> (ATH_MAX_QDEPTH on ath9k) and software retries (ATH_MAX_SW_RETRIES on
> ath9k) helps with latencies. They have at least empirically tested
> this with ath9k with
> a simple patch:
> 
> https://www.bufferbloat.net/attachments/43/580-ath9k_lowlatency.patch
> 
> The obvious issue with this approach is it assumes STA mode of
> operation, with an AP you do not want to reduce the queue size like
> that. In fact because of the dynamic nature of 802.11 and the
> different modes of operation it is a hard question to solve on what
> queue size you should have. The BQL effort seems to try to unify a
> solution but obviously did not consider 802.11's complexities. 802.11
> makes this very complicated given the PtP and PtMP support we have and
> random number of possible peers.
> 
> Then -- we have Aggregation. At least AMPDU Aggregation seems to
> empirically deteriorate latency and bufferbloat guys seem to hate it.
> Of course their statements are baseless and they are ignoring a lot of
> effort that went into this. Their current efforts have been to reduce
> segment size of a aggregates and this seems to help but the same
> problem looms over this resolution -- the optimal aggregation segment
> size should be dynamic and my instincts tell me we likely need to also
> rely on a minstrel-like based algorithm for finding the optimal length.

Luis, as the author of that patch... I agree entirely that we want something dynamic.  I was actually writing that assuming AP operation... and it works pretty well, but I wouldn't expect it to be anything like optimal in all situations.

It looks like the time limits (called segment_size in the code) in Minstrel-HT were just copied from Minstrel-classic, which was tuned for 11g timings.  The patch reduces the time limits and retry counts (the SW retry limit number goes up because of another patch that changes the accounting for SW retries from passes through the queue to transmitter shots, but 50 shots is way less than 20 passes through the queue).  Now, this is just a matter of having sensible defaults that are not crazily trying to use hundreds of transmit opportunities on one packet.

That patch also reduces the aggregation opportunities a bit; the driver has something approximating a target queue depth, ATH_MAX_QDEPTH, that by default was 123 packets, and I reduced it to 34.  Now, why 34?  Because at any smaller number, it's going to impact aggregation and therefore performance really badly, while at a much larger number it's going to affect latency.  I do understand why aggregation is important; the MAC has a lot of dead air in it, the scarce resource is transmit opportunities rather than bandwidth per se, and we need to get as much as reasonably possible done with each transmit opportunity.

What this patch does assume is that most of the clients have fairly decent coverage; it's going to be really unfair to .11b clients and those right out on the fringes of the APs coverage.  But, with a fairly busy AP and decent coverage, it does actually work well in practice on the AP (I run it at home, and there's a fair bit of stuff on my network...).  The demonstration is, I can have a few TCP streams running flat out from my laptop to something on the wired LAN, and still make a voip call from any device on the wireless... including the laptop (which runs OS X Lion and has a Broadcom radio, by the way, so Linux is not the only stack that does pretty well for latency).  The TCP throughput is barely affected by that patch, but the latency is dramatically improved; what was over 100 ms an
 d wildly varying (under load from TCP traffic) is now very stable and a little under 20 ms on the wireless hop.

So, yes, I do think some kind of dynamic queue sizing is called for.  Also, I think we need a queue bundle per active peer (just to cover all the operation modes... that would be just the AP in STA mode), that is dynamically sized per traffic class per peer.  Also, a decent qdisc that will do a reasonable job of getting latency-sensitive stuff into queues that are trying for latency rather than throughput.

And to the buffer bloat guys: yes, I do see how many buffers I'm proposing using here... it might be a couple or four thousand on a really busy AP.  But the point is not to eliminate buffering, it is to use it sensibly to help performance rather than hurt as it so often does at present.  The number of buffers in total doesn't matter, it's the depth of the queues seen by any particular packet passing through the network that is really critical... and too few is just as bad as too many, especially when it leads to wasting a scarce link resource, as too few buffers will do on an 802.11n AP.

> 
> 2. Constant small drops in throughput
> =============================
> 
> How to explain this? I have no clue. Two current theories:
> 
> a. Dynamic Power save
> b. Offchannel operations on bgscans
> c. Bufferbloat: large hw queue size and sw retries

d. Someone has a broken rate control algorithm, and that is causing slowdowns and packet loss.

The study that Dave was referring to earlier was done on Windows XP clients, using APs running who knows what (we know the best of them was ath9k and Minstrel-classic, because it was running code based on OpenWRT 8.something, but the others I have no idea).  There's all kinds of variables there, and I wouldn't rule out any kind of weirdness.

I think Linux in general is in pretty good shape with respect to most of these issues, what with your work on power save and scanning, and with minstrel for rate control.  Part of the bufferbloat effort is to get the awareness of queue size issues... and what we're doing here is, basically, documenting the tradeoffs and considerations in 802.11 land.

I think a distilled version of these conversations needs to be written up as an informational RFC so the IETC has something to refer to.

> 
> One can rule out (a) and (b) by disabling Dynamic Power Save (iw dev
> wlan0 power_save off) and also bg scans. If its (c) then we can work
> our way up to proving a solution with the same fixes for the first
> latency issue. But there are more subtle issues here. Bufferbloat
> folks talk about "ants" and "elephants". They call "Elephants" as
> frames that are just data, but "ants" are small frames that build make
> the networks work -- so consider 802.11 management frames, and TCP
> ACKs, and so forth. They argue we should prioritize these more and
> ensure we use whatever techniques we can to ensure we reduce latency
> for them. At least on ath9k we only aggregate data frames, but that
> doesn't mean we are not aggregating other "ant" frames. We at least
> now have in place code to not aggregate Voice Traffic -- that's good
> but we can do more. For example we can use AMSDU TX support for small
> frame. This means we'd need to prioritize AMSDU TX support, which we
> do not have support for in mac80211. I think this will help here, but
> consider queue size too -- we can likely get even better results here
> by ensuring we reduce latency further for them.
> 
> Hope this helps sum up the issue for 802.11 and what we are faced with.
> 
>  Luis

It sure does help, thanks Luis.

Andrew--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
