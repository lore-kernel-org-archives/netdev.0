From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 08/14] xen-netback: use foreign page information
 from the pages themselves
Date: Tue, 13 Jan 2015 14:43:39 +0000
Message-ID: <54B52F1B.8040408@citrix.com>
References: <1421077417-7162-1-git-send-email-david.vrabel@citrix.com> <1421077417-7162-9-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jenny Herbert <jennifer.herbert@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59787 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbAMOp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 09:45:28 -0500
In-Reply-To: <1421077417-7162-9-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/15 15:43, David Vrabel wrote:
> From: Jenny Herbert <jenny.herbert@citrix.com>
> 
> Use the foreign page flag in netback to get the domid and grant ref
> needed for the grant copy.  This signficiantly simplifies the netback
> code and makes netback work with foreign pages from other backends
> (e.g., blkback).
> 
> This allows blkback to use iSCSI disks provided by domUs running on
> the same host.

Dave,

This depends on several xen changes.  It's been Acked-by: Ian Campbell
<ian.campbell@citrix.com>

Are you happy for me to merge this via the xen tree in 3.20?

David

> Signed-off-by: Jenny Herbert <jennifer.herbert@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |  100 ++++---------------------------------
>  1 file changed, 9 insertions(+), 91 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 6441318..ae3ab37 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -314,9 +314,7 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
>  static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb,
>  				 struct netrx_pending_operations *npo,
>  				 struct page *page, unsigned long size,
> -				 unsigned long offset, int *head,
> -				 struct xenvif_queue *foreign_queue,
> -				 grant_ref_t foreign_gref)
> +				 unsigned long offset, int *head)
>  {
>  	struct gnttab_copy *copy_gop;
>  	struct xenvif_rx_meta *meta;
> @@ -333,6 +331,8 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
>  	offset &= ~PAGE_MASK;
>  
>  	while (size > 0) {
> +		struct xen_page_foreign *foreign;
> +
>  		BUG_ON(offset >= PAGE_SIZE);
>  		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
>  
> @@ -361,9 +361,10 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
>  		copy_gop->flags = GNTCOPY_dest_gref;
>  		copy_gop->len = bytes;
>  
> -		if (foreign_queue) {
> -			copy_gop->source.domid = foreign_queue->vif->domid;
> -			copy_gop->source.u.ref = foreign_gref;
> +		foreign = xen_page_foreign(page);
> +		if (foreign) {
> +			copy_gop->source.domid = foreign->domid;
> +			copy_gop->source.u.ref = foreign->gref;
>  			copy_gop->flags |= GNTCOPY_source_gref;
>  		} else {
>  			copy_gop->source.domid = DOMID_SELF;
> @@ -406,35 +407,6 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
>  }
>  
>  /*
> - * Find the grant ref for a given frag in a chain of struct ubuf_info's
> - * skb: the skb itself
> - * i: the frag's number
> - * ubuf: a pointer to an element in the chain. It should not be NULL
> - *
> - * Returns a pointer to the element in the chain where the page were found. If
> - * not found, returns NULL.
> - * See the definition of callback_struct in common.h for more details about
> - * the chain.
> - */
> -static const struct ubuf_info *xenvif_find_gref(const struct sk_buff *const skb,
> -						const int i,
> -						const struct ubuf_info *ubuf)
> -{
> -	struct xenvif_queue *foreign_queue = ubuf_to_queue(ubuf);
> -
> -	do {
> -		u16 pending_idx = ubuf->desc;
> -
> -		if (skb_shinfo(skb)->frags[i].page.p ==
> -		    foreign_queue->mmap_pages[pending_idx])
> -			break;
> -		ubuf = (struct ubuf_info *) ubuf->ctx;
> -	} while (ubuf);
> -
> -	return ubuf;
> -}
> -
> -/*
>   * Prepare an SKB to be transmitted to the frontend.
>   *
>   * This function is responsible for allocating grant operations, meta
> @@ -459,8 +431,6 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  	int head = 1;
>  	int old_meta_prod;
>  	int gso_type;
> -	const struct ubuf_info *ubuf = skb_shinfo(skb)->destructor_arg;
> -	const struct ubuf_info *const head_ubuf = ubuf;
>  
>  	old_meta_prod = npo->meta_prod;
>  
> @@ -507,68 +477,16 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  			len = skb_tail_pointer(skb) - data;
>  
>  		xenvif_gop_frag_copy(queue, skb, npo,
> -				     virt_to_page(data), len, offset, &head,
> -				     NULL,
> -				     0);
> +				     virt_to_page(data), len, offset, &head);
>  		data += len;
>  	}
>  
>  	for (i = 0; i < nr_frags; i++) {
> -		/* This variable also signals whether foreign_gref has a real
> -		 * value or not.
> -		 */
> -		struct xenvif_queue *foreign_queue = NULL;
> -		grant_ref_t foreign_gref;
> -
> -		if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
> -			(ubuf->callback == &xenvif_zerocopy_callback)) {
> -			const struct ubuf_info *const startpoint = ubuf;
> -
> -			/* Ideally ubuf points to the chain element which
> -			 * belongs to this frag. Or if frags were removed from
> -			 * the beginning, then shortly before it.
> -			 */
> -			ubuf = xenvif_find_gref(skb, i, ubuf);
> -
> -			/* Try again from the beginning of the list, if we
> -			 * haven't tried from there. This only makes sense in
> -			 * the unlikely event of reordering the original frags.
> -			 * For injected local pages it's an unnecessary second
> -			 * run.
> -			 */
> -			if (unlikely(!ubuf) && startpoint != head_ubuf)
> -				ubuf = xenvif_find_gref(skb, i, head_ubuf);
> -
> -			if (likely(ubuf)) {
> -				u16 pending_idx = ubuf->desc;
> -
> -				foreign_queue = ubuf_to_queue(ubuf);
> -				foreign_gref =
> -					foreign_queue->pending_tx_info[pending_idx].req.gref;
> -				/* Just a safety measure. If this was the last
> -				 * element on the list, the for loop will
> -				 * iterate again if a local page were added to
> -				 * the end. Using head_ubuf here prevents the
> -				 * second search on the chain. Or the original
> -				 * frags changed order, but that's less likely.
> -				 * In any way, ubuf shouldn't be NULL.
> -				 */
> -				ubuf = ubuf->ctx ?
> -					(struct ubuf_info *) ubuf->ctx :
> -					head_ubuf;
> -			} else
> -				/* This frag was a local page, added to the
> -				 * array after the skb left netback.
> -				 */
> -				ubuf = head_ubuf;
> -		}
>  		xenvif_gop_frag_copy(queue, skb, npo,
>  				     skb_frag_page(&skb_shinfo(skb)->frags[i]),
>  				     skb_frag_size(&skb_shinfo(skb)->frags[i]),
>  				     skb_shinfo(skb)->frags[i].page_offset,
> -				     &head,
> -				     foreign_queue,
> -				     foreign_queue ? foreign_gref : UINT_MAX);
> +				     &head);
>  	}
>  
>  	return npo->meta_prod - old_meta_prod;
> 
