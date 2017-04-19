From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] mdio_bus: Issue GPIO RESET to PHYs.
Date: Wed, 19 Apr 2017 15:38:53 +0200
Message-ID: <20170419133853.GA2696@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <20170419113951.GA31908@lunn.ch>
 <f8624649-3e49-f68c-f364-ee73f1cc514d@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f8624649-3e49-f68c-f364-ee73f1cc514d@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 02:56:48PM +0300, Roger Quadros wrote:
> Hi,
> 
> On 19/04/17 14:39, Andrew Lunn wrote:
> > On Wed, Apr 19, 2017 at 12:24:26PM +0300, Roger Quadros wrote:
> >> Some boards [1] leave the PHYs at an invalid state
> >> during system power-up or reset thus causing unreliability
> >> issues with the PHY which manifests as PHY not being detected
> >> or link not functional. To fix this, these PHYs need to be RESET
> >> via a GPIO connected to the PHY's RESET pin.
> >>
> >> Some boards have a single GPIO controlling the PHY RESET pin of all
> >> PHYs on the bus whereas some others have separate GPIOs controlling
> >> individual PHY RESETs.
> >>
> >> In both cases, the RESET de-assertion cannot be done in the PHY driver
> >> as the PHY will not probe till its reset is de-asserted.
> >> So do the RESET de-assertion in the MDIO bus driver.
> >>
> >> [1] - am572x-idk, am571x-idk, a437x-idk
> >>
> >> Signed-off-by: Roger Quadros <rogerq@ti.com>
> >> ---
> >>  drivers/net/phy/mdio_bus.c | 26 ++++++++++++++++++++++++++
> >>  drivers/of/of_mdio.c       |  4 ++++
> >>  include/linux/phy.h        |  5 +++++
> >>  3 files changed, 35 insertions(+)
> > 
> > Hi Roger
> > 
> > Thanks for making this generic.
> > 
> > Please add device tree binding documentation. I think that actually
> > means you have to document MDIO in general, since there currently is
> > not a binding document.
> 
> OK.
> 
> > 
> >> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> >> index fa7d51f..25fda2b 100644
> >> --- a/drivers/net/phy/mdio_bus.c
> >> +++ b/drivers/net/phy/mdio_bus.c
> >> @@ -22,8 +22,11 @@
> >>  #include <linux/init.h>
> >>  #include <linux/delay.h>
> >>  #include <linux/device.h>
> >> +#include <linux/gpio.h>
> >> +#include <linux/gpio/consumer.h>
> >>  #include <linux/of_device.h>
> >>  #include <linux/of_mdio.h>
> >> +#include <linux/of_gpio.h>
> >>  #include <linux/netdevice.h>
> >>  #include <linux/etherdevice.h>
> >>  #include <linux/skbuff.h>
> >> @@ -43,6 +46,8 @@
> >>  
> >>  #include "mdio-boardinfo.h"
> >>  
> >> +#define DEFAULT_GPIO_RESET_DELAY	10	/* in microseconds */
> >> +
> >>  int mdiobus_register_device(struct mdio_device *mdiodev)
> >>  {
> >>  	if (mdiodev->bus->mdio_map[mdiodev->addr])
> >> @@ -307,6 +312,7 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
> >>  {
> >>  	struct mdio_device *mdiodev;
> >>  	int i, err;
> >> +	struct gpio_desc *gpiod;
> >>  
> >>  	if (NULL == bus || NULL == bus->name ||
> >>  	    NULL == bus->read || NULL == bus->write)
> >> @@ -333,6 +339,26 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
> >>  	if (bus->reset)
> >>  		bus->reset(bus);
> >>  
> >> +	/* de-assert bus level PHY GPIO resets */
> >> +	for (i = 0; i < bus->num_reset_gpios; i++) {
> >> +		gpiod = devm_gpiod_get_index(&bus->dev, "reset", i,
> >> +					     GPIOD_OUT_LOW);
> >> +		if (IS_ERR(gpiod)) {
> >> +			err = PTR_ERR(gpiod);
> >> +			if (err != -ENOENT) {
> >> +				pr_err("mii_bus %s couldn't get reset GPIO\n",
> >> +				       bus->id);
> >> +				return err;
> >> +			}
> >> +		} else {
> >> +			gpiod_set_value_cansleep(gpiod, 1);
> > 
> > 
> >> +			if (!bus->reset_delay_us)
> >> +				bus->reset_delay_us = DEFAULT_GPIO_RESET_DELAY;
> > 
> > Maybe do this once, where you read the device tree property.
> 
> I was thinking from point of view that GPIO RESET code should work even without
> device tree. Although I'm not sure if there would be any users or not.

Hi Roger

I don't see how this would work. What would devm_gpiod_get_index()
return? Something from ACPI? But then there would be something
equivalent for getting the delay.

Lets keep it simple and OF only. If there is a real need for something
in addition to OF, it can be added later.

   Andrew
