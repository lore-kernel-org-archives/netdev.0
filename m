From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Wed, 14 May 2008 01:02:51 +0100 (BST)
Message-ID: <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
References: <1210695378.13845.362.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirk.serum.com.pl ([213.77.9.205]:64816 "EHLO serum.com.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754828AbYENACy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 20:02:54 -0400
In-Reply-To: <1210695378.13845.362.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nate,

> Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
> appropriate dev_flags are passed in to phy_connect().  This is
> needed when the PHY is used for fiber and backplane connections.
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> ---

 Thanks for your changes -- they do not seem to break my system, but I
have no way to verify your additions at the run time as I only have
BCM5421 PHYs to try with.  A few comments follow.

> Note: This contains a few "magic" numbers/bits which are documented
> in the comments.  I neglected making #defines for all of these to
> keep the change size down, but I'm willing to make them if people want
> it enough.  Most are probably 5482 specific.

 Please do provide these macros!  The size does not matter (duh, what a
truism!).  What really matters is the meaning of the numbers.  What seems
obvious now, may not be such a couple of changes into the future.  
Besides, it is much more effective to grep, etc. for macros than for
numbers.

 We have magic numbers elsewhere, true, but they are results of
reverse-engineering, so the exact meaning is unknown.  Of course if you
have a possibility to document them properly, you are welcome to do so.
But for everything that's known, let's keep the code as it should be from
the beginning.

> +#define MII_BCM54XX_RSV0	0x15	/* Reserved / Expansion registers */

 Hmm, the name seems confusing -- is it the manufacturer's official name
of the register?  Based on the semantics I would call it
MII_BCM54XX_EXP_DATA or suchlike.

> +#define MII_BCM54XX_EXP		0x17	/* Expansion register access */

 And then perhaps MII_BCM54XX_EXP_SEL for consistency.

> +	return phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_WRITE
> +		| MII_BCM54XX_SHD_VAL(shadow)
> +		| MII_BCM54XX_SHD_DATA(val));

 Formatting, please -- Linux wants operators at the end of the line and 
indentation to mark where the continuation correlates to the line above.  
In this case either:

	return phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_WRITE |
						  MII_BCM54XX_SHD_VAL(shadow) |
						  MII_BCM54XX_SHD_DATA(val));

or:

	return phy_write(phydev, MII_BCM54XX_SHD,
			 MII_BCM54XX_SHD_WRITE | MII_BCM54XX_SHD_VAL(shadow) |
			 MII_BCM54XX_SHD_DATA(val));

I have a preference within the two and there are other acceptable
variations, but I won't influence you. ;-)

> +	phy_write(phydev, MII_BCM54XX_EXP,
> +			(sec_serdes ? MII_BCM54XX_EXP_SSD : MII_BCM54XX_EXP_ER)
> +			| regnum);

 Likewise:

	phy_write(phydev, MII_BCM54XX_EXP, (sec_serdes ? MII_BCM54XX_EXP_SSD :
						         MII_BCM54XX_EXP_ER) |
					   regnum);

or:

	phy_write(phydev, MII_BCM54XX_EXP,
		  (sec_serdes ? MII_BCM54XX_EXP_SSD : MII_BCM54XX_EXP_ER) |
		  regnum);


> +static inline int
> +bcm54xx_exp_write(struct phy_device *phydev, int sec_serdes, u8 regnum, u16 val)

 Hmm, you have reached the 80th column -- that causes problems sometimes,
I would wrap the arguments.

> +		bcm54xx_shadow_write(phydev, 0x14,
> +			bcm54xx_shadow_read(phydev, 0x14) | 0x9);

 Similarly:

		bcm54xx_shadow_write(phydev, 0x14,
				     bcm54xx_shadow_read(phydev, 0x14) | 0x9);

I think these all fit, but:

		reg = bcm54xx_shadow_read(phydev, 0x14);
		bcm54xx_shadow_write(phydev, 0x14, reg | 0x9);

would be good otherwise.

> +	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
> +		/*
> +		 * Only link status matters for 1000Base-X mode, so force
> +		 * 1000 Mbit/s full-duplex status
> +		 */
> +		if (phydev->link) {
> +			phydev->speed = SPEED_1000;
> +			phydev->duplex = DUPLEX_FULL;
> +		}
> +	}

 Hmm, out of curiosity -- does such enforcement play well with tools like 
ethtool or mii-tool?

  Maciej
