From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH][net-next v2] gianfar: Fix alloc_skb_resources on -ENOMEM
 cleanup path
Date: Fri, 9 Nov 2012 09:05:07 -0500
Message-ID: <509D0D93.5030204@windriver.com>
References: <1352448701-14041-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51999 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab2KIOFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 09:05:11 -0500
In-Reply-To: <1352448701-14041-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-11-09 03:11 AM, Claudiu Manoil wrote:
> Should gfar_init_bds() return with -ENOMEM inside gfar_alloc_skb_resources(),
> free_skb_resources() will be called twice in a row on the "cleanup" path,
> leading to duplicate kfree() calls for rx_|tx_queue->rx_|tx_skbuff resulting
> in segmentation fault.
> This patch prevents the segmentation fault to happen in the future
> (rx_|tx_sbkbuff set to NULL), and corrects the error path handling
> for gfar_init_bds().
> 
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>

> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
> v1: do free_skb_resources() on the cleanup path of gfar_init_bds()'s parent
> v2: (minor change) no "goto" construct inside gfar_restore()
> 
>  drivers/net/ethernet/freescale/gianfar.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 1d03dcd..81a0f33 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -210,7 +210,7 @@ static int gfar_init_bds(struct net_device *ndev)
>  				skb = gfar_new_skb(ndev);
>  				if (!skb) {
>  					netdev_err(ndev, "Can't allocate RX buffers\n");
> -					goto err_rxalloc_fail;
> +					return -ENOMEM;
>  				}
>  				rx_queue->rx_skbuff[j] = skb;
>  
> @@ -223,10 +223,6 @@ static int gfar_init_bds(struct net_device *ndev)
>  	}
>  
>  	return 0;
> -
> -err_rxalloc_fail:
> -	free_skb_resources(priv);
> -	return -ENOMEM;
>  }
>  
>  static int gfar_alloc_skb_resources(struct net_device *ndev)
> @@ -1356,7 +1352,11 @@ static int gfar_restore(struct device *dev)
>  	if (!netif_running(ndev))
>  		return 0;
>  
> -	gfar_init_bds(ndev);
> +	if (gfar_init_bds(ndev)) {
> +		free_skb_resources(priv);
> +		return -ENOMEM;
> +	}
> +
>  	init_registers(ndev);
>  	gfar_set_mac_address(ndev);
>  	gfar_init_mac(ndev);
> @@ -1709,6 +1709,7 @@ static void free_skb_tx_queue(struct gfar_priv_tx_q *tx_queue)
>  		tx_queue->tx_skbuff[i] = NULL;
>  	}
>  	kfree(tx_queue->tx_skbuff);
> +	tx_queue->tx_skbuff = NULL;
>  }
>  
>  static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
> @@ -1732,6 +1733,7 @@ static void free_skb_rx_queue(struct gfar_priv_rx_q *rx_queue)
>  		rxbdp++;
>  	}
>  	kfree(rx_queue->rx_skbuff);
> +	rx_queue->rx_skbuff = NULL;
>  }
>  
>  /* If there are any tx skbs or rx skbs still around, free them.
> 
