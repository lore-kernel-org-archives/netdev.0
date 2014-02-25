From: Michael Chan <mchan@broadcom.com>
Subject: Re: [RFC 2/3] tg3: Use pci_set_power_state() for setting PM states
Date: Mon, 24 Feb 2014 16:15:37 -0800
Message-ID: <1393287337.9208.80.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1393281245-3951-1-git-send-email-jdmason@kudzu.us>
	 <1393281245-3951-2-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:28201 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbaBYAPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:15:48 -0500
In-Reply-To: <1393281245-3951-2-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-24 at 15:34 -0700, Jon Mason wrote: 
> Use the existing infrastructure of pci_set_power_state() instead of
> setting the relevant bits via PCI config read/write in the driver.
> Also, use pci_pme_active() to set the PCI_PM_CTRL_PME_ENABLE bit in PCI
> PM control register.  pci_set_power_state() and pci_pme_active() perform
> the same operations as the driver did before, so there should be no
> functional change.  That being said, this has not been tested.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> Cc: Nithin Nayak Sujir <nsujir@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>

I've reviewed the code and this patch should be ok.  The original intent
of the code was to force the power state to D0 in case it was clobbered
by an MMIO write not intended for that register due to a hardware bug.
If it was clobbered like that, pci_set_power_state() may not set it to
D0 if it thinks that it is already in D0.  There is no MMIO write up
until this point so it is ok to call pci_set_power_state().

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/ethernet/broadcom/tg3.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 3167ed6..36c3fd9 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -16362,22 +16362,14 @@ static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
>  		 * for all chip writes not to mailbox registers.
>  		 */
>  		if (tg3_flag(tp, PCIX_MODE)) {
> -			u32 pm_reg;
> -
>  			tg3_flag_set(tp, PCIX_TARGET_HWBUG);
>  
>  			/* The chip can have it's power management PCI config
>  			 * space registers clobbered due to this bug.
>  			 * So explicitly force the chip into D0 here.
>  			 */
> -			pci_read_config_dword(tp->pdev,
> -					      tp->pdev->pm_cap + PCI_PM_CTRL,
> -					      &pm_reg);
> -			pm_reg &= ~PCI_PM_CTRL_STATE_MASK;
> -			pm_reg |= PCI_PM_CTRL_PME_ENABLE | 0 /* D0 */;
> -			pci_write_config_dword(tp->pdev,
> -					       tp->pdev->pm_cap + PCI_PM_CTRL,
> -					       pm_reg);
> +			pci_set_power_state(tp->pdev, PCI_D0);
> +			pci_pme_active(tp->pdev, true);
>  
>  			/* Also, force SERR#/PERR# in PCI command. */
>  			pci_read_config_word(tp->pdev, PCI_COMMAND, &pci_cmd);
