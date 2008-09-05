From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 3/3] ibm_newemac: MAL support for PowerPC 405EZ
Date: Fri, 5 Sep 2008 12:10:37 +1000
Message-ID: <20080905021037.GG14128@verge.net.au>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com> <20080904150216.GD2479@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55714 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbYIECKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 22:10:39 -0400
Content-Disposition: inline
In-Reply-To: <20080904150216.GD2479@yoda.jdub.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 04, 2008 at 11:02:16AM -0400, Josh Boyer wrote:
> The PowerPC 405EZ SoC has some differences in the interrupt layout and
> handling for the MAL.  The SERR, TXDE, and RXDE interrupts are OR'd into
> a single interrupt.  Also, due to the possibility for interrupt coalescing,
> the TXEOB and RXEOB interrupts require an interrupt bit to be cleared in
> the ICINTSTAT SDR.
> 
> This sets the proper MAL feature bits for 405EZ boards, and adds a common
> shared handler for SERR, TXDE, and RXDE.  This has been adapted from code
> originally written by Stefan Roese.
> 
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> ---
>  drivers/net/ibm_newemac/mal.c |   98 ++++++++++++++++++++++++++++++++--------
>  1 files changed, 78 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
> index 10c267b..3cef534 100644
> --- a/drivers/net/ibm_newemac/mal.c
> +++ b/drivers/net/ibm_newemac/mal.c
> @@ -28,6 +28,7 @@
>  #include <linux/delay.h>
>  
>  #include "core.h"
> +#include <asm/dcr-regs.h>
>  
>  static int mal_count;
>  
> @@ -279,6 +280,9 @@ static irqreturn_t mal_txeob(int irq, void *dev_instance)
>  	mal_schedule_poll(mal);
>  	set_mal_dcrn(mal, MAL_TXEOBISR, r);
>  
> +	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
> +		mtdcri(SDR0, 0x4510, (mfdcri(SDR0, 0x4510) | 0x60000000));
> +
>  	return IRQ_HANDLED;
>  }
>  
> @@ -293,6 +297,9 @@ static irqreturn_t mal_rxeob(int irq, void *dev_instance)
>  	mal_schedule_poll(mal);
>  	set_mal_dcrn(mal, MAL_RXEOBISR, r);
>  
> +	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
> +		mtdcri(SDR0, 0x4510, (mfdcri(SDR0, 0x4510) | 0x80000000));
> +
>  	return IRQ_HANDLED;
>  }
>  
> @@ -336,6 +343,25 @@ static irqreturn_t mal_rxde(int irq, void *dev_instance)
>  	return IRQ_HANDLED;
>  }
>  
> +static irqreturn_t mal_int(int irq, void *dev_instance)
> +{
> +	struct mal_instance *mal = dev_instance;
> +	u32 esr = get_mal_dcrn(mal, MAL_ESR);
> +
> +	if (esr & MAL_ESR_EVB) {
> +		/* descriptor error */
> +		if (esr & MAL_ESR_DE) {
> +			if (esr & MAL_ESR_CIDT)
> +				return (mal_rxde(irq, dev_instance));

	Return statements shouldn't be enlosed in brackets according to
	checkpatch.pl. Also in a few other places.

> +			else
> +				return (mal_txde(irq, dev_instance));
> +		} else { /* SERR */
> +			return (mal_serr(irq, dev_instance));
> +		}
> +	}
> +	return IRQ_HANDLED;
> +}
> +
>  void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
>  {
>  	/* Spinlock-type semantics: only one caller disable poll at a time */
> @@ -542,11 +568,22 @@ static int __devinit mal_probe(struct of_device *ofdev,
>  		goto fail;
>  	}
>  
> -	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> -	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> -	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> -	mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
> -	mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
> +	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez"))
> +		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT | MAL_FTR_COMMON_ERR_INT);

The above like is >80 characters wide.
But I'm not sure that anyone cares.

> +
> +	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> +		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> +		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> +		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> +		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
> +	} else {
> +		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
> +		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
> +		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
> +		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
> +		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
> +	}

It seems that that first three calls to irq_of_parse_and_map() could
be moved outside of the if/else clause.

	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
	} else {
		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
	}

> +
>  	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
>  	    mal->serr_irq == NO_IRQ || mal->txde_irq == NO_IRQ ||
>  	    mal->rxde_irq == NO_IRQ) {
> @@ -608,21 +645,42 @@ static int __devinit mal_probe(struct of_device *ofdev,
>  			     sizeof(struct mal_descriptor) *
>  			     mal_rx_bd_offset(mal, i));
>  
> -	err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
> -	if (err)
> -		goto fail2;
> -	err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
> -	if (err)
> -		goto fail3;
> -	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> -	if (err)
> -		goto fail4;
> -	err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
> -	if (err)
> -		goto fail5;
> -	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> -	if (err)
> -		goto fail6;
> +	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
> +		err = request_irq(mal->serr_irq, mal_int, IRQF_SHARED,
> +				"MAL SERR", mal);
> +		if (err)
> +			goto fail2;
> +		err = request_irq(mal->txde_irq, mal_int, IRQF_SHARED,
> +				"MAL TX DE", mal);
> +		if (err)
> +			goto fail3;
> +		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> +		if (err)
> +			goto fail4;
> +		err = request_irq(mal->rxde_irq, mal_int, IRQF_SHARED,
> +				"MAL RX DE", mal);
> +		if (err)
> +			goto fail5;
> +		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> +		if (err)
> +			goto fail6;
> +	} else {
> +		err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
> +		if (err)
> +			goto fail2;
> +		err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
> +		if (err)
> +			goto fail3;
> +		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
> +		if (err)
> +			goto fail4;
> +		err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
> +		if (err)
> +			goto fail5;
> +		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
> +		if (err)
> +			goto fail6;
> +	}

There seems to be a lot of repention in the above if/else clauses.
I wonder if something like this might be nicer.

	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
		irqflags = IRQF_SHARED;
		hdlr_serr = hdlr_txde = hdlr_rxde = mal_int;
	} else {
		irqflags = 0;
		hdlr_serr = mal_serr;
		hdlr_txde = mal_txde;
		hdlr_rxde = mal_rxde;
	}
	err = request_irq(mal->serr_irq, hdlr_serr, irqflags, "MAL SERR", mal);
	if (err)
		goto fail2;
	err = request_irq(mal->txde_irq, hdlr_txde, irqflags, "MAL TX DE", mal);
	if (err)
		goto fail3;
	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
	if (err)
		goto fail4;
	err = request_irq(mal->rxde_irq, hdlr_rxde, irqflags, "MAL RX DE", mal);
	if (err)
		goto fail5;
	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
	if (err)
		goto fail6;

>  
>  	/* Enable all MAL SERR interrupt sources */
>  	if (mal->version == 2)
> -- 
> 1.5.5.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
