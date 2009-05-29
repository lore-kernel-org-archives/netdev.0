From: Gautham R Shenoy <ego@in.ibm.com>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Fri, 29 May 2009 17:36:37 +0530
Message-ID: <20090529120637.GA32184@in.ibm.com>
References: <20090518154241.GA27047@elte.hu> <20090518160254.GD6768@linux.vnet.ibm.com> <20090519085825.GA9388@elte.hu> <20090519123316.GA7159@linux.vnet.ibm.com> <20090519124436.GA6238@elte.hu> <20090519161839.GA6750@linux.vnet.ibm.com> <20090520080924.GA6736@elte.hu> <20090520153023.GB6729@linux.vnet.ibm.com> <20090527225705.GA2594@elte.hu> <20090529012251.GG6757@linux.vnet.ibm.com>
Reply-To: ego@in.ibm.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca, Nathan Lynch <ntl@pobox.com>,
	Srivatsa Vaddagiri <vatsa@in.ibm.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:60492 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758343AbZE2MG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 08:06:56 -0400
Content-Disposition: inline
In-Reply-To: <20090529012251.GG6757@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 28, 2009 at 06:22:51PM -0700, Paul E. McKenney wrote:
> 
> Hmmm...  Making the transition work nicely would require some thought.
> It might be good to retain the two-phase nature, even when reversing
> the order of offline notifications.  This would address one disadvantage
> of the past-life version, which was unnecessary migration of processes
> off of the CPU in question, only to find that a later notifier aborted
> the offlining.

The notifiers handling CPU_DEAD cannot abort it from here since the
operation has already completed, whether they like it or not!

If there exist notifiers which try to abort it from here, it's a BUG, as
the code says:

        /* CPU is completely dead: tell everyone.  Too late to complain.
	 * */
         if (raw_notifier_call_chain(&cpu_chain, CPU_DEAD | mod,
	                                     hcpu) == NOTIFY_BAD)
	                     BUG();

Also, one can thus consider the CPU_DEAD and the CPU_POST_DEAD parts to be
the extensions of the second phase. Just that we do some
additional cleanup once the CPU has actually gone down. migration of
processes (while breaking their affinity if required) is one of them.

But there are other things as well, such as rebuilding the sched-domain
which have to be done after the cpu has gone down. Currently this
operation contributes to majority of time taken to bring a cpu-offline.

>
> So only the first phase is permitted to abort the offlining of the CPU,
> and this first phase must also set whatever state is necessary to prevent
> some later operation from making it impossible to offline the CPU.
> The second phase would unconditionally take the CPU out of service.
> In theory, this approach would allow incremental conversion of the
> notifiers, waiting to remove the stop_machine stuff until all notifiers
> had been converted.
> If this actually works out, the sequence of changes would be as follows:
> 
> 1.	Reverse the order of the offline notifications, fixing any
> 	bugs induced/exposed by this change.
> 
> 2.	Incrementally convert notifiers to the new mechanism.  This
> 	will require more thought.
> 
> 3.	Get rid of the stop_machine and the CPU_DEAD once all are
> 	converted.

I agree with this sequence. It seems quite logical.

However, I am not yet sure if we can completely get rid of stop_machine
and CPU_DEAD in practice, unless we're okay with having an
time-consuming rollback operation. Currently the rollback only consists of
rolling back the actions done during CPU_UP_PREPARE/CPU_DOWN_PREPARE.

And from the notifiers profile (see attached file),
UP_PREPARE/DOWN_PREPARE seem to consume a lot lesser time
when compared to the post-hotplug notifications.

> 
> Or we might find that simply reversing the order (#1 above) suffices.
> 
> > > This meant that a given CPU was naturally guaranteed to be 
> > > correctly taking interrupts for the entire time that it was 
> > > capable of running user-level processes. Later in the offlining 
> > > process, it would still take interrupts, but would be unable to 
> > > run user processes.  Still later, it would no longer be taking 
> > > interrupts, and would stop participating in RCU and in the global 
> > > TLB-flush algorithm.  There was no need to stop the whole machine 
> > > to make a given CPU go offline, in fact, most of the work was done 
> > > by the CPU in question.
> > > 
> > > In the case of RCU, this meant that there was no need for 
> > > double-checking for offlined CPUs, because CPUs could reliably 
> > > indicate a quiescent state on their way out.
> > > 
> > > On the other hand, there was no equivalent of dynticks in the old 
> > > days. And it is dynticks that is responsible for most of the 
> > > complexity present in force_quiescent_state(), not CPU hotplug.
> > > 
> > > So I cannot hold up RCU as something that would be greatly 
> > > simplified by changing the CPU hotplug design, much as I might 
> > > like to.  ;-)
> > 
> > We could probably remove a fair bit of dynticks complexity by 
> > removing non-dynticks and removing non-hrtimer. People could still 
> > force a 'periodic' interrupting mode (if they want, or if their hw 
> > forces that), but that would be a plain periodic hrtimer firing off 
> > all the time.
> 
> Hmmm...  That would not simplify RCU much, but on the other hand (1) the
> rcutree.c dynticks approach is already quite a bit simpler than the
> rcupreempt.c approach and (2) doing this could potentially simplify
> other things.
> 
> 							Thanx, Paul
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

-- 
Thanks and Regards
gautham

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=cpu-hotplug-summary

=============================================================================
statistics for CPU_DOWN_PREPARE
=============================================================================
      410 ns: buffer_cpu_notify             : CPU_DOWN_PREPARE
      441 ns: radix_tree_callback           : CPU_DOWN_PREPARE
      473 ns: relay_hotcpu_callback         : CPU_DOWN_PREPARE
      486 ns: blk_cpu_notify                : CPU_DOWN_PREPARE
      563 ns: cpu_callback                  : CPU_DOWN_PREPARE
      579 ns: hotplug_hrtick                : CPU_DOWN_PREPARE
      594 ns: cpu_callback                  : CPU_DOWN_PREPARE
      605 ns: cpu_numa_callback             : CPU_DOWN_PREPARE
      611 ns: hrtimer_cpu_notify            : CPU_DOWN_PREPARE
      625 ns: flow_cache_cpu                : CPU_DOWN_PREPARE
      625 ns: rcu_barrier_cpu_hotplug       : CPU_DOWN_PREPARE
      639 ns: hotplug_cfd                   : CPU_DOWN_PREPARE
      641 ns: pageset_cpuup_callback        : CPU_DOWN_PREPARE
      656 ns: rb_cpu_notify                 : CPU_DOWN_PREPARE
      670 ns: dev_cpu_callback              : CPU_DOWN_PREPARE
      670 ns: topology_cpu_callback         : CPU_DOWN_PREPARE
      672 ns: remote_softirq_cpu_notify     : CPU_DOWN_PREPARE
      715 ns: ratelimit_handler             : CPU_DOWN_PREPARE
      715 ns: rcu_cpu_notify                : CPU_DOWN_PREPARE
      717 ns: timer_cpu_notify              : CPU_DOWN_PREPARE
      730 ns: page_alloc_cpu_notify         : CPU_DOWN_PREPARE
      746 ns: cpu_callback                  : CPU_DOWN_PREPARE
      821 ns: cpuset_track_online_cpus      : CPU_DOWN_PREPARE
      824 ns: slab_cpuup_callback           : CPU_DOWN_PREPARE
      849 ns: sysfs_cpu_notify              : CPU_DOWN_PREPARE
      884 ns: percpu_counter_hotcpu_callback: CPU_DOWN_PREPARE
      961 ns: update_runtime                : CPU_DOWN_PREPARE
     1323 ns: migration_call                : CPU_DOWN_PREPARE
     1918 ns: vmstat_cpuup_callback         : CPU_DOWN_PREPARE
     2072 ns: workqueue_cpu_callback        : CPU_DOWN_PREPARE
=========================================================================
Total time for CPU_DOWN_PREPARE = .023235000 ms
=========================================================================
=============================================================================
statistics for CPU_DYING
=============================================================================
      365 ns: remote_softirq_cpu_notify     : CPU_DYING
      365 ns: topology_cpu_callback         : CPU_DYING
      381 ns: blk_cpu_notify                : CPU_DYING
      381 ns: cpu_callback                  : CPU_DYING
      381 ns: relay_hotcpu_callback         : CPU_DYING
      381 ns: update_runtime                : CPU_DYING
      394 ns: dev_cpu_callback              : CPU_DYING
      395 ns: hotplug_cfd                   : CPU_DYING
      395 ns: vmstat_cpuup_callback         : CPU_DYING
      397 ns: cpuset_track_online_cpus      : CPU_DYING
      397 ns: flow_cache_cpu                : CPU_DYING
      397 ns: pageset_cpuup_callback        : CPU_DYING
      397 ns: rb_cpu_notify                 : CPU_DYING
      398 ns: hotplug_hrtick                : CPU_DYING
      410 ns: cpu_callback                  : CPU_DYING
      410 ns: page_alloc_cpu_notify         : CPU_DYING
      411 ns: rcu_cpu_notify                : CPU_DYING
      412 ns: slab_cpuup_callback           : CPU_DYING
      412 ns: sysfs_cpu_notify              : CPU_DYING
      412 ns: timer_cpu_notify              : CPU_DYING
      426 ns: buffer_cpu_notify             : CPU_DYING
      426 ns: radix_tree_callback           : CPU_DYING
      441 ns: cpu_callback                  : CPU_DYING
      442 ns: cpu_numa_callback             : CPU_DYING
      473 ns: ratelimit_handler             : CPU_DYING
      531 ns: percpu_counter_hotcpu_callback: CPU_DYING
      562 ns: workqueue_cpu_callback        : CPU_DYING
      730 ns: rcu_barrier_cpu_hotplug       : CPU_DYING
     1536 ns: migration_call                : CPU_DYING
     1873 ns: hrtimer_cpu_notify            : CPU_DYING
=========================================================================
Total time for CPU_DYING = .015331000 ms
=========================================================================
=============================================================================
statistics for CPU_DOWN_CANCELED
=============================================================================
=========================================================================
Total time for CPU_DOWN_CANCELED = 0 ms
=========================================================================
=============================================================================
statistics for __stop_machine
=============================================================================
   357983 ns: __stop_machine                :
=========================================================================
Total time for __stop_machine = .357983000 ms
=========================================================================
=============================================================================
statistics for CPU_DEAD
=============================================================================
      350 ns: update_runtime                : CPU_DEAD
      379 ns: hotplug_hrtick                : CPU_DEAD
      381 ns: cpu_callback                  : CPU_DEAD
      381 ns: rb_cpu_notify                 : CPU_DEAD
      426 ns: hotplug_cfd                   : CPU_DEAD
      426 ns: relay_hotcpu_callback         : CPU_DEAD
      441 ns: rcu_barrier_cpu_hotplug       : CPU_DEAD
      442 ns: remote_softirq_cpu_notify     : CPU_DEAD
      609 ns: ratelimit_handler             : CPU_DEAD
      625 ns: cpu_numa_callback             : CPU_DEAD
      684 ns: dev_cpu_callback              : CPU_DEAD
      686 ns: workqueue_cpu_callback        : CPU_DEAD
      838 ns: rcu_cpu_notify                : CPU_DEAD
      898 ns: pageset_cpuup_callback        : CPU_DEAD
     1202 ns: vmstat_cpuup_callback         : CPU_DEAD
     1295 ns: blk_cpu_notify                : CPU_DEAD
     1554 ns: buffer_cpu_notify             : CPU_DEAD
     2588 ns: hrtimer_cpu_notify            : CPU_DEAD
     3274 ns: radix_tree_callback           : CPU_DEAD
     5246 ns: timer_cpu_notify              : CPU_DEAD
     8587 ns: flow_cache_cpu                : CPU_DEAD
     8645 ns: topology_cpu_callback         : CPU_DEAD
    12454 ns: cpu_callback                  : CPU_DEAD
    12650 ns: cpu_callback                  : CPU_DEAD
    45727 ns: percpu_counter_hotcpu_callback: CPU_DEAD
    55242 ns: page_alloc_cpu_notify         : CPU_DEAD
    56766 ns: sysfs_cpu_notify              : CPU_DEAD
    58241 ns: slab_cpuup_callback           : CPU_DEAD
    78250 ns: migration_call                : CPU_DEAD
 10784759 ns: cpuset_track_online_cpus      : CPU_DEAD
=========================================================================
Total time for CPU_DEAD = 11.144046000 ms
=========================================================================
=============================================================================
statistics for CPU_POST_DEAD
=============================================================================
      350 ns: cpu_callback                  : CPU_POST_DEAD
      365 ns: blk_cpu_notify                : CPU_POST_DEAD
      365 ns: buffer_cpu_notify             : CPU_POST_DEAD
      365 ns: cpu_numa_callback             : CPU_POST_DEAD
      365 ns: dev_cpu_callback              : CPU_POST_DEAD
      365 ns: flow_cache_cpu                : CPU_POST_DEAD
      365 ns: hrtimer_cpu_notify            : CPU_POST_DEAD
      365 ns: page_alloc_cpu_notify         : CPU_POST_DEAD
      365 ns: rb_cpu_notify                 : CPU_POST_DEAD
      365 ns: rcu_cpu_notify                : CPU_POST_DEAD
      365 ns: timer_cpu_notify              : CPU_POST_DEAD
      365 ns: update_runtime                : CPU_POST_DEAD
      366 ns: cpu_callback                  : CPU_POST_DEAD
      366 ns: hotplug_cfd                   : CPU_POST_DEAD
      366 ns: pageset_cpuup_callback        : CPU_POST_DEAD
      366 ns: radix_tree_callback           : CPU_POST_DEAD
      367 ns: hotplug_hrtick                : CPU_POST_DEAD
      367 ns: topology_cpu_callback         : CPU_POST_DEAD
      367 ns: vmstat_cpuup_callback         : CPU_POST_DEAD
      381 ns: cpu_callback                  : CPU_POST_DEAD
      381 ns: cpuset_track_online_cpus      : CPU_POST_DEAD
      381 ns: relay_hotcpu_callback         : CPU_POST_DEAD
      381 ns: sysfs_cpu_notify              : CPU_POST_DEAD
      383 ns: rcu_barrier_cpu_hotplug       : CPU_POST_DEAD
      410 ns: remote_softirq_cpu_notify     : CPU_POST_DEAD
      412 ns: slab_cpuup_callback           : CPU_POST_DEAD
      442 ns: migration_call                : CPU_POST_DEAD
      457 ns: percpu_counter_hotcpu_callback: CPU_POST_DEAD
      502 ns: ratelimit_handler             : CPU_POST_DEAD
    86200 ns: workqueue_cpu_callback        : CPU_POST_DEAD
=========================================================================
Total time for CPU_POST_DEAD = .097260000 ms
=========================================================================
=============================================================================
statistics for CPU_UP_PREPARE
=============================================================================
      336 ns: hotplug_hrtick                : CPU_UP_PREPARE
      350 ns: cpu_callback                  : CPU_UP_PREPARE
      365 ns: blk_cpu_notify                : CPU_UP_PREPARE
      381 ns: vmstat_cpuup_callback         : CPU_UP_PREPARE
      410 ns: buffer_cpu_notify             : CPU_UP_PREPARE
      410 ns: radix_tree_callback           : CPU_UP_PREPARE
      426 ns: dev_cpu_callback              : CPU_UP_PREPARE
      426 ns: remote_softirq_cpu_notify     : CPU_UP_PREPARE
      428 ns: cpuset_track_online_cpus      : CPU_UP_PREPARE
      441 ns: sysfs_cpu_notify              : CPU_UP_PREPARE
      471 ns: hotplug_cfd                   : CPU_UP_PREPARE
      472 ns: rb_cpu_notify                 : CPU_UP_PREPARE
      473 ns: flow_cache_cpu                : CPU_UP_PREPARE
      486 ns: page_alloc_cpu_notify         : CPU_UP_PREPARE
      488 ns: hrtimer_cpu_notify            : CPU_UP_PREPARE
      488 ns: update_runtime                : CPU_UP_PREPARE
      502 ns: rcu_barrier_cpu_hotplug       : CPU_UP_PREPARE
      531 ns: percpu_counter_hotcpu_callback: CPU_UP_PREPARE
      547 ns: ratelimit_handler             : CPU_UP_PREPARE
      594 ns: relay_hotcpu_callback         : CPU_UP_PREPARE
     1125 ns: rcu_cpu_notify                : CPU_UP_PREPARE
     1309 ns: pageset_cpuup_callback        : CPU_UP_PREPARE
     1947 ns: timer_cpu_notify              : CPU_UP_PREPARE
     5389 ns: cpu_numa_callback             : CPU_UP_PREPARE
     6379 ns: topology_cpu_callback         : CPU_UP_PREPARE
     6436 ns: slab_cpuup_callback           : CPU_UP_PREPARE
    19879 ns: cpu_callback                  : CPU_UP_PREPARE
    20227 ns: cpu_callback                  : CPU_UP_PREPARE
    33940 ns: migration_call                : CPU_UP_PREPARE
   143731 ns: workqueue_cpu_callback        : CPU_UP_PREPARE
=========================================================================
Total time for CPU_UP_PREPARE = .249387000 ms
=========================================================================
=============================================================================
statistics for CPU_UP_CANCELED
=============================================================================
=========================================================================
Total time for CPU_UP_CANCELED = 0 ms
=========================================================================
=============================================================================
statistics for __cpu_up
=============================================================================
205868908 ns: __cpu_up                      :
=========================================================================
Total time for __cpu_up = 205.868908000 ms
=========================================================================
=============================================================================
statistics for CPU_STARTING
=============================================================================
      350 ns: hotplug_cfd                   : CPU_STARTING
      352 ns: cpu_callback                  : CPU_STARTING
      352 ns: remote_softirq_cpu_notify     : CPU_STARTING
      363 ns: vmstat_cpuup_callback         : CPU_STARTING
      365 ns: cpu_callback                  : CPU_STARTING
      365 ns: dev_cpu_callback              : CPU_STARTING
      365 ns: hotplug_hrtick                : CPU_STARTING
      365 ns: radix_tree_callback           : CPU_STARTING
      365 ns: rb_cpu_notify                 : CPU_STARTING
      368 ns: update_runtime                : CPU_STARTING
      379 ns: cpu_callback                  : CPU_STARTING
      379 ns: cpu_numa_callback             : CPU_STARTING
      380 ns: rcu_barrier_cpu_hotplug       : CPU_STARTING
      380 ns: relay_hotcpu_callback         : CPU_STARTING
      381 ns: hrtimer_cpu_notify            : CPU_STARTING
      381 ns: pageset_cpuup_callback        : CPU_STARTING
      381 ns: slab_cpuup_callback           : CPU_STARTING
      382 ns: flow_cache_cpu                : CPU_STARTING
      394 ns: blk_cpu_notify                : CPU_STARTING
      397 ns: buffer_cpu_notify             : CPU_STARTING
      397 ns: percpu_counter_hotcpu_callback: CPU_STARTING
      397 ns: sysfs_cpu_notify              : CPU_STARTING
      397 ns: topology_cpu_callback         : CPU_STARTING
      410 ns: rcu_cpu_notify                : CPU_STARTING
      412 ns: page_alloc_cpu_notify         : CPU_STARTING
      426 ns: cpuset_track_online_cpus      : CPU_STARTING
      455 ns: ratelimit_handler             : CPU_STARTING
      471 ns: timer_cpu_notify              : CPU_STARTING
      516 ns: migration_call                : CPU_STARTING
      549 ns: workqueue_cpu_callback        : CPU_STARTING
=========================================================================
Total time for CPU_STARTING = .011874000 ms
=========================================================================
=============================================================================
statistics for CPU_ONLINE
=============================================================================
      365 ns: radix_tree_callback           : CPU_ONLINE
      379 ns: hotplug_hrtick                : CPU_ONLINE
      381 ns: hrtimer_cpu_notify            : CPU_ONLINE
      381 ns: remote_softirq_cpu_notify     : CPU_ONLINE
      410 ns: slab_cpuup_callback           : CPU_ONLINE
      410 ns: timer_cpu_notify              : CPU_ONLINE
      412 ns: blk_cpu_notify                : CPU_ONLINE
      426 ns: dev_cpu_callback              : CPU_ONLINE
      426 ns: flow_cache_cpu                : CPU_ONLINE
      426 ns: topology_cpu_callback         : CPU_ONLINE
      428 ns: rcu_barrier_cpu_hotplug       : CPU_ONLINE
      428 ns: rcu_cpu_notify                : CPU_ONLINE
      440 ns: buffer_cpu_notify             : CPU_ONLINE
      455 ns: pageset_cpuup_callback        : CPU_ONLINE
      457 ns: relay_hotcpu_callback         : CPU_ONLINE
      473 ns: rb_cpu_notify                 : CPU_ONLINE
      518 ns: update_runtime                : CPU_ONLINE
      549 ns: cpu_numa_callback             : CPU_ONLINE
      562 ns: ratelimit_handler             : CPU_ONLINE
      595 ns: page_alloc_cpu_notify         : CPU_ONLINE
      596 ns: hotplug_cfd                   : CPU_ONLINE
      777 ns: percpu_counter_hotcpu_callback: CPU_ONLINE
     1037 ns: cpu_callback                  : CPU_ONLINE
     1280 ns: cpu_callback                  : CPU_ONLINE
     1680 ns: cpu_callback                  : CPU_ONLINE
     2043 ns: vmstat_cpuup_callback         : CPU_ONLINE
     3422 ns: migration_call                : CPU_ONLINE
    12344 ns: workqueue_cpu_callback        : CPU_ONLINE
    52879 ns: sysfs_cpu_notify              : CPU_ONLINE
 12287706 ns: cpuset_track_online_cpus      : CPU_ONLINE
=========================================================================
Total time for CPU_ONLINE = 12.372685000 ms
=========================================================================

--x+6KMIRAuhnl3hBn--
