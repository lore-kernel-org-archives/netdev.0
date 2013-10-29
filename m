From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: allocate xenvif arrays using
 vzalloc.
Date: Tue, 29 Oct 2013 15:50:18 +0000
Message-ID: <20131029155018.GK5221@zion.uk.xensource.com>
References: <20131029152628.GA3065@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<andrew.bennieston@citrix.com>, <david.vrabel@citrix.com>,
	<malcolm.crossley@citrix.com>
To: Joby Poriyath <joby.poriyath@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:51883 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618Ab3J2PuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 11:50:21 -0400
Content-Disposition: inline
In-Reply-To: <20131029152628.GA3065@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 03:27:13PM +0000, Joby Poriyath wrote:
[...]
> +
> +static int allocate_xenvif_arrays(struct xenvif *vif)
> +{
> +	vif->mmap_pages = vif->pending_tx_info = NULL;
> +	vif->tx_copy_ops = vif->grant_copy_op = vif->meta = NULL;
> +
> +	vif->mmap_pages = vzalloc(MAX_PENDING_REQS * sizeof(struct page *));
> +	if (! vif->mmap_pages)

No space after "!".

> +		goto fail;
> +
> +	vif->pending_tx_info = vzalloc(MAX_PENDING_REQS * 
> +					sizeof(struct pending_tx_info));
> +	if (! vif->pending_tx_info)
> +		goto fail;
> +
> +	vif->tx_copy_ops = vzalloc(2 * MAX_PENDING_REQS *
> +					sizeof(struct gnttab_copy));
> +	if (! vif->tx_copy_ops)
> +		goto fail;
> +
> +	vif->grant_copy_op = vzalloc(2 * XEN_NETIF_RX_RING_SIZE *
> +					sizeof(struct gnttab_copy));
> +	if (! vif->grant_copy_op)
> +		goto fail;
> +
> +	vif->meta = vzalloc(2 * XEN_NETIF_RX_RING_SIZE *
> +					sizeof(struct xenvif_rx_meta));

Indentation.

> +	if (! vif->meta)
> +		goto fail;
> +
> +	return 0;
> +
> +fail:
> +	deallocate_xenvif_arrays(vif);
> +	return 1;

return -ENOMEM;

> +}
> +
>  struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  			    unsigned int handle)
>  {
> @@ -313,6 +367,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	vif->ip_csum = 1;
>  	vif->dev = dev;
>  
> +	if (allocate_xenvif_arrays(vif)) {
> +		netdev_warn(dev, "Could not create device: out of memory\n");
> +		free_netdev(dev);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
>  	vif->credit_bytes = vif->remaining_credit = ~0UL;
>  	vif->credit_usec  = 0UL;
>  	init_timer(&vif->credit_timeout);
> @@ -484,6 +544,7 @@ void xenvif_free(struct xenvif *vif)
>  
>  	unregister_netdev(vif->dev);
>  
> +	deallocate_xenvif_arrays(vif);
>  	free_netdev(vif->dev);
>  
>  	module_put(THIS_MODULE);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 828fdab..34c0c05 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -602,12 +602,12 @@ void xenvif_rx_action(struct xenvif *vif)
>  			break;
>  	}
>  
> -	BUG_ON(npo.meta_prod > ARRAY_SIZE(vif->meta));
> +	BUG_ON(npo.meta_prod > 2*XEN_NETIF_RX_RING_SIZE);
>  
>  	if (!npo.copy_prod)
>  		return;
>  
> -	BUG_ON(npo.copy_prod > ARRAY_SIZE(vif->grant_copy_op));
> +	BUG_ON(npo.copy_prod > 2*XEN_NETIF_RX_RING_SIZE);

It's better to

  #define XEN_NETBK_RX_ARRAY_SIZE (2*XEN_NETIF_RX_RING_SIZE)

And use it consistently in code (allocation / comparison). Otherwise
it's easy to change one site and forget about others.

>  	gnttab_batch_copy(vif->grant_copy_op, npo.copy_prod);
>  
>  	while ((skb = __skb_dequeue(&rxq)) != NULL) {
> @@ -1571,7 +1571,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
>  
>  		vif->tx.req_cons = idx;
>  
> -		if ((gop-vif->tx_copy_ops) >= ARRAY_SIZE(vif->tx_copy_ops))
> +		if ((gop-vif->tx_copy_ops) >= 2*MAX_PENDING_REQS)

Same here.

  #define XEN_NETBK_TX_ARRAY_SIZE

Wei.
