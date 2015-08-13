From: Graeme Gregory <gg@slimlogic.co.uk>
Subject: Re: [PATCH 2/2] Convert smsc911x to use ACPI as well as DT
Date: Thu, 13 Aug 2015 10:38:38 +0100
Message-ID: <20150813093838.GC5468@xora-haswell.xora.org.uk>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-3-git-send-email-jeremy.linton@arm.com>
 <20150813082759.GB5468@xora-haswell.xora.org.uk>
 <20150813090117.GA13833@red-moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	Jeremy Linton <Jeremy.Linton@arm.com>,
	"suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48791 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751900AbbHMJil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 05:38:41 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 03A4D2191B
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 05:38:40 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20150813090117.GA13833@red-moon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 10:01:17AM +0100, Lorenzo Pieralisi wrote:
> On Thu, Aug 13, 2015 at 09:27:59AM +0100, Graeme Gregory wrote:
> > On Wed, Aug 12, 2015 at 05:06:27PM -0500, Jeremy Linton wrote:
> > > Add ACPI bindings for the smsc911x driver. Convert the DT specific calls
> > > to nonspecific device* calls, This allows the driver to work
> > > with both ACPI and DT configurations. Ethernet should now work when using
> > > ACPI on ARM Juno.
> 
> Last sentence does not belong in the commit log.
> 
> > > 
> > > Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
> > 
> > The code looks fine to me.
> > 
> > Currently the compulsary DT properties seem to match the "approved" ACPI
> > NIC properties from here
> > 
> > http://www.uefi.org/sites/default/files/resources/nic-request-v2.pdf
> 
> What about _DSD device specific properties (eg "smsc,save-mac-address") ?
> Are we taking 1:1 translation between DT and ACPI for granted ?
> 
> I thought some process must be put in place to define the corresponding
> bindings in ACPI before starting this mechanical translation or maybe
> I missed something, I would like to understand.
> 
> How does the device specific _DSD definitions work in ACPI world ? Where
> are they published ? How will we translate those to DT bindings if there
> is need ?
> 

This I do not know as that discussion is still ongoing. But those
options are currently marked as optional so driver should not fail if
they are not present in ACPI.

Graeme

> Lorenzo
> 
> > Reviewed-by: Graeme Gregory <graeme.gregory@linaro.org>
> > 
> > Thanks
> > 
> > > ---
> > >  drivers/net/ethernet/smsc/smsc911x.c | 48 +++++++++++++++++-------------------
> > >  1 file changed, 22 insertions(+), 26 deletions(-)
> > > 
> > > diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> > > index 959aeea..0f21aa3 100644
> > > --- a/drivers/net/ethernet/smsc/smsc911x.c
> > > +++ b/drivers/net/ethernet/smsc/smsc911x.c
> > > @@ -59,7 +59,9 @@
> > >  #include <linux/of_device.h>
> > >  #include <linux/of_gpio.h>
> > >  #include <linux/of_net.h>
> > > +#include <linux/acpi.h>
> > >  #include <linux/pm_runtime.h>
> > > +#include <linux/property.h>
> > >  
> > >  #include "smsc911x.h"
> > >  
> > > @@ -2362,59 +2364,46 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
> > >  	.tx_writefifo = smsc911x_tx_writefifo_shift,
> > >  };
> > >  
> > > -#ifdef CONFIG_OF
> > > -static int smsc911x_probe_config_dt(struct smsc911x_platform_config *config,
> > > -				    struct device_node *np)
> > > +static int smsc911x_probe_config(struct smsc911x_platform_config *config,
> > > +				 struct device *dev)
> > >  {
> > > -	const char *mac;
> > >  	u32 width = 0;
> > >  
> > > -	if (!np)
> > > +	if (!dev)
> > >  		return -ENODEV;
> > >  
> > > -	config->phy_interface = of_get_phy_mode(np);
> > > +	config->phy_interface = device_get_phy_mode(dev);
> > >  
> > > -	mac = of_get_mac_address(np);
> > > -	if (mac)
> > > -		memcpy(config->mac, mac, ETH_ALEN);
> > > +	device_get_mac_address(dev, config->mac, ETH_ALEN);
> > >  
> > > -	of_property_read_u32(np, "reg-shift", &config->shift);
> > > +	device_property_read_u32(dev, "reg-shift", &config->shift);
> > >  
> > > -	of_property_read_u32(np, "reg-io-width", &width);
> > > +	device_property_read_u32(dev, "reg-io-width", &width);
> > >  	if (width == 4)
> > >  		config->flags |= SMSC911X_USE_32BIT;
> > >  	else
> > >  		config->flags |= SMSC911X_USE_16BIT;
> > >  
> > > -	if (of_get_property(np, "smsc,irq-active-high", NULL))
> > > +	if (device_property_present(dev, "smsc,irq-active-high"))
> > >  		config->irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_HIGH;
> > >  
> > > -	if (of_get_property(np, "smsc,irq-push-pull", NULL))
> > > +	if (device_property_present(dev, "smsc,irq-push-pull"))
> > >  		config->irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL;
> > >  
> > > -	if (of_get_property(np, "smsc,force-internal-phy", NULL))
> > > +	if (device_property_present(dev, "smsc,force-internal-phy"))
> > >  		config->flags |= SMSC911X_FORCE_INTERNAL_PHY;
> > >  
> > > -	if (of_get_property(np, "smsc,force-external-phy", NULL))
> > > +	if (device_property_present(dev, "smsc,force-external-phy"))
> > >  		config->flags |= SMSC911X_FORCE_EXTERNAL_PHY;
> > >  
> > > -	if (of_get_property(np, "smsc,save-mac-address", NULL))
> > > +	if (device_property_present(dev, "smsc,save-mac-address"))
> > >  		config->flags |= SMSC911X_SAVE_MAC_ADDRESS;
> > >  
> > >  	return 0;
> > >  }
> > > -#else
> > > -static inline int smsc911x_probe_config_dt(
> > > -				struct smsc911x_platform_config *config,
> > > -				struct device_node *np)
> > > -{
> > > -	return -ENODEV;
> > > -}
> > > -#endif /* CONFIG_OF */
> > >  
> > >  static int smsc911x_drv_probe(struct platform_device *pdev)
> > >  {
> > > -	struct device_node *np = pdev->dev.of_node;
> > >  	struct net_device *dev;
> > >  	struct smsc911x_data *pdata;
> > >  	struct smsc911x_platform_config *config = dev_get_platdata(&pdev->dev);
> > > @@ -2478,7 +2467,7 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
> > >  		goto out_disable_resources;
> > >  	}
> > >  
> > > -	retval = smsc911x_probe_config_dt(&pdata->config, np);
> > > +	retval = smsc911x_probe_config(&pdata->config, &pdev->dev);
> > >  	if (retval && config) {
> > >  		/* copy config parameters across to pdata */
> > >  		memcpy(&pdata->config, config, sizeof(pdata->config));
> > > @@ -2654,6 +2643,12 @@ static const struct of_device_id smsc911x_dt_ids[] = {
> > >  MODULE_DEVICE_TABLE(of, smsc911x_dt_ids);
> > >  #endif
> > >  
> > > +static const struct acpi_device_id smsc911x_acpi_match[] = {
> > > +	{ "ARMH9118", 0 },
> > > +	{ }
> > > +};
> > > +MODULE_DEVICE_TABLE(acpi, smsc911x_acpi_match);
> > > +
> > >  static struct platform_driver smsc911x_driver = {
> > >  	.probe = smsc911x_drv_probe,
> > >  	.remove = smsc911x_drv_remove,
> > > @@ -2661,6 +2656,7 @@ static struct platform_driver smsc911x_driver = {
> > >  		.name	= SMSC_CHIPNAME,
> > >  		.pm	= SMSC911X_PM_OPS,
> > >  		.of_match_table = of_match_ptr(smsc911x_dt_ids),
> > > +		.acpi_match_table = ACPI_PTR(smsc911x_acpi_match),
> > >  	},
> > >  };
> > >  
> > > -- 
> > > 2.4.3
> > > 
> > > 
> > > 
> > > _______________________________________________
> > > linux-arm-kernel mailing list
> > > linux-arm-kernel@lists.infradead.org
> > > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> > 
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> > 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
