From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH] net: sh_eth: fix the rxdesc pointer when rx descriptor
 empty happens
Date: Wed, 20 Jun 2012 15:10:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1206201507260.20254@axis700.grange>
References: <4FC491EB.4040002@renesas.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4FC491EB.4040002@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Shimoda-san

On Tue, 29 May 2012, Shimoda, Yoshihiro wrote:

> When Receive Descriptor Empty happens, rxdesc pointer of the driver
> and actual next descriptor of the controller may be mismatch.
> This patch fixes it.

Unfortunately, this patch breaks networking on ecovec (sh7724). Booting 
with dhcp and NFS-root progresses very slowly with lots of "nfs: server 
not responding / Ok" messages and never completes. Reverting it in current 
Linus' tree fixes the problem.

Thanks
Guennadi

> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index be3c221..667169b 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1101,8 +1101,12 @@ static int sh_eth_rx(struct net_device *ndev)
> 
>  	/* Restart Rx engine if stopped. */
>  	/* If we don't need to check status, don't. -KDU */
> -	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R))
> +	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
> +		/* fix the values for the next receiving */
> +		mdp->cur_rx = mdp->dirty_rx = (sh_eth_read(ndev, RDFAR) -
> +					       sh_eth_read(ndev, RDLAR)) >> 4;
>  		sh_eth_write(ndev, EDRRR_R, EDRRR);
> +	}
> 
>  	return 0;
>  }
> @@ -1199,8 +1203,6 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
>  		/* Receive Descriptor Empty int */
>  		ndev->stats.rx_over_errors++;
> 
> -		if (sh_eth_read(ndev, EDRRR) ^ EDRRR_R)
> -			sh_eth_write(ndev, EDRRR_R, EDRRR);
>  		if (netif_msg_rx_err(mdp))
>  			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
>  	}
> -- 
> 1.7.1
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
