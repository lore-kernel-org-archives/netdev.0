From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/5] bnx2: Read firmware version from VPD.
Date: Thu, 03 Dec 2009 20:17:13 +0000
Message-ID: <1259871433.2780.42.camel@achroite.uk.solarflarecom.com>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
	 <1259869595-6450-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43529 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbZLCURO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:17:14 -0500
In-Reply-To: <1259869595-6450-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-03 at 11:46 -0800, Michael Chan wrote:
> And display it through ethtool -i.
>=20
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/bnx2.c |  102 ++++++++++++++++++++++++++++++++++++++++++=
++++++++--
>  1 files changed, 99 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index dba3840..b7bc74b 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -7722,6 +7722,93 @@ bnx2_get_pci_speed(struct bnx2 *bp)
> =20
>  }
> =20
> +static void __devinit
> +bnx2_read_vpd_fw_ver(struct bnx2 *bp)
> +{
> +	int rc, i, v0_len =3D 0;
> +	u8 *data;
> +	u8 *v0_str =3D NULL;
> +	bool mn_match =3D false;
> +
> +#define BNX2_MAX_VER_SLEN	30

And how about:

#define BNX2_VPD_LEN		128

and then using that instead of all the magic numbers below...

> +	data =3D kmalloc(256, GFP_KERNEL);
> +	if (!data)
> +		return;
> +
> +	rc =3D bnx2_nvram_read(bp, 0x300, data + 128, 128);
> +	if (rc)
> +		goto vpd_done;
> +
> +	for (i =3D 0; i < 128; i +=3D 4) {
> +		data[i] =3D data[i + 131];
> +		data[i + 1] =3D data[i + 130];
> +		data[i + 2] =3D data[i + 129];
> +		data[i + 3] =3D data[i + 128];
> +	}

Is this correct for both big-endian and little-endian architectures?

> +	for (i =3D 0; i < 128; ) {

Allowing for the size of a long tag, that should be:

	for (i =3D 0; i <=3D BNX2_VPD_LEN - 3; ) {

> +		unsigned char val =3D data[i];
> +		unsigned int block_end;
> +
> +		if (val =3D=3D 0x82 || val =3D=3D 0x91) {
> +			i =3D (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
> +			continue;
> +		}
> +
> +		if (val !=3D 0x90)
> +			goto vpd_done;
> +
> +		block_end =3D (i + 3 + (data[i + 1] + (data[i + 2] << 8)));

=EF=BB=BFPerhaps these VPD tag values should go in pci_regs.h.  And the=
re's
really no need to repeat the length calculation.

> +		i +=3D 3;
> +
> +		if (block_end > 128)
> +			goto vpd_done;
> +
> +		while (i < (block_end - 2)) {
> +			if (data[i] =3D=3D 'M' && data[i + 1] =3D=3D 'N') {
> +				int mn_len =3D data[i + 2];
> +
> +				if (mn_len !=3D 4)
> +					goto vpd_done;
> +
> +				i +=3D 3;
> +				if (memcmp(&data[i], "1028", 4))
> +					goto vpd_done;
> +				mn_match =3D true;
> +				i +=3D 4;
> +
> +			} else if (data[i] =3D=3D 'V' && data[i + 1] =3D=3D '0') {
> +				v0_len =3D data[i + 2];
> +
> +				i +=3D 3;
> +				if (v0_len > BNX2_MAX_VER_SLEN ||
> +				    (v0_len + i) > 128)
> +					goto vpd_done;
> +
> +				if (v0_len > BNX2_MAX_VER_SLEN)
> +					v0_len =3D BNX2_MAX_VER_SLEN;
> +
> +				v0_str =3D &data[i];
> +				i +=3D data[i + 2];

This last statement is reading the length from the wrong byte since i
has already been updated.

> +			} else {
> +				i +=3D 3 + data[i + 2];
> +			}
[...]

=EF=BB=BFIt would make more sense to read and validate length just once=
:

=EF=BB=BF		while (i < (block_end - 2)) {
			int len =3D data[i + 2];

			if (i + 3 + len > block_end)
				goto vpd_done;

			if (data[i] =3D=3D 'M' && data[i + 1] =3D=3D 'N') {
				if (len !=3D 4 ||
				    memcmp(&data[i + 3], "1028", 4))
					goto vpd_done;
				mn_match =3D true;
			} else if (data[i] =3D=3D 'V' && data[i + 1] =3D=3D '0') {
				if (len > BNX2_MAX_VER_SLEN)
					goto vpd_done;
				v0_str =3D &data[i + 3];
				v0_len =3D len;
			}

			i +=3D 3 + len;
			...

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

