From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 1/2] net: phy: Set the driver when registering an MDIO
 bus device
Date: Tue, 5 Aug 2014 12:41:39 +0800
Message-ID: <20140805044137.GE2167@dragon>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
 <20140805032257.GD2167@dragon> <53E05702.9000007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Fabio Estevam <festevam@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Marek =?utf-8?B?VmHFoXV0?= <marex@denx.de>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0240.outbound.protection.outlook.com ([207.46.163.240]:57402
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753032AbaHEEmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 00:42:02 -0400
Content-Disposition: inline
In-Reply-To: <53E05702.9000007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2014 at 09:01:06PM -0700, Florian Fainelli wrote:
> On 08/04/14 20:22, Shawn Guo wrote:
> >On Mon, Aug 04, 2014 at 11:55:22PM -0300, Fabio Estevam wrote:
> >>Hi Ezequiel,
> >>
> >>On Wed, Jul 23, 2014 at 4:47 PM, Ezequiel Garcia
> >><ezequiel.garcia@free-electrons.com> wrote:
> >>>mdiobus_register() registers a device which is already bound to a driver.
> >>>Hence, the driver pointer should be set properly in order to track down
> >>>the driver associated to the MDIO bus.
> >>>
> >>>This will be used to allow ethernet driver to pin down a MDIO bus driver,
> >>>preventing it from being unloaded while the PHY device is running.
> >>>
> >>>Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> >>>Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> >>>Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> >>>---
> >>>  drivers/net/phy/mdio_bus.c | 1 +
> >>>  1 file changed, 1 insertion(+)
> >>>
> >>>diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> >>>index 4eaadcf..203651e 100644
> >>>--- a/drivers/net/phy/mdio_bus.c
> >>>+++ b/drivers/net/phy/mdio_bus.c
> >>>@@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
> >>>
> >>>         bus->dev.parent = bus->parent;
> >>>         bus->dev.class = &mdio_bus_class;
> >>>+       bus->dev.driver = bus->parent->driver;
> >>>         bus->dev.groups = NULL;
> >>>         dev_set_name(&bus->dev, "%s", bus->id);
> >>
> >>This patches causes the following regression in 3.16 (tested on mx5/mx6):
> >
> >The change will trigger a device_suspend() call on mii_bus device with
> >the pm suspend/resume callbacks being fec driver ones, since
> >bus->parent->driver points to fec driver.
> >
> >So net result is fec_suspend() will be called twice during suspend, once
> >in mii_bus device context and the other in fec device context.  In fec
> >context, it works just fine.  And the issue we're seeing is from mii_bus
> >device context, where the driver_data of the device is invalid.
> >
> >I do not think fec_suspend() should be called in mii_bus device context.
> 
> Right, that does not sound like a good thing to do. Does it work if
> you call pm_suspend_ignore_children() either in the FEC driver or in
> mdiobus_register()?

No, it doesn't stop fec_suspend() being called from mii_bus device
context.

> 
> I am not exactly sure what the best solution looks like at this point

Let's see if Ezequiel has any idea, but otherwise we should probably
revert the patch for 3.16 stable.

Shawn
