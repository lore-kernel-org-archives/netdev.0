From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH/RFC v1 10/12] [MIPS] BCM63XX: Add integrated ethernet PHY support for phylib.
Date: Tue, 21 Oct 2008 12:08:54 -0500
Message-ID: <B812781E-031F-4A1E-8FDB-E0482F495325@freescale.com>
References: <1224382023-24412-1-git-send-email-mbizon@freebox.fr>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:48047 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbYJURJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 13:09:20 -0400
In-Reply-To: <1224382023-24412-1-git-send-email-mbizon@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Oct 18, 2008, at 21:07, Maxime Bizon wrote:

> Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
> ---
> drivers/net/phy/Kconfig   |    6 ++
> drivers/net/phy/Makefile  |    1 +
> drivers/net/phy/bcm63xx.c |  132 ++++++++++++++++++++++++++++++++++++ 
> +++++++++
> 3 files changed, 139 insertions(+), 0 deletions(-)
> create mode 100644 drivers/net/phy/bcm63xx.c
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index d55932a..a5d2c2d 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -56,6 +56,12 @@ config BROADCOM_PHY
> 	  Currently supports the BCM5411, BCM5421, BCM5461, BCM5464, BCM5481
> 	  and BCM5482 PHYs.
>
> +config BCM63XX_PHY
> +	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
> +	depends on BCM63XX


This is probably right, but just to check: These PHYs will never be  
used outside of the BCM63xx family?


>
> +	---help---
> +	  Currently supports the 6348 and 6358 PHYs.
> +
> config ICPLUS_PHY
> 	tristate "Drivers for ICPlus PHYs"
> 	---help---
> diff --git a/drivers/net/phy/bcm63xx.c b/drivers/net/phy/bcm63xx.c
> new file mode 100644
> index 0000000..4fed95e

> +static int bcm63xx_config_init(struct phy_device *phydev)
> +{
> +	int reg, err;
> +
> +	reg = phy_read(phydev, MII_BCM63XX_IR);
> +	if (reg < 0)
> +		return reg;
> +
> +	/* Mask interrupts globally.  */
> +	reg |= MII_BCM63XX_IR_GMASK;
> +	err = phy_write(phydev, MII_BCM63XX_IR, reg);
> +	if (err < 0)
> +		return err;
> +
> +	/* Unmask events we are interested in  */
> +	reg = ~(MII_BCM63XX_IR_DUPLEX |
> +		MII_BCM63XX_IR_SPEED |
> +		MII_BCM63XX_IR_LINK) |
> +		MII_BCM63XX_IR_EN;

You just cleared the global interrupt mask.  I have two problems with  
that:

1) If there's some reason you need to mask and then unmask interrupts,  
you should make that clear in the comments.  If there's not a reason,  
then it's a bit silly to do both.

2) Interrupts should not be enabled until the PHY's config_intr()  
function is called, and asks for them to be enabled.

Maybe you just wanted that to be:

  reg &= ~(MII_BCM63XX_IR_DUPLEX |
...


The other comment I have is that these probably should go in the  
broadcom.c file.  I'm not deeply tied to the notion of one file per  
company, but it has become the way it is done.

Andy
