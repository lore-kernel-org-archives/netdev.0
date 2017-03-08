From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH v2 net-next 2/8] net: stmicro: configure mtl rx and tx
 algorithms
Date: Wed, 8 Mar 2017 17:45:19 +0100
Message-ID: <0f6466c7-74a1-ae62-1fa4-16bc73f8c6c8@axis.com>
References: <cover.1488975090.git.jpinto@synopsys.com>
 <02bee5939abb88be5db27752e2469bc756cf36b9.1488975090.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:33804 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751633AbdCHQpY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Mar 2017 11:45:24 -0500
In-Reply-To: <02bee5939abb88be5db27752e2469bc756cf36b9.1488975090.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2017 01:22 PM, Joao Pinto wrote:
> This patch adds the RX and TX scheduling algorithms programming.
> It introduces the multiple queues configuration function
> (stmmac_mtl_configuration) in stmmac_main.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> changes v1->v2:
> - Just to keep up with patch-set version
>
>  drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 10 +++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 48 +++++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 31 +++++++++++++--
>  4 files changed, 90 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 04d9245..5a0a781 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -455,6 +455,10 @@ struct stmmac_ops {
>  	int (*rx_ipc)(struct mac_device_info *hw);
>  	/* Enable RX Queues */
>  	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
> +	/* Program RX Algorithms */
> +	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
> +	/* Program TX Algorithms */
> +	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_alg);
>  	/* Dump MAC registers */
>  	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
>  	/* Handle extra events on specific interrupts hw dependent */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> index db45134..748ab6f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> @@ -161,6 +161,16 @@ enum power_event {
>  #define GMAC_HI_REG_AE			BIT(31)
>  
>  /*  MTL registers */
> +#define MTL_OPERATION_MODE		0x00000c00
> +#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
> +#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
> +#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
> +#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
> +#define MTL_OPERATION_SCHALG_SP		(0x3 << 5)
> +#define MTL_OPERATION_RAA		BIT(2)
> +#define MTL_OPERATION_RAA_SP		(0x0 << 2)
> +#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
> +
>  #define MTL_INT_STATUS			0x00000c20
>  #define MTL_INT_Q0			BIT(0)
>  
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 1e79e65..7503b8e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -70,6 +70,52 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
>  	writel(value, ioaddr + GMAC_RXQ_CTRL0);
>  }
>  
> +static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
> +					  u32 rx_alg)
> +{
> +	void __iomem *ioaddr = hw->pcsr;
> +	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
> +
> +	value &= ~MTL_OPERATION_RAA;
> +	switch (rx_alg) {
> +	case MTL_RX_ALGORITHM_SP:
> +	value |= MTL_OPERATION_RAA_SP;
> +	break;
> +	case MTL_RX_ALGORITHM_WSP:
> +	value |= MTL_OPERATION_RAA_WSP;
> +	break;
> +	default:
> +	break;
> +	}
> +
> +	writel(value, ioaddr + MTL_OPERATION_MODE);
> +}
> +
> +static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
> +					  u32 tx_alg)
> +{
> +	void __iomem *ioaddr = hw->pcsr;
> +	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
> +
> +	value &= ~MTL_OPERATION_SCHALG_MASK;
> +	switch (tx_alg) {
> +	case MTL_TX_ALGORITHM_WRR:
> +	value |= MTL_OPERATION_SCHALG_WRR;
> +	break;
> +	case MTL_TX_ALGORITHM_WFQ:
> +	value |= MTL_OPERATION_SCHALG_WFQ;
> +	break;
> +	case MTL_TX_ALGORITHM_DWRR:
> +	value |= MTL_OPERATION_SCHALG_DWRR;
> +	break;
> +	case MTL_TX_ALGORITHM_SP:
> +	value |= MTL_OPERATION_SCHALG_SP;
> +	break;
> +	default:
> +	break;
> +	}
> +}
> +
>  static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
>  {
>  	void __iomem *ioaddr = hw->pcsr;
> @@ -457,6 +503,8 @@ static const struct stmmac_ops dwmac4_ops = {
>  	.core_init = dwmac4_core_init,
>  	.rx_ipc = dwmac4_rx_ipc_enable,
>  	.rx_queue_enable = dwmac4_rx_queue_enable,
> +	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
> +	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
>  	.dump_regs = dwmac4_dump_regs,
>  	.host_irq_status = dwmac4_irq_status,
>  	.flow_ctrl = dwmac4_flow_ctrl,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 4498a38..af57f8d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1645,6 +1645,31 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
>  }
>  
>  /**
> + *  stmmac_mtl_configuration - Configure MTL
> + *  @priv: driver private structure
> + *  Description: It is used for configurring MTL
> + */
> +static void stmmac_mtl_configuration(struct stmmac_priv *priv)
> +{
> +	u32 rx_queues_count = priv->plat->rx_queues_to_use;
> +	u32 tx_queues_count = priv->plat->tx_queues_to_use;
> +
> +	/* Configure MTL RX algorithms */
> +	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
> +		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
> +						priv->plat->rx_sched_algorithm);
> +
> +	/* Configure MTL TX algorithms */
> +	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorithms)
> +		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
> +						priv->plat->tx_sched_algorithm);
> +
> +	/* Enable MAC RX Queues */
> +	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> +		stmmac_mac_enable_rx_queues(priv);

Hello Joao

Since you are now enabling RX queues here,
perhaps we should move the enabling of TX queue(s) here as well?


> +}
> +
> +/**
>   * stmmac_hw_setup - setup mac in a usable state.
>   *  @dev : pointer to the device structure.
>   *  Description:
> @@ -1688,9 +1713,9 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	/* Initialize the MAC Core */
>  	priv->hw->mac->core_init(priv->hw, dev->mtu);
>  
> -	/* Initialize MAC RX Queues */
> -	if (priv->hw->mac->rx_queue_enable)
> -		stmmac_mac_enable_rx_queues(priv);
> +	/* Initialize MTL*/
> +	if (priv->synopsys_id >= DWMAC_CORE_4_00)
> +		stmmac_mtl_configuration(priv);
>  
>  	ret = priv->hw->mac->rx_ipc(priv->hw);
>  	if (!ret) {
