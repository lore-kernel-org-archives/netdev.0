From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH][net-next] gianfar: Fix alloc_skb_resources on -ENOMEM
 cleanup path
Date: Thu, 8 Nov 2012 09:21:03 -0500
Message-ID: <509BBFCF.20109@windriver.com>
References: <1352382008-7039-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59632 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab2KHOVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 09:21:10 -0500
In-Reply-To: <1352382008-7039-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-11-08 08:40 AM, Claudiu Manoil wrote:
> Should gfar_init_bds() return with -ENOMEM inside gfar_alloc_skb_resources(),
> free_skb_resources() will be called twice in a row on the "cleanup" path,
> leading to duplicate kfree() calls for rx_|tx_queue->rx_|tx_skbuff resulting
> in segmentation fault.
> This patch prevents the segmentation fault to happen in the future
> (rx_|tx_sbkbuff set to NULL), and corrects the error path handling
> for gfar_init_bds().

Since gfar_init_bds is more like a slave routine to gfar_alloc_skb_resources,
I think the dup free_skb_resources should remain in the parent, and be removed
from gfar_init_bds.  Otherwise the gfar_alloc_skb_resources will appear
confusing -- one will think it it allocates some resources, hits a failure
and then returns without bothering to do any cleanup of the parts it
did manage to allocate. (Then gfar_restore will have to call the free
itself _if_ gfar_init_bds fails too.)

Paul.
--

> 
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 1d03dcd..c5c82ad 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -311,7 +311,7 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
>  	}
>  
>  	if (gfar_init_bds(ndev))
> -		goto cleanup;
> +		return -ENOMEM;
>  
>  	return 0;
>  
> @@ -1356,7 +1356,9 @@ static int gfar_restore(struct device *dev)
>  	if (!netif_running(ndev))
>  		return 0;
>  
> -	gfar_init_bds(ndev);
> +	if (gfar_init_bds(ndev))
> +		return -ENOMEM;
> +
>  	init_registers(ndev);
>  	gfar_set_mac_address(ndev);
>  	gfar_init_mac(ndev);
> @@ -1709,6 +1711,7 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
>  		tx_queue->tx_skbuff[i] = NULL;
>  	}
>  	kfree(tx_queue->tx_skbuff);
> +	tx_queue->tx_skbuff = NULL;
>  }
>  
>  static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
> @@ -1732,6 +1735,7 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
>  		rxbdp++;
>  	}
>  	kfree(rx_queue->rx_skbuff);
> +	rx_queue->rx_skbuff = NULL;
>  }
>  
>  /* If there are any tx skbs or rx skbs still around, free them.
> 
