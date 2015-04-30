From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 14:46:01 +0200
Message-ID: <20150430124601.GA22831@lunn.ch>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
 <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dave@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44585 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbbD3Mum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 08:50:42 -0400
Content-Disposition: inline
In-Reply-To: <1430359064-23454-8-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* Read the switch identifier register using the special Port register, and if
> + * successful, override the PHY ID for this device
> + */
> +static int mv88e6060_phy_fixup(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* Marvell switches should be accessed using MDIO address 16 */
> +	if (phydev->addr != 16)
> +		return 0;
> +
> +	ret = mdiobus_read(phydev->bus, REG_PORT(0), 0x03) &
> +			   MV88E6060_MAGIC_MASK;
> +	if (ret != MV88E6060_MAGIC)
> +		return 0;
> +
> +	phydev->phy_id = MV88E6060_MAGIC;
> +
> +	return 0;
> +}

Hi Florian

The 6060 datasheet is the only public one. It talks a little bit about
this. The switch can either use addresses 0-15, or 16-31, depending on
EE_CLK/ADDR4 pin. So your first check needs expanding.

The other chips have two different addressing modes, depending on pins
at reset time. They can be similar to the 6060, using a large number
of registers over a number of MDIO addresses. Or they can use two
registers at a configurable MDIO address, with these two registers
being Operation and Data. You access all the real switch registers
indirectly. Probing such a setup could be destructive, you need to
perform writes to register address 0 and 1, which if it is a real phy,
not a switch, means writing to its control register and status
register. So i guess before doing this, we need to read phyid1 and
phyid2, and only do such a probe if we get 0xffff for both.

I guess we need to see how problematic this is, before we can modify
all the drivers to probe like this. I do have hardware using this
indirect mode, so i can do some testing.

    Andrew
