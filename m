From: maowenan <maowenan@huawei.com>
Subject: RE: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Wed, 8 Feb 2017 07:57:58 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F201ED9E4E@szxemi502-mbx.china.huawei.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
 <20170208073746.10963-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "rmk+kernel@armlinux.org.uk" <rmk+kernel@armlinux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4778 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752142AbdBHH6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:58:18 -0500
In-Reply-To: <20170208073746.10963-2-f.fainelli@gmail.com>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Wednesday, February 08, 2017 3:38 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; andrew@lunn.ch; rmk+kernel@armlinux.org.uk;
> maowenan; Florian Fainelli
> Subject: [PATCH net v2 1/3] net: phy: Fix PHY module checks
> 
> The Generic PHY drivers gets assigned after we checked that the current PHY
> driver is NULL, so we need to check a few things before we can safely
> derference d->driver. Update phy_attach_direct() and phy_detach() accordingly
> to be resilient to these cases.
> 
> Even though the Generic PHY driver defaults to phy_probe() which can hardly
> fail at the moment, let's fix the label so we don't call phy_detach() on a network
> device we have not attached yet.
> 
> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy_device.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c index
> 0d8f4d3847f6..bde240bf8d7b 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -920,7 +920,7 @@ int phy_attach_direct(struct net_device *dev, struct
> phy_device *phydev,
>  		return -EIO;
>  	}
> 
> -	if (!try_module_get(d->driver->owner)) {
> +	if (d->driver && !try_module_get(d->driver->owner)) {
>  		dev_err(&dev->dev, "failed to get the device driver module\n");
>  		return -EIO;

Hi Florian,
  Here "return -EIO" will miss decreasing bus->owner reference count.

Mao Wenan

>  	}
> @@ -943,7 +943,7 @@ int phy_attach_direct(struct net_device *dev, struct
> phy_device *phydev,
>  			err = device_bind_driver(d);
> 
>  		if (err)
> -			goto error;
> +			goto error_put_device;
>  	}
> 
>  	if (phydev->attached_dev) {
> @@ -981,6 +981,7 @@ int phy_attach_direct(struct net_device *dev, struct
> phy_device *phydev,
> 
>  error:
>  	phy_detach(phydev);
> +error_put_device:
>  	put_device(d);
>  	module_put(d->driver->owner);
>  	if (ndev_owner != bus->owner)
> @@ -1065,7 +1066,8 @@ void phy_detach(struct phy_device *phydev)
>  	bus = phydev->mdio.bus;
> 
>  	put_device(&phydev->mdio.dev);
> -	module_put(phydev->mdio.dev.driver->owner);
> +	if (phydev->mdio.dev.driver)
> +		module_put(phydev->mdio.dev.driver->owner);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
>  }
> --
> 2.9.3
