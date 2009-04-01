From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: More fun with dma debugging: 8139cp frees DMA memory with
	different size
Date: Thu, 2 Apr 2009 00:59:41 +0200
Message-ID: <20090401225941.GA20111@electric-eye.fr.zoreil.com>
References: <20090401151851.GA19496@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54321 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755563AbZDAWz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 18:55:58 -0400
Content-Disposition: inline
In-Reply-To: <20090401151851.GA19496@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> :
[...]
> diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> index a09e3a7..a4b4491 100644
> --- a/drivers/net/8139cp.c
> +++ b/drivers/net/8139cp.c
> @@ -1065,7 +1065,8 @@ static int cp_refill_rx(struct cp_private *cp)
>  		skb_reserve(skb, NET_IP_ALIGN);
>  
>  		mapping = dma_map_single(&cp->pdev->dev, skb->data,
> -					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +					 cp->rx_buf_sz + NET_IP_ALIGN,
> +					 PCI_DMA_FROMDEVICE);
>  		cp->rx_skb[i] = skb;
>  
>  		cp->rx_ring[i].opts2 = 0;

We have just substracted NET_IP_ALIGN bytes from skb->data. It will
silence the warning (though the user can expect to see a new one
appear in cp_clean_rings) but it is imho not completely sane. 

What about something along:

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index a09e3a7..3067921 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -559,8 +559,8 @@ rx_status_loop:
 
 		skb_reserve(new_skb, NET_IP_ALIGN);
 
-		dma_unmap_single(&cp->pdev->dev, mapping,
-				 buflen, PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&cp->pdev->dev, mapping, cp->rx_buf_sz,
+				 PCI_DMA_FROMDEVICE);
 
 		/* Handle checksum offloading for incoming packets. */
 		if (cp_rx_csum_ok(status))
@@ -570,8 +570,8 @@ rx_status_loop:
 
 		skb_put(skb, len);
 
-		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
-					 PCI_DMA_FROMDEVICE);
+		mapping = dma_map_single(&cp->pdev->dev, new_skb->data,
+					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		cp->rx_skb[rx_tail] = new_skb;
 
 		cp_rx_skb(cp, skb, desc);

-- 
Ueimor
