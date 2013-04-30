From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next V7 3/4] xen-netback: coalesce
 slots in TX path and fix regressions
Date: Tue, 30 Apr 2013 13:59:59 +0100
Message-ID: <517FDC6F02000078000D21B8@nat28.tlf.novell.com>
References: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
 <1366633243-17775-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <davem@davemloft.net>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:35552 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759848Ab3D3M7T convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 30 Apr 2013 08:59:19 -0400
In-Reply-To: <1366633243-17775-4-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 22.04.13 at 14:20, Wei Liu <wei.liu2@citrix.com> wrote:
> @@ -898,47 +928,78 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  
>  static int netbk_count_requests(struct xenvif *vif,
>  				struct xen_netif_tx_request *first,
> +				RING_IDX first_idx,
>  				struct xen_netif_tx_request *txp,
>  				int work_to_do)
>  {
>  	RING_IDX cons = vif->tx.req_cons;

It looks bogus and confusing to me to pass first_idx into this
function when this really is the same as cons.

Jan

> -	int frags = 0;
> +	int slots = 0;
> +	int drop_err = 0;
>  
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
>  
>  	do {
> -		if (frags >= work_to_do) {
> -			netdev_err(vif->dev, "Need more frags\n");
> +		if (slots >= work_to_do) {
> +			netdev_err(vif->dev,
> +				   "Asked for %d slots but exceeds this limit\n",
> +				   work_to_do);
>  			netbk_fatal_tx_err(vif);
>  			return -ENODATA;
>  		}
>  
> -		if (unlikely(frags >= MAX_SKB_FRAGS)) {
> -			netdev_err(vif->dev, "Too many frags\n");
> +		/* This guest is really using too many slots and
> +		 * considered malicious.
> +		 */
> +		if (unlikely(slots >= max_skb_slots)) {
> +			netdev_err(vif->dev,
> +				   "Malicious frontend using %d slots, threshold %u\n",
> +				   slots, max_skb_slots);
>  			netbk_fatal_tx_err(vif);
>  			return -E2BIG;
>  		}
>  
> -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> +		/* Xen network protocol had implicit dependency on
> +		 * MAX_SKB_FRAGS. XEN_NETIF_NR_SLOTS_MIN is set to the
> +		 * historical MAX_SKB_FRAGS value 18 to honor the same
> +		 * behavior as before. Any packet using more than 18
> +		 * slots but less than max_skb_slots slots is dropped
> +		 */
> +		if (!drop_err && slots >= XEN_NETIF_NR_SLOTS_MIN) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev,
> +					   "Too many slots (%d) exceeding limit (%d), dropping packet\n",
> +					   slots, XEN_NETIF_NR_SLOTS_MIN);
> +			drop_err = -E2BIG;
> +		}
> +
> +		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>  		       sizeof(*txp));
>  		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
> +			netdev_err(vif->dev,
> +				   "Invalid tx request, slot size %u > remaining size %u\n",
> +				   txp->size, first->size);
>  			netbk_fatal_tx_err(vif);
>  			return -EIO;
>  		}
>  
>  		first->size -= txp->size;
> -		frags++;
> +		slots++;
>  
>  		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
> -			netdev_err(vif->dev, "txp->offset: %x, size: %u\n",
> +			netdev_err(vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
>  				 txp->offset, txp->size);
>  			netbk_fatal_tx_err(vif);
>  			return -EINVAL;
>  		}
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
> -	return frags;
> +
> +	if (drop_err) {
> +		netbk_tx_err(vif, first, first_idx + slots);
> +		return drop_err;
> +	}
> +
> +	return slots;
>  }
>  
>  static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
