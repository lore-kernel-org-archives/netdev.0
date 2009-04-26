From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Sun, 26 Apr 2009 13:54:39 -0700
Message-ID: <20090426205439.GB6945@linux.vnet.ibm.com>
References: <20090426052340.GA24931@linux.vnet.ibm.com> <20090426112717.GE10391@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca, tglx@linutronix.de,
	rostedt@goodmis.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756403AbZDZUyz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090426112717.GE10391@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 26, 2009 at 01:27:17PM +0200, Ingo Molnar wrote:
> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Second cut of "big hammer" expedited RCU grace periods, but only 
> > for rcu_bh.  This creates another softirq vector, so that entering 
> > this softirq vector will have forced an rcu_bh quiescent state (as 
> > noted by Dave Miller).  Use smp_call_function() to invoke 
> > raise_softirq() on all CPUs in order to cause this to happen.  
> > Track the CPUs that have passed through a quiescent state (or gone 
> > offline) with a cpumask.
> 
> hm, i'm still asking whether doing this would be simpler via a 
> reschedule vector - which not only is an existing facility but also 
> forces all RCU domains through a quiescent state - not just bh-RCU 
> participants.
> 
> Triggering a new softirq is in no way simpler that doing an SMP 
> cross-call - in fact softirqs are a finite resource so using some 
> other facility would be preferred.
> 
> Am i missing something?

Well, it is entirely possible that I am the one missing something.

So, here is the line of reasoning that lead me to the bh-RCU approach:

o	The two flavors of RCU that can support an off-to-the-side
	expedited implementation are RCU-bh and RCU-sched.  Preemptable
	RCU requires a more intrusive approach for normal RCU, due to
	the fact that RCU readers can be preempted and can block on locks.
	Therefore, forcing a reschedule on each CPU does not force a
	grace period for preemptable RCU.

	Of course, there is an easy workaround -- for preemptable
	RCU, make the expedited primitive just directly invoke
	synchronize_rcu().  Although this would not provide any speedup,
	it would at least guarantee correct operation.	But I believe
	that we need to have a way to expedite grace periods on -rt
	kernels with preemptable RCU as well as on non-real-time kernels.

o	As you say, an RCU-sched grace period implies an RCU-bh grace
	period on non-realtime kernels.  Unfortunately, for -rt kernels,
	softirq handlers can be preempted and can block while waiting
	for locks, so forcing a reschedule on each CPU does not force
	a grace period for RCU-bh in a -rt kernel.

	Again, there is an easy workaround: in CONFIG_PREEMPT_RT
	kernels, make the RCU-bh variant of the expedited primitive
	invoke a new synchronize_rcu_bh() primitive.

	Of course, allowing an RCU-sched grace period to imply an RCU-bh
	grace period loses the DoS-resistance advantages of RCU-bh.
	However, very few of the RCU updates in the kernel take
	advantage of DoS resistance.  Furthermore, Steve's patch did
	not use RCU-bh, so one could argue that we should forget about
	DoS-resistance for the time being.  Thoughts?

o	The approach in the previous patch works across all kernel
	builds, because of the fact that it forces a new softirq handler
	to run, thus guaranteeing that all prior softirq handlers and
	RCU-bh read-side critical sections for the CPU in question
	have completed.

o	I used a new softirq vector out of laziness.  I could instead
	raise RCU_SOFTIRQ, and then add code to each of the
	rcu_process_callbacks() functions to ack the expedited
	raise_softirq().

	Easy for me to change, though.  I guess I don't have to be
	-that- lazy.  ;-)

o	So, why RCU-bh rather than RCU-sched?

	Again, laziness.  The RCU-sched approach requires greater
	intrusiveness into the existing RCU implementations.  Nothing
	wrong with that, given that this is in fact another RCU API
	member, but given the choice, I would rather do the intruding
	after dropping Classic RCU.

	The easiest way I could see to minimize intrusion for RCU-sched
	is to create a new per-CPU counter that is incremented by each
	implementation of rcu_qsctr_inc().  But even easier to avoid
	the rcu_qsctr_inc() code path entirely.

Once we have dropped Classic RCU and I have merged Preemptable RCU into
Hierarchical RCU, it becomes much more attractive to merge the expediting
into the main RCU state machine.

Thoughts?

							Thanx, Paul
