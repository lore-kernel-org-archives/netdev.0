From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen/netfront: handle compound page fragments on
 transmit
Date: Tue, 20 Nov 2012 06:45:35 -0800
Message-ID: <1353422735.2590.6.camel@edumazet-glaptop>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:48376 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab2KTOpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 09:45:39 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so8642526iea.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 06:45:38 -0800 (PST)
In-Reply-To: <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 11:40 +0000, Ian Campbell wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in xennet_make_frags by iterating over the frames which
> make up the page.
> 
> This is the netfront equivalent to 6a8ed462f16b for netback.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: xen-devel@lists.xen.org
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> Cc: ANNIE LI <annie.li@oracle.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> Cc: Stefan Bader <stefan.bader@canonical.com>
> ---
>  drivers/net/xen-netfront.c |   58 +++++++++++++++++++++++++++++++++----------
>  1 files changed, 44 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index caa0110..a12b99a 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -452,24 +452,54 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
>  	/* Grant backend access to each skb fragment page. */
>  	for (i = 0; i < frags; i++) {
>  		skb_frag_t *frag = skb_shinfo(skb)->frags + i;
> +		struct page *page = skb_frag_page(frag);
> +		unsigned long size = skb_frag_size(frag);
> +		unsigned long offset = frag->page_offset;
>  
> -		tx->flags |= XEN_NETTXF_more_data;
> +		/* Data must not cross a page boundary. */
> +		BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
>  
> -		id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> -		np->tx_skbs[id].skb = skb_get(skb);
> -		tx = RING_GET_REQUEST(&np->tx, prod++);
> -		tx->id = id;
> -		ref = gnttab_claim_grant_reference(&np->gref_tx_head);
> -		BUG_ON((signed short)ref < 0);
> +		/* Skip unused frames from start of page */

'frame' in the comment means an order-0 page ?

> +		page += offset >> PAGE_SHIFT;
> +		offset &= ~PAGE_MASK;
>  
> -		mfn = pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
> -		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> -						mfn, GNTMAP_readonly);
> +		while (size > 0) {
> +			unsigned long bytes;
>  
> -		tx->gref = np->grant_tx_ref[id] = ref;
> -		tx->offset = frag->page_offset;
> -		tx->size = skb_frag_size(frag);
> -		tx->flags = 0;
> +			BUG_ON(offset >= PAGE_SIZE);
> +
> +			bytes = PAGE_SIZE - offset;
> +			if (bytes > size)
> +				bytes = size;
> +
> +			tx->flags |= XEN_NETTXF_more_data;
> +
> +			id = get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> +			np->tx_skbs[id].skb = skb_get(skb);

BTW this skb_get() means extra atomic operations for every 4096 bytes
unit, and an extra atomic op (and test for final 0) at TX completion.
This could be avoided, by setting np->tx_skbs[id].skb = skb only for the
very last unit.

> +			tx = RING_GET_REQUEST(&np->tx, prod++);
> +			tx->id = id;
> +			ref = gnttab_claim_grant_reference(&np->gref_tx_head);
> +			BUG_ON((signed short)ref < 0);
> +
> +			mfn = pfn_to_mfn(page_to_pfn(page));
> +			gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> +							mfn, GNTMAP_readonly);
> +
> +			tx->gref = np->grant_tx_ref[id] = ref;
> +			tx->offset = offset;
> +			tx->size = bytes;
> +			tx->flags = 0;
> +
> +			offset += bytes;
> +			size -= bytes;
> +
> +			/* Next frame */
> +			if (offset == PAGE_SIZE && size) {
> +				BUG_ON(!PageCompound(page));
> +				page++;
> +				offset = 0;
> +			}
> +		}
>  	}
>  
>  	np->tx.req_prod_pvt = prod;

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
