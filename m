From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2] phylib: rename mdio-ofgpio to mdio-gpio
Date: Fri, 31 Oct 2008 10:52:34 -0600
Message-ID: <fa686aa40810310952k1b82099dhe5f32c848505e0c5@mail.gmail.com>
References: <20081031164132.20490.27608.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <20081031164924.20490.44681.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20081031164924.20490.44681.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 31, 2008 at 10:49 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Cc: Laurent Pinchart <laurentp@cse-semaphore.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Mike Frysinger <vapier.adi@gmail.com>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
>
>  drivers/net/phy/Kconfig       |    2
>  drivers/net/phy/Makefile      |    2
>  drivers/net/phy/mdio-gpio.c   |  204 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/mdio-ofgpio.c |  204 -----------------------------------------
>  4 files changed, 206 insertions(+), 206 deletions(-)
>  create mode 100644 drivers/net/phy/mdio-gpio.c
>  delete mode 100644 drivers/net/phy/mdio-ofgpio.c
>
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index d55932a..0318077 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -84,7 +84,7 @@ config MDIO_BITBANG
>
>          If in doubt, say N.
>
> -config MDIO_OF_GPIO
> +config MDIO_GPIO
>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
>        depends on MDIO_BITBANG && OF_GPIO
>        ---help---
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
> index 0000000..2ff9775
> --- /dev/null
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -0,0 +1,204 @@
> +/*
> + * OpenFirmware GPIO based MDIO bitbang driver.
> + *
> + * Copyright (c) 2008 CSE Semaphore Belgium.
> + *  by Laurent Pinchart <laurentp@cse-semaphore.com>
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
> +#include <linux/of_gpio.h>
> +#include <linux/of_platform.h>
> +
> +struct mdio_gpio_info {
> +       struct mdiobb_ctrl ctrl;
> +       int mdc, mdio;
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
> +static int mdio_read(struct mdiobb_ctrl *ctrl)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       return gpio_get_value(bitbang->mdio);
> +}
> +
> +static void mdio(struct mdiobb_ctrl *ctrl, int what)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       gpio_set_value(bitbang->mdio, what);
> +}
> +
> +static void mdc(struct mdiobb_ctrl *ctrl, int what)
> +{
> +       struct mdio_gpio_info *bitbang =
> +               container_of(ctrl, struct mdio_gpio_info, ctrl);
> +
> +       gpio_set_value(bitbang->mdc, what);
> +}
> +
> +static struct mdiobb_ops mdio_gpio_ops = {
> +       .owner = THIS_MODULE,
> +       .set_mdc = mdc,
> +       .set_mdio_dir = mdio_dir,
> +       .set_mdio_data = mdio,
> +       .get_mdio_data = mdio_read,
> +};
> +
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
> +
> +static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
> +{
> +       const u32 *data;
> +       int len, id, irq;
> +
> +       data = of_get_property(np, "reg", &len);
> +       if (!data || len != 4)
> +               return;
> +
> +       id = *data;
> +       bus->phy_mask &= ~(1 << id);
> +
> +       irq = of_irq_to_resource(np, 0, NULL);
> +       if (irq != NO_IRQ)
> +               bus->irq[id] = irq;
> +}
> +
> +static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> +                                        const struct of_device_id *match)
> +{
> +       struct device_node *np = NULL;
> +       struct mii_bus *new_bus;
> +       struct mdio_gpio_info *bitbang;
> +       int ret = -ENOMEM;
> +       int i;
> +
> +       bitbang = kzalloc(sizeof(struct mdio_gpio_info), GFP_KERNEL);
> +       if (!bitbang)
> +               goto out;
> +
> +       bitbang->ctrl.ops = &mdio_gpio_ops;
> +
> +       new_bus = alloc_mdio_bitbang(&bitbang->ctrl);
> +       if (!new_bus)
> +               goto out_free_bitbang;
> +
> +       new_bus->name = "GPIO Bitbanged MII",
> +
> +       ret = mdio_ofgpio_bitbang_init(new_bus, ofdev->node);
> +       if (ret)
> +               goto out_free_bus;
> +
> +       new_bus->phy_mask = ~0;
> +       new_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +       if (!new_bus->irq)
> +               goto out_free_bus;
> +
> +       for (i = 0; i < PHY_MAX_ADDR; i++)
> +               new_bus->irq[i] = -1;
> +
> +       while ((np = of_get_next_child(ofdev->node, np)))
> +               if (!strcmp(np->type, "ethernet-phy"))
> +                       add_phy(new_bus, np);
> +
> +       new_bus->parent = &ofdev->dev;
> +       dev_set_drvdata(&ofdev->dev, new_bus);
> +
> +       ret = mdiobus_register(new_bus);
> +       if (ret)
> +               goto out_free_irqs;
> +
> +       return 0;
> +
> +out_free_irqs:
> +       dev_set_drvdata(&ofdev->dev, NULL);
> +       kfree(new_bus->irq);
> +out_free_bus:
> +       free_mdio_bitbang(new_bus);
> +out_free_bitbang:
> +       kfree(bitbang);
> +out:
> +       return ret;
> +}
> +
> +static int mdio_ofgpio_remove(struct of_device *ofdev)
> +{
> +       struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
> +       struct mdio_gpio_info *bitbang = bus->priv;
> +
> +       mdiobus_unregister(bus);
> +       kfree(bus->irq);
> +       free_mdio_bitbang(bus);
> +       dev_set_drvdata(&ofdev->dev, NULL);
> +       kfree(bitbang);
> +
> +       return 0;
> +}
> +
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
> +
> +static int mdio_ofgpio_init(void)
> +{
> +       return of_register_platform_driver(&mdio_ofgpio_driver);
> +}
> +
> +static void mdio_ofgpio_exit(void)
> +{
> +       of_unregister_platform_driver(&mdio_ofgpio_driver);
> +}
> +
> +module_init(mdio_ofgpio_init);
> +module_exit(mdio_ofgpio_exit);
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
>
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
