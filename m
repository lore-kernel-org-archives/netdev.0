From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 4/4] sky2: Adapt sky2 to use reworked PCI PM
Date: Fri, 25 Jul 2008 17:18:13 +0200
Message-ID: <200807251718.13918.rjw@sisk.pl>
References: <200807191436.40726.rjw@sisk.pl> <200807241352.18947.jbarnes@virtuousgeek.org> <20080724165016.7be588e9@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:49198 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbYGYPQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 11:16:04 -0400
In-Reply-To: <20080724165016.7be588e9@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 25 of July 2008, Stephen Hemminger wrote:
> On Thu, 24 Jul 2008 13:52:18 -0700
> Jesse Barnes <jbarnes@virtuousgeek.org> wrote:
> 
> > On Thursday, July 24, 2008 1:50 pm Rafael J. Wysocki wrote:
> > > [Sorry for the delayed response, I'm at OLS.]
> > >
> > > On Monday, 21 of July 2008, Andrew Morton wrote:
> > > > On Sat, 19 Jul 2008 14:42:51 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> 
> > wrote:
> > > > > Adapt the sky2 driver to use the reworked PCI PM.
> > > >
> > > > I fixed the rejects in "[PATCH 3/4] tg3: Adapt tg3 to use reworked PCI
> > > > PM code" but this patch has too many for me to want to fix them.
> > > >
> > > > As usual, please at least take a look at what's in linux-next before
> > > > going and bypassing all that queued work.
> > >
> > > Sorry for that.
> > >
> > > Appended is a version of the patch applying to the current mainline on top
> > > of patches 1/4 - 3/4 without rejects.
> > >
> > > BTW, the sky2's WOL is broken on my test box because of commit
> > > db99b98885e717454feef1c6868b27d3f23c2e7c ("sky2: put PHY in sleep when
> > > down") that causes the box to hang solid in sky2_suspend() and
> > > sky2_shutdown() after WOL has been enabled with 'ethtool -s eth0 wol g'.
> > >
> > > This has already been reported to Stephen and Jeff.
> > 
> > Btw, I just asked Linus to pull the 2/4 part of this patchset, so the rest 
> > should be able to go upstream soon.
> > 
> > Thanks,
> > Jesse
> 
> 
> Does this fix your WOL issue?
> 
> When doing wake on lan and resume, the PHY may need to get more
> power up bits tweaked.

At the moment I have no access to the affected machine.  I'll test it after
I return from OLS (most probably on Monday) and report back.

Thanks,
Rafael


---
> 
> --- a/drivers/net/sky2.c	2008-07-24 15:35:33.000000000 -0700
> +++ b/drivers/net/sky2.c	2008-07-24 15:43:44.000000000 -0700
> @@ -698,6 +698,7 @@ static const u32 coma_mode[] = { PCI_Y2_
>  static void sky2_phy_power_up(struct sky2_hw *hw, unsigned port)
>  {
>  	u32 reg1;
> +	u16 ctrl;
>  
>  	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
> @@ -709,6 +710,33 @@ static void sky2_phy_power_up(struct sky
>  	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
>  	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	sky2_pci_read32(hw, PCI_DEV_REG1);
> +
> +	if (hw->chip_id != CHIP_ID_YUKON_EC) {
> +		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
> +			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
> +			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
> +
> +			/* turn on GII power */
> +			ctrl &= ~PHY_M_PC_POW_D_ENA;
> +			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
> +		}
> +	}
> +
> +	if (hw->flags & SKY2_HW_NEWER_PHY) {
> +		/* select page 2 to access MAC control register */
> +		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
> +
> +		ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
> +		/* allow GMII Power Down */
> +		ctrl |= PHY_M_MAC_GMIF_PUP;
> +		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
> +
> +		/* set page register back to 0 */
> +		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
> +	}
> +
> +	/* force phy reset and clear power down */
> +	gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_RESET);
>  }
>  
>  static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
> @@ -731,6 +759,9 @@ static void sky2_phy_power_down(struct s
>  		ctrl &= ~PHY_M_MAC_GMIF_PUP;
>  		gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
>  
> +		/* this register change must be followed by a software reset */
> +		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_RESET);
> +
>  		/* set page register back to 0 */
>  		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
>  	}
> 
> 


