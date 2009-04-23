From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Thu, 23 Apr 2009 08:34:02 -0700
Message-ID: <20090423153402.GC6877@linux.vnet.ibm.com>
References: <20090423052520.GA13036@linux.vnet.ibm.com> <20090423075436.GB22606@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090423075436.GB22606@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 09:54:36AM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > First cut of "big hammer" expedited RCU grace periods, but only 
> > for rcu_bh.  This creates another softirq vector, so that entering 
> > this softirq vector will have forced an rcu_bh quiescent state (as 
> > noted by Dave Miller).  Use smp_call_function() to invoke 
> > raise_softirq() on all CPUs in order to cause this to happen.  
> > Track the CPUs that have passed through a quiescent state (or gone 
> > offline) with a cpumask.
> > 
> > Does nothing to expedite callbacks already registered with 
> > call_rcu_bh(), but there is no need to.
> > 
> > Shortcomings:
> > 
> > o	Untested, probably does not compile, not for inclusion.
> > 
> > o	Does not handle rcu, only rcu_bh.
> > 
> > Thoughts?
> 
> I'm wondering, why not just do a two-liner, along the lines of:
> 
> 	for_each_online_cpu(cpu)
> 		smp_send_reschedule(cpu);
> 
> That should trigger a quiescent state on all online cpus. It wont 
> perturb the scheduler state (which is reschedule-IPI invariant).
> (And this is a big-hammer approach anyway so even if it did we 
> wouldnt care.)
> 
> Am i missing something embarrasingly obvious perhaps?

This two-liner would indeed trigger a quiescent state on all online CPUs.

However, it would not force RCU to notice these quiescent states quickly.
This is because RCU's normal grace-period-detection path can be thought of
as a state machine driven out of the per-CPU scheduling-clock interrupt
handler.  So RCU would still take another jiffy or two to close the grace
period -- more if there was a partly-done grace period that needed to
complete before a new one could start.

So both Lai's and my patch bypass RCU's normal state machine in order
to not only force the quiescent states, but also to determine that they
have in fact happened.

Hmmm...  I need to ask Jeff Chua what HZ he was running with.  Because if
there was some read-side critical section soaking up 30 milliseconds,
all that hammering will do is slow things down...

							Thanx, Paul
