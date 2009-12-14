From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] sky2: leave PCI config space writeable
Date: Mon, 14 Dec 2009 22:49:07 +0100
Message-ID: <200912142249.07753.rjw@sisk.pl>
References: <20091214103458.7787e011@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:48810 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758470AbZLNVs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 16:48:57 -0500
In-Reply-To: <20091214103458.7787e011@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 14 December 2009, Stephen Hemminger wrote:
> Since power management is done by PCI subsystem as well as driver,
> don't toggle the bit that disables PCI register writes.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

> --- a/drivers/net/sky2.c	2009-12-11 11:09:44.856489827 -0800
> +++ b/drivers/net/sky2.c	2009-12-11 11:09:55.947770545 -0800
> @@ -644,7 +644,6 @@ static void sky2_phy_power_up(struct sky
>  {
>  	u32 reg1;
>  
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
>  	reg1 &= ~phy_power[port];
>  
> @@ -652,7 +651,6 @@ static void sky2_phy_power_up(struct sky
>  		reg1 |= coma_mode[port];
>  
>  	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	sky2_pci_read32(hw, PCI_DEV_REG1);
>  
>  	if (hw->chip_id == CHIP_ID_YUKON_FE)
> @@ -709,11 +707,9 @@ static void sky2_phy_power_down(struct s
>  		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_PDOWN);
>  	}
>  
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
>  	reg1 |= phy_power[port];		/* set PHY to PowerDown/COMA Mode */
>  	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  }
>  
>  /* Force a renegotiation */
> @@ -2152,9 +2148,7 @@ static void sky2_qlink_intr(struct sky2_
>  
>  	/* reset PHY Link Detect */
>  	phy = sky2_pci_read16(hw, PSM_CONFIG_REG4);
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  	sky2_pci_write16(hw, PSM_CONFIG_REG4, phy | 1);
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  
>  	sky2_link_up(sky2);
>  }
> @@ -2645,7 +2639,6 @@ static void sky2_hw_intr(struct sky2_hw 
>  	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
>  		u16 pci_err;
>  
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		pci_err = sky2_pci_read16(hw, PCI_STATUS);
>  		if (net_ratelimit())
>  			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
> @@ -2653,14 +2646,12 @@ static void sky2_hw_intr(struct sky2_hw 
>  
>  		sky2_pci_write16(hw, PCI_STATUS,
>  				      pci_err | PCI_STATUS_ERROR_BITS);
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	}
>  
>  	if (status & Y2_IS_PCI_EXP) {
>  		/* PCI-Express uncorrectable Error occurred */
>  		u32 err;
>  
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
>  		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
>  			     0xfffffffful);
> @@ -2668,7 +2659,6 @@ static void sky2_hw_intr(struct sky2_hw 
>  			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
>  
>  		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	}
>  
>  	if (status & Y2_HWE_L1_MASK)
> @@ -3047,7 +3037,6 @@ static void sky2_reset(struct sky2_hw *h
>  	}
>  
>  	sky2_power_on(hw);
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  
>  	for (i = 0; i < hw->ports; i++) {
>  		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
> @@ -3084,7 +3073,6 @@ static void sky2_reset(struct sky2_hw *h
>  		reg <<= PSM_CONFIG_REG4_TIMER_PHY_LINK_DETECT_BASE;
>  
>  		/* reset PHY Link Detect */
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		sky2_pci_write16(hw, PSM_CONFIG_REG4,
>  				 reg | PSM_CONFIG_REG4_RST_PHY_LINK_DETECT);
>  		sky2_pci_write16(hw, PSM_CONFIG_REG4, reg);
> @@ -3102,7 +3090,6 @@ static void sky2_reset(struct sky2_hw *h
>  			/* restore the PCIe Link Control register */
>  			sky2_pci_write16(hw, cap + PCI_EXP_LNKCTL, reg);
>  		}
> -		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  
>  		/* re-enable PEX PM in PEX PHY debug reg. 8 (clear bit 12) */
>  		sky2_write32(hw, Y2_PEX_PHY_DATA, PEX_DB_ACCESS | (0x08UL << 16));
> 
> 

