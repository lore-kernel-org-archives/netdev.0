From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH v3] sh_eth: ensure pm_runtime cannot suspend the device during init
Date: Thu, 20 Mar 2014 19:01:31 +0100
Message-ID: <3894339.LtO9XLDneL@avalon>
References: <1395336877-12402-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:35191 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933009AbaCTR7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:59:43 -0400
In-Reply-To: <1395336877-12402-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

Thank you for the patch.

On Thursday 20 March 2014 18:34:37 Ben Dooks wrote:
> The pm_rumtime work queue is causing the device to be suspended during
> initialisation, thus the initialisation may not be able to access registers
> properly. As the code is called from a work queue, it is possible that this
> is not seen from certain configurations/builds due to the asynchronos
> nature of the code.
> 
> Another issue has also been found where the network device registration
> calls back into the driver thus causing further pm_runtime calls that
> also caused issues with the MDIO bus code.
> 
> Use pm_runtime_get_sync() and pm_runtime_put() to ensure that the
> pm system does not suspend it during the probe() call and remove the
> now unnecessary pm_runtime_resume() call.
> 
> This fixes the external abort that can cause /sbin/init or other such
> init processed to die.
> 
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> ---
> Cc: sergei.shtylyov@cogentembedded.com
> Cc: laurent.pinchart+renesas@ideasonboard.com
> cc: netdev@vger.kernel.org
> 
> Note, Laurent this should probably be applied before your
> current series as it may require changes to the exit sequence.

Would you like me to include the patch in that series when I'll send a pull 
request ?

> Fixes from v1:
> 	- use pm_runtime_put() over pm_runtime_put_sync() as
> 	  we do not need to guaranteed the device has powered
>           off after probe.
> 
> Fixed from v2:
> 	- call pm_runtime_put() in error path
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
> b/drivers/net/ethernet/renesas/sh_eth.c index 4f76b5e..610da51 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2841,6 +2841,9 @@ static int sh_eth_drv_probe(struct platform_device
> *pdev) goto out;
>  	}
> 
> +	pm_runtime_enable(&pdev->dev);
> +	pm_runtime_get_sync(&pdev->dev);
> +
>  	/* The sh Ether-specific entries in the device structure. */
>  	ndev->base_addr = res->start;
>  	devno = pdev->id;
> @@ -2868,8 +2871,6 @@ static int sh_eth_drv_probe(struct platform_device
> *pdev)
> 
>  	spin_lock_init(&mdp->lock);
>  	mdp->pdev = pdev;
> -	pm_runtime_enable(&pdev->dev);
> -	pm_runtime_resume(&pdev->dev);
> 
>  	if (pdev->dev.of_node)
>  		pd = sh_eth_parse_dt(&pdev->dev);
> @@ -2961,6 +2962,7 @@ static int sh_eth_drv_probe(struct platform_device
> *pdev) pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
>  		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
> 
> +	pm_runtime_put(&pdev->dev);
>  	platform_set_drvdata(pdev, ndev);
> 
>  	return ret;
> @@ -2976,6 +2978,7 @@ out_release:
>  	if (ndev)
>  		free_netdev(ndev);
> 
> +	pm_runtime_put(&pdev->dev);

Do we also need a pm_runtime_disable() here ?

>  out:
>  	return ret;
>  }

-- 
Regards,

Laurent Pinchart
