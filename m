From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmveth: fix bad UDP checksums
Date: Thu, 21 Aug 2008 14:41:07 -0500
Message-ID: <48ADC4D3.4000201@linux.vnet.ibm.com>
References: <20080820190826.24896.41095.62294@soporte.mitelefono.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53763 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761AbYHUTmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 15:42:13 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7LJiaXF025138
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:44:36 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7LJftlX213336
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:41:55 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7LJfsoc011255
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:41:54 -0400
In-Reply-To: <20080820190826.24896.41095.62294@soporte.mitelefono.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked by: Brian King <brking@linux.vnet.ibm.com>

Santiago Leon wrote:
> This patch fixes a ibmveth bug where bad UDP checksums are being transmitted 
> when checksum offloading is enabled.
> The hypervisor does checksum offloading only on TCP packets, so ibmveth calls 
> skb_checksum_help() for any other protocol.  The bug happens because 
> the packet is being modified after the DMA map, so we would need a memory 
> barrier before making the hypervisor call.  Reordering the code so that the 
> DMA map happens after skb_checksum_help() has the additional advantage of 
> fixing a DMA map leak if skb_checksum_help() where to fail.
> 
> Please consider applying.
> 
> Signed-off-by: Santiago Leon <santil@us.ibm.com>
> ---
> 
>  ibmveth.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> --- a/drivers/net/ibmveth.c	2008-08-19 07:31:29.000000000 -0400
> +++ b/drivers/net/ibmveth.c	2008-08-19 07:46:24.000000000 -0400
> @@ -904,8 +904,6 @@ static int ibmveth_start_xmit(struct sk_
>  	unsigned long data_dma_addr;
> 
>  	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
> -	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
> -				       skb->len, DMA_TO_DEVICE);
> 
>  	if (skb->ip_summed == CHECKSUM_PARTIAL &&
>  	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
> @@ -924,6 +922,8 @@ static int ibmveth_start_xmit(struct sk_
>  		buf[1] = 0;
>  	}
> 
> +	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
> +				       skb->len, DMA_TO_DEVICE);
>  	if (dma_mapping_error(&adapter->vdev->dev, data_dma_addr)) {
>  		if (!firmware_has_feature(FW_FEATURE_CMO))
>  			ibmveth_error_printk("tx: unable to map xmit buffer\n");
> @@ -932,6 +932,7 @@ static int ibmveth_start_xmit(struct sk_
>  		desc.fields.address = adapter->bounce_buffer_dma;
>  		tx_map_failed++;
>  		used_bounce = 1;
> +		wmb();
>  	} else
>  		desc.fields.address = data_dma_addr;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


