From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: fix endian code for avr32
Date: Wed, 18 Mar 2015 15:40:50 +0100
Message-ID: <55098E72.7060000@monstr.eu>
References: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ChrBcUTCe0SFstIlxwxgqXBGU5WDKsQAE"
Cc: Linux Networking List <netdev@vger.kernel.org>,
	Arun Chandran <achandran@mvista.com>,
	Haavard Skinnemoen <hskinnemoen@gmail.com>,
	Hans-Christian Egtvedt <egtvedt@samfundet.no>,
	Linux Kernel List <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426676247-14023-1-git-send-email-ben.dooks@codethink.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ChrBcUTCe0SFstIlxwxgqXBGU5WDKsQAE
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi,

On 03/18/2015 11:57 AM, Ben Dooks wrote:
> [note this has yet to be compile tested on avr32]
>=20
> The changes to run the macb driver in 29af05aeb98e ("net: macb:
> Add big endian CPU support") to support big endian operation on
> ARM may not work on AVR32 which already is naturally big endian
> architecture (and the driver already works here).
>=20
> In this case  the readl/writel relaxed will do the opposite of __raw
> accesors which arleady work. Add an indirection of cdneth_ prefixed

here is type.

> accesors which are changed as necessary. Also do not issue the DMA
> descritpor endian fetch configuration for AVR32.

ditto.

>=20
> From discussions with Arnd Bergman, the following fix changes the use
> of readl_relaxed and writel_relaxed with a version that can be put
> back to __raw_readl/__raw_writel for the CONFIG_AVR32 case (and also
> remove the change to the DMA descriptor endian).
>=20
> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> --
> CC: Linux Networking List <netdev@vger.kernel.org>
> CC: Arun Chandran <achandran@mvista.com>
> CC: Haavard Skinnemoen <hskinnemoen@gmail.com>
> CC: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> CC: Linux Kernel List <linux-kernel@vger.kernel.org>
> CC: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 14 +++++++-------
>  drivers/net/ethernet/cadence/macb.h | 20 ++++++++++++++------
>  2 files changed, 21 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
> index b71e316..1c3f6e7 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>  	WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR) / 4);=

> =20
>  	for(; p < end; p++, reg++)
> -		*p +=3D readl_relaxed(reg);
> +		*p +=3D cdneth_readl(reg);
>  }
> =20
>  static int macb_halt_tx(struct macb *bp)
> @@ -1587,7 +1587,7 @@ static void macb_configure_dma(struct macb *bp)
>  		dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
>  		dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
>  		/* Tell the chip to byteswap descriptors on big-endian hosts */
> -#ifdef __BIG_ENDIAN
> +#if defined(__BIG_ENDIAN) && !defined(CONFIG_AVR32)
>  		dmacfg |=3D GEM_BIT(ENDIA_DESC);
>  #endif

the code has changed here - please rebase it on the top of net-next tree.=


>  		if (bp->dev->features & NETIF_F_HW_CSUM)
> @@ -1836,14 +1836,14 @@ static void gem_update_stats(struct macb *bp)
> =20
>  	for (i =3D 0; i < GEM_STATS_LEN; ++i, ++p) {
>  		u32 offset =3D gem_statistics[i].offset;
> -		u64 val =3D readl_relaxed(bp->regs + offset);
> +		u64 val =3D cdneth_readl(bp->regs + offset);
> =20
>  		bp->ethtool_stats[i] +=3D val;
>  		*p +=3D val;
> =20
>  		if (offset =3D=3D GEM_OCTTXL || offset =3D=3D GEM_OCTRXL) {
>  			/* Add GEM_OCTTXH, GEM_OCTRXH */
> -			val =3D readl_relaxed(bp->regs + offset + 4);
> +			val =3D cdneth_readl(bp->regs + offset + 4);
>  			bp->ethtool_stats[i] +=3D ((u64)val) << 32;
>  			*(++p) +=3D val;
>  		}
> @@ -2191,17 +2191,17 @@ static void macb_probe_queues(void __iomem *mem=
,
>  	unsigned int hw_q;
>  	u32 mid;
> =20
> -	*queue_mask =3D 0x1;
> +	*queue_mask =3D 0x1;\
>  	*num_queues =3D 1;
> =20
>  	/* is it macb or gem ? */
> -	mid =3D readl_relaxed(mem + MACB_MID);
> +	mid =3D cdneth_readl(mem + MACB_MID);
> =20
>  	if (MACB_BFEXT(IDNUM, mid) !=3D 0x2)
>  		return;
> =20
>  	/* bit 0 is never set but queue 0 always exists */
> -	*queue_mask =3D readl_relaxed(mem + GEM_DCFG6) & 0xff;
> +	*queue_mask =3D cdneth_readl(mem + GEM_DCFG6) & 0xff;
> =20
>  	*queue_mask |=3D 0x1;
> =20
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet=
/cadence/macb.h
> index 6cfff0b..c003e98 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -422,19 +422,27 @@
>  		    << GEM_##name##_OFFSET))		\
>  	 | GEM_BF(name, value))
> =20
> +#ifdef CONFIG_AVR32
> +#define cdneth_readl	__raw_readl
> +#define cdneth_writel	__raw_writel
> +#else
> +#define cdneth_readl	readl_relaxed
> +#define cdneth_writel	writel_relaxed
> +#endif

but this seems to me the way back. If cadence IP is big-endian then you c=
an you what
I have suggested to you before. Just do endian detection on IP itself.
It means one checking will be for arm platforms if cpu runs big or little=
 endian
and if IP is big on little endian.
It will end up in dynamic IO real/write functions which seems to the best=
 way to go.
Of course doing this in this style means to add one more load in every io=
 operations
but I don't think this is impact performance a lot.

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--ChrBcUTCe0SFstIlxwxgqXBGU5WDKsQAE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlUJjnIACgkQykllyylKDCH8JwCbBum2E4+RQssDoEIKfoT6cOC8
GJIAnRrLfKUb87YmZ0jbvZRfD3wEFJZR
=56tt
-----END PGP SIGNATURE-----

--ChrBcUTCe0SFstIlxwxgqXBGU5WDKsQAE--
