From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Fri, 22 Aug 2014 15:29:15 +0800
Message-ID: <53F6F14B.1030609@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com> <1408683665.5648.69.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408683665.5648.69.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2014 01:01 PM, Mike Galbraith wrote:
> On Thu, 2014-08-21 at 16:05 +0800, Jason Wang wrote: 
>> > Rx busy loop does not scale well in the case when several parallel
>> > sessions is active. This is because we keep looping even if there's
>> > another process is runnable. For example, if that process is about to
>> > send packet, keep busy polling in current process will brings extra
>> > delay and damage the performance.
>> > 
>> > This patch solves this issue by exiting the busy loop when there's
>> > another process is runnable in current cpu. Simple test that pin two
>> > netperf sessions in the same cpu in receiving side shows obvious
>> > improvement:
> That patch says to me it's a bad idea to spin when someone (anyone) else
> can get some work done on a CPU, which intuitively makes sense.  But..
>
> (ponders net goop: with silly 1 byte ping-pong load, throughput is bound
> by fastpath latency, net plus sched plus fixable nohz and governor crud
> if not polling, so you can't get a lot of data moved byte at a time no
> matter how sexy the pipe whether polling or not due to bound.  If OTOH
> net hardware is a blazing fast large bore packet cannon, net overhead
> per unit payload drops, sched+crud is a constant)

Polling could be done by either rx busy loop in process context or NAPI
in softirq. Rx busy loop may only spin and poll when no packet were
found in socket receive queue. It spins in the hope that at least one
packet will come (in this case the process will exit rx busy loop) in a
short while. In this way, it eliminates the overheads of NAPI, wakeup
and scheduling. This patch just make the busy polling less aggressive:
Since the process finds nothing to receive when still spinning in this
loop, there's no need to waste cpu cycles ( or even call cpu_relax()) if
there's another work could be done by current CPU.

For stream workload like you mentioned here, if the card was fast
enough, the socket receive queue was not easy to be drained. Rx busy
loop won't help or even won't be triggered in this case.
>
> Seems the only time it's a good idea to poll is if blasting big packets
> on sexy hardware, and if you're doing that, you want to poll regardless
> of whether somebody else is waiting, or?

NAPI will work instead of rx busy loop in this case. It will poll and
try to drain nic's rx ring in softirq regardless somebody else.

Btw, current rx busy loop does not perform well on stream workload since
it bypasses GRO to reduce latency. But this issue beyond the scope of
this patch.
