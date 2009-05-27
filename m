From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Tue, 26 May 2009 21:30:01 -0700
Message-ID: <20090527043001.GD6882@linux.vnet.ibm.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com> <20090526012843.GF7168@linux.vnet.ibm.com> <20090526154625.GA8662@linux.vnet.ibm.com> <4A1C9DFF.70708@cn.fujitsu.com>
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
In-Reply-To: <4A1C9DFF.70708@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2009 at 09:57:19AM +0800, Lai Jiangshan wrote:
> Paul E. McKenney wrote:
> > 
> > I am concerned about the following sequence of events:
> > 
> > o	synchronize_sched_expedited() disables preemption, thus blocking
> > 	offlining operations.
> > 
> > o	CPU 1 starts offlining CPU 0.  It acquires the CPU-hotplug lock,
> > 	and proceeds, and is now waiting for preemption to be enabled.
> > 
> > o	synchronize_sched_expedited() disables preemption, sees
> > 	that CPU 0 is online, so initializes and queues a request,
> > 	does a wake-up-process(), and finally does a preempt_enable().
> > 
> > o	CPU 0 is currently running a high-priority real-time process,
> > 	so the wakeup does not immediately happen.
> > 
> > o	The offlining process completes, including the kthread_stop()
> > 	to the migration task.
> > 
> > o	The migration task wakes up, sees kthread_should_stop(),
> > 	and so exits without checking its queue.
> > 
> > o	synchronize_sched_expedited() waits forever for CPU 0 to respond.
> > 
> > I suppose that one way to handle this would be to check for the CPU
> > going offline before doing the wait_for_completion(), but I am concerned
> > about races affecting this check as well.
> > 
> > Or is there something in the CPU-offline process that makes the above
> > sequence of events impossible?
> > 
> > 							Thanx, Paul
> > 
> > 
> 
> I realized this, I wrote this:
> > 
> > The coupling of synchronize_sched_expedited() and migration_req
> > is largely increased:
> > 
> > 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
> >    See migration_call::CPU_DEAD
> 
> synchronize_sched_expedited() will not wait for CPU#0, because
> migration_call()::case CPU_DEAD wakes up the requestors.
> 
> migration_call()
> {
> 	...
> 	case CPU_DEAD:
> 	case CPU_DEAD_FROZEN:
> 		...
> 		/*
> 		 * No need to migrate the tasks: it was best-effort if
> 		 * they didn't take sched_hotcpu_mutex. Just wake up
> 		 * the requestors.
> 		 */
> 		spin_lock_irq(&rq->lock);
> 		while (!list_empty(&rq->migration_queue)) {
> 			struct migration_req *req;
> 
> 			req = list_entry(rq->migration_queue.next,
> 					 struct migration_req, list);
> 			list_del_init(&req->list);
> 			spin_unlock_irq(&rq->lock);
> 			complete(&req->done);
> 			spin_lock_irq(&rq->lock);
> 		}
> 		spin_unlock_irq(&rq->lock);
> 		...
> 	...
> }
> 
> My approach depend on the requestors are waked up at any case.
> migration_call() does it for us but the coupling is largely
> increased.

OK, good point!  I do need to think about this.

In the meantime, where do you see a need to run
synchronize_sched_expedited() from within a hotplug CPU notifier?

						Thanx, Paul
