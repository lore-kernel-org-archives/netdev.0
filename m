From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 08:12:14 +0200
Message-ID: <1239948734.23397.4052.camel@laptop>
References: <20090415170111.6e1ca264@nehalam>
	 <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	 <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net>
	 <20090416234955.GL6924@linux.vnet.ibm.com>
	 <20090417012812.GA25534@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, shemminger@vyatta.com,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43965 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbZDQGMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 02:12:55 -0400
In-Reply-To: <20090417012812.GA25534@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-16 at 18:28 -0700, Paul E. McKenney wrote:
> On Thu, Apr 16, 2009 at 04:49:55PM -0700, Paul E. McKenney wrote:
> > On Thu, Apr 16, 2009 at 03:33:54PM -0700, David Miller wrote:
> > > From: Patrick McHardy <kaber@trash.net>
> > > Date: Thu, 16 Apr 2009 15:11:31 +0200
> > > 
> > > > Linus Torvalds wrote:
> > > >> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
> > > >>> The counters are the bigger problem, otherwise we could just free
> > > >>> table
> > > >>> info via rcu.  Do we really have to support: replace where the counter
> > > >>> values coming out to user space are always exactly accurate, or is it
> > > >>> allowed to replace a rule and maybe lose some counter ticks (worst
> > > >>> case
> > > >>> NCPU-1).
> > > >> Why not just read the counters fromt he old one at RCU free time (they
> > > >> are guaranteed to be stable at that point, since we're all done with
> > > >> those entries), and apply them at that point to the current setup?
> > > > 
> > > > We need the counters immediately to copy them to userspace, so waiting
> > > > for an asynchronous RCU free is not going to work.
> > > 
> > > It just occurred to me that since all netfilter packet handling
> > > goes through one place, we could have a sort-of "netfilter RCU"
> > > of sorts to solve this problem.
> > 
> > OK, I am putting one together...
> > 
> > It will be needed sooner or later, though I suspect per-CPU locking
> > would work fine in this case.
> 
> And here is a crude first cut.  Untested, probably does not even compile.
> 
> Straight conversion of Mathieu Desnoyers's user-space RCU implementation
> at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did help
> a little, but he must bear the bulk of the guilt).  Pick on srcu.h
> and srcu.c out of sheer laziness.  User-space testing gives deep
> sub-microsecond grace-period latencies, so should be fast enough, at
> least if you don't mind two smp_call_function() invocations per grace
> period and spinning on each instance of a per-CPU variable.
> 
> Again, I believe per-CPU locking should work fine for the netfilter
> counters, but I guess "friends don't let friends use hashed locks".
> (I would not know for sure, never having used them myself, except of
> course to protect hash tables.)
> 
> Most definitely -not- for inclusion at this point.  Next step is to hack
> up the relevant rcutorture code and watch it explode on contact.  ;-)

One comment, its again a global thing..

I've been playing with the idea for a while now to make all RCU
implementations into proper objects so that you can do things like:

  struct atomic_rcu_domain my_rcu_domain = create_atomic_rcu();

  atomic_rcu_read_lock(&my_rcu_domain());
  ...

  atomic_rcu_read_unlock(&my_rcu_domain());

and

  call_atomic_rcu(&my_rcu_domain, &my_obj->rcu_head, do_something);

etc..

We would have:

  atomic_rcu  --  'classic' non preemptible RCU (treercu these days)
  sleep_rcu   --  'preemptible' RCU

Then have 3 default domains:

sched_rcu     -- always atomic_rcu
rcu           -- depends on PREEMPT_RCU
preempt_rcu   -- always sleep_rcu

This would allow generic code to:
  1) use preemptible RCU for those cases where needed
  2) create smaller RCU domains where needed, such as in this case
  3) mostly do away with SRCU

Now I realize that the presented RCU implementation has a different
grace period method than the existing ones that use the timer tick to
drive the state machine, so 2) might not be too relevant here. But maybe
we can do something with different grace periods too.

Anyway, just an idea because I always get a little offended at the hard
coded global variables in all these RCU implementations :-)



