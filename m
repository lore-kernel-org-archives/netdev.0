From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver
Date: Fri, 24 Oct 2008 21:38:47 +0200
Message-ID: <20081024193847.GB18032@pengutronix.de>
References: <20081024152956.11865.9334.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:55008 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751602AbYJXTiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 15:38:50 -0400
Content-Disposition: inline
In-Reply-To: <20081024152956.11865.9334.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius,

On Fri, Oct 24, 2008 at 06:29:56PM +0300, Paulius Zaleckas wrote:
> Useful for machines where PHY control is connected to GPIO.
> This driver also supports interrupts from PHY.
> 

<snip>

> +static int __devinit mdio_gpio_bitbang_init(struct mii_bus *bus, void *data)
> +{
> +	struct mdio_gpio_info *bitbang =
> +		container_of(bus->priv, struct mdio_gpio_info, ctrl);
> +	struct mdio_gpio_platform_data *pdata = data;
> +	unsigned int i;
> +
> +	if (pdata == NULL)
> +		goto out;
> +
> +	bitbang->mdc = pdata->mdc;
> +	bitbang->mdio = pdata->mdio;
> +
> +	if (gpio_request(bitbang->mdc, "mdc"))
> +		goto out;
> +
> +	if (gpio_request(bitbang->mdio, "mdio"))
> +		goto out_free_mdc;
> +
> +	for (i = 0; i < pdata->nr_phys; i++) {
> +		unsigned int phy_addr = pdata->phys[i].addr;
> +
> +		BUG_ON(phy_addr >= PHY_MAX_ADDR);
> +
> +		bus->phy_mask &= ~(1 << phy_addr);
> +		bus->irq[phy_addr] = pdata->phys[i].irq;
> +	}
> +
> +	return 0;
> +
> +out_free_mdc:
> +	gpio_free(bitbang->mdc);
> +out:
> +	return -ENODEV;
> +}
> +
> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +	struct mii_bus *new_bus;
> +	struct mdio_gpio_info *bitbang;
> +	int ret = -ENOMEM;
> +	int i;
> +
> +	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> +	if (!bitbang)
> +		goto out;
> +
> +	bitbang->ctrl.ops = &mdio_gpio_ops;
> +
> +	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
> +	if (!new_bus)
> +		goto out_free_bitbang;
> +
> +	new_bus->name = "GPIO Bitbanged MII",
> +	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
> +
> +	new_bus->phy_mask = ~0;
> +	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +	if (!new_bus->irq)
> +		goto out_free_bus;
> +
> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		new_bus->irq[i] = PHY_POLL;
> +
> +	ret = mdio_gpio_bitbang_init(new_bus, pdev->dev.platform_data);
> +	if (ret)
> +		goto out_free_irqs;
> +
> +	new_bus->dev = &pdev->dev;
> +	platform_set_drvdata(pdev, new_bus);
> +
> +	ret = mdiobus_register(new_bus);
> +	if (ret)
> +		goto out_free_all;
> +
> +	return 0;
> +
> +out_free_all:
> +	platform_set_drvdata(pdev, NULL);

You forgot to free the gpios requested in mdio_gpio_bitbang_init() here.

> +out_free_irqs:
> +	kfree(new_bus->irq);
> +out_free_bus:
> +	free_mdio_bitbang(new_bus);
> +out_free_bitbang:
> +	kfree(bitbang);
> +out:
> +	return ret;
> +}
> +
> +static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> +{
> +	struct mii_bus *bus = platform_get_drvdata(pdev);
> +	struct mdio_gpio_info *bitbang = bus->priv;
> +
> +	mdiobus_unregister(bus);
> +	kfree(bus->irq);
> +	free_mdio_bitbang(bus);
> +	platform_set_drvdata(pdev, NULL);
> +	gpio_free(bitbang->mdc);
> +	gpio_free(bitbang->mdio);
> +	kfree(bitbang);
> +
> +	return 0;
> +}
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
> +static int mdio_gpio_init(void)
> +{
> +	return platform_driver_register(&mdio_gpio_driver);
> +}
> +
> +static void mdio_gpio_exit(void)
> +{
> +	platform_driver_unregister(&mdio_gpio_driver);
> +}
> +
> +module_init(mdio_gpio_init);
> +module_exit(mdio_gpio_exit);
> diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
> new file mode 100644
> index 0000000..82d5fa4
> --- /dev/null
> +++ b/include/linux/mdio-gpio.h
> @@ -0,0 +1,40 @@
> +/*
> + * MDIO-GPIO bus platform data structures
> + *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + */
> +
> +#ifndef __LINUX_MDIO_GPIO_H
> +#define __LINUX_MDIO_GPIO_H
> +
> +struct mdio_gpio_phy {
> +	/* PHY address on MDIO bus */
> +	unsigned int addr;
> +	/* preconfigured irq connected to PHY or -1 if no irq */
> +	int irq;
> +};
> +
> +struct mdio_gpio_platform_data {
> +	/* GPIO numbers for bus pins */
> +	unsigned int mdc;
> +	unsigned int mdio;
> +
> +	unsigned int nr_phys;
> +	struct mdio_gpio_phy *phys;
> +};
> +
> +#endif /* __LINUX_MDIO_GPIO_H */
> 
> 
> -------------------------------------------------------------------
> List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
> FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
> Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
> 

-- 
 Pengutronix - Linux Solutions for Science and Industry
   Handelsregister:  Amtsgericht Hildesheim, HRA 2686
     Hannoversche Str. 2, 31134 Hildesheim, Germany
   Phone: +49-5121-206917-0 |  Fax: +49-5121-206917-9
