From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 7/7] can: m_can: workaround for transmit data less than
 4 bytes
Date: Mon, 03 Nov 2014 17:48:17 +0100
Message-ID: <5457B1D1.6080301@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-7-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="206uA6wgHj6i1fqxnTNkFsUomGXXx2M8l"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36780 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbaKCQs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:48:29 -0500
In-Reply-To: <1414579527-31100-7-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--206uA6wgHj6i1fqxnTNkFsUomGXXx2M8l
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> We meet an IC issue that we have to write the full 8 bytes (whatever
> value for the second word) in Message RAM to avoid bit error for transm=
it
> data less than 4 bytes.

Is this a SoC or a m_can problem? Are all versions of the SoC/m_can
affected? Is there a m_can version register somewhere?

> Without the workaround, we can easily see the following errors:
> root@imx6qdlsolo:~# ip link set can0 up type can bitrate 1000000
> [   66.882520] IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready
> root@imx6qdlsolo:~# cansend can0 123#112233
> [   66.935640] m_can 20e8000.can can0: Bit Error Uncorrected
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
>  drivers/net/can/m_can/m_can.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index 219e0e3..f2d9ebe 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1058,10 +1058,19 @@ static netdev_tx_t m_can_start_xmit(struct sk_b=
uff *skb,
>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 16)=
;
> =20
> -	for (i =3D 0; i < cf->len; i +=3D 4)
> +	for (i =3D 0; i < cf->len; i +=3D 4) {
>  		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
>  				 *(u32 *)(cf->data + i));
> =20
> +		/* FIXME: we meet an IC issue that we have to write the full 8

FIXME usually indicates that the driver needs some work here. Just
describe your hardware bug, you might add a reference to an errata if
available, though.

> +		 * bytes (whatever value for the second word) in Message RAM to
> +		 * avoid bit error for transmit data less than 4 bytes
> +		 */
> +		if (cf->len <=3D 4)
> +			m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4 + 1),
> +					 0x0);

This workaround doesn't handle the dlc =3D=3D 0 case, your error descript=
ion
isn't completely if this is a problem, too.

It should be possible to change the for loop to go always to 8, or
simply unroll the loop:

/* errata description goes here */
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));

> +	}
> +
>  	can_put_echo_skb(skb, dev, 0);
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--206uA6wgHj6i1fqxnTNkFsUomGXXx2M8l
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV7HRAAoJECte4hHFiupUZqIP/1wukuQNrs+up8EJya2d0HWK
wKRsG6Ehojae8D7vsixYPtUYIHSBXmSfBFUMxFMWcVgtAr89+EWoYGXFr7NHCHZw
uZdMknhuwFDuPspKuIeVNQvCW71l6ATX2ETW9nM2IlPIvP9fn2Tdyz4vLR34P+hC
J0H3o8O4R7WhK1+uqedlEVgHVviSuUAteAre9jI23mUPVo0ujdbr3G4C85GyU4wv
S9JK1vFjsz+b8XjqxWCcJmgSJUQ+p4D+morXad7TmeYTGEFqiIC/FVbEj5dA7I+j
ctvFRKhZgj11qQMeS/u2wEBeZW6+qV7XOwCMxjjDyLUAzpsv7VmPai7KqqtXeT+1
7FvTEsYPKLP9KTg9DwP5X2oh9U6kkqqBrjn+OHXrdtIWuxulau0mAr4jk93A2Wv6
2qI9Tj4+/GN8ekBVhunATtb0KJi/+uu4MD7X3OMCOb4vy3YbKK7QULblgYvWu/Kh
A0nXRQ5Ipg5Cse7FKh7LOFJk3a6esC4hh1hQEsfbzjpwxHpFmr679ebU83eIdqd2
bDiBJkqW+wHfoIAvr9OySX8l/yjady5t0IgB6A3F69MZLlA0MYYqweA1wq4R+n9b
pknbikRKobUzoDgnmRGa37UWxsBorDvGWRYOCljichWcHH7hF30UHChrAfy/ieud
V+toLgj06yKv4LZNFklL
=XiLs
-----END PGP SIGNATURE-----

--206uA6wgHj6i1fqxnTNkFsUomGXXx2M8l--
