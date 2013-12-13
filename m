From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Fri, 13 Dec 2013 15:36:12 +0000
Message-ID: <20131213153612.GM21900@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386892097-15502-3-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 11:48:10PM +0000, Zoltan Kiss wrote:
> This patch changes the grant copy on the TX patch to grant mapping
> 
> v2:
> - delete branch for handling fragmented packets fit PKT_PROT_LINE sized first
                                                      ^ PKT_PROT_LEN
>   request
> - mark the effect of using ballooned pages in a comment
> - place setting of skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY right
>   before netif_receive_skb, and mark the importance of it
> - grab dealloc_lock before __napi_complete to avoid contention with the
>   callback's napi_schedule
> - handle fragmented packets where first request < PKT_PROT_LINE
                                                    ^ PKT_PROT_LEN
> - fix up error path when checksum_setup failed
> - check before teardown for pending grants, and start complain if they are
>   there after 10 second
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
[...]
>  void xenvif_free(struct xenvif *vif)
>  {
> +	int i, unmap_timeout = 0;
> +
> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> +			i = 0;
> +			unmap_timeout++;
> +			msleep(1000);
> +			if (unmap_timeout > 9 &&
> +				net_ratelimit())
> +				netdev_err(vif->dev,
> +					"Page still granted! Index: %x\n", i);
> +		}
> +	}
> +
> +	free_xenballooned_pages(MAX_PENDING_REQS, vif->mmap_pages);
> +

If some pages are stuck and you just free them will it cause Dom0 to
crash? I mean, if those pages are recycled by other balloon page users.

Even if it will not cause Dom0 to crash, will it leak any resource in
Dom0? At plain sight it looks like at least grant table entry is leaked,
isn't it? We need to be careful about this because a malicious might be
able to DoS Dom0 with resource leakage.

>  	netif_napi_del(&vif->napi);
>  
>  	unregister_netdev(vif->dev);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 3ddc474..20352be 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -645,9 +645,12 @@ static void xenvif_tx_err(struct xenvif *vif,
>  			  struct xen_netif_tx_request *txp, RING_IDX end)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
> +	unsigned long flags;
>  
>  	do {
> +		spin_lock_irqsave(&vif->response_lock, flags);
>  		make_tx_response(vif, txp, XEN_NETIF_RSP_ERROR);
> +		spin_unlock_irqrestore(&vif->response_lock, flags);

You only hold the lock for one function call is this intentional?

>  		if (cons == end)
>  			break;
>  		txp = RING_GET_REQUEST(&vif->tx, cons++);
> @@ -786,10 +789,10 @@ static inline void xenvif_tx_create_gop(struct xenvif *vif, u16 pending_idx,
>  
>  }
>  
> -static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
> +static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>  					       struct sk_buff *skb,
>  					       struct xen_netif_tx_request *txp,
> -					       struct gnttab_copy *gop)
> +					       struct gnttab_map_grant_ref *gop)
>  {
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	skb_frag_t *frags = shinfo->frags;
> @@ -810,83 +813,12 @@ static struct gnttab_copy *xenvif_get_requests(struct xenvif *vif,
>  	/* Skip first skb fragment if it is on same page as header fragment. */
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
>  
[...]
>  		if (checksum_setup(vif, skb)) {
>  			netdev_dbg(vif->dev,
>  				   "Can't setup checksum in net_tx_action\n");
> +			if (skb_shinfo(skb)->destructor_arg)
> +				skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  			kfree_skb(skb);
>  			continue;
>  		}
> @@ -1601,6 +1559,14 @@ static int xenvif_tx_submit(struct xenvif *vif)
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

This is really tricky. :-P

>  		netif_receive_skb(skb);
>  	}
>  
> @@ -1711,7 +1677,7 @@ static inline void xenvif_tx_dealloc_action(struct xenvif *vif)
>  int xenvif_tx_action(struct xenvif *vif, int budget)
>  {
>  	unsigned nr_gops;
> -	int work_done;
> +	int work_done, ret;
>  
>  	if (unlikely(!tx_work_todo(vif)))
>  		return 0;
> @@ -1721,7 +1687,13 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  	if (nr_gops == 0)
>  		return 0;
>  
> -	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
> +	if (nr_gops) {

Surely you can remove this "if". At this point nr_gops cannot be zero --
see two lines above.

> +		ret = gnttab_map_refs(vif->tx_map_ops,
> +			NULL,
> +			vif->pages_to_map,
> +			nr_gops);
> +		BUG_ON(ret);
> +	}
>  
>  	work_done = xenvif_tx_submit(vif);
>  
> @@ -1732,61 +1704,37 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
>  			       u8 status)
>  {
[...]
>  
>  void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
>  {
>  	int ret;
> +	struct gnttab_unmap_grant_ref tx_unmap_op;
> +
>  	if (vif->grant_tx_handle[pending_idx] == NETBACK_INVALID_HANDLE) {
>  		netdev_err(vif->dev,
>  				"Trying to unmap invalid handle! pending_idx: %x\n",
>  				pending_idx);
>  		return;
>  	}
> -	gnttab_set_unmap_op(&vif->tx_unmap_ops[0],
> +	gnttab_set_unmap_op(&tx_unmap_op,
>  			idx_to_kaddr(vif, pending_idx),
>  			GNTMAP_host_map,
>  			vif->grant_tx_handle[pending_idx]);
> -	ret = gnttab_unmap_refs(vif->tx_unmap_ops,
> +	ret = gnttab_unmap_refs(&tx_unmap_op,
>  			NULL,
>  			&vif->mmap_pages[pending_idx],
>  			1);

This change should be squashed to patch 1. Or as I suggested the changes
in patch 1 should be moved here.

> @@ -1845,7 +1793,6 @@ static inline int rx_work_todo(struct xenvif *vif)
>  
>  static inline int tx_work_todo(struct xenvif *vif)
>  {
> -

Stray blank line change.

Wei.

>  	if (likely(RING_HAS_UNCONSUMED_REQUESTS(&vif->tx)) &&
>  	    (nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
>  	     < MAX_PENDING_REQS))
