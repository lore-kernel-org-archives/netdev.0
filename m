From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: Using sched_clock() for polling time limit
Date: Sat, 29 Jun 2013 21:50:48 +0300
Message-ID: <51CF2C88.4030900@linux.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>  <20130628125926.14419.89905.stgit@ladj378.jer.intel.com> <1372438309.1937.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372438309.1937.9.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/06/2013 19:51, Ben Hutchings wrote:
> On Fri, 2013-06-28 at 15:59 +0300, Eliezer Tamir wrote:
>> Our use of sched_clock is OK because we don't mind the side effects
>> of calling it and occasionally waking up on a different CPU.
>
> Sure about that?  Jitter matters too.
>
Pretty sure, this is a limit on how long we poll, it's for fairness to
the rest of the system not for performance of this code.

What matters is that on average you are bounded by something close to
what the user specified. If once in a while you run less because of
clock jitter, or even twice the specified time, it's no big deal.

So I don't see how jitter would matter.

And if your workload is jitter sensitive, you should probably be
pinning tasks to CPUs anyway.


>> When CONFIG_DEBUG_PREEMPT is on, disable preempt before calling
>> sched_clock() so we don't trigger a debug_smp_processor_id() warning.
> [...]
>
> I think this is papering over a problem.  The warning is there for a
> good reason.

I think we understand the warning, and that we are OK with the effects.

looking at how other users in the kernel solved this issue
It seems like this is what they do.
for example trace/ring_buffer.c:ring_buffer_time_Stamp()

Also kvm_clock_read() and xen_clokcsource_read() seem to disable preempt
just to silence this warning.

If they really cared about reading the value on one CPU, then being
scheduled on another they should have disabled interrupts.
or am I missing something?

> Would functions like these make it possible to use sched_clock() safely
> for polling?  (I didn't spend much time thinking about the names.)
>
> struct sched_timestamp {
> 	int cpu;
> 	unsigned long long clock;
> };
>
> static inline struct sched_timestamp sched_get_timestamp(void)
> {
> 	struct sched_timestamp ret;
>
> 	preempt_disable_notrace();
> 	ret.cpu = smp_processor_id();
> 	ret.clock = sched_clock();
> 	preempt_enable_no_resched_notrace();
>
> 	return ret;
> }

I don't understand, preempt_disable() only makes prevents preempt
from taking the CPU away from you, you could still lose it for
other reasons.
You would really need to disable interrupts in this region to be
sure that it all executed on the same CPU.

-Eliezer
