From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 12:28:13 +0000
Message-ID: <50AB856D02000078000A9EFD@nat28.tlf.novell.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
 <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Stefan Bader" <stefan.bader@canonical.com>,
	"Sander Eikelenboom" <linux@eikelenboom.it>,
	"Eric Dumazet" <edumazet@google.com>,
	"Konrad Rzeszutek Wilk" <konrad@kernel.org>,
	<xen-devel@lists.xen.org>, "ANNIE LI" <annie.li@oracle.com>,
	<netdev@vger.kernel.org>
To: "Ian Campbell" <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:54979 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab2KTM1U convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:8:1>);
	Tue, 20 Nov 2012 07:27:20 -0500
In-Reply-To: <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 20.11.12 at 12:40, Ian Campbell <ian.campbell@citrix.com> wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
> 
> Handle this in xennet_make_frags by iterating over the frames which
> make up the page.
> 
> This is the netfront equivalent to 6a8ed462f16b for netback.

Wouldn't you need to be at least a little more conservative here
with respect to resource use: I realize that get_id_from_freelist()
return values were never checked, and failure of
gnttab_claim_grant_reference() was always dealt with via
BUG_ON(), but considering that netfront_tx_slot_available()
doesn't account for compound page fragments, I think this (lack
of) error handling needs improvement in the course of the
change here (regardless of - I think - someone having said that
usually the sum of all pages referenced from an skb's fragments
would not exceed MAX_SKB_FRAGS - "usually" just isn't enough
imo).

Jan

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
> @@ -452,24 +452,54 @@ static void xennet_make_frags(struct sk_buff *skb, 
> struct net_device *dev,
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
> -- 
> 1.7.2.5
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org 
> http://lists.xen.org/xen-devel 
