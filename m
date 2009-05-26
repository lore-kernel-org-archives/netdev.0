From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Tue, 26 May 2009 12:41:29 -0400
Message-ID: <20090526164129.GA19443@Krystal>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com> <20090526012843.GF7168@linux.vnet.ibm.com> <20090526154625.GA8662@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, jengelh@medozas.de, r000n@r000n.net,
	benh@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526154625.GA8662@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> On Mon, May 25, 2009 at 06:28:43PM -0700, Paul E. McKenney wrote:
> > On Tue, May 26, 2009 at 09:03:55AM +0800, Lai Jiangshan wrote:
> > > Paul E. McKenney wrote:
> > > > 
> > > > Good point -- I should at the very least add a comment to
> > > > synchronize_sched_expedited() stating that it cannot be called holding
> > > > any lock that is acquired in a CPU hotplug notifier.  If this restriction
> > > > causes any problems, then your approach seems like a promising fix.
> > > 
> > > Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> > 
> > Thank you very much for your review and comments!!!
> > 
> > > >> The coupling of synchronize_sched_expedited() and migration_req
> > > >> is largely increased:
> > > >>
> > > >> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
> > > >>    See migration_call::CPU_DEAD
> > > > 
> > > > Good.  ;-)
> > > > 
> > > >> 2) migration_call() is the highest priority of cpu notifiers,
> > > >>    So even any other cpu notifier calls synchronize_sched_expedited(),
> > > >>    It'll not cause DEADLOCK.
> > > > 
> > > > You mean if using your preempt_disable() approach, right?  Unless I am
> > > > missing something, the current get_online_cpus() approach would deadlock
> > > > in this case.
> > > 
> > > Yes, I mean if using my preempt_disable() approach. The current
> > > get_online_cpus() approach would NOT deadlock in this case also,
> > > we can require get_online_cpus() in cpu notifiers.
> > 
> > I have added the comment for the time being, but should people need to
> > use this in CPU-hotplug notifiers, then again your preempt_disable()
> > approach looks to be a promising fix.
> 
> I looked more closely at your preempt_disable() suggestion, which you
> presented earlier as follows:
> 
> > I think we can reuse req->dest_cpu and remove get_online_cpus().
> > (and use preempt_disable() and for_each_possible_cpu())
> > 
> > req->dest_cpu = -2 means @req is not queued
> > req->dest_cpu = -1 means @req is queued
> > 
> > a little like this code:
> > 
> > 	mutex_lock(&rcu_sched_expedited_mutex);
> > 	for_each_possible_cpu(cpu) {
> > 		preempt_disable()
> > 		if (cpu is not online)
> > 			just set req->dest_cpu to -2;
> > 		else
> > 			init and queue req, and wake_up_process().
> > 		preempt_enable()
> > 	}
> > 	for_each_possible_cpu(cpu) {
> > 		if (req is queued)
> > 			wait_for_completion().
> > 	}
> > 	mutex_unlock(&rcu_sched_expedited_mutex);
> 
> I am concerned about the following sequence of events:
> 
> o	synchronize_sched_expedited() disables preemption, thus blocking
> 	offlining operations.
> 
> o	CPU 1 starts offlining CPU 0.  It acquires the CPU-hotplug lock,
> 	and proceeds, and is now waiting for preemption to be enabled.
> 
> o	synchronize_sched_expedited() disables preemption, sees
> 	that CPU 0 is online, so initializes and queues a request,
> 	does a wake-up-process(), and finally does a preempt_enable().
> 
> o	CPU 0 is currently running a high-priority real-time process,
> 	so the wakeup does not immediately happen.
> 
> o	The offlining process completes, including the kthread_stop()
> 	to the migration task.
> 
> o	The migration task wakes up, sees kthread_should_stop(),
> 	and so exits without checking its queue.
> 
> o	synchronize_sched_expedited() waits forever for CPU 0 to respond.
> 
> I suppose that one way to handle this would be to check for the CPU
> going offline before doing the wait_for_completion(), but I am concerned
> about races affecting this check as well.
> 
> Or is there something in the CPU-offline process that makes the above
> sequence of events impossible?
> 

I think you are right, there is a problem there. The simple fact that
this needs to disable preemption to protect against cpu hotplug seems a
bit strange. If I may propose an alternate solution, which assumes that
threads pinned to a CPU are migrated to a different CPU when a CPU goes
offline (and will therefore execute anyway), and that a CPU brought
online after the first iteration on online cpus was already quiescent
(hopefully my assumptions are right). Preemption is left enabled during
all the critical section.

It looks a lot like Lai's approach, except that I use a cpumask (I
thought it looked cleaner and typically involves less operations than
looping on each possible cpu). I also don't disable preemption and
assume that cpu hotplug can happen at any point during this critical
section.

Something along the lines of :

static DECLARE_BITMAP(cpu_wait_expedited_bits, CONFIG_NR_CPUS);
const struct cpumask *const cpu_wait_expedited_mask =
			to_cpumask(cpu_wait_expedited_bits);

	mutex_lock(&rcu_sched_expedited_mutex);
	cpumask_clear(cpu_wait_expedited_mask);
	for_each_online_cpu(cpu) {
		init and queue cpu req, and wake_up_process().
		cpumask_set_cpu(cpu, cpu_wait_expedited_mask);
	}
	for_each_cpu_mask(cpu, cpu_wait_expedited_mask) {
		wait_for_completion(cpu req);
	}
	mutex_unlock(&rcu_sched_expedited_mutex);

There is one concern with this approach : if a CPU is hotunplugged and
hotplugged during the critical section, I think the scheduler would
migrate the thread to a different CPU (upon hotunplug) and let the
thread run on this other CPU. If the target CPU is hotplugged again,
this would mean the thread would have run on a different CPU than the
target. I think we can argue that a CPU going offline and online again
will meet quiescent state requirements, so this should not be a problem.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
