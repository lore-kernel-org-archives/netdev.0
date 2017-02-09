From: Heiko Schocher <hs@denx.de>
Subject: Re: [net, v3, 1/3] net: phy: Fix PHY module checks and NULL deref in
 phy_attach_direct()
Date: Thu, 9 Feb 2017 07:58:17 +0100
Message-ID: <589C1309.5040302@denx.de>
References: <20170209001401.2564-2-f.fainelli@gmail.com>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maowenan <maowenan@huawei.com>,
        andrew@lunn.ch, rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:37395 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdBIG7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 01:59:38 -0500
In-Reply-To: <20170209001401.2564-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Florian,

Am 09.02.2017 um 01:13 schrieb Florian Fainelli:
> The Generic PHY drivers gets assigned after we checked that the current
> PHY driver is NULL, so we need to check a few things before we can
> safely dereference d->driver. This would be causing a NULL deference to
> occur when a system binds to the Generic PHY driver. Update
> phy_attach_direct() to do the following:
>
> - grab the driver module reference after we have assigned the Generic
>    PHY drivers accordingly
>
> - update the error path to clean up the module reference in case the
>    Generic PHY probe function fails
>
> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/phy/phy_device.c | 16 +++++++++++++++-
>   1 file changed, 15 insertions(+), 1 deletion(-)

just stumbled over this bug on an am335x based board, with an
KSZ8081 attached, so there a "fixed-link" is used like:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/arch/arm/boot/dts/am335x-baltos-ir3220.dts#n105

With your patch it crashes also ...

If I remove this part:

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d63d190..9dd08a4 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -921,11 +921,6 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
                 return -EIO;
         }

-       if (!try_module_get(d->driver->owner)) {
-               dev_err(&dev->dev, "failed to get the device driver module\n");
-               return -EIO;
-       }
-
         get_device(d);

         /* Assume that if there is no driver, that it doesn't

it boots again .. I think, you forgot? simply this remove ?

bye,
Heiko
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 0d8f4d3847f6..d63d190a95ef 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -908,6 +908,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>   	struct module *ndev_owner = dev->dev.parent->driver->owner;
>   	struct mii_bus *bus = phydev->mdio.bus;
>   	struct device *d = &phydev->mdio.dev;
> +	bool using_genphy = false;
>   	int err;
>
>   	/* For Ethernet device drivers that register their own MDIO bus, we
> @@ -938,12 +939,22 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>   			d->driver =
>   				&genphy_driver[GENPHY_DRV_1G].mdiodrv.driver;
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
>   		err = d->driver->probe(d);
>   		if (err >= 0)
>   			err = device_bind_driver(d);
>
>   		if (err)
> -			goto error;
> +			goto error_module_put;
>   	}
>
>   	if (phydev->attached_dev) {
> @@ -981,6 +992,9 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>
>   error:
>   	phy_detach(phydev);
> +error_module_put:
> +	module_put(d->driver->owner);
> +error_put_device:
>   	put_device(d);
>   	module_put(d->driver->owner);
>   	if (ndev_owner != bus->owner)
>

-- 
DENX Software Engineering GmbH,      Managing Director: Wolfgang Denk
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
