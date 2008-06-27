From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 06/10] smc91x: prepare SMC_USE_PXA_DMA to be specified in
 platform data
Date: Thu, 26 Jun 2008 20:01:43 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806262001230.2979@xanadu.home>
References: <1214300867-15495-7-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:32474 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbYF0ABn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 20:01:43 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K3300C2QHEVQX40@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 26 Jun 2008 20:01:43 -0400 (EDT)
In-reply-to: <1214300867-15495-7-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Jun 2008, Eric Miao wrote:

> From: Eric Miao <eric.miao@marvell.com>
> 
> Now that the original SMC_USE_PXA_DMA specific code will always being
> built if CONFIG_ARCH_PXA is defined, so to make this part of the code
> to be PXA public, and still prevent it from being built if support of
> PXA is not selected.
> 
> A SMC91X_USE_DMA flag is added to the platform data to allow platform
> to choose its usage of DMA. Note this flag itself is so named to be
> generic enough (assuming other platforms can also use DMA).
> 
> It keeps backward compatibility to set the SMC91X_USE_DMA flag if
> SMC_USE_PXA_DMA is still defined.
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

Acked-by: Nicolas Pitre <nico@cam.org>

> ---
>  drivers/net/smc91x.c   |   13 ++++++++-----
>  drivers/net/smc91x.h   |    6 +++---
>  include/linux/smc91x.h |    2 ++
>  3 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index 3a319f2..a7b583d 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -1923,8 +1923,11 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
>        	if (retval)
>        		goto err_out;
>  
> -#ifdef SMC_USE_PXA_DMA
> -	{
> +#ifdef CONFIG_ARCH_PXA
> +#  ifdef SMC_USE_PXA_DMA
> +	lp->cfg.flags |= SMC91X_USE_DMA;
> +#  endif
> +	if (lp->cfg.flags & SMC91X_USE_DMA) {
>  		int dma = pxa_request_dma(dev->name, DMA_PRIO_LOW,
>  					  smc_pxa_dma_irq, NULL);
>  		if (dma >= 0)
> @@ -1964,7 +1967,7 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
>  	}
>  
>  err_out:
> -#ifdef SMC_USE_PXA_DMA
> +#ifdef CONFIG_ARCH_PXA
>  	if (retval && dev->dma != (unsigned char)-1)
>  		pxa_free_dma(dev->dma);
>  #endif
> @@ -2178,7 +2181,7 @@ static int smc_drv_probe(struct platform_device *pdev)
>  		goto out_release_attrib;
>  	}
>  
> -#ifdef SMC_USE_PXA_DMA
> +#ifdef CONFIG_ARCH_PXA
>  	{
>  		struct smc_local *lp = netdev_priv(ndev);
>  		lp->device = &pdev->dev;
> @@ -2221,7 +2224,7 @@ static int smc_drv_remove(struct platform_device *pdev)
>  
>  	free_irq(ndev->irq, ndev);
>  
> -#ifdef SMC_USE_PXA_DMA
> +#ifdef CONFIG_ARCH_PXA
>  	if (ndev->dma != (unsigned char)-1)
>  		pxa_free_dma(ndev->dma);
>  #endif
> diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> index 6a90400..208dfc8 100644
> --- a/drivers/net/smc91x.h
> +++ b/drivers/net/smc91x.h
> @@ -479,7 +479,7 @@ struct smc_local {
>  
>  	spinlock_t lock;
>  
> -#ifdef SMC_USE_PXA_DMA
> +#ifdef CONFIG_ARCH_PXA
>  	/* DMA needs the physical address of the chip */
>  	u_long physaddr;
>  	struct device *device;
> @@ -494,7 +494,7 @@ struct smc_local {
>  #define SMC_16BIT(p)	((p)->cfg.flags & SMC91X_USE_16BIT)
>  #define SMC_32BIT(p)	((p)->cfg.flags & SMC91X_USE_32BIT)
>  
> -#ifdef SMC_USE_PXA_DMA
> +#ifdef CONFIG_ARCH_PXA
>  /*
>   * Let's use the DMA engine on the XScale PXA2xx for RX packets. This is
>   * always happening in irq context so no need to worry about races.  TX is
> @@ -588,7 +588,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  {
>  	DCSR(dma) = 0;
>  }
> -#endif  /* SMC_USE_PXA_DMA */
> +#endif  /* CONFIG_ARCH_PXA */
>  
>  
>  /*
> diff --git a/include/linux/smc91x.h b/include/linux/smc91x.h
> index 0dea945..3827b92 100644
> --- a/include/linux/smc91x.h
> +++ b/include/linux/smc91x.h
> @@ -14,6 +14,8 @@
>  #define SMC91X_IO_SHIFT_3	(3 << 4)
>  #define SMC91X_IO_SHIFT(x)	(((x) >> 4) & 0x3)
>  
> +#define SMC91X_USE_DMA		(1 << 6)
> +
>  struct smc91x_platdata {
>  	unsigned long flags;
>  };
> -- 
> 1.5.4.3
> 


Nicolas
