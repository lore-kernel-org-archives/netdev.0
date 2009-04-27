From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Mon, 27 Apr 2009 09:17:04 -0700
Message-ID: <20090427161704.GD7226@linux.vnet.ibm.com>
References: <20090426052340.GA24931@linux.vnet.ibm.com> <20090426112717.GE10391@elte.hu> <20090426191343.GC29238@Krystal> <20090426202255.GA5365@elte.hu> <20090426214451.GC6945@linux.vnet.ibm.com> <20090427032639.GA10087@elte.hu> <20090427132153.GI6945@linux.vnet.ibm.com> <20090427134302.GA19137@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090427134302.GA19137@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 27, 2009 at 03:43:02PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Mon, Apr 27, 2009 at 05:26:39AM +0200, Ingo Molnar wrote:
> > > 
> > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > 
> > > > On Sun, Apr 26, 2009 at 10:22:55PM +0200, Ingo Molnar wrote:
> > > > > 
> > > > > * Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> > > > > 
> > > > > > * Ingo Molnar (mingo@elte.hu) wrote:
> > > > > > > 
> > > > > > > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > > > > > > 
> > > > > > > > Second cut of "big hammer" expedited RCU grace periods, but only 
> > > > > > > > for rcu_bh.  This creates another softirq vector, so that entering 
> > > > > > > > this softirq vector will have forced an rcu_bh quiescent state (as 
> > > > > > > > noted by Dave Miller).  Use smp_call_function() to invoke 
> > > > > > > > raise_softirq() on all CPUs in order to cause this to happen.  
> > > > > > > > Track the CPUs that have passed through a quiescent state (or gone 
> > > > > > > > offline) with a cpumask.
> > > > > > > 
> > > > > > > hm, i'm still asking whether doing this would be simpler via a 
> > > > > > > reschedule vector - which not only is an existing facility but also 
> > > > > > > forces all RCU domains through a quiescent state - not just bh-RCU 
> > > > > > > participants.
> > > > > > > 
> > > > > > > Triggering a new softirq is in no way simpler that doing an SMP 
> > > > > > > cross-call - in fact softirqs are a finite resource so using some 
> > > > > > > other facility would be preferred.
> > > > > > > 
> > > > > > > Am i missing something?
> > > > > > > 
> > > > > > 
> > > > > > I think the reason for this whole thread is that waiting for rcu 
> > > > > > quiescent state, when called many times e.g. in multiple iptables 
> > > > > > invokations, takes too longs (5 seconds to load the netfilter 
> > > > > > rules at boot). [...]
> > > > > 
> > > > > I'm aware of the problem space.
> > > > > 
> > > > > I was suggesting that to trigger the quiescent state and to wait for 
> > > > > it to propagate it would be enough to reuse the reschedule 
> > > > > mechanism.
> > > > > 
> > > > > It would be relatively straightforward: first a send-reschedule then 
> > > > > do a wait_task_context_switch() on rq->curr - both are existing 
> > > > > primitives. (a task reference has to be taken but that's pretty much 
> > > > > all)
> > > > 
> > > > Well, one reason I didn't take this approach was that I didn't 
> > > > happen to think of it.  ;-)
> > > > 
> > > > Also that I hadn't heard of wait_task_context_switch().
> > > > 
> > > > Hmmm...  Looking for wait_task_context_switch().  OK, found it.
> > > > 
> > > > It looks to me that this primitive won't return until the 
> > > > scheduler actually decides to run something else.  We instead need 
> > > > to have something that stops waiting once the CPU enters the 
> > > > scheduler, hence the previous thought of making rcu_qsctr_inc() do 
> > > > a bit of extra work.
> > > > 
> > > > This would be a way of making an expedited RCU-sched across all 
> > > > RCU implementations.  As noted in the earlier email, it would not 
> > > > handle RCU or RCU-bh in a -rt kernel.
> > > > 
> > > > > By the time wait_task_context_switch() returns from the last CPU 
> > > > > we know that the quiescent state has passed.
> > > > 
> > > > We would want to wait for all of the CPUs in parallel, though, 
> > > > wouldn't we?  Seems that we would not want to wait for the last 
> > > > CPU to do another trip through the scheduler if it had already 
> > > > passed through the scheduler while we were waiting on the earlier 
> > > > CPUs.
> > > > 
> > > > So it seems like we would still want a two-pass approach -- one 
> > > > pass to capture the current state, the second pass to wait for the 
> > > > state to change.
> > > 
> > > I think waiting in parallel is still possible (first kick all tasks, 
> > > then make sure all tasks have left the CPU at least once).
> > > 
> > > The busy-waiting in wait_task_context_switch() is indeed a 
> > > problem - but perhaps that could be refactored to be a 
> > > migration-thread driven wait_for_completion() + complete() 
> > > cycle? It could be driven by preempt notifiers perhaps - and 
> > > become zero-cost.
> > 
> > Hmmm...  It would need to be informed of the quiescent state even 
> > if that quiescent state did not result in a preemption.
> > 
> > But you are right -- I do need to expedite RCU, not just RCU-bh, 
> > especially given that the boot-speed guys are starting to see 
> > grace periods as a measureable fraction of the boot time.  I will 
> > take another pass at this.
> 
> The precise method of signalling is a detail i suspect - so by all 
> means use a new softirq if that is the cleanest. I'd also agree that 
> covering not just bh-rcu would definitely be a good idea.

Fair enough!  ;-)

							Thanx, Paul
