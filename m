From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: Explaining RX-stages for XDP
Date: Tue, 27 Sep 2016 19:12:44 -0700
Message-ID: <20160928021242.GA77695@ast-mbp.thefacebook.com>
References: <20160927113237.7138c097@redhat.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org" <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	Daniel Borkmann <borkmann-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160927113237.7138c097-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Tue, Sep 27, 2016 at 11:32:37AM +0200, Jesper Dangaard Brouer wrote:
> 
> Let me try in a calm way (not like [1]) to explain how I imagine that
> the XDP processing RX-stage should be implemented. As I've pointed out
> before[2], I'm proposing splitting up the driver into RX-stages.  This
> is a mental-model change, I hope you can follow my "inception" attempt.
> 
> The basic concept behind this idea is, if the RX-ring contains
> multiple "ready" packets, then the kernel was too slow, processing
> incoming packets. Thus, switch into more efficient mode, which is a
> "packet-vector" mode.
> 
> Today, our XDP micro-benchmarks looks amazing, and they are!  But once
> real-life intermixed traffic is used, then we loose the XDP I-cache
> benefit.  XDP is meant for DoS protection, and an attacker can easily
> construct intermixed traffic.  Why not fix this architecturally?
> 
> Most importantly concept: If XDP return XDP_PASS, do NOT pass the
> packet up the network stack immediately (that would flush I-cache).
> Instead store the packet for the next RX-stage.  Basically splitting
> the packet-vector into two packet-vectors, one for network-stack and
> one for XDP.  Thus, intermixed XDP vs. netstack not longer have effect
> on XDP performance.
> 
> The reason for also creating an XDP packet-vector, is to move the
> XDP_TX transmit code out of the XDP processing stage (and future
> features).  This maximize I-cache availability to the eBPF program,
> and make eBPF performance more uniform across drivers.
> 
> 
> Inception:
>  * Instead of individual packets, see it as a RX packet-vector.
>  * XDP should be seen as a stage *before* the network stack gets called.
> 
> If your mind can handle it: I'm NOT proposing a RX-vector of 64-packets.
> I actually want N-packet per vector (8-16).  As the NIC HW RX process
> runs concurrently, and by the time it takes to process N-packets, more
> packets have had a chance to arrive in the RX-ring queue.

Sounds like what Edward was proposing earlier with building
link list of skbs and passing further into stack?
Or the idea is different ?

As far as intermixed XDP vs stack traffic, I think for DoS case the traffic
patterns are binary. Either all of it is good or under attack most of
the traffic is bad, so makes sense to optimize for these two.
50/50 case I think is artificial and not worth optimizing for.
For all good traffic whether xdp is there or not shouldn't matter
for this N-vector optimization. Whether it's a batch of 8, 16 or 64,
either via link-list or array, it should probably be a generic
mechanism independent of any xdp stuff.
For under attack traffic the most important is to optimize for line
rate parsing of the traffic inside bpf and quickest as possible
drop on the driver side. Few good packets that are passed to the stack
make no difference to overall system performance.
I think existing mlx4+xdp is already optimized for 'mostly attack' traffic
and performs pretty weel, since imo 'all drop' benchmark is accurate.
Optimizing xdp for 'mostly good' traffic is indeed a challange.
We'd need all the tricks to make it as good as normal skb-based traffic.
I haven't seen any tests yet comparing xdp with 'return XDP_PASS' program
vs no xdp at all running netperf tcp/udp in user space. It shouldn't
be too far off. Doing this benchmarking on mlx4 is also not necessarily
will speak for ixgbe, since large mtu there is packet per page already,
so whenever ixgbe supports xdp, I think, ixgbe+xdp+'return XDP_PASS'
should be the same tcp/udp performance as ixgbe+large_mtu.
No doubt, would be interesting to see mlx numbers.
