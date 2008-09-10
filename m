From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Wed, 10 Sep 2008 14:22:47 +1000
Message-ID: <20080910042247.GA2544@gondor.apana.org.au>
References: <20080910032304.GA28580@gondor.apana.org.au> <20080909.203808.112347106.davem@davemloft.net> <20080910040107.GA29695@gondor.apana.org.au> <20080909.210654.159776216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49281 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750767AbYIJEWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:22:54 -0400
Content-Disposition: inline
In-Reply-To: <20080909.210654.159776216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 09, 2008 at 09:06:54PM -0700, David Miller wrote:
> 
> Only AF_KEY gave an error, and this ended the dump.  This was
> one of Timo's goals, to make AF_KEY continue where it left
> off in subsequent dump calls done by the user, when we hit the
> socket limit.

I see.

> > While it is possible to restore the old order and save a little
> > bit of memory, I certainly don't think this is very urgent.
> 
> Too late, I already implemented it :-)

Awesome :) Your patch is much simpler than I thought.
 
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 4bb9499..ba0e47c 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -120,7 +120,6 @@ extern struct mutex xfrm_cfg_mutex;
>  /* Full description of state of transformer. */
>  struct xfrm_state
>  {
> -	struct list_head	all;
>  	union {
>  		struct list_head	gclist;
>  		struct hlist_node	bydst;

This union now needs to move across to bysrc or byspi since bydst
needs to be preserved for walking even after a node is added to
the GC.

> @@ -566,7 +564,6 @@ int __xfrm_state_delete(struct xfrm_state *x)
>  		x->km.state = XFRM_STATE_DEAD;
>  		spin_lock(&xfrm_state_lock);
>  		x->lastused = xfrm_state_walk_ongoing;
> -		list_del_rcu(&x->all);
>  		hlist_del(&x->bydst);

We need hlist_del_rcu on bydst for the same reason.

> @@ -1571,24 +1564,29 @@ int xfrm_state_walk(struct xfrm_state_walk *walk,
>  	old = x = walk->state;
>  	walk->state = NULL;
>  	spin_lock_bh(&xfrm_state_lock);
> -	if (x == NULL)
> -		x = list_first_entry(&xfrm_state_all, struct xfrm_state, all);
> -	list_for_each_entry_from(x, &xfrm_state_all, all) {
> -		if (x->km.state == XFRM_STATE_DEAD)
> -			continue;
> -		if (!xfrm_id_proto_match(x->id.proto, walk->proto))
> -			continue;
> -		if (last) {
> -			err = func(last, walk->count, data);
> -			if (err) {
> -				xfrm_state_hold(last);
> -				walk->state = last;
> -				xfrm_state_walk_ongoing++;
> -				goto out;
> +	for (i = walk->chain; i <= xfrm_state_hmask; i++) {
> +		struct hlist_head *h = xfrm_state_bydst + i;
> +		struct hlist_node *entry;
> +
> +		if (!x)
> +			x = hlist_entry(h->first, struct xfrm_state, bydst);
> +		hlist_for_each_entry_from(x, entry, bydst) {
> +			if (!xfrm_id_proto_match(x->id.proto, walk->proto))
> +				continue;
> +			if (last) {
> +				err = func(last, walk->count, data);
> +				if (err) {

This is a bug in the original patch.  When we get an error on
the very last node we'll lose that node instead of dumping it
later.  I wonder if we could just get rid of last altogether...

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
