From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v3)
Date: Mon, 10 Nov 2008 18:15:53 +0100
Message-ID: <200811101815.54126.laurentp@cse-semaphore.com>
References: <20081110151145.12986.45668.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:12102 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754150AbYKJRPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 12:15:45 -0500
In-Reply-To: <20081110151145.12986.45668.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paulius,

sorry for the late reply. I've been busy at work with a release and had no 
time to test the patch. Comments follow.

On Monday 10 November 2008, Paulius Zaleckas wrote:
> make mdio-gpio work with non OpenFirmware gpio implementation.
>
> Aditional changes to mdio-gpio:
> - use gpio_request() and gpio_free()
> - place irq[] array in struct mdio_gpio_info
> - add module description, author and license
> - add note about compiling this driver as module
> - rename mdc and mdio function (were ugly names)
> - change MII to MDIO in bus name
> - add __init __exit to module (un)loading functions
> - probe fails if no phys added to the bus
> - kzalloc bitbang with sizeof(*bitbang)
>
> Changes since v2:
> - more #ifdefs reduction
> - platform driver will be registered on OF platforms also
> - unified platform and OF bus_id to phy%i
>
> Changes since v1:
> - removed NO_IRQ
> - reduced #idefs
>
> Laurent, please test this driver under OF.

Unfortunately this breaks on OF platforms (at least on mine):

~ # ifconfig eth0 up
[  258.886051] eb:01 not found
[  258.887409] eth0: Could not attach to phy

See below for an analysis.

> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Cc: Laurent Pinchart <laurent.pinchart@skynet.be>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Mike Frysinger <vapier.adi@gmail.com>
> ---
>
>  drivers/net/phy/Kconfig     |    5 +
>  drivers/net/phy/mdio-gpio.c |  232
> ++++++++++++++++++++++++++++++------------- include/linux/mdio-gpio.h   |  
> 25 +++++
>  3 files changed, 191 insertions(+), 71 deletions(-)
>  create mode 100644 include/linux/mdio-gpio.h
>
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 0318077..c4c5a2f 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -86,8 +86,11 @@ config MDIO_BITBANG
>
>  config MDIO_GPIO
>  	tristate "Support for GPIO lib-based bitbanged MDIO buses"
> -	depends on MDIO_BITBANG && OF_GPIO
> +	depends on MDIO_BITBANG && GENERIC_GPIO
>  	---help---
>  	  Supports GPIO lib-based MDIO busses.
>
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called mdio-gpio.
> +
>  endif # PHYLIB
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> index 2ff9775..1a889fa 100644
> --- a/drivers/net/phy/mdio-gpio.c
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -1,9 +1,12 @@
>  /*
> - * OpenFirmware GPIO based MDIO bitbang driver.
> + * GPIO based MDIO bitbang driver.
> + * Supports OpenFirmware.
>   *
>   * Copyright (c) 2008 CSE Semaphore Belgium.
>   *  by Laurent Pinchart <laurentp@cse-semaphore.com>
>   *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> + *
>   * Based on earlier work by
>   *
>   * Copyright (c) 2003 Intracom S.A.
> @@ -21,9 +24,14 @@
>  #include <linux/slab.h>
>  #include <linux/init.h>
>  #include <linux/interrupt.h>
> -#include <linux/mdio-bitbang.h>
> +#include <linux/platform_device.h>
> +#include <linux/gpio.h>
> +#include <linux/mdio-gpio.h>
> +
> +#ifdef CONFIG_OF_GPIO
>  #include <linux/of_gpio.h>
>  #include <linux/of_platform.h>
> +#endif
>
>  struct mdio_gpio_info {
>  	struct mdiobb_ctrl ctrl;
> @@ -41,7 +49,7 @@ static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
>  		gpio_direction_input(bitbang->mdio);
>  }
>
> -static int mdio_read(struct mdiobb_ctrl *ctrl)
> +static int mdio_get(struct mdiobb_ctrl *ctrl)
>  {
>  	struct mdio_gpio_info *bitbang =
>  		container_of(ctrl, struct mdio_gpio_info, ctrl);
> @@ -49,7 +57,7 @@ static int mdio_read(struct mdiobb_ctrl *ctrl)
>  	return gpio_get_value(bitbang->mdio);
>  }
>
> -static void mdio(struct mdiobb_ctrl *ctrl, int what)
> +static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
>  {
>  	struct mdio_gpio_info *bitbang =
>  		container_of(ctrl, struct mdio_gpio_info, ctrl);
> @@ -57,7 +65,7 @@ static void mdio(struct mdiobb_ctrl *ctrl, int what)
>  	gpio_set_value(bitbang->mdio, what);
>  }
>
> -static void mdc(struct mdiobb_ctrl *ctrl, int what)
> +static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
>  {
>  	struct mdio_gpio_info *bitbang =
>  		container_of(ctrl, struct mdio_gpio_info, ctrl);
> @@ -67,93 +75,69 @@ static void mdc(struct mdiobb_ctrl *ctrl, int what)
>
>  static struct mdiobb_ops mdio_gpio_ops = {
>  	.owner = THIS_MODULE,
> -	.set_mdc = mdc,
> +	.set_mdc = mdc_set,
>  	.set_mdio_dir = mdio_dir,
> -	.set_mdio_data = mdio,
> -	.get_mdio_data = mdio_read,
> +	.set_mdio_data = mdio_set,
> +	.get_mdio_data = mdio_get,
>  };
>
> -static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
> -                                         struct device_node *np)
> -{
> -	struct mdio_gpio_info *bitbang = bus->priv;
> -
> -	bitbang->mdc = of_get_gpio(np, 0);
> -	bitbang->mdio = of_get_gpio(np, 1);
> -
> -	if (bitbang->mdc < 0 || bitbang->mdio < 0)
> -		return -ENODEV;
> -
> -	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);

The bus id was "%x"...

> -	return 0;
> -}
> -
> -static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
> +static int __devinit mdio_gpio_bus_init(struct device *dev,
> +					struct mdio_gpio_platform_data *pdata,
> +					int bus_id)
>  {
> -	const u32 *data;
> -	int len, id, irq;
> -
> -	data = of_get_property(np, "reg", &len);
> -	if (!data || len != 4)
> -		return;
> -
> -	id = *data;
> -	bus->phy_mask &= ~(1 << id);
> -
> -	irq = of_irq_to_resource(np, 0, NULL);
> -	if (irq != NO_IRQ)
> -		bus->irq[id] = irq;
> -}
> -
> -static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> -                                        const struct of_device_id *match)
> -{
> -	struct device_node *np = NULL;
>  	struct mii_bus *new_bus;
>  	struct mdio_gpio_info *bitbang;
>  	int ret = -ENOMEM;
>  	int i;
>
> -	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> +	bitbang = kzalloc(sizeof(*bitbang), GFP_KERNEL);
>  	if (!bitbang)
>  		goto out;
>
>  	bitbang->ctrl.ops = &mdio_gpio_ops;
> +	bitbang->mdc = pdata->mdc;
> +	bitbang->mdio = pdata->mdio;
>
>  	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
>  	if (!new_bus)
>  		goto out_free_bitbang;
>
> -	new_bus->name = "GPIO Bitbanged MII",
> +	new_bus->name = "GPIO Bitbanged MDIO",
>
> -	ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
> -	if (ret)
> -		goto out_free_bus;
> +	ret = -ENODEV;
>
> -	new_bus->phy_mask = ~0;
> -	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> -	if (!new_bus->irq)
> +	new_bus->phy_mask = pdata->phy_mask;
> +	new_bus->irq = pdata->irqs;
> +	new_bus->parent = dev;
> +
> +	if (new_bus->phy_mask == ~0)
>  		goto out_free_bus;
>
>  	for (i = 0; i < PHY_MAX_ADDR; i++)
> -		new_bus->irq[i] = -1;
> +		if (!new_bus->irq[i])
> +			new_bus->irq[i] = PHY_POLL;
>
> -	while ((np = of_get_next_child(ofdev->node, np)))
> -		if (!strcmp(np->type, "ethernet-phy"))
> -			add_phy(new_bus, np);
> +	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", bus_id);

And you renamed it to phy%i. Ethernet drivers relying on the id should be 
updated as well.

Updating drivers/net/fs_enet/fs_enet-main.c (in find_phy) fixed the problem 
for my platform. Please not that this requires a change to 
drivers/net/fs_enet/mii-bitbang.c (in fs_mii_bitbang_init) as well.

> +
> +	if (gpio_request(bitbang->mdc, "mdc"))
> +		goto out_free_bus;
>
> -	new_bus->parent = &ofdev->dev;
> -	dev_set_drvdata(&ofdev->dev, new_bus);
> +	if (gpio_request(bitbang->mdio, "mdio"))
> +		goto out_free_mdc;
> +
> +	dev_set_drvdata(dev, new_bus);
>
>  	ret = mdiobus_register(new_bus);
>  	if (ret)
> -		goto out_free_irqs;
> +		goto out_free_all;
>
>  	return 0;
>
> -out_free_irqs:
> -	dev_set_drvdata(&ofdev->dev, NULL);
> -	kfree(new_bus->irq);
> +out_free_all:
> +	dev_set_drvdata(dev, NULL);
> +	gpio_free(bitbang->mdio);
> +out_free_mdc:
> +	gpio_free(bitbang->mdc);
>  out_free_bus:
>  	free_mdio_bitbang(new_bus);
>  out_free_bitbang:
> @@ -162,16 +146,86 @@ out:
>  	return ret;
>  }
>
> -static int mdio_ofgpio_remove(struct of_device *ofdev)
> +static void __devexit mdio_gpio_bus_destroy(struct device *dev)
>  {
> -	struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
> +	struct mii_bus *bus = dev_get_drvdata(dev);
>  	struct mdio_gpio_info *bitbang = bus->priv;
>
>  	mdiobus_unregister(bus);
> -	kfree(bus->irq);
>  	free_mdio_bitbang(bus);
> -	dev_set_drvdata(&ofdev->dev, NULL);
> +	dev_set_drvdata(dev, NULL);
> +	gpio_free(bitbang->mdc);
> +	gpio_free(bitbang->mdio);
>  	kfree(bitbang);
> +}
> +
> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +	struct mdio_gpio_platform_data *pdata = pdev->dev.platform_data;
> +
> +	if (!pdata)
> +		return -ENODEV;
> +
> +	return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
> +}
> +
> +static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> +{
> +	mdio_gpio_bus_destroy(&pdev->dev);
> +
> +	return 0;
> +}
> +
> +#ifdef CONFIG_OF_GPIO
> +static void __devinit add_phy(struct mdio_gpio_platform_data *pdata,
> +			      struct device_node *np)
> +{
> +	const u32 *data;
> +	int len, id, irq;
> +
> +	data = of_get_property(np, "reg", &len);
> +	if (!data || len != 4)
> +		return;
> +
> +	id = *data;
> +	pdata->phy_mask &= ~(1 << id);
> +
> +	irq = of_irq_to_resource(np, 0, NULL);
> +	if (irq)
> +		pdata->irqs[id] = irq;
> +}
> +
> +static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> +                                        const struct of_device_id *match)
> +{
> +	struct device_node *np = NULL;
> +	struct mdio_gpio_platform_data *pdata;
> +
> +	pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
> +	if (!pdata)
> +		return -ENOMEM;
> +
> +	pdata->mdc = of_get_gpio(ofdev->node, 0);
> +	pdata->mdio = of_get_gpio(ofdev->node, 1);
> +
> +	if (pdata->mdc < 0 || pdata->mdio < 0)
> +		goto out_free;
> +
> +	while ((np = of_get_next_child(ofdev->node, np)))
> +		if (!strcmp(np->type, "ethernet-phy"))
> +			add_phy(pdata, np);
> +
> +	return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
> +
> +out_free:
> +	kfree(pdata);
> +	return -ENODEV;
> +}
> +
> +static int __devexit mdio_ofgpio_remove(struct of_device *ofdev)
> +{
> +	mdio_gpio_bus_destroy(&ofdev->dev);
> +	kfree(ofdev->dev.platform_data);
>
>  	return 0;
>  }
> @@ -187,18 +241,56 @@ static struct of_platform_driver mdio_ofgpio_driver =
> { .name = "mdio-gpio",
>  	.match_table = mdio_ofgpio_match,
>  	.probe = mdio_ofgpio_probe,
> -	.remove = mdio_ofgpio_remove,
> +	.remove = __devexit_p(mdio_ofgpio_remove),
>  };
>
> -static int mdio_ofgpio_init(void)
> +static inline int __init mdio_ofgpio_init(void)
>  {
>  	return of_register_platform_driver(&mdio_ofgpio_driver);
>  }
>
> -static void mdio_ofgpio_exit(void)
> +static inline void __exit mdio_ofgpio_exit(void)
>  {
>  	of_unregister_platform_driver(&mdio_ofgpio_driver);
>  }
> +#else
> +static inline int __init mdio_ofgpio_init(void) { return 0; }
> +static inline void __exit mdio_ofgpio_exit(void) { }
> +#endif /* CONFIG_OF_GPIO */
> +
> +static struct platform_driver mdio_gpio_driver = {
> +	.probe = mdio_gpio_probe,
> +	.remove = __devexit_p(mdio_gpio_remove),
> +	.driver		= {
> +		.name	= "mdio-gpio",
> +		.owner	= THIS_MODULE,
> +	},
> +};
> +
> +static int __init mdio_gpio_init(void)
> +{
> +	int ret;
> +
> +	ret = mdio_ofgpio_init();
> +	if (ret)
> +		return ret;
> +
> +	ret = platform_driver_register(&mdio_gpio_driver);
> +	if (ret)
> +		mdio_ofgpio_exit();
> +
> +	return ret;
> +}
> +module_init(mdio_gpio_init);
> +
> +static void __exit mdio_gpio_exit(void)
> +{
> +	platform_driver_unregister(&mdio_gpio_driver);
> +	mdio_ofgpio_exit();
> +}
> +module_exit(mdio_gpio_exit);
>
> -module_init(mdio_ofgpio_init);
> -module_exit(mdio_ofgpio_exit);
> +MODULE_ALIAS("platform:mdio-gpio");
> +MODULE_AUTHOR("Laurent Pinchart, Paulius Zaleckas");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("Generic driver for MDIO bus emulation using GPIO");
> diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
> new file mode 100644
> index 0000000..e9d3fdf
> --- /dev/null
> +++ b/include/linux/mdio-gpio.h
> @@ -0,0 +1,25 @@
> +/*
> + * MDIO-GPIO bus platform data structures
> + *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */
> +
> +#ifndef __LINUX_MDIO_GPIO_H
> +#define __LINUX_MDIO_GPIO_H
> +
> +#include <linux/mdio-bitbang.h>
> +
> +struct mdio_gpio_platform_data {
> +	/* GPIO numbers for bus pins */
> +	unsigned int mdc;
> +	unsigned int mdio;
> +
> +	unsigned int phy_mask;
> +	int irqs[PHY_MAX_ADDR];
> +};
> +
> +#endif /* __LINUX_MDIO_GPIO_H */

Best regards,

Laurent Pinchart
