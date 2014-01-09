From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Thu, 9 Jan 2014 15:30:10 +0000
Message-ID: <20140109153010.GE12164@zion.uk.xensource.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
 <1389139818-24458-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>,
	Roger Pau =?iso-8859-1?Q?Monn=E9?= <roger.pau@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19525 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbaAIPaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 10:30:13 -0500
Content-Disposition: inline
In-Reply-To: <1389139818-24458-2-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 12:10:10AM +0000, Zoltan Kiss wrote:
> This patch contains the new definitions necessary for grant mapping.
> 
> v2:
> - move unmapping to separate thread. The NAPI instance has to be scheduled
>   even from thread context, which can cause huge delays
> - that causes unfortunately bigger struct xenvif
> - store grant handle after checking validity
> 
> v3:
> - fix comment in xenvif_tx_dealloc_action()
> - call unmap hypercall directly instead of gnttab_unmap_refs(), which does
>   unnecessary m2p_override. Also remove pages_to_[un]map members

Is it worthy to have another function call
gnttab_unmap_refs_no_m2p_override in Xen core driver, or just add a
parameter to control wether we need to touch m2p_override? I *think* it
will benefit block driver as well?

(CC Roger and David for input)

> - BUG() if grant_tx_handle corrupted
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
> ---
[...]
>  
>  #define XENVIF_QUEUE_LENGTH 32
>  #define XENVIF_NAPI_WEIGHT  64
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index addfe1d1..7c241f9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -771,6 +771,19 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
>  	return page;
>  }
>  
> +static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
> +	       struct xen_netif_tx_request *txp,
> +	       struct gnttab_map_grant_ref *gop)

Indentation.

> +{
> +	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
> +			  GNTMAP_host_map | GNTMAP_readonly,
> +			  txp->gref, vif->domid);
> +
> +	memcpy(&vif->pending_tx_info[pending_idx].req, txp,
> +	       sizeof(*txp));
> +
> +}
> +
[...]
> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
> +{
> +	unsigned long flags;
> +	pending_ring_idx_t index;
> +	u16 pending_idx = ubuf->desc;
> +	struct pending_tx_info *temp =
> +		container_of(ubuf, struct pending_tx_info, callback_struct);
> +	struct xenvif *vif =
> +		container_of(temp - pending_idx, struct xenvif,
> +			pending_tx_info[0]);

Indentation.

> +
> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
> +	do {
> +		pending_idx = ubuf->desc;
> +		ubuf = (struct ubuf_info *) ubuf->ctx;
> +		index = pending_index(vif->dealloc_prod);
> +		vif->dealloc_ring[index] = pending_idx;
> +		/* Sync with xenvif_tx_action_dealloc:

xenvif_tx_dealloc_action I suppose.

> +		 * insert idx then incr producer.
> +		 */
> +		smp_wmb();
> +		vif->dealloc_prod++;
> +	} while (ubuf);
> +	wake_up(&vif->dealloc_wq);
> +	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
> +}
> +
> +static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
> +{
> +	struct gnttab_unmap_grant_ref *gop;
> +	pending_ring_idx_t dc, dp;
> +	u16 pending_idx, pending_idx_release[MAX_PENDING_REQS];
> +	unsigned int i = 0;
> +
> +	dc = vif->dealloc_cons;
> +	gop = vif->tx_unmap_ops;
> +
> +	/* Free up any grants we have finished using */
> +	do {
> +		dp = vif->dealloc_prod;
> +
> +		/* Ensure we see all indices enqueued by all
> +		 * xenvif_zerocopy_callback().
> +		 */
> +		smp_rmb();
> +
> +		while (dc != dp) {
> +			pending_idx =
> +				vif->dealloc_ring[pending_index(dc++)];
> +
> +			/* Already unmapped? */
> +			if (vif->grant_tx_handle[pending_idx] ==
> +				NETBACK_INVALID_HANDLE) {
> +				netdev_err(vif->dev,
> +					"Trying to unmap invalid handle! "
> +					"pending_idx: %x\n", pending_idx);
> +				continue;

You seemed to miss the BUG_ON we discussed?

See thread starting <52AF1A84.3090304@citrix.com>.

Wei.

> +			}
> +
> +			pending_idx_release[gop-vif->tx_unmap_ops] =
> +				pending_idx;
> +			gnttab_set_unmap_op(gop,
> +					idx_to_kaddr(vif, pending_idx),
> +					GNTMAP_host_map,
> +					vif->grant_tx_handle[pending_idx]);
> +			vif->grant_tx_handle[pending_idx] =
> +				NETBACK_INVALID_HANDLE;
> +			++gop;
> +		}
> +
