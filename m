From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/8] net: stmicro: configure mtl rx and tx
 algorithms
Date: Wed, 08 Mar 2017 11:16:22 -0800 (PST)
Message-ID: <20170308.111622.1405002206787661951.davem@davemloft.net>
References: <cover.1488969672.git.jpinto@synopsys.com>
        <cover.1488969672.git.jpinto@synopsys.com>
        <bf9eb10ea5f36cd66a61ea781725b9d190d101d6.1488969672.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
To: Joao.Pinto@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdCHTYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:24:34 -0500
In-Reply-To: <bf9eb10ea5f36cd66a61ea781725b9d190d101d6.1488969672.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joao Pinto <Joao.Pinto@synopsys.com>
Date: Wed,  8 Mar 2017 11:03:09 +0000

> This patch adds the RX and TX scheduling algorithms programming.
> It introduces the multiple queues configuration function
> (stmmac_mtl_configuration) in stmmac_main.
> 
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
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

This is not properly indented at all.  The code inside each switch statement
needs one more TAB.

Sam for dwmac4_prog_mtl_tx_algorithms().
