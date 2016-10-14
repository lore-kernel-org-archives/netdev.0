From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 13:30:15 -0500
Message-ID: <58012437.6010706@codeaurora.org>
References: <20161014040641.GE5822@lunn.ch> <5800C3C7.60705@codeaurora.org>
 <20161014120624.GG5822@lunn.ch> <5800D214.70808@codeaurora.org>
 <20161014124928.GJ5822@lunn.ch> <5800D474.1030303@codeaurora.org>
 <20161014125736.GK5822@lunn.ch> <5800D796.1030602@codeaurora.org>
 <20161014131852.GM5822@lunn.ch> <58010E79.2030607@codeaurora.org>
 <20161014172514.GA23455@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42862 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcJNSqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 14:46:39 -0400
In-Reply-To: <20161014172514.GA23455@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:

> It is normal to get the phy-mode from device tree. I've no idea what
> ACPI is supposed to do. Setting it to PHY_INTERFACE_MODE_NA means you
> assume the boot loader has correctly setup the hardware. You ACPI
> firmware might of done this, but there is no guarantee a device tree
> base bootloader has. So i would prefer not changing this.

Fair enough.  I don't think it's specified anywhere what firmware is 
supposed to do.

What about specifying PHY_INTERFACE_MODE_NA on ACPI systems, but using 
the phy-mode property on device tree systems?  That doesn't sound like a 
great idea.

>> >I don't see any other driver issue BMCR_PDOWN in their functions.  I
>> >added some printks for the PHYSID1 and PHYSID2 registers before and
>> >after BMCR_PDOWN:
>> >
>> >at803x_suspend:235 MII_PHYSID1=004d MII_PHYSID2=d074
>> >at803x_suspend:242 MII_PHYSID1=ffff MII_PHYSID2=ffff
>> >
>> >So after calling BMCR_PDOWN, the PHYSID1 and PHYSID2 registers are
>> >no longer readable.  Is that expected?
> You are making two changes here. Is it the SGMII power down which is
> causing the id registers to return 0xffff, or the BMCR_PDOWN.
>
> The generic suspend code sets the PDOWN bit, so it is assuming the PHY
> will respond afterwards.

Ok, it took me a while to figure this out.  The driver does three writes:

phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
phy_write(phydev, MII_BMCR, phy_read(phydev, MII_BMCR) | BMCR_PDOWN);
phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr | AT803X_BT_BX_REG_SEL);

The first clears the AT803X_BT_BX_REG_SEL bit.  According to the 
datasheet, that changes the register set from copper to fiber mode. 
BMCR_PDOWN in fiber mode shuts off the SerDes bus.  That's not true in 
copper mode.

Then after shutting down SerDes, it switches back to copper mode.

I also noticed the at803x_suspend already sends BMCR_PDOWN in copper 
mode earlier in the function.

So the question remains: should drivers shut down the SerDes bus when 
they suspend?  In a sense, I'm wondering if we should revert

	at803x: fix suspend/resume for SGMII link

However, the changelog for that patch makes it sound like it's a 
necessary fix.

So I'm torn.  With the SerDes connection disabled, the driver no longer 
responds to ID register reads.  That seems like something that would be 
broken on device tree as well, but I don't understand why no one noticed 
it before.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
