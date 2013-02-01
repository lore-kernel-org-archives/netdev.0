From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/2 net-next] xfrm: count esp/ah header to lifetime
Date: Fri, 1 Feb 2013 11:18:36 +0100
Message-ID: <20130201101836.GA26962@secunet.com>
References: <1359695836-5666-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37221 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754598Ab3BAKSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 05:18:39 -0500
Content-Disposition: inline
In-Reply-To: <1359695836-5666-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2013 at 01:17:15PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com> 
> 
> rfc4301 4.4.2 says:
> 
> (a) If byte count is used, then the implementation SHOULD count the
>     number of bytes to which the IPsec cryptographic algorithm is
>     applied.  For ESP, this is the encryption algorithm (including
>     Null encryption) and for AH, this is the authentication
>     algorithm.  This includes pad bytes, etc.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/xfrm/xfrm_input.c  |    4 +++-
>  net/xfrm/xfrm_output.c |    8 +++++---
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index ab2bb42..da156e9 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -114,6 +114,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>  	unsigned int family;
>  	int decaps = 0;
>  	int async = 0;
> +	int skb_len = 0;
>  
>  	/* A negative encap_type indicates async resumption. */
>  	if (encap_type < 0) {
> @@ -192,6 +193,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>  
>  		skb_dst_force(skb);
>  
> +		skb_len = skb->len;
>  		nexthdr = x->type->input(x, skb);
>  
>  		if (nexthdr == -EINPROGRESS)
> @@ -219,7 +221,7 @@ resume:
>  
>  		x->repl->advance(x, seq);
>  
> -		x->curlft.bytes += skb->len;
> +		x->curlft.bytes += skb_len;

Using a stack variable does not work with asynchronous ciphers.
We would not count the lifebytes at all in this case.

>  		x->curlft.packets++;
>  
>  		spin_unlock(&x->lock);
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 3670526..2c5aa8d 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -79,9 +79,6 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
>  			goto error;
>  		}
>  
> -		x->curlft.bytes += skb->len;
> -		x->curlft.packets++;
> -
>  		spin_unlock_bh(&x->lock);
>  
>  		skb_dst_force(skb);
> @@ -90,6 +87,11 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
>  		if (err == -EINPROGRESS)
>  			goto out_exit;
>  
> +		spin_lock_bh(&x->lock);
> +		x->curlft.bytes += skb->len;
> +		x->curlft.packets++;
> +		spin_unlock_bh(&x->lock);
> +

This is certainly not the right place to do this. It is after the exit on
asynchronous crypto and before the resume from asynchronous crypto, so again
we would not count the lifebytes.

>  resume:
>  		if (err) {
>  			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEPROTOERROR);
> -- 
> 1.7.10.4
