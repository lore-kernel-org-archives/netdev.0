From: Zoltan Kiss <zoltan.kiss@linaro.org>
Subject: Re: [Xen-devel] [PATCHv1 2/2] xen-netback: unref frags when handling
 a from-guest skb with a frag list
Date: Tue, 03 Mar 2015 16:56:44 +0000
Message-ID: <54F5E7CC.6060903@linaro.org>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com> <1425399971-27630-3-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:41039 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755811AbbCCQ4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:56:47 -0500
Received: by widex7 with SMTP id ex7so24267458wid.0
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:56:45 -0800 (PST)
In-Reply-To: <1425399971-27630-3-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/03/15 16:26, David Vrabel wrote:
> Every time a VIF is destroyed up-to 256 pages may be leaked if packets
                                 "up to" (and maybe a comma before it?)
> with more than MAX_SKB_FRAGS frags where transmitted from the guest.
                                      were
> Even worse, if another user of ballooned pages allocated one of these
> ballooned pages it would not handle the the unexpectedly non-zero page
                                           ^^^
One too many "the"
> count (e.g., gntdev would deadlock when unmapping a grant because the
> page count would never reach 1).
>
> When handling a from-guest skb with a frag list, unref the frags
> before releasing them so they are freed correctly when the VIF is
> destroyed.
>
> Also swap over to the new (local) frags /after/ calling the skb
> destructor.  This isn't strictly necessary but it's less confusing.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Zoltan Kiss <zoltan.kiss@linaro.org>
> ---
>   drivers/net/xen-netback/netback.c |   43 +++++++++++++++++++------------------
>   1 file changed, 22 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f7a31d2..3d06eeb 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1343,7 +1343,7 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>   {
>   	unsigned int offset = skb_headlen(skb);
>   	skb_frag_t frags[MAX_SKB_FRAGS];
> -	int i;
> +	int i, nr_frags;
>   	struct ubuf_info *uarg;
>   	struct sk_buff *nskb = skb_shinfo(skb)->frag_list;
>
> @@ -1357,17 +1357,16 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>   	skb->data_len += nskb->len;
>
>   	/* create a brand new frags array and coalesce there */
> -	for (i = 0; offset < skb->len; i++) {
> +	for (nr_frags = 0; offset < skb->len; nr_frags++) {
>   		struct page *page;
>   		unsigned int len;
>
> -		BUG_ON(i >= MAX_SKB_FRAGS);
> +		BUG_ON(nr_frags >= MAX_SKB_FRAGS);
>   		page = alloc_page(GFP_ATOMIC);
>   		if (!page) {
> -			int j;
>   			skb->truesize += skb->data_len;
> -			for (j = 0; j < i; j++)
> -				put_page(frags[j].page.p);
> +			for (i = 0; i < nr_frags; i++)
> +				put_page(frags[i].page.p);
>   			return -ENOMEM;
>   		}
>
> @@ -1379,27 +1378,29 @@ static int xenvif_handle_frag_list(struct xenvif_queue *queue, struct sk_buff *s
>   			BUG();
>
>   		offset += len;
> -		frags[i].page.p = page;
> -		frags[i].page_offset = 0;
> -		skb_frag_size_set(&frags[i], len);
> +		frags[nr_frags].page.p = page;
> +		frags[nr_frags].page_offset = 0;
> +		skb_frag_size_set(&frags[nr_frags], len);
>   	}
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
>   	skb_frag_list_init(skb);
> -	uarg = skb_shinfo(skb)->destructor_arg;
> -	/* increase inflight counter to offset decrement in callback */
> +	xenvif_skb_zerocopy_prepare(queue, nskb);
> +	kfree_skb(nskb);
> +
> +	/* Release all the original (foreign) frags. */
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +		skb_frag_unref(skb, i);
>   	atomic_inc(&queue->inflight_packets);
> +	uarg = skb_shinfo(skb)->destructor_arg;
>   	uarg->callback(uarg, true);
>   	skb_shinfo(skb)->destructor_arg = NULL;
>
> -	xenvif_skb_zerocopy_prepare(queue, nskb);
> -	kfree_skb(nskb);
> +	/* Fill the skb with the new (local) frags. */
> +	memcpy(skb_shinfo(skb)->frags, frags,
> +	       nr_frags * sizeof(skb_frag_t));
> +	skb_shinfo(skb)->nr_frags = nr_frags;
> +	skb->truesize += nr_frags * PAGE_SIZE;
>
>   	return 0;
>   }
>
