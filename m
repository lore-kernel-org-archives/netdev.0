From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 net-next 4/9] net: stmicro: mtl rx queue enabled as dcb
 or avb
Date: Thu, 9 Mar 2017 15:01:39 +0300
Message-ID: <713f3c43-d57f-fb37-1fb6-24f5c13d0958@cogentembedded.com>
References: <cover.1489055407.git.jpinto@synopsys.com>
 <3cf0a7279e962b65151c9ae8e0ebb22bdc5b47a0.1489055407.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        niklas.cassel@axis.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33485 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753983AbdCIMDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 07:03:18 -0500
Received: by mail-lf0-f42.google.com with SMTP id a6so27244778lfa.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 04:01:44 -0800 (PST)
In-Reply-To: <3cf0a7279e962b65151c9ae8e0ebb22bdc5b47a0.1489055407.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 03/09/2017 02:03 PM, Joao Pinto wrote:

> This patch introduces the enabling of RX queues as DCB or as AVB based on
> configuration.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 6f59751..04d0fa3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -59,13 +59,17 @@ static void dwmac4_core_init(struct mac_device_info *hw, int mtu)
>  	writel(value, ioaddr + GMAC_INT_EN);
>  }
>
> -static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
> +static void dwmac4_rx_queue_enable(struct mac_device_info *hw,
> +				   u8 mode, u32 queue)
>  {
>  	void __iomem *ioaddr = hw->pcsr;
>  	u32 value = readl(ioaddr + GMAC_RXQ_CTRL0);
>
>  	value &= GMAC_RX_QUEUE_CLEAR(queue);
> -	value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
> +	if (mode == MTL_RX_AVB)
> +		value |= GMAC_RX_AV_QUEUE_ENABLE(queue);
> +	else if (mode == MTL_RX_DCB)
> +		value |= GMAC_RX_DCB_QUEUE_ENABLE(queue);

    *switch*, maybe?

[...]
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 1ad6957..17faa1f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1256,19 +1256,14 @@ static void free_dma_desc_resources(struct stmmac_priv *priv)
>   */
>  static void stmmac_mac_enable_rx_queues(struct stmmac_priv *priv)
>  {
> -	int rx_count = priv->dma_cap.number_rx_queues;
> +	u32 rx_queues_count = priv->plat->rx_queues_to_use;
>  	int queue = 0;

    It's now set to 0 right below, in the *for* statement. So this initializer 
seems useless.

> +	u8 mode = 0;
>
> -	/* If GMAC does not have multiple queues, then this is not necessary*/
> -	if (rx_count == 1)
> -		return;
> -
> -	/**
> -	 *  If the core is synthesized with multiple rx queues / multiple
> -	 *  dma channels, then rx queues will be disabled by default.
> -	 *  For now only rx queue 0 is enabled.
> -	 */
> -	priv->hw->mac->rx_queue_enable(priv->hw, queue);
> +	for (queue = 0; queue < rx_queues_count; queue++) {
> +		mode = priv->plat->rx_queues_cfg[queue].mode_to_use;
> +		priv->hw->mac->rx_queue_enable(priv->hw, mode, queue);
> +	}
>  }
>
>  /**

MBR, Sergei
