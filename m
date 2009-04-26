From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Sun, 26 Apr 2009 15:13:44 -0400
Message-ID: <20090426191343.GC29238@Krystal>
References: <20090426052340.GA24931@linux.vnet.ibm.com> <20090426112717.GE10391@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts16-srv.bellnexxia.net ([209.226.175.4]:44746 "EHLO
	tomts16-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753842AbZDZTNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2009 15:13:46 -0400
Content-Disposition: inline
In-Reply-To: <20090426112717.GE10391@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ingo Molnar (mingo@elte.hu) wrote:
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
> 

I think the reason for this whole thread is that waiting for rcu
quiescent state, when called many times e.g. in multiple iptables
invokations, takes too longs (5 seconds to load the netfilter rules at
boot). The three solutions proposed so far are :

- bh disabling + per-cpu read-write lock
- RCU FGP (fast grace periods), where the writer directly check each
  per-cpu variables associated with netfilter to make sure the quiescent
  state for a particular resource has been reached. (derived from my
  userspace RCU implementation)
- expedited "big hammer" rcu GP, where the writer only waits for bh
  quiescent state. This is useful if we can guarantee that all readers
  are either in bh context or disable bottom halves.

Therefore, it's really on purpose that Paul does not wait for global RCU
quiescent states, but rather just for bh : it's faster.

IMHO, the bh rcu GP shares the same problem as the global RCU GP
approach : it monitors global kernel state to ensure quiescence. It's
better in practice because bh quiescent states are much more frequent
than global QS, but it still depends on every other bh handler and bh
disabled section duration to calculate the maximum writer delay. One
might argue that if we keep those small, this should not matter in
practice.

The RCU FGP approach is interesting because it's based solely on
netfilter-specific per-cpu variables to detect QS. Therefore, even if
an unrelated piece of kernel software eventually decides to be a bad
citizen and disable bh for long periods on a 4096 cpu box, it won't slow
down the netfilter tables update.

This last positive aspect of RCU FGP is common with the bh disabling +
per-cpu rw lock approach, where the rw lock is also local to netfilter.
However, taking a rwlock and disabling bh will make the read-side much
slower than RCU FGP (which simply disables preemption and touches a
per-cpu GP/nesting count variable). But given RCU FGP is relatively new,
it makes sense to use a known-good solution in the short term.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
