From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: RFC: Custom PHY device detection functions
Date: Thu, 5 Jun 2008 11:52:27 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806051152050.3242@t2.domain.actdsltmp>
References: <4847013B.4090408@openwrt.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:50485 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbYFESxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:53:53 -0400
In-Reply-To: <4847013B.4090408@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Jun 2008, Felix Fietkau wrote:
> I'm working on Linux on small consumer grade wireless routers. Many of these 
> have switches that connect directly to the Ethernet controller through 
> MII/MDIO. These typically support 6-8 ports, one of which connects to the 
> CPU. I am working on supporting some of these with PHY drivers, which I will 
> submit for review when they're ready.
> Most of these devices can be detected with the regular PHY ID and mask, but 
> unfortunately there are some that lay out their registers a bit differently 
> and thus need custom detection.
> I worked around this with the following patch, that allows drivers to do 
> their own detection, but I'm not sure if this is suitable for inclusion in 
> the PHY layer or if there is a different way to solve this.
> Any ideas?

If the phy uses non-standard registers, isn't it too late after the phy
layer has already read the phy_id?

If not, could you use the existing probe function?  Set phy_id_mask to 0 and
have the probe function return ENODEV if it's the wrong device.  I think the
driver layer will go through all matching drivers, calling each one's probe
function, until one of them claims the device.

>
> - Felix
>
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -132,6 +132,9 @@
> 	 struct phy_device *phydev = to_phy_device(dev);
> 	 struct phy_driver *phydrv = to_phy_driver(drv);
>
> +	if (phydrv->detect)
> +		return (phydrv->detect(phydev->bus, phydev->addr));
> +
> 	 return ((phydrv->phy_id & phydrv->phy_id_mask) ==
>  		(phydev->phy_id & phydrv->phy_id_mask));
> }
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -325,6 +325,11 @@
> 	 u32 features;
> 	 u32 flags;
>
> +	/* Called during discovery to test if the
> +	 * device can attach to the bus, even if
> +	 * phy id and mask do not match */
> +	bool (*detect)(struct mii_bus *bus, int addr);
> +
> 	 /* Called to initialize the PHY,
> 	 * including after a reset */
> 	 int (*config_init)(struct phy_device *phydev);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
