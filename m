From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH v2 3/6] net: stmmac: stmmac_platform: fix parsing of DT
 binding
Date: Mon, 5 Dec 2016 17:12:07 +0100
Message-ID: <cb287d85-cbd3-7a63-ddeb-d9dbcb09c18a@axis.com>
References: <1480929039-20257-1-git-send-email-niklass@axis.com>
 <1480929039-20257-4-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480929039-20257-4-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/2016 10:10 AM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
>
> commit 64c3b252e9fc ("net: stmmac: fixed the pbl setting with DT")
> changed the parsing of the DT binding.
>
> Before 64c3b252e9fc, snps,fixed-burst and snps,mixed-burst were parsed
> regardless if the property snps,pbl existed or not.
> After the commit, fixed burst and mixed burst are only parsed if
> snps,pbl exists. Now when snps,aal has been added, it too is only
> parsed if snps,pbl exists.
>
> Since the DT binding does not specify that fixed burst, mixed burst
> or aal depend on snps,pbl being specified, undo changes introduced
> by 64c3b252e9fc.
>
> The issue commit 64c3b252e9fc ("net: stmmac: fixed the pbl setting with
> DT") tries to address is solved in another way:
> The databook specifies that all values other than
> 1, 2, 4, 8, 16, or 32 results in undefined behavior,
> so snps,pbl = <0> is invalid.
>
> If pbl is 0 after parsing, set pbl to DEFAULT_DMA_PBL.
> This handles the case where the property is omitted, and also handles
> the case where the property is specified without any data.
>
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  3 +++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 27 +++++++++++-----------
>  2 files changed, 16 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index b1e42ddf0370..2298c4d109fb 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1586,6 +1586,9 @@ static int stmmac_init_dma_engine(struct stmmac_priv *priv)
>  		return -EINVAL;
>  	}
>  
> +	if (!priv->plat->dma_cfg->pbl)
> +		priv->plat->dma_cfg->pbl = DEFAULT_DMA_PBL;
> +

Perhaps it is cleaner to have this "fallback to a default value" in
stmmac_probe_config_dt, right after
of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl),
since the only other place where the pbl is set, is from PCI glue.

The PCI glue should set a correct pbl value, and shouldn't need to
rely on a default value.
The code in stmmac_init_dma_engine could then, instead of
"fallback to a default value", return an error if pbl == 0.

>  	if (priv->extend_desc && (priv->mode == STMMAC_RING_MODE))
>  		atds = 1;
>  
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 98bf86d64d96..59e1740479fc 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -301,21 +301,20 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
>  		plat->force_sf_dma_mode = 1;
>  	}
>  
> -	if (of_find_property(np, "snps,pbl", NULL)) {
> -		dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
> -				       GFP_KERNEL);
> -		if (!dma_cfg) {
> -			stmmac_remove_config_dt(pdev, plat);
> -			return ERR_PTR(-ENOMEM);
> -		}
> -		plat->dma_cfg = dma_cfg;
> -		of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
> -		dma_cfg->aal = of_property_read_bool(np, "snps,aal");
> -		dma_cfg->fixed_burst =
> -			of_property_read_bool(np, "snps,fixed-burst");
> -		dma_cfg->mixed_burst =
> -			of_property_read_bool(np, "snps,mixed-burst");
> +	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg),
> +			       GFP_KERNEL);
> +	if (!dma_cfg) {
> +		stmmac_remove_config_dt(pdev, plat);
> +		return ERR_PTR(-ENOMEM);
>  	}
> +	plat->dma_cfg = dma_cfg;
> +
> +	of_property_read_u32(np, "snps,pbl", &dma_cfg->pbl);
> +
> +	dma_cfg->aal = of_property_read_bool(np, "snps,aal");
> +	dma_cfg->fixed_burst = of_property_read_bool(np, "snps,fixed-burst");
> +	dma_cfg->mixed_burst = of_property_read_bool(np, "snps,mixed-burst");
> +
>  	plat->force_thresh_dma_mode = of_property_read_bool(np, "snps,force_thresh_dma_mode");
>  	if (plat->force_thresh_dma_mode) {
>  		plat->force_sf_dma_mode = 0;
