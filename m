From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Mon, 25 May 2009 09:44:46 -0700
Message-ID: <20090525164446.GD7168@linux.vnet.ibm.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:48859 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039AbZEYQok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2009 12:44:40 -0400
Content-Disposition: inline
In-Reply-To: <4A1A3C23.8090004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2009 at 02:35:15PM +0800, Lai Jiangshan wrote:
> Paul E. McKenney wrote:
> > Seventh cut of "big hammer" expedited RCU grace periods.  This leverages
> > the existing per-CPU migration kthreads, as suggested by Ingo.  These
> > are awakened in a loop, and waited for in a second loop.  Not fully
> > scalable, but removing the extra hop through smp_call_function
> > reduces latency on systems with moderate numbers of CPUs.  The
> > synchronize_rcu_expedited() and and synchronize_bh_expedited() primitives
> > invoke synchronize_sched_expedited(), except for CONFIG_PREEMPT_RCU,
> > where they instead invoke synchronize_rcu() and synchronize_rcu_bh(),
> > respectively.  This will be fixed in the future, after preemptable RCU
> > is folded into the rcutree implementation.
> > 
> 
> I'm strongly need this guarantee:
> 
> preempt_disable() guarantees/implies rcu_read_lock().
> 
> And
> local_irq_diable() guarantees/implies rcu_read_lock().
> rcu_read_lock_bh() guarantees/implies rcu_read_lock().
> 
> 
> It will simplifies codes.

Hmmm...  I did produce a patch that modified preemptable RCU
in this way quite some time back, but at that time the problem
was solved in a different way.  The approach was either to add
rcu_read_lock()/rcu_read_unlock() pairs as needed, or to switch to
call_rcu_sched() or synchronize_sched() for the update side.

But please note that this approach would not permit the current
implementation of synchronize_sched_expedited() to be used in the
preemptable-RCU case, because synchronize_sched_expedited() would
not wait for RCU read-side critical sections that had been preempted.
And the ability to preempt RCU read-side critical sections is absolutely
required for CONFIG_PREEMPT_RT versions of the Linux kernel.

> And
> A lot's of current kernel code does not use rcu_read_lock()
> when it has preempt_disable()-ed/local_irq_diable()-ed or
> when it is in irq/softirq.
> 
> Without these guarantees, these code is broken.

One way or another, such code does need to be fixed.  Either by
reintroducing the old patch, or by fixing the code itself.

> > +
> > +static DEFINE_PER_CPU(struct migration_req, rcu_migration_req);
> > +static DEFINE_MUTEX(rcu_sched_expedited_mutex);
> > +
> > +/*
> > + * Wait for an rcu-sched grace period to elapse, but use "big hammer"
> > + * approach to force grace period to end quickly.  This consumes
> > + * significant time on all CPUs, and is thus not recommended for
> > + * any sort of common-case code.
> > + */
> > +void synchronize_sched_expedited(void)
> > +{
> > +	int cpu;
> > +	unsigned long flags;
> > +	struct rq *rq;
> > +	struct migration_req *req;
> > +
> > +	mutex_lock(&rcu_sched_expedited_mutex);
> > +	get_online_cpus();
> > +	for_each_online_cpu(cpu) {
> > +		rq = cpu_rq(cpu);
> > +		req = &per_cpu(rcu_migration_req, cpu);
> > +		init_completion(&req->done);
> > +		req->task = NULL;
> > +		req->dest_cpu = -1;
> > +		spin_lock_irqsave(&rq->lock, flags);
> > +		list_add(&req->list, &rq->migration_queue);
> > +		spin_unlock_irqrestore(&rq->lock, flags);
> > +		wake_up_process(rq->migration_thread);
> > +	}
> > +	for_each_online_cpu(cpu) {
> > +		req = &per_cpu(rcu_migration_req, cpu);
> > +		wait_for_completion(&req->done);
> > +	}
> > +	put_online_cpus();
> > +	mutex_unlock(&rcu_sched_expedited_mutex);
> > +}
> > +EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
> > +
> > +#endif /* #else #ifndef CONFIG_SMP */
> > 
> > 
> 
> Very nice implement!

Glad you like it!!!  The idea is Ingo's.

Gah!!!  I need to have included a Suggested-by on v7 of the patch!!!

> Only one opinion:
> get_online_cpus() is a large lock, a lot's of lock in kernel is required
> after cpu_hotplug.lock.
> 
> _cpu_down()
> 	cpu_hotplug_begin()
> 		mutex_lock(&cpu_hotplug.lock)
> 	__raw_notifier_call_chain(CPU_DOWN_PREPARE)
> 		Lock a-kernel-lock.
> 
> It means when we have held a-kernel-lock, we can not call
> synchronize_sched_expedited(). get_online_cpus() narrows
> synchronize_sched_expedited()'s usages.
> 
> I think we can reuse req->dest_cpu and remove get_online_cpus().
> (and use preempt_disable() and for_each_possible_cpu())
> 
> req->dest_cpu = -2 means @req is not queued
> req->dest_cpu = -1 means @req is queued
> 
> a little like this code:
> 
> 	mutex_lock(&rcu_sched_expedited_mutex);
> 	for_each_possible_cpu(cpu) {
> 		preempt_disable()
> 		if (cpu is not online)
> 			just set req->dest_cpu to -2;
> 		else
> 			init and queue req, and wake_up_process().
> 		preempt_enable()
> 	}
> 	for_each_possible_cpu(cpu) {
> 		if (req is queued)
> 			wait_for_completion().
> 	}
> 	mutex_unlock(&rcu_sched_expedited_mutex);

Good point -- I should at the very least add a comment to
synchronize_sched_expedited() stating that it cannot be called holding
any lock that is acquired in a CPU hotplug notifier.  If this restriction
causes any problems, then your approach seems like a promising fix.

> The coupling of synchronize_sched_expedited() and migration_req
> is largely increased:
> 
> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
>    See migration_call::CPU_DEAD

Good.  ;-)

> 2) migration_call() is the highest priority of cpu notifiers,
>    So even any other cpu notifier calls synchronize_sched_expedited(),
>    It'll not cause DEADLOCK.

You mean if using your preempt_disable() approach, right?  Unless I am
missing something, the current get_online_cpus() approach would deadlock
in this case.

							Thanx, Paul
