From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 2/9] xen-netback: Change TX path
 from grant copy to mapping
Date: Tue, 17 Dec 2013 16:49:19 -0500
Message-ID: <20131217214919.GC32553@phenom.dumpdata.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:44911 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab3LQVt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:49:29 -0500
Content-Disposition: inline
In-Reply-To: <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 11:48:10PM +0000, Zoltan Kiss wrote:
> This patch changes the grant copy on the TX patch to grant mapping
> 
> v2:
> - delete branch for handling fragmented packets fit PKT_PROT_LINE sized first
>   request
> - mark the effect of using ballooned pages in a comment
> - place setting of skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY right
>   before netif_receive_skb, and mark the importance of it
> - grab dealloc_lock before __napi_complete to avoid contention with the
>   callback's napi_schedule
> - handle fragmented packets where first request < PKT_PROT_LINE
> - fix up error path when checksum_setup failed
> - check before teardown for pending grants, and start complain if they are
>   there after 10 second
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   57 +++++++-
>  drivers/net/xen-netback/netback.c   |  257 ++++++++++++++---------------------
>  2 files changed, 156 insertions(+), 158 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 1c27e9e..42946de 100644
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
>  		goto drop;
>  
>  	/* At best we'll need one slot for the header and one for each
> @@ -335,8 +337,25 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	vif->pending_prod = MAX_PENDING_REQS;
>  	for (i = 0; i < MAX_PENDING_REQS; i++)
>  		vif->pending_ring[i] = i;
> -	for (i = 0; i < MAX_PENDING_REQS; i++)
> -		vif->mmap_pages[i] = NULL;
> +	/* If ballooning is disabled, this will consume real memory, so you
> +	 * better enable it. The long term solution would be to use just a
> +	 * bunch of valid page descriptors, without dependency on ballooning
> +	 */
> +	err = alloc_xenballooned_pages(MAX_PENDING_REQS,
> +		vif->mmap_pages,
> +		false);
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
> +	init_timer(&vif->dealloc_delay);
>  
>  	/*
>  	 * Initialise a dummy MAC address. We choose the numerically
> @@ -380,6 +399,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		goto err;
>  
>  	init_waitqueue_head(&vif->wq);
> +	init_waitqueue_head(&vif->dealloc_wq);
>  
>  	if (tx_evtchn == rx_evtchn) {
>  		/* feature-split-event-channels == 0 */
> @@ -421,6 +441,14 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		goto err_rx_unbind;
>  	}
>  
> +	vif->dealloc_task = kthread_create(xenvif_dealloc_kthread,
> +				   (void *)vif, "%s-dealloc", vif->dev->name);
> +	if (IS_ERR(vif->dealloc_task)) {
> +		pr_warn("Could not allocate kthread for %s\n", vif->dev->name);
> +		err = PTR_ERR(vif->dealloc_task);
> +		goto err_rx_unbind;
> +	}
> +
>  	vif->task = task;
>  
>  	rtnl_lock();
> @@ -433,6 +461,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  	rtnl_unlock();
>  
>  	wake_up_process(vif->task);
> +	wake_up_process(vif->dealloc_task);
>  
>  	return 0;
>  
> @@ -470,6 +499,12 @@ void xenvif_disconnect(struct xenvif *vif)
>  		vif->task = NULL;
>  	}
>  
> +	if (vif->dealloc_task) {
> +		del_timer_sync(&vif->dealloc_delay);
> +		kthread_stop(vif->dealloc_task);
> +		vif->dealloc_task = NULL;
> +	}
> +
>  	if (vif->tx_irq) {
>  		if (vif->tx_irq == vif->rx_irq)
>  			unbind_from_irqhandler(vif->tx_irq, vif);
> @@ -485,6 +520,22 @@ void xenvif_disconnect(struct xenvif *vif)
>  
>  void xenvif_free(struct xenvif *vif)
>  {
> +	int i, unmap_timeout = 0;
> +
> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> +			i = 0;
> +			unmap_timeout++;
> +			msleep(1000);

You don't want to use schedule() and a wakeup here to allow other threads
to do their work?

> +			if (unmap_timeout > 9 &&
> +				net_ratelimit())
> +				netdev_err(vif->dev,
> +					"Page still granted! Index: %x\n", i);
> +		}
> +	}
> +
> +	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);

How about just stashing those pages on a 'I can't free them' list that will
keep them forever. And if that list gets truly large then switch back to
grant_copy?
