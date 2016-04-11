From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Mon, 11 Apr 2016 14:25:21 -0500
Message-ID: <20160411192521.GA6896@rob-hp-laptop>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3381543.SDQLqND8Pp@wasted.cogentembedded.com>
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
In-Reply-To: <3381543.SDQLqND8Pp@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 09, 2016 at 01:22:47AM +0300, Sergei Shtylyov wrote:
> The PHY  devices sometimes do have their reset signal (maybe even power
> supply?) tied to some GPIO and sometimes it also does happen that a boot
> loader does not leave it deasserted. So far this issue has been attacked
> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
> the GPIO in question;  that solution, when  applied to the device trees,
> led to adding the PHY reset GPIO properties to the MAC device node, with
> one exception: Cadence MACB driver which could handle the "reset-gpios"
> prop  in a PHY device  subnode.  I believe that the correct approach is to
> teach the 'phylib' to get the MDIO device reset GPIO from the device tree
> node corresponding to this device -- which this patch is doing...
> 
> Note that I had to modify the  AT803x PHY driver as it would stop working
> otherwise as it made use of the reset GPIO for its own purposes...

Lots of double spaces in here. Please fix.

> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
>  Documentation/devicetree/bindings/net/phy.txt |    2 +
>  drivers/net/phy/at803x.c                      |   19 ++------------
>  drivers/net/phy/mdio_bus.c                    |    4 +++
>  drivers/net/phy/mdio_device.c                 |   27 +++++++++++++++++++--
>  drivers/net/phy/phy_device.c                  |   33 ++++++++++++++++++++++++--
>  drivers/of/of_mdio.c                          |   16 ++++++++++++
>  include/linux/mdio.h                          |    3 ++
>  include/linux/phy.h                           |    5 +++
>  8 files changed, 89 insertions(+), 20 deletions(-)

[...]

> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>  static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *child,
>  				   u32 addr)
>  {
> +	struct gpio_desc *gpiod;
>  	struct phy_device *phy;
>  	bool is_c45;
>  	int rc;
> @@ -52,10 +53,17 @@ static int of_mdiobus_register_phy(struc
>  	is_c45 = of_device_is_compatible(child,
>  					 "ethernet-phy-ieee802.3-c45");
>  
> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");

Calling fwnode_* functions in a DT specific file/function? That doesn't 
make sense.

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
>  	if (IS_ERR_OR_NULL(phy))
>  		return 1;
>  
