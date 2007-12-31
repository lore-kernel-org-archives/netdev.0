From: Paul Moore <paul.moore@hp.com>
Subject: Re: [IPSEC]: Move all calls to xfrm_audit_state_icvfail to xfrm_input
Date: Mon, 31 Dec 2007 12:48:40 -0500
Message-ID: <200712311248.40984.paul.moore@hp.com>
References: <20071231042355.GA9215@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:57874 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750789AbXLaRtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 12:49:13 -0500
In-Reply-To: <20071231042355.GA9215@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 30 December 2007 11:23:55 pm Herbert Xu wrote:
> Hi Dave:
>
> While refreshing the async IPsec patches I noticed some fresh code
> duplication.
>
> [IPSEC]: Move all calls to xfrm_audit_state_icvfail to xfrm_input
>
> Let's nip the code duplication in the bud :)

Thanks, not sure why I didn't see that in the first place :)

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
> index ec8de0a..d76803a 100644
> --- a/net/ipv4/ah4.c
> +++ b/net/ipv4/ah4.c
> @@ -179,10 +179,8 @@ static int ah_input(struct xfrm_state *x, struct
> sk_buff *skb) err = ah_mac_digest(ahp, skb, ah->auth_data);
>  		if (err)
>  			goto unlock;
> -		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
> -			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
> +		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
>  			err = -EBADMSG;
> -		}
>  	}
>  unlock:
>  	spin_unlock(&x->lock);
> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> index b334c76..28ea5c7 100644
> --- a/net/ipv4/esp4.c
> +++ b/net/ipv4/esp4.c
> @@ -191,7 +191,6 @@ static int esp_input(struct xfrm_state *x, struct
> sk_buff *skb) BUG();
>
>  		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
> -			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
>  			err = -EBADMSG;
>  			goto unlock;
>  		}
> diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
> index 2d32772..fb0d07a 100644
> --- a/net/ipv6/ah6.c
> +++ b/net/ipv6/ah6.c
> @@ -380,10 +380,8 @@ static int ah6_input(struct xfrm_state *x, struct
> sk_buff *skb) err = ah_mac_digest(ahp, skb, ah->auth_data);
>  		if (err)
>  			goto unlock;
> -		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
> -			xfrm_audit_state_icvfail(x, skb, IPPROTO_AH);
> +		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
>  			err = -EBADMSG;
> -		}
>  	}
>  unlock:
>  	spin_unlock(&x->lock);
> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index e10f10b..5bd5292 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -186,7 +186,6 @@ static int esp6_input(struct xfrm_state *x, struct
> sk_buff *skb) BUG();
>
>  		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
> -			xfrm_audit_state_icvfail(x, skb, IPPROTO_ESP);
>  			ret = -EBADMSG;
>  			goto unlock;
>  		}
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index 1b250f3..039e701 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -186,8 +186,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr,
> __be32 spi, int encap_type) resume:
>  		spin_lock(&x->lock);
>  		if (nexthdr <= 0) {
> -			if (nexthdr == -EBADMSG)
> +			if (nexthdr == -EBADMSG) {
> +				xfrm_audit_state_icvfail(x, skb,
> +							 x->type->proto);
>  				x->stats.integrity_failed++;
> +			}
>  			XFRM_INC_STATS(LINUX_MIB_XFRMINSTATEPROTOERROR);
>  			goto drop_unlock;
>  		}
>
> Thanks,



-- 
paul moore
linux security @ hp
