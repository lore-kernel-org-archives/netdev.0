From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Thu, 12 Jan 2017 22:49:41 +0100
Message-ID: <20170112214941.GE10203@lunn.ch>
References: <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
 <20170111225948.GH13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
 <20170111232200.GI13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B66@DFLE11.ent.ti.com>
 <20170112010658.GA25391@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354EB0@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58798 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750760AbdALVtr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 16:49:47 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354EB0@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But our problem is caused by the read_status function:
> 
> 	if ((phydev->supported & SUPPORTED_FIBRE)) {
> 		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
> 		if (err < 0)
> 			goto error;
> 		
> 		err = marvell_read_status_page(phydev, MII_M1111_FIBER);
> 		if (err < 0)
> 			goto error;
> 		
> 		/* If the fiber link is up, it is the selected and used link.
> 		* In this case, we need to stay in the fiber page.
> 		* Please to be careful about that, avoid to restore Copper page
> 		* in other functions which could break the behaviour
> 		* for some fiber phy like 88E1512.
> 		* */
> 		if (phydev->link)
> 			return 0;
> 
> which keeps the fiber page if phydev->link is true (for some
> reason this is the case even though we are not using fiber)

How are you using the PHY. What phy-mode do you have set?  Do you
happen to be using it as an RGMII to SERDES/SGMII bridge? This is what
Russell King is doing, i think.

Have you tried the patch Russell submitted recently.

Author: Russell King <rmk+kernel@armlinux.org.uk>
Date:   Tue Jan 10 23:13:45 2017 +0000

    net: phy: marvell: fix Marvell 88E1512 used in SGMII mode
    
    When an Marvell 88E1512 PHY is connected to a nic in SGMII mode, the
    fiber page is used for the SGMII host-side connection.  The PHY driver
    notices that SUPPORTED_FIBRE is set, so it tries reading the fiber page
    for the link status, and ends up reading the MAC-side status instead of
    the outgoing (copper) link.  This leads to incorrect results reported
    via ethtool.
    
    If the PHY is connected via SGMII to the host, ignore the fiber page.
    However, continue to allow the existing power management code to
    suspend and resume the fiber page.

> However, this causes a problem in kernel reboot because neither
> the suspend/resume is called to restore the copper page and
> u-boot marvell phy driver does not support 1510 fiber, which
> will then result in writing to the wrong phy regs and causes
> a sgmii auto-nego time out.

This is still a u-boot bug. It should not assume the PHY is in a sane
state. It should reset it and configure it as needed. So far, i don't
think you have reported any issues with Linux usage of the PHY. There
clearly are bugs, but your real problem is u-boot.

> In addition to fixing the ! in suspend/resume, my suggestion
> would be to change also the read_status function to
> always restore the copper page after doing the fiber stuffs:

Nope. This is done deliberately, as the comment suggests:

> 		/* If the fiber link is up, it is the selected and used link.
> 		* In this case, we need to stay in the fiber page.
> 		* Please to be careful about that, avoid to restore Copper page
> 		* in other functions which could break the behaviour
> 		* for some fiber phy like 88E1512.
> 		* */
> 		if (phydev->link)
> 			return 0;

The point is, the phylib will continue polling the PHY registers,
reading them. If the FIBRE is up, we want to read the FIBRE values,
not the copper.

> Another issue is that, as of now, FIBER is enabled regardless
> of the specific 88e151x. But I believe there is 88e151x chip(s)
> that does not support fiber. Should fiber be enabled only for
> those that do support fiber?

Yes, we should look at register 30, page 18 any set SUPPORTED_FIBRE
based on that.

      Andrew
