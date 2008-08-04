From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] sky2: fix PM related regressions
Date: Mon, 4 Aug 2008 23:12:31 +0200
Message-ID: <200808042312.32249.rjw@sisk.pl>
References: <20080804133337.3c0fe889@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47276 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755839AbYHDVJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 17:09:37 -0400
In-Reply-To: <20080804133337.3c0fe889@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 4 of August 2008, Stephen Hemminger wrote:
> Fix the problems reported for 2.6.27-rc1 caused by over aggressive
> power management. Turning clock off on PCI Express is problematic for WOL,
> and when doing multi-booting.

The patch fixes the problem for me, thanks.

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/sky2.c	2008-07-30 08:36:44.000000000 -0700
> +++ b/drivers/net/sky2.c	2008-08-02 21:00:58.000000000 -0700
> @@ -275,86 +275,6 @@ static void sky2_power_aux(struct sky2_h
>  			     PC_VAUX_ON | PC_VCC_OFF));
>  }
>  
> -static void sky2_power_state(struct sky2_hw *hw, pci_power_t state)
> -{
> -	u16 power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_CTRL);
> -	int pex = pci_find_capability(hw->pdev, PCI_CAP_ID_EXP);
> -	u32 reg;
> -
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
> -
> -	switch (state) {
> -	case PCI_D0:
> -		break;
> -
> -	case PCI_D1:
> -		power_control |= 1;
> -		break;
> -
> -	case PCI_D2:
> -		power_control |= 2;
> -		break;
> -
> -	case PCI_D3hot:
> -	case PCI_D3cold:
> -		power_control |= 3;
> -		if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
> -			/* additional power saving measurements */
> -			reg = sky2_pci_read32(hw, PCI_DEV_REG4);
> -
> -			/* set gating core clock for LTSSM in L1 state */
> -			reg |= P_PEX_LTSSM_STAT(P_PEX_LTSSM_L1_STAT) |
> -				/* auto clock gated scheme controlled by CLKREQ */
> -				P_ASPM_A1_MODE_SELECT |
> -				/* enable Gate Root Core Clock */
> -				P_CLK_GATE_ROOT_COR_ENA;
> -
> -			if (pex && (hw->flags & SKY2_HW_CLK_POWER)) {
> -				/* enable Clock Power Management (CLKREQ) */
> -				u16 ctrl = sky2_pci_read16(hw, pex + PCI_EXP_DEVCTL);
> -
> -				ctrl |= PCI_EXP_DEVCTL_AUX_PME;
> -				sky2_pci_write16(hw, pex + PCI_EXP_DEVCTL, ctrl);
> -			} else
> -				/* force CLKREQ Enable in Our4 (A1b only) */
> -				reg |= P_ASPM_FORCE_CLKREQ_ENA;
> -
> -			/* set Mask Register for Release/Gate Clock */
> -			sky2_pci_write32(hw, PCI_DEV_REG5,
> -					 P_REL_PCIE_EXIT_L1_ST | P_GAT_PCIE_ENTER_L1_ST |
> -					 P_REL_PCIE_RX_EX_IDLE | P_GAT_PCIE_RX_EL_IDLE |
> -					 P_REL_GPHY_LINK_UP | P_GAT_GPHY_LINK_DOWN);
> -		} else
> -			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_CLK_HALT);
> -
> -		/* put CPU into reset state */
> -		sky2_write8(hw,  B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_RESET);
> -		if (hw->chip_id == CHIP_ID_YUKON_SUPR && hw->chip_rev == CHIP_REV_YU_SU_A0)
> -			/* put CPU into halt state */
> -			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_HALTED);
> -
> -		if (pex && !(hw->flags & SKY2_HW_RAM_BUFFER)) {
> -			reg = sky2_pci_read32(hw, PCI_DEV_REG1);
> -			/* force to PCIe L1 */
> -			reg |= PCI_FORCE_PEX_L1;
> -			sky2_pci_write32(hw, PCI_DEV_REG1, reg);
> -		}
> -		break;
> -
> -	default:
> -		dev_warn(&hw->pdev->dev, PFX "Invalid power state (%d) ",
> -		       state);
> -		return;
> -	}
> -
> -	power_control |= PCI_PM_CTRL_PME_ENABLE;
> -	/* Finally, set the new power state. */
> -	sky2_pci_write32(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
> -
> -	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
> -	sky2_pci_read32(hw, B0_CTST);
> -}
> -
>  static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
>  {
>  	u16 reg;
> @@ -709,6 +629,11 @@ static void sky2_phy_power_up(struct sky
>  	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
>  	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
>  	sky2_pci_read32(hw, PCI_DEV_REG1);
> +
> +	if (hw->chip_id == CHIP_ID_YUKON_FE)
> +		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_ANE);
> +	else if (hw->flags & SKY2_HW_ADV_POWER_CTL)
> +		sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_CLR);
>  }
>  
>  static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
> @@ -2855,10 +2780,6 @@ static int __devinit sky2_init(struct sk
>  		hw->flags = SKY2_HW_GIGABIT
>  			| SKY2_HW_NEWER_PHY
>  			| SKY2_HW_ADV_POWER_CTL;
> -
> -		/* check for Rev. A1 dev 4200 */
> -		if (sky2_read16(hw, Q_ADDR(Q_XA1, Q_WM)) == 0)
> -			hw->flags |= SKY2_HW_CLK_POWER;
>  		break;
>  
>  	case CHIP_ID_YUKON_EX:
> @@ -2914,12 +2835,6 @@ static int __devinit sky2_init(struct sk
>  	if (hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P')
>  		hw->flags |= SKY2_HW_FIBRE_PHY;
>  
> -	hw->pm_cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PM);
> -	if (hw->pm_cap == 0) {
> -		dev_err(&hw->pdev->dev, "cannot find PowerManagement capability\n");
> -		return -EIO;
> -	}
> -
>  	hw->ports = 1;
>  	t8 = sky2_read8(hw, B2_Y2_HW_RES);
>  	if ((t8 & CFG_DUAL_MAC_MSK) == CFG_DUAL_MAC_MSK) {
> @@ -4512,7 +4427,7 @@ static int sky2_suspend(struct pci_dev *
>  
>  	pci_save_state(pdev);
>  	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
> -	sky2_power_state(hw, pci_choose_state(pdev, state));
> +	pci_set_power_state(pdev, pci_choose_state(pdev, state));
>  
>  	return 0;
>  }
> @@ -4525,7 +4440,9 @@ static int sky2_resume(struct pci_dev *p
>  	if (!hw)
>  		return 0;
>  
> -	sky2_power_state(hw, PCI_D0);
> +	err = pci_set_power_state(pdev, PCI_D0);
> +	if (err)
> +		goto out;
>  
>  	err = pci_restore_state(pdev);
>  	if (err)
> @@ -4595,7 +4512,7 @@ static void sky2_shutdown(struct pci_dev
>  	pci_enable_wake(pdev, PCI_D3cold, wol);
>  
>  	pci_disable_device(pdev);
> -	sky2_power_state(hw, PCI_D3hot);
> +	pci_set_power_state(pdev, PCI_D3hot);
>  }
>  
>  static struct pci_driver sky2_driver = {
> --- a/drivers/net/sky2.h	2008-08-02 20:55:08.000000000 -0700
> +++ b/drivers/net/sky2.h	2008-08-02 21:01:04.000000000 -0700
> @@ -2072,9 +2072,7 @@ struct sky2_hw {
>  #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
>  #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
>  #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
> -#define SKY2_HW_CLK_POWER	0x00000100	/* clock power management */
>  
> -	int		     pm_cap;
>  	u8	     	     chip_id;
>  	u8		     chip_rev;
>  	u8		     pmd_type;
> 
> 


