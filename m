From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V4 09/13] Bundle fix for xen backends and frontends
Date: Thu, 2 Feb 2012 21:34:20 -0500
Message-ID: <20120203023420.GA25511@phenom.dumpdata.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
 <1328201363-13915-10-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:33980 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab2BCChD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 21:37:03 -0500
Content-Disposition: inline
In-Reply-To: <1328201363-13915-10-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2012 at 04:49:19PM +0000, Wei Liu wrote:
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/block/xen-blkback/xenbus.c    |    8 +++++---
>  drivers/block/xen-blkfront.c          |    5 +++--
>  drivers/net/xen-netback/netback.c     |    4 ++--
>  drivers/net/xen-netfront.c            |    9 +++++----
>  drivers/pci/xen-pcifront.c            |    5 +++--
>  drivers/scsi/xen-scsiback/common.h    |    3 ++-
>  drivers/scsi/xen-scsiback/interface.c |    6 ++++--
>  drivers/scsi/xen-scsiback/xenbus.c    |    4 ++--
>  drivers/scsi/xen-scsifront/xenbus.c   |    5 +++--

Heheh. If you could seperate the scsi[back|front] from this
patchset that would be great. The reason is that SCSI front/back
aren't yet ready for upstream.

>  drivers/xen/xen-pciback/xenbus.c      |   11 ++++++-----
>  10 files changed, 35 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/block/xen-blkback/xenbus.c b/drivers/block/xen-blkback/xenbus.c
> index 9e9c8a1..ef7e88b 100644
> --- a/drivers/block/xen-blkback/xenbus.c
> +++ b/drivers/block/xen-blkback/xenbus.c
> @@ -122,7 +122,8 @@ static struct xen_blkif *xen_blkif_alloc(domid_t domid)
>  	return blkif;
>  }
>  
> -static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
> +static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page[],
> +			 int nr_pages,
>  			 unsigned int evtchn)
>  {
>  	int err;
> @@ -131,7 +132,8 @@ static int xen_blkif_map(struct xen_blkif *blkif, unsigned long shared_page,
>  	if (blkif->irq)
>  		return 0;
>  
> -	err = xenbus_map_ring_valloc(blkif->be->dev, shared_page, &blkif->blk_ring);
> +	err = xenbus_map_ring_valloc(blkif->be->dev, shared_page,
> +				     nr_pages, &blkif->blk_ring);
>  	if (err < 0)
>  		return err;
>  
> @@ -779,7 +781,7 @@ static int connect_ring(struct backend_info *be)
>  		ring_ref, evtchn, be->blkif->blk_protocol, protocol);
>  
>  	/* Map the shared frame, irq etc. */
> -	err = xen_blkif_map(be->blkif, ring_ref, evtchn);
> +	err = xen_blkif_map(be->blkif, &ring_ref, 1, evtchn);
>  	if (err) {
>  		xenbus_dev_fatal(dev, err, "mapping ring-ref %lu port %u",
>  				 ring_ref, evtchn);
> diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
> index 2f22874..2c6443a 100644
> --- a/drivers/block/xen-blkfront.c
> +++ b/drivers/block/xen-blkfront.c
> @@ -827,6 +827,7 @@ static int setup_blkring(struct xenbus_device *dev,
>  {
>  	struct blkif_sring *sring;
>  	int err;
> +	int grefs[1];
>  
>  	info->ring_ref = GRANT_INVALID_REF;
>  
> @@ -840,13 +841,13 @@ static int setup_blkring(struct xenbus_device *dev,
>  
>  	sg_init_table(info->sg, BLKIF_MAX_SEGMENTS_PER_REQUEST);
>  
> -	err = xenbus_grant_ring(dev, virt_to_mfn(info->ring.sring));
> +	err = xenbus_grant_ring(dev, info->ring.sring, 1, grefs);
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
> index 384f4e5..cb1a661 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1440,7 +1440,7 @@ int xenvif_map_frontend_rings(struct xenvif *vif,
>  	int err = -ENOMEM;
>  
>  	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     tx_ring_ref, &addr);
> +				     &tx_ring_ref, 1, &addr);
>  	if (err)
>  		goto err;
>  
> @@ -1448,7 +1448,7 @@ int xenvif_map_frontend_rings(struct xenvif *vif,
>  	BACK_RING_INIT(&vif->tx, txs, PAGE_SIZE);
>  
>  	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> -				     rx_ring_ref, &addr);
> +				     &rx_ring_ref, 1, &addr);
>  	if (err)
>  		goto err;
>  
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 01f589d..b7ff815 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1482,6 +1482,7 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
>  	struct xen_netif_tx_sring *txs;
>  	struct xen_netif_rx_sring *rxs;
>  	int err;
> +	int grefs[1];
>  	struct net_device *netdev = info->netdev;
>  
>  	info->tx_ring_ref = GRANT_INVALID_REF;
> @@ -1505,13 +1506,13 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
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
> @@ -1521,12 +1522,12 @@ static int setup_netfront(struct xenbus_device *dev, struct netfront_info *info)
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
> index 7cf3d2f..394c926 100644
> --- a/drivers/pci/xen-pcifront.c
> +++ b/drivers/pci/xen-pcifront.c
> @@ -767,12 +767,13 @@ static int pcifront_publish_info(struct pcifront_device *pdev)
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
> diff --git a/drivers/scsi/xen-scsiback/common.h b/drivers/scsi/xen-scsiback/common.h
> index dafa79e..4d13617 100644
> --- a/drivers/scsi/xen-scsiback/common.h
> +++ b/drivers/scsi/xen-scsiback/common.h
> @@ -150,7 +150,8 @@ typedef struct {
>  
>  irqreturn_t scsiback_intr(int, void *);
>  int scsiback_init_sring(struct vscsibk_info *info,
> -		unsigned long ring_ref, unsigned int evtchn);
> +			int ring_ref[], int nr_refs,
> +			unsigned int evtchn);
>  int scsiback_schedule(void *data);
>  
>  
> diff --git a/drivers/scsi/xen-scsiback/interface.c b/drivers/scsi/xen-scsiback/interface.c
> index 663568e..fad0a63 100644
> --- a/drivers/scsi/xen-scsiback/interface.c
> +++ b/drivers/scsi/xen-scsiback/interface.c
> @@ -60,7 +60,8 @@ struct vscsibk_info *vscsibk_info_alloc(domid_t domid)
>  }
>  
>  int scsiback_init_sring(struct vscsibk_info *info,
> -		unsigned long ring_ref, unsigned int evtchn)
> +			int ring_ref[], int nr_refs,
> +			unsigned int evtchn)
>  {
>  	struct vscsiif_sring *sring;
>  	int err;
> @@ -73,7 +74,8 @@ int scsiback_init_sring(struct vscsibk_info *info,
>  		return -1;
>  	}
>  
> -	err = xenbus_map_ring_valloc(info->dev, ring_ref, &info->ring_area);
> +	err = xenbus_map_ring_valloc(info->dev, ring_ref, nr_refs,
> +				     &info->ring_area);
>  	if (err < 0)
>  		return -ENOMEM;
>  
> diff --git a/drivers/scsi/xen-scsiback/xenbus.c b/drivers/scsi/xen-scsiback/xenbus.c
> index 2869f89..81d5598 100644
> --- a/drivers/scsi/xen-scsiback/xenbus.c
> +++ b/drivers/scsi/xen-scsiback/xenbus.c
> @@ -60,7 +60,7 @@ static int __vscsiif_name(struct backend_info *be, char *buf)
>  static int scsiback_map(struct backend_info *be)
>  {
>  	struct xenbus_device *dev = be->dev;
> -	unsigned long ring_ref = 0;
> +	int ring_ref = 0;
>  	unsigned int evtchn = 0;
>  	int err;
>  	char name[TASK_COMM_LEN];
> @@ -72,7 +72,7 @@ static int scsiback_map(struct backend_info *be)
>  		xenbus_dev_fatal(dev, err, "reading %s ring", dev->otherend);
>  		return err;
>  	}
> -	err = scsiback_init_sring(be->info, ring_ref, evtchn);
> +	err = scsiback_init_sring(be->info, &ring_ref, 1, evtchn);
>  	if (err)
>  		return err;
>  
> diff --git a/drivers/scsi/xen-scsifront/xenbus.c b/drivers/scsi/xen-scsifront/xenbus.c
> index bc5c289..8726410 100644
> --- a/drivers/scsi/xen-scsifront/xenbus.c
> +++ b/drivers/scsi/xen-scsifront/xenbus.c
> @@ -60,6 +60,7 @@ static int scsifront_alloc_ring(struct vscsifrnt_info *info)
>  	struct xenbus_device *dev = info->dev;
>  	struct vscsiif_sring *sring;
>  	int err = -ENOMEM;
> +	int grefs[1];
>  
>  
>  	info->ring_ref = GRANT_INVALID_REF;
> @@ -73,14 +74,14 @@ static int scsifront_alloc_ring(struct vscsifrnt_info *info)
>  	SHARED_RING_INIT(sring);
>  	FRONT_RING_INIT(&info->ring, sring, PAGE_SIZE);
>  
> -	err = xenbus_grant_ring(dev, virt_to_mfn(sring));
> +	err = xenbus_grant_ring(dev, sring, 1, grefs);
>  	if (err < 0) {
>  		free_page((unsigned long) sring);
>  		info->ring.sring = NULL;
>  		xenbus_dev_fatal(dev, err, "fail to grant shared ring (Front to Back)");
>  		goto free_sring;
>  	}
> -	info->ring_ref = err;
> +	info->ring_ref = grefs[0];
>  
>  	err = xenbus_alloc_evtchn(dev, &info->evtchn);
>  	if (err)
> diff --git a/drivers/xen/xen-pciback/xenbus.c b/drivers/xen/xen-pciback/xenbus.c
> index 5a42ae7..0d8a98c 100644
> --- a/drivers/xen/xen-pciback/xenbus.c
> +++ b/drivers/xen/xen-pciback/xenbus.c
> @@ -98,17 +98,18 @@ static void free_pdev(struct xen_pcibk_device *pdev)
>  	kfree(pdev);
>  }
>  
> -static int xen_pcibk_do_attach(struct xen_pcibk_device *pdev, int gnt_ref,
> -			     int remote_evtchn)
> +static int xen_pcibk_do_attach(struct xen_pcibk_device *pdev, int gnt_ref[],
> +			       int nr_grefs,
> +			       int remote_evtchn)
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
> @@ -172,7 +173,7 @@ static int xen_pcibk_attach(struct xen_pcibk_device *pdev)
>  		goto out;
>  	}
>  
> -	err = xen_pcibk_do_attach(pdev, gnt_ref, remote_evtchn);
> +	err = xen_pcibk_do_attach(pdev, &gnt_ref, 1, remote_evtchn);
>  	if (err)
>  		goto out;
>  
> -- 
> 1.7.2.5
