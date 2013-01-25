From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [PATCH/RFC 2/3] ethernet: add a PHY reset GPIO DT binding to
 sh_eth
Date: Fri, 25 Jan 2013 11:34:55 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
References: <1359043653-11374-1-git-send-email-g.liakhovetski@gmx.de>
 <1359043653-11374-3-git-send-email-g.liakhovetski@gmx.de> <7921225.sfO3PIeLVS@avalon>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-sh@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org
To: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <7921225.sfO3PIeLVS@avalon>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Laurent

On Fri, 25 Jan 2013, Laurent Pinchart wrote:

> Hi Guennadi,
> 
> On Thursday 24 January 2013 17:07:32 Guennadi Liakhovetski wrote:
> > If an ethernet PHY can be reset by a GPIO, it can be specified in DT. Add
> > a binding and code to parse it, request the GPIO and take the PHY out of
> > reset.
> > 
> > Signed-off-by: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
> > Cc: devicetree-discuss@lists.ozlabs.org
> > Cc: netdev@vger.kernel.org
> > ---
> >  Documentation/devicetree/bindings/net/sh_ether.txt |    2 ++
> >  drivers/net/ethernet/renesas/sh_eth.c              |    9 ++++++++-
> >  2 files changed, 10 insertions(+), 1 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt
> > b/Documentation/devicetree/bindings/net/sh_ether.txt index c11e45d..edaf683
> > 100644
> > --- a/Documentation/devicetree/bindings/net/sh_ether.txt
> > +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
> > @@ -12,6 +12,7 @@ Required properties:
> >  - interrupts:                   Interrupt mapping for the sh_eth interrupt
> >                                  sources (vector id).
> >  - phy-mode:              String, operation mode of the PHY interface.
> > +- phy-reset-gpios:              PHY reset GPIO tuple
> 
> If you can't have more than one GPIO here, what about calling it phy-reset-
> gpio ?

>From Documentation/devicetree/bindings/gpio/gpio.txt:

<quote>
GPIO properties should be named "[<name>-]gpios".
</quote>

> >  - sh-eth,edmac-endian:          String, endian of sh_eth dmac.
> >  - sh-eth,register-type:         String, register type of sh_eth.
> >                                  Please select "gigabit", "fast-sh4" or
> > @@ -37,6 +38,7 @@ Example (armadillo800eva):
> >  		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
> >  		interrupts = <0x500>;
> >  		phy-mode = "mii";
> > +		phy-reset-gpios = <&gpio 18 0>;
> >  		sh-eth,edmac-endian = "little";
> >  		sh-eth,register-type = "gigabit";
> >  		sh-eth,phy-id = <0>;
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c
> > b/drivers/net/ethernet/renesas/sh_eth.c index 1f64848..06035a2 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -20,6 +20,7 @@
> >   *  the file called "COPYING".
> >   */
> > 
> > +#include <linux/gpio.h>
> >  #include <linux/init.h>
> >  #include <linux/module.h>
> >  #include <linux/kernel.h>
> > @@ -33,6 +34,7 @@
> >  #include <linux/netdevice.h>
> >  #include <linux/of.h>
> >  #include <linux/of_device.h>
> > +#include <linux/of_gpio.h>
> >  #include <linux/of_platform.h>
> >  #include <linux/of_address.h>
> >  #include <linux/of_irq.h>
> > @@ -2376,10 +2378,11 @@ sh_eth_of_get_register_type(struct device_node *np)
> >  static struct sh_eth_plat_data *
> >  sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
> >  {
> > -	int ret;
> > +	int ret, gpio;
> >  	const char *of_str;
> >  	struct device_node *np = dev->of_node;
> >  	struct sh_eth_plat_data *pdata;
> > +	enum of_gpio_flags flags;
> > 
> >  	pdata = devm_kzalloc(dev, sizeof(struct sh_eth_plat_data),
> >  					GFP_KERNEL);
> > @@ -2420,6 +2423,10 @@ sh_eth_parse_dt(struct device *dev, struct net_device
> > *ndev) else
> >  		pdata->needs_init = 0;
> > 
> > +	gpio = of_get_named_gpio_flags(np, "phy-reset-gpios", 0, &flags);
> > +	if (gpio_is_valid(gpio) && !devm_gpio_request(dev, gpio, NULL))
> > +		gpio_direction_output(gpio, !!(flags & OF_GPIO_ACTIVE_LOW));
> 
> You could use devm_gpio_request_one() here.

Yes, but then the flag would look uglier, something like

		devm_gpio_request_one(dev, gpio, flags & 
			OF_GPIO_ACTIVE_LOW ? GPIOF_OUT_INIT_HIGH : 
			GPIOF_OUT_INIT_LOW);

Does it really look like an improvement? :)

> Is there no need to reset the phy at runtime ?

No idea, I'm not developing the driver, I'm just porting one specific 
feature from one API to another with no functional changes (apart from 
postponing setting the GPIO).

Thanks
Guennadi

> > +
> >  #ifdef CONFIG_OF_NET
> >  	if (!is_valid_ether_addr(ndev->dev_addr)) {
> >  		const char *macaddr = of_get_mac_address(np);
> -- 
> Regards,
> 
> Laurent Pinchart
> 

---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
