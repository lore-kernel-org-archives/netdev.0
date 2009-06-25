From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] vxge: fix GRO receive with INTA interrupts
Date: Thu, 25 Jun 2009 17:18:19 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77056E4779@nekter>
References: <20090625183134.40e8fd7a@leela>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:59871 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbZFYVSV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 17:18:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090625183134.40e8fd7a@leela>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

Thanks. We are in the midst of submitting a few bug fixes and will add
this fix to the list. We fixed it without assuming that only 1 vpath
will be enabled with INTA. It's been hard coded to 1 with INTA, for
performance reasons, but when I get some time, I'd like to optimize the
completion handling to over come this issue.

Ram
> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Thursday, June 25, 2009 9:32 AM
> To: Ramkrishna Vepa
> Cc: netdev@vger.kernel.org
> Subject: [PATCH] vxge: fix GRO receive with INTA interrupts
> 
> TCP receiving in vxge is extremely slow when using INTA interrupts.
> The bug is that vxge_poll_inta() receives frames on ring->napi's
> gro_list, but never flushes GRO for this napi_struct, because there's
> a second napi_struct in struct vxgedev.
> There's no need for the second napi_struct. We can use ring->napi
> only. When vxge has to fallback to INTA, we know there will be exactly
> one vpath (and exactly one vxge_ring). This change results in a
cleanup
> too.
> Tested successfully with netperf, booted with and without pci=nomsi.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> commit c60c53194a4ed435294fffba239a0b264e208483
> Author: Michal Schmidt <mschmidt@redhat.com>
> Date:   Thu Jun 25 15:06:57 2009 +0200
> 
>     vxge: missing GRO flush when using INTA
> 
>     Fixes very slow TCP.
> 
> diff --git a/drivers/net/vxge/vxge-main.c
b/drivers/net/vxge/vxge-main.c
> index 6034497..6132ef4 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -1660,7 +1660,7 @@ int vxge_reset(struct vxgedev *vdev)
> 
>  /**
>   * vxge_poll - Receive handler when Receive Polling is used.
> - * @dev: pointer to the device structure.
> + * @napi: pointer to the NAPI structure.
>   * @budget: Number of packets budgeted to be processed in this
iteration.
>   *
>   * This function comes into picture only if Receive side is being
handled
> @@ -1672,14 +1672,12 @@ int vxge_reset(struct vxgedev *vdev)
>   */
>  static int vxge_poll_msix(struct napi_struct *napi, int budget)
>  {
> -	struct vxge_ring *ring =
> -		container_of(napi, struct vxge_ring, napi);
> -	int budget_org = budget;
> -	ring->budget = budget;
> +	struct vxge_ring *ring = container_of(napi, struct vxge_ring,
napi);
> 
> +	ring->budget = budget;
>  	vxge_hw_vpath_poll_rx(ring->handle);
> 
> -	if (ring->pkts_processed < budget_org) {
> +	if (ring->pkts_processed < budget) {
>  		napi_complete(napi);
>  		/* Re enable the Rx interrupts for the vpath */
>  		vxge_hw_channel_msix_unmask(
> @@ -1692,35 +1690,24 @@ static int vxge_poll_msix(struct napi_struct
> *napi, int budget)
> 
>  static int vxge_poll_inta(struct napi_struct *napi, int budget)
>  {
> -	struct vxgedev *vdev = container_of(napi, struct vxgedev, napi);
> -	int pkts_processed = 0;
> -	int i;
> -	int budget_org = budget;
> -	struct vxge_ring *ring;
> -
> -	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device *)
> -		pci_get_drvdata(vdev->pdev);
> +	struct vxge_ring *ring = container_of(napi, struct vxge_ring,
napi);
> +	struct vxge_vpath *vpath = container_of(ring, struct vxge_vpath,
> ring);
> +	struct vxgedev *vdev = vpath->vdev;
> 
> -	for (i = 0; i < vdev->no_of_vpath; i++) {
> -		ring = &vdev->vpaths[i].ring;
> -		ring->budget = budget;
> -		vxge_hw_vpath_poll_rx(ring->handle);
> -		pkts_processed += ring->pkts_processed;
> -		budget -= ring->pkts_processed;
> -		if (budget <= 0)
> -			break;
> -	}
> +	ring->budget = budget;
> +	vxge_hw_vpath_poll_rx(ring->handle);
> 
>  	VXGE_COMPLETE_ALL_TX(vdev);
> 
> -	if (pkts_processed < budget_org) {
> +	if (ring->pkts_processed < budget) {
> +		struct __vxge_hw_device *hldev = vdev->devh;
>  		napi_complete(napi);
>  		/* Re enable the Rx interrupts for the ring */
>  		vxge_hw_device_unmask_all(hldev);
>  		vxge_hw_device_flush_io(hldev);
>  	}
> 
> -	return pkts_processed;
> +	return ring->pkts_processed;
>  }
> 
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -2165,7 +2152,7 @@ static irqreturn_t vxge_isr_napi(int irq, void
> *dev_id)
>  			(64 - VXGE_HW_MAX_VIRTUAL_PATHS))) {
> 
>  			vxge_hw_device_clear_tx_rx(hldev);
> -			napi_schedule(&vdev->napi);
> +			napi_schedule(&vdev->vpaths[0].ring.napi);
>  			vxge_debug_intr(VXGE_TRACE,
>  				"%s:%d  Exiting...", __func__,
__LINE__);
>  			return IRQ_HANDLED;
> @@ -2707,17 +2694,12 @@ vxge_open(struct net_device *dev)
>  		goto out1;
>  	}
> 
> -
> -	if (vdev->config.intr_type != MSI_X) {
> -		netif_napi_add(dev, &vdev->napi, vxge_poll_inta,
> +	for (i = 0; i < vdev->no_of_vpath; i++) {
> +		netif_napi_add(dev, &vdev->vpaths[i].ring.napi,
> +			vdev->config.intr_type == MSI_X ?
> +				vxge_poll_msix : vxge_poll_inta,
>  			vdev->config.napi_weight);
> -		napi_enable(&vdev->napi);
> -	} else {
> -		for (i = 0; i < vdev->no_of_vpath; i++) {
> -			netif_napi_add(dev, &vdev->vpaths[i].ring.napi,
> -			    vxge_poll_msix, vdev->config.napi_weight);
> -			napi_enable(&vdev->vpaths[i].ring.napi);
> -		}
> +		napi_enable(&vdev->vpaths[i].ring.napi);
>  	}
> 
>  	/* configure RTH */
> @@ -2835,13 +2817,8 @@ out2:
>  	vxge_rem_isr(vdev);
> 
>  	/* Disable napi */
> -	if (vdev->config.intr_type != MSI_X)
> -		napi_disable(&vdev->napi);
> -	else {
> -		for (i = 0; i < vdev->no_of_vpath; i++)
> -			napi_disable(&vdev->vpaths[i].ring.napi);
> -	}
> -
> +	for (i = 0; i < vdev->no_of_vpath; i++)
> +		napi_disable(&vdev->vpaths[i].ring.napi);
>  out1:
>  	vxge_close_vpaths(vdev, 0);
>  out0:
> @@ -2868,13 +2845,8 @@ void vxge_free_mac_add_list(struct vxge_vpath
> *vpath)
>  static void vxge_napi_del_all(struct vxgedev *vdev)
>  {
>  	int i;
> -	if (vdev->config.intr_type != MSI_X)
> -		netif_napi_del(&vdev->napi);
> -	else {
> -		for (i = 0; i < vdev->no_of_vpath; i++)
> -			netif_napi_del(&vdev->vpaths[i].ring.napi);
> -	}
> -	return;
> +	for (i = 0; i < vdev->no_of_vpath; i++)
> +		netif_napi_del(&vdev->vpaths[i].ring.napi);
>  }
> 
>  int do_vxge_close(struct net_device *dev, int do_io)
> @@ -2940,12 +2912,8 @@ int do_vxge_close(struct net_device *dev, int
> do_io)
>  	del_timer_sync(&vdev->vp_reset_timer);
> 
>  	/* Disable napi */
> -	if (vdev->config.intr_type != MSI_X)
> -		napi_disable(&vdev->napi);
> -	else {
> -		for (i = 0; i < vdev->no_of_vpath; i++)
> -			napi_disable(&vdev->vpaths[i].ring.napi);
> -	}
> +	for (i = 0; i < vdev->no_of_vpath; i++)
> +		napi_disable(&vdev->vpaths[i].ring.napi);
> 
>  	netif_carrier_off(vdev->ndev);
>  	printk(KERN_NOTICE "%s: Link Down\n", vdev->ndev->name);
> diff --git a/drivers/net/vxge/vxge-main.h
b/drivers/net/vxge/vxge-main.h
> index 9704b2b..2b6a2ea 100644
> --- a/drivers/net/vxge/vxge-main.h
> +++ b/drivers/net/vxge/vxge-main.h
> @@ -348,7 +348,6 @@ struct vxgedev {
>  	int max_vpath_supported;
>  	int no_of_vpath;
> 
> -	struct napi_struct napi;
>  	/* A debug option, when enabled and if error condition occurs,
>  	 * the driver will do following steps:
>  	 * - mask all interrupts
