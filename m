From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix PHY polling system blocking
Date: Fri, 12 Mar 2010 14:42:48 -0800
Message-ID: <20100312144248.ade8b700.akpm@linux-foundation.org>
References: <1267894258.18869.2.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267894258.18869.2.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 Mar 2010 17:50:58 +0100
Stefani Seibold <stefani@seibold.net> wrote:

> This patch fix the PHY poller, which can block the whole system. On a
> Freescale PPC 834x this result in a delay of 450 us due the slow
> communication with the PHY chip.
> 
> For PHY chips without interrupts, the status of the ethernet will be
> polled every 2 sec. The poll function will read some register of the MII
> PHY. The time between the sending the MII_READ_COMMAND and receiving the
> result is more the 100 us on a PPC 834x.
>    
> The patch modifies the poller a lit bit. Only a link status state change
> will result in a successive detection of the connection type. The poll
> cycle on the other hand will be increased to every seconds.

You didn't tell us how many seconds.  That would be important?

> Together this patch will prevent a blocking of nearly 400 us every two
> seconds of the whole system on a PPC 834x.
> 

I can't say that I really understand what you did - what functionality
did we lose?

Would it not be better to extend the phy state machine a bit?  When we
detect the link status change, issue the MII command then arm the
delayed-work timer to expire in a millisecond, then go in next time and
read the result?

That might require fancy locking to prevent other threads of control
from going in and mucking up the MII state.  Possibly leave phydev_lock
held across that millisecond to keep other people away?

> 
> ...
> 
> diff -u -N -r -p linux-2.6.33.orig/drivers/net/phy/phy.c linux-2.6.33/drivers/net//phy/phy.c
> --- linux-2.6.33.orig/drivers/net/phy/phy.c	2010-02-24 19:52:17.000000000 +0100
> +++ linux-2.6.33/drivers/net//phy/phy.c	2010-02-28 22:53:14.725464101 +0100

erp, your weird patch headers ("//") broke my seven-year-old script. 
But I fixed it!

> @@ -871,9 +871,8 @@ void phy_state_machine(struct work_struc
>  		case PHY_RUNNING:
>  			/* Only register a CHANGE if we are
>  			 * polling */
> -			if (PHY_POLL == phydev->irq)
> -				phydev->state = PHY_CHANGELINK;
> -			break;
> +			if (PHY_POLL != phydev->irq)
> +				break;
>  		case PHY_CHANGELINK:
>  			err = phy_read_status(phydev);
>  
> diff -u -N -r -p linux-2.6.33.orig/drivers/net/phy/phy_device.c linux-2.6.33/drivers/net//phy/phy_device.c
> --- linux-2.6.33.orig/drivers/net/phy/phy_device.c	2010-02-24 19:52:17.000000000 +0100
> +++ linux-2.6.33/drivers/net//phy/phy_device.c	2010-02-28 22:53:14.726464145 +0100
> @@ -161,7 +161,7 @@ struct phy_device* phy_device_create(str
>  	dev->speed = 0;
>  	dev->duplex = -1;
>  	dev->pause = dev->asym_pause = 0;
> -	dev->link = 1;
> +	dev->link = 0;
>  	dev->interface = PHY_INTERFACE_MODE_GMII;
>  
>  	dev->autoneg = AUTONEG_ENABLE;
> @@ -694,10 +694,16 @@ int genphy_update_link(struct phy_device
>  	if (status < 0)
>  		return status;
>  
> -	if ((status & BMSR_LSTATUS) == 0)
> +	if ((status & BMSR_LSTATUS) == 0) {
> +		if (phydev->link==0)
> +			return 1;
>  		phydev->link = 0;
> -	else
> +	}
> +	else {
> +		if (phydev->link==1)
> +			return 1;
>  		phydev->link = 1;
> +	}

Please don't invent new coding styles.  scripts/checkpatch.pl is here
to help.
