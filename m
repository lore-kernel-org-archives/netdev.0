From: Martin Willi <martin@strongswan.org>
Subject: Re: [RFC PATCH] xfrm: Accept XFRM_STATE_AF_UNSPEC SAs on IPv4/IPv6   only hosts
Date: Tue, 02 Dec 2008 10:49:24 +0100
Message-ID: <1228211364.23126.62.camel@martin>
References: <1227629406.21037.193.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:38060 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751432AbYLBJtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 04:49:51 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id 0BF5E2F19DEC
	for <netdev@vger.kernel.org>; Tue,  2 Dec 2008 10:49:27 +0100 (CET)
In-Reply-To: <1227629406.21037.193.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm wondering what's the state of this patch. Should I resubmit without
[RFC]? Something else wrong with it?

It has been tagged as "Accepted" in patchworks, but isn't gone anywhere
so far.

Thanks
Martin

On Tue, 2008-11-25 at 17:10 +0100, Martin Willi wrote:
> Installing SAs using the XFRM_STATE_AF_UNSPEC fails on hosts with
> support for one address family only. This patch accepts such SAs, even
> if the processing of not supported packets will fail.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>
> 
> ---
> For me the meaning of that flag is not really clear. If it means
> "I-want-to-run-v6-in-v4-or-vice-versa" then the current behavior
> (reject SA) is probably ok.
> However, in my understanding ("accept-any-inner-address-family"), the
> kernel should accept such SAs. Otherwise userspace has to query the
> supported address families.
> 
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 508337f..456782b 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -2032,8 +2032,9 @@ int xfrm_init_state(struct xfrm_state *x)
>  		x->inner_mode = inner_mode;
>  	} else {
>  		struct xfrm_mode *inner_mode_iaf;
> +		int iafamily = AF_INET;
>  
> -		inner_mode = xfrm_get_mode(x->props.mode, AF_INET);
> +		inner_mode = xfrm_get_mode(x->props.mode, x->props.family);
>  		if (inner_mode == NULL)
>  			goto error;
>  
> @@ -2041,22 +2042,17 @@ int xfrm_init_state(struct xfrm_state *x)
>  			xfrm_put_mode(inner_mode);
>  			goto error;
>  		}
> +		x->inner_mode = inner_mode;
>  
> -		inner_mode_iaf = xfrm_get_mode(x->props.mode, AF_INET6);
> -		if (inner_mode_iaf == NULL)
> -			goto error;
> +		if (x->props.family == AF_INET)
> +			iafamily = AF_INET6;
>  
> -		if (!(inner_mode_iaf->flags & XFRM_MODE_FLAG_TUNNEL)) {
> -			xfrm_put_mode(inner_mode_iaf);
> -			goto error;
> -		}
> -
> -		if (x->props.family == AF_INET) {
> -			x->inner_mode = inner_mode;
> -			x->inner_mode_iaf = inner_mode_iaf;
> -		} else {
> -			x->inner_mode = inner_mode_iaf;
> -			x->inner_mode_iaf = inner_mode;
> +		inner_mode_iaf = xfrm_get_mode(x->props.mode, iafamily);
> +		if (inner_mode_iaf) {
> +			if (inner_mode_iaf->flags & XFRM_MODE_FLAG_TUNNEL)
> +				x->inner_mode_iaf = inner_mode_iaf;
> +			else
> +				xfrm_put_mode(inner_mode_iaf);
>  		}
>  	}
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


