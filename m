From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: Explaining RX-stages for XDP
Date: Wed, 28 Sep 2016 12:44:31 +0200
Message-ID: <20160928124431.351d7180@redhat.com>
References: <20160927113237.7138c097@redhat.com>
	<20160928021242.GA77695@ast-mbp.thefacebook.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Mel Gorman <mgorman-3eNAlZScCAx27rWaFMvyedHuzzzSOjJt@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <20160928021242.GA77695-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org


On Tue, 27 Sep 2016 19:12:44 -0700 Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Tue, Sep 27, 2016 at 11:32:37AM +0200, Jesper Dangaard Brouer wrote:
> > 
> > Let me try in a calm way (not like [1]) to explain how I imagine that
> > the XDP processing RX-stage should be implemented. As I've pointed out
> > before[2], I'm proposing splitting up the driver into RX-stages.  This
> > is a mental-model change, I hope you can follow my "inception" attempt.
> > 
> > The basic concept behind this idea is, if the RX-ring contains
> > multiple "ready" packets, then the kernel was too slow, processing
> > incoming packets. Thus, switch into more efficient mode, which is a
> > "packet-vector" mode.
> > 
> > Today, our XDP micro-benchmarks looks amazing, and they are!  But once
> > real-life intermixed traffic is used, then we loose the XDP I-cache
> > benefit.  XDP is meant for DoS protection, and an attacker can easily
> > construct intermixed traffic.  Why not fix this architecturally?
> > 
> > Most importantly concept: If XDP return XDP_PASS, do NOT pass the
> > packet up the network stack immediately (that would flush I-cache).
> > Instead store the packet for the next RX-stage.  Basically splitting
> > the packet-vector into two packet-vectors, one for network-stack and
> > one for XDP.  Thus, intermixed XDP vs. netstack not longer have effect
> > on XDP performance.
> > 
> > The reason for also creating an XDP packet-vector, is to move the
> > XDP_TX transmit code out of the XDP processing stage (and future
> > features).  This maximize I-cache availability to the eBPF program,
> > and make eBPF performance more uniform across drivers.
> > 
> > 
> > Inception:
> >  * Instead of individual packets, see it as a RX packet-vector.
> >  * XDP should be seen as a stage *before* the network stack gets called.
> > 
> > If your mind can handle it: I'm NOT proposing a RX-vector of 64-packets.
> > I actually want N-packet per vector (8-16).  As the NIC HW RX process
> > runs concurrently, and by the time it takes to process N-packets, more
> > packets have had a chance to arrive in the RX-ring queue.  
> 
> Sounds like what Edward was proposing earlier with building
> link list of skbs and passing further into stack?
> Or the idea is different ?

The idea is quite different.  It has nothing to do with Edward's
proposal[3].  The RX packet-vector is simply an array, either of pointers
or index numbers (into the RX-ring).  The needed changes are completely
contained inside the driver.


> As far as intermixed XDP vs stack traffic, I think for DoS case the
> traffic patterns are binary. Either all of it is good or under attack
> most of the traffic is bad, so makes sense to optimize for these two.
> 50/50 case I think is artificial and not worth optimizing for.

Sorry, but I feel you have completely misunderstood the concept of my
idea.  It does not matter what traffic pattern you believe or don't
believe in, it is irrelevant.  The fact is that intermixed traffic is
possible with the current solution.  The core of my idea is to remove
the possibility for this intermixed traffic to occur, simply by seeing
XDP as a RX-stage before the stack.


> For all good traffic whether xdp is there or not shouldn't matter
> for this N-vector optimization. Whether it's a batch of 8, 16 or 64,
> either via link-list or array, it should probably be a generic
> mechanism independent of any xdp stuff.

I also feel you have misunderstood the N-vector "optimization".
But, yes, this introduction of RX-stages is independent of XDP.

The RX-stages is a generic change to the drivers programming model.


[...]
> I think existing mlx4+xdp is already optimized for 'mostly attack' traffic
> and performs pretty well, since imo 'all drop' benchmark is accurate.

The "all drop" benchmark is as artificial as it gets.  It think Eric
agrees.

My idea is confining the XDP_DROP part to a RX-stage _before_ the
netstack. Then, the "all drop" benchmark number will get a little more
trustworthy.


> Optimizing xdp for 'mostly good' traffic is indeed a challange.
> We'd need all the tricks to make it as good as normal skb-based traffic.
>
> I haven't seen any tests yet comparing xdp with 'return XDP_PASS' program
> vs no xdp at all running netperf tcp/udp in user space. It shouldn't
> be too far off.

Well, I did post numbers to the list with a 'return XDP_PASS' program[4]:
 https://mid.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg122350.html

Wake-up and smell the coffee, please revise your assumptions:
 * It showed that the performance reduction is 25.98%!!!
   (AB comparison dropping packets in iptables raw)

Conclusion: These measurements confirm that we need a page recycle
facility for the drivers before switching to order-0 allocations.

I did the same kind of experiment with mlx5. Where I change the memory
model to order-0 pages, and then I implemented page_pool on top. (Below
number are before I implemented the DMA part of page_pool, which do
work now).

page_pool work
 - iptables-raw-drop: driver mlx5
   * 4,487,518 pps - baseline-before     =>  100.0%
   * 3,624,237 pps - mlx5 order0-patch   => - 19.2% (slower)
   * 4,806,142 pps - PoC page_pool patch =>   +7.1% (faster)

This Prove-of-Concept page_pool patch show that it is worth doing, as
the end result is a 7% performance improvement.  It also show page
recycling is definitely needed, as this also show that the cost
switching to order-0 is approx 212 cycles on this machine.

(1/4487518-1/3624237)*10^9* 4GHz = -212.32 cycles (cost change to order-0)
(1/4806142-1/3624237)*10^9* 4GHz = -271.41 cycles (gain of recycling)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://mid.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg127043.html
[2] http://lists.openwall.net/netdev/2016/01/15/51  
[3] http://lists.openwall.net/netdev/2016/04/19/89
[4] https://mid.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg122350.html
