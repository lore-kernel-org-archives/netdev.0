From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH net-next 4/6] qlge: Fixed double pci free upon
 tx_ring->q allocation failure.
Date: Fri, 29 Jun 2012 15:48:05 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA877435B23E0@AVEXMB1.qlogic.org>
References: <1340994290-28832-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <1340994290-28832-5-git-send-email-jitendra.kalsaria@qlogic.com>
 <20120629213755.GC19152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:4993
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752778Ab2F2WsR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 18:48:17 -0400
In-Reply-To: <20120629213755.GC19152@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois,

See comments inline.

Jiten

-----Original Message-----
From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
Sent: Friday, June 29, 2012 2:38 PM
To: Jitendra Kalsaria
Cc: David Miller; netdev; Ron@linux-zupk.site; Dept-NX Linux NIC Driver
Subject: Re: [PATCH net-next 4/6] qlge: Fixed double pci free upon tx_ring->q allocation failure.

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

[JK] Will, definitely take care of this in future patch.

-- 
Ueimor
