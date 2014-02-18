From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v5 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Tue, 18 Feb 2014 17:40:35 +0000
Message-ID: <1392745235.23084.60.camel@kazak.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
	 <1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390253069-25507-3-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
> This patch changes the grant copy on the TX patch to grant mapping

Both this and the previous patch had a single sentence commit message (I
count them together since they are split weirdly and are a single
logical change to my eyes).

Really a change of this magnitude deserves a commit message to match,
e.g. explaining the approach which is taken by the code at a high level,
what it is doing, how it is doing it, the rationale for using a kthread
etc etc.

> 
> v2:
> - delete branch for handling fragmented packets fit PKT_PROT_LEN sized first
>   request
> - mark the effect of using ballooned pages in a comment
> - place setting of skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY right
>   before netif_receive_skb, and mark the importance of it
> - grab dealloc_lock before __napi_complete to avoid contention with the
>   callback's napi_schedule
> - handle fragmented packets where first request < PKT_PROT_LEN
> - fix up error path when checksum_setup failed
> - check before teardown for pending grants, and start complain if they are
>   there after 10 second
> 
> v3:
> - delete a surplus checking from tx_action
> - remove stray line
> - squash xenvif_idx_unmap changes into the first patch
> - init spinlocks
> - call map hypercall directly instead of gnttab_map_refs()
> - fix unmapping timeout in xenvif_free()
> 
> v4:
> - fix indentations and comments
> - handle errors of set_phys_to_machine
> - go back to gnttab_map_refs instead of direct hypercall. Now we rely on the
>   modified API
> 
> v5:
> - BUG_ON(vif->dealloc_task) in xenvif_connect
> - use 'task' in xenvif_connect for thread creation
> - proper return value if alloc_xenballooned_pages fails
> - BUG in xenvif_tx_check_gop if stale handle found
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   63 ++++++++-
>  drivers/net/xen-netback/netback.c   |  254 ++++++++++++++---------------------
>  2 files changed, 160 insertions(+), 157 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index f0f0c3d..b3daae2 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -122,7 +122,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	BUG_ON(skb->dev != dev);
>  
>  	/* Drop the packet if vif is not ready */
> -	if (vif->task == NULL || !xenvif_schedulable(vif))
> +	if (vif->task == NULL ||
> +	    vif->dealloc_task == NULL ||

Under what conditions could this be true? Would it not represent a
rather serious failure?

> +	    !xenvif_schedulable(vif))
>  		goto drop;
>  
>  	/* At best we'll need one slot for the header and one for each
> @@ -344,8 +346,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	vif->pending_prod = MAX_PENDING_REQS;
>  	for (i = 0; i < MAX_PENDING_REQS; i++)
>  		vif->pending_ring[i] = i;
> -	for (i = 0; i < MAX_PENDING_REQS; i++)
> -		vif->mmap_pages[i] = NULL;
> +	spin_lock_init(&vif->dealloc_lock);
> +	spin_lock_init(&vif->response_lock);
> +	/* If ballooning is disabled, this will consume real memory, so you
> +	 * better enable it.

Almost no one who would be affected by this is going to read this
comment. And it doesn't just require enabling ballooning, but actually
booting with some maxmem "slack" to leave space.

Classic-xen kernels used to add 8M of slop to the physical address space
to leave a suitable pool for exactly this sort of thing. I never liked
that but perhaps it should be reconsidered (or at least raised as a
possibility with the core-Xen Linux guys).

>  The long term solution would be to use just a
> +	 * bunch of valid page descriptors, without dependency on ballooning

Where would these come from? Do you have a cunning plan here?

> +	 */
> +	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
> +				       vif->mmap_pages,
> +				       false);
> +	if (err) {
> +		netdev_err(dev, "Could not reserve mmap_pages\n");
> +		return ERR_PTR(-ENOMEM);
> +	}
> +	for (i = 0; i < MAX_PENDING_REQS; i++) {
> +		vif->pending_tx_info[i].callback_struct = (struct ubuf_info)
> +			{ .callback = xenvif_zerocopy_callback,
> +			  .ctx = NULL,
> +			  .desc = i };
> +		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
> +	}
>  
>  	/*
>  	 * Initialise a dummy MAC address. We choose the numerically
> @@ -383,12 +403,14 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  
>  	BUG_ON(vif->tx_irq);
>  	BUG_ON(vif->task);
> +	BUG_ON(vif->dealloc_task);
>  
>  	err = xenvif_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
>  	if (err < 0)
>  		goto err;
>  
>  	init_waitqueue_head(&vif->wq);
> +	init_waitqueue_head(&vif->dealloc_wq);
>  
>  	if (tx_evtchn == rx_evtchn) {
>  		/* feature-split-event-channels == 0 */
> @@ -432,6 +454,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  
>  	vif->task = task;
>  
> +	task = kthread_create(xenvif_dealloc_kthread,
> +					   (void *)vif,
> +					   "%s-dealloc",
> +					   vif->dev->name);

This is separate to the existing kthread that handles rx stuff. If they
cannot or should not be combined then I think the existing one needs
renaming, both the function and the thread itself in a precursor patch.

> @@ -494,6 +534,23 @@ void xenvif_disconnect(struct xenvif *vif)
>  
>  void xenvif_free(struct xenvif *vif)
>  {
> +	int i, unmap_timeout = 0;
> +
> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> +			unmap_timeout++;
> +			schedule_timeout(msecs_to_jiffies(1000));

What are we waiting for here? Have we taken any action to ensure that it
is going to happen, like kicking something?

> +			if (unmap_timeout > 9 &&

Why 9? Why not rely on net_ratelimit to DTRT? Or is it normal for this
to fail at least once?

> +			    net_ratelimit())
> +				netdev_err(vif->dev,

I thought there was a ratelimited netdev printk which combined the
limiting and the printing in one function call. Maybe I am mistaken.

> +					   "Page still granted! Index: %x\n",
> +					   i);
> +			i = -1;
> +		}
> +	}
> +
> +	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
> +
>  	netif_napi_del(&vif->napi);
>  
>  	unregister_netdev(vif->dev);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 195602f..747b428 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -646,9 +646,12 @@ static void xenvif_tx_err(struct xenvif *vif,
>  			  struct xen_netif_tx_request *txp, RING_IDX end)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
> +	unsigned long flags;
>  
>  	do {
> +		spin_lock_irqsave(&vif->response_lock, flags);

Looking at the callers you have added it would seem more natural to
handle the locking within make_tx_response itself.

What are you locking against here? Is this different to the dealloc
lock? If the concern is the rx action stuff and the dealloc stuff
conflicting perhaps a single vif lock would make sense?

>  		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
> +		spin_unlock_irqrestore(&vif->response_lock, flags);
>  		if (cons == end)
>  			break;
>  		txp = RING_GET_REQUEST(&vif->tx, cons++);
> @@ -787,10 +790,10 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif,
>  	       sizeof(*txp));
>  }
>  
> -static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
> -					       struct sk_buff *skb,
> -					       struct xen_netif_tx_request *txp,
> -					       struct gnttab_copy *gop)
> +static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
> +							struct sk_buff *skb,
> +							struct xen_netif_tx_request *txp,
> +							struct gnttab_map_grant_ref *gop)
>  {
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	skb_frag_t *frags = shinfo->frags;
> @@ -909,9 +841,9 @@ err:
>  
>  static int xenvif_tx_check_gop(struct xenvif *vif,
>  			       struct sk_buff *skb,
> -			       struct gnttab_copy **gopp)
> +			       struct gnttab_map_grant_ref **gopp)
>  {
> -	struct gnttab_copy *gop = *gopp;
> +	struct gnttab_map_grant_ref *gop = *gopp;
>  	u16 pending_idx = *((u16 *)skb->data);
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	struct pending_tx_info *tx_info;
> @@ -923,6 +855,17 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  	err = gop->status;
>  	if (unlikely(err))
>  		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
> +	else {
> +		if (vif->grant_tx_handle[pending_idx] !=
> +		    NETBACK_INVALID_HANDLE) {
> +			netdev_err(vif->dev,
> +				   "Stale mapped handle! pending_idx %x handle %x\n",
> +				   pending_idx,
> +				   vif->grant_tx_handle[pending_idx]);
> +			BUG();
> +		}
> +		vif->grant_tx_handle[pending_idx] = gop->handle;
> +	}
>  
>  	/* Skip first skb fragment if it is on same page as header fragment. */
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
> @@ -936,18 +879,24 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  		head = tx_info->head;
>  
>  		/* Check error status: if okay then remember grant handle. */
> -		do {
>  			newerr = (++gop)->status;
> -			if (newerr)
> -				break;
> -			peek = vif->pending_ring[pending_index(++head)];
> -		} while (!pending_tx_is_head(vif, peek));
>  
>  		if (likely(!newerr)) {
> +			if (vif->grant_tx_handle[pending_idx] !=
> +			    NETBACK_INVALID_HANDLE) {
> +				netdev_err(vif->dev,
> +					   "Stale mapped handle! pending_idx %x handle %x\n",
> +					   pending_idx,
> +					   vif->grant_tx_handle[pending_idx]);
> +				BUG();
> +			}

You had the same thing earlier. Perhaps a helper function would be
useful?

> +			vif->grant_tx_handle[pending_idx] = gop->handle;
>  			/* Had a previous error? Invalidate this fragment. */
> -			if (unlikely(err))
> +			if (unlikely(err)) {
> +				xenvif_idx_unmap(vif, pending_idx);
>  				xenvif_idx_release(vif, pending_idx,
>  						   XEN_NETIF_RSP_OKAY);

Would it make sense to unmap and release in a single function? (I
Haven't looked to see if you ever do one without the other, but the next
page of diff had two more occurrences of them together)

> +			}
>  			continue;
>  		}
>  
> @@ -960,9 +909,11 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  
>  		/* First error: invalidate header and preceding fragments. */
>  		pending_idx = *((u16 *)skb->data);
> +		xenvif_idx_unmap(vif, pending_idx);
>  		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
>  		for (j = start; j < i; j++) {
>  			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
> +			xenvif_idx_unmap(vif, pending_idx);
>  			xenvif_idx_release(vif, pending_idx,
>  					   XEN_NETIF_RSP_OKAY);
>  		}

>  	}
> +	/* FIXME: __skb_fill_page_desc set this to true because page->pfmemalloc
> +	 * overlaps with "index", and "mapping" is not set. I think mapping
> +	 * should be set. If delivered to local stack, it would drop this
> +	 * skb in sk_filter unless the socket has the right to use it.

What is the plan to fix this?

Is this dropping not a significant issue (TBH I'm not sure what "has the
right to use it" would entail).

> +	 */
> +	skb->pfmemalloc	= false;
>  }
>  
>  static int xenvif_get_extras(struct xenvif *vif,
> @@ -1372,7 +1341,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)

> @@ -1581,7 +1535,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		else if (txp->flags & XEN_NETTXF_data_validated)
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> -		xenvif_fill_frags(vif, skb);
> +		xenvif_fill_frags(vif,
> +				  skb,
> +				  skb_shinfo(skb)->destructor_arg ?
> +				  pending_idx :
> +				  INVALID_PENDING_IDX

Couldn't xenvif_fill_frags calculate the 3rd argument itself given that
it has skb in hand.

> );
>  
>  		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
>  			int target = min_t(int, skb->len, PKT_PROT_LEN);
> @@ -1595,6 +1553,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		if (checksum_setup(vif, skb)) {
>  			netdev_dbg(vif->dev,
>  				   "Can't setup checksum in net_tx_action\n");
> +			/* We have to set this flag so the dealloc thread can
> +			 * send the slots back

Wouldn't it be more accurate to say that we need it so that the callback
happens (which we then use to trigger the dealloc thread)?

> +			 */
> +			if (skb_shinfo(skb)->destructor_arg)
> +				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  			kfree_skb(skb);
>  			continue;
>  		}
> @@ -1620,6 +1583,14 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  
>  		work_done++;
>  
> +		/* Set this flag right before netif_receive_skb, otherwise
> +		 * someone might think this packet already left netback, and
> +		 * do a skb_copy_ubufs while we are still in control of the
> +		 * skb. E.g. the __pskb_pull_tail earlier can do such thing.

Hrm, subtle.

Ian.
