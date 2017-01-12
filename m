From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Thu, 12 Jan 2017 21:41:40 +0000
Message-ID: <20170112214140.GM14217@n2100.armlinux.org.uk>
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
Cc: Andrew Lunn <andrew@lunn.ch>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:34752 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdALVnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 16:43:00 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354EB0@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 09:31:27PM +0000, Kwok, WingMan wrote:
> 
> > > I double checked that ours is actually a 88E1514. According
> > > to Marvell's brief description, it seems that it does support
> > > fiber.
> > >
> > > Reading page 18 reg 30 returns 6.
> > 
> > O.K, that is consistent. Looking at the Marvell SDK:
> > 
> > phy/Include/madApiDefs.h:#define    MAD_SUB_88E1510  4   /* 88E1510 */
> > phy/Include/madApiDefs.h:#define    MAD_SUB_88E1518  5   /* 88E1518 */
> > phy/Include/madApiDefs.h:#define    MAD_SUB_88E1512  6   /*
> > 88E1512/88E1514 */
> > 
> > I took another look at the patch adding Fibre support. The
> > suspend/resume functions are wrong.
> > 
> >         /* Suspend the fiber mode first */
> >         if (!(phydev->supported & SUPPORTED_FIBRE)) {
> > 
> > The ! should not be there. Does removing them both fix your problem?
> > 
> 
> Hi Andrew,
> 
> Thanks for taking the time to look into those patches. Yes we notice
> the error in the suspend/resume functions also.
> 
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

See below.

> However, this causes a problem in kernel reboot because neither
> the suspend/resume is called to restore the copper page and
> u-boot marvell phy driver does not support 1510 fiber, which
> will then result in writing to the wrong phy regs and causes
> a sgmii auto-nego time out.

So what we need to do is to have a .shutdown function installed - but
it's not that simple...

	.mdiodrv = {
		.driver = {
			.shutdown = mv88e1512_shutdown,
		},
	},

in the appropriate phy_driver array element, and then have:

static void mv88e1512_shutdown(struct device *dev)
{
	struct phy_device *phydev = to_phy_device(dev);

	phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_COPPER);
}

which will restore the copper page on non-emergency reboots.  For
emergency reboots, we're out of luck... the real fix would be for
uboot to ensure that when it detects this PHY, it ensures that the
right page is selected.

Now, that all said, there's a bug in this code, which is fixed by
a patch I recently submitted.  If you have an 88E151x connected via
SGMII, then the read_status function incorrectly believes it should
be reading from the fiber page - when in fact the fiber page is
reporting the status of the host-side link.  So, before trying the
above modification, please try this patch - it's already been merged
into the net tree, so should hit -rc soon.

My guess from what you've said above is that your 88E151x is connected
via SGMII, so you need the patch below rather than trying to install
a shutdown function.

8<====
From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: phy: marvell: fix Marvell 88E1512 used in SGMII mode

When an Marvell 88E1512 PHY is connected to a nic in SGMII mode, the
fiber page is used for the SGMII host-side connection.  The PHY driver
notices that SUPPORTED_FIBRE is set, so it tries reading the fiber page
for the link status, and ends up reading the MAC-side status instead of
the outgoing (copper) link.  This leads to incorrect results reported
via ethtool.

If the PHY is connected via SGMII to the host, ignore the fiber page.
However, continue to allow the existing power management code to
suspend and resume the fiber page.

Fixes: 6cfb3bcc0641 ("Marvell phy: check link status in case of fiber link.")
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/marvell.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 6ad76829c7cd..04e439ad5cff 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1190,7 +1190,8 @@ static int marvell_read_status(struct phy_device *phydev)
 	int err;
 
 	/* Check the fiber mode first */
-	if (phydev->supported & SUPPORTED_FIBRE) {
+	if (phydev->supported & SUPPORTED_FIBRE &&
+	    phydev->interface != PHY_INTERFACE_MODE_SGMII) {
 		err = phy_write(phydev, MII_MARVELL_PHY_PAGE, MII_M1111_FIBER);
 		if (err < 0)
 			goto error;
-- 
2.7.4


-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
