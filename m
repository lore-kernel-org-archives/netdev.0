From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Mon, 25 May 2009 14:35:15 +0800
Message-ID: <4A1A3C23.8090004@cn.fujitsu.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090522190525.GA13286@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> Seventh cut of "big hammer" expedited RCU grace periods.  This leverages
> the existing per-CPU migration kthreads, as suggested by Ingo.  These
> are awakened in a loop, and waited for in a second loop.  Not fully
> scalable, but removing the extra hop through smp_call_function
> reduces latency on systems with moderate numbers of CPUs.  The
> synchronize_rcu_expedited() and and synchronize_bh_expedited() primitives
> invoke synchronize_sched_expedited(), except for CONFIG_PREEMPT_RCU,
> where they instead invoke synchronize_rcu() and synchronize_rcu_bh(),
> respectively.  This will be fixed in the future, after preemptable RCU
> is folded into the rcutree implementation.
> 

I'm strongly need this guarantee:

preempt_disable() guarantees/implies rcu_read_lock().

And
local_irq_diable() guarantees/implies rcu_read_lock().
rcu_read_lock_bh() guarantees/implies rcu_read_lock().


It will simplifies codes.

And
A lot's of current kernel code does not use rcu_read_lock()
when it has preempt_disable()-ed/local_irq_diable()-ed or
when it is in irq/softirq.

Without these guarantees, these code is broken.

> +
> +static DEFINE_PER_CPU(struct migration_req, rcu_migration_req);
> +static DEFINE_MUTEX(rcu_sched_expedited_mutex);
> +
> +/*
> + * Wait for an rcu-sched grace period to elapse, but use "big hammer"
> + * approach to force grace period to end quickly.  This consumes
> + * significant time on all CPUs, and is thus not recommended for
> + * any sort of common-case code.
> + */
> +void synchronize_sched_expedited(void)
> +{
> +	int cpu;
> +	unsigned long flags;
> +	struct rq *rq;
> +	struct migration_req *req;
> +
> +	mutex_lock(&rcu_sched_expedited_mutex);
> +	get_online_cpus();
> +	for_each_online_cpu(cpu) {
> +		rq = cpu_rq(cpu);
> +		req = &per_cpu(rcu_migration_req, cpu);
> +		init_completion(&req->done);
> +		req->task = NULL;
> +		req->dest_cpu = -1;
> +		spin_lock_irqsave(&rq->lock, flags);
> +		list_add(&req->list, &rq->migration_queue);
> +		spin_unlock_irqrestore(&rq->lock, flags);
> +		wake_up_process(rq->migration_thread);
> +	}
> +	for_each_online_cpu(cpu) {
> +		req = &per_cpu(rcu_migration_req, cpu);
> +		wait_for_completion(&req->done);
> +	}
> +	put_online_cpus();
> +	mutex_unlock(&rcu_sched_expedited_mutex);
> +}
> +EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
> +
> +#endif /* #else #ifndef CONFIG_SMP */
> 
> 

Very nice implement!

Only one opinion:
get_online_cpus() is a large lock, a lot's of lock in kernel is required
after cpu_hotplug.lock.

_cpu_down()
	cpu_hotplug_begin()
		mutex_lock(&cpu_hotplug.lock)
	__raw_notifier_call_chain(CPU_DOWN_PREPARE)
		Lock a-kernel-lock.

It means when we have held a-kernel-lock, we can not call
synchronize_sched_expedited(). get_online_cpus() narrows
synchronize_sched_expedited()'s usages.

I think we can reuse req->dest_cpu and remove get_online_cpus().
(and use preempt_disable() and for_each_possible_cpu())

req->dest_cpu = -2 means @req is not queued
req->dest_cpu = -1 means @req is queued

a little like this code:

	mutex_lock(&rcu_sched_expedited_mutex);
	for_each_possible_cpu(cpu) {
		preempt_disable()
		if (cpu is not online)
			just set req->dest_cpu to -2;
		else
			init and queue req, and wake_up_process().
		preempt_enable()
	}
	for_each_possible_cpu(cpu) {
		if (req is queued)
			wait_for_completion().
	}
	mutex_unlock(&rcu_sched_expedited_mutex);


The coupling of synchronize_sched_expedited() and migration_req
is largely increased:

1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
   See migration_call::CPU_DEAD

2) migration_call() is the highest priority of cpu notifiers,
   So even any other cpu notifier calls synchronize_sched_expedited(),
   It'll not cause DEADLOCK.

Lai.

