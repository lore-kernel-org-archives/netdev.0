From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCHv1 2/2] xen-netback: unref frags when handling a
 from-guest skb with a frag list
Date: Wed, 4 Mar 2015 09:48:02 +0000
Message-ID: <1425462482.25940.93.camel@citrix.com>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com>
	 <1425399971-27630-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:3597 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759032AbbCDJsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 04:48:05 -0500
In-Reply-To: <1425399971-27630-3-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 16:26 +0000, David Vrabel wrote:
> Every time a VIF is destroyed up-to 256 pages may be leaked if packets
> with more than MAX_SKB_FRAGS frags where transmitted from the guest.
> Even worse, if another user of ballooned pages allocated one of these
> ballooned pages it would not handle the the unexpectedly non-zero page
> count (e.g., gntdev would deadlock when unmapping a grant because the
> page count would never reach 1).
> 
> When handling a from-guest skb with a frag list, unref the frags
> before releasing them so they are freed correctly when the VIF is
> destroyed.

Am I right that the majority of the first 2 hunks (and various bits of
the 3rd) are just switching the outer loop to nr_frags instead of i, to
free up i for use in the new code below? And also to switch j to the now
available i in the inner loop.

> Also swap over to the new (local) frags /after/ calling the skb
> destructor.  This isn't strictly necessary but it's less confusing.

My only concern would be that this now means there is a period where the
frags list is invalid. However I think the calling context is such that
nobody else can have a reference to an skb which has the same shinfo as
the one in our hand. Is that right?

(If not then I think the old code was also buggy/racy, but with a
smaller window)

> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |   43 +++++++++++++++++++------------------
>  1 file changed, 22 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f7a31d2..3d06eeb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1343,7 +1343,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>  {
>  	unsigned int offset = skb_headlen(skb);
>  	skb_frag_t frags[MAX_SKB_FRAGS];
> -	int i;
> +	int i, nr_frags;
>  	struct ubuf_info *uarg;
>  	struct sk_buff *nskb = skb_shinfo(skb)->frag_list;
>  
> @@ -1357,17 +1357,16 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>  	skb->data_len += nskb->len;
>  
>  	/* create a brand new frags array and coalesce there */
> -	for (i = 0; offset < skb->len; i++) {
> +	for (nr_frags = 0; offset < skb->len; nr_frags++) {
>  		struct page *page;
>  		unsigned int len;
>  
> -		BUG_ON(i >= MAX_SKB_FRAGS);
> +		BUG_ON(nr_frags >= MAX_SKB_FRAGS);
>  		page = alloc_page(GFP_ATOMIC);
>  		if (!page) {
> -			int j;
>  			skb->truesize += skb->data_len;
> -			for (j = 0; j < i; j++)
> -				put_page(frags[j].page.p);
> +			for (i = 0; i < nr_frags; i++)
> +				put_page(frags[i].page.p);
>  			return -ENOMEM;
>  		}
>  
> @@ -1379,27 +1378,29 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>  			BUG();
>  
>  		offset += len;
> -		frags[i].page.p = page;
> -		frags[i].page_offset = 0;
> -		skb_frag_size_set(&frags[i], len);
> +		frags[nr_frags].page.p = page;
> +		frags[nr_frags].page_offset = 0;
> +		skb_frag_size_set(&frags[nr_frags], len);
>  	}
> -	/* swap out with old one */
> -	memcpy(skb_shinfo(skb)->frags,
> -	       frags,
> -	       i * sizeof(skb_frag_t));
> -	skb_shinfo(skb)->nr_frags = i;
> -	skb->truesize += i * PAGE_SIZE;
> -
> -	/* remove traces of mapped pages and frag_list */
> +
> +	/* Copied all the bits from the frag list -- free it. */
>  	skb_frag_list_init(skb);
> -	uarg = skb_shinfo(skb)->destructor_arg;
> -	/* increase inflight counter to offset decrement in callback */
> +	xenvif_skb_zerocopy_prepare(queue, nskb);
> +	kfree_skb(nskb);
> +
> +	/* Release all the original (foreign) frags. */
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +		skb_frag_unref(skb, i);
>  	atomic_inc(&queue->inflight_packets);
> +	uarg = skb_shinfo(skb)->destructor_arg;
>  	uarg->callback(uarg, true);
>  	skb_shinfo(skb)->destructor_arg = NULL;
>  
> -	xenvif_skb_zerocopy_prepare(queue, nskb);
> -	kfree_skb(nskb);
> +	/* Fill the skb with the new (local) frags. */
> +	memcpy(skb_shinfo(skb)->frags, frags,
> +	       nr_frags * sizeof(skb_frag_t));
> +	skb_shinfo(skb)->nr_frags = nr_frags;
> +	skb->truesize += nr_frags * PAGE_SIZE;
>  
>  	return 0;
>  }
