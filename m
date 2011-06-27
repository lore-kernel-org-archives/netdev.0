From: "Matt Carlson" <mcarlson@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
Subject: Re: [PATCH 15/19 v2] tg3: remove unnecessary read of
 PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 16:33:52 -0700
Message-ID: <20110627233352.GA6223@mcarlson.broadcom.com>
References: <1309196854-16232-1-git-send-email-jdmason@kudzu.us>
 <20110627225649.GA20786@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4004 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755741Ab1F0X3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 19:29:41 -0400
In-Reply-To: <20110627225649.GA20786@kudzu.us>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 03:56:50PM -0700, Jon Mason wrote:
> The PCIE capability offset is saved during PCI bus walking.  Use the
> value from pci_dev instead of checking in the driver and saving it off
> the the driver specific structure.  It will remove an unnecessary search
> in the PCI configuration space if this value is referenced instead of
> reacquiring it.
> 
> v2 of the patch re-adds the PCI_EXPRESS flag and adds comments
> describing why it is necessary.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> ---
>  drivers/net/tg3.c |   25 ++++++++++++++-----------
>  drivers/net/tg3.h |    5 +----
>  2 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 97cd02d..a555efd 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -2679,11 +2679,11 @@ static int tg3_power_down_prepare(struct tg3 *tp)
>  		u16 lnkctl;
>  
>  		pci_read_config_word(tp->pdev,
> -				     tp->pcie_cap + PCI_EXP_LNKCTL,
> +				     tp->pdev->pcie_cap + PCI_EXP_LNKCTL,

Sorry to be a stickler, but can we convert all occurances of
'tp->pdev->pcie_cap' to pci_pcie_cap(tp->pdev)?  If the PCI layer is
taking control of that variable, the driver shouldn't be accessing it
directly if it can help it.

>  				     &lnkctl);
>  		lnkctl |= PCI_EXP_LNKCTL_CLKREQ_EN;
>  		pci_write_config_word(tp->pdev,
> -				      tp->pcie_cap + PCI_EXP_LNKCTL,
> +				      tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
>  				      lnkctl);
>  	}
>  
> @@ -3485,7 +3485,7 @@ relink:
>  		u16 oldlnkctl, newlnkctl;
>  
>  		pci_read_config_word(tp->pdev,
> -				     tp->pcie_cap + PCI_EXP_LNKCTL,
> +				     tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
>  				     &oldlnkctl);
>  		if (tp->link_config.active_speed == SPEED_100 ||
>  		    tp->link_config.active_speed == SPEED_10)
> @@ -3494,7 +3494,7 @@ relink:
>  			newlnkctl = oldlnkctl | PCI_EXP_LNKCTL_CLKREQ_EN;
>  		if (newlnkctl != oldlnkctl)
>  			pci_write_config_word(tp->pdev,
> -					      tp->pcie_cap + PCI_EXP_LNKCTL,
> +					      tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
>  					      newlnkctl);
>  	}
>  
> @@ -7226,7 +7226,7 @@ static int tg3_chip_reset(struct tg3 *tp)
>  
>  	udelay(120);
>  
> -	if (tg3_flag(tp, PCI_EXPRESS) && tp->pcie_cap) {
> +	if (tg3_flag(tp, PCI_EXPRESS) && pci_pcie_cap(tp->pdev)) {
>  		u16 val16;
>  
>  		if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
> @@ -7244,7 +7244,7 @@ static int tg3_chip_reset(struct tg3 *tp)
>  
>  		/* Clear the "no snoop" and "relaxed ordering" bits. */
>  		pci_read_config_word(tp->pdev,
> -				     tp->pcie_cap + PCI_EXP_DEVCTL,
> +				     tp->pdev->pcie_cap + PCI_EXP_DEVCTL,
>  				     &val16);
>  		val16 &= ~(PCI_EXP_DEVCTL_RELAX_EN |
>  			   PCI_EXP_DEVCTL_NOSNOOP_EN);
> @@ -7255,14 +7255,14 @@ static int tg3_chip_reset(struct tg3 *tp)
>  		if (!tg3_flag(tp, CPMU_PRESENT))
>  			val16 &= ~PCI_EXP_DEVCTL_PAYLOAD;
>  		pci_write_config_word(tp->pdev,
> -				      tp->pcie_cap + PCI_EXP_DEVCTL,
> +				      tp->pdev->pcie_cap + PCI_EXP_DEVCTL,
>  				      val16);
>  
>  		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
>  
>  		/* Clear error status */
>  		pci_write_config_word(tp->pdev,
> -				      tp->pcie_cap + PCI_EXP_DEVSTA,
> +				      tp->pdev->pcie_cap + PCI_EXP_DEVSTA,
>  				      PCI_EXP_DEVSTA_CED |
>  				      PCI_EXP_DEVSTA_NFED |
>  				      PCI_EXP_DEVSTA_FED |
> @@ -13777,8 +13777,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  	pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
>  			      &pci_state_reg);
>  
> -	tp->pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
> -	if (tp->pcie_cap != 0) {
> +	if (pci_is_pcie(tp->pdev)) {
>  		u16 lnkctl;
>  
>  		tg3_flag_set(tp, PCI_EXPRESS);
> @@ -13791,7 +13790,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  		pcie_set_readrq(tp->pdev, tp->pcie_readrq);
>  
>  		pci_read_config_word(tp->pdev,
> -				     tp->pcie_cap + PCI_EXP_LNKCTL,
> +				     tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
>  				     &lnkctl);
>  		if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
>  			if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
> @@ -13808,6 +13807,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
>  			tg3_flag_set(tp, L1PLLPD_EN);
>  		}
>  	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
> +		/* BCM5785 devices are effectively PCIe devices, and should
> +		 * follow PCIe codepaths, but do not have a PCIe capabilities
> +		 * section.
> +		*/
>  		tg3_flag_set(tp, PCI_EXPRESS);
>  	} else if (!tg3_flag(tp, 5705_PLUS) ||
>  		   tg3_flag(tp, 5780_CLASS)) {
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index bedc3b4..5f250ae 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2857,7 +2857,7 @@ enum TG3_FLAGS {
>  	TG3_FLAG_IS_5788,
>  	TG3_FLAG_MAX_RXPEND_64,
>  	TG3_FLAG_TSO_CAPABLE,
> -	TG3_FLAG_PCI_EXPRESS,
> +	TG3_FLAG_PCI_EXPRESS, /* BCM5785 + pci_is_pcie() */
>  	TG3_FLAG_ASF_NEW_HANDSHAKE,
>  	TG3_FLAG_HW_AUTONEG,
>  	TG3_FLAG_IS_NIC,
> @@ -3022,10 +3022,7 @@ struct tg3 {
>  
>  	int				pm_cap;
>  	int				msi_cap;
> -	union {
>  	int				pcix_cap;
> -	int				pcie_cap;
> -	};
>  	int				pcie_readrq;
>  
>  	struct mii_bus			*mdio_bus;
> -- 
> 1.7.5.4
> 
> 

