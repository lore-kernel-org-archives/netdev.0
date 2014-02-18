From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Tue, 18 Feb 2014 17:06:54 +0000
Message-ID: <1392743214.23084.38.camel@kazak.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
	 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
> This patch contains the new definitions necessary for grant mapping.

Is this just adding a bunch of (currently) unused functions? That's a
slightly odd way to structure a series. They don't seem to be "generic
helpers" or anything so it would be more normal to introduce these as
they get used -- it's a bit hard to review them out of context.

> v2:

This sort of intraversion changelog should go after the S-o-b and a
"---" marker. This way they are not included in the final commit
message.

[...]
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
---

v2: Blah blah

v3: Etc etc


> @@ -226,6 +248,12 @@ bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed);
>  
>  void xenvif_stop_queue(struct xenvif *vif);
>  
> +/* Callback from stack when TX packet can be released */
> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
> +
> +/* Unmap a pending page, usually has to be called before xenvif_idx_release */

"usually" or always? How does one determine when it is or isn't
appropriate to call it later?

> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
> +
>  extern bool separate_tx_rx_irq;
>  
>  #endif /* __XEN_NETBACK__COMMON_H__ */
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 7669d49..f0f0c3d 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -38,6 +38,7 @@
>  
>  #include <xen/events.h>
>  #include <asm/xen/hypercall.h>
> +#include <xen/balloon.h>

What is this for?
 
>  #define XENVIF_QUEUE_LENGTH 32
>  #define XENVIF_NAPI_WEIGHT  64
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index bb241d0..195602f 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -773,6 +773,20 @@ static struct page *xenvif_alloc_page(struct xenvif *vif,
>  	return page;
>  }
>  
> +static inline void xenvif_tx_create_gop(struct xenvif *vif,
> +					u16 pending_idx,
> +					struct xen_netif_tx_request *txp,
> +					struct gnttab_map_grant_ref *gop)
> +{
> +	vif->pages_to_map[gop-vif->tx_map_ops] = vif->mmap_pages[pending_idx];
> +	gnttab_set_map_op(gop, idx_to_kaddr(vif, pending_idx),
> +			  GNTMAP_host_map | GNTMAP_readonly,
> +			  txp->gref, vif->domid);
> +
> +	memcpy(&vif->pending_tx_info[pending_idx].req, txp,
> +	       sizeof(*txp));

Can this not go in xenvif_tx_build_gops? Or conversely should the
non-mapping code there be factored out?

Given the presence of both kinds of gop the name of this function needs
to be more specific I think.

> +}
> +
>  static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
>  					       struct sk_buff *skb,
>  					       struct xen_netif_tx_request *txp,
> @@ -1612,6 +1626,107 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  	return work_done;
>  }
>  
> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
> +{
> +	unsigned long flags;
> +	pending_ring_idx_t index;
> +	u16 pending_idx = ubuf->desc;
> +	struct pending_tx_info *temp =
> +		container_of(ubuf, struct pending_tx_info, callback_struct);
> +	struct xenvif *vif = container_of(temp - pending_idx,

This is subtracting a u16 from a pointer?

> +					  struct xenvif,
> +					  pending_tx_info[0]);
> +
> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
> +	do {
> +		pending_idx = ubuf->desc;
> +		ubuf = (struct ubuf_info *) ubuf->ctx;
> +		index = pending_index(vif->dealloc_prod);
> +		vif->dealloc_ring[index] = pending_idx;
> +		/* Sync with xenvif_tx_dealloc_action:
> +		 * insert idx then incr producer.
> +		 */
> +		smp_wmb();

Is this really needed given that there is a lock held?

Or what is dealloc_lock protecting against?

> +		vif->dealloc_prod++;

What happens if the dealloc ring becomes full, will this wrap and cause
havoc?

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
> +					   "Trying to unmap invalid handle! "
> +					   "pending_idx: %x\n", pending_idx);
> +				BUG();
> +			}
> +
> +			pending_idx_release[gop-vif->tx_unmap_ops] =
> +				pending_idx;
> +			vif->pages_to_unmap[gop-vif->tx_unmap_ops] =
> +				vif->mmap_pages[pending_idx];
> +			gnttab_set_unmap_op(gop,
> +					    idx_to_kaddr(vif, pending_idx),
> +					    GNTMAP_host_map,
> +					    vif->grant_tx_handle[pending_idx]);
> +			vif->grant_tx_handle[pending_idx] =
> +				NETBACK_INVALID_HANDLE;
> +			++gop;

Can we run out of space in the gop array?

> +		}
> +
> +	} while (dp != vif->dealloc_prod);
> +
> +	vif->dealloc_cons = dc;

No barrier here?

> +	if (gop - vif->tx_unmap_ops > 0) {
> +		int ret;
> +		ret = gnttab_unmap_refs(vif->tx_unmap_ops,
> +					vif->pages_to_unmap,
> +					gop - vif->tx_unmap_ops);
> +		if (ret) {
> +			netdev_err(vif->dev, "Unmap fail: nr_ops %x ret %d\n",
> +				   gop - vif->tx_unmap_ops, ret);
> +			for (i = 0; i < gop - vif->tx_unmap_ops; ++i) {

This seems liable to be a lot of spew on failure. Perhaps only log the
ones where gop[i].status != success.

Have you considered whether or not the frontend can force this error to
occur?

> +				netdev_err(vif->dev,
> +					   " host_addr: %llx handle: %x status: %d\n",
> +					   gop[i].host_addr,
> +					   gop[i].handle,
> +					   gop[i].status);
> +			}
> +			BUG();
> +		}
> +	}
> +
> +	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
> +		xenvif_idx_release(vif, pending_idx_release[i],
> +				   XEN_NETIF_RSP_OKAY);
> +}
> +
> +
>  /* Called after netfront has transmitted */
>  int xenvif_tx_action(struct xenvif *vif, int budget)
>  {
> @@ -1678,6 +1793,25 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>  	vif->mmap_pages[pending_idx] = NULL;
>  }
>  
> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)

This is a single shot version of the batched xenvif_tx_dealloc_action
version? Why not just enqueue the idx to be unmapped later?

> +{
> +	int ret;
> +	struct gnttab_unmap_grant_ref tx_unmap_op;
> +
> +	if (vif->grant_tx_handle[pending_idx] == NETBACK_INVALID_HANDLE) {
> +		netdev_err(vif->dev,
> +			   "Trying to unmap invalid handle! pending_idx: %x\n",
> +			   pending_idx);
> +		BUG();
> +	}
> +	gnttab_set_unmap_op(&tx_unmap_op,
> +			    idx_to_kaddr(vif, pending_idx),
> +			    GNTMAP_host_map,
> +			    vif->grant_tx_handle[pending_idx]);
> +	ret = gnttab_unmap_refs(&tx_unmap_op, &vif->mmap_pages[pending_idx], 1);
> +	BUG_ON(ret);
> +	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
> +}
>  
>  static void make_tx_response(struct xenvif *vif,
>  			     struct xen_netif_tx_request *txp,
> @@ -1740,6 +1874,11 @@ static inline int tx_work_todo(struct xenvif *vif)
>  	return 0;
>  }
>  
> +static inline bool tx_dealloc_work_todo(struct xenvif *vif)
> +{
> +	return vif->dealloc_cons != vif->dealloc_prod
> +}
> +
>  void xenvif_unmap_frontend_rings(struct xenvif *vif)
>  {
>  	if (vif->tx.sring)
> @@ -1826,6 +1965,28 @@ int xenvif_kthread(void *data)
>  	return 0;
>  }
>  
> +int xenvif_dealloc_kthread(void *data)

Is this going to be a thread per vif?

> +{
> +	struct xenvif *vif = data;
> +
> +	while (!kthread_should_stop()) {
> +		wait_event_interruptible(vif->dealloc_wq,
> +					 tx_dealloc_work_todo(vif) ||
> +					 kthread_should_stop());
> +		if (kthread_should_stop())
> +			break;
> +
> +		xenvif_tx_dealloc_action(vif);
> +		cond_resched();
> +	}
> +
> +	/* Unmap anything remaining*/
> +	if (tx_dealloc_work_todo(vif))
> +		xenvif_tx_dealloc_action(vif);
> +
> +	return 0;
> +}
> +
>  static int __init netback_init(void)
>  {
>  	int rc = 0;
