From: "George Spelvin" <linux@horizon.com>
Subject: Re: [REGRESSION,BISECTED] Panic on ifup
Date: 12 Jul 2010 21:50:29 -0400
Message-ID: <20100713015029.2897.qmail@science.horizon.com>
References: <4C3ABDC3.3000408@iki.fi>
Cc: davem@davemloft.net, linux@horizon.com, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:55858 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751116Ab0GMBub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 21:50:31 -0400
In-Reply-To: <4C3ABDC3.3000408@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And here goes the patch (which I've only compile tested so far).

That does indeed fix it!  Also applies and works with -rc5.
Please queue for -rc6.  (Unless you want to tweak the patch a bit;
I haven't done any sort of code review on it.)

Tested-by: George Spelvin <linux@horizon.com>

> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index af1c173..200f8d7 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1598,7 +1598,8 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy
> **pols, int num_pols,
>  		if (err != -EAGAIN)
>  			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
>  		return ERR_PTR(err);
> -	}
> +	} else if (err == 0)
> +		return NULL;
> 
>  	dst = xfrm_bundle_create(pols[0], xfrm, err, fl, dst_orig);
>  	if (IS_ERR(dst)) {

This could be simplified to (if you want; it's smaller but uglier)

	if (err <= 0) {
		if (err != 0 && err != -EAGAIN)
			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
		return ERR_PTR(err);	/* Correctly returns NULL if err == 0 */
	}

> @@ -1678,6 +1679,13 @@ xfrm_bundle_lookup(struct net *net, struct flowi
> *fl, u16 family, u8 dir,
>  			goto make_dummy_bundle;
>  		dst_hold(&xdst->u.dst);
>  		return oldflo;
> +	} else if (new_xdst == NULL) {
> +		num_xfrms = 0;
> +		if (oldflo == NULL)
> +			goto make_dummy_bundle;
> +		xdst->num_xfrms = 0;
> +		dst_hold(&xdst->u.dst);
> +		return oldflo;
>  	}
> 
>  	/* Kill the previous bundle */

This I'm having a hard time simplifying.  It resembles the previous
block, but not enough.

> @@ -1760,6 +1768,10 @@ restart:
>  				xfrm_pols_put(pols, num_pols);
>  				err = PTR_ERR(xdst);
>  				goto dropdst;
> +			} else if (xdst == NULL) {
> +				num_xfrms = 0;
> +				drop_pols = num_pols;
> +				goto no_transform;
>  			}
> 
>  			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
> 

I see two nearby tests for xdst == NULL ("To accelerate a bit..."); I take it
they can't be combined?
