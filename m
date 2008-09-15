From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 2/3] phylib: add missing _{check_gmii_support,link_ok,nway_restart}
Date: Mon, 15 Sep 2008 18:03:24 -0500
Message-ID: <3661904F-A16E-4B85-8525-33F72257D1A3@freescale.com>
References: <1220448012-20347-1-git-send-email-buytenh@wantstofly.org> <1220448012-20347-3-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36041 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbYIOXDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 19:03:53 -0400
In-Reply-To: <1220448012-20347-3-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 3, 2008, at 08:20, Lennert Buytenhek wrote:

> drivers/net/mii.c provides a couple of routines which currently have
> no phylib equivalents.  This patch provides those phylib equivalents.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

I think all of this functionality is provided by other parts of the  
phylib.  See below.


> /**
> + * phy_check_gmii_support - check if the PHY supports (R)GMII
> + * @phydev: the phy_device struct
> + */
> +int phy_check_gmii_support(struct phy_device *phydev)
> +{
> +	int retval;
> +
> +	retval = phy_read(phydev, MII_BMSR);
> +	if (retval < 0 || (retval & BMSR_ESTATEN) == 0)
> +		return 0;
> +
> +	retval = phy_read(phydev, MII_ESTATUS);
> +	if (retval < 0)
> +		return 0;
> +
> +	return !!(retval & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF));
> +}
> +EXPORT_SYMBOL(phy_check_gmii_support);


If you look in genphy_config_init() in drivers/net/phy/phy_device.c,  
you'll see that it fills in phydev->supported based on ESTATUS.  So  
this function could be reduced to:

return !!(phydev->supported & (SUPPORTED_1000baseT_Full |  
SUPPORTED_1000baseT_Half));


> +
> +/**
> + * phy_link_ok - is link status up/ok
> + * @phydev: the phy_device struct
> + *
> + * Returns 1 if the PHY reports link status up/ok, 0 otherwise.
> + */
> +int phy_link_ok(struct phy_device *phydev)
> +{
> +	int retval;
> +
> +	/* first, a dummy read, needed to latch some MII phys */
> +	phy_read(phydev, MII_BMSR);
> +
> +	retval = phy_read(phydev, MII_BMSR);
> +	if (retval < 0 || (retval & BMSR_LSTATUS) == 0)
> +		return 0;
> +
> +	return 1;
> +}
> +EXPORT_SYMBOL(phy_link_ok);


genphy_update_link() does everything here except return 0/1.  But it  
fills in phydev->link, which is meant to reflect the current link  
status.


> +
> +/**
> + * phy_nway_restart - restart NWay (autonegotiation) for this  
> interface
> + * @phydev: the phy_device struct
> + *
> + * Returns 0 on success, negative on error.
> + */
> +int phy_nway_restart(struct phy_device *phydev)
> +{
> +	int bmcr;
> +
> +	/* if autoneg is off, it's an error */
> +	bmcr = phy_read(phydev, MII_BMCR);
> +	if (bmcr < 0 || (bmcr & BMCR_ANENABLE) == 0)
> +		return -EINVAL;
> +
> +	if (phy_write(phydev, MII_BMCR, bmcr | BMCR_ANRESTART) < 0)
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(phy_nway_restart);


genphy_restart_aneg() does this, though that's the low-level API for it.

Andy
