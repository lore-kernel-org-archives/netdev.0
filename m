From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Mon, 25 Jul 2011 15:37:23 -0600
Message-ID: <20110725213723.GI26735@ponder.secretlab.ca>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, patches@linaro.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:58973 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012Ab1GYVh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 17:37:27 -0400
Received: by gwaa18 with SMTP id a18so2884992gwa.19
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2011 14:37:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 25, 2011 at 05:44:00PM +0800, Shawn Guo wrote:
> It adds device tree probe support for smsc911x driver.
> 
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Steve Glendinning <steve.glendinning@smsc.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
>  drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
>  2 files changed, 132 insertions(+), 25 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/smsc.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
> new file mode 100644
> index 0000000..1920695
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/smsc.txt
> @@ -0,0 +1,34 @@
> +* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
> +
> +Required properties:
> +- compatible : Should be "smsc,lan<model>""smsc,lan"

Drop "smsc,lan".  That's far too generic.

> +- reg : Address and length of the io space for SMSC LAN
> +- smsc-int-gpios : Should specify the GPIO for SMSC LAN interrupt line

This looks broken.  Shouldn't this be specified as a normal
"interrupts" property?

> +- phy-mode : String, operation mode of the PHY interface.
> +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
> +
> +Optional properties:
> +- smsc,irq-active-high : Indicates the IRQ polarity is active-low
> +- smsc,irq-push-pull : Indicates the IRQ type is push-pull
> +- smsc,register-needs-shift : Indicates the register access needs shift
> +- smsc,access-in-32bit : Indicates the access to controller is in 32-bit
> +  mode

Currently, reg-io-width and reg-shift are being used to manipulate
register access on ns16550 serial ports.  The same thing can be used
here.  See bindings/tty/serial/of-serial.txt


> +- smsc,force-internal-phy : Forces SMSC LAN controller to use
> +  internal PHY
> +- smsc,force-external-phy : Forces SMSC LAN controller to use
> +  external PHY

I would expect using an external phy would also expect a phy-device
property to connect to the phy node.

> +- smsc,save-mac-address : Indicates that mac address needs to be saved
> +  before resetting the controller
> +- local-mac-address : 6 bytes, mac address
> +
> +Examples:
> +
> +lan9220@f4000000 {
> +	compatible = "smsc,lan9220", "smsc,lan";
> +	reg = <0xf4000000 0x2000000>;
> +	phy-mode = "mii";
> +	smsc-int-gpios = <&gpio1 31 0>; /* GPIO2_31 */
> +	smsc,irq-push-pull;
> +	smsc,access-in-32bit;
> +};
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index b9016a3..0097048 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -53,6 +53,10 @@
>  #include <linux/phy.h>
>  #include <linux/smsc911x.h>
>  #include <linux/device.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/of_gpio.h>
> +#include <linux/of_net.h>
>  #include "smsc911x.h"
>  
>  #define SMSC_CHIPNAME		"smsc911x"
> @@ -2095,25 +2099,67 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
>  	.tx_writefifo = smsc911x_tx_writefifo_shift,
>  };
>  
> +#ifdef CONFIG_OF
> +static int __devinit smsc911x_probe_config_dt(
> +				struct smsc911x_platform_config *config,
> +				struct device_node *np)
> +{
> +	const char *mac;
> +
> +	if (!np)
> +		return -ENODEV;
> +
> +	config->phy_interface = of_get_phy_mode(np);
> +
> +	mac = of_get_mac_address(np);
> +	if (mac)
> +		memcpy(config->mac, mac, ETH_ALEN);
> +
> +	if (of_get_property(np, "smsc,irq-active-high", NULL))
> +		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> +
> +	if (of_get_property(np, "smsc,irq-push-pull", NULL))
> +		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
> +
> +	if (of_get_property(np, "smsc,register-needs-shift", NULL))
> +		config->shift = 1;
> +
> +	if (of_get_property(np, "smsc,access-in-32bit", NULL))
> +		config->flags |= SMSC911X_USE_32BIT;
> +
> +	if (of_get_property(np, "smsc,force-internal-phy", NULL))
> +		config->flags |= SMSC911X_FORCE_INTERNAL_PHY;
> +
> +	if (of_get_property(np, "smsc,force-external-phy", NULL))
> +		config->flags |= SMSC911X_FORCE_EXTERNAL_PHY;
> +
> +	if (of_get_property(np, "smsc,save-mac-address", NULL))
> +		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
> +
> +	return 0;
> +}
> +#else
> +static inline int smsc911x_probe_config_dt(
> +				struct smsc911x_platform_config *config,
> +				struct device_node *np)
> +{
> +	return -ENODEV;
> +}
> +#endif /* CONFIG_OF */
> +
>  static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  {
> +	struct device_node *np = pdev->dev.of_node;
>  	struct net_device *dev;
>  	struct smsc911x_data *pdata;
>  	struct smsc911x_platform_config *config = pdev->dev.platform_data;
>  	struct resource *res, *irq_res;
>  	unsigned int intcfg = 0;
> -	int res_size, irq_flags;
> -	int retval;
> +	int irq_gpio, res_size, irq_flags = 0;
> +	int retval = 0;
>  
>  	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
>  
> -	/* platform data specifies irq & dynamic bus configuration */
> -	if (!pdev->dev.platform_data) {
> -		pr_warn("platform_data not provided\n");
> -		retval = -ENODEV;
> -		goto out_0;
> -	}
> -
>  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
>  					   "smsc911x-memory");
>  	if (!res)
> @@ -2125,13 +2171,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	}
>  	res_size = resource_size(res);
>  
> -	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> -	if (!irq_res) {
> -		pr_warn("Could not allocate irq resource\n");
> -		retval = -ENODEV;
> -		goto out_0;
> -	}
> -

This should still work for the device-tree situation.  Why remove it?

>  	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
>  		retval = -EBUSY;
>  		goto out_0;
> @@ -2148,26 +2187,53 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  
>  	pdata = netdev_priv(dev);
>  
> -	dev->irq = irq_res->start;
> -	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> -	pdata->ioaddr = ioremap_nocache(res->start, res_size);
> -
> -	/* copy config parameters across to pdata */
> -	memcpy(&pdata->config, config, sizeof(pdata->config));
> +	if (np) {
> +		irq_gpio = of_get_named_gpio(np, "smsc-int-gpios", 0);
> +		retval = gpio_request_one(irq_gpio, GPIOF_IN, "smsc-int-gpio");
> +		if (!retval)
> +			dev->irq = gpio_to_irq(irq_gpio);

Yeah, that's definitely the wrong way to handle this.  If the
device it wired to a gpio controller, then the gpio controller also
need to be an interrupt controller to ensure that it can map interrupt
numbers.

> +	} else {
> +		irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +		if (irq_res) {
> +			dev->irq = irq_res->start;
> +			irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> +		} else {
> +			retval = -ENODEV;
> +		}
> +	}
>  
> -	pdata->dev = dev;
> -	pdata->msg_enable = ((1 << debug) - 1);
> +	if (retval) {
> +		SMSC_WARN(pdata, probe, "Error smsc911x irq not found");
> +		retval = -EINVAL;
> +		goto out_free_netdev_2;
> +	}
>  
> +	pdata->ioaddr = ioremap_nocache(res->start, res_size);
>  	if (pdata->ioaddr == NULL) {
>  		SMSC_WARN(pdata, probe, "Error smsc911x base address invalid");
>  		retval = -ENOMEM;
>  		goto out_free_netdev_2;
>  	}
>  
> +	pdata->dev = dev;
> +	pdata->msg_enable = ((1 << debug) - 1);
> +
> +	retval = smsc911x_probe_config_dt(&pdata->config, np);
> +	if (retval && config) {
> +		/* copy config parameters across to pdata */
> +		memcpy(&pdata->config, config, sizeof(pdata->config));
> +		retval = 0;
> +	}
> +
> +	if (retval) {
> +		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
> +		goto out_unmap_io_3;
> +	}
> +
>  	/* assume standard, non-shifted, access to HW registers */
>  	pdata->ops = &standard_smsc911x_ops;
>  	/* apply the right access if shifting is needed */
> -	if (config->shift)
> +	if (pdata->config.shift)
>  		pdata->ops = &shifted_smsc911x_ops;
>  
>  	retval = smsc911x_init(dev);
> @@ -2314,6 +2380,12 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
>  #define SMSC911X_PM_OPS NULL
>  #endif
>  
> +static const struct of_device_id smsc_dt_ids[] = {
> +	{ .compatible = "smsc,lan", },

As mentioned above, "smsc,lan" is far too generic.

> +	{ /* sentinel */ }
> +};
> +MODULE_DEVICE_TABLE(of, smsc_dt_ids);
> +
>  static struct platform_driver smsc911x_driver = {
>  	.probe = smsc911x_drv_probe,
>  	.remove = __devexit_p(smsc911x_drv_remove),
> @@ -2321,6 +2393,7 @@ static struct platform_driver smsc911x_driver = {
>  		.name	= SMSC_CHIPNAME,
>  		.owner	= THIS_MODULE,
>  		.pm	= SMSC911X_PM_OPS,
> +		.of_match_table = smsc_dt_ids,
>  	},
>  };
>  
> -- 
> 1.7.4.1
> 
> 
