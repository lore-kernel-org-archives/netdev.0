From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Thu, 19 Feb 2015 13:16:27 +0100
Message-ID: <54E5D41B.7000102@atmel.com>
References: <1424258975-28611-1-git-send-email-achandran@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Arun Chandran <achandran@mvista.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424258975-28611-1-git-send-email-achandran@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/02/2015 12:29, Arun Chandran a =E9crit :
> This patch converts all __raw_readl and __raw_writel function calls
> to their corresponding readl_relaxed and writel_relaxed variants.
>=20
> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
> when the CPU is configured in big endian mode.
>=20
> Signed-off-by: Arun Chandran <achandran@mvista.com>
> ---
> 	This patch is tested on xilinx ZC702 evaluation board with
> 	CONFIG_CPU_BIG_ENDIAN=3Dy and booting NFS rootfs

It seems okay:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
> ---
>  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++------
>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>  2 files changed, 20 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index ad76b8e..05fb36d 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>  	WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR) / 4=
);
> =20
>  	for(; p < end; p++, reg++)
> -		*p +=3D __raw_readl(reg);
> +		*p +=3D readl_relaxed(reg);
>  }
> =20
>  static int macb_halt_tx(struct macb *bp)
> @@ -1585,7 +1585,11 @@ static void macb_configure_dma(struct macb *bp=
)
>  		if (bp->dma_burst_length)
>  			dmacfg =3D GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
>  		dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
> -		dmacfg &=3D ~GEM_BIT(ENDIA);
> +		dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
> +		/* Tell the chip to byteswap descriptors on big-endian hosts */
> +#ifdef __BIG_ENDIAN
> +		dmacfg |=3D GEM_BIT(ENDIA_DESC);
> +#endif
>  		if (bp->dev->features & NETIF_F_HW_CSUM)
>  			dmacfg |=3D GEM_BIT(TXCOEN);
>  		else
> @@ -1832,14 +1836,14 @@ static void gem_update_stats(struct macb *bp)
> =20
>  	for (i =3D 0; i < GEM_STATS_LEN; ++i, ++p) {
>  		u32 offset =3D gem_statistics[i].offset;
> -		u64 val =3D __raw_readl(bp->regs + offset);
> +		u64 val =3D readl_relaxed(bp->regs + offset);
> =20
>  		bp->ethtool_stats[i] +=3D val;
>  		*p +=3D val;
> =20
>  		if (offset =3D=3D GEM_OCTTXL || offset =3D=3D GEM_OCTRXL) {
>  			/* Add GEM_OCTTXH, GEM_OCTRXH */
> -			val =3D __raw_readl(bp->regs + offset + 4);
> +			val =3D readl_relaxed(bp->regs + offset + 4);
>  			bp->ethtool_stats[i] +=3D ((u64)val) << 32;
>  			*(++p) +=3D val;
>  		}
> @@ -2191,12 +2195,14 @@ static void macb_probe_queues(void __iomem *m=
em,
>  	*num_queues =3D 1;
> =20
>  	/* is it macb or gem ? */
> -	mid =3D __raw_readl(mem + MACB_MID);
> +	mid =3D readl_relaxed(mem + MACB_MID);
> +
>  	if (MACB_BFEXT(IDNUM, mid) !=3D 0x2)
>  		return;
> =20
>  	/* bit 0 is never set but queue 0 always exists */
> -	*queue_mask =3D __raw_readl(mem + GEM_DCFG6) & 0xff;
> +	*queue_mask =3D readl_relaxed(mem + GEM_DCFG6) & 0xff;
> +
>  	*queue_mask |=3D 0x1;
> =20
>  	for (hw_q =3D 1; hw_q < MACB_MAX_QUEUES; ++hw_q)
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethern=
et/cadence/macb.h
> index 31dc080..57f0a1a 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -229,7 +229,8 @@
>  /* Bitfields in DMACFG. */
>  #define GEM_FBLDO_OFFSET	0 /* fixed burst length for DMA */
>  #define GEM_FBLDO_SIZE		5
> -#define GEM_ENDIA_OFFSET	7 /* endian swap mode for packet data acces=
s */
> +#define GEM_ENDIA_DESC_OFFSET	6 /* endian swap mode for management d=
escriptor access */
> +#define GEM_ENDIA_PKT_OFFSET	7 /* endian swap mode for packet data a=
ccess */
>  #define GEM_ENDIA_SIZE		1
>  #define GEM_RXBMS_OFFSET	8 /* RX packet buffer memory size select */
>  #define GEM_RXBMS_SIZE		2
> @@ -423,17 +424,17 @@
> =20
>  /* Register access macros */
>  #define macb_readl(port,reg)				\
> -	__raw_readl((port)->regs + MACB_##reg)
> +	readl_relaxed((port)->regs + MACB_##reg)
>  #define macb_writel(port,reg,value)			\
> -	__raw_writel((value), (port)->regs + MACB_##reg)
> +	writel_relaxed((value), (port)->regs + MACB_##reg)
>  #define gem_readl(port, reg)				\
> -	__raw_readl((port)->regs + GEM_##reg)
> +	readl_relaxed((port)->regs + GEM_##reg)
>  #define gem_writel(port, reg, value)			\
> -	__raw_writel((value), (port)->regs + GEM_##reg)
> +	writel_relaxed((value), (port)->regs + GEM_##reg)
>  #define queue_readl(queue, reg)				\
> -	__raw_readl((queue)->bp->regs + (queue)->reg)
> +	readl_relaxed((queue)->bp->regs + (queue)->reg)
>  #define queue_writel(queue, reg, value)			\
> -	__raw_writel((value), (queue)->bp->regs + (queue)->reg)
> +	writel_relaxed((value), (queue)->bp->regs + (queue)->reg)
> =20
>  /* Conditional GEM/MACB macros.  These perform the operation to the =
correct
>   * register dependent on whether the device is a GEM or a MACB.  For=
 registers
>=20


--=20
Nicolas Ferre
