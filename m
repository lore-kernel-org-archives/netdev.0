From: supersud501 <supersud501@yahoo.de>
Subject: Re: [RFT] sky2: wake-on-lan configuration issues
Date: Mon, 14 Jan 2008 22:05:28 +0100
Message-ID: <478BCE98.5030709@yahoo.de>
References: <bug-9721-10286@http.bugzilla.kernel.org/>	<478A743C.9050405@yahoo.de>	<20080113125708.070b4843.akpm@linux-foundation.org>	<200801132227.59229.rjw@sisk.pl>	<478A965E.8070306@yahoo.de> <20080114101439.72304b92@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20080114101439.72304b92@deepthought>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Stephen Hemminger wrote:
> Please test this patch against Linus's current (approx 2.6.24-rc7-git5).
> Ignore Andrew's premature reversion attempt...
> 
> This patch disables config mode access after clearing PCI settings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- a/drivers/net/sky2.c	2008-01-14 09:44:22.000000000 -0800
> +++ b/drivers/net/sky2.c	2008-01-14 09:44:51.000000000 -0800
> @@ -621,6 +621,7 @@ static void sky2_phy_power(struct sky2_h
>  	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
>  	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
>  
> +	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
>  	/* Turn on/off phy power saving */
>  	if (onoff)
> @@ -632,7 +633,8 @@ static void sky2_phy_power(struct sky2_h
>  		reg1 |= coma_mode[port];
>  
>  	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
> -	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
> +	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
> +	sky2_pci_read32(hw, PCI_DEV_REG1);
>  
>  	udelay(100);
>  }
> @@ -2426,6 +2428,7 @@ static void sky2_hw_intr(struct sky2_hw 
>  	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
>  		u16 pci_err;
>  
> +		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		pci_err = sky2_pci_read16(hw, PCI_STATUS);
>  		if (net_ratelimit())
>  			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
> @@ -2433,12 +2436,14 @@ static void sky2_hw_intr(struct sky2_hw 
>  
>  		sky2_pci_write16(hw, PCI_STATUS,
>  				      pci_err | PCI_STATUS_ERROR_BITS);
> +		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	}
>  
>  	if (status & Y2_IS_PCI_EXP) {
>  		/* PCI-Express uncorrectable Error occurred */
>  		u32 err;
>  
> +		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
>  		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
>  			     0xfffffffful);
> @@ -2446,6 +2451,7 @@ static void sky2_hw_intr(struct sky2_hw 
>  			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
>  
>  		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
> +		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	}
>  
>  	if (status & Y2_HWE_L1_MASK)
> @@ -2811,6 +2817,7 @@ static void sky2_reset(struct sky2_hw *h
>  	}
>  
>  	sky2_power_on(hw);
> +	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  
>  	for (i = 0; i < hw->ports; i++) {
>  		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
> 

yes, that did it! just tested it (current linus git tree with patched 
sky with above patch), everything is clean now (dmesg output) and wol 
works even with the commit ac93a3946b676025fa55356180e8321639744b31

so it the bug is fixed without the need to revert 
ac93a3946b676025fa55356180e8321639744b31.
