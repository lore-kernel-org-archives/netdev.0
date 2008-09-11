From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: xfrm_state locking regression...
Date: Thu, 11 Sep 2008 14:24:59 -0700
Message-ID: <20080911212459.GL6693@linux.vnet.ibm.com>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48317 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbYIKVZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 17:25:16 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8BLP2AI018695
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 17:25:02 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8BLP1Ok207410
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 15:25:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8BLOxSN009354
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 15:25:01 -0600
Content-Disposition: inline
In-Reply-To: <20080909143312.GA29952@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 12:33:12AM +1000, Herbert Xu wrote:
> On Mon, Sep 08, 2008 at 05:25:13PM -0700, David Miller wrote:
> > 
> > The only comment I would make is that maybe it's a bit excessive
> > to trigger the GC worker every time we walk the states.
> 
> Good point!
> 
> I've avoided the memory barrier by simply extending the mutexed
> section in the GC to cover the list splicing.  Here's the updated
> patch:
> 
> ipsec: Use RCU-like construct for saved state within a walk
> 
> Now that we save states within a walk we need synchronisation
> so that the list the saved state is on doesn't disappear from
> under us.
> 
> As it stands this is done by keeping the state on the list which
> is bad because it gets in the way of the management of the state
> life-cycle.
> 
> An alternative is to make our own pseudo-RCU system where we use
> counters to indicate which state can't be freed immediately as
> it may be referenced by an ongoing walk when that resumes.

There is only one reader at a time, right?  Otherwise, I don't see how
the increments and reads of xfrm_state_walk_completed line up.

							Thanx, Paul

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 2933d74..4bb9499 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -120,9 +120,11 @@ extern struct mutex xfrm_cfg_mutex;
>  /* Full description of state of transformer. */
>  struct xfrm_state
>  {
> -	/* Note: bydst is re-used during gc */
>  	struct list_head	all;
> -	struct hlist_node	bydst;
> +	union {
> +		struct list_head	gclist;
> +		struct hlist_node	bydst;
> +	};
>  	struct hlist_node	bysrc;
>  	struct hlist_node	byspi;
> 
> @@ -1286,16 +1288,9 @@ static inline void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
>  	walk->count = 0;
>  }
> 
> -static inline void xfrm_state_walk_done(struct xfrm_state_walk *walk)
> -{
> -	if (walk->state != NULL) {
> -		xfrm_state_put(walk->state);
> -		walk->state = NULL;
> -	}
> -}
> -
>  extern int xfrm_state_walk(struct xfrm_state_walk *walk,
>  			   int (*func)(struct xfrm_state *, int, void*), void *);
> +extern void xfrm_state_walk_done(struct xfrm_state_walk *walk);
>  extern struct xfrm_state *xfrm_state_alloc(void);
>  extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr, 
>  					  struct flowi *fl, struct xfrm_tmpl *tmpl,
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 7bd62f6..d90f936 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -59,6 +59,11 @@ static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
>  static unsigned int xfrm_state_num;
>  static unsigned int xfrm_state_genid;
> 
> +/* Counter indicating ongoing walk, protected by xfrm_state_lock. */
> +static unsigned long xfrm_state_walk_ongoing;
> +/* Counter indicating walk completion, protected by xfrm_cfg_mutex. */
> +static unsigned long xfrm_state_walk_completed;
> +
>  static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
>  static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
> 
> @@ -191,7 +196,8 @@ static DEFINE_RWLOCK(xfrm_state_afinfo_lock);
>  static struct xfrm_state_afinfo *xfrm_state_afinfo[NPROTO];
> 
>  static struct work_struct xfrm_state_gc_work;
> -static HLIST_HEAD(xfrm_state_gc_list);
> +static LIST_HEAD(xfrm_state_gc_leftovers);
> +static LIST_HEAD(xfrm_state_gc_list);
>  static DEFINE_SPINLOCK(xfrm_state_gc_lock);
> 
>  int __xfrm_state_delete(struct xfrm_state *x);
> @@ -403,17 +409,22 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
> 
>  static void xfrm_state_gc_task(struct work_struct *data)
>  {
> -	struct xfrm_state *x;
> -	struct hlist_node *entry, *tmp;
> -	struct hlist_head gc_list;
> +	struct xfrm_state *x, *tmp;
> +	unsigned long completed;
> 
> +	mutex_lock(&xfrm_cfg_mutex);
>  	spin_lock_bh(&xfrm_state_gc_lock);
> -	gc_list.first = xfrm_state_gc_list.first;
> -	INIT_HLIST_HEAD(&xfrm_state_gc_list);
> +	list_splice_tail_init(&xfrm_state_gc_list, &xfrm_state_gc_leftovers);
>  	spin_unlock_bh(&xfrm_state_gc_lock);
> 
> -	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, bydst)
> +	completed = xfrm_state_walk_completed;
> +	mutex_unlock(&xfrm_cfg_mutex);
> +
> +	list_for_each_entry_safe(x, tmp, &xfrm_state_gc_leftovers, gclist) {
> +		if ((long)(x->lastused - completed) > 0)
> +			break;
>  		xfrm_state_gc_destroy(x);
> +	}
> 
>  	wake_up(&km_waitq);
>  }
> @@ -540,12 +551,8 @@ void __xfrm_state_destroy(struct xfrm_state *x)
>  {
>  	WARN_ON(x->km.state != XFRM_STATE_DEAD);
> 
> -	spin_lock_bh(&xfrm_state_lock);
> -	list_del(&x->all);
> -	spin_unlock_bh(&xfrm_state_lock);
> -
>  	spin_lock_bh(&xfrm_state_gc_lock);
> -	hlist_add_head(&x->bydst, &xfrm_state_gc_list);
> +	list_add_tail(&x->gclist, &xfrm_state_gc_list);
>  	spin_unlock_bh(&xfrm_state_gc_lock);
>  	schedule_work(&xfrm_state_gc_work);
>  }
> @@ -558,6 +565,8 @@ int __xfrm_state_delete(struct xfrm_state *x)
>  	if (x->km.state != XFRM_STATE_DEAD) {
>  		x->km.state = XFRM_STATE_DEAD;
>  		spin_lock(&xfrm_state_lock);
> +		x->lastused = xfrm_state_walk_ongoing;
> +		list_del_rcu(&x->all);
>  		hlist_del(&x->bydst);
>  		hlist_del(&x->bysrc);
>  		if (x->id.spi)
> @@ -1572,6 +1581,7 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
>  			if (err) {
>  				xfrm_state_hold(last);
>  				walk->state = last;
> +				xfrm_state_walk_ongoing++;
>  				goto out;
>  			}
>  		}
> @@ -1586,12 +1596,28 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
>  		err = func(last, 0, data);
>  out:
>  	spin_unlock_bh(&xfrm_state_lock);
> -	if (old != NULL)
> +	if (old != NULL) {
>  		xfrm_state_put(old);
> +		xfrm_state_walk_completed++;
> +		if (!list_empty(&xfrm_state_gc_leftovers))
> +			schedule_work(&xfrm_state_gc_work);
> +	}
>  	return err;
>  }
>  EXPORT_SYMBOL(xfrm_state_walk);
> 
> +void xfrm_state_walk_done(struct xfrm_state_walk *walk)
> +{
> +	if (walk->state != NULL) {
> +		xfrm_state_put(walk->state);
> +		walk->state = NULL;
> +		xfrm_state_walk_completed++;
> +		if (!list_empty(&xfrm_state_gc_leftovers))
> +			schedule_work(&xfrm_state_gc_work);
> +	}
> +}
> +EXPORT_SYMBOL(xfrm_state_walk_done);
> +
> 
>  void xfrm_replay_notify(struct xfrm_state *x, int event)
>  {
> 
> Thanks,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
