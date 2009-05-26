From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Tue, 26 May 2009 08:46:25 -0700
Message-ID: <20090526154625.GA8662@linux.vnet.ibm.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com> <20090526012843.GF7168@linux.vnet.ibm.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090526012843.GF7168@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2009 at 06:28:43PM -0700, Paul E. McKenney wrote:
> On Tue, May 26, 2009 at 09:03:55AM +0800, Lai Jiangshan wrote:
> > Paul E. McKenney wrote:
> > > 
> > > Good point -- I should at the very least add a comment to
> > > synchronize_sched_expedited() stating that it cannot be called holding
> > > any lock that is acquired in a CPU hotplug notifier.  If this restriction
> > > causes any problems, then your approach seems like a promising fix.
> > 
> > Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> Thank you very much for your review and comments!!!
> 
> > >> The coupling of synchronize_sched_expedited() and migration_req
> > >> is largely increased:
> > >>
> > >> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
> > >>    See migration_call::CPU_DEAD
> > > 
> > > Good.  ;-)
> > > 
> > >> 2) migration_call() is the highest priority of cpu notifiers,
> > >>    So even any other cpu notifier calls synchronize_sched_expedited(),
> > >>    It'll not cause DEADLOCK.
> > > 
> > > You mean if using your preempt_disable() approach, right?  Unless I am
> > > missing something, the current get_online_cpus() approach would deadlock
> > > in this case.
> > 
> > Yes, I mean if using my preempt_disable() approach. The current
> > get_online_cpus() approach would NOT deadlock in this case also,
> > we can require get_online_cpus() in cpu notifiers.
> 
> I have added the comment for the time being, but should people need to
> use this in CPU-hotplug notifiers, then again your preempt_disable()
> approach looks to be a promising fix.

I looked more closely at your preempt_disable() suggestion, which you
presented earlier as follows:

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

I am concerned about the following sequence of events:

o	synchronize_sched_expedited() disables preemption, thus blocking
	offlining operations.

o	CPU 1 starts offlining CPU 0.  It acquires the CPU-hotplug lock,
	and proceeds, and is now waiting for preemption to be enabled.

o	synchronize_sched_expedited() disables preemption, sees
	that CPU 0 is online, so initializes and queues a request,
	does a wake-up-process(), and finally does a preempt_enable().

o	CPU 0 is currently running a high-priority real-time process,
	so the wakeup does not immediately happen.

o	The offlining process completes, including the kthread_stop()
	to the migration task.

o	The migration task wakes up, sees kthread_should_stop(),
	and so exits without checking its queue.

o	synchronize_sched_expedited() waits forever for CPU 0 to respond.

I suppose that one way to handle this would be to check for the CPU
going offline before doing the wait_for_completion(), but I am concerned
about races affecting this check as well.

Or is there something in the CPU-offline process that makes the above
sequence of events impossible?

							Thanx, Paul
