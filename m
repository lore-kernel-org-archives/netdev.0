From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 28/46] PHY: remove rwsem use from phy core
Date: Fri, 27 Apr 2007 16:11:52 -0500
Message-ID: <B1DB67A5-F4DA-45D6-94A1-5E4C40F130DF@freescale.com>
References: <20070427185152.GA17121@kroah.com> <1177700040520-git-send-email-gregkh@suse.de> <11777000433552-git-send-email-gregkh@suse.de> <11777000471977-git-send-email-gregkh@suse.de> <11777000511784-git-send-email-gregkh@suse.de> <11777000552084-git-send-email-gregkh@suse.de> <1177700059319-git-send-email-gregkh@suse.de> <11777000632194-git-send-email-gregkh@suse.de> <11777000663361-git-send-email-gregkh@suse.de> <1177700070961-git-send-email-gregkh@suse.de> <1177700074272-git-send-email-gregkh@suse.de> <11777000773819-git-send-email-gregkh@suse.de> <11777000814075-git-send-email-gregkh@suse.de> <11777000852694-git-send-email-gregkh@suse.de> <11777000881307-git-send-email-gregkh@suse.de> <11777000923797-git-send-email-gregkh@suse.de> <11777000963332-git-send-email-gregkh@suse.de> <11777001002860-git-send-email-gregkh@suse.de> <11777001041847-git-send-email-gregkh@suse.de> <1177700107
 2576-git-send-email-gregkh@suse.de> <11777001102852-git-send-email-gregkh@suse.de> <11777!
 00114535-git-send-email-gregkh@suse.de> <11777001182501-git-send-email-gregkh@suse.de> <11777001222882-git-send-email-gregkh@suse.de> <1177700125350-git-send-email-gregkh@suse.de> <11777001301175-git-send-email-gregkh@suse.de> <11777001333852-git-send-email-gregkh@suse.de> <117770013729-git-send-email-gregkh@suse.de> <11777001413571-git-send-email-gregkh@suse.de>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48332 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757309AbXD0VME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 17:12:04 -0400
In-Reply-To: <11777001413571-git-send-email-gregkh@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Apr 27, 2007, at 13:53, Greg Kroah-Hartman wrote:

> The subsystem rwsem is not used by the driver core at all, so the  
> use of
> it in the phy code doesn't make any sense.  They might possibly
> want to use a local lock, but I am unsure about that.
>
> Cc: netdev <netdev@vger.kernel.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

Acked-by: Andy Fleming <afleming@freescale.com>

> ---

I think I copied that code from elsewhere without truly understanding  
it.

*bows head in shame*

As such, I have no objection to this patch unless someone says it  
breaks their board.  :)

>  drivers/net/phy/fixed.c      |    6 ------
>  drivers/net/phy/phy_device.c |    9 +--------
>  2 files changed, 1 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 66da91b..68c99b4 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -276,21 +276,15 @@ static int fixed_mdio_register_device(int  
> number, int speed, int duplex)
>  	   artificially, we are binding the driver here by hand;
>  	   it will be the same for all the fixed phys anyway.
>  	 */
> -	down_write(&phydev->dev.bus->subsys.rwsem);
> -
>  	phydev->dev.driver = &fixed_mdio_driver.driver;
>
>  	err = phydev->dev.driver->probe(&phydev->dev);
>  	if(err < 0) {
>  		printk(KERN_ERR "Phy %s: problems with fixed driver\n",phydev- 
> >dev.bus_id);
> -		up_write(&phydev->dev.bus->subsys.rwsem);
>  		goto probe_fail;
>  	}
>
>  	err = device_bind_driver(&phydev->dev);
> -
> -	up_write(&phydev->dev.bus->subsys.rwsem);
> -
>  	if (err)
>  		goto probe_fail;
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/ 
> phy_device.c
> index 7d5b6d1..8f01952 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -208,16 +208,12 @@ struct phy_device *phy_attach(struct  
> net_device *dev,
>  	 * exist, and we should use the genphy driver. */
>  	if (NULL == d->driver) {
>  		int err;
> -		down_write(&d->bus->subsys.rwsem);
>  		d->driver = &genphy_driver.driver;
>
>  		err = d->driver->probe(d);
> -
>  		if (err >= 0)
>  			err = device_bind_driver(d);
>
> -		up_write(&d->bus->subsys.rwsem);
> -
>  		if (err)
>  			return ERR_PTR(err);
>  	}
> @@ -258,11 +254,8 @@ void phy_detach(struct phy_device *phydev)
>  	 * was using the generic driver), we unbind the device
>  	 * from the generic driver so that there's a chance a
>  	 * real driver could be loaded */
> -	if (phydev->dev.driver == &genphy_driver.driver) {
> -		down_write(&phydev->dev.bus->subsys.rwsem);
> +	if (phydev->dev.driver == &genphy_driver.driver)
>  		device_release_driver(&phydev->dev);
> -		up_write(&phydev->dev.bus->subsys.rwsem);
> -	}
>  }
>  EXPORT_SYMBOL(phy_detach);
>
> -- 
> 1.5.1.2
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

