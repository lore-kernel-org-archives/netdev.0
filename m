From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net 1/4] lan78xx: Fix for crash associated with System
 suspend
Date: Wed, 6 Sep 2017 15:59:08 +0200
Message-ID: <20170906135908.GB11864@lunn.ch>
References: <CE371C1263339941885964188A0225FA333370@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58678 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932209AbdIFN7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 09:59:16 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA333370@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 06, 2017 at 10:51:31AM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Fix for crash associated with System suspend
> 
> Since ndo_stop removes phydev which makes phydev NULL.
> Whenever system suspend is initiated or after "ifconfig <interface> down",
> if set_wol or get_wol is triggered phydev is NULL leads system crash.
> Hence phy_start/phy_stop for ndo_start/ndo_stop fixes the issues
> instead of adding/removing phydevice

Looking at this patch, there apears to be lots of different things
going on. Please can you split it up into multiple patches.

> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 44 ++++++++++++++++++++++++++++----------------
>  1 file changed, 28 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index b99a7fb..955ab3b 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -2024,6 +2024,8 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  						 lan8835_fixup);
>  		if (ret < 0) {
>  			netdev_err(dev->net, "fail to register fixup\n");
> +			phy_unregister_fixup_for_uid(PHY_KSZ9031RNX,
> +						     0xfffffff0);

goto error; would be better. phy_unregister_fixup_for_uid() does not care if you try to unregister
something which has not been registered.

Also, this should be a separate patch. 

>  			return ret;
>  		}
>  		/* add more external PHY fixup here if needed */
> @@ -2031,8 +2033,7 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  		phydev->is_internal = false;
>  	} else {
>  		netdev_err(dev->net, "unknown ID found\n");
> -		ret = -EIO;
> -		goto error;
> +		return -EIO;
>  	}
>  
>  	/* if phyirq is not set, use polling mode in phylib */
> @@ -2051,7 +2052,10 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  	if (ret) {
>  		netdev_err(dev->net, "can't attach PHY to %s\n",
>  			   dev->mdiobus->id);
> -		return -EIO;
> +		ret = -EIO;
> +		if (dev->chipid == ID_REV_CHIP_ID_7801_)
> +			goto error;
> +		return ret;

Why not add the if (dev->chipid == ID_REV_CHIP_ID_7801_) after the
error: label?



>  	}
>  
>  	/* MAC doesn't support 1000T Half */
> @@ -2067,8 +2071,6 @@ static int lan78xx_phy_init(struct lan78xx_net *dev)
>  
>  	dev->fc_autoneg = phydev->autoneg;
>  
> -	phy_start(phydev);
> -
>  	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
>  
>  	return 0;
> @@ -2497,9 +2499,9 @@ static int lan78xx_open(struct net_device *net)
>  	if (ret < 0)
>  		goto done;
>  
> -	ret = lan78xx_phy_init(dev);
> -	if (ret < 0)
> -		goto done;
> +	if (dev->domain_data.phyirq > 0)
> +		phy_start_interrupts(dev->net->phydev);

This is unusual. I don't see any other MAC driver starting interrupts.
This needs explaining.

     Andrew
