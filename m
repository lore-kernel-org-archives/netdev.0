From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: make mdio-gpio work without OF (v2)
Date: Tue, 4 Nov 2008 09:24:29 -0700
Message-ID: <fa686aa40811040824x52dab7fel9f76567cb6d49c8@mail.gmail.com>
References: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:1285 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbYKDQYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 11:24:30 -0500
In-Reply-To: <20081104144518.4429.37325.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2008 at 7:45 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
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
> Changes since v1:
> - removed NO_IRQ
> - reduced #idefs

I like this better, but I have a few more comments below.  I'd like to
see the #ifdefs reduced even more.

> +#ifdef CONFIG_OF_GPIO
>  static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
>                                         const struct of_device_id *match)
>  {
>        struct device_node *np = NULL;
> +       struct device *dev = &ofdev->dev;
> +#else
> +static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> +{
> +       struct mdio_gpio_platform_data *pdata;
> +       struct device *dev = &pdev->dev;
> +#endif

At this point, instead of #ifdeffing the function signature, I would
much rather see this generalized as something like
'mdio_gpio_setup()'.  Then move the OF and non-OF specific bits into
two new functions; mdio_ofgpio_probe() and mdio_gpio_probe().  The two
new functions should be placed with the appropriate bus binding in the
#ifdef/#else block at the bottom of the file.

Separating it in this way will keep the two separate binding code
paths easier to read and understand.

> +#ifdef CONFIG_OF_GPIO
> +       bitbang->mdc = of_get_gpio(ofdev->node, 0);
> +       bitbang->mdio = of_get_gpio(ofdev->node, 1);
> +
> +       if (bitbang->mdc < 0 || bitbang->mdio < 0)
> +               goto out_free_bus;
> +
> +       snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
>
>        while ((np = of_get_next_child(ofdev->node, np)))
> -               if (!strcmp(np->type, "ethernet-phy"))
> -                       add_phy(new_bus, np);
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
> +       pdata = dev->platform_data;
> +       if (pdata == NULL)
> +               goto out_free_bus;
> +
> +       bitbang->mdc = pdata->mdc;
> +       bitbang->mdio = pdata->mdio;
>
> -       new_bus->parent = &ofdev->dev;
> -       dev_set_drvdata(&ofdev->dev, new_bus);
> +       snprintf(new_bus->id, MII_BUS_ID_SIZE, "phy%i", pdev->id);
> +
> +       for (i = 0; i < pdata->nr_phys; i++)
> +               add_phy(new_bus, pdata->phys[i].addr, pdata->phys[i].irq);
> +#endif

These are the bits to factor out into binding specific probe()
functions.  I want to see the data interpretation code (probe)
separated from the driver setup code.

Otherwise, this looks good to me.

g.

> +
> +       if (new_bus->phy_mask == ~0)
> +               goto out_free_bus;
> +
> +       if (gpio_request(bitbang->mdc, "mdc"))
> +               goto out_free_bus;
> +
> +       if (gpio_request(bitbang->mdio, "mdio"))
> +               goto out_free_mdc;
> +
> +       dev_set_drvdata(dev, new_bus);
>
>        ret = mdiobus_register(new_bus);
>        if (ret)
> -               goto out_free_irqs;
> +               goto out_free_all;
>
>        return 0;
>
> -out_free_irqs:
> -       dev_set_drvdata(&ofdev->dev, NULL);
> -       kfree(new_bus->irq);
> +out_free_all:
> +       dev_set_drvdata(dev, NULL);
> +       gpio_free(bitbang->mdio);
> +out_free_mdc:
> +       gpio_free(bitbang->mdc);
>  out_free_bus:
>        free_mdio_bitbang(new_bus);
>  out_free_bitbang:
> @@ -162,20 +202,29 @@ out:
>        return ret;
>  }
>
> +#ifdef CONFIG_OF_GPIO
>  static int mdio_ofgpio_remove(struct of_device *ofdev)
>  {
> -       struct mii_bus *bus = dev_get_drvdata(&ofdev->dev);
> +       struct device *dev = &ofdev->dev;
> +#else
> +static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> +{
> +       struct device *dev = &pdev->dev;
> +#endif

Ditto here my comments on the probe functions; create binding specific
*_remove() functions and refactor this into a common
mdio_gpio_teardown() function.

> +       struct mii_bus *bus = dev_get_drvdata(dev);
>        struct mdio_gpio_info *bitbang = bus->priv;
>
>        mdiobus_unregister(bus);
> -       kfree(bus->irq);
>        free_mdio_bitbang(bus);
> -       dev_set_drvdata(&ofdev->dev, NULL);
> +       dev_set_drvdata(dev, NULL);
> +       gpio_free(bitbang->mdc);
> +       gpio_free(bitbang->mdio);
>        kfree(bitbang);
>
>        return 0;
>  }
>
> +#ifdef CONFIG_OF_GPIO
>  static struct of_device_id mdio_ofgpio_match[] = {
>        {
>                .compatible = "virtual,mdio-gpio",
> @@ -190,15 +239,42 @@ static struct of_platform_driver mdio_ofgpio_driver = {
>        .remove = mdio_ofgpio_remove,
>  };
>
> -static int mdio_ofgpio_init(void)
> +static int __init mdio_ofgpio_init(void)
>  {
>        return of_register_platform_driver(&mdio_ofgpio_driver);
>  }
> +module_init(mdio_ofgpio_init);
>
> -static void mdio_ofgpio_exit(void)
> +static void __exit mdio_ofgpio_exit(void)
>  {
>        of_unregister_platform_driver(&mdio_ofgpio_driver);
>  }
> -
> -module_init(mdio_ofgpio_init);
>  module_exit(mdio_ofgpio_exit);
> +#else
> +static struct platform_driver mdio_gpio_driver = {
> +       .probe = mdio_gpio_probe,
> +       .remove = __devexit_p(mdio_gpio_remove),
> +       .driver         = {
> +               .name   = "mdio-gpio",
> +               .owner  = THIS_MODULE,
> +       },
> +};
> +
> +static int __init mdio_gpio_init(void)
> +{
> +       return platform_driver_register(&mdio_gpio_driver);
> +}
> +module_init(mdio_gpio_init);
> +
> +static void __exit mdio_gpio_exit(void)
> +{
> +       platform_driver_unregister(&mdio_gpio_driver);
> +}
> +module_exit(mdio_gpio_exit);
> +
> +MODULE_ALIAS("platform:mdio-gpio");
> +#endif /* CONFIG_OF_GPIO */
> +
> +MODULE_AUTHOR("Laurent Pinchart, Paulius Zaleckas");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("Generic driver for MDIO bus emulation using GPIO");
> diff --git a/include/linux/mdio-gpio.h b/include/linux/mdio-gpio.h
> new file mode 100644
> index 0000000..6a8258d
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
> +       /* preconfigured irq connected to PHY */
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
