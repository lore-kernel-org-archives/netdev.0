From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] phylib: make mdio-gpio work without OF
Date: Fri, 31 Oct 2008 11:18:26 -0600
Message-ID: <fa686aa40810311018q71248550oa65a5f20ff3bb8fe@mail.gmail.com>
References: <20081031164132.20490.27608.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <20081031164934.20490.67539.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	"Laurent Pinchart" <laurentp@cse-semaphore.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:63302 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbYJaRS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 13:18:27 -0400
In-Reply-To: <20081031164934.20490.67539.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 10:49 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> make mdio-gpio work with non OpenFirmware gpio implementation.
>

Looking good, but it has too many #ifdef blocks for my taste.  In
particular, if the driver is refactored a bit then all the OF stuff
can be contained within a single ifdef block, as can all the non-OF
stuff.  Comments below...

> +#ifdef CONFIG_OF_GPIO
>  static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
>                                          struct device_node *np)
>  {
> @@ -87,34 +102,60 @@ static int __devinit mdio_ofgpio_bitbang_init(struct mii_bus *bus,
>        snprintf(bus->id, MII_BUS_ID_SIZE, "%x", bitbang->mdc);
>        return 0;
>  }
> -
> -static void __devinit add_phy(struct mii_bus *bus, struct device_node *np)
> +#else
> +static void __devinit mdio_gpio_bitbang_init(struct mii_bus *bus,
> +                                        struct mdio_gpio_platform_data *pdata,
> +                                       int bus_id)
>  {
> -       const u32 *data;
> -       int len, id, irq;
> +       struct mdio_gpio_info *bitbang = bus->priv;
> +
> +       bitbang->mdc = pdata->mdc;
> +       bitbang->mdio = pdata->mdio;
> +
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "phy%i", bus_id);
> +}
> +#endif

mdio_ofgpio_bitbang_init() is such short function and it is only
called once inside the probe() function.  Rather than duplicate it, it
can probably be moved inside the OF probe function and do the same
thing for the non-OF probe().

>
> -       data = of_get_property(np, "reg", &len);
> -       if (!data || len != 4)
> +static void __devinit add_phy(struct mii_bus *bus, unsigned int phy_addr,
> +                             int phy_irq)
> +{
> +       if (phy_addr >= PHY_MAX_ADDR) {
> +               dev_err(bus->parent,
> +                       "Failed to add phy with invalid address: 0x%x",
> +                       phy_addr);
>                return;
> +       }
>
> -       id = *data;
> -       bus->phy_mask &= ~(1 << id);
> +       bus->phy_mask &= ~(1 << phy_addr);
>
> -       irq = of_irq_to_resource(np, 0, NULL);
> -       if (irq != NO_IRQ)
> -               bus->irq[id] = irq;
> +       if (phy_irq != NO_IRQ)
> +               bus->irq[phy_addr] = phy_irq;
>  }

I like the refactoring of add_phy

>
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

Instead of doing multiple #ifdef sections throughout the probe
function, use one #ifdef block for the OF stuff and another for all
the non-OF stuff.  You can factor out any non-trivial common code
blocks into shared helper functions.

Otherwise, looking good.

Thanks,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
