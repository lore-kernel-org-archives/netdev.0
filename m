From: Alexandre Torgue <alexandre.torgue@st.com>
Subject: Re: [PATCH v3 1/6] net: stmmac: return error if no DMA configuration
 is found
Date: Thu, 8 Dec 2016 11:44:35 +0100
Message-ID: <d18098a5-a4a4-0c63-f64c-cdb7144dd67e@st.com>
References: <1481120409-18103-1-git-send-email-niklass@axis.com>
 <1481120409-18103-2-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Niklas Cassel <niklas.cassel@axis.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481120409-18103-2-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On 12/07/2016 03:20 PM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> All drivers except pci glue layer calls stmmac_probe_config_dt.
> stmmac_probe_config_dt does a kzalloc dma_cfg.
>
> pci glue layer does kzalloc dma_cfg explicitly, so all current
> drivers does a kzalloc dma_cfg.
>
> Return an error if no DMA configuration is found, that way
> we can assume that the DMA configuration always exists.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Acked-by: Alexandre Torgue <alexandre.torgue@stcom>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 982c95213da4..14366800e5e6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1578,16 +1578,12 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
>   */
>  static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  {
> -	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, aal = 0;
> -	int mixed_burst = 0;
>  	int atds = 0;
>  	int ret = 0;
>
> -	if (priv->plat->dma_cfg) {
> -		pbl = priv->plat->dma_cfg->pbl;
> -		fixed_burst = priv->plat->dma_cfg->fixed_burst;
> -		mixed_burst = priv->plat->dma_cfg->mixed_burst;
> -		aal = priv->plat->dma_cfg->aal;
> +	if (!priv->plat->dma_cfg) {
> +		dev_err(priv->device, "DMA configuration not found\n");
> +		return -EINVAL;
>  	}
>
>  	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
> @@ -1599,8 +1595,12 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  		return ret;
>  	}
>
> -	priv->hw->dma->init(priv->ioaddr, pbl, fixed_burst, mixed_burst,
> -			    aal, priv->dma_tx_phy, priv->dma_rx_phy, atds);
> +	priv->hw->dma->init(priv->ioaddr,
> +			    priv->plat->dma_cfg->pbl,
> +			    priv->plat->dma_cfg->fixed_burst,
> +			    priv->plat->dma_cfg->mixed_burst,
> +			    priv->plat->dma_cfg->aal,
> +			    priv->dma_tx_phy, priv->dma_rx_phy, atds);
>
>  	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
>  		priv->rx_tail_addr = priv->dma_rx_phy +
>
