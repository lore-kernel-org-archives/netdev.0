From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [PATCH 2/2] benet: fix the misusage of zero dma address
Date: Mon, 5 Apr 2010 12:40:59 +0530
Message-ID: <20100405071059.GA32671@serverengines.com>
References: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
 <1270176803-8561-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:35742 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750818Ab0DEHL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 03:11:28 -0400
Content-Disposition: inline
In-Reply-To: <1270176803-8561-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fujita, thanks for the patch; pls see below:

On 02/04/10 11:53 +0900, FUJITA Tomonori wrote:
> benet driver wrongly assumes that zero is an invalid dma address
> (calls dma_unmap_page for only non zero dma addresses). Zero is a
> valid dma address on some architectures. The dma length can be used
> here.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  drivers/net/benet/be_main.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
> index 8d5e27b..8828c7d 100644
> --- a/drivers/net/benet/be_main.c
> +++ b/drivers/net/benet/be_main.c
> @@ -394,13 +394,15 @@ static void unmap_tx_frag(struct pci_dev *pdev, struct be_eth_wrb *wrb,
>  	be_dws_le_to_cpu(wrb, sizeof(*wrb));
>  
>  	dma = (u64)wrb->frag_pa_hi << 32 | (u64)wrb->frag_pa_lo;
> -	if (dma != 0) {
> +	if (wrb->frag_len) {
>  		if (unmap_single)
>  			pci_unmap_single(pdev, dma, wrb->frag_len,
>  				PCI_DMA_TODEVICE);
>  		else
>  			pci_unmap_page(pdev, dma, wrb->frag_len,
>  				PCI_DMA_TODEVICE);
> +
> +		wrb->frag_len = 0;
Why does wrb->frag_len need to be reset here?
In the TX path, it is set to the proper value for data wrbs and zero
for dummy and hdr wrbs.
>  	}
>  }
>  
> @@ -466,9 +468,9 @@ dma_err:
>  	txq->head = map_head;
>  	while (copied) {
>  		wrb = queue_head_node(txq);
> +		copied -= wrb->frag_len;
>  		unmap_tx_frag(pdev, wrb, map_single);
>  		map_single = false;
> -		copied -= wrb->frag_len;
>  		queue_head_inc(txq);
>  	}
>  	return 0;
> -- 
> 1.7.0
> 
