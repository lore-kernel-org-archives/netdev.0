From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/3] chelsio: more rx speedup
Date: Tue, 9 Jan 2007 09:42:03 +0100
Message-ID: <200701090942.04197.netdev@axxeo.de>
References: <20061215190716.956791000@osdl.org> <20070108112524.730e89f0@dxpl.pdx.osdl.net> <20070108112612.5f947357@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:59972 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbXAIImR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 03:42:17 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070108112612.5f947357@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger schrieb:
> --- netdev-2.6.orig/drivers/net/chelsio/sge.c
> +++ netdev-2.6/drivers/net/chelsio/sge.c
[...]
> @@ -1043,45 +1046,42 @@ static void recycle_fl_buf(struct freelQ
>   *	be copied but there is no memory for the copy.
>   */
>  static inline struct sk_buff *get_packet(struct pci_dev *pdev,
> -					 struct freelQ *fl, unsigned int len,
> -					 int dma_pad, int skb_pad,
> -					 unsigned int copy_thres,
> -					 unsigned int drop_thres)
> +					 struct freelQ *fl, unsigned int len)
>  {
>  	struct sk_buff *skb;
> -	struct freelQ_ce *ce = &fl->centries[fl->cidx];
> +	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
>  
> -	if (len < copy_thres) {
> -		skb = alloc_skb(len + skb_pad, GFP_ATOMIC);
> -		if (likely(skb != NULL)) {
> -			skb_reserve(skb, skb_pad);
> -			skb_put(skb, len);
> -			pci_dma_sync_single_for_cpu(pdev,
> -					    pci_unmap_addr(ce, dma_addr),
> -					    pci_unmap_len(ce, dma_len),
> -					    PCI_DMA_FROMDEVICE);
> -			memcpy(skb->data, ce->skb->data + dma_pad, len);
> -			pci_dma_sync_single_for_device(pdev,
> +	if (len < copybreak) {
> +		skb = alloc_skb(len + 2, GFP_ATOMIC);
> +		if (!skb)
> +			goto use_orig_buf;
> +
> +		skb_reserve(skb, 2);	/* align IP header */

Please use NET_IP_ALIGN here:

+		skb = alloc_skb(len + NET_IP_ALIGN, GFP_ATOMIC);
+		if (!skb)
+			goto use_orig_buf;
+
+		skb_reserve(skb, NET_IP_ALIGN);

> +		skb_put(skb, len);
> +		pci_dma_sync_single_for_cpu(pdev,
>  					    pci_unmap_addr(ce, dma_addr),
>  					    pci_unmap_len(ce, dma_len),
>  					    PCI_DMA_FROMDEVICE);
> -		} else if (!drop_thres)
> -			goto use_orig_buf;
> -
> +		memcpy(skb->data, ce->skb->data, len);
> +		pci_dma_sync_single_for_device(pdev,
> +					       pci_unmap_addr(ce, dma_addr),
> +					       pci_unmap_len(ce, dma_len),
> +					       PCI_DMA_FROMDEVICE);
>  		recycle_fl_buf(fl, fl->cidx);
>  		return skb;
>  	}
>  
> -	if (fl->credits < drop_thres) {
> +use_orig_buf:
> +	if (fl->credits < 2) {

Why 2? What does this magic number mean?


Regards

Ingo Oeser
