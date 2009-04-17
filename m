From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 22:19:02 -0400
Message-ID: <20090417021902.GC24956@Krystal>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754623AbZDQCYd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090417012812.GA25534@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> On Thu, Apr 16, 2009 at 04:49:55PM -0700, Paul E. McKenney wrote:
> > On Thu, Apr 16, 2009 at 03:33:54PM -0700, David Miller wrote:
> > > From: Patrick McHardy <kaber@trash.net>
> > > Date: Thu, 16 Apr 2009 15:11:31 +0200
> > > 
> > > > Linus Torvalds wrote:
> > > >> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
> > > >>> The counters are the bigger problem, otherwise we could just free
> > > >>> table
> > > >>> info via rcu.  Do we really have to support: replace where the counter
> > > >>> values coming out to user space are always exactly accurate, or is it
> > > >>> allowed to replace a rule and maybe lose some counter ticks (worst
> > > >>> case
> > > >>> NCPU-1).
> > > >> Why not just read the counters fromt he old one at RCU free time (they
> > > >> are guaranteed to be stable at that point, since we're all done with
> > > >> those entries), and apply them at that point to the current setup?
> > > > 
> > > > We need the counters immediately to copy them to userspace, so waiting
> > > > for an asynchronous RCU free is not going to work.
> > > 
> > > It just occurred to me that since all netfilter packet handling
> > > goes through one place, we could have a sort-of "netfilter RCU"
> > > of sorts to solve this problem.
> > 
> > OK, I am putting one together...
> > 
> > It will be needed sooner or later, though I suspect per-CPU locking
> > would work fine in this case.
> 
> And here is a crude first cut.  Untested, probably does not even compile.
> 
> Straight conversion of Mathieu Desnoyers's user-space RCU implementation
> at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did help
> a little, but he must bear the bulk of the guilt).

I'm innocent, I swear ;-)

That should give very impressive performance results.

Please see comments below,

>   Pick on srcu.h
> and srcu.c out of sheer laziness.  User-space testing gives deep
> sub-microsecond grace-period latencies, so should be fast enough, at
> least if you don't mind two smp_call_function() invocations per grace
> period and spinning on each instance of a per-CPU variable.
> 
> Again, I believe per-CPU locking should work fine for the netfilter
> counters, but I guess "friends don't let friends use hashed locks".
> (I would not know for sure, never having used them myself, except of
> course to protect hash tables.)
> 
> Most definitely -not- for inclusion at this point.  Next step is to hack
> up the relevant rcutorture code and watch it explode on contact.  ;-)
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> ---
> 
>  include/linux/srcu.h |   30 ++++++++++++++++++++++++
>  kernel/srcu.c        |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 93 insertions(+)
> 
> diff --git a/include/linux/srcu.h b/include/linux/srcu.h
> index aca0eee..4577cd0 100644
> --- a/include/linux/srcu.h
> +++ b/include/linux/srcu.h
> @@ -50,4 +50,34 @@ void srcu_read_unlock(struct srcu_struct *sp, int idx) __releases(sp);
>  void synchronize_srcu(struct srcu_struct *sp);
>  long srcu_batches_completed(struct srcu_struct *sp);
>  
> +/* Single bit for grace-period index, low-order bits are nesting counter. */
> +#define RCU_FGP_COUNT		1UL
> +#define RCU_FGP_PARITY		(1UL << (sizeof(long) << 2))
> +#define RCU_FGP_NEST_MASK	(RCU_FGP_PARITY - 1)
> +
> +extern long rcu_fgp_ctr;
> +DECLARE_PER_CPU(long, rcu_fgp_active_readers);
> +
> +static inline void rcu_read_lock_fgp(void)
> +{
> +	long tmp;
> +	long *uarp;
> +
> +	preempt_disable();
> +	uarp = &__get_cpu_var(rcu_fgp_active_readers);

OK, so we are translating the original implementation from per-thread to
per-cpu, with preemption disabled. Fine with me if we can't afford the
per-thread unsigned long nor can't afford to iterate on each thread when
waiting for RCU quiescent state.

> +	tmp = *uarp;
> +	if (likely(!(tmp & RCU_FGP_NEST_MASK)))
> +		*uarp = rcu_fgp_ctr;  /* Outermost rcu_read_lock(). */

ACCESS_ONCE(rcu_fgp_ctr) could not hurt here I think. Given the
surrounding code, that does not seem like a necessity, but that would
express that it is really an atomic read.

> +	else
> +		*uarp = tmp + RCU_FGP_COUNT;  /* Nested rcu_read_lock(). */
> +	barrier();

I kind of expect an IPI with a smp_mb() to promote this barrier() to a
smp_mb() when the update side needs to wait for a quiescent state. I
guess a comment telling this here would not hurt.

> +}
> +
> +static inline void rcu_read_unlock_fgp(void)
> +{
> +	barrier();

Same here.

> +	__get_cpu_var(rcu_fgp_active_readers)--;
> +	preempt_enable();
> +}
> +
>  #endif
> diff --git a/kernel/srcu.c b/kernel/srcu.c
> index b0aeeaf..a5dc464 100644
> --- a/kernel/srcu.c
> +++ b/kernel/srcu.c
> @@ -255,3 +255,66 @@ EXPORT_SYMBOL_GPL(srcu_read_lock);
>  EXPORT_SYMBOL_GPL(srcu_read_unlock);
>  EXPORT_SYMBOL_GPL(synchronize_srcu);
>  EXPORT_SYMBOL_GPL(srcu_batches_completed);
> +
> +DEFINE_MUTEX(rcu_fgp_mutex);
> +long rcu_fgp_ctr = RCU_FGP_COUNT;

Saying why we populate the value 1 here (RCU_FGP_COUNT) as an
optimization for the read-side might help understanding this choice.

> +DEFINE_PER_CPU(long, rcu_fgp_active_readers);
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
> +static void rcu_fgp_wait_for_quiescent_state(void)
> +{
> +	int cpu;
> +	long *uarp;
> +
> +	for_each_online_cpu(cpu) {
> +		uarp = &per_cpu(rcu_fgp_active_readers, cpu);
> +		while (rcu_old_fgp_ongoing(uarp))
> +			cpu_relax();

I would be tempted to add a comment here telling hot cpu hotunplug
cannot let us wait forever, given all read-side critical sections we can
be busy-waiting for are required to have preemption disabled, and are
therefore cpu-hotplug safe.

> +	}
> +}
> +
> +static void rcu_fgp_do_mb(void *unused)
> +{
> +	smp_mb();  /* Each CPU does a memory barrier. */
> +}

Ah, here it is. Commenting that it matches the two barrier()s I identified
above would be good.

> +
> +void synchronize_rcu_fgp(void)
> +{
> +	mutex_lock(&rcu_fgp_mutex);
> +	
> +	/* CPUs must see earlier change before parity flip. */
> +	smp_call_function(rcu_fgp_do_mb, NULL, 1);

/*
 * Call a function on all other processors
 */
int smp_call_function(void(*func)(void *info), void *info, int wait);

I guess you meant on_each_cpu ? That should include "self", given we
also need the smp_mb().

> +
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

Same as above.

Mathieu, who can still recognise his original userspace implementation
:-)

> +	mutex_unlock(&rcu_fgp_mutex);
> +}

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
