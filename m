From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] pktgen: skb bursting via skb->xmit_more API
Date: Sat, 30 Aug 2014 15:37:42 +0200
Message-ID: <20140830153742.7f27d98c@redhat.com>
References: <20140827211300.26976.52104.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	cwang@twopensource.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbaH3Nhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2014 09:37:54 -0400
In-Reply-To: <20140827211300.26976.52104.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 27 Aug 2014 23:13:00 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> This patch just demonstrates the effect of delaying the HW tailptr.
> Let me demonstrate the performance effect of bulking packet with pktgen.
> 
> These results is a **single** CPU pktgen TX via script:
>  https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen02_burst.sh
> 
> Cmdline args:
>  ./pktgen02_burst.sh -i eth5 -d 192.168.21.4 -m 00:12:c0:80:1d:54 -b $skb_burst
> 
> Special case skb_burst=1 does not burst, but activates the
> skb_burst_count++ and writing to skb->xmit_more.
> 
> Performance
>  skb_burst=0  tx:5614370 pps
>  skb_burst=1  tx:5571279 pps ( -1.38 ns (worse))
>  skb_burst=2  tx:6942821 pps ( 35.46 ns)
>  skb_burst=3  tx:7556214 pps ( 11.69 ns)
>  skb_burst=4  tx:7740632 pps ( 3.15 ns)
>  skb_burst=5  tx:7972489 pps ( 3.76 ns)
>  skb_burst=6  tx:8129856 pps ( 2.43 ns)
>  skb_burst=7  tx:8281671 pps ( 2.25 ns)
>  skb_burst=8  tx:8383790 pps ( 1.47 ns)
>  skb_burst=9  tx:8451248 pps ( 0.95 ns)
>  skb_burst=10 tx:8503571 pps ( 0.73 ns)
>  skb_burst=16 tx:8745878 pps ( 3.26 ns)
>  skb_burst=24 tx:8871629 pps ( 1.62 ns)
>  skb_burst=32 tx:8945166 pps ( 0.93 ns)
> 
> skb_burst=(0 vs 32) improvement:
>  (1/5614370*10^9)-(1/8945166*10^9) = 66.32 ns
>   + 3330796 pps

A more interesting benchmark with pktgen is to see what happens if
pktgen have to free and allocate a new SKB everytime in the transmit
loop.  Because this adds a relatively significant delay between packets.

Baseline before with SKB_CLONE=100000 (and skb_burst=0), was
5614370pps.  Corrosponding to a 178 nanosec delay between packets
(1/5614370*10^9).

Pktgen performance drops to 2421076 pps with SKB_CLONE=0 (and
skb_burst=0), causing a full free+alloc cycle (also keeping the
do_gettimeofday() timestamp). This corrosponds to (1/2421076*10^9)
413 nanosec between packets.

Interesting this also tell us that the stack overhead + pktgen
packet-init is (413-178=) 235ns. (The do_gettimeofday contributes
23ns, leaving 212ns).

Results:
 skb_burst=0  2421076 pps
 skb_burst=1  2410301 pps ( -1.85 ns (worse))
 skb_burst=2  2580824 pps ( 27.41 ns)
 skb_burst=3  2678276 pps ( 14.10 ns)
 skb_burst=4  2729021 pps (  6.94 ns)
 skb_burst=5  2742044 pps (  1.74 ns)
 skb_burst=6  2763974 pps (  2.89 ns)
 skb_burst=7  2772413 pps (  1.10 ns)
 skb_burst=8  2788705 pps (  2.10 ns)
 skb_burst=9  2791055 pps (  0.30 ns)
 skb_burst=10 2791726 pps (  0.09 ns)
 skb_burst=16 2819949 pps (  3.58 ns)
 skb_burst=24 2817786 pps ( -0.27 ns)
 skb_burst=32 2813690 pps ( -0.51 ns)

Perhaps a little bit interesting that performance slightly decreases
after skb_burst=16, but this could simply be caused by the accuracy
level (as those tests had a variation of min:-0.250 max:1.811 ns).

skb_burst=(0 vs 32) improvement:
 (1/2421076*10^9)-(1/2813690*10^9) = 57.63 ns
 2,813,690-2,421,076 = +392,614 pps

Bulking via HW ring buffer tailptr "flush", still showed a significant
performance improvement, even with this spacing caused by pktgen
free+alloc+init+timestamp.  I tried to tcpdump packets on the sink
host, but I could not "see" the bulking (this is most likely a problem
with the sink and tcpdumps time resolution).


Setup notes:
 - pktgen TX single CPU test (E5-2695)
 - ethtool -C eth5 rx-usecs 30
 - tuned-adm profile latency-performance
 - IRQ aligned to CPUs
 - Ethernet Flow-Control disabled
 - No Hyper-Threading
 - netfilter_unload_modules.sh

Need something to relate these nanosec to?
Go read:
 http://netoptimizer.blogspot.dk/2014/05/the-calculations-10gbits-wirespeed.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
