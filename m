From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 4/6] qlge: Fixed double pci free upon tx_ring->q allocation failure.
Date: Fri, 29 Jun 2012 23:37:55 +0200
Message-ID: <20120629213755.GC19152@electric-eye.fr.zoreil.com>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com> <1340994290-28832-5-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Ron@linux-zupk.site,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40312 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab2F2Vsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 17:48:55 -0400
Content-Disposition: inline
In-Reply-To: <1340994290-28832-5-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jitendra Kalsaria <jitendra.kalsaria@qlogic.com> :
[...]
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index cdbc860..aa514c5 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -2701,11 +2701,9 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
>  	    pci_alloc_consistent(qdev->pdev, tx_ring->wq_size,
>  				 &tx_ring->wq_base_dma);
>  
> -	if ((tx_ring->wq_base == NULL) ||
> -	    tx_ring->wq_base_dma & WQ_ADDR_ALIGN) {
> -		netif_err(qdev, ifup, qdev->ndev, "tx_ring alloc failed.\n");
> -		return -ENOMEM;
> -	}
> +	if ((tx_ring->wq_base == NULL) || tx_ring->wq_base_dma & WQ_ADDR_ALIGN)
> +		goto err;
> +
>  	tx_ring->q =
>  	    kmalloc(tx_ring->wq_len * sizeof(struct tx_ring_desc), GFP_KERNEL);
>  	if (tx_ring->q == NULL)
> @@ -2713,8 +2711,12 @@ static int ql_alloc_tx_resources(struct ql_adapter *qdev,
>  
>  	return 0;
>  err:
> -	pci_free_consistent(qdev->pdev, tx_ring->wq_size,
> +	if (tx_ring->wq_base) {
> +		pci_free_consistent(qdev->pdev, tx_ring->wq_size,
>  			    tx_ring->wq_base, tx_ring->wq_base_dma);
> +		tx_ring->wq_base = NULL;
> +	}

You do not need a test: use a second label + goto.

Nit: You can replace 'if ((tx_ring->wq_base == NULL)' with
'if (!tx_ring->wq_base' and add a local variable for qdev->pdev.

You may consider replacing pci_alloc_consistent with dma_alloc_coherent
in a future patch.

-- 
Ueimor
