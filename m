From: Bhavesh Davda <bhavesh@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: fix starving rx ring when
 alloc_skb	fails
Date: Thu, 16 Jun 2011 15:56:03 -0700
Message-ID: <B07832953588294D802727FF264E276A11E6AC8772@exch-mbx-112.vmware.com>
References: <1308261747-17702-1-git-send-email-scottjg@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: Scott Goldman <scottjg@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:14807 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755910Ab1FPW4A convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 18:56:00 -0400
Received: from mailhost3.vmware.com (mailhost3.vmware.com [10.16.27.45])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 15AAE31020
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2011 15:56:00 -0700 (PDT)
In-Reply-To: <1308261747-17702-1-git-send-email-scottjg@vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LGTM.

Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

> -----Original Message-----
> From: pv-drivers-bounces@vmware.com [mailto:pv-drivers-bounces@vmware.com] On
> Behalf Of Scott J. Goldman
> Sent: Thursday, June 16, 2011 3:02 PM
> To: netdev@vger.kernel.org; pv-drivers@vmware.com
> Subject: [Pv-drivers] [PATCH] vmxnet3: fix starving rx ring when alloc_skb
> fails
> 
> if the rx ring is completely empty, then the device may never fire an rx
> interrupt. unfortunately, the rx interrupt is what triggers populating
> the rx ring with fresh buffers, so this will cause networking to lock
> up.
> 
> this patch recycles the last skb that we were about to indicate up to
> the network stack (only if the rx ring is completely starved of skbs)
> so the ring will never be completely empty. If we fail to allocate a
> secondary page buffer, we just indicate a 0 length buffer to the device.
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c |   98 +++++++++++++++++++++++++-----------
>  drivers/net/vmxnet3/vmxnet3_int.h |    5 +-
>  2 files changed, 70 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c
> b/drivers/net/vmxnet3/vmxnet3_drv.c
> index 33097ec..cfa9ff7 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -558,6 +558,17 @@ vmxnet3_tq_cleanup_all(struct vmxnet3_adapter *adapter)
>  		vmxnet3_tq_cleanup(&adapter->tx_queue[i], adapter);
>  }
> 
> +static bool
> +vmxnet3_rq_empty(const struct vmxnet3_rx_queue *rq, u32 ring_idx)
> +{
> +	const struct vmxnet3_cmd_ring *ring = &rq->rx_ring[ring_idx];
> +	u32 i = ring->next2comp;
> +	while (rq->buf_info[ring_idx][i].buf_type != VMXNET3_RX_BUF_SKB)
> +		VMXNET3_INC_RING_IDX_ONLY(i, ring->size);
> +
> +	return (i == ring->next2fill);
> +}
> +
>  /*
>   *    starting from ring->next2fill, allocate rx buffers for the given ring
>   *    of the rx queue and update the rx desc. stop after @num_to_alloc
> buffers
> @@ -571,9 +582,12 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32
> ring_idx,
>  	int num_allocated = 0;
>  	struct vmxnet3_rx_buf_info *rbi_base = rq->buf_info[ring_idx];
>  	struct vmxnet3_cmd_ring *ring = &rq->rx_ring[ring_idx];
> +	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
> +	bool alloc_skb_failed = false;
>  	u32 val;
> +	u32 len;
> 
> -	while (num_allocated < num_to_alloc) {
> +	while (num_allocated < num_to_alloc && !alloc_skb_failed) {
>  		struct vmxnet3_rx_buf_info *rbi;
>  		union Vmxnet3_GenericDesc *gd;
> 
> @@ -586,7 +600,27 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32
> ring_idx,
>  							 NET_IP_ALIGN);
>  				if (unlikely(rbi->skb == NULL)) {
>  					rq->stats.rx_buf_alloc_failure++;
> -					break;
> +					alloc_skb_failed = true;
> +					/*
> +					 * if allocation failed and ring is
> +					 * empty, we recycle the last skb we
> +					 * rx'ed so that we don't starve the
> +					 * rx ring
> +					 */
> +					if (ctx->skb &&
> +					    vmxnet3_rq_empty(rq, ring_idx)) {
> +						rbi->skb = ctx->skb;
> +						ctx->skb = NULL;
> +						skb_recycle_check(rbi->skb,
> +								  rbi->len +
> +								  NET_IP_ALIGN);
> +						/*
> +						 * free any frags chained to
> +						 * the skb
> +						 */
> +						__pskb_trim(rbi->skb, 0);
> +					} else
> +						break;
>  				}
>  				rbi->skb->dev = adapter->netdev;
> 
> @@ -594,8 +628,10 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32
> ring_idx,
>  				rbi->dma_addr = pci_map_single(adapter->pdev,
>  						rbi->skb->data, rbi->len,
>  						PCI_DMA_FROMDEVICE);
> +				len = rbi->len;
>  			} else {
>  				/* rx buffer skipped by the device */
> +				len = rbi->len;
>  			}
>  			val = VMXNET3_RXD_BTYPE_HEAD << VMXNET3_RXD_BTYPE_SHIFT;
>  		} else {
> @@ -606,13 +642,18 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32
> ring_idx,
>  				rbi->page = alloc_page(GFP_ATOMIC);
>  				if (unlikely(rbi->page == NULL)) {
>  					rq->stats.rx_buf_alloc_failure++;
> -					break;
> +					len = 0;
> +				} else {
> +					rbi->dma_addr = pci_map_page(
> +							    adapter->pdev,
> +							    rbi->page, 0,
> +							    PAGE_SIZE,
> +							    PCI_DMA_FROMDEVICE);
> +					len = rbi->len;
>  				}
> -				rbi->dma_addr = pci_map_page(adapter->pdev,
> -						rbi->page, 0, PAGE_SIZE,
> -						PCI_DMA_FROMDEVICE);
>  			} else {
>  				/* rx buffers skipped by the device */
> +				len = rbi->len;
>  			}
>  			val = VMXNET3_RXD_BTYPE_BODY << VMXNET3_RXD_BTYPE_SHIFT;
>  		}
> @@ -620,7 +661,7 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32
> ring_idx,
>  		BUG_ON(rbi->dma_addr == 0);
>  		gd->rxd.addr = cpu_to_le64(rbi->dma_addr);
>  		gd->dword[2] = cpu_to_le32((ring->gen << VMXNET3_RXD_GEN_SHIFT)
> -					   | val | rbi->len);
> +					   | val | len);
> 
>  		num_allocated++;
>  		vmxnet3_cmd_ring_adv_next2fill(ring);
> @@ -1148,7 +1189,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  			  &rxComp);
>  	while (rcd->gen == rq->comp_ring.gen) {
>  		struct vmxnet3_rx_buf_info *rbi;
> -		struct sk_buff *skb;
>  		int num_to_alloc;
>  		struct Vmxnet3_RxDesc *rxd;
>  		u32 idx, ring_idx;
> @@ -1168,7 +1208,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  		rbi = rq->buf_info[ring_idx] + idx;
> 
>  		BUG_ON(rxd->addr != rbi->dma_addr ||
> -		       rxd->len != rbi->len);
> +		       (rxd->len != rbi->len && rbi->len != 0));
> 
>  		if (unlikely(rcd->eop && rcd->err)) {
>  			vmxnet3_rx_error(rq, rcd, ctx, adapter);
> @@ -1198,8 +1238,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  					 PCI_DMA_FROMDEVICE);
> 
>  			skb_put(ctx->skb, rcd->len);
> -		} else {
> -			BUG_ON(ctx->skb == NULL);
> +		} else if (ctx->skb) {
>  			/* non SOP buffer must be type 1 in most cases */
>  			if (rbi->buf_type == VMXNET3_RX_BUF_PAGE) {
>  				BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_BODY);
> @@ -1222,25 +1261,6 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  			}
>  		}
> 
> -		skb = ctx->skb;
> -		if (rcd->eop) {
> -			skb->len += skb->data_len;
> -			skb->truesize += skb->data_len;
> -
> -			vmxnet3_rx_csum(adapter, skb,
> -					(union Vmxnet3_GenericDesc *)rcd);
> -			skb->protocol = eth_type_trans(skb, adapter->netdev);
> -
> -			if (unlikely(adapter->vlan_grp && rcd->ts)) {
> -				vlan_hwaccel_receive_skb(skb,
> -						adapter->vlan_grp, rcd->tci);
> -			} else {
> -				netif_receive_skb(skb);
> -			}
> -
> -			ctx->skb = NULL;
> -		}
> -
>  rcd_done:
>  		/* device may skip some rx descs */
>  		rq->rx_ring[ring_idx].next2comp = idx;
> @@ -1264,6 +1284,24 @@ rcd_done:
>  			}
>  		}
> 
> +		if (rcd->eop && ctx->skb) {
> +			ctx->skb->len += ctx->skb->data_len;
> +			ctx->skb->truesize += ctx->skb->data_len;
> +
> +			vmxnet3_rx_csum(adapter, ctx->skb,
> +					(union Vmxnet3_GenericDesc *)rcd);
> +			ctx->skb->protocol = eth_type_trans(ctx->skb,
> +							    adapter->netdev);
> +			if (unlikely(adapter->vlan_grp && rcd->ts)) {
> +				vlan_hwaccel_receive_skb(ctx->skb,
> +							 adapter->vlan_grp,
> +							 rcd->tci);
> +			} else {
> +				netif_receive_skb(ctx->skb);
> +			}
> +			ctx->skb = NULL;
> +		}
> +
>  		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
>  		vmxnet3_getRxComp(rcd,
>  		     &rq->comp_ring.base[rq->comp_ring.next2proc].rcd, &rxComp);
> diff --git a/drivers/net/vmxnet3/vmxnet3_int.h
> b/drivers/net/vmxnet3/vmxnet3_int.h
> index 0e567c24..cb13ed7 100644
> --- a/drivers/net/vmxnet3/vmxnet3_int.h
> +++ b/drivers/net/vmxnet3/vmxnet3_int.h
> @@ -68,10 +68,10 @@
>  /*
>   * Version numbers
>   */
> -#define VMXNET3_DRIVER_VERSION_STRING   "1.1.9.0-k"
> +#define VMXNET3_DRIVER_VERSION_STRING   "1.1.10.0-k"
> 
>  /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION
> */
> -#define VMXNET3_DRIVER_VERSION_NUM      0x01010900
> +#define VMXNET3_DRIVER_VERSION_NUM      0x01010A00
> 
>  #if defined(CONFIG_PCI_MSI)
>  	/* RSS only makes sense if MSI-X is supported. */
> @@ -255,7 +255,6 @@ struct vmxnet3_rx_buf_info {
> 
>  struct vmxnet3_rx_ctx {
>  	struct sk_buff *skb;
> -	u32 sop_idx;
>  };
> 
>  struct vmxnet3_rq_driver_stats {
> --
> 1.7.4.1
> 
> _______________________________________________
> Pv-drivers mailing list
> Pv-drivers@vmware.com
> http://mailman2.vmware.com/mailman/listinfo/pv-drivers
