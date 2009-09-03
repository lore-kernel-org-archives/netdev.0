From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 10:44:35 -0700
Message-ID: <20090903174435.GF6761@linux.vnet.ibm.com>
References: <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:36971 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753642AbZICRoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 13:44:34 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 03, 2009 at 02:24:17PM -0500, Christoph Lameter wrote:
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
> 
> > Point is we cannot deal with RCU quietness before disposing the slab cache,
> > (if SLAB_DESTROY_BY_RCU was set on the cache) since this disposing *will*
> > make call_rcu() calls when a full slab is freed/purged.
> 
> There is no need to do call_rcu calls for frees at that point since
> objects are no longer in use. We could simply disable SLAB_DESTROY_BY_RCU
> for the final clearing of caches.

Suppose we have the following sequence of events:

1.	CPU 0 is running a task that is using the slab cache.

	This CPU does kmem_cache_free(), which happens to free up
	some memory to the system.  Because SLAB_DESTROY_BY_RCU is
	set, an RCU callback is posted to do the actual freeing.

	Please note that this RCU callback is internal to the slab,
	so that the slab user cannot be aware of it.  In fact, the
	slab user isn't doing any call_rcu()s whatever.

2.	CPU 0 discovers that the slab cache can now be destroyed.

	It determines that there are no users, and has guaranteed
	that there will be no future users.  So it knows that it
	can safely do kmem_cache_destroy().

3.	In absence of rcu_barrier(), kmem_cache_destroy() would
	immediately tear down the slab data structures.

4.	At the end of the next grace period, the RCU callback posted
	(again, internally by the slab cache) is invoked.  It has a
	coronary due to the slab data structures having already been
	freed, and (worse yet) possibly reallocated for other uses.

Hence the need for the rcu_barrier() when tearing down SLAB_DESTROY_BY_RCU
slab caches.

> > And when RCU grace period is elapsed, the callback *will* need access to
> > the cache we want to dismantle. Better to not have kfreed()/poisoned it...
> 
> But going through the RCU period is pointless since no user of the cache
> remains.

Which is irrelevant.  The outstanding RCU callback was posted by the
slab cache itself, -not- by the user of the slab cache.

> > I believe you mix two RCU uses here.
> >
> > 1) The one we all know, is use normal caches (!SLAB_DESTROY_BY_RCU)
> > (or kmalloc()), and use call_rcu(... kfree_something)
> >
> >    In this case, you are 100% right that the subsystem itself has
> >    to call rcu_barrier() (or respect whatever self-synchro) itself,
> >    before calling kmem_cache_destroy()
> >
> > 2) The SLAB_DESTROY_BY_RCU one.
> >
> >    Part of cache dismantle needs to call rcu_barrier() itself.
> >    Caller doesnt have to use rcu_barrier(). It would be a waste of time,
> >    as kmem_cache_destroy() will refill rcu wait queues with its own stuff.
> 
> The dismantling does not need RCU since there are no operations on the
> objects in progress. So simply switch DESTROY_BY_RCU off for close.

Unless I am missing something, this patch re-introduces the bug that
the rcu_barrier() was added to prevent.  So, in absence of a better
explanation of what I am missing:

NACK.

							Thanx, Paul

> ---
>  mm/slub.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2009-09-03 10:14:51.000000000 -0500
> +++ linux-2.6/mm/slub.c	2009-09-03 10:18:32.000000000 -0500
> @@ -2594,9 +2594,9 @@ static inline int kmem_cache_close(struc
>   */
>  void kmem_cache_destroy(struct kmem_cache *s)
>  {
> -	if (s->flags & SLAB_DESTROY_BY_RCU)
> -		rcu_barrier();
>  	down_write(&slub_lock);
> +	/* Stop deferring frees so that we can immediately free structures */
> +	s->flags &= ~SLAB_DESTROY_BY_RCU;
>  	s->refcount--;
>  	if (!s->refcount) {
>  		list_del(&s->list);
