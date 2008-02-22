From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH RFC] phylib: fix forced mode misbehaviour for aneg off case
Date: Fri, 22 Feb 2008 11:40:04 -0600
Message-ID: <B1C15E4A-AA44-46E4-831A-698317E5F677@freescale.com>
References: <20080222155524.GA6623@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57771 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753618AbYBVRkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 12:40:19 -0500
In-Reply-To: <20080222155524.GA6623@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 22, 2008, at 09:55, Anton Vorontsov wrote:

> When user disabled autonegotiation via ethtool, and no link is  
> detected,
> phylib will place phy into forcing mode, and then will start calling
> phy_force_reduction(). This will break user expectations. For example,
> user asks for fixed speed 1000:
>
> ethtool -s eth0 autoneg off speed 1000
>
> Without link attached what will actually happen is:
>
> Trying 100/FULL
> Trying 100/HALF
> Trying 10/FULL
> Trying 10/HALF
> ...


The intent of phy_force_reduction() was to provide a fallback in case  
the user unknowingly selects a speed that is not possible with the  
current link partner.  For instance, if you try to select gigabit on  
a 100MB link, it wouldn't work, but because of the way the code was  
designed, the phylib will find a link configuration that works.

However, I agree that it's not ideal to have the phylib spending a  
lot of time looking for a link if there's not one there.  On the  
other hand, why is the user trying to force the link to a certain  
speed if there's no link?

I'm not really opposed to it, though.


>
> This patch implements "software autonegotiation" that is equivalent to
> current behaviour, but enabled only when hardware autonegotiation was
> enabled and failed afterwards. With aneg disabled, phylib will not try
> other link setups.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---


>
> @@ -447,7 +451,8 @@ int phy_start_aneg(struct phy_device *phydev)
>  			phydev->link_timeout = PHY_AN_TIMEOUT;
>  		} else {
>  			phydev->state = PHY_FORCING;
> -			phydev->link_timeout = PHY_FORCE_TIMEOUT;
> +			if (AUTONEG_SOFT == phydev->autoneg)
> +				phydev->link_timeout = PHY_FORCE_TIMEOUT;
>  		}
>  	}


I'm worried that phydev->link_timeout may end up being left in an  
unknown state here.  Are you expecting it to be 0?  If so, I think it  
would be best to set it to 0 in an if clause.

>
>
> @@ -904,7 +909,7 @@ static void phy_state_machine(struct  
> work_struct *work)
>  			if (phydev->link) {
>  				phydev->state = PHY_RUNNING;
>  				netif_carrier_on(phydev->attached_dev);
> -			} else {
> +			} else if (AUTONEG_SOFT == phydev->autoneg) {
>  				if (0 == phydev->link_timeout--) {
>  					phy_force_reduction(phydev);
>  					needs_aneg = 1;


Especially since this will, I believe, leave link_timeout at -1

Andy
