From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 04/13] xen-netback: implement RX persistent grants
Date: Tue, 19 May 2015 16:32:05 +0100
Message-ID: <20150519153205.GC26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-5-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29818 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbbESPc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 11:32:28 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-5-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:28PM +0200, Joao Martins wrote:
> It starts by doing a lookup in the tree for a gref. If no persistent
> grant is found on the tree, it will do grant copy and prepare
> the grant maps. Finally valides the grant map and adds it to the tree.

validates?

> After mapped these grants can be pulled from the tree in the subsequent
> requests. If it's out of pages in the tree pool, it will fallback to
> grant copy.
> 

Again, this looks complicated. Why use combined scheme? I will do
detailed reviews after we're sure we need such scheme.

> It adds four new fields in the netrx_pending_operations: copy_done
> to track how many copies were made; map_prod and map_cons to track
> how many maps are outstanding validation and finally copy_page for
> the correspondent page (in tree) for copy_gref.
> 
> Results are 1.04 Mpps measured with pktgen (pkt_size 64, burst 1)
> with persistent grants versus 1.23 Mpps with grant copy (20%
> regression). With persistent grants it adds up contention on
> queue->wq as the kthread_guest_rx goes to sleep more often. If we
> speed up the sender (burst 2,4 and 8) it goes up to 1.7 Mpps with
> persistent grants. This issue is addressed in later a commit, by
> copying the skb on xenvif_start_xmit() instead of going through
> the RX kthread.
> 
> Signed-off-by: Joao Martins <joao.martins@neclab.eu>
> ---
>  drivers/net/xen-netback/common.h    |   7 ++
>  drivers/net/xen-netback/interface.c |  14 ++-
>  drivers/net/xen-netback/netback.c   | 190 ++++++++++++++++++++++++++++++------
>  3 files changed, 178 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index e5ee220..23deb6a 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -235,6 +235,13 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>  
>  	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
>  
> +	/* To map the grefs to be added to the tree */
> +	struct gnttab_map_grant_ref rx_map_ops[XEN_NETIF_RX_RING_SIZE];
> +	struct page *rx_pages_to_map[XEN_NETIF_RX_RING_SIZE];
> +	/* Only used if feature-persistent = 1 */

This comment applies to rx_map_ops and rx_pages_to_map as well. Could
you move it up?

> +	struct persistent_gnt_tree rx_gnts_tree;
> +	struct page *rx_gnts_pages[XEN_NETIF_RX_RING_SIZE];
> +
>  	/* We create one meta structure per ring request we consume, so
>  	 * the maximum number is the same as the ring size.
>  	 */
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c

[...]

>  
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 529d7c3..738b6ee 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -413,14 +413,62 @@ static void xenvif_rx_queue_drop_expired(struct xenvif_queue *queue)
>  }
>  
>  struct netrx_pending_operations {
> +	unsigned map_prod, map_cons;
>  	unsigned copy_prod, copy_cons;
>  	unsigned meta_prod, meta_cons;
>  	struct gnttab_copy *copy;
>  	struct xenvif_rx_meta *meta;
>  	int copy_off;
>  	grant_ref_t copy_gref;
> +	struct page *copy_page;
> +	unsigned copy_done;
>  };
>  
> +static void xenvif_create_rx_map_op(struct xenvif_queue *queue,
> +				    struct gnttab_map_grant_ref *mop,
> +				    grant_ref_t ref,
> +				    struct page *page)

Rename it to xenvif_rx_create_map_op to be consistent with
xenvif_tx_create_map_op?

> +{
> +	queue->rx_pages_to_map[mop - queue->rx_map_ops] = page;
> +	gnttab_set_map_op(mop,
> +			  (unsigned long)page_to_kaddr(page),
> +			  GNTMAP_host_map,
> +			  ref, queue->vif->domid);
> +}
> +

[...]

> +
> +		persistent_gnt = xenvif_pgrant_new(tree, gop_map);
> +		if (unlikely(!persistent_gnt)) {
> +			netdev_err(queue->vif->dev,
> +				   "Couldn't add gref to the tree! ref: %d",
> +				   gop_map->ref);
> +			xenvif_page_unmap(queue, gop_map->handle, &page);
> +			put_free_pages(tree, &page, 1);
> +			kfree(persistent_gnt);
> +			persistent_gnt = NULL;

persistent_gnt is already NULL.

So the kfree and = NULL is pointless.

> +			continue;
> +		}
> +
> +		put_persistent_gnt(tree, persistent_gnt);
> +	}
> +}
> +
> +/*
>   * This is a twin to xenvif_gop_skb.  Assume that xenvif_gop_skb was
>   * used to set up the operations on the top of
>   * netrx_pending_operations, which have since been done.  Check that
>   * they didn't give any errors and advance over them.
>   */
> -static int xenvif_check_gop(struct xenvif *vif, int nr_meta_slots,
> +static int xenvif_check_gop(struct xenvif_queue *queue, int nr_meta_slots,
>  			    struct netrx_pending_operations *npo)
>  {
>  	struct gnttab_copy     *copy_op;
>  	int status = XEN_NETIF_RSP_OKAY;
>  	int i;
>  
> +	nr_meta_slots -= npo->copy_done;
> +	if (npo->map_prod)

Should be "if (npo->map_prod != npo->map_cons)"?

Wei.
