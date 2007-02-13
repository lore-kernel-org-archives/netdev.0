From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] RFC: Broadcom PHY forcing fix
Date: Mon, 12 Feb 2007 18:47:18 -0600
Message-ID: <4CFF5416-F371-48F4-8B43-DD6780CD593F@freescale.com>
References: <Pine.LNX.4.64.0701251718270.4944@gate.crashing.org> <Pine.LNX.4.64N.0701261426040.15582@blysk.ds.pg.gda.pl>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35189 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933010AbXBMAv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 19:51:26 -0500
In-Reply-To: <Pine.LNX.4.64N.0701261426040.15582@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jan 26, 2007, at 08:36, Maciej W. Rozycki wrote:

> Kumar,
>
>> I've got a BCM5461 that requires this fix to be able to force the  
>> speeds
>> on the PHY.  Not sure if its needed on the other variants or not.   
>> The
>> problem is the genphy_config_aneg resets the PHY when forcing the  
>> speed
>> and once we reset the BCM5461 it doesn't remember any of its  
>> settings.
>
>  I recall seeing a similar problem before and having checked with  
> the IEEE
> spec I believe it's the generic code that is incorrect.  Following  
> is my
> fix to address this problem.  Please try and see if it works for you.
>
>  I am waiting for 2.6.20 to happen before I recheck my list of patches
> related to the BCM1250 MAC and the PHY library and (re)submit  
> whatever is
> still relevant.  This patch is one of candidates.


I'm sifting through patches, and rediscovered this one waiting  
around.  I'm mostly happy with it, but I have a few questions...


>
>   Maciej
>
> patch-mips-2.6.18-20060920-phy-forcing-1
> diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/ 
> drivers/net/phy/phy.c linux-mips-2.6.18-20060920/drivers/net/phy/phy.c
> --- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy.c	 
> 2006-08-05 04:58:46.000000000 +0000
> +++ linux-mips-2.6.18-20060920/drivers/net/phy/phy.c	2006-09-25  
> 03:03:45.000000000 +0000
> @@ -713,6 +713,8 @@ static void phy_timer(unsigned long data
>  				} else {
>  					phydev->state = PHY_NOLINK;
>  					netif_carrier_off(phydev->attached_dev);
> +					phydev->link_timeout =
> +						PHY_NOLINK_TIMEOUT;


What's the purpose of a NOLINK timeout?  What problem is this  
solving?  I'd prefer not to constantly restart AN every 3 seconds  
when the link is actually down.  Do we need the autoneg code to wait  
a few seconds before it considers a link state of 0 valid?


> diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/ 
> drivers/net/phy/phy_device.c linux-mips-2.6.18-20060920/drivers/net/ 
> phy/phy_device.c
> --- linux-mips-2.6.18-20060920.macro/drivers/net/phy/phy_device.c	 
> 2006-09-20 20:50:26.000000000 +0000
> +++ linux-mips-2.6.18-20060920/drivers/net/phy/phy_device.c	 
> 2006-09-25 01:51:34.000000000 +0000
> @@ -325,10 +325,18 @@ EXPORT_SYMBOL(genphy_config_advert);
>   *   Please see phy_sanitize_settings() */
>  int genphy_setup_forced(struct phy_device *phydev)
>  {
> -	int ctl = BMCR_RESET;
> +	int ctl;
>
>  	phydev->pause = phydev->asym_pause = 0;
>
> +	ctl = phy_read(phydev, MII_BMCR);
> +
> +	ctl &= ~(BMCR_ANENABLE | BMCR_ANRESTART);
> +
> +	ctl &= ~(BMCR_ISOLATE);
> +
> +	ctl &= ~(BMCR_SPEED1000 | BMCR_SPEED100 | BMCR_FULLDPLX);
> +


This is fine, but I'm wondering if it's really necessary to go  
through all this effort just to preserve the values of RESET,  
LOOPBACK, POWER, and collision test.  I agree, in principle, it's  
probably more robust, though.  But can we perhaps make a constant like:

#define BMCR_FORCE_MASK (all the bits we want to keep)

And then use that?  Or do it all in one line?  It just feels a little  
clunky to me this way (Just my own sense of code aesthetics).


Andy


