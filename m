From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [RFC v2] iwlwifi: pcie: transmit queue auto-sizing
Date: Fri, 5 Feb 2016 08:48:32 -0800
Message-ID: <56B4D260.2000501@candelatech.com>
References: <1454616764-19841-1-git-send-email-emmanuel.grumbach@intel.com>
 <1454616988-21901-1-git-send-email-emmanuel.grumbach@intel.com>
 <56B3B885.1050409@candelatech.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32EA02656@hasmsx107.ger.corp.intel.com>
 <56B3BF25.8080509@candelatech.com>
 <CA+BoTQm+xTU6o7CMbCHr=bSgp7WE5btE4pMki5XJWiXaOG4SdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
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

On 02/05/2016 12:44 AM, Michal Kazior wrote:

> Per-station queues sound tricky if you consider bufferbloat.
>
> To maximize use of airtime (i.e. txop) you need to send big
> aggregates. Since aggregates are per station-tid to maximize
> multi-station performance (in AP mode) you'll need to queue a lot of
> frames, per each station, depending on the chosen tx rate.
>
> A bursted txop can be as big as 5-10ms. If you consider you want to
> queue 5-10ms worth of data for *each* station at any given time you
> obviously introduce a lot of lag. If you have 10 stations you might
> end up with service period at 10*10ms = 100ms. This gets even worse if
> you consider MU-MIMO because you need to do an expensive sounding
> procedure before transmitting. So while SU aggregation can probably
> still work reasonably well with shorter bursts (1-2ms) MU needs at
> least 3ms to get *any* gain when compared to SU (which obviously means
> you want more to actually make MU pay off). The rule of thumb is the
> longer you wait the bigger capacity you can get.
>
> Apparently there's interest in maximizing throughput but it stands in
> direct opposition of keeping the latency down so I've been thinking
> how to satisfy both.

I really think this should be tunable.  For instance, someone making an AP
that is mostly for letting lots of users stream movies would care a lot more
about throughput than someone making an AP that is mainly for browsing the
web and doing more latency-sensitive activities.


> The current approach ath10k is taking (patches in review [1][2]) is to
> use mac80211 software queues for per-station queuing, exposing queue
> state to firmware (it decides where frames should be dequeued from)
> and making it possible to stop/wake per-station tx subqueue with fake
> netdev queues. I'm starting to think this is not the right way though
> because it's inherently hard to control latency and there's a huge
> memory overhead associated with the fake netdev queues. Also fq_codel
> is a less effective with this kind of setup.
>
> My current thinking is that the entire problem should be solved via
> (per-AC) qdiscs, e.g. fq_codel. I guess one could use
> limit/target/interval/quantum knobs to tune it for higher latency of
> aggregation-oriented Wi-Fi links where long service time (think
> 100-200ms) is acceptable. However fq_codel is oblivious to how Wi-Fi
> works in the first place, i.e. Wi-Fi gets better throughput if you
> deliver bursts of packets destined to the same station. Moreover this
> gets even more complicated with MU-MIMO where you may want to consider
> spatial location (which influences signal quality when grouped) of
> each station when you decide which set of stations you're going to
> aggregate to in parallel. Since drivers have a finite tx ring this it
> is important to deliver bursts that can actually be aggregated
> efficiently. This means driver would need to be able to tell qdisc
> about per-flow conditions to influence the RR scheme in some way
> (assuming a qdiscs even understands flows; do we need a unified way of
> talking about flows between qdiscs and drivers?).

I wonder if it would work better if we removed most of the
tid handling and aggregation logic in the firmware.  Maybe just have the mgt Q and best
effort (and skip VO/VI).  Let the OS tell (or suggest to) the firmware when aggregation
starts and stops.  That might at least cut the number of queues in half,
saving memory and latency up and down the stack.

Thanks,
Ben


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
