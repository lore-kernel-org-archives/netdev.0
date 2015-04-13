From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Sun, 12 Apr 2015 20:42:01 -0400 (EDT)
Message-ID: <20150412.204201.2242904202939074517.davem@davemloft.net>
References: <1428657020-11191-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com
To: Shengzhou.Liu@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428657020-11191-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Date: Fri, 10 Apr 2015 17:10:20 +0800

>  		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
> -			*phy_id = 0xffffffff;
> -			return 0;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | 6;
> +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> +			if (phy_reg < 0)
> +				return -EIO;

Why are you reading this same register again, and why are you doing
it with the magic constant "6".  That's not '6', it's 'MDIO_DEVS2'.

The first loop executed here should have read from this address, and
placed the value into the ->devices_in_package.

> +			c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | 5;

Again, this isn't '5', it's 'MDIO_DEVS1'.

This looks really like a hack.  You're reading again the same registers,
by hand, that the loop should already be reading properly.

Why not restructure the loop to actually probe naturally for the
presence bits in a way that works on the chip you are trying to make
work?
