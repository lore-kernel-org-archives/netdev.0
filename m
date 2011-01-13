From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v4 09/10] ARM: mx28: read fec mac address from ocotp
Date: Thu, 13 Jan 2011 15:50:47 +0100
Message-ID: <20110113145047.GU24920@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-10-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:32893 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756847Ab1AMOvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 09:51:00 -0500
Content-Disposition: inline
In-Reply-To: <1294297998-26930-10-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shawn,

$SUBJECT ~=3D s,mx28,mxs/mx28evk, please

On Thu, Jan 06, 2011 at 03:13:17PM +0800, Shawn Guo wrote:
> Read fec mac address from ocotp and save it into fec_platform_data
> mac field for fec driver to use.
>=20
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v2:
>  - It's not necessary to remove "const" for fec_platform_data from
>    platform-fec.c and devices-common.h, so add it back.
>  - Hard-coding Freescale OUI (00:04:9f) instead of just the first
>    two two octets.
>  - Correct the return of mx28evk_fec_get_mac() and check it
>    with caller
>=20
>  arch/arm/mach-mxs/mach-mx28evk.c |   32 ++++++++++++++++++++++++++++=
++++
>  1 files changed, 32 insertions(+), 0 deletions(-)
>=20
> diff --git a/arch/arm/mach-mxs/mach-mx28evk.c b/arch/arm/mach-mxs/mac=
h-mx28evk.c
> index def6519..54fa512 100644
> --- a/arch/arm/mach-mxs/mach-mx28evk.c
> +++ b/arch/arm/mach-mxs/mach-mx28evk.c
> @@ -129,12 +129,44 @@ static struct fec_platform_data mx28_fec_pdata[=
] =3D {
>  	},
>  };
> =20
> +static int __init mx28evk_fec_get_mac(void)
> +{
> +	int i, ret;
> +	u32 val;
> +
> +	/*
> +	 * OCOTP only stores the last 4 octets for each mac address,
> +	 * so hard-code Freescale OUI (00:04:9f) here.
> +	 */
> +	for (i =3D 0; i < 2; i++) {
> +		ret =3D mxs_read_ocotp(0x20 + i * 0x10, 1, &val);
> +		if (ret)
> +			goto error;
> +
> +		mx28_fec_pdata[i].mac[0] =3D 0x00;
> +		mx28_fec_pdata[i].mac[1] =3D 0x04;
> +		mx28_fec_pdata[i].mac[2] =3D 0x9f;
> +		mx28_fec_pdata[i].mac[3] =3D (val >> 16) & 0xff;
> +		mx28_fec_pdata[i].mac[4] =3D (val >> 8) & 0xff;
> +		mx28_fec_pdata[i].mac[5] =3D (val >> 0) & 0xff;
> +	}
> +
> +	return 0;
> +
> +error:
> +	pr_err("%s: timeout when reading fec mac from OCOTP\n", __func__);
> +	return ret;
> +}
> +
>  static void __init mx28evk_init(void)
>  {
>  	mxs_iomux_setup_multiple_pads(mx28evk_pads, ARRAY_SIZE(mx28evk_pads=
));
> =20
>  	mx28_add_duart();
> =20
> +	if (mx28evk_fec_get_mac())
> +		pr_warn("%s: failed on fec mac setup\n", __func__);
> +
>  	mx28evk_fec_reset();
>  	mx28_add_fec(0, &mx28_fec_pdata[0]);
>  #ifdef CONFIG_FEC2
> --=20
> 1.7.1
>=20
>=20
>=20

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
