From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] Better MWI workaround for 21143 rev 65 chip errata
Date: Fri, 4 Apr 2008 00:42:16 -0600
Message-ID: <20080404064216.GA8791@colo.lackof.org>
References: <20080325113909.82BF8C2B76@solo.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@parisc-linux.org, zero@colonel-panic.org, jgarzik@pobox.com
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:49922 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbYDDGm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 02:42:28 -0400
Content-Disposition: inline
In-Reply-To: <20080325113909.82BF8C2B76@solo.franken.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 25, 2008 at 12:39:09PM +0100, Thomas Bogendoerfer wrote:
> From: Peter Horton <zero@colonel-panic.org>
> 
> This patch works around the MWI bug on the DC21143 rev 65 Tulip by
> ensuring that the receive buffers don't end on a cache line boundary
> (as documented in the errata).
> 
> This patch is required for the MIPS based Cobalt Qube/RaQ as
> supporting the extra PCI commands seems to reduce the chance of a hard
> lockup between the Tulip and the PCI bridge.
> 
> Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks!
I haven't tested this but it looks correct to me.

grant

> ---
> 
>  drivers/net/tulip/tulip.h      |    7 ++++++-
>  drivers/net/tulip/tulip_core.c |   19 +++++--------------
>  2 files changed, 11 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/tulip/tulip.h b/drivers/net/tulip/tulip.h
> index 3f69f53..908422f 100644
> --- a/drivers/net/tulip/tulip.h
> +++ b/drivers/net/tulip/tulip.h
> @@ -268,7 +268,12 @@ enum t21143_csr6_bits {
>  #define RX_RING_SIZE	128
>  #define MEDIA_MASK     31
>  
> -#define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. */
> +/* The receiver on the DC21143 rev 65 can fail to close the last
> + * receive descriptor in certain circumstances (see errata) when
> + * using MWI. This can only occur if the receive buffer ends on
> + * a cache line boundary, so the "+ 4" below ensures it doesn't.
> + */
> +#define PKT_BUF_SZ	(1536 + 4)	/* Size of each temporary Rx buffer. */
>  
>  #define TULIP_MIN_CACHE_LINE	8	/* in units of 32-bit words */
>  
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index ed600bf..5781150 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -1154,18 +1154,13 @@ static void __devinit tulip_mwi_config (struct pci_dev *pdev,
>  
>  	tp->csr0 = csr0 = 0;
>  
> -	/* if we have any cache line size at all, we can do MRM */
> -	csr0 |= MRM;
> +	/* if we have any cache line size at all, we can do MRM and MWI */
> +	csr0 |= MRM | MWI;
>  
> -	/* ...and barring hardware bugs, MWI */
> -	if (!(tp->chip_id == DC21143 && tp->revision == 65))
> -		csr0 |= MWI;
> -
> -	/* set or disable MWI in the standard PCI command bit.
> -	 * Check for the case where  mwi is desired but not available
> +	/* Enable MWI in the standard PCI command bit.
> +	 * Check for the case where MWI is desired but not available
>  	 */
> -	if (csr0 & MWI)	pci_try_set_mwi(pdev);
> -	else		pci_clear_mwi(pdev);
> +	pci_try_set_mwi(pdev);
>  
>  	/* read result from hardware (in case bit refused to enable) */
>  	pci_read_config_word(pdev, PCI_COMMAND, &pci_command);
> @@ -1401,10 +1396,6 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
>  #ifdef CONFIG_TULIP_MWI
>  	if (!force_csr0 && (tp->flags & HAS_PCI_MWI))
>  		tulip_mwi_config (pdev, dev);
> -#else
> -	/* MWI is broken for DC21143 rev 65... */
> -	if (chip_idx == DC21143 && pdev->revision == 65)
> -		tp->csr0 &= ~MWI;
>  #endif
>  
>  	/* Stop the chip's Tx and Rx processes. */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
