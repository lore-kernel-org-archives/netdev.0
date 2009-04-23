From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Thu, 23 Apr 2009 14:11:58 +0800
Message-ID: <49F006AE.5040104@cn.fujitsu.com>
References: <20090423052520.GA13036@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57024 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbZDWGOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 02:14:24 -0400
In-Reply-To: <20090423052520.GA13036@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> First cut of "big hammer" expedited RCU grace periods, but only for
> rcu_bh.  This creates another softirq vector, so that entering this
> softirq vector will have forced an rcu_bh quiescent state (as noted by
> Dave Miller).  Use smp_call_function() to invoke raise_softirq() on all
> CPUs in order to cause this to happen.  Track the CPUs that have passed
> through a quiescent state (or gone offline) with a cpumask.
> 
> Does nothing to expedite callbacks already registered with call_rcu_bh(),
> but there is no need to.
> 
> Shortcomings:
> 
> o	Untested, probably does not compile, not for inclusion.
> 
> o	Does not handle rcu, only rcu_bh.
> 
> Thoughts?
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  include/linux/interrupt.h |    1 
>  include/linux/rcupdate.h  |    1 
>  kernel/rcupdate.c         |  106 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 108 insertions(+)
> 
> diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
> index 91bb76f..b7b58cc 100644
> --- a/include/linux/interrupt.h
> +++ b/include/linux/interrupt.h
> @@ -338,6 +338,7 @@ enum
>  	TASKLET_SOFTIRQ,
>  	SCHED_SOFTIRQ,
>  	HRTIMER_SOFTIRQ,
> +	RCU_EXPEDITED_SOFTIRQ,
>  	RCU_SOFTIRQ,	/* Preferable RCU should always be the last softirq */
>  
>  	NR_SOFTIRQS
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 15fbb3c..d4af557 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -264,6 +264,7 @@ extern void synchronize_rcu(void);
>  extern void rcu_barrier(void);
>  extern void rcu_barrier_bh(void);
>  extern void rcu_barrier_sched(void);
> +extern void synchronize_rcu_bh_expedited(void);
>  
>  /* Internal to kernel */
>  extern void rcu_init(void);
> diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
> index a967c9f..bfa98dd 100644
> --- a/kernel/rcupdate.c
> +++ b/kernel/rcupdate.c
> @@ -217,10 +217,116 @@ static int __cpuinit rcu_barrier_cpu_hotplug(struct notifier_block *self,
>  	return NOTIFY_OK;
>  }
>  
> +static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
> +static long synchronize_rcu_bh_completed; /* Expedited-grace-period count. */
> +
> +#ifndef CONFIG_SMP
> +
> +static void __init synchronize_rcu_expedited_init(void)
> +{
> +}
> +
> +void synchronize_rcu_bh_expedited(void)
> +{
> +	mutex_lock(&synchronize_rcu_bh_mutex);
> +	synchronize_rcu_bh_completed++;
> +	mutex_unlock(&synchronize_rcu_bh_mutex);
> +}
> +
> +#else /* #ifndef CONFIG_SMP */
> +
> +static DEFINE_PER_CPU(int, rcu_bh_need_qs);
> +static cpumask_var_t rcu_bh_waiting_map;
> +
> +static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
> +{
> +	if (__get_cpu_var(rcu_bh_need_qs)) {
> +		smp_mb();
> +		__get_cpu_var(rcu_bh_need_qs) = 0;
> +		smp_mb();
> +	}
> +}
> +
> +static void rcu_bh_fast_qs(void *unused)
> +{
> +	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
> +}
> +
> +static void __init synchronize_rcu_expedited_init(void)
> +{
> +	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
> +	alloc_bootmem_cpumask_var(&rcu_bh_waiting_map);
> +}
> +
> +void synchronize_rcu_bh_expedited(void)
> +{
> +	int cpu;
> +	int done;
> +	int times = 0;
> +
> +	mutex_lock(&synchronize_rcu_bh_mutex);
> +
> +	/* Take snapshot of online CPUs, blocking CPU hotplug. */
> +	preempt_disable();
> +	cpumask_copy(rcu_bh_waiting_map, &cpu_online_map);
> +	preempt_enable();
> +
> +	/* Mark each online CPU as needing a quiescent state. */
> +	for_each_cpu(cpu, rcu_bh_waiting_map)
> +		per_cpu(rcu_bh_need_qs, cpu) = 1;
> +
> +	/* Call for a quiescent state on each online CPU. */
> +	preempt_disable();
> +	cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
> +	smp_call_function(rcu_bh_fast_qs, NULL, 1);
> +	preempt_enable();
> +
> +	/*
> +	 * Loop waiting for each CPU to either pass through a quiescent
> +	 * state or to go offline.  We don't care which.
> +	 */
> +	for (;;) {
> +		
> +		/* Ignore CPUs that have gone offline, blocking CPU hotplug. */
> +		preempt_disable();
> +		cpumask_and(rcu_bh_waiting_map, rcu_bh_waiting_map,
> +			    &cpu_online_map);
> +		cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
> +		preempt_enable();
> +
> +		/* Check if any CPUs still need a quiescent state. */
> +		done = 1;
> +		for_each_cpu(cpu, rcu_bh_waiting_map) {
> +			if (per_cpu(rcu_bh_need_qs, cpu)) {
> +				done = 0;
> +				break;
> +			}
> +			cpumask_clear_cpu(cpu, rcu_bh_waiting_map);
> +		}
> +		if (done)
> +			break;
> +
> +		/*
> +		 * Wait a bit.  If we have already waited a fair
> +		 * amount of time, sleep.
> +		 */
> +		if (++times < 10)
> +			udelay(10 * times);
> +		else
> +			schedule_timeout_uninterruptible(1);
> +	}
> +
> +	synchronize_rcu_bh_completed++;
> +	mutex_unlock(&synchronize_rcu_bh_mutex);
> +}
> +
> +#endif /* #else #ifndef CONFIG_SMP */
> +
>  void __init rcu_init(void)
>  {
>  	__rcu_init();
>  	hotcpu_notifier(rcu_barrier_cpu_hotplug, 0);
> +	synchronize_rcu_expedited_init();
>  }
>  
>  void rcu_scheduler_starting(void)
> 

Hi, Paul

I just typed codes in email, very like these two pathes:

[PATCH 1/2] sched: Introduce APIs for waiting multi events
http://lkml.org/lkml/2009/4/14/733

[PATCH 2/2] rcupdate: use struct ref_completion
http://lkml.org/lkml/2009/4/14/734

Lai.
--------------

#ifndef CONFIG_SMP

static void __init synchronize_rcu_expedited_init(void)
{
}

void synchronize_rcu_bh_expedited(void)
{
	cond_resched();
}

#else /* #ifndef CONFIG_SMP */

static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
static DEFINE_PER_CPU(int, call_only_once); /* is it need ? */
static struct ref_completion rcu_bh_expedited_completion

static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
{
	if (__get_cpu_var(call_only_once)) {
		smp_mb();
		ref_completion_put(&rcu_bh_expedited_completion);
		__get_cpu_var(call_only_once) = 0;
	}
}

static void rcu_bh_fast_qs(void *unused)
{
	__get_cpu_var(call_only_once) = 1;
	ref_completion_get(&rcu_bh_expedited_completion);
	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
}

static void __init synchronize_rcu_expedited_init(void)
{
	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
}

void synchronize_rcu_bh_expedited(void)
{
	mutex_lock(&synchronize_rcu_bh_mutex);

	ref_completion_get_init(&rcu_bh_expedited_completion);

	smp_call_function(rcu_bh_fast_qs, NULL, 1);

	ref_completion_put_init(&rcu_bh_expedited_completion);
	ref_completion_wait(&rcu_bh_expedited_completion);

	mutex_unlock(&synchronize_rcu_bh_mutex);
}

#endif /* #else #ifndef CONFIG_SMP */

