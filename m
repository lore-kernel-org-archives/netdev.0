From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: do not check x->km.state
Date: Thu, 13 Dec 2012 11:19:48 +0100
Message-ID: <20121213101948.GG18940@secunet.com>
References: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34284 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811Ab2LMKTv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 05:19:51 -0500
Content-Disposition: inline
In-Reply-To: <1355389560-7705-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 05:06:00PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> do not check x->km.state, it will be checked by succedent
> xfrm_state_check_expire()
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/xfrm6_input.c |    1 -
>  net/xfrm/xfrm_input.c  |    4 ----
>  2 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
> index f8c3cf8..de4babd 100644
> --- a/net/ipv6/xfrm6_input.c
> +++ b/net/ipv6/xfrm6_input.c
> @@ -108,7 +108,6 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
>  		spin_lock(&x->lock);
>  
>  		if ((!i || (x->props.flags & XFRM_STATE_WILDRECV)) &&
> -		    likely(x->km.state == XFRM_STATE_VALID) &&
>  		    !xfrm_state_check_expire(x)) {
>  			spin_unlock(&x->lock);
>  			if (x->type->input(x, skb) > 0) {
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index ab2bb42..a8fbb09 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -163,10 +163,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>  		skb->sp->xvec[skb->sp->len++] = x;
>  
>  		spin_lock(&x->lock);
> -		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
> -			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
> -			goto drop_unlock;
> -		}


This would remove the only place where the LINUX_MIB_XFRMINSTATEINVALID
statistics counter is incremented. I think it would be better to ensure
a valid state before we call xfrm_state_check_expire(). This would make
the statistics more accurate and we can remove the x->km.state check
from xfrm_state_check_expire().
