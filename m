From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 1/2] net: phy: Set the driver when registering an MDIO
 bus device
Date: Tue, 5 Aug 2014 11:22:58 +0800
Message-ID: <20140805032257.GD2167@dragon>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Marek =?utf-8?B?VmHFoXV0?= <marex@denx.de>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0144.outbound.protection.outlook.com ([207.46.163.144]:12386
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754919AbaHEDXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2014 23:23:22 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2014 at 11:55:22PM -0300, Fabio Estevam wrote:
> Hi Ezequiel,
> 
> On Wed, Jul 23, 2014 at 4:47 PM, Ezequiel Garcia
> <ezequiel.garcia@free-electrons.com> wrote:
> > mdiobus_register() registers a device which is already bound to a driver.
> > Hence, the driver pointer should be set properly in order to track down
> > the driver associated to the MDIO bus.
> >
> > This will be used to allow ethernet driver to pin down a MDIO bus driver,
> > preventing it from being unloaded while the PHY device is running.
> >
> > Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> > Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> > Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> > ---
> >  drivers/net/phy/mdio_bus.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> > index 4eaadcf..203651e 100644
> > --- a/drivers/net/phy/mdio_bus.c
> > +++ b/drivers/net/phy/mdio_bus.c
> > @@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
> >
> >         bus->dev.parent = bus->parent;
> >         bus->dev.class = &mdio_bus_class;
> > +       bus->dev.driver = bus->parent->driver;
> >         bus->dev.groups = NULL;
> >         dev_set_name(&bus->dev, "%s", bus->id);
> 
> This patches causes the following regression in 3.16 (tested on mx5/mx6):

The change will trigger a device_suspend() call on mii_bus device with
the pm suspend/resume callbacks being fec driver ones, since
bus->parent->driver points to fec driver.

So net result is fec_suspend() will be called twice during suspend, once
in mii_bus device context and the other in fec device context.  In fec
context, it works just fine.  And the issue we're seeing is from mii_bus
device context, where the driver_data of the device is invalid.

I do not think fec_suspend() should be called in mii_bus device context.

Shawn
