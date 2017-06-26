From: =?UTF-8?Q?Andr=c3=a9_Przywara?= <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Mon, 26 Jun 2017 01:18:23 +0100
Message-ID: <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db@arm.com>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com>
 <20170531071852.12422-6-clabbe.montjoie@gmail.com>
Reply-To: andre.przywara-5wv7dgnIgG8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 mark.rutland-5wv7dgnIgG8@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
 linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
 peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <linux-sunxi+bncBDNZNK75ZIKRB7FGYHFAKGQEXYGRVXQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170531071852.12422-6-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 31/05/17 08:18, Corentin Labbe wrote:
> The dwmac-sun8i is a heavy hacked version of stmmac hardware by
> allwinner.
> In fact the only common part is the descriptor management and the first
> register function.

Hi,

I know I am a bit late with this, but while adapting the U-Boot driver
to the new binding I was wondering about the internal PHY detection:

> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> new file mode 100644
> index 000000000000..1a6bfe6c958f
> --- /dev/null
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
> @@ -0,0 +1,990 @@

....

> +static int sun8i_dwmac_probe(struct platform_device *pdev)
> +{
> +	struct plat_stmmacenet_data *plat_dat;
> +	struct stmmac_resources stmmac_res;
> +	struct sunxi_priv_data *gmac;
> +	struct device *dev = &pdev->dev;
> +	int ret;
> +
> +	ret = stmmac_get_platform_resources(pdev, &stmmac_res);
> +	if (ret)
> +		return ret;
> +
> +	plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
> +	if (IS_ERR(plat_dat))
> +		return PTR_ERR(plat_dat);
> +
> +	gmac = devm_kzalloc(dev, sizeof(*gmac), GFP_KERNEL);
> +	if (!gmac)
> +		return -ENOMEM;
> +
> +	gmac->variant = of_device_get_match_data(&pdev->dev);
> +	if (!gmac->variant) {
> +		dev_err(&pdev->dev, "Missing dwmac-sun8i variant\n");
> +		return -EINVAL;
> +	}
> +
> +	gmac->tx_clk = devm_clk_get(dev, "stmmaceth");
> +	if (IS_ERR(gmac->tx_clk)) {
> +		dev_err(dev, "Could not get TX clock\n");
> +		return PTR_ERR(gmac->tx_clk);
> +	}
> +
> +	/* Optional regulator for PHY */
> +	gmac->regulator = devm_regulator_get_optional(dev, "phy");
> +	if (IS_ERR(gmac->regulator)) {
> +		if (PTR_ERR(gmac->regulator) == -EPROBE_DEFER)
> +			return -EPROBE_DEFER;
> +		dev_info(dev, "No regulator found\n");
> +		gmac->regulator = NULL;
> +	}
> +
> +	gmac->regmap = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
> +						       "syscon");
> +	if (IS_ERR(gmac->regmap)) {
> +		ret = PTR_ERR(gmac->regmap);
> +		dev_err(&pdev->dev, "Unable to map syscon: %d\n", ret);
> +		return ret;
> +	}
> +
> +	plat_dat->interface = of_get_phy_mode(dev->of_node);
> +	if (plat_dat->interface == gmac->variant->internal_phy) {
> +		dev_info(&pdev->dev, "Will use internal PHY\n");

So here you seem to deduce the usage of the internal PHY by the PHY
interface specified in the DT (MII = internal, RGMII = external).
I think I raised this question before, but isn't it perfectly legal for
a board to use MII with an external PHY even on those SoCs that feature
an internal PHY?
On the first glance that does not make too much sense, but apart from
not being the correct binding to describe all of the SoCs features I see
two scenarios:
1) A board vendor might choose to not use the internal PHY because it
has bugs, lacks features (configurability) or has other issues. For
instance I have heard reports that the internal PHY makes the SoC go
rather hot, possibly limiting the CPU frequency. By using an external
MII PHY (which are still cheaper than RGMII PHYs) this can be avoided.
2) A PHY does not necessarily need to be directly connected to
magnetics. Indeed quite some boards use (RG)MII to connect to a switch
IC or some other network circuitry, for instance fibre connectors.

So I was wondering if we would need an explicit:
	allwinner,use-internal-phy;
boolean DT property to signal the usage of the internal PHY?
Alternatively we could go with the negative version:
	allwinner,disable-internal-phy;

Or what about introducing a new "allwinner,internal-mii-phy" compatible
string for the *PHY* node and use that?

I just want to avoid that we introduce a binding that causes us
headaches later. I think we can still fix this with a followup patch
before the driver and its binding hit a release kernel.

Cheers,
Andre.

> +		gmac->use_internal_phy = true;
> +		gmac->ephy_clk = of_clk_get(plat_dat->phy_node, 0);
> +		if (IS_ERR(gmac->ephy_clk)) {
> +			ret = PTR_ERR(gmac->ephy_clk);
> +			dev_err(&pdev->dev, "Cannot get EPHY clock: %d\n", ret);
> +			return -EINVAL;
> +		}
> +
> +		gmac->rst_ephy = of_reset_control_get(plat_dat->phy_node, NULL);
> +		if (IS_ERR(gmac->rst_ephy)) {
> +			ret = PTR_ERR(gmac->rst_ephy);
> +			if (ret == -EPROBE_DEFER)
> +				return ret;
> +			dev_err(&pdev->dev, "No EPHY reset control found %d\n",
> +				ret);
> +			return -EINVAL;
> +		}
> +	} else {
> +		dev_info(&pdev->dev, "Will use external PHY\n");
> +		gmac->use_internal_phy = false;
> +	}
> +
> +	/* platform data specifying hardware features and callbacks.
> +	 * hardware features were copied from Allwinner drivers.
> +	 */
> +	plat_dat->rx_coe = STMMAC_RX_COE_TYPE2;
> +	plat_dat->tx_coe = 1;
> +	plat_dat->has_sun8i = true;
> +	plat_dat->bsp_priv = gmac;
> +	plat_dat->init = sun8i_dwmac_init;
> +	plat_dat->exit = sun8i_dwmac_exit;
> +	plat_dat->setup = sun8i_dwmac_setup;
> +
> +	ret = sun8i_dwmac_init(pdev, plat_dat->bsp_priv);
> +	if (ret)
> +		return ret;
> +
> +	ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
> +	if (ret)
> +		sun8i_dwmac_exit(pdev, plat_dat->bsp_priv);
> +
> +	return ret;
> +}
> +
> +static const struct of_device_id sun8i_dwmac_match[] = {
> +	{ .compatible = "allwinner,sun8i-h3-emac",
> +		.data = &emac_variant_h3 },
> +	{ .compatible = "allwinner,sun8i-a83t-emac",
> +		.data = &emac_variant_a83t },
> +	{ .compatible = "allwinner,sun50i-a64-emac",
> +		.data = &emac_variant_a64 },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(of, sun8i_dwmac_match);
> +
> +static struct platform_driver sun8i_dwmac_driver = {
> +	.probe  = sun8i_dwmac_probe,
> +	.remove = stmmac_pltfr_remove,
> +	.driver = {
> +		.name           = "dwmac-sun8i",
> +		.pm		= &stmmac_pltfr_pm_ops,
> +		.of_match_table = sun8i_dwmac_match,
> +	},
> +};
> +module_platform_driver(sun8i_dwmac_driver);
> +
> +MODULE_AUTHOR("Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>");
> +MODULE_DESCRIPTION("Allwinner sun8i DWMAC specific glue layer");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index c80c9c3b67db..68a188e74c54 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -235,6 +235,17 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
>  		else if ((clk_rate >= CSR_F_250M) && (clk_rate < CSR_F_300M))
>  			priv->clk_csr = STMMAC_CSR_250_300M;
>  	}
> +
> +	if (priv->plat->has_sun8i) {
> +		if (clk_rate > 160000000)
> +			priv->clk_csr = 0x03;
> +		else if (clk_rate > 80000000)
> +			priv->clk_csr = 0x02;
> +		else if (clk_rate > 40000000)
> +			priv->clk_csr = 0x01;
> +		else
> +			priv->clk_csr = 0;
> +	}
>  }
>  
>  static void print_pkt(unsigned char *buf, int len)
> @@ -3955,6 +3966,10 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
>  
>  	priv->hw = mac;
>  
> +	/* dwmac-sun8i only work in chain mode */
> +	if (priv->plat->has_sun8i)
> +		chain_mode = 1;
> +
>  	/* To use the chained or ring mode */
>  	if (priv->synopsys_id >= DWMAC_CORE_4_00) {
>  		priv->hw->mode = &dwmac4_ring_mode_ops;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 7fc3a1ef395a..3840529344ed 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -309,6 +309,12 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>  			 struct device_node *np, struct device *dev)
>  {
>  	bool mdio = true;
> +	static const struct of_device_id need_mdio_ids[] = {
> +		{ .compatible = "snps,dwc-qos-ethernet-4.10" },
> +		{ .compatible = "allwinner,sun8i-a83t-emac" },
> +		{ .compatible = "allwinner,sun8i-h3-emac" },
> +		{ .compatible = "allwinner,sun50i-a64-emac" },
> +	};
>  
>  	/* If phy-handle property is passed from DT, use it as the PHY */
>  	plat->phy_node = of_parse_phandle(np, "phy-handle", 0);
> @@ -325,8 +331,7 @@ static int stmmac_dt_phy(struct plat_stmmacenet_data *plat,
>  		mdio = false;
>  	}
>  
> -	/* exception for dwmac-dwc-qos-eth glue logic */
> -	if (of_device_is_compatible(np, "snps,dwc-qos-ethernet-4.10")) {
> +	if (of_match_node(need_mdio_ids, np)) {
>  		plat->mdio_node = of_get_child_by_name(np, "mdio");
>  	} else {
>  		/**
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index 8bb550bca96d..108739ff9223 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -186,6 +186,7 @@ struct plat_stmmacenet_data {
>  	struct reset_control *stmmac_rst;
>  	struct stmmac_axi *axi;
>  	int has_gmac4;
> +	bool has_sun8i;
>  	bool tso_en;
>  	int mac_port_sel_speed;
>  	bool en_tx_lpi_clockgating;
> 
