From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Mon, 7 May 2012 13:24:42 +0300
Message-ID: <20120507102441.GA18591@redhat.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
 <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30414 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab2EGKYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 06:24:40 -0400
Content-Disposition: inline
In-Reply-To: <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 03:56:09PM +0100, Ian Campbell wrote:
> This should be used by drivers which need to hold on to an skb for an extended
> (perhaps unbounded) period of time. e.g. the tun driver which relies on
> userspace consuming the skb.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: mst@redhat.com
> ---
>  drivers/net/tun.c      |    1 +
>  include/linux/skbuff.h |   11 ++++++++
>  net/core/skbuff.c      |   68 ++++++++++++++++++++++++++++++++++-------------
>  3 files changed, 61 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bb8c72c..b53e04e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -415,6 +415,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Orphan the skb - required as we might hang on to it
>  	 * for indefinite time. */
>  	skb_orphan(skb);
> +	skb_orphan_frags(skb, GFP_KERNEL);
>  
>  	/* Enqueue packet */
>  	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index ccc7d93..9145f83 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1711,6 +1711,17 @@ static inline void skb_orphan(struct sk_buff *skb)
>  }
>  
>  /**
> + *	skb_orphan_frags - orphan the frags contained in a buffer
> + *	@skb: buffer to orphan frags from
> + *	@gfp_mask: allocation mask for replacement pages
> + *
> + *	For each frag in the SKB which has a destructor (i.e. has an
> + *	owner) create a copy of that frag and release the original
> + *	page by calling the destructor.
> + */
> +extern int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask);
> +
> +/**
>   *	__skb_queue_purge - empty a list
>   *	@list: list to empty
>   *
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 945b807..f009abb 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -697,31 +697,25 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
>  }
>  EXPORT_SYMBOL_GPL(skb_morph);
>  
> -/*	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
> - *	@skb: the skb to modify
> - *	@gfp_mask: allocation priority
> - *
> - *	This must be called on SKBTX_DEV_ZEROCOPY skb.
> - *	It will copy all frags into kernel and drop the reference
> - *	to userspace pages.
> - *
> - *	If this function is called from an interrupt gfp_mask() must be
> - *	%GFP_ATOMIC.
> - *
> - *	Returns 0 on success or a negative error code on failure
> - *	to allocate kernel memory to copy to.
> +/*
> + * If uarg != NULL copy and replace all frags.
> + * If uarg == NULL then only copy and replace those which have a destructor
> + * pointer.
>   */
> -int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> +static int skb_copy_frags(struct sk_buff *skb, gfp_t gfp_mask,
> +			  struct ubuf_info *uarg)
>  {
>  	int i;
>  	int num_frags = skb_shinfo(skb)->nr_frags;
>  	struct page *page, *head = NULL;
> -	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
>  
>  	for (i = 0; i < num_frags; i++) {
>  		u8 *vaddr;
>  		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
>  
> +		if (!uarg && !f->page.destructor)
> +			continue;
> +
>  		page = alloc_page(GFP_ATOMIC);
>  		if (!page) {
>  			while (head) {
> @@ -739,11 +733,16 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  		head = page;
>  	}
>  
> -	/* skb frags release userspace buffers */
> -	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +	/* skb frags release buffers */
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
> +		if (!uarg && !f->page.destructor)
> +			continue;
>  		skb_frag_unref(skb, i);
> +	}
>  
> -	uarg->callback(uarg);
> +	if (uarg)
> +		uarg->callback(uarg);
>  

So above we only linked up copied pages, but below we
try to use the list for all frags. Looks like a bug,
I think it needs to check destructor and uarg too.


>  	/* skb frags point to kernel buffers */
>  	for (i = skb_shinfo(skb)->nr_frags; i > 0; i--) {
> @@ -752,10 +751,41 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  		head = (struct page *)head->private;
>  	}
>  
> -	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
>  	return 0;
>  }
>  
> +/*	skb_copy_ubufs	-	copy userspace skb frags buffers to kernel
> + *	@skb: the skb to modify
> + *	@gfp_mask: allocation priority
> + *
> + *	This must be called on SKBTX_DEV_ZEROCOPY skb.
> + *	It will copy all frags into kernel and drop the reference
> + *	to userspace pages.
> + *
> + *	If this function is called from an interrupt gfp_mask() must be
> + *	%GFP_ATOMIC.
> + *
> + *	Returns 0 on success or a negative error code on failure
> + *	to allocate kernel memory to copy to.
> + */
> +int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
> +{
> +	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
> +	int rc;
> +
> +	rc = skb_copy_frags(skb, gfp_mask, uarg);
> +
> +	if (rc == 0)
> +		skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> +
> +	return rc;
> +}
> +
> +int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
> +{
> +	return skb_copy_frags(skb, gfp_mask, NULL);
> +}
> +EXPORT_SYMBOL(skb_orphan_frags);
>  
>  /**
>   *	skb_clone	-	duplicate an sk_buff
> -- 
> 1.7.2.5
