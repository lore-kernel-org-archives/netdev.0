From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] xfrm: Fix refcount imbalance in xfrm_lookup
Date: Wed, 23 Jul 2014 19:21:13 +0200
Message-ID: <1406136073.3363.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
	 <1406103487-1656-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:40460 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932289AbaGWRV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 13:21:28 -0400
Received: by mail-wg0-f51.google.com with SMTP id b13so1481543wgh.22
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 10:21:26 -0700 (PDT)
In-Reply-To: <1406103487-1656-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-07-23 at 10:18 +0200, Steffen Klassert wrote:
> xfrm_lookup must return a dst_entry with a refcount for the caller.
> Git commit 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
> removed this refcount for the socket policy case accidentally.
> This patch restores it and sets DST_NOCACHE flag to make sure
> that the dst_entry is freed when the refcount becomes null.
> 
> Fixes: 1a1ccc96abb ("xfrm: Remove caching of xfrm_policy_sk_bundles")
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/xfrm/xfrm_policy.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index a8ef510..0525d78 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2097,6 +2097,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>  				goto no_transform;
>  			}
>  
> +			dst_hold(&xdst->u.dst);
> +			xdst->u.dst.flags |= DST_NOCACHE;
>  			route = xdst->route;
>  		}
>  	}


Hmm... are you sure ?

Before 1a1ccc96abb we did a dst_hold() because we kept the dst in
xfrm_policy_sk_bundles. So keeping a reference count was mandatory.

But after, I don't understand why it is needed at all.
