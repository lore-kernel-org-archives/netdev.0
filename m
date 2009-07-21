From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH v2] net: Rework mdio-ofgpio driver to use of_mdio
	infrastructure
Date: Tue, 21 Jul 2009 11:09:46 -0600
Message-ID: <fa686aa40907211009o473020e2wb0ea79130b6f1d09@mail.gmail.com>
References: <4A646117.1030409@elphinstone.net> <fa686aa40907200759h1e4ec8cfh8a35890127a899a1@mail.gmail.com>
	<4A658F69.7020002@elphinstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev <linuxppc-dev@ozlabs.org>,
	David Miller <davem@davemloft.net>
To: Mark Ware <mware@elphinstone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:30891 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbZGURKH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 13:10:07 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1266317qwh.37
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 10:10:06 -0700 (PDT)
In-Reply-To: <4A658F69.7020002@elphinstone.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 21, 2009 at 3:50 AM, Mark Ware<mware@elphinstone.net> wrote=
:
> Changes to the fs_enet driver (aa73832c5a80d6c52c69b18af858d88fa595dd=
3c)
> cause kernel crashes when using the mdio-ofgpio driver.
>
> The following patch replicates similar changes made to the fs_enet
> mii-bitbang drivers.

This looks good to me.  I've not tested it though (no hardware that
uses it).  You should specify the testing you've done in the commit
log.  Your signed-off-by: line is also missing.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

David, once the above issues are solved, this one needs to be merged fo=
r 2.6.31.

Cheers,
g.

> ---
>
> This version attempts to address Grant's comments below:
>
> Grant Likely wrote:
>>
>> You should refactor mdio_gpio_bus_init() to not call
>> mdiobus_register() at all, and instead just return a pointer to the
>> unregistered new_bus. =A0Then mdio_gpio_probe() and mdio_ofgpio_prob=
e()
>> can call the correct register variant directly. =A0Fewer ugly #ifdef=
s
>> this way. =A0It also eliminates the need to cast the void* pointer.
>>
>
> =A0drivers/net/phy/mdio-gpio.c | =A0 77
> ++++++++++++++++++++-----------------------
> =A01 files changed, 36 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.=
c
> index 33984b7..22cdd45 100644
> --- a/drivers/net/phy/mdio-gpio.c
> +++ b/drivers/net/phy/mdio-gpio.c
> @@ -30,6 +30,7 @@
>
> =A0#ifdef CONFIG_OF_GPIO
> =A0#include <linux/of_gpio.h>
> +#include <linux/of_mdio.h>
> =A0#include <linux/of_platform.h>
> =A0#endif
>
> @@ -81,13 +82,12 @@ static struct mdiobb_ops mdio_gpio_ops =3D {
> =A0 =A0 =A0 =A0.get_mdio_data =3D mdio_get,
> =A0};
>
> -static int __devinit mdio_gpio_bus_init(struct device *dev,
> +static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *=
dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct mdio_gpio_platform_data
> *pdata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0int bus_id)
> =A0{
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct mdio_gpio_info *bitbang;
> - =A0 =A0 =A0 int ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0bitbang =3D kzalloc(sizeof(*bitbang), GFP_KERNEL);
> @@ -104,8 +104,6 @@ static int __devinit mdio_gpio_bus_init(struct de=
vice
> *dev,
>
> =A0 =A0 =A0 =A0new_bus->name =3D "GPIO Bitbanged MDIO",
>
> - =A0 =A0 =A0 ret =3D -ENODEV;
> -
> =A0 =A0 =A0 =A0new_bus->phy_mask =3D pdata->phy_mask;
> =A0 =A0 =A0 =A0new_bus->irq =3D pdata->irqs;
> =A0 =A0 =A0 =A0new_bus->parent =3D dev;
> @@ -129,15 +127,8 @@ static int __devinit mdio_gpio_bus_init(struct d=
evice
> *dev,
>
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, new_bus);
>
> - =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> - =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_all;
> -
> - =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 return new_bus;
>
> -out_free_all:
> - =A0 =A0 =A0 dev_set_drvdata(dev, NULL);
> - =A0 =A0 =A0 gpio_free(bitbang->mdio);
> =A0out_free_mdc:
> =A0 =A0 =A0 =A0gpio_free(bitbang->mdc);
> =A0out_free_bus:
> @@ -145,30 +136,47 @@ out_free_bus:
> =A0out_free_bitbang:
> =A0 =A0 =A0 =A0kfree(bitbang);
> =A0out:
> - =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 return NULL;
> =A0}
>
> -static void __devexit mdio_gpio_bus_destroy(struct device *dev)
> +static void __devinit mdio_gpio_bus_deinit(struct device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct mii_bus *bus =3D dev_get_drvdata(dev);
> =A0 =A0 =A0 =A0struct mdio_gpio_info *bitbang =3D bus->priv;
>
> - =A0 =A0 =A0 mdiobus_unregister(bus);
> - =A0 =A0 =A0 free_mdio_bitbang(bus);
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, NULL);
> - =A0 =A0 =A0 gpio_free(bitbang->mdc);
> =A0 =A0 =A0 =A0gpio_free(bitbang->mdio);
> + =A0 =A0 =A0 gpio_free(bitbang->mdc);
> + =A0 =A0 =A0 free_mdio_bitbang(bus);
> =A0 =A0 =A0 =A0kfree(bitbang);
> =A0}
>
> +static void __devexit mdio_gpio_bus_destroy(struct device *dev)
> +{
> + =A0 =A0 =A0 struct mii_bus *bus =3D dev_get_drvdata(dev);
> +
> + =A0 =A0 =A0 mdiobus_unregister(bus);
> + =A0 =A0 =A0 mdio_gpio_bus_deinit(dev);
> +}
> +
> =A0static int __devinit mdio_gpio_probe(struct platform_device *pdev)
> =A0{
> =A0 =A0 =A0 =A0struct mdio_gpio_platform_data *pdata =3D pdev->dev.pl=
atform_data;
> + =A0 =A0 =A0 struct mii_bus *new_bus;
> + =A0 =A0 =A0 int ret;
>
> =A0 =A0 =A0 =A0if (!pdata)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>
> - =A0 =A0 =A0 return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
> + =A0 =A0 =A0 new_bus =3D mdio_gpio_bus_init(&pdev->dev, pdata, pdev-=
>id);
> + =A0 =A0 =A0 if (!new_bus)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> + =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio_gpio_bus_deinit(&pdev->dev);
> +
> + =A0 =A0 =A0 return ret;
> =A0}
>
> =A0static int __devexit mdio_gpio_remove(struct platform_device *pdev=
)
> @@ -179,29 +187,12 @@ static int __devexit mdio_gpio_remove(struct
> platform_device *pdev)
> =A0}
>
> =A0#ifdef CONFIG_OF_GPIO
> -static void __devinit add_phy(struct mdio_gpio_platform_data *pdata,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct devi=
ce_node *np)
> -{
> - =A0 =A0 =A0 const u32 *data;
> - =A0 =A0 =A0 int len, id, irq;
> -
> - =A0 =A0 =A0 data =3D of_get_property(np, "reg", &len);
> - =A0 =A0 =A0 if (!data || len !=3D 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 id =3D *data;
> - =A0 =A0 =A0 pdata->phy_mask &=3D ~(1 << id);
> -
> - =A0 =A0 =A0 irq =3D of_irq_to_resource(np, 0, NULL);
> - =A0 =A0 =A0 if (irq)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->irqs[id] =3D irq;
> -}
>
> =A0static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 const struct of_device_id *match)
> =A0{
> - =A0 =A0 =A0 struct device_node *np =3D NULL;
> =A0 =A0 =A0 =A0struct mdio_gpio_platform_data *pdata;
> + =A0 =A0 =A0 struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0pdata =3D kzalloc(sizeof(*pdata), GFP_KERNEL);
> @@ -215,14 +206,18 @@ static int __devinit mdio_ofgpio_probe(struct
> of_device *ofdev,
>
> =A0 =A0 =A0 =A0ret =3D of_get_gpio(ofdev->node, 1);
> =A0 =A0 =A0 =A0if (ret < 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
> =A0 =A0 =A0 =A0pdata->mdio =3D ret;
>
> - =A0 =A0 =A0 while ((np =3D of_get_next_child(ofdev->node, np)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(np->type, "ethernet-phy"))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_phy(pdata, np);
> + =A0 =A0 =A0 new_bus =3D mdio_gpio_bus_init(&ofdev->dev, pdata, pdat=
a->mdc);
> + =A0 =A0 =A0 if (!new_bus)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>
> - =A0 =A0 =A0 return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->md=
c);
> + =A0 =A0 =A0 ret =3D of_mdiobus_register(new_bus, ofdev->node);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio_gpio_bus_deinit(&ofdev->dev);
> +
> + =A0 =A0 =A0 return ret;
>
> =A0out_free:
> =A0 =A0 =A0 =A0kfree(pdata);
> --
> 1.5.6.5
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
