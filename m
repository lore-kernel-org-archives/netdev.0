From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2] net/smsc911x: add device tree probe support
Date: Sat, 30 Jul 2011 00:16:38 +0800
Message-ID: <20110729161637.GB2241@S2100-06.ap.freescale.net>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
 <1311928996-10729-1-git-send-email-shawn.guo@linaro.org>
 <20110729155354.GD11164@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>, <patches@linaro.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	"David S. Miller" <davem@davemloft.net>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:51620
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751212Ab1G2QJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 12:09:20 -0400
Content-Disposition: inline
In-Reply-To: <20110729155354.GD11164@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2011 at 09:53:54AM -0600, Grant Likely wrote:
> On Fri, Jul 29, 2011 at 04:43:16PM +0800, Shawn Guo wrote:
> > It adds device tree probe support for smsc911x driver.
> > 
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: Grant Likely <grant.likely@secretlab.ca>
> > Cc: Steve Glendinning <steve.glendinning@smsc.com>
> > Cc: David S. Miller <davem@davemloft.net>
> 
> Some comments below, and I asked a question on the older version about
> the actual model name vs. compatible, but otherwise it looks right and
> you can add my:
> 
> Reviewed-by: Grant Likely <grant.likely@secretlab.ca>
> 
Thanks, Grant.

> > ---
> > Changes since v1:
> >  * Instead of getting irq line from gpio number, it use irq domain
> >    to keep platform_get_resource(IORESOURCE_IRQ) works for dt too.
> >  * Use 'lan9115' the first model that smsc911x supports in the match
> >    table
> >  * Use reg-shift and reg-io-width which already used in of_serial for
> >    shift and access size binding
> > 
> >  Documentation/devicetree/bindings/net/smsc911x.txt |   38 +++++++++
> >  drivers/net/smsc911x.c                             |   85 +++++++++++++++++---
> >  2 files changed, 112 insertions(+), 11 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/net/smsc911x.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> > new file mode 100644
> > index 0000000..271c454
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> > @@ -0,0 +1,38 @@
> > +* Smart Mixed-Signal Connectivity (SMSC) LAN911x/912x Controller
> > +
> > +Required properties:
> > +- compatible : Should be "smsc,lan<model>", "smsc,lan9115"
> > +- reg : Address and length of the io space for SMSC LAN
> > +- interrupts : Should contain SMSC LAN interrupt line
> > +- interrupt-parent : Should be the phandle for the interrupt controller
> > +  that services interrupts for this device
> > +- phy-mode : String, operation mode of the PHY interface.
> > +  Supported values are: "mii", "gmii", "sgmii", "tbi", "rmii",
> > +  "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid", "rtbi", "smii".
> > +
> > +Optional properties:
> > +- reg-shift : Specify the quantity to shift the register offsets by
> > +- reg-io-width : Specify the size (in bytes) of the IO accesses that
> > +  should be performed on the device.  Valid value for SMSC LAN is
> > +  2 or 4.  If it's omitted or invalid, the size would be 2.
> > +- smsc,irq-active-high : Indicates the IRQ polarity is active-low
> 
> Which is it?  Active high or active low?  The property doesn't match
> the description.
> 
Sorry.  The description is wrong.

> > +- smsc,irq-push-pull : Indicates the IRQ type is push-pull
> 
> What exactly does "push-pull" mean here?
> 
I do not understand exactly.  But I see the term used in driver was
originally from SMSC data sheet.

> > +- smsc,force-internal-phy : Forces SMSC LAN controller to use
> > +  internal PHY
> > +- smsc,force-external-phy : Forces SMSC LAN controller to use
> > +  external PHY
> > +- smsc,save-mac-address : Indicates that mac address needs to be saved
> > +  before resetting the controller
> > +- local-mac-address : 6 bytes, mac address
> > +
> > +Examples:
> > +
> > +lan9220@f4000000 {
> > +	compatible = "smsc,lan9220", "smsc,lan9115";
> > +	reg = <0xf4000000 0x2000000>;
> > +	phy-mode = "mii";
> > +	interrupt-parent = <&gpio1>;
> > +	interrupts = <31>;
> > +	reg-io-width = <4>;
> > +	smsc,irq-push-pull;
> > +};
> > diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> > index b9016a3..75c08a5 100644
> > --- a/drivers/net/smsc911x.c
> > +++ b/drivers/net/smsc911x.c
> > @@ -53,6 +53,10 @@
> >  #include <linux/phy.h>
> >  #include <linux/smsc911x.h>
> >  #include <linux/device.h>
> > +#include <linux/of.h>
> > +#include <linux/of_device.h>
> > +#include <linux/of_gpio.h>
> > +#include <linux/of_net.h>
> >  #include "smsc911x.h"
> >  
> >  #define SMSC_CHIPNAME		"smsc911x"
> > @@ -2095,8 +2099,58 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
> >  	.tx_writefifo = smsc911x_tx_writefifo_shift,
> >  };
> >  
> > +#ifdef CONFIG_OF
> > +static int __devinit smsc911x_probe_config_dt(
> > +				struct smsc911x_platform_config *config,
> > +				struct device_node *np)
> > +{
> > +	const char *mac;
> > +	u32 width = 0;
> > +
> > +	if (!np)
> > +		return -ENODEV;
> > +
> > +	config->phy_interface = of_get_phy_mode(np);
> > +
> > +	mac = of_get_mac_address(np);
> > +	if (mac)
> > +		memcpy(config->mac, mac, ETH_ALEN);
> > +
> > +	of_property_read_u32(np, "reg-shift", &config->shift);
> > +
> > +	of_property_read_u32(np, "reg-io-width", &width);
> > +	if (width == 4)
> > +		config->flags |= SMSC911X_USE_32BIT;
> > +
> > +	if (of_get_property(np, "smsc,irq-active-high", NULL))
> > +		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> > +
> > +	if (of_get_property(np, "smsc,irq-push-pull", NULL))
> > +		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
> > +
> > +	if (of_get_property(np, "smsc,force-internal-phy", NULL))
> > +		config->flags |= SMSC911X_FORCE_INTERNAL_PHY;
> > +
> > +	if (of_get_property(np, "smsc,force-external-phy", NULL))
> > +		config->flags |= SMSC911X_FORCE_EXTERNAL_PHY;
> > +
> > +	if (of_get_property(np, "smsc,save-mac-address", NULL))
> > +		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
> > +
> > +	return 0;
> > +}
> > +#else
> > +static inline int smsc911x_probe_config_dt(
> > +				struct smsc911x_platform_config *config,
> > +				struct device_node *np)
> > +{
> > +	return -ENODEV;
> > +}
> > +#endif /* CONFIG_OF */
> > +
> >  static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  {
> > +	struct device_node *np = pdev->dev.of_node;
> >  	struct net_device *dev;
> >  	struct smsc911x_data *pdata;
> >  	struct smsc911x_platform_config *config = pdev->dev.platform_data;
> > @@ -2107,13 +2161,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  
> >  	pr_info("Driver version %s\n", SMSC_DRV_VERSION);
> >  
> > -	/* platform data specifies irq & dynamic bus configuration */
> > -	if (!pdev->dev.platform_data) {
> > -		pr_warn("platform_data not provided\n");
> > -		retval = -ENODEV;
> > -		goto out_0;
> > -	}
> > -
> >  	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> >  					   "smsc911x-memory");
> >  	if (!res)
> > @@ -2152,9 +2199,6 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
> >  	pdata->ioaddr = ioremap_nocache(res->start, res_size);
> >  
> > -	/* copy config parameters across to pdata */
> > -	memcpy(&pdata->config, config, sizeof(pdata->config));
> > -
> >  	pdata->dev = dev;
> >  	pdata->msg_enable = ((1 << debug) - 1);
> >  
> > @@ -2164,10 +2208,22 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  		goto out_free_netdev_2;
> >  	}
> >  
> > +	retval = smsc911x_probe_config_dt(&pdata->config, np);
> > +	if (retval && config) {
> > +		/* copy config parameters across to pdata */
> > +		memcpy(&pdata->config, config, sizeof(pdata->config));
> 
> The following will do the same but is type-safe:
> 	pdata->config = *config;
> 
I choose to keep the original taste :)

> > +		retval = 0;
> > +	}
> > +
> > +	if (retval) {
> > +		SMSC_WARN(pdata, probe, "Error smsc911x config not found");
> > +		goto out_unmap_io_3;
> > +	}
> > +
> >  	/* assume standard, non-shifted, access to HW registers */
> >  	pdata->ops = &standard_smsc911x_ops;
> >  	/* apply the right access if shifting is needed */
> > -	if (config->shift)
> > +	if (pdata->config.shift)
> >  		pdata->ops = &shifted_smsc911x_ops;
> >  
> >  	retval = smsc911x_init(dev);
> > @@ -2314,6 +2370,12 @@ static const struct dev_pm_ops smsc911x_pm_ops = {
> >  #define SMSC911X_PM_OPS NULL
> >  #endif
> >  
> > +static const struct of_device_id smsc911x_dt_ids[] = {
> > +	{ .compatible = "smsc,lan9115", },
> > +	{ /* sentinel */ }
> > +};
> > +MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
> > +
> >  static struct platform_driver smsc911x_driver = {
> >  	.probe = smsc911x_drv_probe,
> >  	.remove = __devexit_p(smsc911x_drv_remove),
> > @@ -2321,6 +2383,7 @@ static struct platform_driver smsc911x_driver = {
> >  		.name	= SMSC_CHIPNAME,
> >  		.owner	= THIS_MODULE,
> >  		.pm	= SMSC911X_PM_OPS,
> > +		.of_match_table = smsc911x_dt_ids,
> >  	},
> >  };
> >  
> > -- 
> > 1.7.4.1
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards,
Shawn

