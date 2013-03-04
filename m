From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 4/8] xenbus_client: Extend interface to support
 multi-page ring
Date: Mon, 4 Mar 2013 16:12:36 -0500
Message-ID: <20130304211236.GF16762@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com,
	Roger Pau Monne <roger.pau@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Mukesh Rathor <mukesh.rathor@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50682 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758766Ab3CDVMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 16:12:49 -0500
Content-Disposition: inline
In-Reply-To: <1360944010-15336-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 04:00:05PM +0000, Wei Liu wrote:
> Also bundle fixes for xen frontends and backends in this patch.

Please explain what this does. I have a fairly good idea
of what it does, but if there are folks who are going to look
in the source code and find this git commit they might not understand
how this is suppose to be used or why it is better to have
more than 0-page rings.



> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Roger Pau Monne <roger.pau@citrix.com>
> Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
> Cc: Mukesh Rathor <mukesh.rathor@oracle.com>
> ---
>  drivers/block/xen-blkback/xenbus.c |   14 +-
>  drivers/block/xen-blkfront.c       |    6 +-
>  drivers/net/xen-netback/netback.c  |    4 +-
>  drivers/net/xen-netfront.c         |    9 +-
>  drivers/pci/xen-pcifront.c         |    5 +-
>  drivers/xen/xen-pciback/xenbus.c   |   10 +-
>  drivers/xen/xenbus/xenbus_client.c |  314 ++++++++++++++++++++++++++----------
>  include/xen/xenbus.h               |   17 +-
>  8 files changed, 270 insertions(+), 109 deletions(-)
> 
> diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkback/xenbus.c
> index 6398072..384ff24 100644
> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -122,7 +122,8 @@ static struct xen_blkif *xen_blkif_alloc(domid_t domid)
>  	return blkif;
>  }
>  
> -static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
> +static int xen_blkif_map(struct xen_blkif *blkif, int *shared_pages,
> +			 int nr_pages,
>  			 unsigned int evtchn)
>  {
>  	int err;
> @@ -131,7 +132,8 @@ static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
>  	if (blkif->irq)
>  		return 0;
>  
> -	err = xenbus_map_ring_valloc(blkif->be->dev, shared_page, &blkif->blk_ring);
> +	err = xenbus_map_ring_valloc(blkif->be->dev, shared_pages,
> +				     nr_pages, &blkif->blk_ring);
>  	if (err < 0)
>  		return err;
>  
> @@ -726,7 +728,7 @@ again:
>  static int connect_ring(struct backend_info *be)
>  {
>  	struct xenbus_device *dev = be->dev;
> -	unsigned long ring_ref;
> +	int ring_ref;
>  	unsigned int evtchn;
>  	unsigned int pers_grants;
>  	char protocol[64] = "";
> @@ -767,14 +769,14 @@ static int connect_ring(struct backend_info *be)
>  	be->blkif->vbd.feature_gnt_persistent = pers_grants;
>  	be->blkif->vbd.overflow_max_grants = 0;
>  
> -	pr_info(DRV_PFX "ring-ref %ld, event-channel %d, protocol %d (%s) %s\n",
> +	pr_info(DRV_PFX "ring-ref %d, event-channel %d, protocol %d (%s) %s\n",
>  		ring_ref, evtchn, be->blkif->blk_protocol, protocol,
>  		pers_grants ? "persistent grants" : "");
>  
>  	/* Map the shared frame, irq etc. */
> -	err = xen_blkif_map(be->blkif, ring_ref, evtchn);
> +	err = xen_blkif_map(be->blkif, &ring_ref, 1, evtchn);
>  	if (err) {
> -		xenbus_dev_fatal(dev, err, "mapping ring-ref %lu port %u",
> +		xenbus_dev_fatal(dev, err, "mapping ring-ref %u port %u",
>  				 ring_ref, evtchn);
>  		return err;
>  	}
> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index 96e9b00..12c9ebd 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -991,6 +991,7 @@ static int setup_blkring(struct xenbus_device *dev,
>  {
>  	struct blkif_sring *sring;
>  	int err;
> +	int grefs[1];

Perhaps all of those '1' should have a #define.

Say 'XEN_DEFAULT_RING_PAGE_SIZE'?

>  
>  	info->ring_ref = GRANT_INVALID_REF;
>  
> @@ -1004,13 +1005,14 @@ static int setup_blkring(struct xenbus_device *dev,
>  
>  	sg_init_table(info->sg, BLKIF_MAX_SEGMENTS_PER_REQUEST);
>  
> -	err = xenbus_grant_ring(dev, virt_to_mfn(info->ring.sring));
> +	err = xenbus_grant_ring(dev, info->ring.sring,
> +				1, grefs);
>  	if (err < 0) {
>  		free_page((unsigned long)sring);
>  		info->ring.sring = NULL;
>  		goto fail;
>  	}
> -	info->ring_ref = err;
> +	info->ring_ref = grefs[0];
>  
>  	err = xenbus_alloc_evtchn(dev, &info->evtchn);
>  	if (err)
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index de59098..98ccea9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1665,7 +1665,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
>  	int err = -ENOMEM;
>  
>  	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     tx_ring_ref, &addr);
> +				     &tx_ring_ref, 1, &addr);
>  	if (err)
>  		goto err;
>  
> @@ -1673,7 +1673,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
>  	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
>  
>  	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     rx_ring_ref, &addr);
> +				     &rx_ring_ref, 1, &addr);
>  	if (err)
>  		goto err;
>  
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 7ffa43b..8bd75a1 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1501,6 +1501,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>  	struct xen_netif_tx_sring *txs;
>  	struct xen_netif_rx_sring *rxs;
>  	int err;
> +	int grefs[1];
>  	struct net_device *netdev = info->netdev;
>  
>  	info->tx_ring_ref = GRANT_INVALID_REF;
> @@ -1524,13 +1525,13 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>  	SHARED_RING_INIT(txs);
>  	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
>  
> -	err = xenbus_grant_ring(dev, virt_to_mfn(txs));
> +	err = xenbus_grant_ring(dev, txs, 1, grefs);
>  	if (err < 0) {
>  		free_page((unsigned long)txs);
>  		goto fail;
>  	}
>  
> -	info->tx_ring_ref = err;
> +	info->tx_ring_ref = grefs[0];
>  	rxs = (struct xen_netif_rx_sring *)get_zeroed_page(GFP_NOIO | __GFP_HIGH);
>  	if (!rxs) {
>  		err = -ENOMEM;
> @@ -1540,12 +1541,12 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>  	SHARED_RING_INIT(rxs);
>  	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
>  
> -	err = xenbus_grant_ring(dev, virt_to_mfn(rxs));
> +	err = xenbus_grant_ring(dev, rxs, 1, grefs);
>  	if (err < 0) {
>  		free_page((unsigned long)rxs);
>  		goto fail;
>  	}
> -	info->rx_ring_ref = err;
> +	info->rx_ring_ref = grefs[0];
>  
>  	err = xenbus_alloc_evtchn(dev, &info->evtchn);
>  	if (err)
> diff --git a/drivers/pci/xen-pcifront.c b/drivers/pci/xen-pcifront.c
> index 966abc6..016a2bb 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -772,12 +772,13 @@ static int pcifront_publish_info(struct pcifront_device *pdev)
>  {
>  	int err = 0;
>  	struct xenbus_transaction trans;
> +	int grefs[1];
>  
> -	err = xenbus_grant_ring(pdev->xdev, virt_to_mfn(pdev->sh_info));
> +	err = xenbus_grant_ring(pdev->xdev, pdev->sh_info, 1, grefs);
>  	if (err < 0)
>  		goto out;
>  
> -	pdev->gnt_ref = err;
> +	pdev->gnt_ref = grefs[0];
>  
>  	err = xenbus_alloc_evtchn(pdev->xdev, &pdev->evtchn);
>  	if (err)
> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
> index 64b11f9..4655851 100644
> --- a/drivers/xen/xen-pciback/xenbus.c
> +++ b/drivers/xen/xen-pciback/xenbus.c
> @@ -98,17 +98,17 @@ static void free_pdev(struct xen_pcibk_device *pdev)
>  	kfree(pdev);
>  }
>  
> -static int xen_pcibk_do_attach(struct xen_pcibk_device *pdev, int gnt_ref,
> -			     int remote_evtchn)
> +static int xen_pcibk_do_attach(struct xen_pcibk_device *pdev, int *gnt_ref,
> +			       int nr_grefs, int remote_evtchn)
>  {
>  	int err = 0;
>  	void *vaddr;
>  
>  	dev_dbg(&pdev->xdev->dev,
>  		"Attaching to frontend resources - gnt_ref=%d evtchn=%d\n",
> -		gnt_ref, remote_evtchn);
> +		gnt_ref[0], remote_evtchn);
>  
> -	err = xenbus_map_ring_valloc(pdev->xdev, gnt_ref, &vaddr);
> +	err = xenbus_map_ring_valloc(pdev->xdev, gnt_ref, nr_grefs, &vaddr);
>  	if (err < 0) {
>  		xenbus_dev_fatal(pdev->xdev, err,
>  				"Error mapping other domain page in ours.");
> @@ -172,7 +172,7 @@ static int xen_pcibk_attach(struct xen_pcibk_device *pdev)
>  		goto out;
>  	}
>  
> -	err = xen_pcibk_do_attach(pdev, gnt_ref, remote_evtchn);
> +	err = xen_pcibk_do_attach(pdev, &gnt_ref, 1, remote_evtchn);
>  	if (err)
>  		goto out;
>  
> diff --git a/drivers/xen/xenbus/xenbus_client.c b/drivers/xen/xenbus/xenbus_client.c
> index 1bac743..7c1bd49 100644
> --- a/drivers/xen/xenbus/xenbus_client.c
> +++ b/drivers/xen/xenbus/xenbus_client.c
> @@ -54,14 +54,16 @@ struct xenbus_map_node {
>  		struct vm_struct *area; /* PV */
>  		struct page *page;     /* HVM */
>  	};
> -	grant_handle_t handle;
> +	grant_handle_t handle[XENBUS_MAX_RING_PAGES];
> +	unsigned int   nr_handles;
>  };
>  
>  static DEFINE_SPINLOCK(xenbus_valloc_lock);
>  static LIST_HEAD(xenbus_valloc_pages);
>  
>  struct xenbus_ring_ops {
> -	int (*map)(struct xenbus_device *dev, int gnt, void **vaddr);
> +	int (*map)(struct xenbus_device *dev, int *gnt, int nr_gnts,
> +		   void **vaddr);
>  	int (*unmap)(struct xenbus_device *dev, void *vaddr);
>  };
>  
> @@ -357,17 +359,39 @@ static void xenbus_switch_fatal(struct xenbus_device *dev, int depth, int err,
>  /**
>   * xenbus_grant_ring
>   * @dev: xenbus device
> - * @ring_mfn: mfn of ring to grant
> -
> - * Grant access to the given @ring_mfn to the peer of the given device.  Return
> - * 0 on success, or -errno on error.  On error, the device will switch to
> + * @vaddr: starting virtual address of the ring
> + * @nr_pages: number of pages to be granted
> + * @grefs: grant reference array to be filled in
> + *
> + * Grant access to the given @vaddr to the peer of the given device.
> + * Then fill in @grefs with grant references.  Return 0 on success, or
> + * -errno on error.  On error, the device will switch to
>   * XenbusStateClosing, and the error will be saved in the store.
>   */
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn)
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> +		      int nr_pages, int *grefs)
>  {
> -	int err = gnttab_grant_foreign_access(dev->otherend_id, ring_mfn, 0);
> -	if (err < 0)
> -		xenbus_dev_fatal(dev, err, "granting access to ring page");
> +	int i;
> +	int err;
> +
> +	for (i = 0; i < nr_pages; i++) {
> +		unsigned long addr = (unsigned long)vaddr +
> +			(PAGE_SIZE * i);
> +		err = gnttab_grant_foreign_access(dev->otherend_id,
> +						  virt_to_mfn(addr), 0);
> +		if (err < 0) {
> +			xenbus_dev_fatal(dev, err,
> +					 "granting access to ring page");
> +			goto fail;
> +		}
> +		grefs[i] = err;
> +	}
> +
> +	return 0;
> +
> +fail:
> +	for ( ; i >= 0; i--)
> +		gnttab_end_foreign_access_ref(grefs[i], 0);
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(xenbus_grant_ring);
> @@ -448,7 +472,8 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
>  /**
>   * xenbus_map_ring_valloc
>   * @dev: xenbus device
> - * @gnt_ref: grant reference
> + * @gnt_ref: grant reference array
> + * @nr_grefs: number of grant references
>   * @vaddr: pointer to address to be filled out by mapping
>   *
>   * Based on Rusty Russell's skeleton driver's map_page.
> @@ -459,51 +484,61 @@ EXPORT_SYMBOL_GPL(xenbus_free_evtchn);
>   * or -ENOMEM on error. If an error is returned, device will switch to
>   * XenbusStateClosing and the error message will be saved in XenStore.
>   */
> -int xenbus_map_ring_valloc(struct xenbus_device *dev, int gnt_ref, void **vaddr)
> +int xenbus_map_ring_valloc(struct xenbus_device *dev, int *gnt_ref,
> +			   int nr_grefs, void **vaddr)
>  {
> -	return ring_ops->map(dev, gnt_ref, vaddr);
> +	return ring_ops->map(dev, gnt_ref, nr_grefs, vaddr);
>  }
>  EXPORT_SYMBOL_GPL(xenbus_map_ring_valloc);
>  
>  static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
> -				     int gnt_ref, void **vaddr)
> +				     int *gnt_ref, int nr_grefs, void **vaddr)
>  {
> -	struct gnttab_map_grant_ref op = {
> -		.flags = GNTMAP_host_map | GNTMAP_contains_pte,
> -		.ref   = gnt_ref,
> -		.dom   = dev->otherend_id,
> -	};
> +	struct gnttab_map_grant_ref op;
>  	struct xenbus_map_node *node;
>  	struct vm_struct *area;
> -	pte_t *pte;
> +	pte_t *pte[XENBUS_MAX_RING_PAGES];
> +	int i;
> +	int err = GNTST_okay;
> +	int vma_leaked; /* used in rollback */

bool

>  
>  	*vaddr = NULL;
>  
> +	if (nr_grefs > XENBUS_MAX_RING_PAGES)
> +		return -EINVAL;
> +
>  	node = kzalloc(sizeof(*node), GFP_KERNEL);
>  	if (!node)
>  		return -ENOMEM;
>  
> -	area = alloc_vm_area(PAGE_SIZE, &pte);
> +	area = alloc_vm_area(PAGE_SIZE * nr_grefs, pte);
>  	if (!area) {
>  		kfree(node);
>  		return -ENOMEM;
>  	}
>  
> -	op.host_addr = arbitrary_virt_to_machine(pte).maddr;
> -
> -	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
> -		BUG();
> -
> -	if (op.status != GNTST_okay) {
> -		free_vm_area(area);
> -		kfree(node);
> -		xenbus_dev_fatal(dev, op.status,
> -				 "mapping in shared page %d from domain %d",
> -				 gnt_ref, dev->otherend_id);
> -		return op.status;
> +	/* Issue hypercall for individual entry, rollback if error occurs. */
> +	for (i = 0; i < nr_grefs; i++) {
> +		op.flags = GNTMAP_host_map | GNTMAP_contains_pte;
> +		op.ref   = gnt_ref[i];
> +		op.dom   = dev->otherend_id;
> +		op.host_addr = arbitrary_virt_to_machine(pte[i]).maddr;
> +
> +		if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
> +			BUG();
> +
> +		if (op.status != GNTST_okay) {
> +			err = op.status;
> +			xenbus_dev_fatal(dev, op.status,
> +				 "mapping in shared page (%d/%d) %d from domain %d",
> +				 i+1, nr_grefs, gnt_ref[i], dev->otherend_id);
> +			node->handle[i] = INVALID_GRANT_HANDLE;
> +			goto rollback;
> +		} else
> +			node->handle[i] = op.handle;
>  	}
>  
> -	node->handle = op.handle;
> +	node->nr_handles = nr_grefs;
>  	node->area = area;
>  
>  	spin_lock(&xenbus_valloc_lock);
> @@ -512,31 +547,73 @@ static int xenbus_map_ring_valloc_pv(struct xenbus_device *dev,
>  
>  	*vaddr = area->addr;
>  	return 0;
> +
> +rollback:
> +	vma_leaked = 0;
> +	for ( ; i >= 0; i--) {
> +		if (node->handle[i] != INVALID_GRANT_HANDLE) {
> +			struct gnttab_unmap_grant_ref unmap_op;
> +			unmap_op.dev_bus_addr = 0;
> +			unmap_op.host_addr =
> +				arbitrary_virt_to_machine(pte[i]).maddr;
> +			unmap_op.handle = node->handle[i];
> +
> +			if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref,
> +						      &unmap_op, 1))
> +				BUG();
> +
> +			if (unmap_op.status != GNTST_okay) {
> +				pr_alert("rollback mapping (%d/%d) %d from domain %d, err = %d",
> +					 i+1, nr_grefs, gnt_ref[i],
> +					 dev->otherend_id,
> +					 unmap_op.status);
> +				vma_leaked = 1;
> +			}
> +			node->handle[i] = INVALID_GRANT_HANDLE;
> +		}
> +	}
> +
> +	if (!vma_leaked)
> +		free_vm_area(area);
> +	else
> +		pr_alert("leaking vm area %p size %d page(s)", area, nr_grefs);
> +
> +	kfree(node);
> +
> +	return err;
>  }
>  
>  static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
> -				      int gnt_ref, void **vaddr)
> +				      int *gnt_ref, int nr_grefs, void **vaddr)
>  {
>  	struct xenbus_map_node *node;
>  	int err;
>  	void *addr;
> +	int vma_leaked;
>  
>  	*vaddr = NULL;
>  
> +	if (nr_grefs > XENBUS_MAX_RING_PAGES)
> +		return -EINVAL;
> +
>  	node = kzalloc(sizeof(*node), GFP_KERNEL);
>  	if (!node)
>  		return -ENOMEM;
>  
> -	err = alloc_xenballooned_pages(1, &node->page, false /* lowmem */);
> +	err = alloc_xenballooned_pages(nr_grefs, &node->page,
> +				       false /* lowmem */);
>  	if (err)
>  		goto out_err;
>  
>  	addr = pfn_to_kaddr(page_to_pfn(node->page));
>  
> -	err = xenbus_map_ring(dev, gnt_ref, &node->handle, addr);
> +	err = xenbus_map_ring(dev, gnt_ref, nr_grefs, node->handle,
> +			      addr, &vma_leaked);
>  	if (err)
>  		goto out_err;
>  
> +	node->nr_handles = nr_grefs;
> +
>  	spin_lock(&xenbus_valloc_lock);
>  	list_add(&node->next, &xenbus_valloc_pages);
>  	spin_unlock(&xenbus_valloc_lock);
> @@ -545,7 +622,8 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
>  	return 0;
>  
>   out_err:
> -	free_xenballooned_pages(1, &node->page);
> +	if (!vma_leaked)
> +		free_xenballooned_pages(nr_grefs, &node->page);
>  	kfree(node);
>  	return err;
>  }
> @@ -554,36 +632,75 @@ static int xenbus_map_ring_valloc_hvm(struct xenbus_device *dev,
>  /**
>   * xenbus_map_ring
>   * @dev: xenbus device
> - * @gnt_ref: grant reference
> + * @gnt_ref: grant reference array
> + * @nr_grefs: number of grant reference
>   * @handle: pointer to grant handle to be filled
>   * @vaddr: address to be mapped to
> + * @vma_leaked: cannot clean up a failed mapping, vma leaked
>   *
> - * Map a page of memory into this domain from another domain's grant table.
> + * Map pages of memory into this domain from another domain's grant table.
>   * xenbus_map_ring does not allocate the virtual address space (you must do
> - * this yourself!). It only maps in the page to the specified address.
> + * this yourself!). It only maps in the pages to the specified address.
>   * Returns 0 on success, and GNTST_* (see xen/include/interface/grant_table.h)
>   * or -ENOMEM on error. If an error is returned, device will switch to
> - * XenbusStateClosing and the error message will be saved in XenStore.
> + * XenbusStateClosing and the last error message will be saved in XenStore.
>   */
> -int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
> -		    grant_handle_t *handle, void *vaddr)
> +int xenbus_map_ring(struct xenbus_device *dev, int *gnt_ref, int nr_grefs,
> +		    grant_handle_t *handle, void *vaddr, int *vma_leaked)
>  {
>  	struct gnttab_map_grant_ref op;
> +	int i;
> +	int err = GNTST_okay;
> +
> +	for (i = 0; i < nr_grefs; i++) {
> +		unsigned long addr = (unsigned long)vaddr +
> +			(PAGE_SIZE * i);
> +		gnttab_set_map_op(&op, (unsigned long)addr,
> +				  GNTMAP_host_map, gnt_ref[i],
> +				  dev->otherend_id);
> +
> +		if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref,
> +					      &op, 1))
> +			BUG();
> +
> +		if (op.status != GNTST_okay) {
> +			xenbus_dev_fatal(dev, op.status,
> +				 "mapping in shared page (%d/%d) %d from domain %d",
> +				 i+1, nr_grefs, gnt_ref[i], dev->otherend_id);
> +			handle[i] = INVALID_GRANT_HANDLE;
> +			goto rollback;
> +		} else
> +			handle[i] = op.handle;
> +	}
>  
> -	gnttab_set_map_op(&op, (unsigned long)vaddr, GNTMAP_host_map, gnt_ref,
> -			  dev->otherend_id);
> -
> -	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
> -		BUG();
> +	return 0;
>  
> -	if (op.status != GNTST_okay) {
> -		xenbus_dev_fatal(dev, op.status,
> -				 "mapping in shared page %d from domain %d",
> -				 gnt_ref, dev->otherend_id);
> -	} else
> -		*handle = op.handle;
> +rollback:
> +	*vma_leaked = 0;
> +	for ( ; i >= 0; i--) {
> +		if (handle[i] != INVALID_GRANT_HANDLE) {
> +			struct gnttab_unmap_grant_ref unmap_op;
> +			unsigned long addr = (unsigned long)vaddr +
> +				(PAGE_SIZE * i);
> +			gnttab_set_unmap_op(&unmap_op, (phys_addr_t)addr,
> +					    GNTMAP_host_map, handle[i]);
> +
> +			if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref,
> +						      &unmap_op, 1))
> +				BUG();
> +
> +			if (unmap_op.status != GNTST_okay) {
> +				pr_alert("rollback mapping (%d/%d) %d from domain %d, err = %d",
> +					 i+1, nr_grefs, gnt_ref[i],
> +					 dev->otherend_id,
> +					 unmap_op.status);
> +				*vma_leaked = 1;
> +			}
> +			handle[i] = INVALID_GRANT_HANDLE;
> +		}
> +	}
>  
> -	return op.status;
> +	return err;
>  }
>  EXPORT_SYMBOL_GPL(xenbus_map_ring);
>  
> @@ -609,10 +726,11 @@ EXPORT_SYMBOL_GPL(xenbus_unmap_ring_vfree);
>  static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)
>  {
>  	struct xenbus_map_node *node;
> -	struct gnttab_unmap_grant_ref op = {
> -		.host_addr = (unsigned long)vaddr,
> -	};
> +	struct gnttab_unmap_grant_ref op[XENBUS_MAX_RING_PAGES];
>  	unsigned int level;
> +	int i;
> +	int last_error = GNTST_okay;
> +	int vma_leaked;

bool
>  
>  	spin_lock(&xenbus_valloc_lock);
>  	list_for_each_entry(node, &xenbus_valloc_pages, next) {
> @@ -631,22 +749,39 @@ static int xenbus_unmap_ring_vfree_pv(struct xenbus_device *dev, void *vaddr)
>  		return GNTST_bad_virt_addr;
>  	}
>  
> -	op.handle = node->handle;
> -	op.host_addr = arbitrary_virt_to_machine(
> -		lookup_address((unsigned long)vaddr, &level)).maddr;
> +	for (i = 0; i < node->nr_handles; i++) {
> +		unsigned long addr = (unsigned long)vaddr +
> +			(PAGE_SIZE * i);
> +		op[i].dev_bus_addr = 0;
> +		op[i].handle = node->handle[i];
> +		op[i].host_addr = arbitrary_virt_to_machine(
> +			lookup_address((unsigned long)addr, &level)).maddr;
> +	}
>  
> -	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
> +	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, op,
> +				      node->nr_handles))
>  		BUG();
>  
> -	if (op.status == GNTST_okay)
> +	vma_leaked = 0;
> +	for (i = 0; i < node->nr_handles; i++) {
> +		if (op[i].status != GNTST_okay) {
> +			last_error = op[i].status;
> +			vma_leaked = 1;
> +			xenbus_dev_error(dev, op[i].status,
> +				 "unmapping page (%d/%d) at handle %d error %d",
> +				 i+1, node->nr_handles, node->handle[i],
> +				 op[i].status);
> +		}
> +	}
> +
> +	if (!vma_leaked)
>  		free_vm_area(node->area);
>  	else
> -		xenbus_dev_error(dev, op.status,
> -				 "unmapping page at handle %d error %d",
> -				 node->handle, op.status);
> +		pr_alert("leaking vm area %p size %d page(s)",
> +			 node->area, node->nr_handles);
>  
>  	kfree(node);
> -	return op.status;
> +	return last_error;
>  }
>  
>  static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
> @@ -673,10 +808,10 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
>  		return GNTST_bad_virt_addr;
>  	}
>  
> -	rv = xenbus_unmap_ring(dev, node->handle, addr);
> +	rv = xenbus_unmap_ring(dev, node->handle, node->nr_handles, addr);
>  
>  	if (!rv)
> -		free_xenballooned_pages(1, &node->page);
> +		free_xenballooned_pages(node->nr_handles, &node->page);
>  	else
>  		WARN(1, "Leaking %p\n", vaddr);
>  
> @@ -687,7 +822,8 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
>  /**
>   * xenbus_unmap_ring
>   * @dev: xenbus device
> - * @handle: grant handle
> + * @handle: grant handle array
> + * @nr_handles: number of grant handles
>   * @vaddr: addr to unmap
>   *
>   * Unmap a page of memory in this domain that was imported from another domain.
> @@ -695,21 +831,33 @@ static int xenbus_unmap_ring_vfree_hvm(struct xenbus_device *dev, void *vaddr)
>   * (see xen/include/interface/grant_table.h).
>   */
>  int xenbus_unmap_ring(struct xenbus_device *dev,
> -		      grant_handle_t handle, void *vaddr)
> +		      grant_handle_t *handle, int nr_handles,
> +		      void *vaddr)
>  {
>  	struct gnttab_unmap_grant_ref op;
> +	int last_error = GNTST_okay;
> +	int i;
> +
> +	for (i = 0; i < nr_handles; i++) {
> +		unsigned long addr = (unsigned long)vaddr +
> +			(PAGE_SIZE * i);
> +		gnttab_set_unmap_op(&op, (unsigned long)addr,
> +				    GNTMAP_host_map, handle[i]);
> +		handle[i] = INVALID_GRANT_HANDLE;
> +
> +		if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref,
> +					      &op, 1))
> +			BUG();
> +
> +		if (op.status != GNTST_okay) {
> +			xenbus_dev_error(dev, op.status,
> +				 "unmapping page (%d/%d) at handle %d error %d",
> +				 i+1, nr_handles, handle[i], op.status);
> +			last_error = op.status;
> +		}
> +	}
>  
> -	gnttab_set_unmap_op(&op, (unsigned long)vaddr, GNTMAP_host_map, handle);
> -
> -	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
> -		BUG();
> -
> -	if (op.status != GNTST_okay)
> -		xenbus_dev_error(dev, op.status,
> -				 "unmapping page at handle %d error %d",
> -				 handle, op.status);
> -
> -	return op.status;
> +	return last_error;
>  }
>  EXPORT_SYMBOL_GPL(xenbus_unmap_ring);
>  
> diff --git a/include/xen/xenbus.h b/include/xen/xenbus.h
> index 0a7515c..b7d9613 100644
> --- a/include/xen/xenbus.h
> +++ b/include/xen/xenbus.h
> @@ -46,6 +46,11 @@
>  #include <xen/interface/io/xenbus.h>
>  #include <xen/interface/io/xs_wire.h>
>  
> +/* Max pages supported by multi-page ring in the backend */
> +#define XENBUS_MAX_RING_PAGE_ORDER  2
> +#define XENBUS_MAX_RING_PAGES       (1U << XENBUS_MAX_RING_PAGE_ORDER)

So why this value? If this is a mechanical change shouldn't the order be '0' ?

> +#define INVALID_GRANT_HANDLE        (~0U)
> +
>  /* Register callback to watch this node. */
>  struct xenbus_watch
>  {
> @@ -195,15 +200,17 @@ int xenbus_watch_pathfmt(struct xenbus_device *dev, struct xenbus_watch *watch,
>  			 const char *pathfmt, ...);
>  
>  int xenbus_switch_state(struct xenbus_device *dev, enum xenbus_state new_state);
> -int xenbus_grant_ring(struct xenbus_device *dev, unsigned long ring_mfn);
> +int xenbus_grant_ring(struct xenbus_device *dev, void *vaddr,
> +		      int nr_gages, int *grefs);
>  int xenbus_map_ring_valloc(struct xenbus_device *dev,
> -			   int gnt_ref, void **vaddr);
> -int xenbus_map_ring(struct xenbus_device *dev, int gnt_ref,
> -			   grant_handle_t *handle, void *vaddr);
> +			   int *gnt_ref, int nr_grefs, void **vaddr);
> +int xenbus_map_ring(struct xenbus_device *dev, int *gnt_ref, int nr_grefs,
> +		    grant_handle_t *handle, void *vaddr, int *vma_leaked);
>  
>  int xenbus_unmap_ring_vfree(struct xenbus_device *dev, void *vaddr);
>  int xenbus_unmap_ring(struct xenbus_device *dev,
> -		      grant_handle_t handle, void *vaddr);
> +		      grant_handle_t *handle, int nr_handles,
> +		      void *vaddr);
>  
>  int xenbus_alloc_evtchn(struct xenbus_device *dev, int *port);
>  int xenbus_bind_evtchn(struct xenbus_device *dev, int remote_port, int *port);
> -- 
> 1.7.10.4
> 
