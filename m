From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: Bug in skb_segment: fskb->len != len
Date: Tue, 29 Oct 2013 10:08:49 +0100
Message-ID: <20131029090849.GC5944@cpaasch-mac>
References: <20131028115552.GC4408@cpaasch-mac>
 <1382966471.13037.18.camel@edumazet-glaptop.roam.corp.google.com>
 <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46532 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889Ab3J2JJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:09:02 -0400
Content-Disposition: inline
In-Reply-To: <1383009308.5464.2.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/10/13 - 18:15:08, Eric Dumazet wrote:
> On Mon, 2013-10-28 at 06:21 -0700, Eric Dumazet wrote:
> 
> > But we also need to fix the skb_segment() bug anyway.
> 
> Hi Christoph
> 
> I cooked a minimal patch, could you please try it ?
> 
> I'll refactor skb_segment() to be smarter for the next release
> (linux-3.14).
> 
> Thanks !
> 
>  net/core/skbuff.c |   15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)

Ok, my router does not crash anymore with my workload.

Thanks for fixing it!

Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>


Cheers,
Christoph

> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 0ab32faa520f..771946487a8d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2761,7 +2761,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  	unsigned int len;
>  	__be16 proto;
>  	bool csum;
> -	int sg = !!(features & NETIF_F_SG);
> +	bool sg = !!(features & NETIF_F_SG);
>  	int nfrags = skb_shinfo(skb)->nr_frags;
>  	int err = -ENOMEM;
>  	int i = 0;
> @@ -2793,7 +2793,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  			hsize = len;
>  
>  		if (!hsize && i >= nfrags) {
> -			BUG_ON(fskb->len != len);
> +			if (fskb->len != len) {
> +				hsize = len;
> +				sg = false;
> +				goto do_linear;
> +			}
>  
>  			pos += len;
>  			nskb = skb_clone(fskb, GFP_ATOMIC);
> @@ -2812,6 +2816,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  			skb_release_head_state(nskb);
>  			__skb_push(nskb, doffset);
>  		} else {
> +do_linear:
>  			nskb = __alloc_skb(hsize + doffset + headroom,
>  					   GFP_ATOMIC, skb_alloc_rx_flag(skb),
>  					   NUMA_NO_NODE);
> @@ -2838,9 +2843,6 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  						 nskb->data - tnl_hlen,
>  						 doffset + tnl_hlen);
>  
> -		if (fskb != skb_shinfo(skb)->frag_list)
> -			goto perform_csum_check;
> -
>  		if (!sg) {
>  			nskb->ip_summed = CHECKSUM_NONE;
>  			nskb->csum = skb_copy_and_csum_bits(skb, offset,
> @@ -2849,6 +2851,9 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>  			continue;
>  		}
>  
> +		if (fskb != skb_shinfo(skb)->frag_list)
> +			goto perform_csum_check;
> +
>  		frag = skb_shinfo(nskb)->frags;
>  
>  		skb_copy_from_linear_data_offset(skb, offset,
> 
> 
