From: Andy Fleming <afleming@freescale.com>
Subject: Re: Marvell PHY driver fix
Date: Fri, 22 Feb 2008 11:25:42 -0600
Message-ID: <B35B214F-5E9F-4DAA-8F74-41ACDC8480FA@freescale.com>
References: <20080222143409.GA1477@ru.mvista.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	"Mark A. Greer" <mgreer@mvista.com>
To: Alexandr Smirnov <asmirnov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48888 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbYBVR1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 12:27:05 -0500
In-Reply-To: <20080222143409.GA1477@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 22, 2008, at 08:34, Alexandr Smirnov wrote:

> Marvell PHY m88e1111 (not sure about other models, but think they  
> too) works in
> two modes: fiber and copper. In Marvell PHY driver (that we have in  
> current
> community kernels) code supported only copper mode, and this is not  
> configurable,
> bits for copper mode are simply written in registers during PHY
> initialization. This patch adds support for both modes.

Excellent.  I've known about this problem for a while, but haven't  
been able to look into it.

However, some comments below

>
> Signed-off-by: Alexandr Smirnov <asmirnov@ru.mvista.com>
>
> diff -pruN powerpc.orig/drivers/net/phy/marvell.c powerpc/drivers/ 
> net/phy/marvell.c
> --- powerpc.orig/drivers/net/phy/marvell.c	2008-02-07  
> 14:59:32.000000000 +0300
> +++ powerpc/drivers/net/phy/marvell.c	2008-02-19 21:47:34.000000000  
> +0300
> @@ -58,9 +58,28 @@

>
> +#define MII_M1111_PHY_CR		0
> +#define MII_M1111_SOFTWARE_RESET	0x8000

You don't need to do this.  There are already constants for both of  
those values.  That's a standard register.

>
>
>  MODULE_DESCRIPTION("Marvell PHY driver");
>  MODULE_AUTHOR("Andy Fleming");
> @@ -141,12 +160,22 @@ static int marvell_config_aneg(struct ph
>  static int m88e1111_config_init(struct phy_device *phydev)
>  {
>  	int err;
> +	int temp;
> +	int mode;
> +
> +	/* Enable Fiber/Copper auto selection */
> +	temp = phy_read(phydev, MII_M1111_PHY_EXT_SR);
> +	temp |= MII_M1111_HWCFG_FIBER_COPPER_AUTO;
> +	phy_write(phydev, MII_M1111_PHY_EXT_SR, temp);
> +
> +	temp = phy_read(phydev, MII_M1111_PHY_CR);
> +	temp |= MII_M1111_SOFTWARE_RESET;
> +	phy_write(phydev, MII_M1111_PHY_CR, temp);


Use the standard constants from mii.h (MII_BMCR, and BMCR_RESET)


>
>
>
>  		temp &= ~(MII_M1111_HWCFG_MODE_MASK);
> -		temp |= MII_M1111_HWCFG_MODE_RGMII;
> +
> +		mode = phy_read(phydev, MII_M1111_PHY_EXT_CR);
> +		mode = (mode & MII_M1111_HWCFG_FIBER_COPPER_RES) >> 13;
> +
> +		switch (mode) {
> +		case MII_M1111_COPPER:
> +			temp |= MII_M1111_HWCFG_MODE_COPPER_RGMII;
> +			break;
> +		case MII_M1111_FIBER:
> +			temp |= MII_M1111_HWCFG_MODE_FIBER_RGMII;
> +		}


I think using a switch statement on a single bit is probably  
overkill.  Much clearer, I think, if you do:

mode = phy_read(phydev, MII_M1111_PHY_EXT_CR);

if (mode & MII_M1111_HWCFG_FIBER_COPPER_RES)
	temp |= MII_M1111_HWCFG_MODE_FIBER_RGMII;
else
	temp |= MII_M1111_HWCFG_MODE_COPPER_RGMII;


>
> +/* marvell_read_status
> + *
> + * Generic status code does not detect Fiber correctly!


After looking at the manual for the 88e1111, I think there may be a  
way to continue using the generic code, rather than replicating the  
generic code with slightly different values.  It looks like the  
problem isn't that Fiber disobeys the MIIM standard, but that it uses  
a paging mechanism to determine whether it's the Fiber Status/Control  
or the Copper Status/Control.  Many of the registers exist in both  
pages, but those two don't.  However, based on this, it seems  
reasonable to use the detected mode (fiber/copper) to determine  
whether we should be operating out of page 0 or 1.

Could you try making sure that register 22[7:0] = 0x1 for fiber, and  
see if you can then just use the standard genphy_read_status()?

Andy
