From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] Fix IOMMU overflow checking in s2io.c
Date: Wed, 25 Jun 2008 22:16:04 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7703C9C94D@nekter>
References: <20080618115836.GA18655@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Andi Kleen" <andi@firstfloor.org>, <jeff@garzik.org>,
	<netdev@vger.kernel.org>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterio
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:1111 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbYFZCQH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 22:16:07 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080618115836.GA18655@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi,

Thanks for this fix. We will recreate a new patch which includes the fix
mentioned in your comments and resubmit.

Ram
> -----Original Message-----
> From: Andi Kleen [mailto:andi@firstfloor.org]
> Sent: Wednesday, June 18, 2008 4:59 AM
> To: jeff@garzik.org; netdev@vger.kernel.org; ram.vepa@neterion.com;
> Rastapur Santosh; Sivakumar Subramani; Sreenivasa Honnur
> Subject: [PATCH] Fix IOMMU overflow checking in s2io.c
> 
> Fix IOMMU overflow checking in s2io.c
> 
> s2io has IOMMU overflow checking, but unfortunately it is wrong.
> 
> It didn't use the standard macros, which meant that it only worked
> on POWER and SPARC because only those define DMA_ERROR_CODE. Convert
it to
> use the standard macros instead.
> 
> I also commented two more bugs in the IOMMU handling. It assumes
> that 0 DMA addresses cannot happen, but that's not true in all IOMMU
> setups.
> The information if a buffer has been already mapped needs to be stored
> elsewhere.
> 
> Didn't fix those because it needs careful checking of the buffer
handling
> by the maintainers.
> 
> Cc: ram.vepa@neterion.com
> Cc: santosh.rastapur@neterion.com
> Cc: sivakumar.subramani@neterion.com
> Cc: sreenivasa.honnur@neterion.com
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> Index: linux/drivers/net/s2io.c
> ===================================================================
> --- linux.orig/drivers/net/s2io.c
> +++ linux/drivers/net/s2io.c
> @@ -2625,9 +2625,7 @@ static int fill_rx_buffers(struct ring_i
>  			rxdp1->Buffer0_ptr = pci_map_single
>  			    (ring->pdev, skb->data, size - NET_IP_ALIGN,
>  				PCI_DMA_FROMDEVICE);
> -			if( (rxdp1->Buffer0_ptr == 0) ||
> -				(rxdp1->Buffer0_ptr ==
> -				DMA_ERROR_CODE))
> +			if(pci_dma_mapping_error(rxdp1->Buffer0_ptr))
>  				goto pci_map_failed;
> 
>  			rxdp->Control_2 =
> @@ -2657,6 +2655,7 @@ static int fill_rx_buffers(struct ring_i
>  			skb->data = (void *) (unsigned long)tmp;
>  			skb_reset_tail_pointer(skb);
> 
> +			/* AK: check is wrong. 0 can be valid dma
address */
>  			if (!(rxdp3->Buffer0_ptr))
>  				rxdp3->Buffer0_ptr =
>  				   pci_map_single(ring->pdev, ba->ba_0,
> @@ -2665,8 +2664,7 @@ static int fill_rx_buffers(struct ring_i
>
pci_dma_sync_single_for_device(ring->pdev,
>  				(dma_addr_t) rxdp3->Buffer0_ptr,
>  				    BUF0_LEN, PCI_DMA_FROMDEVICE);
> -			if( (rxdp3->Buffer0_ptr == 0) ||
> -				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE))
> +			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr))
>  				goto pci_map_failed;
> 
>  			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
> @@ -2681,18 +2679,17 @@ static int fill_rx_buffers(struct ring_i
>  				(ring->pdev, skb->data, ring->mtu + 4,
>  						PCI_DMA_FROMDEVICE);
> 
> -				if( (rxdp3->Buffer2_ptr == 0) ||
> -					(rxdp3->Buffer2_ptr ==
DMA_ERROR_CODE))
> +				if
(pci_dma_mapping_error(rxdp3->Buffer2_ptr))
>  					goto pci_map_failed;
> 
> +				/* AK: check is wrong */
>  				if (!rxdp3->Buffer1_ptr)
>  					rxdp3->Buffer1_ptr =
>
pci_map_single(ring->pdev,
>  						ba->ba_1, BUF1_LEN,
>  						PCI_DMA_FROMDEVICE);
> 
> -				if( (rxdp3->Buffer1_ptr == 0) ||
> -					(rxdp3->Buffer1_ptr ==
DMA_ERROR_CODE)) {
> +				if
(pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
>  					pci_unmap_single
>  						(ring->pdev,
>  						(dma_addr_t)(unsigned
long)
> @@ -4264,16 +4261,14 @@ static int s2io_xmit(struct sk_buff *skb
>  		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
>  					fifo->ufo_in_band_v,
>  					sizeof(u64), PCI_DMA_TODEVICE);
> -		if((txdp->Buffer_Pointer == 0) ||
> -			(txdp->Buffer_Pointer == DMA_ERROR_CODE))
> +		if (pci_dma_mapping_error(txdp->Buffer_Pointer))
>  			goto pci_map_failed;
>  		txdp++;
>  	}
> 
>  	txdp->Buffer_Pointer = pci_map_single
>  	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
> -	if((txdp->Buffer_Pointer == 0) ||
> -		(txdp->Buffer_Pointer == DMA_ERROR_CODE))
> +	if (pci_dma_mapping_error(txdp->Buffer_Pointer))
>  		goto pci_map_failed;
> 
>  	txdp->Host_Control = (unsigned long) skb;
> @@ -6884,10 +6879,8 @@ static int set_rxd_buffer_pointer(struct
>  				pci_map_single( sp->pdev, (*skb)->data,
>  					size - NET_IP_ALIGN,
>  					PCI_DMA_FROMDEVICE);
> -			if( (rxdp1->Buffer0_ptr == 0) ||
> -				(rxdp1->Buffer0_ptr == DMA_ERROR_CODE))
{
> +			if (pci_dma_mapping_error(rxdp1->Buffer0_ptr))
>  				goto memalloc_failed;
> -			}
>  			rxdp->Host_Control = (unsigned long) (*skb);
>  		}
>  	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control
==
> 0)) {
> @@ -6913,15 +6906,12 @@ static int set_rxd_buffer_pointer(struct
>  				pci_map_single(sp->pdev, (*skb)->data,
>  					       dev->mtu + 4,
>  					       PCI_DMA_FROMDEVICE);
> -			if( (rxdp3->Buffer2_ptr == 0) ||
> -				(rxdp3->Buffer2_ptr == DMA_ERROR_CODE))
{
> +			if (pci_dma_mapping_error(rxdp3->Buffer2_ptr))
>  				goto memalloc_failed;
> -			}
>  			rxdp3->Buffer0_ptr = *temp0 =
>  				pci_map_single( sp->pdev, ba->ba_0,
BUF0_LEN,
>  						PCI_DMA_FROMDEVICE);
> -			if( (rxdp3->Buffer0_ptr == 0) ||
> -				(rxdp3->Buffer0_ptr == DMA_ERROR_CODE))
{
> +			if (pci_dma_mapping_error(rxdp3->Buffer0_ptr)) {
>  				pci_unmap_single (sp->pdev,
>  					(dma_addr_t)rxdp3->Buffer2_ptr,
>  					dev->mtu + 4,
PCI_DMA_FROMDEVICE);
> @@ -6933,8 +6923,7 @@ static int set_rxd_buffer_pointer(struct
>  			rxdp3->Buffer1_ptr = *temp1 =
>  				pci_map_single(sp->pdev, ba->ba_1,
BUF1_LEN,
>  						PCI_DMA_FROMDEVICE);
> -			if( (rxdp3->Buffer1_ptr == 0) ||
> -				(rxdp3->Buffer1_ptr == DMA_ERROR_CODE))
{
> +			if (pci_dma_mapping_error(rxdp3->Buffer1_ptr)) {
>  				pci_unmap_single (sp->pdev,
>  					(dma_addr_t)rxdp3->Buffer0_ptr,
>  					BUF0_LEN, PCI_DMA_FROMDEVICE);
> Index: linux/drivers/net/s2io.h
> ===================================================================
> --- linux.orig/drivers/net/s2io.h
> +++ linux/drivers/net/s2io.h
> @@ -75,10 +75,6 @@ static int debug_level = ERR_DBG;
>  /* DEBUG message print. */
>  #define DBG_PRINT(dbg_level, args...)  if(!(debug_level<dbg_level))
> printk(args)
> 
> -#ifndef DMA_ERROR_CODE
> -#define DMA_ERROR_CODE          (~(dma_addr_t)0x0)
> -#endif
> -
>  /* Protocol assist features of the NIC */
>  #define L3_CKSUM_OK 0xFFFF
>  #define L4_CKSUM_OK 0xFFFF
