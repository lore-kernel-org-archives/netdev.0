From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH diagnostic] Re: HPET regression in 2.6.26 versus 2.6.25
	-- RCU problem
Date: Sun, 10 Aug 2008 18:38:09 -0700
Message-ID: <20080811013808.GA4242@linux.vnet.ibm.com>
References: <630464.55583.qm@web82105.mail.mud.yahoo.com> <20080810151520.GG8125@linux.vnet.ibm.com> <20080811013538.GA3958@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jRHKVT23PllUwdXP"
Cc: Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:50234 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbYHKBiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 21:38:06 -0400
Content-Disposition: inline
In-Reply-To: <20080811013538.GA3958@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jRHKVT23PllUwdXP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 10, 2008 at 06:35:38PM -0700, Paul E. McKenney wrote:
> On Sun, Aug 10, 2008 at 08:15:20AM -0700, Paul E. McKenney wrote:
> > I will see about putting together a diagnostic patch for Classic RCU.
> > The approach will be to record jiffies (or some such) at the beginning
> > of the grace period (in rcu_start_batch()), then have
> > rcu_check_callbacks() complain if:
> > 
> > 1.	it is running on a CPU that has holding up grace periods for
> > 	a long time (say one second).  This will identify the culprit
> > 	assuming that the culprit has not disabled hardware irqs,
> > 	instruction execution, or some such.
> > 
> > 2.	it is running on a CPU that is not holding up grace periods,
> > 	but grace periods have been held up for an even longer time
> > 	(say two seconds).
> > 
> > In either case, some sort of exponential backoff would be needed to
> > avoid multi-gigabyte log files.  Of course, all of this assumes that
> > the machine remains healthy enough to actually get any such messages
> > somewhere that you can see them, but so it goes...

And attached is the kernel module I used to test the patch, for whatever
that might be worth.

							Thanx, Paul

> And here is the patch.  It is still a bit raw, so the results should
> be viewed with some suspicion.  It adds a default-off kernel parameter
> CONFIG_RCU_CPU_STALL which must be enabled.
> 
> Rather than exponential backoff, it backs off to once per 30 seconds.
> My feeling upon thinking on it was that if you have stalled RCU grace
> periods for that long, a few extra printk() messages are probably the
> least of your worries...
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  include/linux/rcuclassic.h |    3 +
>  kernel/rcuclassic.c        |   80 +++++++++++++++++++++++++++++++++++++++++++++
>  lib/Kconfig.debug          |   13 +++++++
>  3 files changed, 96 insertions(+)
> 
> diff -urpNa -X dontdiff linux-2.6.27-rc1/include/linux/rcuclassic.h linux-2.6.27-rc1-cpustall/include/linux/rcuclassic.h
> --- linux-2.6.27-rc1/include/linux/rcuclassic.h	2008-07-30 08:48:16.000000000 -0700
> +++ linux-2.6.27-rc1-cpustall/include/linux/rcuclassic.h	2008-08-10 12:21:22.000000000 -0700
> @@ -46,6 +46,9 @@ struct rcu_ctrlblk {
>  	long	cur;		/* Current batch number.                      */
>  	long	completed;	/* Number of the last completed batch         */
>  	int	next_pending;	/* Is the next batch already waiting?         */
> +#ifdef CONFIG_RCU_CPU_STALL
> +	unsigned long gp_check;	/* Time grace period should end, in seconds.  */
> +#endif /* #ifdef CONFIG_RCU_CPU_STALL */
>  
>  	int	signaled;
>  
> diff -urpNa -X dontdiff linux-2.6.27-rc1/kernel/rcuclassic.c linux-2.6.27-rc1-cpustall/kernel/rcuclassic.c
> --- linux-2.6.27-rc1/kernel/rcuclassic.c	2008-07-30 08:48:17.000000000 -0700
> +++ linux-2.6.27-rc1-cpustall/kernel/rcuclassic.c	2008-08-10 17:51:32.000000000 -0700
> @@ -47,6 +47,7 @@
>  #include <linux/notifier.h>
>  #include <linux/cpu.h>
>  #include <linux/mutex.h>
> +#include <linux/time.h>
>  
>  #ifdef CONFIG_DEBUG_LOCK_ALLOC
>  static struct lock_class_key rcu_lock_key;
> @@ -269,6 +270,81 @@ static void rcu_do_batch(struct rcu_data
>   *   rcu_check_quiescent_state calls rcu_start_batch(0) to start the next grace
>   *   period (if necessary).
>   */
> +
> +#ifdef CONFIG_RCU_CPU_STALL
> +
> +static inline void record_gp_check_time(struct rcu_ctrlblk *rcp)
> +{
> +	rcp->gp_check = get_seconds() + 3;
> +}
> +static void print_other_cpu_stall(struct rcu_ctrlblk *rcp)
> +{
> +	int cpu;
> +	long delta;
> +
> +	/* Only let one CPU complain about others per time interval. */
> +
> +	spin_lock(&rcp->lock);
> +	delta = get_seconds() - rcp->gp_check;
> +	if (delta < 2L ||
> +	    cpus_empty(rcp->cpumask)) {
> +		spin_unlock(&rcp->lock);
> +		return;
> +	rcp->gp_check = get_seconds() + 30;
> +	}
> +	spin_unlock(&rcp->lock);
> +
> +	/* OK, time to rat on our buddy... */
> +
> +	printk(KERN_ERR "RCU detected CPU stalls:");
> +	for_each_cpu_mask(cpu, rcp->cpumask)
> +		printk(" %d", cpu);
> +	printk(" (detected by %d, t=%lu/%lu)\n",
> +	       smp_processor_id(), get_seconds(), rcp->gp_check);
> +}
> +static void print_cpu_stall(struct rcu_ctrlblk *rcp)
> +{
> +	printk(KERN_ERR "RCU detected CPU %d stall (t=%lu/%lu)\n",
> +			smp_processor_id(), get_seconds(), rcp->gp_check);
> +	dump_stack();
> +	spin_lock(&rcp->lock);
> +	if ((long)(get_seconds() - rcp->gp_check) >= 0L)
> +		rcp->gp_check = get_seconds() + 30;
> +	spin_unlock(&rcp->lock);
> +}
> +static inline void check_cpu_stall(struct rcu_ctrlblk *rcp,
> +				   struct rcu_data *rdp)
> +{
> +	long delta;
> +
> +	delta = get_seconds() - rcp->gp_check;
> +	if (cpu_isset(smp_processor_id(), rcp->cpumask) && delta >= 0L) {
> +
> +		/* We haven't checked in, so go dump stack. */
> +
> +		print_cpu_stall(rcp);
> +
> +	} else if (!cpus_empty(rcp->cpumask) && delta >= 2L) {
> +
> +		/* They had two seconds to dump stack, so complain. */
> +
> +		print_other_cpu_stall(rcp);
> +
> +	}
> +}
> +
> +#else /* #ifdef CONFIG_RCU_CPU_STALL */
> +
> +static inline void record_gp_check_time(struct rcu_ctrlblk *rcp)
> +{
> +}
> +static inline void check_cpu_stall(struct rcu_ctrlblk *rcp,
> +				   struct rcu_data *rdp)
> +{
> +}
> +
> +#endif /* #else #ifdef CONFIG_RCU_CPU_STALL */
> +
>  /*
>   * Register a new batch of callbacks, and start it up if there is currently no
>   * active batch and the batch to be registered has not already occurred.
> @@ -285,6 +361,7 @@ static void rcu_start_batch(struct rcu_c
>  		 */
>  		smp_wmb();
>  		rcp->cur++;
> +		record_gp_check_time(rcp);
>  
>  		/*
>  		 * Accessing nohz_cpu_mask before incrementing rcp->cur needs a
> @@ -468,6 +545,9 @@ static void rcu_process_callbacks(struct
>  
>  static int __rcu_pending(struct rcu_ctrlblk *rcp, struct rcu_data *rdp)
>  {
> +	/* Check for CPU stalls, if enabled. */
> +	check_cpu_stall(rcp, rdp);
> +
>  	/* This cpu has pending rcu entries and the grace period
>  	 * for them has completed.
>  	 */
> diff -urpNa -X dontdiff linux-2.6.27-rc1/lib/Kconfig.debug linux-2.6.27-rc1-cpustall/lib/Kconfig.debug
> --- linux-2.6.27-rc1/lib/Kconfig.debug	2008-07-30 08:48:17.000000000 -0700
> +++ linux-2.6.27-rc1-cpustall/lib/Kconfig.debug	2008-08-10 12:14:18.000000000 -0700
> @@ -597,6 +597,19 @@ config RCU_TORTURE_TEST_RUNNABLE
>  	  Say N here if you want the RCU torture tests to start only
>  	  after being manually enabled via /proc.
>  
> +config RCU_CPU_STALL
> +	bool "Check for stalled CPUs delaying RCU grace periods"
> +	depends on CLASSIC_RCU
> +	default n
> +	help
> +	  This option causes RCU to printk information on which
> +	  CPUs are delaying the current grace period, but only when
> +	  the grace period extends for excessive time periods.
> +
> +	  Say Y if you want RCU to perform such checks.
> +
> +	  Say N if you are unsure.
> +
>  config KPROBES_SANITY_TEST
>  	bool "Kprobes sanity tests"
>  	depends on DEBUG_KERNEL

--jRHKVT23PllUwdXP
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="stall.c"

/*
 * Taken from Linux Device Drivers, 3rd Edition.
 * Corbet, Rubini, and Kroah-Hartman.
 *
 * Modified by Paul E. McKenney (c) 2008 to test CPU-stall detection.
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/sched.h>
#include <linux/kthread.h>
#include <linux/err.h>
#include <linux/time.h>
MODULE_LICENSE("Dual BSD/GPL");

int stall_secs = 0;
module_param(stall_secs, int, 0);
MODULE_PARM_DESC(stall_secs, "Number of seconds to stall");

static struct task_struct *kstall_task;

static int stall_thread(void *arg)
{
	unsigned long stop_at;

	printk(KERN_ALERT "stall_thread %ld\n", (long)arg);
	do {
		stop_at = get_seconds();
		printk(KERN_ALERT "stall_thread at %ld seconds\n", stop_at);
		stop_at += stall_secs;
		printk(KERN_ALERT "stall_thread wait until %ld seconds\n", stop_at);
		while ((long)(get_seconds() - stop_at) < 0)
			continue;
		printk(KERN_ALERT "stall_thread ended wait at %ld seconds\n", get_seconds());
		set_current_state(TASK_UNINTERRUPTIBLE);
		schedule_timeout(10 * HZ);
		printk(KERN_ALERT "stall_thread %ld awakening\n", (long)arg);
	} while (!kthread_should_stop());
	printk(KERN_ALERT "stall_thread %ld exiting\n", (long)arg);
	return 0;
}

static int stall_init(void)
{
	int err;

	printk(KERN_ALERT "Hello, world!  stall_secs = %d\n", stall_secs);
	kstall_task = kthread_run(stall_thread, (void *)(long)stall_secs,
				  "stall_thread");
	if (IS_ERR(kstall_task)) {
		err = PTR_ERR(kstall_task);
		kstall_task = NULL;
		return err;
	}
	return 0;
}

static void stall_exit(void)
{
	if (kstall_task != NULL) {
		kthread_stop(kstall_task);
	}
	kstall_task = NULL;
	printk(KERN_ALERT "Goodbye, cruel world\n");
}

module_init(stall_init);
module_exit(stall_exit);

--jRHKVT23PllUwdXP--
