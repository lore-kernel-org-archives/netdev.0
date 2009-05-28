From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Thu, 28 May 2009 16:52:49 -0700
Message-ID: <20090528235249.GD6757@linux.vnet.ibm.com>
References: <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com> <20090526012843.GF7168@linux.vnet.ibm.com> <20090526154625.GA8662@linux.vnet.ibm.com> <20090526164129.GA19443@Krystal> <20090526181352.GA7006@linux.vnet.ibm.com> <20090527014725.GD29692@Krystal> <20090527042749.GC6882@linux.vnet.ibm.com> <20090527144554.GB16459@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, jengelh@medozas.de, r000n@r000n.net,
	benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090527144554.GB16459@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2009 at 10:45:54AM -0400, Mathieu Desnoyers wrote:
> * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > On Tue, May 26, 2009 at 09:47:26PM -0400, Mathieu Desnoyers wrote:
> > > * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > > > On Tue, May 26, 2009 at 12:41:29PM -0400, Mathieu Desnoyers wrote:
> > > > > * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > > > > > On Mon, May 25, 2009 at 06:28:43PM -0700, Paul E. McKenney wrote:
> > > > > > > On Tue, May 26, 2009 at 09:03:55AM +0800, Lai Jiangshan wrote:
> > > > > > > > Paul E. McKenney wrote:
> > > > > > > > > 
> > > > > > > > > Good point -- I should at the very least add a comment to
> > > > > > > > > synchronize_sched_expedited() stating that it cannot be called holding
> > > > > > > > > any lock that is acquired in a CPU hotplug notifier.  If this restriction
> > > > > > > > > causes any problems, then your approach seems like a promising fix.
> > > > > > > > 
> > > > > > > > Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>
> > > > > > > 
> > > > > > > Thank you very much for your review and comments!!!
> > > > > > > 
> > > > > > > > >> The coupling of synchronize_sched_expedited() and migration_req
> > > > > > > > >> is largely increased:
> > > > > > > > >>
> > > > > > > > >> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
> > > > > > > > >>    See migration_call::CPU_DEAD
> > > > > > > > > 
> > > > > > > > > Good.  ;-)
> > > > > > > > > 
> > > > > > > > >> 2) migration_call() is the highest priority of cpu notifiers,
> > > > > > > > >>    So even any other cpu notifier calls synchronize_sched_expedited(),
> > > > > > > > >>    It'll not cause DEADLOCK.
> > > > > > > > > 
> > > > > > > > > You mean if using your preempt_disable() approach, right?  Unless I am
> > > > > > > > > missing something, the current get_online_cpus() approach would deadlock
> > > > > > > > > in this case.
> > > > > > > > 
> > > > > > > > Yes, I mean if using my preempt_disable() approach. The current
> > > > > > > > get_online_cpus() approach would NOT deadlock in this case also,
> > > > > > > > we can require get_online_cpus() in cpu notifiers.
> > > > > > > 
> > > > > > > I have added the comment for the time being, but should people need to
> > > > > > > use this in CPU-hotplug notifiers, then again your preempt_disable()
> > > > > > > approach looks to be a promising fix.
> > > > > > 
> > > > > > I looked more closely at your preempt_disable() suggestion, which you
> > > > > > presented earlier as follows:
> > > > > > 
> > > > > > > I think we can reuse req->dest_cpu and remove get_online_cpus().
> > > > > > > (and use preempt_disable() and for_each_possible_cpu())
> > > > > > > 
> > > > > > > req->dest_cpu = -2 means @req is not queued
> > > > > > > req->dest_cpu = -1 means @req is queued
> > > > > > > 
> > > > > > > a little like this code:
> > > > > > > 
> > > > > > > 	mutex_lock(&rcu_sched_expedited_mutex);
> > > > > > > 	for_each_possible_cpu(cpu) {
> > > > > > > 		preempt_disable()
> > > > > > > 		if (cpu is not online)
> > > > > > > 			just set req->dest_cpu to -2;
> > > > > > > 		else
> > > > > > > 			init and queue req, and wake_up_process().
> > > > > > > 		preempt_enable()
> > > > > > > 	}
> > > > > > > 	for_each_possible_cpu(cpu) {
> > > > > > > 		if (req is queued)
> > > > > > > 			wait_for_completion().
> > > > > > > 	}
> > > > > > > 	mutex_unlock(&rcu_sched_expedited_mutex);
> > > > > > 
> > > > > > I am concerned about the following sequence of events:
> > > > > > 
> > > > > > o	synchronize_sched_expedited() disables preemption, thus blocking
> > > > > > 	offlining operations.
> > > > > > 
> > > > > > o	CPU 1 starts offlining CPU 0.  It acquires the CPU-hotplug lock,
> > > > > > 	and proceeds, and is now waiting for preemption to be enabled.
> > > > > > 
> > > > > > o	synchronize_sched_expedited() disables preemption, sees
> > > > > > 	that CPU 0 is online, so initializes and queues a request,
> > > > > > 	does a wake-up-process(), and finally does a preempt_enable().
> > > > > > 
> > > > > > o	CPU 0 is currently running a high-priority real-time process,
> > > > > > 	so the wakeup does not immediately happen.
> > > > > > 
> > > > > > o	The offlining process completes, including the kthread_stop()
> > > > > > 	to the migration task.
> > > > > > 
> > > > > > o	The migration task wakes up, sees kthread_should_stop(),
> > > > > > 	and so exits without checking its queue.
> > > > > > 
> > > > > > o	synchronize_sched_expedited() waits forever for CPU 0 to respond.
> > > > > > 
> > > > > > I suppose that one way to handle this would be to check for the CPU
> > > > > > going offline before doing the wait_for_completion(), but I am concerned
> > > > > > about races affecting this check as well.
> > > > > > 
> > > > > > Or is there something in the CPU-offline process that makes the above
> > > > > > sequence of events impossible?
> > > > > > 
> > > > > 
> > > > > I think you are right, there is a problem there. The simple fact that
> > > > > this needs to disable preemption to protect against cpu hotplug seems a
> > > > > bit strange. If I may propose an alternate solution, which assumes that
> > > > > threads pinned to a CPU are migrated to a different CPU when a CPU goes
> > > > > offline (and will therefore execute anyway), and that a CPU brought
> > > > > online after the first iteration on online cpus was already quiescent
> > > > > (hopefully my assumptions are right). Preemption is left enabled during
> > > > > all the critical section.
> > > > > 
> > > > > It looks a lot like Lai's approach, except that I use a cpumask (I
> > > > > thought it looked cleaner and typically involves less operations than
> > > > > looping on each possible cpu). I also don't disable preemption and
> > > > > assume that cpu hotplug can happen at any point during this critical
> > > > > section.
> > > > > 
> > > > > Something along the lines of :
> > > > > 
> > > > > static DECLARE_BITMAP(cpu_wait_expedited_bits, CONFIG_NR_CPUS);
> > > > > const struct cpumask *const cpu_wait_expedited_mask =
> > > > > 			to_cpumask(cpu_wait_expedited_bits);
> > > > > 
> > > > > 	mutex_lock(&rcu_sched_expedited_mutex);
> > > > > 	cpumask_clear(cpu_wait_expedited_mask);
> > > > > 	for_each_online_cpu(cpu) {
> > > > > 		init and queue cpu req, and wake_up_process().
> > > > > 		cpumask_set_cpu(cpu, cpu_wait_expedited_mask);
> > > > > 	}
> > > > > 	for_each_cpu_mask(cpu, cpu_wait_expedited_mask) {
> > > > > 		wait_for_completion(cpu req);
> > > > > 	}
> > > > > 	mutex_unlock(&rcu_sched_expedited_mutex);
> > > > > 
> > > > > There is one concern with this approach : if a CPU is hotunplugged and
> > > > > hotplugged during the critical section, I think the scheduler would
> > > > > migrate the thread to a different CPU (upon hotunplug) and let the
> > > > > thread run on this other CPU. If the target CPU is hotplugged again,
> > > > > this would mean the thread would have run on a different CPU than the
> > > > > target. I think we can argue that a CPU going offline and online again
> > > > > will meet quiescent state requirements, so this should not be a problem.
> > > > 
> > > > Having the task runnable on some other CPU is very scary to me.  If the
> > > > CPU comes back online, and synchronize_sched_expedited() manages to
> > > > run before the task gets migrated back onto that CPU, then the grace
> > > > period could be ended too soon.
> > > > 
> > > 
> > > Well, the idea is that we want all in-flight preempt off sections (as
> > > seen at the beginning of synchronize_sched_expedited()) to be over
> > > before we consider the grace period as ended, right ?
> > > 
> > > Let's say we read the cpu online mask at a given time (potentially non
> > > atomically, we don't really care).
> > > 
> > > If, at any point in time while we read the cpu online mask, a CPU
> > > appears to be offline, this means that it cannot hold any in-flight
> > > preempt off section.
> > > 
> > > Even if that specific CPU comes back online after this moment, and
> > > starts scheduling threads again, these threads cannot ever possibly be
> > > in-flight in the old grace period.
> > > 
> > > Therefore, my argument is that for rcu_sched (classic rcu), a CPU going
> > > back online while we wait for quiescent state cannot possibly ever start
> > > running a thread in the previous grace period.
> > > 
> > > My second argument is that if a CPU is hotunplugging while we wait for
> > > QS, either :
> > > 
> > > - It lets the completion thread run before it goes offline. That's fine
> > > - It goes offline and the completion thread is migrated to another CPU.
> > >   This will just make synchronize_sched_expedited() wait for one more
> > >   completion that will execute on the CPU the thread has migrated to.
> > >   Again, we don't care.
> > > - It goes offline/online/offline/online/... : We go back to my first
> > >   argument, which states that if a CPU is out of the cpu online mask at
> > >   any given time after we started the synchronize_sched_expedited()
> > >   execution, it cannot possibly hold an in-flight preempt off section
> > >   belonging to the old GP.
> > > 
> > > Or am I missing something ?
> > 
> > I am worried (perhaps unnecessarily) about the CPU coming online,
> > its kthread still running on some other CPU, someone doing a
> > synchronize_sched_expedited(), which then might possibly complete before
> > the kthread migrates back where it belongs.  If the newly onlined CPU is
> > in an extended RCU read-side critical section, we might end the expedited
> > grace period too soon.
> > 
> > My turn.  Am I missing something?  ;-)
> > 
> 
> If the completion kthreads only live within the boundary of the 
> rcu_sched_expedited_mutex critical section, we never face this problem.
> 
> Therefore, all kthreads created for a given expedited grace period
> should be waited for before the rcu_sched_expedited_mutex is released.

True, but the overhead of creating (say) 100 kthreads is not so consistent
with the "expedited" in synchronize_sched_expedited().

> Here, I don't know the specific behavior of the threads you are willing
> to use, but I see two possibilities when facing cpu hotplug :
> 
> - Either those threads are always active in the system, _really_ tied to
>   a CPU and the hotunplug event kills them and sends their completion.
>   (this is I think what Lai described)

Yep.  And this is what v7 of the patch did.  Lai would like me to get
rid of the get_online_cpus(), replacing it with preempt_disable().
Which I find to be incredibly scary, given the possibility of the
kthread somehow executing on some other CPU, thus breaking RCU.

But see my next reply to Lai.

> - Or we create them while holding the rcu_sched_expedited_mutex, pin
>   them to a CPU. They are less strictly bound to a CPU and get migrated
>   to a different CPU upon hotunplug. Note that their life-span is
>   limited to the rcu_sched_expedited_mutex section, because we expect
>   them to die after completion. This implies a thread creation overhead.

And the thread-creation/destruction overhead is fatal, I believe.

> Hopefully one of the solutions I describe above match the current
> implementation. :)

#1.  ;-)

							Thanx, Paul

> Mathieu
> 
> 
> 
> > 						Thanx, Paul
> > 
> > > Mathieu
> > > 
> > > 
> > > > All of this is intended to make synchronize_sched_expedited() be able to
> > > > run in a CPU hotplug notifier.  Do we have an example where someone
> > > > really wants to do this?  If not, I am really starting to like v7 of
> > > > the patch.  ;-)
> > > > 
> > > > If someone really does need to run synchronize_sched_expedited() from a
> > > > CPU hotplug notifier, perhaps a simpler approach is to have something
> > > > like a try_get_online_cpus(), and just invoke synchronize_sched() upon
> > > > failure:
> > > > 
> > > > 	void synchronize_sched_expedited(void)
> > > > 	{
> > > > 		int cpu;
> > > > 		unsigned long flags;
> > > > 		struct rq *rq;
> > > > 		struct migration_req *req;
> > > > 
> > > > 		mutex_lock(&rcu_sched_expedited_mutex);
> > > > 		if (!try_get_online_cpus()) {
> > > > 			synchronize_sched();
> > > > 			return;
> > > > 		}
> > > > 
> > > > 		/* rest of synchronize_sched_expedited()... */
> > > > 
> > > > But I would want to see a real need for this beforehand.
> > > > 
> > > > 							Thanx, Paul
> > > 
> > > -- 
> > > Mathieu Desnoyers
> > > OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
