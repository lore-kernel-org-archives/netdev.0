From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Wed, 8 Feb 2017 17:57:13 +0100
Message-ID: <20170208165713.GD13281@lunn.ch>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
 <20170208073746.10963-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rmk+kernel@armlinux.org.uk, maowenan@huawei.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60135 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751906AbdBHRkz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 12:40:55 -0500
Content-Disposition: inline
In-Reply-To: <20170208073746.10963-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -920,7 +920,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		return -EIO;
>  	}
>  
> -	if (!try_module_get(d->driver->owner)) {
> +	if (d->driver && !try_module_get(d->driver->owner)) {
>  		dev_err(&dev->dev, "failed to get the device driver module\n");
>  		return -EIO;
>  	}
> @@ -943,7 +943,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  			err = device_bind_driver(d);
>  
>  		if (err)
> -			goto error;
> +			goto error_put_device;
>  	}
>  
>  	if (phydev->attached_dev) {
> @@ -981,6 +981,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  
>  error:
>  	phy_detach(phydev);
> +error_put_device:
>  	put_device(d);
>  	module_put(d->driver->owner);

Can we get into problems here? Maybe we did not do a get?


>  	if (ndev_owner != bus->owner)
> @@ -1065,7 +1066,8 @@ void phy_detach(struct phy_device *phydev)
>  	bus = phydev->mdio.bus;
>  
>  	put_device(&phydev->mdio.dev);
> -	module_put(phydev->mdio.dev.driver->owner);
> +	if (phydev->mdio.dev.driver)
> +		module_put(phydev->mdio.dev.driver->owner);

Humm. By this point, havn't we assigned d->driver to genphy_driver?
So this decrements something we never incremented?

To me, it seems better to move the try_module_get() after assigning
genphy_driver if needed. We then don't have any special conditions.

      Andrew
