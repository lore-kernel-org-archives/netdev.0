From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Fri, 07 Mar 2008 11:45:46 +0100
Message-ID: <1204886746.6387.17.camel@johannes.berg>
References: <200803052345.06610.florian.fainelli@telecomint.eu>
	 (sfid-20080305_225508_457415_A4541370)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bgPMEvf4a8E5TyPXl5jN"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46589 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987AbYCGKqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 05:46:08 -0500
In-Reply-To: <200803052345.06610.florian.fainelli@telecomint.eu> (sfid-20080305_225508_457415_A4541370)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bgPMEvf4a8E5TyPXl5jN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

=20
> +config KORINA
> +	tristate "Korina (IDT rc32434) Ethernet support"
> +	depends on NET_ETHERNET && MIKROTIK_RB500
> +	help
> +	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
> +	  based system say Y. Otherwise say N.

Since you'll never going to see that prompt if you don't have such a
board, that seems pretty unhelpful :)

> +#define TX_TIMEOUT 	(HZ * 100)

Not sure where this is used, but 100 seconds seems quite long, no?

> +enum status { filled, empty };

I'd use names with some prefixes, maybe descriptor_filled? Matter of
taste though I guess.

> +static inline void korina_start_dma(struct dma_reg *ch, u32 dma_addr)

> +static inline void korina_abort_dma(struct net_device *dev,

> +static inline void korina_chain_dma(struct dma_reg *ch, u32 dma_addr)

> +static inline void korina_abort_tx(struct net_device *dev)
> +{
> +	struct korina_private *lp =3D netdev_priv(dev);
> +
> +	korina_abort_dma(dev, lp->tx_dma_regs);
> +}

All those inlines seems a bit excessive since korina_abort_dma is an
inline too and then inlined into two other functions... Are those really
necessary?

> +static inline void korina_start_tx(struct korina_private *lp,
> +					struct dma_desc *td)
> +{
> +	korina_start_dma(lp->tx_dma_regs, CPHYSADDR(td));

Similarly here although korina_start_dma is a lot shorter than stop_dma.

> +	/* stop queue when full, drop pkts if queue already full */
> +	if (lp->tx_count >=3D (KORINA_NUM_TDS - 2)) {

> +		if (lp->tx_count =3D=3D (KORINA_NUM_TDS - 2))
> +			netif_stop_queue(dev);

> +	if (readl(&(lp->tx_dma_regs->dmandptr)) =3D=3D 0) {

Why so many parentheses? :)

> +		/* Mask D H E bit in Rx DMA */
> +		dmasm =3D readl(&lp->rx_dma_regs->dmasm);
> +		writel(dmasm | (DMA_STAT_DONE |
> +				DMA_STAT_HALT | DMA_STAT_ERR),

Pretty useless comment especially since you have to read the code to
understand it! Or was this intended as a comment on how the register
write works? Similar instances all over the driver. Maybe a single
comment at the top of the file on how that register works would be good
instead.

> +static void korina_multicast_list(struct net_device *dev)
> +{
> +	/* listen to broadcasts always and to treat 	*/
> +	/*       IFF bits independantly	*/

typo: independently

> +	struct korina_private *lp =3D netdev_priv(dev);
> +	unsigned long flags;
> +	u32 recognise =3D ETH_ARC_AB;	/* always accept broadcasts */
> +
> +	/* Set promiscuouts mode */

Typo: promiscuous.

> +	if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 15))
> +		/* All multicast and broadcast */
> +		recognise |=3D ETH_ARC_AM;
> +	else if (dev->mc_count > 0)
> +		recognise |=3D ETH_ARC_AM;

Some stuff missing here? the mc_count > 15 checks seems superfluous
since >15 is always >0.

> +static struct net_device_stats *korina_get_stats(struct net_device *dev)
> +{
> +	return &dev->stats;
> +}

Unnecessary, internal_stats is default and does exactly this.

> +/*
> + *  * Restart the RC32434 ethernet controller.
> + *   */

Oddly formatted comment :)

> +static int korina_close(struct net_device *dev)
> +{
> +	struct korina_private *lp =3D netdev_priv(dev);
> +	u32 tmp;
> +
> +	/* Disable interrupts */
> +	disable_irq(lp->rx_irq);
> +	disable_irq(lp->tx_irq);
> +	disable_irq(lp->ovr_irq);
> +	disable_irq(lp->und_irq);
> +
> +	tmp =3D readl(&lp->tx_dma_regs->dmasm);
> +	tmp =3D tmp | DMA_STAT_FINI | DMA_STAT_ERR;
> +	writel(tmp, &lp->tx_dma_regs->dmasm);
> +
> +	tmp =3D readl(&lp->rx_dma_regs->dmasm);
> +	tmp =3D tmp | DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR;
> +	writel(tmp, &lp->rx_dma_regs->dmasm);
> +
> +	free_irq(lp->rx_irq, dev);
> +	free_irq(lp->tx_irq, dev);
> +	free_irq(lp->ovr_irq, dev);
> +	free_irq(lp->und_irq, dev);
> +	return 0;

No need to abort DMA?

johannes

--=-bgPMEvf4a8E5TyPXl5jN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR9Ec2aVg1VMiehFYAQJfIRAAkAUaG5Fmne/lfaJEANp05ZX1T15cbKxN
XuXetUOGWCYZaU4mEgOqAIQN1R54FPlgCXZYS0bWhVXW45RtswtU78Z0nK4S2RCD
kN9YgLfr4xGCwXoe0y638wux6jOmJYYD5Nt2bLUGv/n7ATctS7iri8I5nZdeFA/e
rC0tVc8TbJvY/PHxYbxk5mvcK9Rr90pp96Iqkzh3meNOqxukVHPtRs8HEBzSaMr+
UDWDRgBAUjbE6YxYK4ox9ZyAuqV0x0TFRVY99LhvEw38jZda0KBXj7OSrD/4aMlE
5+9QbDHjvZ0oTBQnYSJ/dnn1cIoxqW+2+ou0olUzAvV4liym1DRJCgtv/SuV+mvk
4M8PrDWemv17d9zjcadQN+Pk7iTQSeFOyf1FLdtaTS4RTFtbWqAZIFDv5zIFvY9+
AXa1u/EeM0RkGEZoNroV4ti3AvITwjlGSiohiO1L7HFcDR9SUbHlahnZ15RFUx+x
GoJqOSOQIPWtHJe+RW+M/Hl66lDXaF0QBb3vRTkwN4NtCyBlBSH73kDJDw8Hg3A1
2Uw2twn3XIkfy7zGEmv7VtB+RMJnETUxu9+nb1sTh0nU6UjB6MsyuniGecMjpkhM
oDpYKfRtKwQXalKQLpPhLiTaEQpGp2rWUiao6TBOI008+To7lRCALrvlL70fZJDs
fHpAbBKx3rY=
=r+Cv
-----END PGP SIGNATURE-----

--=-bgPMEvf4a8E5TyPXl5jN--

