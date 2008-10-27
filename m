From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Mon, 27 Oct 2008 08:37:34 -0600
Message-ID: <20081027143734.GA13565@secretlab.ca>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 27, 2008 at 12:53:22PM +0200, Paulius Zaleckas wrote:
> Useful for machines where PHY control is connected to GPIO.
> This driver also supports interrupts from PHY.
> 
> Changes since v1:
> - fixed releasing of gpio (thanks to Sascha Hauer)
> - fixed compiling due to bus->dev to bus->parent change
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> ---

Well structured driver.  Comments below.

> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> new file mode 100644
> index 0000000..585897b
> --- /dev/null
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -0,0 +1,187 @@
> +/*
> + * GPIO based MDIO bitbang driver.
> + *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> + *
> + * Based on mdio-ofgpio.c:
> + *
> + * Copyright (c) 2008 CSE Semaphore Belgium.
> + *  by Laurent Pinchart <laurentp@cse-semaphore.com>
> + *
> + * Copyright (c) 2003 Intracom S.A.
> + *  by Pantelis Antoniou <panto@intracom.gr>
> + *
> + * 2005 (c) MontaVista Software, Inc.
> + * Vitaly Bordug <vbordug@ru.mvista.com>
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/init.h>
> +#include <linux/platform_device.h>
> +#include <linux/gpio.h>
> +#include <linux/mdio-bitbang.h>
> +#include <linux/mdio-gpio.h>

Missing:

MODULE_AUTHOR()
MODULE_LICENSE()
MODULE_DESCRIPTION()

> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +	struct mii_bus *new_bus;
> +	struct mdio_gpio_info *bitbang;
> +	struct mdio_gpio_platform_data *pdata;
> +	int ret = -ENOMEM;
> +	int i;
> +
> +	pdata = pdev->dev.platform_data;
> +	if (pdata == NULL)
> +		goto out;
> +
> +	bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> +	if (!bitbang)
> +		goto out;
> +
> +	bitbang->ctrl.ops = &mdio_gpio_ops;
> +	bitbang->mdc = pdata->mdc;
> +	bitbang->mdio = pdata->mdio;
> +
> +	if (gpio_request(bitbang->mdc, "mdc"))
> +		goto out_free_bitbang;
> +
> +	if (gpio_request(bitbang->mdio, "mdio"))
> +		goto out_free_mdc;
> +
> +	new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
> +	if (!new_bus)
> +		goto out_free_gpio;
> +
> +	new_bus->name = "GPIO Bitbanged MII",
> +	snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
> +
> +	new_bus->phy_mask = ~0;
> +	new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +	if (!new_bus->irq)
> +		goto out_free_bus;

The IRQ array is fixed size.  You can add it to the mdio_gpio_info
structure and then just set the pointer here so that only one kzalloc
is needed.

> +
> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		new_bus->irq[i] = PHY_POLL;
> +
> +	for (i = 0; i < pdata->nr_phys; i++) {
> +		unsigned int phy_addr = pdata->phys[i].addr;
> +
> +		BUG_ON(phy_addr >= PHY_MAX_ADDR);

Is it really worth bringing down the whole kernel when too many phys are
specified in pdata?

> +
> +		new_bus->phy_mask &= ~(1 << phy_addr);
> +		new_bus->irq[phy_addr] = pdata->phys[i].irq;
> +	}
> +
> +	new_bus->parent = &pdev->dev;
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
> +	kfree(new_bus->irq);
> +out_free_bus:
> +	free_mdio_bitbang(new_bus);
> +out_free_gpio:
> +	gpio_free(bitbang->mdio);
> +out_free_mdc:
> +	gpio_free(bitbang->mdc);
> +out_free_bitbang:
> +	kfree(bitbang);
> +out:
> +	return ret;

Nit:  labels in column 0 will confuse diff when it tries to put the
function name in the diff hunk header.  If you indent the labels by 1
space then future diffs will show the function name instead of the label
name in diff hunk headers.

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

static int __init mdio_gpio_init(void)

> +{
> +	return platform_driver_register(&mdio_gpio_driver);
> +}
> +
> +static void mdio_gpio_exit(void)

static void __exit mdio_gpio_exit(void)

> +{
> +	platform_driver_unregister(&mdio_gpio_driver);
> +}
> +
> +module_init(mdio_gpio_init);
> +module_exit(mdio_gpio_exit);
