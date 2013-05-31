From: Simon Horman <horms@verge.net.au>
Subject: Re: [Patch net-next v3] net: clean up skb headers code
Date: Fri, 31 May 2013 09:25:17 +0900
Message-ID: <20130531002517.GC26684@verge.net.au>
References: <1369879575-18701-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41307 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab3EaAYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:24:33 -0400
Content-Disposition: inline
In-Reply-To: <1369879575-18701-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 10:06:15AM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> fields of struct skbuff) converts skb->*_header to u16,
> some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
> and to be safe, we could just use "X = ~(typeof(X))0;"
> as suggested by David and Ben.
> 
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Cong Wang <amwang@redhat.com>

FWIW, I would prefer to see a patch that just removes the instances
of #ifdef NET_SKBUFF_DATA_USES_OFFSET below, and then a separate
patch to clean-up the use of ~0U once some consensus is reached on
the best approach.

The reason is that I suspect that the #ifdef NET_SKBUFF_DATA_USES_OFFSET
is a bug fix for cases where it is not defined. Whereas the ~0 discussion
is more cosmetic.

> 
> ---
> v2: use typeof
> v3: use ~(typeof(X))0
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 5f93119..f3c18a0 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1593,7 +1593,7 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
>  }
>  static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
>  {
> -	return skb->transport_header != ~0U;
> +	return skb->transport_header != ~(typeof(skb->transport_header))0;
>  }
>  
>  static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
> @@ -1636,7 +1636,7 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
>  
>  static inline int skb_mac_header_was_set(const struct sk_buff *skb)
>  {
> -	return skb->mac_header != ~0U;
> +	return skb->mac_header != ~(typeof(skb->mac_header))0;
>  }
>  
>  static inline void skb_reset_mac_header(struct sk_buff *skb)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f45de07..e121c4b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -199,9 +199,7 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
>  	skb->truesize = sizeof(struct sk_buff);
>  	atomic_set(&skb->users, 1);
>  
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header = (__u16) ~0U;
> -#endif
> +	skb->mac_header = ~(typeof(skb->mac_header))0;
>  out:
>  	return skb;
>  }
> @@ -275,10 +273,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>  	skb->data = data;
>  	skb_reset_tail_pointer(skb);
>  	skb->end = skb->tail + size;
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header = (__u16) ~0U;
> -	skb->transport_header = (__u16) ~0U;
> -#endif
> +	skb->mac_header = ~(typeof(skb->mac_header))0;
> +	skb->transport_header = ~(typeof(skb->transport_header))0;
>  
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
> @@ -344,10 +340,8 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
>  	skb->data = data;
>  	skb_reset_tail_pointer(skb);
>  	skb->end = skb->tail + size;
> -#ifdef NET_SKBUFF_DATA_USES_OFFSET
> -	skb->mac_header = (__u16) ~0U;
> -	skb->transport_header = (__u16) ~0U;
> -#endif
> +	skb->mac_header = ~(typeof(skb->mac_header))0;
> +	skb->transport_header = ~(typeof(skb->transport_header))0;
>  
>  	/* make sure we initialize shinfo sequentially */
>  	shinfo = skb_shinfo(skb);
> 
