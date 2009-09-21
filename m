From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt
 Coalescing
Date: Tue, 22 Sep 2009 09:41:54 +1000
Message-ID: <1253576514.7103.165.camel@pasglop>
References: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Feng Kan <fkan@amcc.com>,
	Loc Ho <lho@amcc.com>, Victor Gallardo <vgallardo@amcc.com>,
	bhutchings@solarflare.com, linuxppc-dev@lists.ozlabs.org,
	davem@davemloft.net, jwboyer@linux.vnet.ibm.com,
	lada.podivin@gmail.com
To: Prodyut Hazarika <phazarika@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:44093 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754421AbZIUXmM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 19:42:12 -0400
In-Reply-To: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-21 at 15:47 -0700, Prodyut Hazarika wrote:
> Support for Hardware Interrupt coalescing in MAL.
> Coalescing is supported on the newer revs of 460EX/GT and 405EX.
> The MAL driver falls back to EOB IRQ if coalescing not supported
> 
> Signed-off-by: Prodyut Hazarika <phazarika@amcc.com>
> Acked-by: Victor Gallardo <vgallardo@amcc.com>
> Acked-by: Feng Kan <fkan@amcc.com>

There's an awful lot of ifdef based on the CPU type in there. This is
not right.

What happens if we build a kernel that is supposed to boot with two
different variants of 405 or 440 ?

All of this should be runtime features.

ie:

> #ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
> +static inline void mal_enable_coal(struct mal_instance *mal)
> +{
> +	unsigned int val;
> +#if defined(CONFIG_405EX)
> +	/* Clear the counters */
> +	val = SDR0_ICC_FLUSH0 | SDR0_ICC_FLUSH1;
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX, val);
> +
> +	/* Set Tx/Rx Timer values */
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX0, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX1, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX0, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX1, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +
> +	/* Enable the Tx/Rx Coalescing interrupt */
> +	val = ((CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR0_SHIFT) |
> +		((CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR1_SHIFT);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX, val);
> +
> +	val = ((CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR0_SHIFT) |
> +		((CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR1_SHIFT);
> +
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX, val);
> +#elif defined(CONFIG_460EX) || defined(CONFIG_460GT)
> +	/* Clear the counters */
> +	val = SDR0_ICC_FLUSH;
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX0, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX1, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX0, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX1, val);
> +#if defined(CONFIG_460GT)
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX2, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX3, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX2, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX3, val);
> +#endif
> +
> +	/* Set Tx/Rx Timer values */
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX0, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX1, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX0, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX1, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +#if defined(CONFIG_460GT)
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX2, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRTX3, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX2, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +	mtdcri(SDR0, DCRN_SDR0_ICCTRRX3, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
> +#endif
> +
> +	/* Enable the Tx/Rx Coalescing interrupt */
> +	val = (CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR_SHIFT;
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX0, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX1, val);
> +#if defined(CONFIG_460GT)
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX2, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRTX3, val);
> +#endif
> +
> +	val = (CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
> +			<< SDR0_ICC_FTHR_SHIFT;
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX0, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX1, val);
> +#if defined(CONFIG_460GT)
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX2, val);
> +	mtdcri(SDR0, DCRN_SDR0_ICCRRX3, val);
> +#endif
> +#endif
> +	printk(KERN_INFO "MAL: Enabled Intr Coal TxCnt: %d RxCnt: %d\n",
> +		CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT,
> +		CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT);
> +}
> +#endif

This is all quite wrong. Either use MAL features or some other runtime
check, possibly via the "compatible" property.

Same goes with the SDR register definitions. Prefix them with the SOC
name but don't make them conditionally compiled. This is all back to the
same mess we had in arch/ppc and I'm not going to accept it.

Also, this coalescing option, while it makes sense to have a CONFIG
option to compile in the support for it or not, the choice to use
coalescing or not should be done at runtime. Same goes with the various
thresholds which should be runtime configurable.

There are existing mechanisms via ethtool to configure coalescing. You
should hookup onto these.


Cheers,
Ben.



