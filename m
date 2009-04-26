From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Sun, 26 Apr 2009 22:22:55 +0200
Message-ID: <20090426202255.GA5365@elte.hu>
References: <20090426052340.GA24931@linux.vnet.ibm.com> <20090426112717.GE10391@elte.hu> <20090426191343.GC29238@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756169AbZDZUXj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090426191343.GC29238@Krystal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> * Ingo Molnar (mingo@elte.hu) wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > Second cut of "big hammer" expedited RCU grace periods, but only 
> > > for rcu_bh.  This creates another softirq vector, so that entering 
> > > this softirq vector will have forced an rcu_bh quiescent state (as 
> > > noted by Dave Miller).  Use smp_call_function() to invoke 
> > > raise_softirq() on all CPUs in order to cause this to happen.  
> > > Track the CPUs that have passed through a quiescent state (or gone 
> > > offline) with a cpumask.
> > 
> > hm, i'm still asking whether doing this would be simpler via a 
> > reschedule vector - which not only is an existing facility but also 
> > forces all RCU domains through a quiescent state - not just bh-RCU 
> > participants.
> > 
> > Triggering a new softirq is in no way simpler that doing an SMP 
> > cross-call - in fact softirqs are a finite resource so using some 
> > other facility would be preferred.
> > 
> > Am i missing something?
> > 
> 
> I think the reason for this whole thread is that waiting for rcu 
> quiescent state, when called many times e.g. in multiple iptables 
> invokations, takes too longs (5 seconds to load the netfilter 
> rules at boot). [...]

I'm aware of the problem space.

I was suggesting that to trigger the quiescent state and to wait for 
it to propagate it would be enough to reuse the reschedule 
mechanism.

It would be relatively straightforward: first a send-reschedule then 
do a wait_task_context_switch() on rq->curr - both are existing 
primitives. (a task reference has to be taken but that's pretty much 
all)

By the time wait_task_context_switch() returns from the last CPU we 
know that the quiescent state has passed.

	Ingo
