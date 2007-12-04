From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][RESEND] PHY: Add the phy_device_release device method.
Date: Mon, 3 Dec 2007 21:44:40 -0800
Message-ID: <20071203214440.78709615.akpm@linux-foundation.org>
References: <20071119.214215.207388094.davem@davemloft.net>
	<4751D9F3.5090502@garzik.org>
	<20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750931AbXLDFpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 00:45:13 -0500
In-Reply-To: <20071203083511.GA9396@avionic-tr-basi.adnet.avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Dec 2007 09:35:11 +0100 Thierry Reding <thierry.reding@avionic-design.de> wrote:

> In cases where more than a single PHY is found on the MDIO bus, the kernel
> will print a warning that this method is missing for each PHY device that
> is not attached to a networking device.
> 
> Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
> ---
>  drivers/net/phy/mdio_bus.c |   19 ++++++++++++++++++-
>  1 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index fc2f0e6..cb7fb47 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -36,6 +36,23 @@
>  #include <asm/uaccess.h>
>  
>  /**
> + * phy_device_release - free a phy_device structure when all users of it are
> + * 	finished.
> + *
> + * @dev: device that's been disconnected
> + *
> + * Will be called only by the device core when all users of this phy_device
> + * are done.
> + */
> +static void phy_device_release(struct device *dev)
> +{
> +	struct phy_device *phy;
> +
> +	phy = to_phy_device(dev);
> +	kfree(phy);
> +}
> +
> +/**
>   * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
>   * @bus: target mii_bus
>   *
> @@ -83,6 +100,7 @@ int mdiobus_register(struct mii_bus *bus)
>  		if (phydev) {
>  			phydev->irq = bus->irq[i];
>  
> +			phydev->dev.release = phy_device_release;
>  			phydev->dev.parent = bus->dev;
>  			phydev->dev.bus = &mdio_bus_type;
>  			snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, i);
> @@ -112,7 +130,6 @@ void mdiobus_unregister(struct mii_bus *bus)
>  	for (i = 0; i < PHY_MAX_ADDR; i++) {
>  		if (bus->phy_map[i]) {
>  			device_unregister(&bus->phy_map[i]->dev);
> -			kfree(bus->phy_map[i]);
>  		}
>  	}
>  }
> 

I've been sitting on
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc3/2.6.24-rc3-mm2/broken-out/phy-implement-release-function.patch
for a few weeks.  For some reason I have it in my "nacked netdev patches"
section but I think that was a mistake and it has not (yet ;)) been nacked.

Anyway, Anton's patch looks somewhat different from yours.  Please compare
notes.

