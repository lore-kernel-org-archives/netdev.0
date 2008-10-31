From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: mdio-ofgpio ---> mdio-gpio
Date: Fri, 31 Oct 2008 10:06:26 -0600
Message-ID: <fa686aa40810310906j6845dd59kc9ccdce5c8213a0c@mail.gmail.com>
References: <20081031155335.19905.14186.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.234]:51515 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbYJaQGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 12:06:30 -0400
In-Reply-To: <20081031155335.19905.14186.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 9:53 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Rename mdio-ofgpio driver to mdio-gpio and make it work with
> non OpenFirmware gpio implementation.

Please respin this patch in 2 pieces; 1 patch to move the file and 1
patch to make the changes.  It is difficult to review as a single
patch.

g.


>
> Aditional changes to mdio-ofgpio:
> - use gpio_request() and gpio_free()
> - place irq[] array in struct mdio_gpio_info
> - add module description, author and license
> - if NO_IRQ is not defined define it to 0
> - add note about compiling this driver as module
> - rename mdc and mdio function (were ugly names)
> - change MII to MDIO in bus name
> - add __init __exit to module (un)loading functions
> - probe fails if no phys added to the bus
> - kzalloc bitbang with sizeof(*bitbang)
>
> Laurent, please test this driver under OF.
>
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Cc: Laurent Pinchart <laurentp@cse-semaphore.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Mike Frysinger <vapier.adi@gmail.com>
> ---
>
>  drivers/net/phy/Kconfig       |    7 +
>  drivers/net/phy/Makefile      |    2
>  drivers/net/phy/mdio-gpio.c   |  308 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/mdio-ofgpio.c |  204 ---------------------------
>  include/linux/mdio-gpio.h     |   30 ++++
>  5 files changed, 344 insertions(+), 207 deletions(-)
>  create mode 100644 drivers/net/phy/mdio-gpio.c
>  delete mode 100644 drivers/net/phy/mdio-ofgpio.c
>  create mode 100644 include/linux/mdio-gpio.h
>
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index d55932a..c4c5a2f 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -84,10 +84,13 @@ config MDIO_BITBANG
>
>          If in doubt, say N.
>
> -config MDIO_OF_GPIO
> +config MDIO_GPIO
>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
> -       depends on MDIO_BITBANG && OF_GPIO
> +       depends on MDIO_BITBANG && GENERIC_GPIO
>        ---help---
>          Supports GPIO lib-based MDIO busses.
>
> +         To compile this driver as a module, choose M here: the module
> +         will be called mdio-gpio.
> +
>  endif # PHYLIB
> diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
> index eee329f..9ae5d30 100644
> --- a/drivers/net/phy/Makefile
> +++ b/drivers/net/phy/Makefile
> @@ -15,4 +15,4 @@ obj-$(CONFIG_ICPLUS_PHY)      += icplus.o
>  obj-$(CONFIG_REALTEK_PHY)      += realtek.o
>  obj-$(CONFIG_FIXED_PHY)                += fixed.o
>  obj-$(CONFIG_MDIO_BITBANG)     += mdio-bitbang.o
> -obj-$(CONFIG_MDIO_OF_GPIO)     += mdio-ofgpio.o
> +obj-$(CONFIG_MDIO_GPIO)                += mdio-gpio.o
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> new file mode 100644
> index 0000000..a7b94ac
> --- /dev/null
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -0,0 +1,308 @@
> +/*
> + * GPIO based MDIO bitbang driver.
> + * Supports OpenFirmware.
> + *
> + * Copyright (c) 2008 CSE Semaphore Belgium.
> + *  by Laurent Pinchart <laurentp@cse-semaphore.com>
> + *
> + * Copyright (C) 2008, Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> + *
> + * Based on earlier work by
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
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/mdio-bitbang.h>
> +#ifdef CONFIG_OF_GPIO
> +# include <linux/of_gpio.h>
> +# include <linux/of_platform.h>
> +#else
> +# include <linux/platform_device.h>
> +# include <linux/gpio.h>
> +# include <linux/mdio-gpio.h>
> +#endif
> +
> +#ifndef NO_IRQ
> +#define NO_IRQ  0
> +#endif
> +
> +struct mdio_gpio_info {
> +       struct mdiobb_ctrl ctrl;
> +       int mdc, mdio;
> +       int irq[PHY_MAX_ADDR];
> +};
> +
> +static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       if (dir)
> +               gpio_direction_output(bitbang->mdio, 1);
> +       else
> +               gpio_direction_input(bitbang->mdio);
> +}
> +
> +static int mdio_get(struct mdiobb_ctrl *ctrl)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       return gpio_get_value(bitbang->mdio);
> +}
> +
> +static void mdio_set(struct mdiobb_ctrl *ctrl, int what)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       gpio_set_value(bitbang->mdio, what);
> +}
> +
> +static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       gpio_set_value(bitbang->mdc, what);
> +}
> +
> +static struct mdiobb_ops mdio_gpio_ops = {
> +       .owner = THIS_MODULE,
> +       .set_mdc = mdc_set,
> +       .set_mdio_dir = mdio_dir,
> +       .set_mdio_data = mdio_set,
> +       .get_mdio_data = mdio_get,
> +};
> +
> +#ifdef CONFIG_OF_GPIO
> +static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
> +                                         struct device_node *np)
> +{
> +       struct mdio_gpio_info *bitbang = bus->priv;
> +
> +       bitbang->mdc = of_get_gpio(np, 0);
> +       bitbang->mdio = of_get_gpio(np, 1);
> +
> +       if (bitbang->mdc < 0 || bitbang->mdio < 0)
> +               return -ENODEV;
> +
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
> +       return 0;
> +}
> +#else
> +static void __devinit mdio_gpio_bitbang_init(struct mii_bus *bus,
> +                                        struct mdio_gpio_platform_data *pdata,
> +                                       int bus_id)
> +{
> +       struct mdio_gpio_info *bitbang = bus->priv;
> +
> +       bitbang->mdc = pdata->mdc;
> +       bitbang->mdio = pdata->mdio;
> +
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "phy%i", bus_id);
> +}
> +#endif
> +
> +static void __devinit add_phy(struct mii_bus *bus, unsigned int phy_addr,
> +                             int phy_irq)
> +{
> +       if (phy_addr >= PHY_MAX_ADDR) {
> +               dev_err(bus->parent,
> +                       "Failed to add phy with invalid address: 0x%x",
> +                       phy_addr);
> +               return;
> +       }
> +
> +       bus->phy_mask &= ~(1 << phy_addr);
> +
> +       if (phy_irq != NO_IRQ)
> +               bus->irq[phy_addr] = phy_irq;
> +}
> +
> +#ifdef CONFIG_OF_GPIO
> +static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> +                                        const struct of_device_id *match)
> +{
> +       struct device_node *np = NULL;
> +       struct device *dev = &ofdev->dev;
> +#else
> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +       struct mdio_gpio_platform_data *pdata;
> +       struct device *dev = &pdev->dev;
> +#endif
> +       struct mii_bus *new_bus;
> +       struct mdio_gpio_info *bitbang;
> +       int ret = -ENOMEM;
> +       int i;
> +
> +#ifndef CONFIG_OF_GPIO
> +       pdata = dev->platform_data;
> +       if (pdata == NULL)
> +               goto out;
> +#endif
> +
> +       bitbang = kzalloc(sizeof(*bitbang), GFP_KERNEL);
> +       if (!bitbang)
> +               goto out;
> +
> +       bitbang->ctrl.ops = &mdio_gpio_ops;
> +
> +       new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
> +       if (!new_bus)
> +               goto out_free_bitbang;
> +
> +       new_bus->name = "GPIO Bitbanged MDIO",
> +
> +#ifdef CONFIG_OF_GPIO
> +       ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
> +       if (ret)
> +               goto out_free_bus;
> +#else
> +       mdio_gpio_bitbang_init(new_bus, pdata, pdev->id);
> +#endif
> +
> +       ret = -ENODEV;
> +
> +       if (gpio_request(bitbang->mdc, "mdc"))
> +               goto out_free_bus;
> +
> +       if (gpio_request(bitbang->mdio, "mdio"))
> +               goto out_free_mdc;
> +
> +       new_bus->phy_mask = ~0;
> +       new_bus->irq = bitbang->irq;
> +       new_bus->parent = dev;
> +
> +       for (i = 0; i < PHY_MAX_ADDR; i++)
> +               new_bus->irq[i] = PHY_POLL;
> +
> +#ifdef CONFIG_OF_GPIO
> +       while ((np = of_get_next_child(ofdev->node, np)))
> +               if (!strcmp(np->type, "ethernet-phy")) {
> +                       const u32 *data;
> +                       int len;
> +
> +                       data = of_get_property(np, "reg", &len);
> +                       if (!data || len != 4)
> +                               continue;
> +
> +                       add_phy(new_bus, *data,
> +                               of_irq_to_resource(np, 0, NULL));
> +               }
> +#else
> +       for (i = 0; i < pdata->nr_phys; i++)
> +               add_phy(new_bus, pdata->phys[i].addr, pdata->phys[i].irq);
> +#endif
> +
> +       if (new_bus->phy_mask == ~0)
> +               goto out_free_gpio;
> +
> +       dev_set_drvdata(dev, new_bus);
> +
> +       ret = mdiobus_register(new_bus);
> +       if (ret)
> +               goto out_free_all;
> +
> +       return 0;
> +
> +out_free_all:
> +       dev_set_drvdata(dev, NULL);
> +out_free_gpio:
> +       gpio_free(bitbang->mdio);
> +out_free_mdc:
> +       gpio_free(bitbang->mdc);
> +out_free_bus:
> +       free_mdio_bitbang(new_bus);
> +out_free_bitbang:
> +       kfree(bitbang);
> +out:
> +       return ret;
> +}
> +
> +#ifdef CONFIG_OF_GPIO
> +static int mdio_ofgpio_remove(struct of_device *ofdev)
> +{
> +       struct device *dev = &ofdev->dev;
> +#else
> +static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> +{
> +       struct device *dev = &pdev->dev;
> +#endif
> +       struct mii_bus *bus = dev_get_drvdata(dev);
> +       struct mdio_gpio_info *bitbang = bus->priv;
> +
> +       mdiobus_unregister(bus);
> +       free_mdio_bitbang(bus);
> +       dev_set_drvdata(dev, NULL);
> +       gpio_free(bitbang->mdc);
> +       gpio_free(bitbang->mdio);
> +       kfree(bitbang);
> +
> +       return 0;
> +}
> +
> +#ifdef CONFIG_OF_GPIO
> +static struct of_device_id mdio_ofgpio_match[] = {
> +       {
> +               .compatible = "virtual,mdio-gpio",
> +       },
> +       {},
> +};
> +
> +static struct of_platform_driver mdio_ofgpio_driver = {
> +       .name = "mdio-gpio",
> +       .match_table = mdio_ofgpio_match,
> +       .probe = mdio_ofgpio_probe,
> +       .remove = mdio_ofgpio_remove,
> +};
> +#else
> +static struct platform_driver mdio_gpio_driver = {
> +       .probe = mdio_gpio_probe,
> +       .remove = __devexit_p(mdio_gpio_remove),
> +       .driver         = {
> +               .name   = "mdio-gpio",
> +               .owner  = THIS_MODULE,
> +       },
> +};
> +#endif
> +
> +static int __init mdio_gpio_init(void)
> +{
> +#ifdef CONFIG_OF_GPIO
> +       return of_register_platform_driver(&mdio_ofgpio_driver);
> +#else
> +       return platform_driver_register(&mdio_gpio_driver);
> +#endif
> +}
> +module_init(mdio_gpio_init);
> +
> +static void __exit mdio_gpio_exit(void)
> +{
> +#ifdef CONFIG_OF_GPIO
> +       of_unregister_platform_driver(&mdio_ofgpio_driver);
> +#else
> +       platform_driver_unregister(&mdio_gpio_driver);
> +#endif
> +}
> +module_exit(mdio_gpio_exit);
> +
> +#ifndef CONFIG_OF_GPIO
> +MODULE_ALIAS("platform:mdio-gpio");
> +#endif
> +MODULE_AUTHOR("Laurent Pinchart, Paulius Zaleckas");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("Generic driver for MDIO bus emulation using GPIO");
> diff --git a/drivers/net/phy/mdio-ofgpio.c b/drivers/net/phy/mdio-ofgpio.c
> deleted file mode 100644
> index 2ff9775..0000000
> --- a/drivers/net/phy/mdio-ofgpio.c
> +++ /dev/null
> @@ -1,204 +0,0 @@
> -/*
> - * OpenFirmware GPIO based MDIO bitbang driver.
> - *
> - * Copyright (c) 2008 CSE Semaphore Belgium.
> - *  by Laurent Pinchart <laurentp@cse-semaphore.com>
> - *
> - * Based on earlier work by
> - *
> - * Copyright (c) 2003 Intracom S.A.
> - *  by Pantelis Antoniou <panto@intracom.gr>
> - *
> - * 2005 (c) MontaVista Software, Inc.
> - * Vitaly Bordug <vbordug@ru.mvista.com>
> - *
> - * This file is licensed under the terms of the GNU General Public License
> - * version 2. This program is licensed "as is" without any warranty of any
> - * kind, whether express or implied.
> - */
> -
> -#include <linux/module.h>
> -#include <linux/slab.h>
> -#include <linux/init.h>
> -#include <linux/interrupt.h>
> -#include <linux/mdio-bitbang.h>
> -#include <linux/of_gpio.h>
> -#include <linux/of_platform.h>
> -
> -struct mdio_gpio_info {
> -       struct mdiobb_ctrl ctrl;
> -       int mdc, mdio;
> -};
> -
> -static void mdio_dir(struct mdiobb_ctrl *ctrl, int dir)
> -{
> -       struct mdio_gpio_info *bitbang =
> -               container_of(ctrl, struct mdio_gpio_info, ctrl);
> -
> -       if (dir)
> -               gpio_direction_output(bitbang->mdio, 1);
> -       else
> -               gpio_direction_input(bitbang->mdio);
> -}
> -
> -static int mdio_read(struct mdiobb_ctrl *ctrl)
> -{
> -       struct mdio_gpio_info *bitbang =
> -               container_of(ctrl, struct mdio_gpio_info, ctrl);
> -
> -       return gpio_get_value(bitbang->mdio);
> -}
> -
> -static void mdio(struct mdiobb_ctrl *ctrl, int what)
> -{
> -       struct mdio_gpio_info *bitbang =
> -               container_of(ctrl, struct mdio_gpio_info, ctrl);
> -
> -       gpio_set_value(bitbang->mdio, what);
> -}
> -
> -static void mdc(struct mdiobb_ctrl *ctrl, int what)
> -{
> -       struct mdio_gpio_info *bitbang =
> -               container_of(ctrl, struct mdio_gpio_info, ctrl);
> -
> -       gpio_set_value(bitbang->mdc, what);
> -}
> -
> -static struct mdiobb_ops mdio_gpio_ops = {
> -       .owner = THIS_MODULE,
> -       .set_mdc = mdc,
> -       .set_mdio_dir = mdio_dir,
> -       .set_mdio_data = mdio,
> -       .get_mdio_data = mdio_read,
> -};
> -
> -static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
> -                                         struct device_node *np)
> -{
> -       struct mdio_gpio_info *bitbang = bus->priv;
> -
> -       bitbang->mdc = of_get_gpio(np, 0);
> -       bitbang->mdio = of_get_gpio(np, 1);
> -
> -       if (bitbang->mdc < 0 || bitbang->mdio < 0)
> -               return -ENODEV;
> -
> -       snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
> -       return 0;
> -}
> -
> -static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
> -{
> -       const u32 *data;
> -       int len, id, irq;
> -
> -       data = of_get_property(np, "reg", &len);
> -       if (!data || len != 4)
> -               return;
> -
> -       id = *data;
> -       bus->phy_mask &= ~(1 << id);
> -
> -       irq = of_irq_to_resource(np, 0, NULL);
> -       if (irq != NO_IRQ)
> -               bus->irq[id] = irq;
> -}
> -
> -static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> -                                        const struct of_device_id *match)
> -{
> -       struct device_node *np = NULL;
> -       struct mii_bus *new_bus;
> -       struct mdio_gpio_info *bitbang;
> -       int ret = -ENOMEM;
> -       int i;
> -
> -       bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> -       if (!bitbang)
> -               goto out;
> -
> -       bitbang->ctrl.ops = &mdio_gpio_ops;
> -
> -       new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
> -       if (!new_bus)
> -               goto out_free_bitbang;
> -
> -       new_bus->name = "GPIO Bitbanged MII",
> -
> -       ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
> -       if (ret)
> -               goto out_free_bus;
> -
> -       new_bus->phy_mask = ~0;
> -       new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> -       if (!new_bus->irq)
> -               goto out_free_bus;
> -
> -       for (i = 0; i < PHY_MAX_ADDR; i++)
> -               new_bus->irq[i] = -1;
> -
> -       while ((np = of_get_next_child(ofdev->node, np)))
> -               if (!strcmp(np->type, "ethernet-phy"))
> -                       add_phy(new_bus, np);
> -
> -       new_bus->parent = &ofdev->dev;
> -       dev_set_drvdata(&ofdev->dev, new_bus);
> -
> -       ret = mdiobus_register(new_bus);
> -       if (ret)
> -               goto out_free_irqs;
> -
> -       return 0;
> -
> -out_free_irqs:
> -       dev_set_drvdata(&ofdev->dev, NULL);
> -       kfree(new_bus->irq);
> -out_free_bus:
> -       free_mdio_bitbang(new_bus);
> -out_free_bitbang:
> -       kfree(bitbang);
> -out:
> -       return ret;
> -}
> -
> -static int mdio_ofgpio_remove(struct of_device *ofdev)
> -{
> -       struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
> -       struct mdio_gpio_info *bitbang = bus->priv;
> -
> -       mdiobus_unregister(bus);
> -       kfree(bus->irq);
> -       free_mdio_bitbang(bus);
> -       dev_set_drvdata(&ofdev->dev, NULL);
> -       kfree(bitbang);
> -
> -       return 0;
> -}
> -
> -static struct of_device_id mdio_ofgpio_match[] = {
> -       {
> -               .compatible = "virtual,mdio-gpio",
> -       },
> -       {},
> -};
> -
> -static struct of_platform_driver mdio_ofgpio_driver = {
> -       .name = "mdio-gpio",
> -       .match_table = mdio_ofgpio_match,
> -       .probe = mdio_ofgpio_probe,
> -       .remove = mdio_ofgpio_remove,
> -};
> -
> -static int mdio_ofgpio_init(void)
> -{
> -       return of_register_platform_driver(&mdio_ofgpio_driver);
> -}
> -
> -static void mdio_ofgpio_exit(void)
> -{
> -       of_unregister_platform_driver(&mdio_ofgpio_driver);
> -}
> -
> -module_init(mdio_ofgpio_init);
> -module_exit(mdio_ofgpio_exit);
> diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
> new file mode 100644
> index 0000000..5ca24ed
> --- /dev/null
> +++ b/include/linux/mdio-gpio.h
> @@ -0,0 +1,30 @@
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
> +struct mdio_gpio_phy {
> +       /* PHY address on MDIO bus */
> +       unsigned int addr;
> +       /* preconfigured irq connected to PHY or -1 if no irq */
> +       int irq;
> +};
> +
> +struct mdio_gpio_platform_data {
> +       /* GPIO numbers for bus pins */
> +       unsigned int mdc;
> +       unsigned int mdio;
> +
> +       unsigned int nr_phys;
> +       struct mdio_gpio_phy *phys;
> +};
> +
> +#endif /* __LINUX_MDIO_GPIO_H */
>
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
