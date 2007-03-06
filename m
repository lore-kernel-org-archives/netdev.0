From: Andy Fleming <afleming@freescale.com>
Subject: Re: [patch 1/1] network: add the missing phy_device speed information to phy_mii_ioctl
Date: Tue, 6 Mar 2007 11:33:32 -0600
Message-ID: <28C12DE1-E0BD-4C5E-8DB9-B722F1877BDF@freescale.com>
References: <9FD2C54661D3494AB6F269E0D4A74E83019775E1@DSBEXCLUSTER.ad.uiuc.edu>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<shanlu@uiuc.edu>
To: Shan Lu <shanlu@cs.uiuc.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965384AbXCFRe6@vger.kernel.org>
In-Reply-To: <9FD2C54661D3494AB6F269E0D4A74E83019775E1@DSBEXCLUSTER.ad.uiuc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mar 2, 2007, at 11:42, Shan Lu wrote:

> Changelog:
> Function `phy_mii_ioctl' returns physical device's information  
> based on
> user requests. When requested to return the basic mode control  
> register
> information (BMCR), the original implementation only returns the
> physical device's duplex information and forgets to return speed
> information, which should not be because BMCR register is used to hold
> both duplex and speed information.
>
> The patch checks the BMCR value against speed-related flags and fills
> the return structure's speed field accordingly.


I think you've misunderstood what this code does, though I agree, in  
principle, with your change.  You have modified the SIOCSMIIREG  
command, which takes in a value, and sets the given register to that  
value.  The structure which is being filled in is not being  
returned.  It is the PHY's software representation at runtime.

So this patch probably fixes a bug (I'd have to think harder about it  
to see if phydev->speed doesn't get updated automatically), but  
you've modified the *setting* command, not the *getting* command.

Is there a reason you are using this function to get and set the  
BMCR?  The PHY Lib provides ethtool functions to do this, and they  
fit better with the design of the PHY Lib.  The mii IOCTL allows you  
to change the registers any way you want, which potentially breaks  
the state machine the PHY Lib sets up for tracking such changes.

All that said, I think the change below needs to go in.  See below  
for inline commentary:


>
> Signed-off-by: Shan<shanlu@cs.uiuc.edu>
>
> ---
> --- drivers/net/phy/phy.c   2007-03-02 10:40:26.000000000 -0600   
> 2.6.20
> +++ drivers/net/phy/phy.c   2007-03-02 10:41:39.000000000 -0600
> @@ -337,6 +337,10 @@ int phy_mii_ioctl(struct phy_device *phy
>                                         phydev->duplex = DUPLEX_FULL;
>                                 else
>                                         phydev->duplex = DUPLEX_HALF;
> +                               if ((!phydev->autoneg) && (val
> &BMCR_SPEED1000))
> +                                       phydev->speed = SPEED_1000;
> +                               else if ((!phydev->autoneg) && (val &
> BMCR_SPEED100))
> +                                       phydev->speed = SPEED_100;


Why not also support SPEED_10 if neither bits are set?

Andy
