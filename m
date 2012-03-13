From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH v2] stmmac: Add device-tree support
Date: Tue, 13 Mar 2012 15:28:04 +0100
Message-ID: <201203131528.04318.sr@denx.de>
References: <1331623394-14600-1-git-send-email-sr@denx.de> <4F5F5753.6080601@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	devicetree-discuss@ozlabs.org, spear-devel@list.st.com
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:42781 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab2CMO2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 10:28:33 -0400
In-Reply-To: <4F5F5753.6080601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob,

thanks for the review. I'll fix the issues and send an updated patch version.

Stefan

On Tuesday 13 March 2012 15:18:59 Rob Herring wrote:
> On 03/13/2012 02:23 AM, Stefan Roese wrote:
> > This patch adds support to configure the STMMAC ethernet driver via
> > device-tree instead of platform_data.
> > 
> > Currently, only the properties needed on SPEAr600 are provided. All
> > other properties should be added once needed on other platforms.
> > 
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> > ---
> > v2:
> > - Renamed stm -> st
> > - Renamed compatible to "st,spear600-gmac"
> > - Removed "prog-burst-len", "had-gmac", has-pmt" properties.
> > 
> >   They are now implicitly set for "st,spear600-gmac" compatible
> >   devices.
> > 
> > - Removed phy-addr
> > - Used "if (pdev->dev.of_node)" to distinguish between DT
> > 
> >   and non-DT version instead of #ifdef
> >  
> >  Documentation/devicetree/bindings/net/stmmac.txt   |   28 ++++++++
> >  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   76
> >  +++++++++++++++++++- 2 files changed, 102 insertions(+), 2 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
> > b/Documentation/devicetree/bindings/net/stmmac.txt new file mode 100644
> > index 0000000..a91f4e1
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> > @@ -0,0 +1,28 @@
> > +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> > +
> > +Required properties:
> > +- compatible: Should be "st,spear600-gmac"
> > +- reg: Address and length of the register set for the device
> > +- interrupt-parent: Should be the phandle for the interrupt controller
> > +  that services interrupts for this device
> > +- interrupts: Should contain the STMMAC interrupts
> > +- interrupt-names: Should contain the interrupt names "macirq"
> > +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> > +  property
> > +- phy-mode: String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "rmii", "gmii", "rgmii".
> > +
> > +Optional properties:
> > +- mac-address: 6 bytes, mac address
> > +
> > +Examples:
> > +
> > +	gmac0: stmmac@e0800000 {
> 
> Use generic names: gmac0: ethernet@e0800000
> 
> > +		compatible = "st,spear600-gmac";
> > +		reg = <0xe0800000 0x8000>;
> > +		interrupt-parent = <&vic1>;
> > +		interrupts = <24 23>;
> > +		interrupt-names = "macirq", "eth_wake_irq";
> > +		mac-address = [000000000000]; /* Filled in by U-Boot */
> > +		phy-mode = "gmii";
> > +	};
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c index
> > 3aad981..ed8b477 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > @@ -24,8 +24,50 @@
> > 
> >  #include <linux/platform_device.h>
> >  #include <linux/io.h>
> > 
> > +#include <linux/of.h>
> > +#include <linux/of_net.h>
> > 
> >  #include "stmmac.h"
> > 
> > +#ifdef CONFIG_OF
> > +static int __devinit stmmac_probe_config_dt(struct platform_device
> > *pdev, +					    struct 
plat_stmmacenet_data *plat,
> > +					    const char **mac)
> > +{
> > +	struct device_node *np = pdev->dev.of_node;
> > +
> > +	if (!np)
> > +		return -ENODEV;
> > +
> > +	*mac = of_get_mac_address(np);
> > +
> > +	plat->interface = of_get_phy_mode(np);
> > +	of_property_read_u32(np, "phy-addr", &plat->phy_addr);
> 
> This property doesn't exist anymore.
> 
> > +	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
> > +					   sizeof(struct 
stmmac_mdio_bus_data),
> > +					   GFP_KERNEL);
> > +
> > +	/*
> > +	 * Currently only the properties needed on SPEAr600
> > +	 * are provided. All other properties should be added
> > +	 * once needed on other platforms.
> > +	 */
> > +        if (of_device_is_compatible(np, "st,spear600-gmac")) {
> 
> indent is using spaces.
> 
> > +		plat->pbl = 8;
> > +		plat->has_gmac = 1;
> > +		plat->pmt = 1;
> > +	}
> > +
> > +	return 0;
> > +}
> > +#else
> > +static int __devinit stmmac_probe_config_dt(struct platform_device
> > *pdev, +					    struct 
plat_stmmacenet_data *plat,
> > +					    const char **mac)
> > +{
> > +	return ERR_PTR(-ENOSYS);
> > +}
> > +#endif /* CONFIG_OF */
> > +
> > 
> >  /**
> >  
> >   * stmmac_pltfr_probe
> >   * @pdev: platform device pointer
> > 
> > @@ -39,7 +81,8 @@ static int stmmac_pltfr_probe(struct platform_device
> > *pdev)
> > 
> >  	struct resource *res;
> >  	void __iomem *addr = NULL;
> >  	struct stmmac_priv *priv = NULL;
> > 
> > -	struct plat_stmmacenet_data *plat_dat;
> > +	struct plat_stmmacenet_data *plat_dat = NULL;
> > +	const char *mac = NULL;
> > 
> >  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> >  	if (!res)
> > 
> > @@ -58,7 +101,25 @@ static int stmmac_pltfr_probe(struct platform_device
> > *pdev)
> > 
> >  		ret = -ENOMEM;
> >  		goto out_release_region;
> >  	
> >  	}
> > 
> > -	plat_dat = pdev->dev.platform_data;
> > +
> > +	if (pdev->dev.of_node) {
> > +		plat_dat = devm_kzalloc(&pdev->dev,
> > +					sizeof(struct 
plat_stmmacenet_data),
> > +					GFP_KERNEL);
> > +		if (!plat_dat) {
> > +			pr_err("%s: ERROR: no memory", __func__);
> > +			ret = -ENOMEM;
> > +			goto out_unmap;
> > +		}
> > +
> > +		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
> > +		if (ret) {
> > +			pr_err("%s: main dt probe failed", __func__);
> > +			goto out_unmap;
> > +		}
> > +	} else {
> > +		plat_dat = pdev->dev.platform_data;
> > +	}
> > 
> >  	/* Custom initialisation (if needed)*/
> >  	if (plat_dat->init) {
> > 
> > @@ -73,6 +134,10 @@ static int stmmac_pltfr_probe(struct platform_device
> > *pdev)
> > 
> >  		goto out_unmap;
> >  	
> >  	}
> > 
> > +	/* Get MAC address if available (DT) */
> > +	if (mac)
> > +		memcpy(priv->dev->dev_addr, mac, ETH_ALEN);
> > +
> > 
> >  	/* Get the MAC information */
> >  	priv->dev->irq = platform_get_irq_byname(pdev, "macirq");
> >  	if (priv->dev->irq == -ENXIO) {
> > 
> > @@ -178,6 +243,12 @@ static const struct dev_pm_ops stmmac_pltfr_pm_ops =
> > {
> > 
> >  static const struct dev_pm_ops stmmac_pltfr_pm_ops;
> >  #endif /* CONFIG_PM */
> > 
> > +static const struct of_device_id stmmac_dt_ids[] = {
> > +	{ .compatible = "st,spear600-gmac", },
> > +	{ /* sentinel */ }
> > +};
> > +MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
> > +
> > 
> >  static struct platform_driver stmmac_driver = {
> >  
> >  	.probe = stmmac_pltfr_probe,
> >  	.remove = stmmac_pltfr_remove,
> > 
> > @@ -185,6 +256,7 @@ static struct platform_driver stmmac_driver = {
> > 
> >  		   .name = STMMAC_RESOURCE_NAME,
> >  		   .owner = THIS_MODULE,
> >  		   .pm = &stmmac_pltfr_pm_ops,
> > 
> > +		   .of_match_table = of_match_ptr(stmmac_dt_ids),
> > 
> >  		   },
> >  
> >  };
