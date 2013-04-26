From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipvs: Use cond_resched_rcu_lock() helper when
 dumping connections
Date: Fri, 26 Apr 2013 09:30:46 -0700
Message-ID: <20130426163046.GG3860@linux.vnet.ibm.com>
References: <1366940708-10180-1-git-send-email-horms@verge.net.au>
 <1366940708-10180-3-git-send-email-horms@verge.net.au>
 <20130426080313.GC8669@dyad.programming.kicks-ass.net>
 <20130426154547.GC3860@linux.vnet.ibm.com>
 <1366991947.8964.233.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Ingo Molnar <mingo@redhat.com>,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Dipankar Sarma <dipankar@in.ibm.com>, dhaval.giani@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49678 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756824Ab3DZQfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 12:35:16 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 26 Apr 2013 10:35:08 -0600
Content-Disposition: inline
In-Reply-To: <1366991947.8964.233.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 08:59:07AM -0700, Eric Dumazet wrote:
> On Fri, 2013-04-26 at 08:45 -0700, Paul E. McKenney wrote:
> 
> > I have done some crude coccinelle patterns in the past, but they are
> > subject to false positives (from when you transfer the pointer from
> > RCU protection to reference-count protection) and also false negatives
> > (when you atomically increment some statistic unrelated to protection).
> > 
> > I could imagine maintaining a per-thread count of the number of outermost
> > RCU read-side critical sections at runtime, and then associating that
> > counter with a given pointer at rcu_dereference() time, but this would
> > require either compiler magic or an API for using a pointer returned
> > by rcu_dereference().  This API could in theory be enforced by sparse.
> > 
> > Dhaval Giani might have some ideas as well, adding him to CC.
> 
> 
> We had this fix the otherday, because tcp prequeue code hit this check :
> 
> static inline struct dst_entry *skb_dst(const struct sk_buff *skb)
> {
>         /* If refdst was not refcounted, check we still are in a 
>          * rcu_read_lock section
>          */
>         WARN_ON((skb->_skb_refdst & SKB_DST_NOREF) &&
>                 !rcu_read_lock_held() &&
>                 !rcu_read_lock_bh_held());
>         return (struct dst_entry *)(skb->_skb_refdst & SKB_DST_PTRMASK);
> }
> 
> ( http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=093162553c33e9479283e107b4431378271c735d )
> 
> Problem is the rcu protected pointer was escaping the rcu lock and was
> then used in another thread.

All the way to some other thread?  That is a serious escape!  ;-)

> What would be cool (but expensive maybe) , would be to get a cookie from
> rcu_read_lock(), and check the cookie at rcu_dereference(). These
> cookies would have system wide scope to catch any kind of errors.

I suspect that your cookie and my counter are quite similar.

> Because a per thread counter would not catch following problem :
> 
> rcu_read_lock();
> 
> ptr = rcu_dereference(x);
> if (!ptr)
> 	return NULL;
> ...
> 
> 
> rcu_read_unlock();
> 
> ...
> rcu_read_lock();
> /* no reload of x, ptr might be now stale/freed */
> if (ptr->field) { ... }

Well, that is why I needed to appeal to compiler magic or an API
extension.  Either way, the pointer returned from rcu_dereference()
must be tagged with the ID of the outermost rcu_read_lock() that
covers it.  Then that tag must be checked against that of the outermost
rcu_read_lock() when it is dereferenced.  If we introduced yet another
set of RCU API members (shudder!) with which to wrapper your
ptr->field use, we could associate additional storage with the
pointer to hold the cookie/counter.  And then use sparse to enforce
use of the new API.

Of course, if we were using C++, we could define a template for pointers
returned by rcu_dereference() in order to make this work.  Now, where
did I put that asbestos suit, you know, the one with the titanium
pinstripes?  ;-)

But even that has some "interesting" issues.  To see this, let's
modify your example a bit:

	rcu_read_lock();

	...

	rcu_read_lock_bh();

	ptr = rcu_dereference(x);
	if (!ptr)
		return NULL;
	...


	rcu_read_unlock_bh();

	...
	/* no reload of x, ptr might be now stale/freed */
	if (ptr->field) { ... }

	...

	rcu_read_unlock();


Now, is it the rcu_read_lock() or the rcu_read_lock_bh() that protects
the rcu_dereference()?

							Thanx, Paul
