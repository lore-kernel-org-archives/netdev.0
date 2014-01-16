From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Thu, 16 Jan 2014 00:01:07 +0000
Message-ID: <20140116000107.GB5331@zion.uk.xensource.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
 <1389731995-9887-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389731995-9887-3-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 08:39:48PM +0000, Zoltan Kiss wrote:
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
> - fix unmapping timeout in xenvif_free()
> 
> v4:
> - fix indentations and comments
> - handle errors of set_phys_to_machine

There's no call to set_phys_to_machine in this patch. Did I miss
something?

> - go back to gnttab_map_refs instead of direct hypercall. Now we rely on the
>   modified API
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   60 +++++++-
>  drivers/net/xen-netback/netback.c   |  256 ++++++++++++++---------------------
>  2 files changed, 159 insertions(+), 157 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index a7855b3..1e0bf71 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -123,7 +123,9 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	BUG_ON(skb->dev != dev);
>  
>  	/* Drop the packet if vif is not ready */
> -	if (vif->task == NULL || !xenvif_schedulable(vif))
> +	if (vif->task == NULL ||
> +	    vif->dealloc_task == NULL ||
> +	    !xenvif_schedulable(vif))
>  		goto drop;
>  
>  	/* At best we'll need one slot for the header and one for each
> @@ -345,8 +347,26 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,

At the beginning of the function there's BUG_ON checks for vif->task. I
would suggest you do the same for vif->dealloc_task, just to be
consistent.

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
> +				       vif->mmap_pages,
> +				       false);
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
> @@ -431,6 +452,16 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		goto err_rx_unbind;
>  	}
>  
> +	vif->dealloc_task = kthread_create(xenvif_dealloc_kthread,
> +					   (void *)vif,
> +					   "%s-dealloc",
> +					   vif->dev->name);
> +	if (IS_ERR(vif->dealloc_task)) {
> +		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
> +		err = PTR_ERR(vif->dealloc_task);
> +		goto err_rx_unbind;
> +	}
> +
>  	vif->task = task;

Please move this line before the above hunk. Don't separate it from
corresponding kthread_create.

Last but not least, though I've looked at this patch for several rounds
and and the basic logic looks correct to me, I would like it to go
through XenRT tests if possible -- eye inspection is error-prone to such
complicated change. (If I'm not mistaken you once told me you've done
regression tests already. That would be neat!)

Wei.
