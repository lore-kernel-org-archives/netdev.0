From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net/fec: add device tree probe support
Date: Sun, 3 Jul 2011 15:23:12 -0600
Message-ID: <20110703212312.GD13742@ponder.secretlab.ca>
References: <1309680401-22904-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, patches@linaro.org,
	Jason Liu <jason.hui@linaro.org>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:44034 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab1GCVXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2011 17:23:13 -0400
Received: by pzk9 with SMTP id 9so1196524pzk.19
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2011 14:23:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1309680401-22904-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 03, 2011 at 04:06:41PM +0800, Shawn Guo wrote:
> It adds device tree probe support for fec driver.
> 
> Signed-off-by: Jason Liu <jason.hui@linaro.org>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Minor comments below.  After addressing them you can add my:

Acked-by: Grant Likely <grant.likely@secretlab.ca>

I don't see any reason not to merge this one in v3.1

g.

> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt |   24 ++++
>  drivers/net/fec.c                                 |  120 ++++++++++++++++++++-
>  2 files changed, 139 insertions(+), 5 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/fsl-fec.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> new file mode 100644
> index 0000000..1dad888
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -0,0 +1,24 @@
> +* Freescale Fast Ethernet Controller (FEC)
> +
> +Required properties:
> +- compatible : Should be "fsl,<soc>-fec"
> +- reg : Address and length of the register set for the device
> +- interrupts : Should contain fec interrupt
> +- phy-mode : String, operation mode of the PHY interface.
> +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi".

We don't have a common binding for this yet.  Should be
"fsl,phy-mode".

> +- gpios : Should specify the gpio for phy reset
> +
> +Optional properties:
> +- local-mac-address : 6 bytes, mac address
> +
> +Example:
> +
> +fec@83fec000 {
> +	compatible = "fsl,imx51-fec", "fsl,imx27-fec";
> +	reg = <0x83fec000 0x4000>;
> +	interrupts = <87>;
> +	phy-mode = "mii";
> +	gpios = <&gpio1 14 0>; /* phy-reset, GPIO2_14 */
> +	local-mac-address = [00 04 9F 01 1B B9];
> +};
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 7ae3f28..3ee05ff 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -44,6 +44,9 @@
>  #include <linux/platform_device.h>
>  #include <linux/phy.h>
>  #include <linux/fec.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/of_gpio.h>
>  
>  #include <asm/cacheflush.h>
>  
> @@ -78,6 +81,17 @@ static struct platform_device_id fec_devtype[] = {
>  	{ }
>  };
>  
> +enum fec_type {
> +	IMX27_FEC,
> +	IMX28_FEC,
> +};
> +
> +static const struct of_device_id fec_dt_ids[] = {
> +	{ .compatible = "fsl,imx27-fec", .data = &fec_devtype[IMX27_FEC], },
> +	{ .compatible = "fsl,imx28-fec", .data = &fec_devtype[IMX28_FEC], },

Personally, I'd drop the fec_devtype array entirely and have discrete
structures for each, but that isn't a big enough objection to withhold
my acked-by.

> +	{ /* sentinel */ },

Drop the trailing comma.

> +};
> +
>  static unsigned char macaddr[ETH_ALEN];
>  module_param_array(macaddr, byte, NULL, 0);
>  MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
> @@ -734,8 +748,25 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
>  	 */
>  	iap = macaddr;
>  
> +#ifdef CONFIG_OF
> +	/*
> +	 * 2) from device tree data
> +	 */
> +	if (!is_valid_ether_addr(iap)) {
> +		struct device_node *np = fep->pdev->dev.of_node;
> +		if (np) {
> +			const char *mac;
> +			int err;
> +			err = of_property_read_string(np,
> +					"local-mac-address", &mac);
> +			if (err)
> +				iap = (unsigned char *) mac;

There is already a function for doing this.  of_get_mac_address().
And mac address is *not* a string, it is a byte array.

> +		}
> +	}
> +#endif
> +
>  	/*
> -	 * 2) from flash or fuse (via platform data)
> +	 * 3) from flash or fuse (via platform data)
>  	 */
>  	if (!is_valid_ether_addr(iap)) {
>  #ifdef CONFIG_M5272
> @@ -748,7 +779,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
>  	}
>  
>  	/*
> -	 * 3) FEC mac registers set by bootloader
> +	 * 4) FEC mac registers set by bootloader
>  	 */
>  	if (!is_valid_ether_addr(iap)) {
>  		*((unsigned long *) &tmpaddr[0]) =
> @@ -1358,6 +1389,72 @@ static int fec_enet_init(struct net_device *ndev)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_OF
> +static int __devinit fec_get_phy_mode_dt(struct platform_device *pdev)
> +{
> +	struct device_node *np = pdev->dev.of_node;
> +	int err, i;
> +	const char *pm, *phy_modes[] = {
> +		[PHY_INTERFACE_MODE_MII]	= "mii",
> +		[PHY_INTERFACE_MODE_GMII]	= "gmii",
> +		[PHY_INTERFACE_MODE_SGMII]	= "sgmii",
> +		[PHY_INTERFACE_MODE_TBI]	= "tbi",
> +		[PHY_INTERFACE_MODE_RMII]	= "rmii",
> +		[PHY_INTERFACE_MODE_RGMII]	= "rgmii",
> +		[PHY_INTERFACE_MODE_RGMII_ID]	= "rgmii-id",
> +		[PHY_INTERFACE_MODE_RGMII_RXID]	= "rgmii-rxid",
> +		[PHY_INTERFACE_MODE_RGMII_TXID] = "rgmii-txid",
> +		[PHY_INTERFACE_MODE_RTBI]	= "rtbi",
> +	};

The phymodes table should be defined outside of the function.

> +
> +	if (np) {
> +		err = of_property_read_string(np, "phy-mode", &pm);
> +		if (err)
> +			return err;
> +		for (i = 0; i < ARRAY_SIZE(phy_modes); i++)
> +			if (!strcasecmp(pm, phy_modes[i]))
> +				return i;
> +	}
> +
> +	return -ENODEV;
> +}
> +
> +static int __devinit fec_reset_phy(struct platform_device *pdev)
> +{
> +	int err, phy_reset;
> +	struct device_node *np = pdev->dev.of_node;
> +
> +	if (!np)
> +		return -ENODEV;
> +
> +	phy_reset = of_get_gpio(np, 0);
> +	err = gpio_request_one(phy_reset, GPIOF_OUT_INIT_LOW, "phy-reset");
> +	if (err) {
> +		pr_warn("FEC: failed to get gpio phy-reset: %d\n", err);
> +		return err;
> +	}
> +
> +	msleep(1);
> +	gpio_set_value(phy_reset, 1);
> +
> +	return 0;
> +}
> +#else /* CONFIG_OF */
> +static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
> +{
> +	return -ENODEV;
> +}
> +
> +static inline int fec_reset_phy(struct platform_device *pdev)
> +{
> +	/*
> +	 * In case of platform probe, the reset has been done
> +	 * by machine code.
> +	 */
> +	return 0;
> +}
> +#endif /* CONFIG_OF */
> +
>  static int __devinit
>  fec_probe(struct platform_device *pdev)
>  {
> @@ -1366,6 +1463,11 @@ fec_probe(struct platform_device *pdev)
>  	struct net_device *ndev;
>  	int i, irq, ret = 0;
>  	struct resource *r;
> +	const struct of_device_id *of_id;
> +
> +	of_id = of_match_device(fec_dt_ids, &pdev->dev);
> +	if (of_id)
> +		pdev->id_entry = (struct platform_device_id *) of_id->data;

of_id->data is a void*.  You don't need the cast.

>  
>  	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	if (!r)
> @@ -1397,9 +1499,16 @@ fec_probe(struct platform_device *pdev)
>  
>  	platform_set_drvdata(pdev, ndev);
>  
> -	pdata = pdev->dev.platform_data;
> -	if (pdata)
> -		fep->phy_interface = pdata->phy;
> +	fep->phy_interface = fec_get_phy_mode_dt(pdev);
> +	if (fep->phy_interface == -ENODEV) {
> +		pdata = pdev->dev.platform_data;
> +		if (pdata)
> +			fep->phy_interface = pdata->phy;
> +		else
> +			fep->phy_interface = PHY_INTERFACE_MODE_MII;
> +	}
> +
> +	fec_reset_phy(pdev);
>  
>  	/* This device has up to three irqs on some platforms */
>  	for (i = 0; i < 3; i++) {
> @@ -1534,6 +1643,7 @@ static struct platform_driver fec_driver = {
>  #ifdef CONFIG_PM
>  		.pm	= &fec_pm_ops,
>  #endif
> +		.of_match_table = fec_dt_ids,
>  	},
>  	.id_table = fec_devtype,
>  	.probe	= fec_probe,
> -- 
> 1.7.4.1
> 
