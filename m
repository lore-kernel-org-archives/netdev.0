From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 3/3] xfrm: Restrict "level use" for IPComp
 configuration
Date: Mon, 9 Dec 2013 11:38:56 +0100
Message-ID: <20131209103856.GL31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-4-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44626 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932909Ab3LIKi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 05:38:58 -0500
Content-Disposition: inline
In-Reply-To: <1385607161-27597-4-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 10:52:41AM +0800, Fan Du wrote:
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 911ef03..d37a2c1 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1895,6 +1895,12 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
>  			return -ENOBUFS;
>  	}
>  
> +	/* IPComp requires level use option to accomodate both compressed
> +	 * and non-compressed packet when checking policy.
> +	 */
> +	if ((t->id.proto == IPPROTO_COMP) && (t->optional == 0))
> +		return -EINVAL;
> +
>  	/* addresses present only in tunnel mode */
>  	if (t->mode == XFRM_MODE_TUNNEL) {
>  		u8 *sa = (u8 *) (rq + 1);
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 52efe71..d7216ea 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -1293,6 +1293,10 @@ static int validate_tmpl(int nr, struct xfrm_user_tmpl *ut, u16 family)
>  		default:
>  			return -EINVAL;
>  		}
> +
> +		/* Refuse any IPComp conf that missing "level use" */
> +		if ((ut[i].id.proto == IPPROTO_COMP) && (ut[i].optional == 0))
> +			return -EINVAL;
>  	}

I think this will make a lot of people unhappy. It was never required
to set 'optional' for ipcomp, and I'd bet that most users don't set
it for ipcomp. I understand the problem, but we can't fix it like that.
