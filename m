From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 1/4] phylib: Add device reset GPIO support
Date: Fri, 20 Oct 2017 11:11:17 -0700
Message-ID: <2dacbfaf-ce5e-f113-9ae8-641441d99bbc@gmail.com>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
 <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/2017 01:14 AM, Geert Uytterhoeven wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> The PHY devices sometimes do have their reset signal (maybe even power
> supply?) tied to some GPIO and sometimes it also does happen that a boot
> loader does not leave it deasserted. So far this issue has been attacked
> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
> the GPIO in question; that solution, when applied to the device trees, led
> to adding the PHY reset GPIO properties to the MAC device node, with one
> exception: Cadence MACB driver which could handle the "reset-gpios" prop
> in a PHY device subnode. I believe that the correct approach is to teach
> the 'phylib' to get the MDIO device reset GPIO from the device tree node
> corresponding to this device -- which this patch is doing...
> 
> Note that I had to modify the AT803x PHY driver as it would stop working
> otherwise -- it made use of the reset GPIO for its own purposes...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Acked-by: Rob Herring <robh@kernel.org>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

This is a new patch as far as PHYLIB is concerned, so not quite accurate
anymore. Thanks for picking that up, this looks good, with a few minor
things here and there.

> [geert: Propagate actual errors from fwnode_get_named_gpiod()]
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> This has gained a dependency on "[PATCH v2] of_mdio: Fix broken PHY IRQ
> in case of probe deferral"
> (https://www.spinics.net/lists/linux-renesas-soc/msg19442.html), as v3
> needs to propagate errors from of_mdiobus_register_phy() and
> of_mdiobus_register_device() [*].
> 
> v3:
>   - Fix fwnode_get_named_gpiod() call due to added parameters (which
>     allowed to eliminate the gpiod_direction_output() call),
>   - Undelete one blank line in the AT803x driver,
>   - Resolve rejects, refresh patch,
>   - Reword/reformat changelog,
>   - Take over from Sergei,
>   - Add Acked-by,
>   - Remove unneeded gpiod check, as gpiod_set_value() handles NULL fine,
>   - Handle fwnode_get_named_gpiod() errors correctly:
>       - -ENOENT is ignored (the GPIO is optional), and turned into NULL,
> 	which allowed to remove all later !IS_ERR() checks,
>       - Other errors (incl. -EPROBE_DEFER) are propagated [*],
> 
> v2:
>   - Reformat changelog,
>   - Resolve rejects, refresh patch.
> ---
>  Documentation/devicetree/bindings/net/phy.txt |  2 ++
>  drivers/net/phy/at803x.c                      | 18 +++------------
>  drivers/net/phy/mdio_bus.c                    |  4 ++++
>  drivers/net/phy/mdio_device.c                 | 26 +++++++++++++++++++--
>  drivers/net/phy/phy_device.c                  | 33 +++++++++++++++++++++++++--
>  drivers/of/of_mdio.c                          | 23 +++++++++++++++++++
>  include/linux/mdio.h                          |  3 +++
>  include/linux/phy.h                           |  5 ++++
>  8 files changed, 95 insertions(+), 19 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index 77d0b2a61ffa96fc..c05479f5ac7cc837 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -53,6 +53,8 @@ Optional Properties:
>    to ensure the integrated PHY is used. The absence of this property indicates
>    the muxers should be configured so that the external PHY is used.
>  
> +- reset-gpios: The GPIO phandle and specifier for the PHY reset signal.
> +
>  Example:
>  
>  ethernet-phy@0 {
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 5f93e6add56394f2..15b4560aeb5de759 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c

You most certainly want to make the conversion of the at803x.c driver as
a separate patch, there is no reason why it should be folded within the
patch teaching PHYLIB about PHY reset through GPIOs. More on that below.

> @@ -71,7 +71,6 @@ MODULE_LICENSE("GPL");
>  
>  struct at803x_priv {
>  	bool phy_reset:1;
> -	struct gpio_desc *gpiod_reset;
>  };
>  
>  struct at803x_context {
> @@ -254,22 +253,11 @@ static int at803x_probe(struct phy_device *phydev)
>  {
>  	struct device *dev = &phydev->mdio.dev;
>  	struct at803x_priv *priv;
> -	struct gpio_desc *gpiod_reset;
>  
>  	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
>  	if (!priv)
>  		return -ENOMEM;
>  
> -	if (phydev->drv->phy_id != ATH8030_PHY_ID)
> -		goto does_not_require_reset_workaround;

We have lost that bit now, see below.

> -
> -	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
> -	if (IS_ERR(gpiod_reset))
> -		return PTR_ERR(gpiod_reset);
> -
> -	priv->gpiod_reset = gpiod_reset;
> -
> -does_not_require_reset_workaround:
>  	phydev->priv = priv;
>  
>  	return 0;
> @@ -343,14 +331,14 @@ static void at803x_link_change_notify(struct phy_device *phydev)
>  	 * cannot recover from by software.
>  	 */
>  	if (phydev->state == PHY_NOLINK) {
> -		if (priv->gpiod_reset && !priv->phy_reset) {
> +		if (phydev->mdio.reset && !priv->phy_reset) {

and phydev->drv->phy_id == ATH8030_PHY_ID, the workaround is not
applicable to all PHY devices.

>  			struct at803x_context context;
>  
>  			at803x_context_save(phydev, &context);
>  
> -			gpiod_set_value(priv->gpiod_reset, 1);
> +			phy_device_reset(phydev, 1);
>  			msleep(1);
> -			gpiod_set_value(priv->gpiod_reset, 0);
> +			phy_device_reset(phydev, 0);
>  			msleep(1);
>  
>  			at803x_context_restore(phydev, &context);
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 2df7b62c1a36811e..da6e5366d641a416 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -38,6 +38,7 @@
>  #include <linux/phy.h>
>  #include <linux/io.h>
>  #include <linux/uaccess.h>
> +#include <linux/gpio/consumer.h>
>  
>  #include <asm/irq.h>
>  
> @@ -420,6 +421,9 @@ void mdiobus_unregister(struct mii_bus *bus)
>  		if (!mdiodev)
>  			continue;
>  
> +		if (mdiodev->reset)
> +			gpiod_put(mdiodev->reset);
> +
>  		mdiodev->device_remove(mdiodev);
>  		mdiodev->device_free(mdiodev);
>  	}
> diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
> index e24f28924af8953d..6926db11ae888174 100644
> --- a/drivers/net/phy/mdio_device.c
> +++ b/drivers/net/phy/mdio_device.c
> @@ -12,6 +12,8 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/errno.h>
> +#include <linux/gpio.h>
> +#include <linux/gpio/consumer.h>
>  #include <linux/init.h>
>  #include <linux/interrupt.h>
>  #include <linux/kernel.h>
> @@ -114,6 +116,12 @@ void mdio_device_remove(struct mdio_device *mdiodev)
>  }
>  EXPORT_SYMBOL(mdio_device_remove);
>  
> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
> +{
> +	gpiod_set_value(mdiodev->reset, value);
> +}
> +EXPORT_SYMBOL(mdio_device_reset);
> +
>  /**
>   * mdio_probe - probe an MDIO device
>   * @dev: device to probe
> @@ -128,9 +136,16 @@ static int mdio_probe(struct device *dev)
>  	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
>  	int err = 0;
>  
> -	if (mdiodrv->probe)
> +	if (mdiodrv->probe) {
> +		/* Deassert the reset signal */
> +		mdio_device_reset(mdiodev, 0);
> +
>  		err = mdiodrv->probe(mdiodev);
>  
> +		/* Assert the reset signal */
> +		mdio_device_reset(mdiodev, 1);

Really? Don't you want to do that only if err is non zero?

> +	}
> +
>  	return err;
>  }
>  
> @@ -140,9 +155,16 @@ static int mdio_remove(struct device *dev)
>  	struct device_driver *drv = mdiodev->dev.driver;
>  	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
>  
> -	if (mdiodrv->remove)
> +	if (mdiodrv->remove) {
> +		/* Deassert the reset signal */
> +		mdio_device_reset(mdiodev, 0);
> +

Why would that be necessary here? If we remove the driver, we probed it,
so we should already be de-asserted, no?

>  		mdiodrv->remove(mdiodev);
>  
> +		/* Assert the reset signal */
> +		mdio_device_reset(mdiodev, 1);
> +	}
> +
>  	return 0;
>  }
>  
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 67f25ac29025c539..e694b0ecf780d096 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -632,6 +632,9 @@ int phy_device_register(struct phy_device *phydev)
>  	if (err)
>  		return err;
>  
> +	/* Deassert the reset signal */
> +	phy_device_reset(phydev, 0);
> +
>  	/* Run all of the fixups for this PHY */
>  	err = phy_scan_fixups(phydev);
>  	if (err) {
> @@ -647,9 +650,15 @@ int phy_device_register(struct phy_device *phydev)
>  		goto out;
>  	}
>  
> +	/* Assert the reset signal */
> +	phy_device_reset(phydev, 1);

Same here, I don't think you can safely assert the PHY reset signal here
and have no side effects. I see the intent now, you want to keep it in
reset for as long as possible, possibly to minimize power consumption?
Depending on how the reset signal is wired and how the PHY HW is
designed, this may cause the PHY to lose all of the programming done,
probably not a good idea.

> +
>  	return 0;
>  
>   out:
> +	/* Assert the reset signal */
> +	phy_device_reset(phydev, 1);
> +
>  	mdiobus_unregister_device(&phydev->mdio);
>  	return err;
>  }
> @@ -849,6 +858,9 @@ int phy_init_hw(struct phy_device *phydev)
>  {
>  	int ret = 0;
>  
> +	/* Deassert the reset signal */
> +	phy_device_reset(phydev, 0);
> +
>  	if (!phydev->drv || !phydev->drv->config_init)
>  		return 0;
>  
> @@ -1126,6 +1138,9 @@ void phy_detach(struct phy_device *phydev)
>  	put_device(&phydev->mdio.dev);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
> +
> +	/* Assert the reset signal */
> +	phy_device_reset(phydev, 1);
>  }
>  EXPORT_SYMBOL(phy_detach);
>  
> @@ -1811,9 +1826,16 @@ static int phy_probe(struct device *dev)
>  	/* Set the state to READY by default */
>  	phydev->state = PHY_READY;
>  
> -	if (phydev->drv->probe)
> +	if (phydev->drv->probe) {
> +		/* Deassert the reset signal */
> +		phy_device_reset(phydev, 0);
> +
>  		err = phydev->drv->probe(phydev);
>  
> +		/* Assert the reset signal */
> +		phy_device_reset(phydev, 1);

Same as for the MDIO device probe, we can't do that unless we return non
zero from probe.

> +	}
> +
>  	mutex_unlock(&phydev->lock);
>  
>  	return err;
> @@ -1829,8 +1851,15 @@ static int phy_remove(struct device *dev)
>  	phydev->state = PHY_DOWN;
>  	mutex_unlock(&phydev->lock);
>  
> -	if (phydev->drv && phydev->drv->remove)
> +	if (phydev->drv && phydev->drv->remove) {
> +		/* Deassert the reset signal */
> +		phy_device_reset(phydev, 0);
> +
>  		phydev->drv->remove(phydev);
> +
> +		/* Assert the reset signal */
> +		phy_device_reset(phydev, 1);
> +	}
>  	phydev->drv = NULL;
>  
>  	return 0;
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 98258583abb0b405..3d044119c032d176 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -47,6 +47,7 @@ static int of_get_phy_id(struct device_node *device, u32 *phy_id)
>  static int of_mdiobus_register_phy(struct mii_bus *mdio,
>  				    struct device_node *child, u32 addr)
>  {
> +	struct gpio_desc *gpiod;
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc;
> @@ -55,10 +56,22 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio,
>  	is_c45 = of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
>  
> +	/* Deassert the optional reset signal */
> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
> +				       GPIOD_OUT_LOW, "PHY reset");
> +	if (PTR_ERR(gpiod) == -ENOENT)
> +		gpiod = NULL;
> +	else if (IS_ERR(gpiod))
> +		return PTR_ERR(gpiod);
> +
>  	if (!is_c45 && !of_get_phy_id(child, &phy_id))
>  		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>  	else
>  		phy = get_phy_device(mdio, addr, is_c45);
> +
> +	/* Assert the reset signal again */
> +	gpiod_set_value(gpiod, 1);

You have a phy_device reference now, so why not call phy_device_reset()
directly here?

> +
>  	if (IS_ERR(phy))
>  		return PTR_ERR(phy);
>  
> @@ -81,6 +94,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio,
>  	 * can be looked up later */
>  	of_node_get(child);
>  	phy->mdio.dev.of_node = child;
> +	phy->mdio.reset = gpiod;
>  
>  	/* All data is now stored in the phy struct;
>  	 * register it */
> @@ -100,6 +114,7 @@ static int of_mdiobus_register_device(struct mii_bus *mdio,
>  				      struct device_node *child, u32 addr)
>  {
>  	struct mdio_device *mdiodev;
> +	struct gpio_desc *gpiod;
>  	int rc;
>  
>  	mdiodev = mdio_device_create(mdio, addr);
> @@ -112,6 +127,14 @@ static int of_mdiobus_register_device(struct mii_bus *mdio,
>  	of_node_get(child);
>  	mdiodev->dev.of_node = child;
>  
> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
> +				       GPIOD_ASIS, "PHY reset");
> +	if (PTR_ERR(gpiod) == -ENOENT)
> +		gpiod = NULL;
> +	else if (IS_ERR(gpiod))
> +		return PTR_ERR(gpiod);
> +	mdiodev->reset = gpiod;

There is some obvious and non desireable duplication of code between
"pure" mdio_device and phy_device paths here, can you factor this such
that there is a common function storing gpiod into a mdio_device's reset
member in both cases?

Also, there is some asymetry being exposed here, the GPIO descriptor is
acquired from OF specific code, but is released in the generic MDIO
device layer, can we find a way to make that symmetrical?
-- 
Florian
