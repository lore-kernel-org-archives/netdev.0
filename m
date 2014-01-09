From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Thu, 9 Jan 2014 15:30:15 +0000
Message-ID: <20140109153015.GF12164@zion.uk.xensource.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
 <1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55363 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321AbaAIPaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 10:30:20 -0500
Content-Disposition: inline
In-Reply-To: <1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 12:10:11AM +0000, Zoltan Kiss wrote:
> This patch changes the grant copy on the TX patch to grant mapping
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

I suppose this is to avoid touching m2p override as well, just as
previous patch uses unmap hypercall directly.

> - fix unmapping timeout in xenvif_free()
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   57 +++++++-
>  drivers/net/xen-netback/netback.c   |  251 ++++++++++++++---------------------
>  2 files changed, 153 insertions(+), 155 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 7170f97..3b2b249 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -122,7 +122,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	BUG_ON(skb->dev != dev);
>  
>  	/* Drop the packet if vif is not ready */
> -	if (vif->task == NULL || !xenvif_schedulable(vif))
> +	if (vif->task == NULL ||
> +		vif->dealloc_task == NULL ||
> +		!xenvif_schedulable(vif))

Indentation.

>  		goto drop;
>  
>  	/* At best we'll need one slot for the header and one for each
> @@ -345,8 +347,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	vif->pending_prod = MAX_PENDING_REQS;
>  	for (i = 0; i < MAX_PENDING_REQS; i++)
>  		vif->pending_ring[i] = i;
> -	for (i = 0; i < MAX_PENDING_REQS; i++)
> -		vif->mmap_pages[i] = NULL;
> +	spin_lock_init(&vif->dealloc_lock);
> +	spin_lock_init(&vif->response_lock);
> +	/* If ballooning is disabled, this will consume real memory, so you
> +	 * better enable it. The long term solution would be to use just a
> +	 * bunch of valid page descriptors, without dependency on ballooning
> +	 */
> +	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
> +		vif->mmap_pages,
> +		false);

Ditto.

> +	if (err) {
> +		netdev_err(dev, "Could not reserve mmap_pages\n");
> +		return NULL;
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
> @@ -390,6 +410,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		goto err;
>  
>  	init_waitqueue_head(&vif->wq);
> +	init_waitqueue_head(&vif->dealloc_wq);
>  
>  	if (tx_evtchn == rx_evtchn) {
>  		/* feature-split-event-channels == 0 */
> @@ -431,6 +452,14 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		goto err_rx_unbind;
>  	}
>  
> +	vif->dealloc_task = kthread_create(xenvif_dealloc_kthread,
> +				   (void *)vif, "%s-dealloc", vif->dev->name);

Ditto.

> +	if (IS_ERR(vif->dealloc_task)) {
> +		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
> +		err = PTR_ERR(vif->dealloc_task);
> +		goto err_rx_unbind;
> +	}
> +
>  	vif->task = task;
>  
>  	rtnl_lock();
[...]
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
> @@ -920,6 +852,18 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  	err = gop->status;
>  	if (unlikely(err))
>  		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
> +	else {
> +		if (vif->grant_tx_handle[pending_idx] !=
> +			NETBACK_INVALID_HANDLE) {
> +			netdev_err(vif->dev,
> +				"Stale mapped handle! pending_idx %x handle %x\n",
> +				pending_idx, vif->grant_tx_handle[pending_idx]);
> +			BUG();
> +		}
> +		set_phys_to_machine(idx_to_pfn(vif, pending_idx),
> +			FOREIGN_FRAME(gop->dev_bus_addr >> PAGE_SHIFT));

What happens when you don't have this?

> +		vif->grant_tx_handle[pending_idx] = gop->handle;
> +	}
>  
>  	/* Skip first skb fragment if it is on same page as header fragment. */
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
> @@ -933,18 +877,26 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
>  		head = tx_info->head;
>  
[...]
>  		}
> @@ -1567,7 +1523,11 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		else if (txp->flags & XEN_NETTXF_data_validated)
>  			skb->ip_summed = CHECKSUM_UNNECESSARY;
>  
> -		xenvif_fill_frags(vif, skb);
> +		xenvif_fill_frags(vif,
> +			skb,
> +			skb_shinfo(skb)->destructor_arg ?
> +					pending_idx :
> +					INVALID_PENDING_IDX);
>  

Indentation.

>  		if (skb_is_nonlinear(skb) && skb_headlen(skb) < PKT_PROT_LEN) {
>  			int target = min_t(int, skb->len, PKT_PROT_LEN);
> @@ -1581,6 +1541,8 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  		if (checksum_setup(vif, skb)) {
>  			netdev_dbg(vif->dev,
>  				   "Can't setup checksum in net_tx_action\n");
> +			if (skb_shinfo(skb)->destructor_arg)
> +				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;

Do you still care setting the flag even if this skb is not going to be
delivered? If so can you state clearly the reason just like the
following hunk?

>  			kfree_skb(skb);
>  			continue;
>  		}
> @@ -1606,6 +1568,14 @@ static int xenvif_tx_submit(struct xenvif *vif)
>  
>  		work_done++;
>  
> +		/* Set this flag right before netif_receive_skb, otherwise
> +		 * someone might think this packet already left netback, and
> +		 * do a skb_copy_ubufs while we are still in control of the
> +		 * skb. E.g. the __pskb_pull_tail earlier can do such thing.
> +		 */
> +		if (skb_shinfo(skb)->destructor_arg)
> +			skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +
>  		netif_receive_skb(skb);
>  	}
>  
> @@ -1715,7 +1685,7 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>  int xenvif_tx_action(struct xenvif *vif, int budget)
>  {
>  	unsigned nr_gops;
> -	int work_done;
> +	int work_done, ret;
>  
>  	if (unlikely(!tx_work_todo(vif)))
>  		return 0;
> @@ -1725,7 +1695,10 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  	if (nr_gops == 0)
>  		return 0;
>  
> -	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
> +	ret = HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref,
> +			vif->tx_map_ops,
> +			nr_gops);

Why do you need to replace gnttab_batch_copy with hypercall? In the
ideal situation gnttab_batch_copy should behave the same as directly
hypercall but it also handles GNTST_eagain for you.

Wei.
