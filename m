From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Thu, 28 May 2009 17:08:48 -0700
Message-ID: <20090529000848.GE6757@linux.vnet.ibm.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com> <4A1B3FFB.7090306@cn.fujitsu.com> <20090526012843.GF7168@linux.vnet.ibm.com> <20090526154625.GA8662@linux.vnet.ibm.com> <4A1C9DFF.70708@cn.fujitsu.com> <20090527043001.GD6882@linux.vnet.ibm.com> <4A1CD17F.1000208@cn.fujitsu.com>
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
Received: from e9.ny.us.ibm.com ([32.97.182.139]:53586 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbZE2AIs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2009 20:08:48 -0400
Content-Disposition: inline
In-Reply-To: <4A1CD17F.1000208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2009 at 01:37:03PM +0800, Lai Jiangshan wrote:
> Paul E. McKenney wrote:
> > OK, good point!  I do need to think about this.
> > 
> > In the meantime, where do you see a need to run
> > synchronize_sched_expedited() from within a hotplug CPU notifier?
> > 
> > 						Thanx, Paul
> > 
> 
> I don't worry about synchronize_sched_expedited() called
> from within a hotplug CPU notifier:
> 
> 1st synchronize_sched_expedited() is newly, nobody calls it before current.
> 2nd get_online_cpus() will not cause DEADLOCK in CPU notifier:
> 	get_online_cpus() finds itself owns the cpu_hotplug.lock, it will
> 	not take it again.
> 
> I worry DEADLOCK like this:(ABBA DEADLOCK)

Good point -- you had in fact mentioned this earlier.

> > get_online_cpus() is a large lock, a lot's of lock in kernel is required
> > after cpu_hotplug.lock.
> > 
> > _cpu_down()
> > 	cpu_hotplug_begin()
> > 		mutex_lock(&cpu_hotplug.lock)
> > 	__raw_notifier_call_chain(CPU_DOWN_PREPARE)
> > 		Lock a-kernel-lock.
> > 
> > It means when we have held a-kernel-lock, we can not call
> > synchronize_sched_expedited(). get_online_cpus() narrows
> > synchronize_sched_expedited()'s usages.
> 
> One thread calls _cpu_down() which do "mutex_lock(&cpu_hotplug.lock)"
> and then do "Lock a-kernel-lock", other thread calls
> synchronize_sched_expedited() with a-kernel-lock held,
> ABBA DEADLOCK would happen:
> 
> thread 1                            |        thread 2
> _cpu_down()                         |    Lock a-kernel-lock. 
>   mutex_lock(&cpu_hotplug.lock)     |    synchronize_sched_expedited()
> ------------------------------------------------------------------------
>   Lock a-kernel-lock.(wait thread2) |       mutex_lock(&cpu_hotplug.lock)
>                                             (wait thread 1)
> 
> 
> cpuset_lock() is an example of a-kernel-lock as described before.
> cpuset_lock() is required in CPU notifier.
> 
> But some work in cpuset need get_online_cpus().
> (cpuset_lock() and then get_online_cpus(), we can
> not release cpuset_lock() temporarily)
> 
> The fix is putting this work done in workqueue.
> (get_online_cpus() and then cpuset_lock());

But there is another way.

Continue to use the migration kthreads, given that they already exist,
already are created and destroyed by CPU hotplug operations, and given
that they run as maximal priority.

My main concern with moving from get_online_cpus() to preempt_disable()
has been the thought that somehow, sometime, in some future release
of Linux, it will be possible for the migration threads to execute
on the wrong CPU, perhaps only occasionally and perhaps only for
very short time periods.  If this were to happen, there would be the
possibility that the grace period would end too soon, which would be
silently fatal.  My fingers simply refused to code something with this
potential vulnerability.

But it is easy to insert a check into migration_thread() to see if it
is running on the wrong CPU.  If it is, I can do a WARN_ONCE() and also
set a state variable to tell synchronize_sched_expedited() to invoke
sychronize_sched(), thus avoiding messing up RCU.  On the next call
to synchronize_sched_expedited(), it would again try relying on the
migration threads.

I am putting together yet another patch, but constructed along these
lines, and will let you know how it turns out.

							Thanx, Paul
