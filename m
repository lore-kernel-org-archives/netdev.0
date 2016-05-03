From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Tue, 3 May 2016 12:03:35 -0500
Message-ID: <20160503170335.GA24392@rob-hp-laptop>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grant.likely@linaro.org, devicetree@vger.kernel.org,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	frowand.list@gmail.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3641492.klKRrvS8tr@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2016 at 01:12:54AM +0300, Sergei Shtylyov wrote:
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
> Note that I had to modify the  AT803x PHY driver as it would stop working
> otherwise as it made use of the reset GPIO for its own purposes...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> Changes in version 2:
> - reformatted the changelog;
> - resolved rejects, refreshed the patch.
> 
> Documentation/devicetree/bindings/net/phy.txt |    2 +
>  Documentation/devicetree/bindings/net/phy.txt |    2 +

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/phy/at803x.c                      |   19 ++------------
>  drivers/net/phy/mdio_bus.c                    |    4 +++
>  drivers/net/phy/mdio_device.c                 |   27 +++++++++++++++++++--
>  drivers/net/phy/phy_device.c                  |   33 ++++++++++++++++++++++++--
>  drivers/of/of_mdio.c                          |   16 ++++++++++++
>  include/linux/mdio.h                          |    3 ++
>  include/linux/phy.h                           |    5 +++
>  8 files changed, 89 insertions(+), 20 deletions(-)
> 
> Index: net-next/Documentation/devicetree/bindings/net/phy.txt
> ===================================================================
> --- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
> +++ net-next/Documentation/devicetree/bindings/net/phy.txt
> @@ -35,6 +35,8 @@ Optional Properties:
>  - broken-turn-around: If set, indicates the PHY device does not correctly
>    release the turn around line low at the end of a MDIO transaction.
>  
> +- reset-gpios: The GPIO phandle and specifier for the PHY reset signal.
> +
>  Example:
>  
>  ethernet-phy@0 {
> Index: net-next/drivers/net/phy/at803x.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/at803x.c
> +++ net-next/drivers/net/phy/at803x.c
> @@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
>  
>  struct at803x_priv {
>  	bool phy_reset:1;
> -	struct gpio_desc *gpiod_reset;
>  };
>  
>  struct at803x_context {
> @@ -271,22 +270,10 @@ static int at803x_probe(struct phy_devic
>  {
>  	struct device *dev = &phydev->mdio.dev;
>  	struct at803x_priv *priv;
> -	struct gpio_desc *gpiod_reset;
>  
>  	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
>  	if (!priv)
>  		return -ENOMEM;
> -
> -	if (phydev->drv->phy_id != ATH8030_PHY_ID)
> -		goto does_not_require_reset_workaround;
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
> @@ -361,14 +348,14 @@ static void at803x_link_change_notify(st
>  	 */
>  	if (phydev->drv->phy_id == ATH8030_PHY_ID) {
>  		if (phydev->state == PHY_NOLINK) {
> -			if (priv->gpiod_reset && !priv->phy_reset) {
> +			if (phydev->mdio.reset && !priv->phy_reset) {
>  				struct at803x_context context;
>  
>  				at803x_context_save(phydev, &context);
>  
> -				gpiod_set_value(priv->gpiod_reset, 1);
> +				phy_device_reset(phydev, 1);
>  				msleep(1);
> -				gpiod_set_value(priv->gpiod_reset, 0);
> +				phy_device_reset(phydev, 0);
>  				msleep(1);
>  
>  				at803x_context_restore(phydev, &context);
> Index: net-next/drivers/net/phy/mdio_bus.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/mdio_bus.c
> +++ net-next/drivers/net/phy/mdio_bus.c
> @@ -35,6 +35,7 @@
>  #include <linux/phy.h>
>  #include <linux/io.h>
>  #include <linux/uaccess.h>
> +#include <linux/gpio/consumer.h>
>  
>  #include <asm/irq.h>
>  
> @@ -371,6 +372,9 @@ void mdiobus_unregister(struct mii_bus *
>  		if (!mdiodev)
>  			continue;
>  
> +		if (mdiodev->reset)
> +			gpiod_put(mdiodev->reset);
> +
>  		mdiodev->device_remove(mdiodev);
>  		mdiodev->device_free(mdiodev);
>  	}
> Index: net-next/drivers/net/phy/mdio_device.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/mdio_device.c
> +++ net-next/drivers/net/phy/mdio_device.c
> @@ -12,6 +12,8 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/errno.h>
> +#include <linux/gpio.h>
> +#include <linux/gpio/consumer.h>
>  #include <linux/init.h>
>  #include <linux/interrupt.h>
>  #include <linux/kernel.h>
> @@ -103,6 +105,13 @@ void mdio_device_remove(struct mdio_devi
>  }
>  EXPORT_SYMBOL(mdio_device_remove);
>  
> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
> +{
> +	if (mdiodev->reset)
> +		gpiod_set_value(mdiodev->reset, value);
> +}
> +EXPORT_SYMBOL(mdio_device_reset);
> +
>  /**
>   * mdio_probe - probe an MDIO device
>   * @dev: device to probe
> @@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
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
> +	}
> +
>  	return err;
>  }
>  
> @@ -129,9 +145,16 @@ static int mdio_remove(struct device *de
>  	struct device_driver *drv = mdiodev->dev.driver;
>  	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
>  
> -	if (mdiodrv->remove)
> +	if (mdiodrv->remove) {
> +		/* Deassert the reset signal */
> +		mdio_device_reset(mdiodev, 0);
> +
>  		mdiodrv->remove(mdiodev);
>  
> +		/* Assert the reset signal */
> +		mdio_device_reset(mdiodev, 1);
> +	}
> +
>  	return 0;
>  }
>  
> Index: net-next/drivers/net/phy/phy_device.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/phy_device.c
> +++ net-next/drivers/net/phy/phy_device.c
> @@ -589,6 +589,9 @@ int phy_device_register(struct phy_devic
>  	if (err)
>  		return err;
>  
> +	/* Deassert the reset signal */
> +	phy_device_reset(phydev, 0);
> +
>  	/* Run all of the fixups for this PHY */
>  	err = phy_scan_fixups(phydev);
>  	if (err) {
> @@ -604,9 +607,15 @@ int phy_device_register(struct phy_devic
>  		goto out;
>  	}
>  
> +	/* Assert the reset signal */
> +	phy_device_reset(phydev, 1);
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
> @@ -792,6 +801,9 @@ int phy_init_hw(struct phy_device *phyde
>  {
>  	int ret = 0;
>  
> +	/* Deassert the reset signal */
> +	phy_device_reset(phydev, 0);
> +
>  	if (!phydev->drv || !phydev->drv->config_init)
>  		return 0;
>  
> @@ -997,6 +1009,9 @@ void phy_detach(struct phy_device *phyde
>  
>  	put_device(&phydev->mdio.dev);
>  	module_put(bus->owner);
> +
> +	/* Assert the reset signal */
> +	phy_device_reset(phydev, 1);
>  }
>  EXPORT_SYMBOL(phy_detach);
>  
> @@ -1596,9 +1611,16 @@ static int phy_probe(struct device *dev)
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
> +	}
> +
>  	mutex_unlock(&phydev->lock);
>  
>  	return err;
> @@ -1612,8 +1634,15 @@ static int phy_remove(struct device *dev
>  	phydev->state = PHY_DOWN;
>  	mutex_unlock(&phydev->lock);
>  
> -	if (phydev->drv->remove)
> +	if (phydev->drv->remove) {
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
> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>  static void of_mdiobus_register_phy(struct mii_bus *mdio,
>  				    struct device_node *child, u32 addr)
>  {
> +	struct gpio_desc *gpiod;
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc;
> @@ -52,10 +53,17 @@ static void of_mdiobus_register_phy(stru
>  	is_c45 = of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
>  
> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
> +	/* Deassert the reset signal */
> +	if (!IS_ERR(gpiod))
> +		gpiod_direction_output(gpiod, 0);
>  	if (!is_c45 && !of_get_phy_id(child, &phy_id))
>  		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>  	else
>  		phy = get_phy_device(mdio, addr, is_c45);
> +	/* Assert the reset signal again */
> +	if (!IS_ERR(gpiod))
> +		gpiod_set_value(gpiod, 1);
>  	if (IS_ERR(phy))
>  		return;
>  
> @@ -75,6 +83,9 @@ static void of_mdiobus_register_phy(stru
>  	of_node_get(child);
>  	phy->mdio.dev.of_node = child;
>  
> +	if (!IS_ERR(gpiod))
> +		phy->mdio.reset = gpiod;
> +
>  	/* All data is now stored in the phy struct;
>  	 * register it */
>  	rc = phy_device_register(phy);
> @@ -92,6 +103,7 @@ static void of_mdiobus_register_device(s
>  				       struct device_node *child, u32 addr)
>  {
>  	struct mdio_device *mdiodev;
> +	struct gpio_desc *gpiod;
>  	int rc;
>  
>  	mdiodev = mdio_device_create(mdio, addr);
> @@ -104,6 +116,10 @@ static void of_mdiobus_register_device(s
>  	of_node_get(child);
>  	mdiodev->dev.of_node = child;
>  
> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
> +	if (!IS_ERR(gpiod))
> +		mdiodev->reset = gpiod;
> +
>  	/* All data is now stored in the mdiodev struct; register it. */
>  	rc = mdio_device_register(mdiodev);
>  	if (rc) {
> Index: net-next/include/linux/mdio.h
> ===================================================================
> --- net-next.orig/include/linux/mdio.h
> +++ net-next/include/linux/mdio.h
> @@ -11,6 +11,7 @@
>  
>  #include <uapi/linux/mdio.h>
>  
> +struct gpio_desc;
>  struct mii_bus;
>  
>  /* Multiple levels of nesting are possible. However typically this is
> @@ -37,6 +38,7 @@ struct mdio_device {
>  	/* Bus address of the MDIO device (0-31) */
>  	int addr;
>  	int flags;
> +	struct gpio_desc *reset;
>  };
>  #define to_mdio_device(d) container_of(d, struct mdio_device, dev)
>  
> @@ -69,6 +71,7 @@ void mdio_device_free(struct mdio_device
>  struct mdio_device *mdio_device_create(struct mii_bus *bus, int addr);
>  int mdio_device_register(struct mdio_device *mdiodev);
>  void mdio_device_remove(struct mdio_device *mdiodev);
> +void mdio_device_reset(struct mdio_device *mdiodev, int value);
>  int mdio_driver_register(struct mdio_driver *drv);
>  void mdio_driver_unregister(struct mdio_driver *drv);
>  
> Index: net-next/include/linux/phy.h
> ===================================================================
> --- net-next.orig/include/linux/phy.h
> +++ net-next/include/linux/phy.h
> @@ -769,6 +769,11 @@ static inline int phy_read_status(struct
>  	return phydev->drv->read_status(phydev);
>  }
>  
> +static inline void phy_device_reset(struct phy_device *phydev, int value)
> +{
> +	mdio_device_reset(&phydev->mdio, value);
> +}
> +
>  #define phydev_err(_phydev, format, args...)	\
>  	dev_err(&_phydev->mdio.dev, format, ##args)
>  
> 
