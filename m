From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Using sched_clock() for polling time limit
Date: Mon, 1 Jul 2013 20:48:11 +0100
Message-ID: <1372708091.2083.50.camel@bwh-desktop.uk.level5networks.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
	  <20130628125926.14419.89905.stgit@ladj378.jer.intel.com>
	 <1372438309.1937.9.camel@bwh-desktop.uk.level5networks.com>
	 <51CF2C88.4030900@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Cody P Schafer <devel-lists@codyps.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CF2C88.4030900@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-06-29 at 21:50 +0300, Eliezer Tamir wrote:
> On 28/06/2013 19:51, Ben Hutchings wrote:
> > On Fri, 2013-06-28 at 15:59 +0300, Eliezer Tamir wrote:
> >> Our use of sched_clock is OK because we don't mind the side effects
> >> of calling it and occasionally waking up on a different CPU.
> >
> > Sure about that?  Jitter matters too.
> >
> Pretty sure, this is a limit on how long we poll, it's for fairness to
> the rest of the system not for performance of this code.
> 
> What matters is that on average you are bounded by something close to
> what the user specified. If once in a while you run less because of
> clock jitter, or even twice the specified time, it's no big deal.

So what is the maximum time difference in sched_clock() values between
CPUs in the same system?

> So I don't see how jitter would matter.
> 
> And if your workload is jitter sensitive, you should probably be
> pinning tasks to CPUs anyway.

Yes, they should be pinned.  But I think a single task that isn't pinned
could poll for significantly longer than intended and the effect
wouldn't be limited to that one task.

> >> When CONFIG_DEBUG_PREEMPT is on, disable preempt before calling
> >> sched_clock() so we don't trigger a debug_smp_processor_id() warning.
> > [...]
> >
> > I think this is papering over a problem.  The warning is there for a
> > good reason.
> 
> I think we understand the warning, and that we are OK with the effects.
> 
> looking at how other users in the kernel solved this issue
> It seems like this is what they do.
> for example trace/ring_buffer.c:ring_buffer_time_Stamp()

Well, this seems to be debug information, not actually used for timing.

> Also kvm_clock_read() and xen_clokcsource_read() seem to disable preempt
> just to silence this warning.

I can't see what you're referring to.

> If they really cared about reading the value on one CPU, then being
> scheduled on another they should have disabled interrupts.
> or am I missing something?
> 
> > Would functions like these make it possible to use sched_clock() safely
> > for polling?  (I didn't spend much time thinking about the names.)
[...]
> I don't understand, preempt_disable() only makes prevents preempt
> from taking the CPU away from you, you could still lose it for
> other reasons.
> You would really need to disable interrupts in this region to be
> sure that it all executed on the same CPU.

Hmm, yes you're right.  Anyway, what I was trying to suggest was that
you would record the current CPU along with the initial timestamp, and
then abort low-latency polling if either the task is moved onto a
different CPU or the time limit was reached.  Checking the CPU first
means that the sched_clock() comparison is valid.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
