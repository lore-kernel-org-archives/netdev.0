From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC/PATCH] net: Rework mdio-ofgpio driver to use of_mdio
	infrastructure
Date: Mon, 20 Jul 2009 08:59:31 -0600
Message-ID: <fa686aa40907200759h1e4ec8cfh8a35890127a899a1@mail.gmail.com>
References: <4A646117.1030409@elphinstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linuxppc-dev <linuxppc-dev@ozlabs.org>
To: Mark Ware <mware@elphinstone.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4A646117.1030409@elphinstone.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

(adding cc:linuxppc-dev@ozlabs.org)

On Mon, Jul 20, 2009 at 6:20 AM, Mark Ware<mware@elphinstone.net> wrote:
> Changes to the fs_enet driver (aa73832c5a80d6c52c69b18af858d88fa595dd3c)
> cause kernel crashes when using the mdio-ofgpio driver.
>
> The following patch is a fairly naive attempt to replicate similar changes
> made to the fs_enet mii-bitbang drivers.

For a naive attempt, it's really quite good.  However, I'd do it
slightly differently.

You should refactor mdio_gpio_bus_init() to not call
mdiobus_register() at all, and instead just return a pointer to the
unregistered new_bus.  Then mdio_gpio_probe() and mdio_ofgpio_probe()
can call the correct register variant directly.  Fewer ugly #ifdefs
this way.  It also eliminates the need to cast the void* pointer.

Thanks for catching this.

g.

> =A0drivers/net/phy/mdio-gpio.c | =A0 39 +++++++++++++--------------------=
------
> =A01 files changed, 13 insertions(+), 26 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
> index 33984b7..6568176 100644
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
> @@ -83,7 +84,8 @@ static struct mdiobb_ops mdio_gpio_ops =3D {
>
> =A0static int __devinit mdio_gpio_bus_init(struct device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct mdio_gpio_platform_data
> *pdata,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int bus_id)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int bus_id,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *ofdev)
> =A0{
> =A0 =A0 =A0 =A0struct mii_bus *new_bus;
> =A0 =A0 =A0 =A0struct mdio_gpio_info *bitbang;
> @@ -129,7 +131,14 @@ static int __devinit mdio_gpio_bus_init(struct device
> *dev,
>
> =A0 =A0 =A0 =A0dev_set_drvdata(dev, new_bus);
>
> - =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> +#ifdef CONFIG_OF_GPIO
> + =A0 =A0if (ofdev)
> + =A0 =A0 =A0 =A0ret =3D of_mdiobus_register(new_bus, ((struct of_device =
*)
> ofdev)->node);
> + =A0 =A0else
> +#else
> + =A0 =A0 =A0 =A0 =A0 ret =3D mdiobus_register(new_bus);
> +#endif
> +
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_all;
>
> @@ -168,7 +177,7 @@ static int __devinit mdio_gpio_probe(struct
> platform_device *pdev)
> =A0 =A0 =A0 =A0if (!pdata)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>
> - =A0 =A0 =A0 return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id);
> + =A0 =A0 =A0 return mdio_gpio_bus_init(&pdev->dev, pdata, pdev->id, NULL=
);
> =A0}
>
> =A0static int __devexit mdio_gpio_remove(struct platform_device *pdev)
> @@ -179,28 +188,10 @@ static int __devexit mdio_gpio_remove(struct
> platform_device *pdev)
> =A0}
>
> =A0#ifdef CONFIG_OF_GPIO
> -static void __devinit add_phy(struct mdio_gpio_platform_data *pdata,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_n=
ode *np)
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
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 const struct of_device_id *match)
> =A0{
> - =A0 =A0 =A0 struct device_node *np =3D NULL;
> =A0 =A0 =A0 =A0struct mdio_gpio_platform_data *pdata;
> =A0 =A0 =A0 =A0int ret;
>
> @@ -218,11 +209,7 @@ static int __devinit mdio_ofgpio_probe(struct of_dev=
ice
> *ofdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free;
> =A0 =A0 =A0 =A0pdata->mdio =3D ret;
>
> - =A0 =A0 =A0 while ((np =3D of_get_next_child(ofdev->node, np)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(np->type, "ethernet-phy"))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_phy(pdata, np);
> -
> - =A0 =A0 =A0 return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc);
> + =A0 =A0 =A0 return mdio_gpio_bus_init(&ofdev->dev, pdata, pdata->mdc, o=
fdev);
>
> =A0out_free:
> =A0 =A0 =A0 =A0kfree(pdata);
> --
> 1.5.6.5
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
