From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 4/7] qlge: Fixed double pci free upon tx_ring->q
 allocation failure.
Date: Tue, 3 Jul 2012 02:22:01 +0100
Message-ID: <1341278521.2590.30.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1341272514-5156-5-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ron.mercer@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53521 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752520Ab2GCBWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:22:04 -0400
In-Reply-To: <1341272514-5156-5-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 19:41 -0400, Jitendra Kalsaria wrote:
> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index cdbc860..9ecd15f 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -2701,20 +2701,20 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
>  	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
>  				 &tx_ring->wq_base_dma);
>  
> -	if ((tx_ring->wq_base == NULL) ||
> -	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
> -		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
> -		return -ENOMEM;
> -	}
> +	if (!tx_ring->wq_base || tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
> +		goto err;
> +

So in case pci_alloc_consistent() fails, you now try to free anyway.
Not sure whether that's safe; do you feel lucky?

>  	tx_ring->q =
>  	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
> -	if (tx_ring->q == NULL)
> +	if (!tx_ring->q)
>  		goto err;

Unrelated change.

>  	return 0;
>  err:
>  	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
> -			    tx_ring->wq_base, tx_ring->wq_base_dma);
> +			tx_ring->wq_base, tx_ring->wq_base_dma);

This was nicely indented before...

> +	tx_ring->wq_base = NULL;
> +	netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
>  	return -ENOMEM;
>  }
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
