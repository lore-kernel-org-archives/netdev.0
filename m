From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Mon, 12 Mar 2012 09:34:59 -0500
Message-ID: <4F5E0993.9020000@gmail.com>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Viresh Kumar <viresh.kumar@st.com>,
	devicetree-discuss@ozlabs.org, linux-arm-kernel@lists.infradead.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58305 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480Ab2CLOfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 10:35:06 -0400
Received: by mail-gy0-f174.google.com with SMTP id r11so2611440ghr.19
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2012 07:35:06 -0700 (PDT)
In-Reply-To: <1331561157-3820-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/2012 09:05 AM, Stefan Roese wrote:
> This patch adds support to configure the STMMAC ethernet driver via
> device-tree instead of platform_data.
> 
> Currently, only the properties needed on SPEAr600 are provided. All
> other properties should be added once needed on other platforms.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Viresh Kumar <viresh.kumar@st.com>
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

This is too generic. This should be 1 string per version of h/w.

'stm' should be 'st' according to vendor-prefixes.txt.

> +- reg: Address and length of the register set for the device
> +- interrupt-parent: Should be the phandle for the interrupt controller
> +  that services interrupts for this device
> +- interrupts: Should contain the STMMAC interrupts
> +- interrupt-names: Should contain the interrupt names "macirq"
> +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> +  property

You should be able to tell this from the compatible string and number of
interrupts.

> +- phy-mode: String, operation mode of the PHY interface.
> +  Supported values are: "mii", "rmii", "gmii", "rgmii".
> +- phy-addr: MDIO address of the PHY

This is normally probed or the mdio bus is a sub-node of the MAC node.
See arch/powerpc/boot/dts/mpc8377_mds.dts for an example.

> +
> +Optional properties:
> +- stm,prog-burst-len: Specify the burst length
> +- stm,has-gmac: Indicates that the controller supports 1000Mbps
> +- stm,has-pmt: Indicates that the controller supports power management

I think these should all be encoded by the compatible string.

Rob

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
