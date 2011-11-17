From: Sven Joachim <svenjoac@gmx.de>
Subject: Re: [PATCH 1/6] sky2: fix hang on shutdown (and other irq issues)
Date: Thu, 17 Nov 2011 09:46:43 +0100
Message-ID: <87r517w2z0.fsf@turtle.gmx.de>
References: <20111116234254.319625694@vyatta.com>
	<20111116234344.526517614@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:47036 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756027Ab1KQIqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:46:47 -0500
In-Reply-To: <20111116234344.526517614@vyatta.com> (Stephen Hemminger's
	message of "Wed, 16 Nov 2011 15:42:55 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-11-17 00:42 +0100, Stephen Hemminger wrote:

> There are several problems with recent change to how IRQ's are setup.
>    * synchronize_irq in sky2_shutdown would hang because there
>      was no IRQ setup.
>    * when device was set to down, some IRQ bits left enabled so a
>      hardware error would produce IRQ with no handler
>    * quick link on Optima chip set was enabled without handler
>    * suspend/resume would leave IRQ on with no handler if device
>      was down

Unfortunately, this patch does not fix the hang at shutdown for me. :-(

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> This needs to be applied to net-next and -net
>
> --- a/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:15:48.212513321 -0800
> +++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-16 15:19:32.898508932 -0800
> @@ -1747,6 +1747,11 @@ static int sky2_up(struct net_device *de
>  
>  	sky2_hw_up(sky2);
>  
> +	if (hw->chip_id == CHIP_ID_YUKON_OPT ||
> +	    hw->chip_id == CHIP_ID_YUKON_PRM ||
> +	    hw->chip_id == CHIP_ID_YUKON_OP_2)
> +		imask |= Y2_IS_PHY_QLNK;	/* enable PHY Quick Link */
> +
>  	/* Enable interrupts from phy/mac for port */
>  	imask = sky2_read32(hw, B0_IMSK);
>  	imask |= portirq_msk[port];
> @@ -2101,15 +2106,21 @@ static int sky2_down(struct net_device *
>  
>  	netif_info(sky2, ifdown, dev, "disabling interface\n");
>  
> -	/* Disable port IRQ */
> -	sky2_write32(hw, B0_IMSK,
> -		     sky2_read32(hw, B0_IMSK) & ~portirq_msk[sky2->port]);
> -	sky2_read32(hw, B0_IMSK);
> -
>  	if (hw->ports == 1) {
> +		sky2_write32(hw, B0_IMSK, 0);
> +		sky2_read32(hw, B0_IMSK);
> +
>  		napi_disable(&hw->napi);
>  		free_irq(hw->pdev->irq, hw);
>  	} else {
> +		u32 imask;
> +
> +		/* Disable port IRQ */
> +		imask  = sky2_read32(hw, B0_IMSK);
> +		imask &= ~portirq_msk[sky2->port];
> +		sky2_write32(hw, B0_IMSK, imask);
> +		sky2_read32(hw, B0_IMSK);
> +
>  		synchronize_irq(hw->pdev->irq);
>  		napi_synchronize(&hw->napi);
>  	}
> @@ -3258,7 +3269,6 @@ static void sky2_reset(struct sky2_hw *h
>  	    hw->chip_id == CHIP_ID_YUKON_PRM ||
>  	    hw->chip_id == CHIP_ID_YUKON_OP_2) {
>  		u16 reg;
> -		u32 msk;
>  
>  		if (hw->chip_id == CHIP_ID_YUKON_OPT && hw->chip_rev == 0) {
>  			/* disable PCI-E PHY power down (set PHY reg 0x80, bit 7 */
> @@ -3281,11 +3291,6 @@ static void sky2_reset(struct sky2_hw *h
>  		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
>  		sky2_pci_write16(hw, PSM_CONFIG_REG4, reg);
>  
> -		/* enable PHY Quick Link */
> -		msk = sky2_read32(hw, B0_IMSK);
> -		msk |= Y2_IS_PHY_QLNK;
> -		sky2_write32(hw, B0_IMSK, msk);
> -
>  		/* check if PSMv2 was running before */
>  		reg = sky2_pci_read16(hw, PSM_CONFIG_REG3);
>  		if (reg & PCI_EXP_LNKCTL_ASPMC)
> @@ -3412,7 +3417,9 @@ static void sky2_all_down(struct sky2_hw
>  
>  	sky2_read32(hw, B0_IMSK);
>  	sky2_write32(hw, B0_IMSK, 0);
> -	synchronize_irq(hw->pdev->irq);
> +
> +	if (hw->ports > 1 || netif_running(hw->dev[0]))
> +		synchronize_irq(hw->pdev->irq);
>  	napi_disable(&hw->napi);
>  
>  	for (i = 0; i < hw->ports; i++) {
> @@ -3430,7 +3437,7 @@ static void sky2_all_down(struct sky2_hw
>  
>  static void sky2_all_up(struct sky2_hw *hw)
>  {
> -	u32 imask = Y2_IS_BASE;
> +	u32 imask = 0;
>  	int i;
>  
>  	for (i = 0; i < hw->ports; i++) {
> @@ -3446,11 +3453,13 @@ static void sky2_all_up(struct sky2_hw *
>  		netif_wake_queue(dev);
>  	}
>  
> -	sky2_write32(hw, B0_IMSK, imask);
> -	sky2_read32(hw, B0_IMSK);
> -
> -	sky2_read32(hw, B0_Y2_SP_LISR);
> -	napi_enable(&hw->napi);
> +	if (imask || hw->ports > 1) {
> +		imask |= Y2_IS_BASE;
> +		sky2_write32(hw, B0_IMSK, imask);
> +		sky2_read32(hw, B0_IMSK);
> +		sky2_read32(hw, B0_Y2_SP_LISR);
> +		napi_enable(&hw->napi);
> +	}
>  }
>  
>  static void sky2_restart(struct work_struct *work)
