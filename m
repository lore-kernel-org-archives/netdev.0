From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC PATCH] v3 RCU implementation with fast grace periods
Date: Tue, 21 Apr 2009 11:10:35 -0400
Message-ID: <20090421151034.GA3792@Krystal>
References: <20090421045931.GA9953@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090421045931.GA9953@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> Hello!
> 
> And here is a crude third cut.  Passes moderate rcutorture testing on
> x86 and Power.
> 
> Straight conversion of Mathieu Desnoyers's user-space RCU implementation
> at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did help
> a little, but he must bear the bulk of the guilt).  Pick on srcu.h
> and srcu.c out of sheer laziness.  User-space testing gives deep
> sub-microsecond grace-period latencies, so should be fast enough, at
> least if you don't mind two smp_call_function() invocations per grace
> period and spinning on each instance of a per-CPU variable.
> 
> Grace periods last about 31 microseconds in absence of readers on a 1.8GHz
> 4-CPU Opteron 844.  Adding momentary readers (which do rcu_read_lock_fgp()
> followed immediately by rcu_read_unlock_fgp() in a loop) does not degrade
> grace-period latency.  Read-side overhead is in the 45-nanosecond range.
> 
> Again, I believe per-CPU locking should work fine for the netfilter
> counters, but I guess "friends don't let friends use hashed locks".
> (I would not know for sure, never having used them myself, except of
> course to protect hash tables.)
> 
> Not for inclusion, intended only as proof of concept.
> 
> Changes since v2:
> 
> o	Applied Evgeniy Polyakov feedback.
> 
> o	Rearrange implementation to suit rcutorture (add exports,
> 	move read-side functions from srcu.h to srcu.c, get function
> 	declarations to the right place).
> 
> o	Set up grace-period detection to spin for a short time,
> 	then, if there are still readers we must wait on, sleep.
> 
> o	Update rcutorture to test rcu_fgp.  Oddly enough, the most
> 	difficult bugs were in rcutorture rather than in rcu_fgp.
> 
> Changes since v1:
> 
> o	Applied Mathieu's feedback.
> 
> o	Added docbook headers and other comments.
> 
> o	Added the rcu_fgp_batches_completed API required by rcutorture.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  include/linux/srcu.h |    5 +
>  kernel/rcutorture.c  |   42 ++++++++++++++
>  kernel/srcu.c        |  149 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 195 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/srcu.h b/include/linux/srcu.h
> index aca0eee..a7e1505 100644
> --- a/include/linux/srcu.h
> +++ b/include/linux/srcu.h
> @@ -50,4 +50,9 @@ void srcu_read_unlock(struct srcu_struct *sp, int idx) __releases(sp);
>  void synchronize_srcu(struct srcu_struct *sp);
>  long srcu_batches_completed(struct srcu_struct *sp);
>  
> +extern void rcu_read_lock_fgp(void);
> +extern void rcu_read_unlock_fgp(void);
> +extern void synchronize_rcu_fgp(void);
> +extern long rcu_fgp_batches_completed(void);
> +
>  #endif
> diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
> index 9b4a975..5a8c744 100644
> --- a/kernel/rcutorture.c
> +++ b/kernel/rcutorture.c
> @@ -462,6 +462,46 @@ static struct rcu_torture_ops rcu_bh_sync_ops = {
>  };
>  
>  /*
> + * Definitions for fgp torture testing.
> + */
> +
> +static int rcu_fgp_torture_read_lock(void) __acquires(RCU_FGP)
> +{
> +	rcu_read_lock_fgp();
> +	return 0;
> +}
> +
> +static void rcu_fgp_torture_read_unlock(int idx) __releases(RCU_FGP)
> +{
> +	rcu_read_unlock_fgp();
> +}
> +
> +static int rcu_fgp_torture_completed(void)
> +{
> +	return rcu_fgp_batches_completed();
> +}
> +
> +static void rcu_fgp_torture_synchronize(void)
> +{
> +	synchronize_rcu_fgp();
> +}
> +
> +static struct rcu_torture_ops rcu_fgp_ops = {
> +	.init = rcu_sync_torture_init,
> +	.cleanup = NULL,
> +	.readlock = rcu_fgp_torture_read_lock,
> +	.readdelay = rcu_read_delay,
> +	.readunlock = rcu_fgp_torture_read_unlock,
> +	.completed = rcu_fgp_torture_completed,
> +	.deferredfree = rcu_sync_torture_deferred_free,
> +	.sync = rcu_fgp_torture_synchronize,
> +	.cb_barrier = NULL,
> +	.stats = NULL,
> +	.irqcapable = 1,
> +	.name = "rcu_fgp"
> +};
> +
> +/*
>   * Definitions for srcu torture testing.
>   */
>  
> @@ -1078,7 +1118,7 @@ rcu_torture_init(void)
>  	int firsterr = 0;
>  	static struct rcu_torture_ops *torture_ops[] =
>  		{ &rcu_ops, &rcu_sync_ops, &rcu_bh_ops, &rcu_bh_sync_ops,
> -		  &srcu_ops, &sched_ops, &sched_ops_sync, };
> +		  &rcu_fgp_ops, &srcu_ops, &sched_ops, &sched_ops_sync, };
>  
>  	mutex_lock(&fullstop_mutex);
>  
> diff --git a/kernel/srcu.c b/kernel/srcu.c
> index b0aeeaf..08dcdb2 100644
> --- a/kernel/srcu.c
> +++ b/kernel/srcu.c
> @@ -33,6 +33,7 @@
>  #include <linux/slab.h>
>  #include <linux/smp.h>
>  #include <linux/srcu.h>
> +#include <linux/delay.h>
>  
>  /**
>   * init_srcu_struct - initialize a sleep-RCU structure
> @@ -255,3 +256,151 @@ EXPORT_SYMBOL_GPL(srcu_read_lock);
>  EXPORT_SYMBOL_GPL(srcu_read_unlock);
>  EXPORT_SYMBOL_GPL(synchronize_srcu);
>  EXPORT_SYMBOL_GPL(srcu_batches_completed);
> +
> +/* Single bit for grace-period index, low-order bits are nesting counter. */
> +#define RCU_FGP_COUNT		1UL
> +#define RCU_FGP_PARITY		(1UL << (sizeof(long) << 2))
> +#define RCU_FGP_NEST_MASK	(RCU_FGP_PARITY - 1)
> +
> +static DEFINE_MUTEX(rcu_fgp_mutex);
> +static long rcu_fgp_ctr = RCU_FGP_COUNT;  /* Include nesting count of 1. */
> +static long rcu_fgp_completed;
> +static DEFINE_PER_CPU(long, rcu_fgp_active_readers);
> +
> +/**
> + * rcu_read_lock_fgp - Start a new RCU fast-grace-period (FGP) reader
> + *
> + * Updates the per-CPU state to note the new reader.  Callable from
> + * pretty much any context in which the CPU is actually running.
> + */
> +void rcu_read_lock_fgp(void)
> +{
> +	long tmp;
> +	long *uarp;
> +
> +	preempt_disable();
> +	uarp = &__get_cpu_var(rcu_fgp_active_readers);
> +	tmp = *uarp;
> +	if (likely(!(tmp & RCU_FGP_NEST_MASK)))
> +		*uarp = rcu_fgp_ctr;  /* Outermost rcu_read_lock(). */
> +	else
> +		*uarp = tmp + RCU_FGP_COUNT;  /* Nested rcu_read_lock(). */
> +	barrier();  /* promoted to smp_mb() by rcu_fgp_do_mb(). */
> +}
> +EXPORT_SYMBOL_GPL(rcu_read_lock_fgp);
> +
> +/**
> + * rcu_read_unlock_fgp - End an RCU fast-grace-period (FGP) reader
> + *
> + * Updates the per-CPU state to note the old reader is done.  Callable from
> + * pretty much any context in which the CPU is actually running.
> + */
> +void rcu_read_unlock_fgp(void)
> +{
> +	barrier();  /* promoted to smp_mb() by rcu_fgp_do_mb(). */
> +	__get_cpu_var(rcu_fgp_active_readers) -= RCU_FGP_COUNT;
> +	preempt_enable();
> +}
> +EXPORT_SYMBOL_GPL(rcu_read_unlock_fgp);
> +
> +/*
> + * Determine if the specified counter value indicates that we need to
> + * wait on the corresponding CPU to exit an rcu_fgp read-side critical
> + * section.  Return non-zero if so.
> + *
> + * Assumes that rcu_fgp_mutex is held, and thus that rcu_fgp_ctr is
> + * unchanging.
> + */
> +static inline int rcu_old_fgp_ongoing(long *value)
> +{
> +	long v = ACCESS_ONCE(*value);
> +
> +	return (v & RCU_FGP_NEST_MASK) &&
> +	       ((v ^ rcu_fgp_ctr) & RCU_FGP_PARITY);
> +}
> +
> +/*
> + * Spin on each CPU until it finishes any pre-existing RCU read-side
> + * critical sections.  We don't have to worry about CPU hotplug,
> + * because readers have preemption disabled, which in turn disables
> + * CPU hotplug throughout all the read-side critical sections.  So
> + * CPUs cannot disappear partway through a read-side critical section.
> + */
> +static void rcu_fgp_wait_for_quiescent_state(void)
> +{
> +	int cpu;
> +	int i;
> +	unsigned long stopat;
> +	long *uarp;
> +
> +	for_each_online_cpu(cpu) {
> +		uarp = &per_cpu(rcu_fgp_active_readers, cpu);
> +		i = 0;
> +		stopat = jiffies;
> +		while (rcu_old_fgp_ongoing(uarp)) {
> +			if (jiffies - stopat > 10) {
> +				printk(KERN_ALERT
> +				       "rcu_fgp cpu %d stall (gp %ld) v=%lx\n",
> +				       cpu, rcu_fgp_completed, *uarp);
> +				stopat = jiffies;
> +			}
> +			if (++i < 5)
> +				udelay(10);
> +			else {
> +				i = 0;
> +				schedule_timeout_uninterruptible(1);
> +			}
> +		}
> +	}
> +}
> +
> +static void rcu_fgp_do_mb(void *unused)
> +{
> +	smp_mb();  /* Promotes barrier() to smp_mb() on other CPUs. */
> +}
> +
> +/**
> + * synchronize_rcu_fgp - Wait for an RCU FGP grace period
> + *
> + * Wait for all pre-existing RCU fast-grace-period (FGP) readers to complete.
> + */
> +void synchronize_rcu_fgp(void)
> +{
> +	mutex_lock(&rcu_fgp_mutex);
> +	
> +	/* CPUs must see earlier change before parity flip. */
> +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> +

Hrm, my original comment about missing smp_mb() here still applies, I
don't think we have come to an agreement yet.

> +	/*
> +	 * We must flip twice to correctly handle tasks that stall
> +	 * in rcu_read_lock_fgp() between the time that they fetch
> +	 * rcu_fgp_ctr and the time that the store to their CPU's
> +	 * rcu_fgp_active_readers.  No matter when they resume
> +	 * execution, we will wait for them to get to the corresponding
> +	 * rcu_read_unlock_fgp().
> +	 */
> +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 0 -> 1 */
> +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 1 -> 0 */
> +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> +
> +	/* Prevent CPUs from reordering out of prior RCU critical sections. */
> +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> +

Same here.

So we would need to either add a smp_mb() at both of these locations, or
use on_each_cpu() rather than smp_call_function. Note that this is to
ensure that the "updater" thread executes these memory barriers.

Mathieu


> +	rcu_fgp_completed++;
> +	mutex_unlock(&rcu_fgp_mutex);
> +}
> +EXPORT_SYMBOL_GPL(synchronize_rcu_fgp);
> +
> +/**
> + * rcu_fgp_batches_completed - return batches completed.
> + * @sp: srcu_struct on which to report batch completion.
> + *
> + * Report the number of batches, correlated with, but not necessarily
> + * precisely the same as, the number of grace periods that have elapsed.
> + */
> +long rcu_fgp_batches_completed(void)
> +{
> +	return rcu_fgp_completed;
> +}
> +EXPORT_SYMBOL_GPL(rcu_fgp_batches_completed);

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
