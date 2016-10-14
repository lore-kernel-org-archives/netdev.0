From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 19:25:14 +0200
Message-ID: <20161014172514.GA23455@lunn.ch>
References: <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org>
 <20161014120624.GG5822@lunn.ch>
 <5800D214.70808@codeaurora.org>
 <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org>
 <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org>
 <20161014131852.GM5822@lunn.ch>
 <58010E79.2030607@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45563 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755455AbcJNRZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 13:25:16 -0400
Content-Disposition: inline
In-Reply-To: <58010E79.2030607@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 11:57:29AM -0500, Timur Tabi wrote:
> Andrew Lunn wrote:
> >That is a basic assumption of the code. If you cannot read the IDs how
> >are you supposed to know what device it is, and what quirks you need
> >to work around its broken features...
> >
> >Does the datasheet say anything about this?
> >
> >I would say for this device, suspend() is too aggressive.
> 
> This change in my driver makes the problem go away (I'm not sure if
> it's a "fix"):
> 
> @@ -992,7 +992,7 @@ int emac_mac_up(struct emac_adapter *adpt)
>         emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
> 
>         ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
> -                                PHY_INTERFACE_MODE_SGMII);
> +                                PHY_INTERFACE_MODE_NA);

It is normal to get the phy-mode from device tree. I've no idea what
ACPI is supposed to do. Setting it to PHY_INTERFACE_MODE_NA means you
assume the boot loader has correctly setup the hardware. You ACPI
firmware might of done this, but there is no guarantee a device tree
base bootloader has. So i would prefer not changing this.
 
> With the interface not set as SGMII, the following code in
> at803x_suspend() is not executed:
> 
> /* also power-down SGMII interface */
> ccr = phy_read(phydev, AT803X_REG_CHIP_CONFIG);
> phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
> phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
> phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);
> 
> I don't see any other driver issue BMCR_PDOWN in their functions.  I
> added some printks for the PHYSID1 and PHYSID2 registers before and
> after BMCR_PDOWN:
> 
> at803x_suspend:235 MII_PHYSID1=004d MII_PHYSID2=d074
> at803x_suspend:242 MII_PHYSID1=ffff MII_PHYSID2=ffff
> 
> So after calling BMCR_PDOWN, the PHYSID1 and PHYSID2 registers are
> no longer readable.  Is that expected?

You are making two changes here. Is it the SGMII power down which is
causing the id registers to return 0xffff, or the BMCR_PDOWN.

The generic suspend code sets the PDOWN bit, so it is assuming the PHY
will respond afterwards.

     Andrew
