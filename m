From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix a bug in get_phy_c45_ids
Date: Sun, 01 Nov 2015 12:14:01 -0500 (EST)
Message-ID: <20151101.121401.1787201985789532795.davem@davemloft.net>
References: <1446109777-14846-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbbKAROD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 12:14:03 -0500
In-Reply-To: <1446109777-14846-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Thu, 29 Oct 2015 17:09:37 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> When probing devices-in-package for a c45 phy, device zero is the last
> device to probe, in a rare situation which driver can read a '0' from
> the device zero, thus c45_ids->devices_in_package is set to '0', so the
> loop condition of probing is matched, see codes below:
> 
> for (i = 1;i < num_ids && c45_ids->devices_in_package == 0;i++)
> 
> driver will run in a dead loop.
> 
> So after probing the device zero, driver should stop the probing loop.
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>

This bug only exists because the loop is extremely confusing.

Please fix this by restructuring the loop:

1) Break out this code:

		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
		phy_reg = mdiobus_read(bus, addr, reg_addr);
		if (phy_reg < 0)
			return -EIO;
		c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;

		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS1;
		phy_reg = mdiobus_read(bus, addr, reg_addr);
		if (phy_reg < 0)
			return -EIO;
		c45_ids->devices_in_package |= (phy_reg & 0xffff);

   into a helper function that takes "c45_ids, bus, addr, i" as arguments
   and returns an error, either 0 or -EIO.  Call it "phy_check_devs_in_pkg"
   or similar.

2) Rewrite the loop as:

	for (i = 1;
	     i < num_ids && c45_ids->devices_in_package == 0;
	     i++) {
		err = phy_check_devs_in_pkg(c45_ids, bus, addr, i);
		if (err < 0)
			return err;
		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
			if (i) {
				/*  If mostly Fs, there is no device there,
				 *  then let's continue to probe more, as some
				 *  10G PHYs have zero Devices In package,
				 *  e.g. Cortina CS4315/CS4340 PHY.
				 */
				err = phy_check_devs_in_pkg(c45_ids, bus, addr, 0);
				if (err)
					return err;
				break;
			}
		} else {
				/* no device there, let's get out of here */
				*phy_id = 0xffffffff;
				return 0;
			}
		}
	}

Thanks.
