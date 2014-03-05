From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v6 4/10] xen-netback: Introduce TX grant mapping
Date: Wed, 5 Mar 2014 12:28:14 +0000
Message-ID: <20140305122814.GG19620@zion.uk.xensource.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com>
 <1393972341-21135-5-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393972341-21135-5-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 04, 2014 at 10:32:15PM +0000, Zoltan Kiss wrote:
> This patch introduces grant mapping on netback TX path. It replaces grant copy
> operations, ditching grant copy coalescing along the way. Another solution for
> copy coalescing is introduced in patch #7, older guests and Windows can broke
> before that patch applies.
> There is a callback (xenvif_zerocopy_callback) from core stack to release the
> slots back to the guests when kfree_skb or skb_orphan_frags called. It feeds a
> separate dealloc thread, as scheduling NAPI instance from there is inefficient,
> therefore we can't do dealloc from the instance.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
[...]
> Joint history:
> 
> v6:
> - I wanted to avoid napi_schedule in zerocopy_callback, as it has a performance
>   penalty if called from another vif thread's context. That's why I moved
>   dealloc to a separate thread. But there are certain situations where it's
>   necessary, so do it. Fortunately it doesn't happen too often, I couldn't see
>   performance regression in iperf tests
> - tx_dealloc_work_todo missing ;
> - introduce xenvif_tx_pending_slots_available() as that code is used often

It was introduced in other patch, not this one.

> - move some definitions to common.h due to previous
> - new ubuf_to_vif and xenvif_grant_handle_[re]set helpers
> - call xenvif_idx_release from xenvif_unmap insted of right after it
> - improve comments
> - add more BUG_ONs
> - check xenvif_tx_pending_slots_available before napi_complete, otherwise NAPI
>   will keep polling on that instance despite it can't do anything as there is no
>   room for pending requests. It becomes even worse if the pending packets are
>   waiting for an another instance on the same CPU.
> - xenvif_fill_frags handles prev_pending_idx independently
> 
>  drivers/net/xen-netback/common.h    |   33 ++-
>  drivers/net/xen-netback/interface.c |   67 +++++-
>  drivers/net/xen-netback/netback.c   |  424 ++++++++++++++++++++++-------------
>  3 files changed, 362 insertions(+), 162 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 2f6d772..de1b799 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -79,6 +79,11 @@ struct pending_tx_info {
>  				  * if it is head of one or more tx
>  				  * reqs
>  				  */
> +	/* callback data for released SKBs. The	callback is always
> +	 * xenvif_zerocopy_callback, ctx points to the next fragment, desc
> +	 * contains the pending_idx
> +	 */
> +	struct ubuf_info callback_struct;
>  };
>  
>  #define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> @@ -136,13 +141,31 @@ struct xenvif {
>  	pending_ring_idx_t pending_cons;
>  	u16 pending_ring[MAX_PENDING_REQS];
>  	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> +	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
>  
>  	/* Coalescing tx requests before copying makes number of grant
>  	 * copy ops greater or equal to number of slots required. In
>  	 * worst case a tx request consumes 2 gnttab_copy.
>  	 */
>  	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];

Forget to remove this?

> -
> +	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
> +	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
> +	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
> +	struct page *pages_to_map[MAX_PENDING_REQS];
> +	struct page *pages_to_unmap[MAX_PENDING_REQS];
> +
> +	/* This prevents zerocopy callbacks  to race over dealloc_ring */
> +	spinlock_t callback_lock;
> +	/* This prevents dealloc thread and NAPI instance to race over response
> +	 * creation and pending_ring in xenvif_idx_release. In xenvif_tx_err
> +	 * it only protect response creation
> +	 */
> +	spinlock_t response_lock;
> +	pending_ring_idx_t dealloc_prod;
> +	pending_ring_idx_t dealloc_cons;
> +	u16 dealloc_ring[MAX_PENDING_REQS];
> +	struct task_struct *dealloc_task;
> +	wait_queue_head_t dealloc_wq;
>  
[...]
> @@ -431,6 +455,18 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  
>  	vif->task = task;
>  
> +	task = kthread_create(xenvif_dealloc_kthread,
> +					   (void *)vif,
> +					   "%s-dealloc",
> +					   vif->dev->name);

Indentation.

> +	if (IS_ERR(task)) {
> +		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
> +		err = PTR_ERR(task);
> +		goto err_rx_unbind;
> +	}
> +
> +	vif->dealloc_task = task;
> +
[...]
>  
> +static inline void xenvif_grant_handle_set(struct xenvif *vif,
> +					   u16 pending_idx,
> +					   grant_handle_t handle)
> +{
> +	if (unlikely(vif->grant_tx_handle[pending_idx] !=
> +		     NETBACK_INVALID_HANDLE)) {
> +		netdev_err(vif->dev,
> +			   "Trying to unmap invalid handle! "
> +			   "pending_idx: %x\n", pending_idx);

This message is not very clear. I think it suits _reset but not here.
In this function the bug should be the attempt to over-write existing
handle, right?

> +		BUG();
> +	}
> +	vif->grant_tx_handle[pending_idx] = handle;
> +}
> +
[...]
> +
>  static int xenvif_tx_check_gop(struct xenvif *vif,
>  			       struct sk_buff *skb,
> -			       struct gnttab_copy **gopp)
> +			       struct gnttab_map_grant_ref **gopp)
>  {
> -	struct gnttab_copy *gop = *gopp;
> +	struct gnttab_map_grant_ref *gop = *gopp;
>  	u16 pending_idx = *((u16 *)skb->cb);
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	struct pending_tx_info *tx_info;
> @@ -927,6 +907,8 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  	err = gop->status;
>  	if (unlikely(err))
>  		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);

You don't need to replace this with xenvif_idx_unmap?

> +	else
> +		xenvif_grant_handle_set(vif, pending_idx , gop->handle);
>  
>  	/* Skip first skb fragment if it is on same page as header fragment. */
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
[...]
>  		/* Remember the error: invalidate all subsequent fragments. */
> @@ -984,6 +960,10 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	int nr_frags = shinfo->nr_frags;
>  	int i;
> +	u16 prev_pending_idx = INVALID_PENDING_IDX;
> +
> +	if (skb_shinfo(skb)->destructor_arg)
> +		prev_pending_idx = skb->cb;
>  
>  	for (i = 0; i < nr_frags; i++) {
>  		skb_frag_t *frag = shinfo->frags + i;
> @@ -993,6 +973,17 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
>  
>  		pending_idx = frag_get_pending_idx(frag);
>  
> +		/* If this is not the first frag, chain it to the previous*/
> +		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
> +			skb_shinfo(skb)->destructor_arg =
> +				&vif->pending_tx_info[pending_idx].callback_struct;
> +		else if (likely(pending_idx != prev_pending_idx))
> +			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
> +				&(vif->pending_tx_info[pending_idx].callback_struct);
> +

Could you document how these pending_tx_info'es are chained together? It
looks like it's still the same mechanism in coalescing, but I'm not
quite sure... And since you remove all definitions for coalescing in the
next patch we eventually reach a point that there's no document about
the mechanism at all, which is not good.

> +		vif->pending_tx_info[pending_idx].callback_struct.ctx = NULL;
> +		prev_pending_idx = pending_idx;
> +
>  		txp = &vif->pending_tx_info[pending_idx].req;
>  		page = virt_to_page(idx_to_kaddr(vif, pending_idx));
>  		__skb_fill_page_desc(skb, i, page, txp->offset, txp->size);
> @@ -1000,10 +991,15 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
>  		skb->data_len += txp->size;
>  		skb->truesize += txp->size;
>  
> -		/* Take an extra reference to offset xenvif_idx_release */
> +		/* Take an extra reference to offset network stack's put_page */
>  		get_page(vif->mmap_pages[pending_idx]);
> -		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);

So when is this slot released? Your previous changes basically replace
xenvif_idx_release with xenvif_idx_unmap, but not this one, why?

>  	}
> +	/* FIXME: __skb_fill_page_desc set this to true because page->pfmemalloc
> +	 * overlaps with "index", and "mapping" is not set. I think mapping
> +	 * should be set. If delivered to local stack, it would drop this
> +	 * skb in sk_filter unless the socket has the right to use it.
> +	 */
> +	skb->pfmemalloc	= false;
>  }
>  
>  static int xenvif_get_extras(struct xenvif *vif,
> @@ -1123,7 +1119,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  
[...]
>  
> +
>  /* Called after netfront has transmitted */
>  int xenvif_tx_action(struct xenvif *vif, int budget)
>  {
>  	unsigned nr_gops;
> -	int work_done;
> +	int work_done, ret;
>  
>  	if (unlikely(!tx_work_todo(vif)))
>  		return 0;
> @@ -1395,7 +1482,11 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  	if (nr_gops == 0)
>  		return 0;
>  
> -	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
> +	ret = gnttab_map_refs(vif->tx_map_ops,
> +			      NULL,
> +			      vif->pages_to_map,
> +			      nr_gops);
> +	BUG_ON(ret);
>  
>  	work_done = xenvif_tx_submit(vif);
>  
> @@ -1406,48 +1497,40 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>  			       u8 status)
>  {
>  	struct pending_tx_info *pending_tx_info;
> -	pending_ring_idx_t head;
> +	pending_ring_idx_t index;
>  	u16 peek; /* peek into next tx request */
> +	unsigned long flags;
>  
> -	BUG_ON(vif->mmap_pages[pending_idx] == (void *)(~0UL));
> -
> -	/* Already complete? */
> -	if (vif->mmap_pages[pending_idx] == NULL)
> -		return;
> -
> -	pending_tx_info = &vif->pending_tx_info[pending_idx];
> -
> -	head = pending_tx_info->head;
> -
> -	BUG_ON(!pending_tx_is_head(vif, head));
> -	BUG_ON(vif->pending_ring[pending_index(head)] != pending_idx);
> -
> -	do {
> -		pending_ring_idx_t index;
> -		pending_ring_idx_t idx = pending_index(head);
> -		u16 info_idx = vif->pending_ring[idx];
> -
> -		pending_tx_info = &vif->pending_tx_info[info_idx];
> +		pending_tx_info = &vif->pending_tx_info[pending_idx];

Is there indentation with this hunk? I don't see left bracket in this
function.

> +		spin_lock_irqsave(&vif->response_lock, flags);
>  		make_tx_response(vif, &pending_tx_info->req, status);
> +		index = pending_index(vif->pending_prod);
> +		vif->pending_ring[index] = pending_idx;
> +		/* TX shouldn't use the index before we give it back here */
> +		mb();
> +		vif->pending_prod++;
> +		spin_unlock_irqrestore(&vif->response_lock, flags);
> +}
>  
> -		/* Setting any number other than
> -		 * INVALID_PENDING_RING_IDX indicates this slot is
> -		 * starting a new packet / ending a previous packet.
> -		 */
> -		pending_tx_info->head = 0;
> -
> -		index = pending_index(vif->pending_prod++);
> -		vif->pending_ring[index] = vif->pending_ring[info_idx];
> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
> +{
> +	int ret;
> +	struct gnttab_unmap_grant_ref tx_unmap_op;
>  
> -		peek = vif->pending_ring[pending_index(++head)];
> +	gnttab_set_unmap_op(&tx_unmap_op,
> +			    idx_to_kaddr(vif, pending_idx),
> +			    GNTMAP_host_map,
> +			    vif->grant_tx_handle[pending_idx]);
> +	/* Btw. already unmapped? */
> +	xenvif_grant_handle_reset(vif, pending_idx);
>  
> -	} while (!pending_tx_is_head(vif, peek));
> +	ret = gnttab_unmap_refs(&tx_unmap_op, NULL,
> +				&vif->mmap_pages[pending_idx], 1);
> +	BUG_ON(ret);
>  
> -	put_page(vif->mmap_pages[pending_idx]);
> -	vif->mmap_pages[pending_idx] = NULL;
> +	xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_OKAY);
>  }
>  
> -

Stray blank line.

>  static void make_tx_response(struct xenvif *vif,
>  			     struct xen_netif_tx_request *txp,
>  			     s8       st)
