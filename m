From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Mon, 08 Sep 2008 17:09:07 -0700 (PDT)
Message-ID: <20080908.170907.242316059.davem@davemloft.net>
References: <48BE329C.2010209@iki.fi>
	<20080902.234723.163403187.davem@davemloft.net>
	<20080905115506.GA26179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754068AbYIIAJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:09:14 -0400
In-Reply-To: <20080905115506.GA26179@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 5 Sep 2008 21:55:07 +1000

> @@ -403,17 +408,23 @@ static void xfrm_state_gc_destroy(struct xfrm_state *x)
>  
>  static void xfrm_state_gc_task(struct work_struct *data)
>  {
> -	struct xfrm_state *x;
> -	struct hlist_node *entry, *tmp;
> -	struct hlist_head gc_list;
> +	struct xfrm_state *x, *tmp;
> +	static LIST_HEAD(gc_list);
> +	unsigned long completed;
>  
>  	spin_lock_bh(&xfrm_state_gc_lock);
> -	gc_list.first = xfrm_state_gc_list.first;
> -	INIT_HLIST_HEAD(&xfrm_state_gc_list);
> +	list_splice_tail_init(&xfrm_state_gc_list, &gc_list);
>  	spin_unlock_bh(&xfrm_state_gc_lock);
>  
> -	hlist_for_each_entry_safe(x, entry, tmp, &gc_list, bydst)
> +	mutex_lock(&xfrm_cfg_mutex);
> +	completed = xfrm_state_walk_completed;
> +	mutex_unlock(&xfrm_cfg_mutex);
> +
> +	list_for_each_entry_safe(x, tmp, &gc_list, gclist) {
> +		if ((long)(x->lastused - completed) > 0)
> +			break;
>  		xfrm_state_gc_destroy(x);
> +	}
>  
>  	wake_up(&km_waitq);
>  }

What happens to all of the entries on the local gc_list which you
will be skipping when you break out of that last loop?

It looks like they will never get processed.
