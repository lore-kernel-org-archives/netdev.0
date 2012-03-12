From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 15:38:25 +0100
Message-ID: <20120312143825.GB13869@game.jcrosoft.org>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Viresh Kumar <viresh.kumar-qxv4g6HH51o@public.gmane.org>,
 devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
To: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1331561157-3820-1-git-send-email-sr-ynQEQJNshbs@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 15:05 Mon 12 Mar     , Stefan Roese wrote:
> This patch adds support to configure the STMMAC ethernet driver via
> device-tree instead of platform_data.
> 
> Currently, only the properties needed on SPEAr600 are provided. All
> other properties should be added once needed on other platforms.
> 
> Signed-off-by: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
> Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
> Cc: Viresh Kumar <viresh.kumar-qxv4g6HH51o@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66 +++++++++++++++++++-
>  2 files changed, 103 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> new file mode 100644
> index 0000000..386a47f
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> @@ -0,0 +1,38 @@
> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> +
> +Required properties:
> +- compatible: Should be "stm,gmac"
this IP have 2 version at least the GMAC for the second generation and mac for
the first generation
> +- reg: Address and length of the register set for the device
> +- interrupt-parent: Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- interrupts: Should contain the STMMAC interrupts
> +- interrupt-names: Should contain the interrupt names "macirq"
> +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> +  property
optionnal
> +- phy-mode: String, operation mode of the PHY interface.
> +  Supported values are: "mii", "rmii", "gmii", "rgmii".
> +- phy-addr: MDIO address of the PHY
> +
> +Optional properties:
> +- stm,prog-burst-len: Specify the burst length
> +- stm,has-gmac: Indicates that the controller supports 1000Mbps
this IP support more mode 10/100/300/1000
> +- stm,has-pmt: Indicates that the controller supports power management
> +- mac-address: 6 bytes, mac address
> +
> +Examples:
> +
> +	gmac0: stmmac@e0800000 {
> +		compatible = "stm,gmac";
> +		reg = <0xe0800000 0x8000>;
> +		interrupt-parent = <&vic1>;
> +		interrupts = <24 23>;
> +		interrupt-names = "macirq", "eth_wake_irq";
> +		mac-address = [000000000000]; /* Filled in by U-Boot */
> +
> +		stm,prog-burst-len = <8>;
> +		stm,has-gmac;
> +		stm,has-pmt;
> +
> +		phy-mode = "gmii";
> +		phy-addr = <0>;
> +	};
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> index 3aad981..fcf46c7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> @@ -24,8 +24,43 @@
>  
>  #include <linux/platform_device.h>
>  #include <linux/io.h>
> +#include <linux/of.h>
> +#include <linux/of_net.h>
>  #include "stmmac.h"
>  
> +#ifdef CONFIG_OF
> +static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
> +					    struct plat_stmmacenet_data *plat,
> +					    const char **mac)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +
> +	if (!np)
> +		return -ENODEV;
> +
> +	*mac = of_get_mac_address(np);
> +
> +	plat->interface = of_get_phy_mode(np);
> +	of_property_read_u32(np, "phy-addr", &plat->phy_addr);
> +	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
> +					   sizeof(struct stmmac_mdio_bus_data),
> +					   GFP_KERNEL);
> +
> +	/*
> +	 * Currently only the properties needed on SPEAr600
> +	 * are provided. All other properties should be added
> +	 * once needed on other platforms.
> +	 */
> +	of_property_read_u32(np, "stm,prog-burst-len", &plat->pbl);
> +	if (of_get_property(np, "stm,has-gmac", NULL))
> +		plat->has_gmac = 1;
> +	if (of_get_property(np, "stm,has-pmt", NULL))
> +		plat->pmt = 1;
> +
> +	return 0;
> +}
> +#endif /* CONFIG_OF */
> +
>  /**
>   * stmmac_pltfr_probe
>   * @pdev: platform device pointer
> @@ -39,7 +74,8 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  	struct resource *res;
>  	void __iomem *addr = NULL;
>  	struct stmmac_priv *priv = NULL;
> -	struct plat_stmmacenet_data *plat_dat;
> +	struct plat_stmmacenet_data *plat_dat = NULL;
> +	const char *mac = NULL;
>  
>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	if (!res)
> @@ -58,6 +94,22 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  		ret = -ENOMEM;
>  		goto out_release_region;
>  	}
> +
> +#ifdef CONFIG_OF
> +	plat_dat = devm_kzalloc(&pdev->dev, sizeof(struct plat_stmmacenet_data),
> +				GFP_KERNEL);
> +	if (!plat_dat) {
> +		pr_err("%s: ERROR: no memory", __func__);
> +		ret = -ENOMEM;
> +		goto out_unmap;
> +	}
> +
> +	ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
> +	if (ret) {
> +		pr_err("%s: main dt probe failed", __func__);
> +		goto out_unmap;
> +	}
> +#else
This must be check at runtime, we can boot a kernel with or without DT.

Best Reards,
J.
>  	plat_dat = pdev->dev.platform_data;
>  
>  	/* Custom initialisation (if needed)*/
> @@ -66,6 +118,7 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  		if (unlikely(ret))
>  			goto out_unmap;
>  	}
> +#endif
>  
>  	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, addr);
>  	if (!priv) {
> @@ -73,6 +126,10 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
>  		goto out_unmap;
>  	}
>  
> +	/* Get MAC address if available (DT) */
> +	if (mac)
> +		memcpy(priv->dev->dev_addr, mac, ETH_ALEN);
> +
>  	/* Get the MAC information */
>  	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
>  	if (priv->dev->irq == -ENXIO) {
> @@ -178,6 +235,12 @@ static const struct dev_pm_ops stmmac_pltfr_pm_ops = {
>  static const struct dev_pm_ops stmmac_pltfr_pm_ops;
>  #endif /* CONFIG_PM */
>  
> +static const struct of_device_id stmmac_dt_ids[] = {
> +	{ .compatible = "stm,gmac", },
> +	{ /* sentinel */ }
> +};
> +MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
> +
>  static struct platform_driver stmmac_driver = {
>  	.probe = stmmac_pltfr_probe,
>  	.remove = stmmac_pltfr_remove,
> @@ -185,6 +248,7 @@ static struct platform_driver stmmac_driver = {
>  		   .name = STMMAC_RESOURCE_NAME,
>  		   .owner = THIS_MODULE,
>  		   .pm = &stmmac_pltfr_pm_ops,
> +		   .of_match_table = of_match_ptr(stmmac_dt_ids),
>  		   },
>  };
>  
> -- 
> 1.7.9.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
