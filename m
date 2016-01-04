From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v3 net-next] net: ethernet: cadence-macb: Add disabled
 usrio caps
Date: Mon, 4 Jan 2016 10:25:13 +0100
Message-ID: <568A3A79.5070502@atmel.com>
References: <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
 <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong@baylibre.com>, <davem@davemloft.net>,
	<harini.katakam@xilinx.com>, <boris.brezillon@free-electrons.com>,
	<alexandre.belloni@free-electrons.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<joshc@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:57165 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbcADJYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 04:24:36 -0500
In-Reply-To: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/01/2016 10:01, Neil Armstrong a =E9crit :
> On some platforms, the macb integration does not use the USRIO
> register to configure the (R)MII port and clocks.
> When the register is not implemented and the MACB error signal
> is connected to the bus error, reading or writing to the USRIO
> register can trigger some Imprecise External Aborts on ARM platforms.
>=20
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 27 +++++++++++++++------------
>  drivers/net/ethernet/cadence/macb.h |  1 +
>  2 files changed, 16 insertions(+), 12 deletions(-)
>=20
> Nicolas,
> I post only the first patch of the previous set posted here :
> http://lkml.kernel.org/r/1449582726-6148-1-git-send-email-narmstrong@=
baylibre.com
> to hopefully make it into the 4.5 merge time,
> I'll post the vendor prefix once this patch will hit mainline.

Okay, but I don't see how you will activate this capability (or I lost
track of it). So, before I can accept one solution, can you please
repost the whole solution as a v4.

Thanks. Bye,


>=20
> Regards,
> Neil
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 8b45bc9..fa53bc3 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2124,7 +2124,8 @@ static void macb_get_regs(struct net_device *de=
v, struct ethtool_regs *regs,
>  	regs_buff[10] =3D macb_tx_dma(&bp->queues[0], tail);
>  	regs_buff[11] =3D macb_tx_dma(&bp->queues[0], head);
> =20
> -	regs_buff[12] =3D macb_or_gem_readl(bp, USRIO);
> +	if (!(bp->caps & MACB_CAPS_USRIO_DISABLED))
> +		regs_buff[12] =3D macb_or_gem_readl(bp, USRIO);
>  	if (macb_is_gem(bp)) {
>  		regs_buff[13] =3D gem_readl(bp, DMACFG);
>  	}
> @@ -2403,19 +2404,21 @@ static int macb_init(struct platform_device *=
pdev)
>  		dev->hw_features &=3D ~NETIF_F_SG;
>  	dev->features =3D dev->hw_features;
> =20
> -	val =3D 0;
> -	if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII)
> -		val =3D GEM_BIT(RGMII);
> -	else if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII &&
> -		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> -		val =3D MACB_BIT(RMII);
> -	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> -		val =3D MACB_BIT(MII);
> +	if (!(bp->caps & MACB_CAPS_USRIO_DISABLED)) {
> +		val =3D 0;
> +		if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII)
> +			val =3D GEM_BIT(RGMII);
> +		else if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII &&
> +			 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +			val =3D MACB_BIT(RMII);
> +		else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
> +			val =3D MACB_BIT(MII);
> =20
> -	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
> -		val |=3D MACB_BIT(CLKEN);
> +		if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
> +			val |=3D MACB_BIT(CLKEN);
> =20
> -	macb_or_gem_writel(bp, USRIO, val);
> +		macb_or_gem_writel(bp, USRIO, val);
> +	}
> =20
>  	/* Set MII management clock divider */
>  	val =3D macb_mdc_clk_div(bp);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index 5c03e81..0d4ecfc 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -400,6 +400,7 @@
>  #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
>  #define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
>  #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
> +#define MACB_CAPS_USRIO_DISABLED		0x00000010
>  #define MACB_CAPS_FIFO_MODE			0x10000000
>  #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
>  #define MACB_CAPS_SG_DISABLED			0x40000000
>=20


--=20
Nicolas Ferre
