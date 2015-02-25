From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Wed, 25 Feb 2015 11:02:16 +0100
Message-ID: <54ED9DA8.3040809@monstr.eu>
References: <54EB34E7.7060400@monstr.eu> <1424763572-23317-1-git-send-email-achandran@mvista.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Cr1VLlVGCFtalBHwSM65WVg1S5ABOMf1f"
To: Arun Chandran <achandran@mvista.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424763572-23317-1-git-send-email-achandran@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Cr1VLlVGCFtalBHwSM65WVg1S5ABOMf1f
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/24/2015 08:39 AM, Arun Chandran wrote:
> This patch converts all __raw_readl and __raw_writel function calls
> to their corresponding readl_relaxed and writel_relaxed variants.
>=20
> It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
> when the cpu is configured in big endian mode.
>=20
> Signed-off-by: Arun Chandran <achandran@mvista.com>
> ---
> 	This patch is tested on xilinx ZC702 evaluation board with
> 	CONFIG_CPU_BIG_ENDIAN=3Dy and booting NFS rootfs
> 	Added on the fly IP endianness detection according to
> 	comments from Michal Simek.
> ---
> ---
>  drivers/net/ethernet/cadence/macb.c | 33 +++++++++++++++++++++++++++--=
----
>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>  2 files changed, 35 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
> index ad76b8e..1642911 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
>  	WARN_ON((unsigned long)(end - p - 1) !=3D (MACB_TPF - MACB_PFR) / 4);=

> =20
>  	for(; p < end; p++, reg++)
> -		*p +=3D __raw_readl(reg);
> +		*p +=3D readl_relaxed(reg);
>  }
> =20
>  static int macb_halt_tx(struct macb *bp)
> @@ -1578,6 +1578,7 @@ static u32 macb_dbw(struct macb *bp)
>  static void macb_configure_dma(struct macb *bp)
>  {
>  	u32 dmacfg;
> +	u32 tmp, ncr;
> =20
>  	if (macb_is_gem(bp)) {
>  		dmacfg =3D gem_readl(bp, DMACFG) & ~GEM_BF(RXBS, -1L);
> @@ -1585,7 +1586,25 @@ static void macb_configure_dma(struct macb *bp)
>  		if (bp->dma_burst_length)
>  			dmacfg =3D GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
>  		dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
> -		dmacfg &=3D ~GEM_BIT(ENDIA);
> +		dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
> +
> +		/* Here we use the loopback bit of net_ctrl register to detect
> +		 * endianness on IP. save it first. Program swaped mode for
> +		 * management descriptor accesses if writing to loop back bit
> +		 * and reading it back brings no change in bit value.
> +		 */
> +		ncr =3D macb_readl(bp, NCR);
> +		__raw_writel(MACB_BIT(LLB), bp->regs + MACB_NCR);
> +		tmp =3D  __raw_readl(bp->regs + MACB_NCR);


I have tested this patch on zc702 le and be and it is working.
The comment is not fully accurate. Sorry I thought that you are using a l=
ittle bit different
configuration than Zynq. The case I had in mind is that CPU and also IP c=
an have different endianness.

The code above is not checking endianness on IP itself but CPU endianness=
 because IP is in little
endian mode all the time. But the logic for detecting this on CPU is corr=
ect and this is what
you need to do on Zynq. You are writing big endian value to little endian=
 register and read it back
to see if it was correctly written or not.

Can you please fix that comment to reflect this?

Thanks,
Michal
--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--Cr1VLlVGCFtalBHwSM65WVg1S5ABOMf1f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTtna0ACgkQykllyylKDCEbxgCdEL58+Y8dKIsAav4BM/3vhBAn
irkAnA8eMbPkkFFHmtyvNGGaF6e5jIvO
=1kvf
-----END PGP SIGNATURE-----

--Cr1VLlVGCFtalBHwSM65WVg1S5ABOMf1f--
