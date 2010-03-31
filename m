From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
	policy->walk.dead
Date: Wed, 31 Mar 2010 19:03:45 +0800
Message-ID: <20100331110345.GC12845@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:42016 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756833Ab0CaLDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:03:54 -0400
Content-Disposition: inline
In-Reply-To: <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 01:17:05PM +0300, Timo Teras wrote:
> All of the code considers ->dead as a hint that the cached policy
> needs to get refreshed. The read side can just drop the read lock
> without any side effects.
> 
> The write side needs to make sure that it's written only exactly
> once. Only possible race is at xfrm_policy_kill(). This is fixed
> by checking result of __xfrm_policy_unlink() when needed. It will
> always succeed if the policy object is looked up from the hash
> list (so some checks are removed), but it needs to be checked if
> we are trying to unlink policy via a reference (appropriate
> checks added).
> 
> Since policy->walk.dead is written exactly once, it no longer
> needs to be protected with a write lock.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

> @@ -794,10 +783,9 @@ int xfrm_policy_flush(struct net *net, u8 type, struct xfrm_audit *audit_info)
>  				     &net->xfrm.policy_inexact[dir], bydst) {
>  			if (pol->type != type)
>  				continue;
> -			dp = __xfrm_policy_unlink(pol, dir);
> +			__xfrm_policy_unlink(pol, dir);
>  			write_unlock_bh(&xfrm_policy_lock);
> -			if (dp)
> -				cnt++;
> +			cnt++;
>  
>  			xfrm_audit_policy_delete(pol, 1, audit_info->loginuid,
>  						 audit_info->sessionid,

I was intrigued to find that my local source never had this dp
stuff.

It seems that this was added recently:

commit 2f1eb65f366b81aa3c22c31e6e8db26168777ec5
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Feb 19 02:00:42 2010 +0000

    xfrm: Flushing empty SPD generates false events

    To see the effect make sure you have an empty SPD.
    On window1 "ip xfrm mon" and on window2 issue "ip xfrm policy flush"
    You get prompt back in window2 and you see the flush event on window1.
    With this fix, you still get prompt on window1 but no event on window2.

    Thanks to Alexey Dobriyan for finding a bug in earlier version
    when using pfkey to do the flushing.

    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: David S. Miller <davem@davemloft.net>

This seems to be bogus to me.  Just because the DB was empty
before the flush doesn't mean that the flush didn't happen.

We should revert this patch in its entirety.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
