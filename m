From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC v2 02/12] sock: skb_copy_ubufs support for compound
 pages
Date: Wed, 22 Feb 2017 12:33:56 -0800
Message-ID: <1487795636.9415.91.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
         <20170222163901.90834-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35429 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934225AbdBVUmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 15:42:11 -0500
Received: by mail-pf0-f193.google.com with SMTP id 68so225852pfx.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 12:41:36 -0800 (PST)
In-Reply-To: <20170222163901.90834-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-22 at 11:38 -0500, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
> 
> Refine skb_copy_ubufs to support compount pages. With upcoming TCP
> and UDP zerocopy sendmsg, such fragments may appear.
> 
> These skbuffs can have both kernel and zerocopy fragments, e.g., when
> corking. Avoid unnecessary copying of fragments that have no userspace
> reference.
> 
> It is not safe to modify skb frags when the skbuff is shared. This
> should not happen. Fail loudly if we find an unexpected edge case.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  net/core/skbuff.c | 24 +++++++++++++++++++++++-
>  1 file changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f3557958e9bf..67e4216fca01 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -944,6 +944,9 @@ EXPORT_SYMBOL_GPL(skb_morph);
>   *	If this function is called from an interrupt gfp_mask() must be
>   *	%GFP_ATOMIC.
>   *
> + *	skb_shinfo(skb) can only be safely modified when not accessed
> + *	concurrently. Fail if the skb is shared or cloned.
> + *
>   *	Returns 0 on success or a negative error code on failure
>   *	to allocate kernel memory to copy to.
>   */
> @@ -954,11 +957,29 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
>  	struct page *page, *head = NULL;
>  	struct ubuf_info *uarg = skb_shinfo(skb)->destructor_arg;
>  
> +	if (skb_shared(skb) || skb_cloned(skb)) {
> +		WARN_ON_ONCE(1);
> +		return -EINVAL;
> +	}
> +
>  	for (i = 0; i < num_frags; i++) {
>  		u8 *vaddr;
> +		unsigned int order = 0;
> +		gfp_t mask = gfp_mask;
>  		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
>  
> -		page = alloc_page(gfp_mask);
> +		page = skb_frag_page(f);
> +		if (page_count(page) == 1) {
> +			skb_frag_ref(skb, i);

This could be : get_page(page);

> +			goto copy_done;
> +		}
> +
> +		if (f->size > PAGE_SIZE) {
> +			order = get_order(f->size);
> +			mask |= __GFP_COMP;

Note that this would probably fail under memory pressure.

We could instead try to explode the few segments into order-0 only
pages.

Hopefully this case should not be frequent.
