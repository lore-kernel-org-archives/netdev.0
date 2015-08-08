From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v3 18/20] net/xen-netback: Make it running on 64KB page
 granularity
Date: Sat, 8 Aug 2015 15:55:34 +0100
Message-ID: <20150808145534.GB14214@zion.uk.xensource.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-19-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438966019-19322-19-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 07, 2015 at 05:46:57PM +0100, Julien Grall wrote:
> The PV network protocol is using 4KB page granularity. The goal of this
> patch is to allow a Linux using 64KB page granularity working as a
> network backend on a non-modified Xen.
> 
> It's only necessary to adapt the ring size and break skb data in small
> chunk of 4KB. The rest of the code is relying on the grant table code.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> 
> ---
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: netdev@vger.kernel.org
> 
[...]
> +#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, XEN_PAGE_SIZE)
> +#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, XEN_PAGE_SIZE)
>  
>  struct xenvif_rx_meta {
>  	int id;
> @@ -80,16 +81,18 @@ struct xenvif_rx_meta {
>  /* Discriminate from any valid pending_idx value. */
>  #define INVALID_PENDING_IDX 0xFFFF
>  
> -#define MAX_BUFFER_OFFSET PAGE_SIZE
> +#define MAX_BUFFER_OFFSET XEN_PAGE_SIZE
>  
>  #define MAX_PENDING_REQS XEN_NETIF_TX_RING_SIZE
>  
> +#define MAX_XEN_SKB_FRAGS (65536 / XEN_PAGE_SIZE + 1)
> +

It might be clearer if you add a comment saying the maximum number of
frags is derived from the page size of the grant page, which happens to
be XEN_PAGE_SIZE at the moment. 

In the future we need to figure out the page size of grant page in a
dynamic way. We shall cross the bridge when we get there.

>  /* It's possible for an skb to have a maximal number of frags
>   * but still be less than MAX_BUFFER_OFFSET in size. Thus the
> - * worst-case number of copy operations is MAX_SKB_FRAGS per
> + * worst-case number of copy operations is MAX_XEN_SKB_FRAGS per
>   * ring slot.
>   */
> -#define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
> +#define MAX_GRANT_COPY_OPS (MAX_XEN_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
>  
>  #define NETBACK_INVALID_HANDLE -1
>  
> @@ -203,7 +206,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>  /* Maximum number of Rx slots a to-guest packet may use, including the
>   * slot needed for GSO meta-data.
>   */
> -#define XEN_NETBK_RX_SLOTS_MAX (MAX_SKB_FRAGS + 1)
> +#define XEN_NETBK_RX_SLOTS_MAX ((MAX_XEN_SKB_FRAGS + 1))
>  
>  enum state_bit_shift {
>  	/* This bit marks that the vif is connected */
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 66f1780..c32a9f2 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -263,6 +263,80 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif_queue *queue,
>  	return meta;
>  }
>  
[...]
>   * Set up the grant operations for this fragment. If it's a flipping
>   * interface, we also set up the unmap request from here.
> @@ -272,83 +346,52 @@ static void xenvif_gop_frag_copy(struct xenvif_queue *queue, struct sk_buff *skb
>  				 struct page *page, unsigned long size,
>  				 unsigned long offset, int *head)
>  {
> -	struct gnttab_copy *copy_gop;
> -	struct xenvif_rx_meta *meta;
> +	struct gop_frag_copy info = {
> +		.queue = queue,
> +		.npo = npo,
> +		.head = *head,
> +		.gso_type = XEN_NETIF_GSO_TYPE_NONE,
> +	};
>  	unsigned long bytes;
> -	int gso_type = XEN_NETIF_GSO_TYPE_NONE;
>  
>  	if (skb_is_gso(skb)) {
>  		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> -			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
>  		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> -			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +			info.gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
>  	}
>  
>  	/* Data must not cross a page boundary. */
>  	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
>  
> -	meta = npo->meta + npo->meta_prod - 1;
> +	info.meta = npo->meta + npo->meta_prod - 1;
>  
>  	/* Skip unused frames from start of page */
>  	page += offset >> PAGE_SHIFT;
>  	offset &= ~PAGE_MASK;
>  
>  	while (size > 0) {
> -		struct xen_page_foreign *foreign;
> -
>  		BUG_ON(offset >= PAGE_SIZE);
> -		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
> -
> -		if (npo->copy_off == MAX_BUFFER_OFFSET)
> -			meta = get_next_rx_buffer(queue, npo);
>  
>  		bytes = PAGE_SIZE - offset;
>  		if (bytes > size)
>  			bytes = size;
>  
> -		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
> -			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
> -
> -		copy_gop = npo->copy + npo->copy_prod++;
> -		copy_gop->flags = GNTCOPY_dest_gref;
> -		copy_gop->len = bytes;
> -
> -		foreign = xen_page_foreign(page);
> -		if (foreign) {
> -			copy_gop->source.domid = foreign->domid;
> -			copy_gop->source.u.ref = foreign->gref;
> -			copy_gop->flags |= GNTCOPY_source_gref;
> -		} else {
> -			copy_gop->source.domid = DOMID_SELF;
> -			copy_gop->source.u.gmfn =
> -				virt_to_gfn(page_address(page));
> -		}
> -		copy_gop->source.offset = offset;
> -
> -		copy_gop->dest.domid = queue->vif->domid;
> -		copy_gop->dest.offset = npo->copy_off;
> -		copy_gop->dest.u.ref = npo->copy_gref;
> -
> -		npo->copy_off += bytes;
> -		meta->size += bytes;
> -
> -		offset += bytes;
> +		info.page = page;
> +		gnttab_foreach_grant_in_range(page, offset, bytes,
> +					      xenvif_gop_frag_copy_grant,
> +					      &info);

Looks like I need to at least wait until the API is settle before giving
my ack.

>  		size -= bytes;
> +		offset = 0;

This looks wrong. Should be offset += bytes.

>  
> -		/* Next frame */
> -		if (offset == PAGE_SIZE && size) {
> +		/* Next page */
> +		if (size) {
>  			BUG_ON(!PageCompound(page));
>  			page++;
> -			offset = 0;

And this should not be deleted, I think.

What is the reason for changing offset calculation? I think there is
still compound page when using 64K page.

>  		}
> -
> -		/* Leave a gap for the GSO descriptor. */
> -		if (*head && ((1 << gso_type) & queue->vif->gso_mask))
> -			queue->rx.req_cons++;
> -
> -		*head = 0; /* There must be something in this buffer now. */
> -
>  	}
> +
> +	*head = info.head;
>  }
>  

The reset looks OK.

Wei.
