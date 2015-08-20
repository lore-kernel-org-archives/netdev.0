From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix uncleaned dma flags
Date: Thu, 20 Aug 2015 15:04:57 -0700
Message-ID: <55D64F09.1090802@gmail.com>
References: <1440040627-59949-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jaedon Shin <jaedon.shin@gmail.com>,
	David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35550 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbHTWHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 18:07:20 -0400
Received: by pdob1 with SMTP id b1so18699332pdo.2
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 15:07:19 -0700 (PDT)
In-Reply-To: <1440040627-59949-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/15 20:17, Jaedon Shin wrote:
> Clean the dma flags of multiq ring buffer int the interface stop
> process. This patch fixes that the genet is not running while the
> interface is re-enabled.
> 
> $ ifup eth0 - running after booting
> $ ifdown eth0
> $ ifup eth0 - not running and occur tx_timeout
> 
> The bcmgenet_dma_disable() in bcmgenet_open() do clean ring16 dma flag
> only. If the genet has multiq, the dma register is not cleaned. and
> bcmgenet_init_dma() is not done correctly. in case
> GENET_V2(tx_queues=4), tdma_ctrl has 0x1e after running
> bcmgenet_dma_disable().

It sounds like this should be moved to bcmgenet_dma_disable() where we
are already modifying DMA_CTRL and returning a dma_ctrl value back to
the caller, or at the very last bcmgenet_dma_teardown().

Thanks!

> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 64c1e9db6b0b..81bde6fa70b7 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -2174,6 +2174,8 @@ static int bcmgenet_dma_teardown(struct bcmgenet_priv *priv)
>  
>  static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
>  {
> +	u32 dma_ctrl;
> +	u32 reg;
>  	int i;
>  
>  	bcmgenet_fini_rx_napi(priv);
> @@ -2182,6 +2184,20 @@ static void bcmgenet_fini_dma(struct bcmgenet_priv *priv)
>  	/* disable DMA */
>  	bcmgenet_dma_teardown(priv);
>  
> +	dma_ctrl = 0;
> +	for (i = 0; i < priv->hw_params->rx_queues; i++)
> +		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
> +	reg = bcmgenet_rdma_readl(priv, DMA_CTRL);
> +	reg &= ~dma_ctrl;
> +	bcmgenet_rdma_writel(priv, reg, DMA_CTRL);
> +
> +	dma_ctrl = 0;
> +	for (i = 0; i < priv->hw_params->tx_queues; i++)
> +		dma_ctrl |= (1 << (i + DMA_RING_BUF_EN_SHIFT));
> +	reg = bcmgenet_tdma_readl(priv, DMA_CTRL);
> +	reg &= ~dma_ctrl;
> +	bcmgenet_tdma_writel(priv, reg, DMA_CTRL);
> +
>  	for (i = 0; i < priv->num_tx_bds; i++) {
>  		if (priv->tx_cbs[i].skb != NULL) {
>  			dev_kfree_skb(priv->tx_cbs[i].skb);
> 


-- 
Florian
