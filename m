From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Thu, 23 Apr 2009 09:54:57 -0700
Message-ID: <20090423165457.GD6877@linux.vnet.ibm.com>
References: <20090423052520.GA13036@linux.vnet.ibm.com> <20090423134539.GC11261@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090423134539.GC11261@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 09:45:39AM -0400, Mathieu Desnoyers wrote:
> * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > First cut of "big hammer" expedited RCU grace periods, but only for
> > rcu_bh.  This creates another softirq vector, so that entering this
> > softirq vector will have forced an rcu_bh quiescent state (as noted by
> > Dave Miller).  Use smp_call_function() to invoke raise_softirq() on all
> > CPUs in order to cause this to happen.  Track the CPUs that have passed
> > through a quiescent state (or gone offline) with a cpumask.
> > 
> > Does nothing to expedite callbacks already registered with call_rcu_bh(),
> > but there is no need to.
> > 
> > Shortcomings:
> > 
> > o	Untested, probably does not compile, not for inclusion.
> > 
> > o	Does not handle rcu, only rcu_bh.
> > 
> > Thoughts?
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> > 
> >  include/linux/interrupt.h |    1 
> >  include/linux/rcupdate.h  |    1 
> >  kernel/rcupdate.c         |  106 ++++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 108 insertions(+)
> > 
> > diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> > index 91bb76f..b7b58cc 100644
> > --- a/include/linux/interrupt.h
> > +++ b/include/linux/interrupt.h
> > @@ -338,6 +338,7 @@ enum
> >  	TASKLET_SOFTIRQ,
> >  	SCHED_SOFTIRQ,
> >  	HRTIMER_SOFTIRQ,
> > +	RCU_EXPEDITED_SOFTIRQ,
> >  	RCU_SOFTIRQ,	/* Preferable RCU should always be the last softirq */
> >  
> >  	NR_SOFTIRQS
> > diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> > index 15fbb3c..d4af557 100644
> > --- a/include/linux/rcupdate.h
> > +++ b/include/linux/rcupdate.h
> > @@ -264,6 +264,7 @@ extern void synchronize_rcu(void);
> >  extern void rcu_barrier(void);
> >  extern void rcu_barrier_bh(void);
> >  extern void rcu_barrier_sched(void);
> > +extern void synchronize_rcu_bh_expedited(void);
> >  
> >  /* Internal to kernel */
> >  extern void rcu_init(void);
> > diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
> > index a967c9f..bfa98dd 100644
> > --- a/kernel/rcupdate.c
> > +++ b/kernel/rcupdate.c
> > @@ -217,10 +217,116 @@ static int __cpuinit rcu_barrier_cpu_hotplug(struct notifier_block *self,
> >  	return NOTIFY_OK;
> >  }
> >  
> > +static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
> > +static long synchronize_rcu_bh_completed; /* Expedited-grace-period count. */
> 
> Given you access this variable through a mutex, you might want to
> consider using a u64 (unsigned long long) to make sure it counts a full
> 64-bits on 32-bits architectures. This would make overflows less likely
> to happen. Note that the reads should be done through a mutex then.
> Another alternative is to protect it using a seqlock. Note that the two
> previous "non-atomic" read solutions should never be used in NMI
> context. :-/

Agreed, except that this is used only by rcutorture to show progress,
and is OK to overflow.

Besides, if I change this, I have to change the corresponding pieces of the
rest of RCU.  ;-)

> > +
> > +#ifndef CONFIG_SMP
> > +
> > +static void __init synchronize_rcu_expedited_init(void)
> > +{
> > +}
> > +
> > +void synchronize_rcu_bh_expedited(void)
> > +{
> > +	mutex_lock(&synchronize_rcu_bh_mutex);
> > +	synchronize_rcu_bh_completed++;
> > +	mutex_unlock(&synchronize_rcu_bh_mutex);
> > +}
> > +
> > +#else /* #ifndef CONFIG_SMP */
> > +
> > +static DEFINE_PER_CPU(int, rcu_bh_need_qs);
> > +static cpumask_var_t rcu_bh_waiting_map;
> > +
> > +static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
> > +{
> > +	if (__get_cpu_var(rcu_bh_need_qs)) {
> 
> Is this test useful at all ? The value can only be 0 or 1, so if it is
> already 0, then we set it to 0 again. I doubt you care that much about
> cache-line bouncing ?

Nah, only about memory barriers.  Probably not worth the check in this
case.

> > +		smp_mb();
> > +		__get_cpu_var(rcu_bh_need_qs) = 0;
> > +		smp_mb();
> 
> Is this second mb required ? We want to make sure no memory access
> coming from code executed before the flag write goes into the next qs
> period, this is fine (and explains the first mb()), but do we care
> about interleaving writes done after the flag write ? In the worse case,
> they will be put in the previous qs period, and that seems fine.

Also that no RCU read-side critical section following gets reordered
to precede the flip.

> > +	}
> > +}
> > +
> > +static void rcu_bh_fast_qs(void *unused)
> > +{
> > +	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
> > +}
> > +
> > +static void __init synchronize_rcu_expedited_init(void)
> > +{
> > +	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
> > +	alloc_bootmem_cpumask_var(&rcu_bh_waiting_map);
> > +}
> > +
> > +void synchronize_rcu_bh_expedited(void)
> > +{
> > +	int cpu;
> > +	int done;
> > +	int times = 0;
> > +
> > +	mutex_lock(&synchronize_rcu_bh_mutex);
> > +
> > +	/* Take snapshot of online CPUs, blocking CPU hotplug. */
> > +	preempt_disable();
> 
> Hrm, how about simply 
> 
> get_online_cpus();
> 
> put_online_cpus();
> 
> just once at the beginning/end of this function to stop cpu hotplug ?
> 
> All these preempt_enable/disable seems a bit too much. But I see that
> you might not want to disabling cpu hotplug for too long, so you
> probably have a good reason to do it this way.

Your approach does have the virtue of simplicity.  Lai's approach,
if it correctly handles CPU hotplug, avoids even disabling preemption,
though it does potentially do some serious cache thrashing for large
numbers of CPUs.

> > +	cpumask_copy(rcu_bh_waiting_map, &cpu_online_map);
> > +	preempt_enable();
> > +
> > +	/* Mark each online CPU as needing a quiescent state. */
> > +	for_each_cpu(cpu, rcu_bh_waiting_map)
> > +		per_cpu(rcu_bh_need_qs, cpu) = 1;
> > +
> > +	/* Call for a quiescent state on each online CPU. */
> > +	preempt_disable();
> > +	cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
> 
> Commenting that smp_call_function has a smp_mb(), which makes sure
> per_cpu(rcu_bh_need_qs, cpu) writes happened before calling the remote
> functions would not hurt.

Ah!  I should have remembered that from last time, shouldn't I?  :-)

Updated.

And thank you for looking this over!!!

							Thanx, Paul

> Mathieu
> 
> > +	smp_call_function(rcu_bh_fast_qs, NULL, 1);
> > +	preempt_enable();
> > +
> > +	/*
> > +	 * Loop waiting for each CPU to either pass through a quiescent
> > +	 * state or to go offline.  We don't care which.
> > +	 */
> > +	for (;;) {
> > +		
> > +		/* Ignore CPUs that have gone offline, blocking CPU hotplug. */
> > +		preempt_disable();
> > +		cpumask_and(rcu_bh_waiting_map, rcu_bh_waiting_map,
> > +			    &cpu_online_map);
> > +		cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
> > +		preempt_enable();
> > +
> > +		/* Check if any CPUs still need a quiescent state. */
> > +		done = 1;
> > +		for_each_cpu(cpu, rcu_bh_waiting_map) {
> > +			if (per_cpu(rcu_bh_need_qs, cpu)) {
> > +				done = 0;
> > +				break;
> > +			}
> > +			cpumask_clear_cpu(cpu, rcu_bh_waiting_map);
> > +		}
> > +		if (done)
> > +			break;
> > +
> > +		/*
> > +		 * Wait a bit.  If we have already waited a fair
> > +		 * amount of time, sleep.
> > +		 */
> > +		if (++times < 10)
> > +			udelay(10 * times);
> > +		else
> > +			schedule_timeout_uninterruptible(1);
> > +	}
> > +
> > +	synchronize_rcu_bh_completed++;
> 
> > +	mutex_unlock(&synchronize_rcu_bh_mutex);
> > +}
> > +
> > +#endif /* #else #ifndef CONFIG_SMP */
> > +
> >  void __init rcu_init(void)
> >  {
> >  	__rcu_init();
> >  	hotcpu_notifier(rcu_barrier_cpu_hotplug, 0);
> > +	synchronize_rcu_expedited_init();
> >  }
> >  
> >  void rcu_scheduler_starting(void)
> 
> -- 
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
