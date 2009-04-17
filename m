From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 14:29:43 -0700
Message-ID: <20090417212943.GD6742@linux.vnet.ibm.com>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <1239948734.23397.4052.camel@laptop> <20090417163351.GC6742@linux.vnet.ibm.com> <1239987097.23397.4800.camel@laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1239987097.23397.4800.camel@laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 17, 2009 at 06:51:37PM +0200, Peter Zijlstra wrote:
> On Fri, 2009-04-17 at 09:33 -0700, Paul E. McKenney wrote:
> 
> > > One comment, its again a global thing..
> > > 
> > > I've been playing with the idea for a while now to make all RCU
> > > implementations into proper objects so that you can do things like:
> > > 
> > >   struct atomic_rcu_domain my_rcu_domain = create_atomic_rcu();
> > > 
> > >   atomic_rcu_read_lock(&my_rcu_domain());
> > >   ...
> > > 
> > >   atomic_rcu_read_unlock(&my_rcu_domain());
> > > 
> > > and
> > > 
> > >   call_atomic_rcu(&my_rcu_domain, &my_obj->rcu_head, do_something);
> > > 
> > > etc..
> > > 
> > > We would have:
> > > 
> > >   atomic_rcu  --  'classic' non preemptible RCU (treercu these days)
> > >   sleep_rcu   --  'preemptible' RCU
> > > 
> > > Then have 3 default domains:
> > > 
> > > sched_rcu     -- always atomic_rcu
> > 
> > This is the call_rcu_sched() variant.
> > 
> > > rcu           -- depends on PREEMPT_RCU
> > 
> > This is the call_rcu() variant.
> > 
> > > preempt_rcu   -- always sleep_rcu
> > 
> > I guess that this one could allow sleeping on mutexes...  Does anyone
> > need to do that?
> 
> I almost did a few times, but never quite got the code that needed it
> working good enough for it to go anywhere.

It probably would not be hard to enable preemptable RCU in a
!CONFIG_PREEMPT configuration, which would allow mutexes to be acquired
in these read-side critical sections.  After I fix any relevant bugs,
of course...

> > > This would allow generic code to:
> > >   1) use preemptible RCU for those cases where needed
> > >   2) create smaller RCU domains where needed, such as in this case
> > >   3) mostly do away with SRCU
> > 
> > #3 would be good!  But...
> > 
> > At an API level, there are two differences between SRCU and the other
> > RCU implementations:
> > 
> > a.	The return value from srcu_read_lock() is passed to
> > 	srcu_read_unlock().
> > 
> > b.	There is a control block passed in to each SRCU primitive.
> > 
> > Difference (a) could potentially be taken care of with a few tricks I
> > am trying in the process of getting preemptrcu merged into treercu.
> 
> Right, incrementing one cpu and decrementing another doesn't change the
> sum over all cpus :-)

Well, I am trying to get rid of the summing over all CPUs -- really hard
to make a reasonable hierarchy that way.  But yes.  ;-)

> > Your approach to (b) certainly makes it uniform, there are >500
> > occurrences of rcu_read_lock() and rcu_read_unlock() each, but only
> > a very few occurrences of srcu_read_lock() and srcu_read_unlock()
> > (like exactly one each!).  So adding an argument to rcu_read_lock()
> > does not sound at all reasonable.
> 
> static inline void rcu_read_lock(void)
> {
> 	atomic_rcu_read_lock(&global_atomic_rcu_context);
> }
> 
> static inline void rcu_read_unlock(void)
> {
> 	atomic_rcu_read_unlock(&global_atomic_rcu_context);
> }
> 
> static inline void call_rcu(struct rcu_head *rcuhead, void (*func)(struct rcu_head *))
> {
> 	call_atomic_rcu(&global_atomic_rcu_context, rcuhead, func);
> }
> 
> etc.. Should take care of that, no?

Given that for classic and hierarchical RCU, rcu_read_lock() and
rcu_read_unlock() just map to preempt_disable() and preempt_enable(),
how is this helping?

> > > Now I realize that the presented RCU implementation has a different
> > > grace period method than the existing ones that use the timer tick to
> > > drive the state machine, so 2) might not be too relevant here. But maybe
> > > we can do something with different grace periods too.
> > > 
> > > Anyway, just an idea because I always get a little offended at the hard
> > > coded global variables in all these RCU implementations :-)
> > 
> > I am thinking in terms of adding a synchronize_rcu_bh() with the desired
> > properties.  That way we avoid yet another RCU flavor.  (What can I say?
> > I got carried away!)  Also, since the rcu-bh flavor is used only by
> > networking, we have a fair amount of freedom to tweak it. 
> 
> Right. I was thinking along the way of providing a watermark (either
> nr_queued based, or time based) and once it exceeds try to drive it from
> read_unlock. Or similar. unlock driven RCU implementations have the best
> grace period time every, except for all the down sides ;-)

Jim Houston did an unlock-driven implementation some years back:

http://marc.theaimsgroup.com/?l=linux-kernel&m=109387402400673&w=2

The read-side overhead can be a problem.  And I have gotten grace-period
latencies under 100ns without driving the grace period from the update
side.  Of course, these implementations have their downsides as well.  ;-)

> >  It will take
> > longer than introducing a new flavor, but Steve Hemminger has a good
> > solution already, and RCU really isn't the thing to do quick hacks on.
> 
> Ok, back on topic :-)
> 
> I wouldn't exactly call it a good solution,

Compared to the global rwlock, it is a wonderful solution.  ;-)

>                                             it does a
> for_each_possible_cpu() spin_lock();
> 
>  1) that should probably be for_each_online_cpu()

In principle I agree.  In practice, this is an infrequently executed
slow path, right?

Or are you concerned about real-time latencies while loading new
iptables or some such?

>  2) that doesn't scale at all, I'm sure dave's 256-way hurts like mad
>     when inserting tons of rules and we do that for every iptable
>     modification.

There of course is a point beyond which this method is slower than
a full RCU grace period.  But I bet that Dave's 256-way machine
is not anywhere near big enough to reach that point.  Maybe he can
try it and tell us what happens.  ;-)

>  3) there is no way lockdep can track all that :(

This is a good point.  I understand the need to acquire the locks, but
am not fully clear on why we cannot acquire one CPU's lock, gather its
counters, release that lock, acquire the next CPU's lock, and so on.
Maybe a code-complexity issue?

Please keep in mind that we are trying to hit 2.6.30 with this fix, so
simplicity is even more important than it usually be.  Yes, I have some
idea of the irony of me saying much of anything about simplicity.  ;-)

> Do we _really_ _really_ __HAVE__ to serialize this? So far I've heard
> Patrick say: there might be, a use case. That doesn't sound like: we
> should make it dead slow for everybody else.

We are making it faster than it used to be by quite a bit by getting rid
of the global lock, so this does sound like a good approach.  Here is my
reasoning:

1.	The update-side performance is good, as verified by Jeff Chua.

2.	The per-packet read-side performance is slowed by roughly the
	overhead of an uncontended lock, which comes to about 60ns
	on my laptop.  At some point, this 60ns will become critical,
	but I do not believe that we are there yet.

	When it does become critical, a new patch can be produced.
	Such a patch can of course be backported as required -- this
	is a reasonably isolated piece of code, right?

							Thanx, Paul
