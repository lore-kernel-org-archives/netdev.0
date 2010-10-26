From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next-2.6] tg3: use dma_alloc_coherent() instead
 of pci_alloc_consistent()
Date: Tue, 26 Oct 2010 10:04:34 -0700
Message-ID: <20101026170434.GA6246@mcarlson.broadcom.com>
References: <1288085882-11988-1-git-send-email-amit.salecha@qlogic.com>
 <1288085882-11988-5-git-send-email-amit.salecha@qlogic.com>
 <1288086894.3169.53.camel@edumazet-laptop>
 <99737F4847ED0A48AECC9F4A1974A4B80F871A817A@MNEXMB2.qlogic.org>
 <1288089033.3169.73.camel@edumazet-laptop>
 <1288094593.3169.95.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Amit Salecha" <amit.salecha@qlogic.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ameen Rahman" <ameen.rahman@qlogic.com>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4801 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760114Ab0JZREr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 13:04:47 -0400
In-Reply-To: <1288094593.3169.95.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 05:03:13AM -0700, Eric Dumazet wrote:
> Le mardi 26 octobre 2010 ?? 12:30 +0200, Eric Dumazet a ??crit :
> 
> > By the way, you should use dma_alloc_coherent() instead of
> > pci_alloc_consistent() so that you can use GFP_KERNEL allocations
> > instead of GFP_ATOMIC, it might help in low memory conditions (if you
> > dont hold a spinlock at this point)
> > 
> 
> tg3 being often used as a reference network driver, I believe we should
> change its allocations before too many people copy paste suboptimal
> pci_alloc_consistent() stuff...
> 
> Matt, could you please queue this patch and submit it to David when
> net-next-2.6 reopens ?

Sure.  Thanks for the patch.

> Thanks
> 
> [PATCH] tg3: use dma_alloc_coherent() instead of pci_alloc_consistent()
> 
> Using dma_alloc_coherent() permits to use GFP_KERNEL allocations instead
> of GFP_ATOMIC ones. Its better when a machine is out of memory, because
> this allows driver to sleep to get its memory and succeed its init,
> especially when allocating high order pages.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Matt Carlson <mcarlson@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/tg3.c |   73 ++++++++++++++++++++++++--------------------
>  1 file changed, 41 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 852e917..7dfa579 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6339,13 +6339,13 @@ static void tg3_rx_prodring_fini(struct tg3 *tp,
>  	kfree(tpr->rx_jmb_buffers);
>  	tpr->rx_jmb_buffers = NULL;
>  	if (tpr->rx_std) {
> -		pci_free_consistent(tp->pdev, TG3_RX_STD_RING_BYTES(tp),
> -				    tpr->rx_std, tpr->rx_std_mapping);
> +		dma_free_coherent(&tp->pdev->dev, TG3_RX_STD_RING_BYTES(tp),
> +				  tpr->rx_std, tpr->rx_std_mapping);
>  		tpr->rx_std = NULL;
>  	}
>  	if (tpr->rx_jmb) {
> -		pci_free_consistent(tp->pdev, TG3_RX_JMB_RING_BYTES(tp),
> -				    tpr->rx_jmb, tpr->rx_jmb_mapping);
> +		dma_free_coherent(&tp->pdev->dev, TG3_RX_JMB_RING_BYTES(tp),
> +				  tpr->rx_jmb, tpr->rx_jmb_mapping);
>  		tpr->rx_jmb = NULL;
>  	}
>  }
> @@ -6358,8 +6358,10 @@ static int tg3_rx_prodring_init(struct tg3 *tp,
>  	if (!tpr->rx_std_buffers)
>  		return -ENOMEM;
>  
> -	tpr->rx_std = pci_alloc_consistent(tp->pdev, TG3_RX_STD_RING_BYTES(tp),
> -					   &tpr->rx_std_mapping);
> +	tpr->rx_std = dma_alloc_coherent(&tp->pdev->dev,
> +					 TG3_RX_STD_RING_BYTES(tp),
> +					 &tpr->rx_std_mapping,
> +					 GFP_KERNEL);
>  	if (!tpr->rx_std)
>  		goto err_out;
>  
> @@ -6370,9 +6372,10 @@ static int tg3_rx_prodring_init(struct tg3 *tp,
>  		if (!tpr->rx_jmb_buffers)
>  			goto err_out;
>  
> -		tpr->rx_jmb = pci_alloc_consistent(tp->pdev,
> -						   TG3_RX_JMB_RING_BYTES(tp),
> -						   &tpr->rx_jmb_mapping);
> +		tpr->rx_jmb = dma_alloc_coherent(&tp->pdev->dev,
> +						 TG3_RX_JMB_RING_BYTES(tp),
> +						 &tpr->rx_jmb_mapping,
> +						 GFP_KERNEL);
>  		if (!tpr->rx_jmb)
>  			goto err_out;
>  	}
> @@ -6491,7 +6494,7 @@ static void tg3_free_consistent(struct tg3 *tp)
>  		struct tg3_napi *tnapi = &tp->napi[i];
>  
>  		if (tnapi->tx_ring) {
> -			pci_free_consistent(tp->pdev, TG3_TX_RING_BYTES,
> +			dma_free_coherent(&tp->pdev->dev, TG3_TX_RING_BYTES,
>  				tnapi->tx_ring, tnapi->tx_desc_mapping);
>  			tnapi->tx_ring = NULL;
>  		}
> @@ -6500,25 +6503,26 @@ static void tg3_free_consistent(struct tg3 *tp)
>  		tnapi->tx_buffers = NULL;
>  
>  		if (tnapi->rx_rcb) {
> -			pci_free_consistent(tp->pdev, TG3_RX_RCB_RING_BYTES(tp),
> -					    tnapi->rx_rcb,
> -					    tnapi->rx_rcb_mapping);
> +			dma_free_coherent(&tp->pdev->dev,
> +					  TG3_RX_RCB_RING_BYTES(tp),
> +					  tnapi->rx_rcb,
> +					  tnapi->rx_rcb_mapping);
>  			tnapi->rx_rcb = NULL;
>  		}
>  
>  		tg3_rx_prodring_fini(tp, &tnapi->prodring);
>  
>  		if (tnapi->hw_status) {
> -			pci_free_consistent(tp->pdev, TG3_HW_STATUS_SIZE,
> -					    tnapi->hw_status,
> -					    tnapi->status_mapping);
> +			dma_free_coherent(&tp->pdev->dev, TG3_HW_STATUS_SIZE,
> +					  tnapi->hw_status,
> +					  tnapi->status_mapping);
>  			tnapi->hw_status = NULL;
>  		}
>  	}
>  
>  	if (tp->hw_stats) {
> -		pci_free_consistent(tp->pdev, sizeof(struct tg3_hw_stats),
> -				    tp->hw_stats, tp->stats_mapping);
> +		dma_free_coherent(&tp->pdev->dev, sizeof(struct tg3_hw_stats),
> +				  tp->hw_stats, tp->stats_mapping);
>  		tp->hw_stats = NULL;
>  	}
>  }
> @@ -6531,9 +6535,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
>  {
>  	int i;
>  
> -	tp->hw_stats = pci_alloc_consistent(tp->pdev,
> -					    sizeof(struct tg3_hw_stats),
> -					    &tp->stats_mapping);
> +	tp->hw_stats = dma_alloc_coherent(&tp->pdev->dev,
> +					  sizeof(struct tg3_hw_stats),
> +					  &tp->stats_mapping,
> +					  GFP_KERNEL);
>  	if (!tp->hw_stats)
>  		goto err_out;
>  
> @@ -6543,9 +6548,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
>  		struct tg3_napi *tnapi = &tp->napi[i];
>  		struct tg3_hw_status *sblk;
>  
> -		tnapi->hw_status = pci_alloc_consistent(tp->pdev,
> -							TG3_HW_STATUS_SIZE,
> -							&tnapi->status_mapping);
> +		tnapi->hw_status = dma_alloc_coherent(&tp->pdev->dev,
> +						      TG3_HW_STATUS_SIZE,
> +						      &tnapi->status_mapping,
> +						      GFP_KERNEL);
>  		if (!tnapi->hw_status)
>  			goto err_out;
>  
> @@ -6566,9 +6572,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
>  			if (!tnapi->tx_buffers)
>  				goto err_out;
>  
> -			tnapi->tx_ring = pci_alloc_consistent(tp->pdev,
> -							      TG3_TX_RING_BYTES,
> -						       &tnapi->tx_desc_mapping);
> +			tnapi->tx_ring = dma_alloc_coherent(&tp->pdev->dev,
> +							    TG3_TX_RING_BYTES,
> +							    &tnapi->tx_desc_mapping,
> +							    GFP_KERNEL);
>  			if (!tnapi->tx_ring)
>  				goto err_out;
>  		}
> @@ -6601,9 +6608,10 @@ static int tg3_alloc_consistent(struct tg3 *tp)
>  		if (!i && (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS))
>  			continue;
>  
> -		tnapi->rx_rcb = pci_alloc_consistent(tp->pdev,
> -						     TG3_RX_RCB_RING_BYTES(tp),
> -						     &tnapi->rx_rcb_mapping);
> +		tnapi->rx_rcb = dma_alloc_coherent(&tp->pdev->dev,
> +						   TG3_RX_RCB_RING_BYTES(tp),
> +						   &tnapi->rx_rcb_mapping,
> +						   GFP_KERNEL);
>  		if (!tnapi->rx_rcb)
>  			goto err_out;
>  
> @@ -14159,7 +14167,8 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
>  	u32 *buf, saved_dma_rwctrl;
>  	int ret = 0;
>  
> -	buf = pci_alloc_consistent(tp->pdev, TEST_BUFFER_SIZE, &buf_dma);
> +	buf = dma_alloc_coherent(&tp->pdev->dev, TEST_BUFFER_SIZE,
> +				 &buf_dma, GFP_KERNEL);
>  	if (!buf) {
>  		ret = -ENOMEM;
>  		goto out_nofree;
> @@ -14343,7 +14352,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
>  	}
>  
>  out:
> -	pci_free_consistent(tp->pdev, TEST_BUFFER_SIZE, buf, buf_dma);
> +	dma_free_coherent(&tp->pdev->dev, TEST_BUFFER_SIZE, buf, buf_dma);
>  out_nofree:
>  	return ret;
>  }
> 
> 
> 

