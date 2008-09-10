From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 20:04:00 -0700 (PDT)
Message-ID: <20080909.200400.96645840.davem@davemloft.net>
References: <20080903053935.GA8428@gondor.apana.org.au>
	<48BE245D.3060905@iki.fi>
	<20080903055041.GA8547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751968AbYIJDEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 23:04:07 -0400
In-Reply-To: <20080903055041.GA8547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 3 Sep 2008 15:50:41 +1000

> ipsec: Move state dump list unlinking into GC
> 
> This patch moves the unlinking of x->all (for dumping) into the
> GC so that we know for sure what locks we hold when we unlink the
> entry.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

After your patch I just applied, things are a bit different now.

Are you going to respin this or is it not relevant any longer?

> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 89551b6..0244325 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -380,6 +380,10 @@ static void xfrm_put_mode(struct xfrm_mode *mode)
>  
>  static void xfrm_state_gc_destroy(struct xfrm_state *x)
>  {
> +	spin_lock_bh(&xfrm_state_lock);
> +	list_del(&x->all);
> +	spin_unlock_bh(&xfrm_state_lock);
> +
>  	del_timer_sync(&x->timer);
>  	del_timer_sync(&x->rtimer);
>  	kfree(x->aalg);
> @@ -540,10 +544,6 @@ void __xfrm_state_destroy(struct xfrm_state *x)
>  {
>  	WARN_ON(x->km.state != XFRM_STATE_DEAD);
>  
> -	spin_lock_bh(&xfrm_state_lock);
> -	list_del(&x->all);
> -	spin_unlock_bh(&xfrm_state_lock);
> -
>  	spin_lock_bh(&xfrm_state_gc_lock);
>  	hlist_add_head(&x->bydst, &xfrm_state_gc_list);
>  	spin_unlock_bh(&xfrm_state_gc_lock);
> 
> Thanks,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
