From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 03/13] xen-netback: implement TX persistent grants
Date: Tue, 19 May 2015 16:23:42 +0100
Message-ID: <20150519152342.GB26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:40651 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933034AbbESPYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 11:24:24 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-4-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:27PM +0200, Joao Martins wrote:
> Introduces persistent grants for TX path which follows similar code path
> as the grant mapping.
> 
> It starts by checking if there's a persistent grant available for header
> and frags grefs and if so setting it in tx_pgrants. If no persistent grant
> is found in the tree for the header it will resort to grant copy (but
> preparing the map ops and add them laster). For the frags it will use the
                                     ^
                                     later

> tree page pool, and in case of no pages it fallbacks to grant map/unmap
> using mmap_pages. When skb destructor callback gets called we release the
> slot and persistent grant within the callback to avoid waking up the
> dealloc thread. As long as there are no unmaps to done the dealloc thread
> will remain inactive.
> 

This scheme looks complicated. Can we just only use one
scheme at a time? What's the rationale for using this combined scheme?
Maybe you're thinking about using a max_grants < ring_size to save
memory?

Only skim the patch. I will do detailed reviews after we're sure this is
the right way to go.

> Results show an improvement of 46% (1.82 vs 1.24 Mpps, 64 pkt size)
> measured with pktgen and up to over 48% (21.6 vs 14.5 Gbit/s) measured
> with iperf (TCP) with 4 parallel flows 1 queue vif, DomU to Dom0.
> Tests ran on a Intel Xeon E5-1650 v2 with HT disabled.
> 
> Signed-off-by: Joao Martins <joao.martins@neclab.eu>
> ---
>  drivers/net/xen-netback/common.h    |  12 ++
>  drivers/net/xen-netback/interface.c |  46 +++++
>  drivers/net/xen-netback/netback.c   | 341 +++++++++++++++++++++++++++++++-----
>  3 files changed, 360 insertions(+), 39 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index e70ace7..e5ee220 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -191,6 +191,15 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>  	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
>  	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
>  	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
> +
> +	/* Tree to store the TX grants
> +	 * Only used if feature-persistent = 1
> +	 */
> +	struct persistent_gnt_tree tx_gnts_tree;
> +	struct page *tx_gnts_pages[XEN_NETIF_TX_RING_SIZE];
> +	/* persistent grants in use */
> +	struct persistent_gnt *tx_pgrants[MAX_PENDING_REQS];
> +
>  	/* passed to gnttab_[un]map_refs with pages under (un)mapping */
>  	struct page *pages_to_map[MAX_PENDING_REQS];
>  	struct page *pages_to_unmap[MAX_PENDING_REQS];
> @@ -361,6 +370,9 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success);
>  
>  /* Unmap a pending page and release it back to the guest */
>  void xenvif_idx_unmap(struct xenvif_queue *queue, u16 pending_idx);
> +void xenvif_page_unmap(struct xenvif_queue *queue,
> +		       grant_handle_t handle,
> +		       struct page **page);
>  
>  static inline pending_ring_idx_t nr_pending_reqs(struct xenvif_queue *queue)
>  {
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 1a83e19..6f996ac 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -456,6 +456,34 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	return vif;
>  }
>  
> +static int init_persistent_gnt_tree(struct persistent_gnt_tree *tree,
> +				    struct page **pages, int max)
> +{
> +	int err;
> +
> +	tree->gnt_max = min_t(unsigned, max, xenvif_max_pgrants);
> +	tree->root.rb_node = NULL;
> +	atomic_set(&tree->gnt_in_use, 0);
> +
> +	err = gnttab_alloc_pages(tree->gnt_max, pages);
> +	if (!err) {
> +		tree->free_pages_num = 0;
> +		INIT_LIST_HEAD(&tree->free_pages);
> +		put_free_pages(tree, pages, tree->gnt_max);
> +	}
> +
> +	return err;
> +}
> +
> +static void deinit_persistent_gnt_tree(struct persistent_gnt_tree *tree,
> +				       struct page **pages)
> +{
> +	free_persistent_gnts(tree, tree->gnt_c);
> +	BUG_ON(!RB_EMPTY_ROOT(&tree->root));
> +	tree->gnt_c = 0;
> +	gnttab_free_pages(tree->gnt_max, pages);
> +}
> +
>  int xenvif_init_queue(struct xenvif_queue *queue)
>  {
>  	int err, i;
> @@ -496,9 +524,23 @@ int xenvif_init_queue(struct xenvif_queue *queue)
>  			  .ctx = NULL,
>  			  .desc = i };
>  		queue->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
> +		queue->tx_pgrants[i] = NULL;
> +	}
> +
> +	if (queue->vif->persistent_grants) {
> +		err = init_persistent_gnt_tree(&queue->tx_gnts_tree,
> +					       queue->tx_gnts_pages,
> +					       XEN_NETIF_TX_RING_SIZE);
> +		if (err)
> +			goto err_disable;
>  	}
>  
>  	return 0;
> +
> +err_disable:
> +	netdev_err(queue->vif->dev, "Could not reserve tree pages.");
> +	queue->vif->persistent_grants = 0;

You can just move the above two lines under `if (err)'.

Also see below.

> +	return 0;
>  }
>  
>  void xenvif_carrier_on(struct xenvif *vif)
> @@ -654,6 +696,10 @@ void xenvif_disconnect(struct xenvif *vif)
>  		}
>  
>  		xenvif_unmap_frontend_rings(queue);
> +
> +		if (queue->vif->persistent_grants)
> +			deinit_persistent_gnt_tree(&queue->tx_gnts_tree,
> +						   queue->tx_gnts_pages);

If the init function fails on queue N (N>0) you now leak resources.

>  	}
>  }
>  
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 332e489..529d7c3 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -269,6 +269,11 @@ static inline unsigned long idx_to_kaddr(struct xenvif_queue *queue,
>  	return (unsigned long)pfn_to_kaddr(idx_to_pfn(queue, idx));
>  }
>  
> +static inline void *page_to_kaddr(struct page *page)
> +{
> +	return pfn_to_kaddr(page_to_pfn(page));
> +}
> +
>  #define callback_param(vif, pending_idx) \
>  	(vif->pending_tx_info[pending_idx].callback_struct)
>  
> @@ -299,6 +304,29 @@ static inline pending_ring_idx_t pending_index(unsigned i)
>  	return i & (MAX_PENDING_REQS-1);
>  }
>  
> +/*  Creates a new persistent grant and add it to the tree.
> + */
> +static struct persistent_gnt *xenvif_pgrant_new(struct persistent_gnt_tree *tree,
> +						struct gnttab_map_grant_ref *gop)
> +{
> +	struct persistent_gnt *persistent_gnt;
> +
> +	persistent_gnt = kmalloc(sizeof(*persistent_gnt), GFP_KERNEL);

xenvif_pgrant_new can be called in NAPI which runs in softirq context
which doesn't allow you to sleep.

> +	if (!persistent_gnt)
> +		return NULL;
> +
> +	persistent_gnt->gnt = gop->ref;
> +	persistent_gnt->page = virt_to_page(gop->host_addr);
> +	persistent_gnt->handle = gop->handle;
> +
> +	if (unlikely(add_persistent_gnt(tree, persistent_gnt))) {
> +		kfree(persistent_gnt);
> +		persistent_gnt = NULL;
> +	}
> +
> +	return persistent_gnt;
> +}
> +
>  bool xenvif_rx_ring_slots_available(struct xenvif_queue *queue, int needed)
>  {
>  	RING_IDX prod, cons;
> @@ -927,22 +955,59 @@ static int xenvif_count_requests(struct xenvif_queue *queue,
>  
>  struct xenvif_tx_cb {
>  	u16 pending_idx;
> +	bool pending_map;
>  };
>  
>  #define XENVIF_TX_CB(skb) ((struct xenvif_tx_cb *)(skb)->cb)
>  
> +static inline void xenvif_pgrant_set(struct xenvif_queue *queue,
> +				     u16 pending_idx,
> +				     struct persistent_gnt *pgrant)
> +{
> +	if (unlikely(queue->tx_pgrants[pending_idx])) {
> +		netdev_err(queue->vif->dev,
> +			   "Trying to overwrite an active persistent grant ! pending_idx: %x\n",
> +			   pending_idx);
> +		BUG();
> +	}
> +	queue->tx_pgrants[pending_idx] = pgrant;
> +}
> +
> +static inline void xenvif_pgrant_reset(struct xenvif_queue *queue,
> +				       u16 pending_idx)
> +{
> +	struct persistent_gnt *pgrant = queue->tx_pgrants[pending_idx];
> +
> +	if (unlikely(!pgrant)) {
> +		netdev_err(queue->vif->dev,
> +			   "Trying to release an inactive persistent_grant ! pending_idx: %x\n",
> +			   pending_idx);
> +		BUG();
> +	}
> +	put_persistent_gnt(&queue->tx_gnts_tree, pgrant);
> +	queue->tx_pgrants[pending_idx] = NULL;
> +}
> +
>  static inline void xenvif_tx_create_map_op(struct xenvif_queue *queue,
> -					  u16 pending_idx,
> -					  struct xen_netif_tx_request *txp,
> -					  struct gnttab_map_grant_ref *mop)
> +					   u16 pending_idx,
> +					   struct xen_netif_tx_request *txp,
> +					   struct gnttab_map_grant_ref *mop,
> +					   bool use_persistent_gnts)
>  {
> -	queue->pages_to_map[mop-queue->tx_map_ops] = queue->mmap_pages[pending_idx];
> -	gnttab_set_map_op(mop, idx_to_kaddr(queue, pending_idx),
> +	struct page *page = NULL;
> +
> +	if (use_persistent_gnts &&
> +	    get_free_page(&queue->tx_gnts_tree, &page)) {
> +		xenvif_pgrant_reset(queue, pending_idx);
> +		use_persistent_gnts = false;
> +	}
> +
> +	page = (!use_persistent_gnts ? queue->mmap_pages[pending_idx] : page);
> +	queue->pages_to_map[mop - queue->tx_map_ops] = page;
> +	gnttab_set_map_op(mop,
> +			  (unsigned long)page_to_kaddr(page),
>  			  GNTMAP_host_map | GNTMAP_readonly,
>  			  txp->gref, queue->vif->domid);
> -
> -	memcpy(&queue->pending_tx_info[pending_idx].req, txp,
> -	       sizeof(*txp));
>  }
>  
>  static inline struct sk_buff *xenvif_alloc_skb(unsigned int size)
> @@ -962,6 +1027,39 @@ static inline struct sk_buff *xenvif_alloc_skb(unsigned int size)
>  	return skb;
>  }
>  
> +/* Checks if there's a persistent grant available for gref and
> + * if so, set it also in the tx_pgrants array that keeps the ones
> + * in use.
> + */
> +static bool xenvif_tx_pgrant_available(struct xenvif_queue *queue,
> +				       grant_ref_t ref, u16 pending_idx,
> +				       bool *can_map)
> +{
> +	struct persistent_gnt_tree *tree = &queue->tx_gnts_tree;
> +	struct persistent_gnt *persistent_gnt;
> +	bool busy;
> +
> +	if (!queue->vif->persistent_grants)
> +		return false;
> +
> +	persistent_gnt = get_persistent_gnt(tree, ref);
> +
> +	/* If gref is already in use we fallback, since it would
> +	 * otherwise mean re-adding the same gref to the tree
> +	 */
> +	busy = IS_ERR(persistent_gnt);
> +	if (unlikely(busy))
> +		persistent_gnt = NULL;
> +

Under what circumstance can we retrieve a already in use persistent
grant? You seem to suggest this is a bug in RX case.

> +	xenvif_pgrant_set(queue, pending_idx, persistent_gnt);
> +	if (likely(persistent_gnt))
> +		return true;
> +
> +	/* Check if we can create another persistent grant */
> +	*can_map = (!busy && tree->free_pages_num);
> +	return false;
> +}
> +
>  static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif_queue *queue,
>  							struct sk_buff *skb,
>  							struct xen_netif_tx_request *txp,
> @@ -973,6 +1071,7 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif_queue *que
>  	int start;
>  	pending_ring_idx_t index;
>  	unsigned int nr_slots, frag_overflow = 0;
> +	bool map_pgrant = false;
>  
>  	/* At this point shinfo->nr_frags is in fact the number of
>  	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
> @@ -988,11 +1087,16 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif_queue *que
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
>  
>  	for (shinfo->nr_frags = start; shinfo->nr_frags < nr_slots;
> -	     shinfo->nr_frags++, txp++, gop++) {
> +	     shinfo->nr_frags++, txp++) {
>  		index = pending_index(queue->pending_cons++);
>  		pending_idx = queue->pending_ring[index];
> -		xenvif_tx_create_map_op(queue, pending_idx, txp, gop);
>  		frag_set_pending_idx(&frags[shinfo->nr_frags], pending_idx);
> +		memcpy(&queue->pending_tx_info[pending_idx].req, txp,
> +		       sizeof(*txp));
> +		if (!xenvif_tx_pgrant_available(queue, txp->gref, pending_idx,
> +						&map_pgrant))
> +			xenvif_tx_create_map_op(queue, pending_idx, txp, gop++,
> +						map_pgrant);
>  	}
>  
>  	if (frag_overflow) {

[...]

>  			MAX_PENDING_REQS);
>  		index = pending_index(queue->dealloc_prod);
> @@ -1691,7 +1939,10 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
>  		smp_wmb();
>  		queue->dealloc_prod++;
>  	} while (ubuf);
> -	wake_up(&queue->dealloc_wq);
> +	/* Wake up only when there are grants to unmap */
> +	if (dealloc_prod_save != queue->dealloc_prod)
> +		wake_up(&queue->dealloc_wq);
> +
>  	spin_unlock_irqrestore(&queue->callback_lock, flags);
>  
>  	if (likely(zerocopy_success))
> @@ -1779,10 +2030,13 @@ int xenvif_tx_action(struct xenvif_queue *queue, int budget)
>  
>  	xenvif_tx_build_gops(queue, budget, &nr_cops, &nr_mops);
>  
> -	if (nr_cops == 0)
> +	if (!queue->vif->persistent_grants &&
> +	    nr_cops == 0)

You can just move nr_cops to previous line.

Wei.
