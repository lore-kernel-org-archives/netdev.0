From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH v3 2/6] net: stmmac: simplify the common DMA init API
Date: Thu, 8 Dec 2016 09:50:50 +0100
Message-ID: <0c1f5530-c872-824e-db41-22d73e93b723@st.com>
References: <1481120409-18103-1-git-send-email-niklass@axis.com>
 <1481120409-18103-3-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481120409-18103-3-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On 12/07/2016 03:20 PM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> Use struct stmmac_dma_cfg *dma_cfg as an argument rather
> than using all the struct members as individual arguments.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Thanks for this patch. You can add my Acked-by.

Regards
Alex


> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h        |  4 ++--
>  drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c | 13 +++++++------
>  drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c  |  7 ++++---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c    | 14 ++++++++------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c   |  6 +-----
>  5 files changed, 22 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index 3ced2e1703c1..b13a144f72ad 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -412,8 +412,8 @@ extern const struct stmmac_desc_ops ndesc_ops;
>  struct stmmac_dma_ops {
>  	/* DMA core initialization */
>  	int (*reset)(void __iomem *ioaddr);
> -	void (*init)(void __iomem *ioaddr, int pbl, int fb, int mb,
> -		     int aal, u32 dma_tx, u32 dma_rx, int atds);
> +	void (*init)(void __iomem *ioaddr, struct stmmac_dma_cfg *dma_cfg,
> +		     u32 dma_tx, u32 dma_rx, int atds);
>  	/* Configure the AXI Bus Mode Register */
>  	void (*axi)(void __iomem *ioaddr, struct stmmac_axi *axi);
>  	/* Dump DMA registers */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> index f35385266fbf..318ae9f10104 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> @@ -84,8 +84,9 @@ static void dwmac1000_dma_axi(void __iomem *ioaddr, struct stmmac_axi *axi)
>  	writel(value, ioaddr + DMA_AXI_BUS_MODE);
>  }
>
> -static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
> -			       int aal, u32 dma_tx, u32 dma_rx, int atds)
> +static void dwmac1000_dma_init(void __iomem *ioaddr,
> +			       struct stmmac_dma_cfg *dma_cfg,
> +			       u32 dma_tx, u32 dma_rx, int atds)
>  {
>  	u32 value = readl(ioaddr + DMA_BUS_MODE);
>
> @@ -101,20 +102,20 @@ static void dwmac1000_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
>  	 */
>  	value |= DMA_BUS_MODE_MAXPBL;
>  	value &= ~DMA_BUS_MODE_PBL_MASK;
> -	value |= (pbl << DMA_BUS_MODE_PBL_SHIFT);
> +	value |= (dma_cfg->pbl << DMA_BUS_MODE_PBL_SHIFT);
>
>  	/* Set the Fixed burst mode */
> -	if (fb)
> +	if (dma_cfg->fixed_burst)
>  		value |= DMA_BUS_MODE_FB;
>
>  	/* Mixed Burst has no effect when fb is set */
> -	if (mb)
> +	if (dma_cfg->mixed_burst)
>  		value |= DMA_BUS_MODE_MB;
>
>  	if (atds)
>  		value |= DMA_BUS_MODE_ATDS;
>
> -	if (aal)
> +	if (dma_cfg->aal)
>  		value |= DMA_BUS_MODE_AAL;
>
>  	writel(value, ioaddr + DMA_BUS_MODE);
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> index 61f54c99a7de..e5664da382f3 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
> @@ -32,11 +32,12 @@
>  #include "dwmac100.h"
>  #include "dwmac_dma.h"
>
> -static void dwmac100_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
> -			      int aal, u32 dma_tx, u32 dma_rx, int atds)
> +static void dwmac100_dma_init(void __iomem *ioaddr,
> +			      struct stmmac_dma_cfg *dma_cfg,
> +			      u32 dma_tx, u32 dma_rx, int atds)
>  {
>  	/* Enable Application Access by writing to DMA CSR0 */
> -	writel(DMA_BUS_MODE_DEFAULT | (pbl << DMA_BUS_MODE_PBL_SHIFT),
> +	writel(DMA_BUS_MODE_DEFAULT | (dma_cfg->pbl << DMA_BUS_MODE_PBL_SHIFT),
>  	       ioaddr + DMA_BUS_MODE);
>
>  	/* Mask interrupts by writing to CSR7 */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> index e81b6e565c29..7d82a3464097 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> @@ -99,27 +99,29 @@ static void dwmac4_dma_init_channel(void __iomem *ioaddr, int pbl,
>  	writel(dma_rx_phy, ioaddr + DMA_CHAN_RX_BASE_ADDR(channel));
>  }
>
> -static void dwmac4_dma_init(void __iomem *ioaddr, int pbl, int fb, int mb,
> -			    int aal, u32 dma_tx, u32 dma_rx, int atds)
> +static void dwmac4_dma_init(void __iomem *ioaddr,
> +			    struct stmmac_dma_cfg *dma_cfg,
> +			    u32 dma_tx, u32 dma_rx, int atds)
>  {
>  	u32 value = readl(ioaddr + DMA_SYS_BUS_MODE);
>  	int i;
>
>  	/* Set the Fixed burst mode */
> -	if (fb)
> +	if (dma_cfg->fixed_burst)
>  		value |= DMA_SYS_BUS_FB;
>
>  	/* Mixed Burst has no effect when fb is set */
> -	if (mb)
> +	if (dma_cfg->mixed_burst)
>  		value |= DMA_SYS_BUS_MB;
>
> -	if (aal)
> +	if (dma_cfg->aal)
>  		value |= DMA_SYS_BUS_AAL;
>
>  	writel(value, ioaddr + DMA_SYS_BUS_MODE);
>
>  	for (i = 0; i < DMA_CHANNEL_NB_MAX; i++)
> -		dwmac4_dma_init_channel(ioaddr, pbl, dma_tx, dma_rx, i);
> +		dwmac4_dma_init_channel(ioaddr, dma_cfg->pbl,
> +					dma_tx, dma_rx, i);
>  }
>
>  static void _dwmac4_dump_dma_regs(void __iomem *ioaddr, u32 channel)
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 14366800e5e6..b1e42ddf0370 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1595,11 +1595,7 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  		return ret;
>  	}
>
> -	priv->hw->dma->init(priv->ioaddr,
> -			    priv->plat->dma_cfg->pbl,
> -			    priv->plat->dma_cfg->fixed_burst,
> -			    priv->plat->dma_cfg->mixed_burst,
> -			    priv->plat->dma_cfg->aal,
> +	priv->hw->dma->init(priv->ioaddr, priv->plat->dma_cfg,
>  			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
>
>  	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
>
