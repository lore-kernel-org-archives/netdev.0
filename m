From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Fri, 13 Dec 2013 15:31:39 +0000
Message-ID: <20131213153138.GL21900@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386892097-15502-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 11:48:09PM +0000, Zoltan Kiss wrote:
> This patch contains the new definitions necessary for grant mapping.
> 
> v2:
> - move unmapping to separate thread. The NAPI instance has to be scheduled
>   even from thread context, which can cause huge delays
> - that causes unfortunately bigger struct xenvif
> - store grant handle after checking validity
> 

If the size of xenvif really becomes a problem, you can try to make
sratch space like struct gnttab_copy per-cpu. The downside is that
approach requires much coding and carefully guard against race
conditions. You would need to consider cost v.s. benefit.

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
> ---
[...]
>  #define XENVIF_QUEUE_LENGTH 32
>  #define XENVIF_NAPI_WEIGHT  64
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index c1b7a42..3ddc474 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -772,6 +772,20 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
>  	return page;
>  }
>  
> +static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
> +	       struct xen_netif_tx_request *txp,
> +	       struct gnttab_map_grant_ref *gop)
> +{
> +	vif->pages_to_map[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
> +	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
> +			  GNTMAP_host_map | GNTMAP_readonly,
> +			  txp->gref, vif->domid);
> +
> +	memcpy(&vif->pending_tx_info[pending_idx].req, txp,
> +	       sizeof(*txp));
> +
> +}
> +

This helper function is not used until next patch. Probably you can move
it to the second patch.

The same applies to other helper functions as well. Move them to the
patch they are used. It would be easier for people to review.

>  static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
>  					       struct sk_buff *skb,
>  					       struct xen_netif_tx_request *txp,
> @@ -1593,6 +1607,106 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  	return work_done;
>  }
>  
> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
> +{

Do we care about zerocopy_success? I don't see it used in this function.

> +	unsigned long flags;
> +	pending_ring_idx_t index;
> +	u16 pending_idx = ubuf->desc;
> +	struct pending_tx_info *temp =
> +		container_of(ubuf, struct pending_tx_info, callback_struct);
> +	struct xenvif *vif =
> +		container_of(temp - pending_idx, struct xenvif,
> +			pending_tx_info[0]);
> +

The third parameter to container_of should be the name of the member
within the struct.

> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
> +	do {
> +		pending_idx = ubuf->desc;
> +		ubuf = (struct ubuf_info *) ubuf->ctx;
> +		index = pending_index(vif->dealloc_prod);
> +		vif->dealloc_ring[index] = pending_idx;
> +		/* Sync with xenvif_tx_action_dealloc:
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
> +		/* Ensure we see all indices enqueued by netif_idx_release(). */

There is no netif_idx_release in netback code. :-)

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
> +			}

Should this be BUG_ON? AIUI this kthread should be the only one doing
unmap, right?

> +
> +			pending_idx_release[gop-vif->tx_unmap_ops] =
> +				pending_idx;
> +			vif->pages_to_unmap[gop-vif->tx_unmap_ops] =
> +				vif->mmap_pages[pending_idx];
> +			gnttab_set_unmap_op(gop,
> +					idx_to_kaddr(vif, pending_idx),
> +					GNTMAP_host_map,
> +					vif->grant_tx_handle[pending_idx]);
> +			vif->grant_tx_handle[pending_idx] =
> +				NETBACK_INVALID_HANDLE;
> +			++gop;
> +		}
> +
[...]
> +}
>  
>  static void make_tx_response(struct xenvif *vif,
>  			     struct xen_netif_tx_request *txp,
> @@ -1720,6 +1854,14 @@ static inline int tx_work_todo(struct xenvif *vif)
>  	return 0;
>  }
>  
> +static inline int tx_dealloc_work_todo(struct xenvif *vif)

static inline bool

Wei.
