From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] v3 RCU implementation with fast grace periods
Date: Tue, 21 Apr 2009 09:51:51 -0700
Message-ID: <20090421165151.GJ6642@linux.vnet.ibm.com>
References: <20090421045931.GA9953@linux.vnet.ibm.com> <20090421151034.GA3792@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:60717 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263AbZDUQv4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 12:51:56 -0400
Content-Disposition: inline
In-Reply-To: <20090421151034.GA3792@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 11:10:35AM -0400, Mathieu Desnoyers wrote:
> * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:

[ . . . ]

> > +void synchronize_rcu_fgp(void)
> > +{
> > +	mutex_lock(&rcu_fgp_mutex);
> > +	
> > +	/* CPUs must see earlier change before parity flip. */
> > +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> > +
> 
> Hrm, my original comment about missing smp_mb() here still applies, I
> don't think we have come to an agreement yet.

My argument is that smp_call_function() must necessarily contain a
full memory barrier, otherwise it cannot function properly.  ;-)

> > +	/*
> > +	 * We must flip twice to correctly handle tasks that stall
> > +	 * in rcu_read_lock_fgp() between the time that they fetch
> > +	 * rcu_fgp_ctr and the time that the store to their CPU's
> > +	 * rcu_fgp_active_readers.  No matter when they resume
> > +	 * execution, we will wait for them to get to the corresponding
> > +	 * rcu_read_unlock_fgp().
> > +	 */
> > +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 0 -> 1 */
> > +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> > +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 1 -> 0 */
> > +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> > +
> > +	/* Prevent CPUs from reordering out of prior RCU critical sections. */
> > +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> > +
> 
> Same here.
> 
> So we would need to either add a smp_mb() at both of these locations, or
> use on_each_cpu() rather than smp_call_function. Note that this is to
> ensure that the "updater" thread executes these memory barriers.

Or rely on the barriers that must be part of smp_call_function.  ;-)

						Thanx, Paul

> Mathieu
> 
> 
> > +	rcu_fgp_completed++;
> > +	mutex_unlock(&rcu_fgp_mutex);
> > +}
> > +EXPORT_SYMBOL_GPL(synchronize_rcu_fgp);
> > +
> > +/**
> > + * rcu_fgp_batches_completed - return batches completed.
> > + * @sp: srcu_struct on which to report batch completion.
> > + *
> > + * Report the number of batches, correlated with, but not necessarily
> > + * precisely the same as, the number of grace periods that have elapsed.
> > + */
> > +long rcu_fgp_batches_completed(void)
> > +{
> > +	return rcu_fgp_completed;
> > +}
> > +EXPORT_SYMBOL_GPL(rcu_fgp_batches_completed);
> 
> -- 
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
