From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 07:51:02 -0700
Message-ID: <20090417145102.GA6742@linux.vnet.ibm.com>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090417021902.GC24956@Krystal> <20090417050530.GB6885@linux.vnet.ibm.com> <20090417054451.GA31411@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090417054451.GA31411@Krystal>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 17, 2009 at 01:44:51AM -0400, Mathieu Desnoyers wrote:
> * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > On Thu, Apr 16, 2009 at 10:19:02PM -0400, Mathieu Desnoyers wrote:
> > > * Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > > > On Thu, Apr 16, 2009 at 04:49:55PM -0700, Paul E. McKenney wrote:

[ . . . ]

> > > > +
> > > > +void synchronize_rcu_fgp(void)
> > > > +{
> > > > +	mutex_lock(&rcu_fgp_mutex);
> > > > +	
> > > > +	/* CPUs must see earlier change before parity flip. */
> > > > +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> > > 
> > > /*
> > >  * Call a function on all other processors
> > >  */
> > > int smp_call_function(void(*func)(void *info), void *info, int wait);
> > > 
> > > I guess you meant on_each_cpu ? That should include "self", given we
> > > also need the smp_mb().
> > 
> > Hmmm...  Why do we need "self"?  Because synchronize_rcu_fgp() blocks,
> > it had jolly well better not be within a read-side critical section.
> > 
> > So, what am I missing here?
> 
> I mean that I think we also need some smp_mb()s on the writer side,
> don't we ? If we want the changes done by the writer (assign pointer) to
> be shown to the readers before the writer starts flipping the parity, a
> smp_mb() is needed at the beginning of synchronize_rcu_fgp() (actually
> at the same location where you call the rcu_fgp_do_mb ipis), same at the
> end (so we order parity flipping with the next assign pointer).
> 
> Or maybe it's getting late and I am missing the obvious.

The smp_call_function() itself must have barriers in order to ensure
that the other CPUs see the updates to its parameter block.

But see my upcoming response to Dave and Peter.

							Thanx, Paul

> Mathieu
> 
> > > > +
> > > > +	/*
> > > > +	 * We must flip twice to correctly handle tasks that stall
> > > > +	 * in rcu_read_lock_fgp() between the time that they fetch
> > > > +	 * rcu_fgp_ctr and the time that the store to their CPU's
> > > > +	 * rcu_fgp_active_readers.  No matter when they resume
> > > > +	 * execution, we will wait for them to get to the corresponding
> > > > +	 * rcu_read_unlock_fgp().
> > > > +	 */
> > > > +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 0 -> 1 */
> > > > +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> > > > +	ACCESS_ONCE(rcu_fgp_ctr) ^= RCU_FGP_PARITY;  /* flip parity 1 -> 0 */
> > > > +	rcu_fgp_wait_for_quiescent_state();	     /* wait for old readers */
> > > > +
> > > > +	/* Prevent CPUs from reordering out of prior RCU critical sections. */
> > > > +	smp_call_function(rcu_fgp_do_mb, NULL, 1);
> > > > +
> > > 
> > > Same as above.
> > 
> > Same as above.  ;-)
> > 
> > > Mathieu, who can still recognise his original userspace implementation
> > > :-)
> > 
> > Yeah, I never was all that good at disguising code anyway.  But I did
> > keep a couple of changes.  ;-)
> > 
> > Updated patch below.
> > 
> > 							Thanx, Paul
> > 
> > ------------------------------------------------------------------------
> > 
> > And here is a crude second cut.  Untested, probably does not even compile.
> > 
> > Straight conversion of Mathieu Desnoyers's user-space RCU implementation
> > at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did help
> > a little, but he must bear the bulk of the guilt).  Pick on srcu.h
> > and srcu.c out of sheer laziness.  User-space testing gives deep
> > sub-microsecond grace-period latencies, so should be fast enough, at
> > least if you don't mind two smp_call_function() invocations per grace
> > period and spinning on each instance of a per-CPU variable.
> > 
> > Again, I believe per-CPU locking should work fine for the netfilter
> > counters, but I guess "friends don't let friends use hashed locks".
> > (I would not know for sure, never having used them myself, except of
> > course to protect hash tables.)
> > 
> > Most definitely -not- for inclusion at this point.  Next step is to hack
> > up the relevant rcutorture code and watch it explode on contact.  ;-)
> > 
> > Changes since v1:
> > 
> > o	Applied Mathieu's feedback.
> > 
> > o	Added docbook headers and other comments.
> > 
> > o	Added the rcu_fgp_batches_completed API required by rcutorture.
> > 
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > ---
> > 
> >  include/linux/srcu.h |   42 ++++++++++++++++++++++++
> >  kernel/srcu.c        |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 131 insertions(+)
> > 
> 
> -- 
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68
