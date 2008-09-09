From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 9 Sep 2008 10:18:28 +1000
Message-ID: <20080909001828.GA20643@gondor.apana.org.au>
References: <48BE329C.2010209@iki.fi> <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.170907.242316059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47732 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754026AbYIIASg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:18:36 -0400
Content-Disposition: inline
In-Reply-To: <20080908.170907.242316059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 05:09:07PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 5 Sep 2008 21:55:07 +1000
> 
> > @@ -403,17 +408,23 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
> >  
> >  static void xfrm_state_gc_task(struct work_struct *data)
> >  {
> > -	struct xfrm_state *x;
> > -	struct hlist_node *entry, *tmp;
> > -	struct hlist_head gc_list;
> > +	struct xfrm_state *x, *tmp;
> > +	static LIST_HEAD(gc_list);
> > +	unsigned long completed;
> >  
> >  	spin_lock_bh(&xfrm_state_gc_lock);
> > -	gc_list.first = xfrm_state_gc_list.first;
> > -	INIT_HLIST_HEAD(&xfrm_state_gc_list);
> > +	list_splice_tail_init(&xfrm_state_gc_list, &gc_list);
> >  	spin_unlock_bh(&xfrm_state_gc_lock);
> >  
> > -	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, bydst)
> > +	mutex_lock(&xfrm_cfg_mutex);
> > +	completed = xfrm_state_walk_completed;
> > +	mutex_unlock(&xfrm_cfg_mutex);
> > +
> > +	list_for_each_entry_safe(x, tmp, &gc_list, gclist) {
> > +		if ((long)(x->lastused - completed) > 0)
> > +			break;
> >  		xfrm_state_gc_destroy(x);
> > +	}
> >  
> >  	wake_up(&km_waitq);
> >  }
> 
> What happens to all of the entries on the local gc_list which you
> will be skipping when you break out of that last loop?
> 
> It looks like they will never get processed.

I made gc_list static, so they'll be processed when the GC task
runs again.  Also whenever completed is incremented we schedule
the GC task.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
