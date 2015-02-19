From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Thu, 19 Feb 2015 13:22:56 +0100
Message-ID: <54E5D5A0.90005@monstr.eu>
References: <1424258975-28611-1-git-send-email-achandran@mvista.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="KBjP6POKA88dW8gpgxGv5Q8rdrDcK3bAt"
To: Arun Chandran <achandran@mvista.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424258975-28611-1-git-send-email-achandran@mvista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--KBjP6POKA88dW8gpgxGv5Q8rdrDcK3bAt
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/18/2015 12:29 PM, Arun Chandran wrote:
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
> ---
> ---
>  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++------
>  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
>  2 files changed, 20 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet=
/cadence/macb.c
> index ad76b8e..05fb36d 100644
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
> @@ -1585,7 +1585,11 @@ static void macb_configure_dma(struct macb *bp)
>  		if (bp->dma_burst_length)
>  			dmacfg =3D GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
>  		dmacfg |=3D GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
> -		dmacfg &=3D ~GEM_BIT(ENDIA);
> +		dmacfg &=3D ~GEM_BIT(ENDIA_PKT);
> +		/* Tell the chip to byteswap descriptors on big-endian hosts */
> +#ifdef __BIG_ENDIAN
> +		dmacfg |=3D GEM_BIT(ENDIA_DESC);
> +#endif

I don't think this is the best way what you should do.
Instead of having this ifdef here you should find out any reg and detect =
if the IP
is in big endian or little endian mode. I have done it for some xilinx IP=
s which
can run on big or little endian system.
In general find reg which some field which has some meaning - write there=
 1
and read expected value and based on that decide if you are on big or lit=
tle endian system.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--KBjP6POKA88dW8gpgxGv5Q8rdrDcK3bAt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAlTl1aYACgkQykllyylKDCFEYQCfY+xeL7r0iarjTE+KOYl523+v
7BMAn0YY5o6jHF/pRd0jCfiEyhD4nrpW
=eV/j
-----END PGP SIGNATURE-----

--KBjP6POKA88dW8gpgxGv5Q8rdrDcK3bAt--
