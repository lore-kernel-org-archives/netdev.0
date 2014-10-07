From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next] net: bcmgenet: fix Tx ring priority programming
Date: Tue, 07 Oct 2014 10:07:42 -0700
Message-ID: <54341DDE.4040909@gmail.com>
References: <20141007163001.85125100761@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:41298 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753439AbaJGRHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:07:49 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so7408602pab.24
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 10:07:49 -0700 (PDT)
In-Reply-To: <20141007163001.85125100761@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2014 09:30 AM, Petri Gynther wrote:
> GENET MAC has three Tx ring priority registers:
> - GENET_x_TDMA_PRIORITY0 for queues 0-5
> - GENET_x_TDMA_PRIORITY1 for queues 6-11
> - GENET_x_TDMA_PRIORITY2 for queues 12-16
> 
> Fix bcmgenet_init_multiq() to program them correctly.

Looks good to me, the register layout is correct for GENETv1 to v4, thanks!

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 42 +++++++++++++++-----------
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h |  2 ++
>  2 files changed, 27 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index e0a6238..fff2634 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -191,8 +191,9 @@ enum dma_reg {
>  	DMA_STATUS,
>  	DMA_SCB_BURST_SIZE,
>  	DMA_ARB_CTRL,
> -	DMA_PRIORITY,
> -	DMA_RING_PRIORITY,
> +	DMA_PRIORITY_0,
> +	DMA_PRIORITY_1,
> +	DMA_PRIORITY_2,
>  };
>  
>  static const u8 bcmgenet_dma_regs_v3plus[] = {
> @@ -201,8 +202,9 @@ static const u8 bcmgenet_dma_regs_v3plus[] = {
>  	[DMA_STATUS]		= 0x08,
>  	[DMA_SCB_BURST_SIZE]	= 0x0C,
>  	[DMA_ARB_CTRL]		= 0x2C,
> -	[DMA_PRIORITY]		= 0x30,
> -	[DMA_RING_PRIORITY]	= 0x38,
> +	[DMA_PRIORITY_0]	= 0x30,
> +	[DMA_PRIORITY_1]	= 0x34,
> +	[DMA_PRIORITY_2]	= 0x38,
>  };
>  
>  static const u8 bcmgenet_dma_regs_v2[] = {
> @@ -211,8 +213,9 @@ static const u8 bcmgenet_dma_regs_v2[] = {
>  	[DMA_STATUS]		= 0x08,
>  	[DMA_SCB_BURST_SIZE]	= 0x0C,
>  	[DMA_ARB_CTRL]		= 0x30,
> -	[DMA_PRIORITY]		= 0x34,
> -	[DMA_RING_PRIORITY]	= 0x3C,
> +	[DMA_PRIORITY_0]	= 0x34,
> +	[DMA_PRIORITY_1]	= 0x38,
> +	[DMA_PRIORITY_2]	= 0x3C,
>  };
>  
>  static const u8 bcmgenet_dma_regs_v1[] = {
> @@ -220,8 +223,9 @@ static const u8 bcmgenet_dma_regs_v1[] = {
>  	[DMA_STATUS]		= 0x04,
>  	[DMA_SCB_BURST_SIZE]	= 0x0C,
>  	[DMA_ARB_CTRL]		= 0x30,
> -	[DMA_PRIORITY]		= 0x34,
> -	[DMA_RING_PRIORITY]	= 0x3C,
> +	[DMA_PRIORITY_0]	= 0x34,
> +	[DMA_PRIORITY_1]	= 0x38,
> +	[DMA_PRIORITY_2]	= 0x3C,
>  };
>  
>  /* Set at runtime once bcmgenet version is known */
> @@ -1696,7 +1700,8 @@ static void bcmgenet_init_multiq(struct net_device *dev)
>  {
>  	struct bcmgenet_priv *priv = netdev_priv(dev);
>  	unsigned int i, dma_enable;
> -	u32 reg, dma_ctrl, ring_cfg = 0, dma_priority = 0;
> +	u32 reg, dma_ctrl, ring_cfg = 0;
> +	u32 dma_priority[3] = {0, 0, 0};
>  
>  	if (!netif_is_multiqueue(dev)) {
>  		netdev_warn(dev, "called with non multi queue aware HW\n");
> @@ -1721,22 +1726,25 @@ static void bcmgenet_init_multiq(struct net_device *dev)
>  
>  		/* Configure ring as descriptor ring and setup priority */
>  		ring_cfg |= 1 << i;
> -		dma_priority |= ((GENET_Q0_PRIORITY + i) <<
> -				(GENET_MAX_MQ_CNT + 1) * i);
>  		dma_ctrl |= 1 << (i + DMA_RING_BUF_EN_SHIFT);
> +
> +		dma_priority[DMA_PRIO_REG_INDEX(i)] |=
> +			((GENET_Q0_PRIORITY + i) << DMA_PRIO_REG_SHIFT(i));
>  	}
>  
> +	/* Set ring 16 priority and program the hardware registers */
> +	dma_priority[DMA_PRIO_REG_INDEX(DESC_INDEX)] |=
> +		((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) <<
> +		 DMA_PRIO_REG_SHIFT(DESC_INDEX));
> +	bcmgenet_tdma_writel(priv, dma_priority[0], DMA_PRIORITY_0);
> +	bcmgenet_tdma_writel(priv, dma_priority[1], DMA_PRIORITY_1);
> +	bcmgenet_tdma_writel(priv, dma_priority[2], DMA_PRIORITY_2);
> +
>  	/* Enable rings */
>  	reg = bcmgenet_tdma_readl(priv, DMA_RING_CFG);
>  	reg |= ring_cfg;
>  	bcmgenet_tdma_writel(priv, reg, DMA_RING_CFG);
>  
> -	/* Use configured rings priority and set ring #16 priority */
> -	reg = bcmgenet_tdma_readl(priv, DMA_RING_PRIORITY);
> -	reg |= ((GENET_Q0_PRIORITY + priv->hw_params->tx_queues) << 20);
> -	reg |= dma_priority;
> -	bcmgenet_tdma_writel(priv, reg, DMA_PRIORITY);
> -
>  	/* Configure ring as descriptor ring and re-enable DMA if enabled */
>  	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
>  	reg |= dma_ctrl;
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index 321b1db..dbf524e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -401,6 +401,8 @@ struct bcmgenet_mib_counters {
>  #define DMA_ARBITER_MODE_MASK		0x03
>  #define DMA_RING_BUF_PRIORITY_MASK	0x1F
>  #define DMA_RING_BUF_PRIORITY_SHIFT	5
> +#define DMA_PRIO_REG_INDEX(q)		((q) / 6)
> +#define DMA_PRIO_REG_SHIFT(q)		(((q) % 6) * DMA_RING_BUF_PRIORITY_SHIFT)
>  #define DMA_RATE_ADJ_MASK		0xFF
>  
>  /* Tx/Rx Dma Descriptor common bits*/
> 
