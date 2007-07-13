From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH 2.6.22 1/4]S2IO: Adding checks to check the return value of pci mapping function
Date: Fri, 13 Jul 2007 00:58:23 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701E1ECA8@nekter>
References: <Pine.GSO.4.10.10706190549470.2608-100000@guinness> <4688EDA2.8000405@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:36707 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbXGME54 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 00:57:56 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4688EDA2.8000405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

We have the fixed the review comments as part of Patch2 and resubmitted
it again yesterday.

Thanks,
~Siva 

-----Original Message-----
From: Jeff Garzik [mailto:jeff@garzik.org] 
Sent: Monday, July 02, 2007 5:51 PM
To: Veena Parat
Cc: netdev@vger.kernel.org; Leonid Grossman; Ramkrishna Vepa; Rastapur
Santosh; Sivakumar Subramani; Sreenivasa Honnur; Alicia Pena; Sriram
Rapuru
Subject: Re: [PATCH 2.6.22 1/4]S2IO: Adding checks to check the return
value of pci mapping function

Veena Parat wrote:
> Adding checks to check the return value of pci mapping function
> 
> Signed-off-by: Veena Parat <veena.parat@neterion.com>
> ---
> diff -urpN org/drivers/net/s2io.c patch_1/drivers/net/s2io.c
> --- org/drivers/net/s2io.c	2007-05-17 20:35:39.000000000 +0530
> +++ patch_1/drivers/net/s2io.c	2007-05-17 20:35:55.000000000
+0530
> @@ -282,6 +282,7 @@ static char ethtool_driver_stats_keys[][
>  	("lro_flush_due_to_max_pkts"),
>  	("lro_avg_aggr_pkts"),
>  	("mem_alloc_fail_cnt"),
> +	{"pci_map_fail_cnt"},
>  	("watchdog_timer_cnt"),
>  	("mem_allocated"),
>  	("mem_freed"),
> @@ -2247,10 +2248,19 @@ static int fill_rxd_3buf(struct s2io_nic
>  			(nic->pdev, skb->data, l3l4hdr_size + 4,
>  			PCI_DMA_FROMDEVICE);
>  
> +	if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
> +		(((struct RxD3*)rxdp)->Buffer1_ptr == DMA_ERROR_CODE)) {
> +		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
> +		return -ENOMEM;
> +	}
> +
>  	/* skb_shinfo(skb)->frag_list will have L4 data payload */
>  	skb_shinfo(skb)->frag_list = dev_alloc_skb(dev->mtu +
ALIGN_SIZE);
>  	if (skb_shinfo(skb)->frag_list == NULL) {
>
nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
> +		pci_unmap_single
> +			(nic->pdev, (dma_addr_t)skb->data, l3l4hdr_size
+ 4,
> +			PCI_DMA_FROMDEVICE);
>  		DBG_PRINT(INFO_DBG, "%s: dev_alloc_skb failed\n ",
dev->name);
>  		return -ENOMEM ;
>  	}
> @@ -2267,6 +2277,11 @@ static int fill_rxd_3buf(struct s2io_nic
>  	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
>  				frag_list->data, dev->mtu,
>  				PCI_DMA_FROMDEVICE);
> +	if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
> +		(((struct RxD3*)rxdp)->Buffer2_ptr == DMA_ERROR_CODE)) {
> +		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
> +		return -ENOMEM;
> +	}
>  	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
>  	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
>  
> @@ -2399,6 +2414,16 @@ static int fill_rx_buffers(struct s2io_n
>  			((struct RxD1*)rxdp)->Buffer0_ptr =
pci_map_single
>  			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
>  				PCI_DMA_FROMDEVICE);
> +			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
> +				(((struct RxD1*)rxdp)->Buffer0_ptr == 
> +				DMA_ERROR_CODE)) {
> +				nic->mac_control.stats_info->sw_stat.
> +					pci_map_fail_cnt++;
> +
nic->mac_control.stats_info->sw_stat.mem_freed
> +					+= skb->truesize;
> +				dev_kfree_skb_irq(skb);
> +				return -ENOMEM;
> +			}
>  			rxdp->Control_2 = 
>  				SET_BUFFER0_SIZE_1(size - NET_IP_ALIGN);
>  

please provide a prep patch that eliminates all these inline casts. 
Create temporary variables or whatever you need to do to convert the
messy and unreadable "(((struct RxD1*)rxdp)->Buffer0_ptr" into
"desc->Buffer0_ptr".

otherwise looks OK

