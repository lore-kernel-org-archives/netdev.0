From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Fix PHY module checks and NULL deref in
 phy_attach_direct()
Date: Wed, 8 Feb 2017 19:07:30 -0800
Message-ID: <7a97ba93-3782-dfd0-d8eb-e528bbf39016@gmail.com>
References: <20170209030526.6029-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: maowenan <maowenan@huawei.com>, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34788 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdBIDOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 22:14:01 -0500
Received: by mail-qt0-f193.google.com with SMTP id w20so25653465qtb.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 19:14:01 -0800 (PST)
In-Reply-To: <20170209030526.6029-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 07:05 PM, Florian Fainelli wrote:
> The Generic PHY drivers gets assigned after we checked that the current
> PHY driver is NULL, so we need to check a few things before we can
> safely dereference d->driver. This would be causing a NULL deference to
> occur when a system binds to the Generic PHY driver. Update
> phy_attach_direct() to do the following:
> 
> - grab the driver module reference after we have assigned the Generic
>   PHY drivers accordingly, and remember we came from the generic PHY
>   path
> 
> - update the error path to clean up the module reference in case the
>   Generic PHY probe function fails
> 
> - split the error path involving phy_detacht() to avoid double free/put
>   since phy_detach() does all the clean up
> 
> - finally, have phy_detach() drop the module reference count before we
>   call device_release_driver() for the Generic PHY driver case
> 
> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Just FWIW, this time I tested all error paths in phy_attach_direct() by
directly injecting errors, and did that with both the Generic PHY driver
and another driver to make sure there were no reference count problems,
nor double frees.

Thanks all!

> ---
> David,
> 
> This is applicable to the "net" and the "net-next" tree since you
> merged "net" into "net-next".
> 
> I will fix the PHY driver bind/unbind mess another time, because we are running
> out of time for 4.10-rc final, and it's not like it worked before and got
> broken in this cycle, it just never worked (the bind/unbind).
> 
> Thanks!
> 
>  drivers/net/phy/phy_device.c | 28 ++++++++++++++++++++--------
>  1 file changed, 20 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 0d8f4d3847f6..8c8e15b8739d 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -908,6 +908,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  	struct module *ndev_owner = dev->dev.parent->driver->owner;
>  	struct mii_bus *bus = phydev->mdio.bus;
>  	struct device *d = &phydev->mdio.dev;
> +	bool using_genphy = false;
>  	int err;
>  
>  	/* For Ethernet device drivers that register their own MDIO bus, we
> @@ -920,11 +921,6 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		return -EIO;
>  	}
>  
> -	if (!try_module_get(d->driver->owner)) {
> -		dev_err(&dev->dev, "failed to get the device driver module\n");
> -		return -EIO;
> -	}
> -
>  	get_device(d);
>  
>  	/* Assume that if there is no driver, that it doesn't
> @@ -938,12 +934,22 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  			d->driver =
>  				&genphy_driver[GENPHY_DRV_1G].mdiodrv.driver;
>  
> +		using_genphy = true;
> +	}
> +
> +	if (!try_module_get(d->driver->owner)) {
> +		dev_err(&dev->dev, "failed to get the device driver module\n");
> +		err = -EIO;
> +		goto error_put_device;
> +	}
> +
> +	if (using_genphy) {
>  		err = d->driver->probe(d);
>  		if (err >= 0)
>  			err = device_bind_driver(d);
>  
>  		if (err)
> -			goto error;
> +			goto error_module_put;
>  	}
>  
>  	if (phydev->attached_dev) {
> @@ -980,9 +986,14 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  	return err;
>  
>  error:
> +	/* phy_detach() does all of the cleanup below */
>  	phy_detach(phydev);
> -	put_device(d);
> +	return err;
> +
> +error_module_put:
>  	module_put(d->driver->owner);
> +error_put_device:
> +	put_device(d);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
>  	return err;
> @@ -1045,6 +1056,8 @@ void phy_detach(struct phy_device *phydev)
>  
>  	phy_led_triggers_unregister(phydev);
>  
> +	module_put(phydev->mdio.dev.driver->owner);
> +
>  	/* If the device had no specific driver before (i.e. - it
>  	 * was using the generic driver), we unbind the device
>  	 * from the generic driver so that there's a chance a
> @@ -1065,7 +1078,6 @@ void phy_detach(struct phy_device *phydev)
>  	bus = phydev->mdio.bus;
>  
>  	put_device(&phydev->mdio.dev);
> -	module_put(phydev->mdio.dev.driver->owner);
>  	if (ndev_owner != bus->owner)
>  		module_put(bus->owner);
>  }
> 


-- 
Florian
