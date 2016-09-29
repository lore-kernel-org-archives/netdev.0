From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: Explaining RX-stages for XDP
Date: Wed, 28 Sep 2016 21:44:20 -0700
Message-ID: <20160929044416.GA92396@ast-mbp.thefacebook.com>
References: <20160927113237.7138c097@redhat.com>
	<20160928021242.GA77695@ast-mbp.thefacebook.com>
	<20160928124431.351d7180@redhat.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160928124431.351d7180-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Wed, Sep 28, 2016 at 12:44:31PM +0200, Jesper Dangaard Brouer wrote:
> 
> The idea is quite different.  It has nothing to do with Edward's
> proposal[3].  The RX packet-vector is simply an array, either of pointers
> or index numbers (into the RX-ring).  The needed changes are completely
> contained inside the driver.
> 
> > As far as intermixed XDP vs stack traffic, I think for DoS case the
> > traffic patterns are binary. Either all of it is good or under attack
> > most of the traffic is bad, so makes sense to optimize for these two.
> > 50/50 case I think is artificial and not worth optimizing for.
> 
> Sorry, but I feel you have completely misunderstood the concept of my
> idea.  It does not matter what traffic pattern you believe or don't
> believe in, it is irrelevant.  The fact is that intermixed traffic is
> possible with the current solution.  The core of my idea is to remove
> the possibility for this intermixed traffic to occur, simply by seeing
> XDP as a RX-stage before the stack.

Is the idea to add two extra 'to_stack' and 'not_to_stack' arrays
after XDP program made a decision ?
Sounds interesting, but I cannot evaluate it properly, since I fail
to see what problem it solves and how it can be benchmarked.
Since you're saying the percentage of good vs bad traffic is irrelevant
then this idea should help all types of traffic in all cases?
That would be truly awesome.

I think the discussion around performance optimizations
should start from:
1. describing the problem: What is the use case?
What is the traffic pattern?
After problem is understood and accepted as a valid problem
and not some research subject then
2. define a benchmark that simulates it
when benchmarking methodology is agreed upon
we can go the next step of
3. come up with multiple ideas/proposals to solve the problem 1.
and finally discuss
4. different implementations of the best proposal from step 3

Without 1 it's easy to come up with a fake benchmark in step 2
that can justify addition of any code in 4
Without 2, the comparison of different proposals will be
based on subjective opinions instead of hard data.
Without 3 the proposed patch will be a hard sell, since
other alternatives were not on the table.

For new features the steps are different, of course.

When we started on XDP among everything else the first two problems
that it's supposed to solve were DoS and loadbalancer/ila_router.
For former the attack traffic is mostly dropped after parsing.
That behavior is simulated by samples/bpf/xdp1_kern.c
For load balancer most of the traffic is parsed and transmitted
out on the same device after packet rewrite. That scenario
is simulated by samples/bpf/xdp2_kern.c
Therefore the benchmarking and performance numbers were
centered around these two programs and I believe XDP itself
is a good solution for DoS and ila_router based on
the performance numbers from these two benchmarks.
I think XDP is _not_ a good solution for many other use cases.

The DoS protection feature when not under attack was
not benchmarked, so this is the area to work on in the future.
(the appropriate benchmark is xdp_pass+tcp+netperf)

Another area that was not benchmarked is how XDP drop/tx
interacts with normal control plane traffic.
We assumed that different hw tx queues should provide
sufficient separation. That is certainly to be tested.
A lot of work to do, no doubt.

> > Optimizing xdp for 'mostly good' traffic is indeed a challange.
> > We'd need all the tricks to make it as good as normal skb-based traffic.
> >
> > I haven't seen any tests yet comparing xdp with 'return XDP_PASS' program
> > vs no xdp at all running netperf tcp/udp in user space. It shouldn't
> > be too far off.
> 
> Well, I did post numbers to the list with a 'return XDP_PASS' program[4]:
>  https://mid.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg122350.html
> 
> Wake-up and smell the coffee, please revise your assumptions:
>  * It showed that the performance reduction is 25.98%!!!
>    (AB comparison dropping packets in iptables raw)

sure. iptables drop is slow with xdp_pass vs iptables without xdp.
This is not a benchmark I was interested in, since I don't
understand what use case it simulates.

> Conclusion: These measurements confirm that we need a page recycle
> facility for the drivers before switching to order-0 allocations.
...
> page_pool work
>  - iptables-raw-drop: driver mlx5
>    * 4,487,518 pps - baseline-before     =>  100.0%
>    * 3,624,237 pps - mlx5 order0-patch   => - 19.2% (slower)
>    * 4,806,142 pps - PoC page_pool patch =>   +7.1% (faster)

I agree that generic page_pool is a useful facility, but
I don't think it's the right approach to design it based on
iptables_drop+xdp_pass benchmark.
You're saying the protoype gives 7.1% improvement. Ok,
but what is the problem being solved?
If the use case is DoS and fast as possible drop, then XDP_DROP
is a better alternative. Why design/benchmark page_pool
based on iptables_drop ?
If page_pool replaces custom page recycling in mlx4/mlx5
with generic one and maintains the same performance
on xdp1_kern.c and xdp2_kern.c benchmarks then the main
value is not a performance optimization, but making common
piece of infrastructure. Which is great.
