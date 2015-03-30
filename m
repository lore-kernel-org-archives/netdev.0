From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single
 CAN frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 12:10:22 +0200
Message-ID: <5519210E.40005@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="8VlT4Jt1lmIOoutuv9348XjNbaCfEjqQn"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47032 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbbC3KK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 06:10:29 -0400
In-Reply-To: <1427652564-32181-2-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8VlT4Jt1lmIOoutuv9348XjNbaCfEjqQn
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/29/2015 08:09 PM, Oliver Hartkopp wrote:
> The CAN_RAW socket can set multiple CAN identifier specific filters tha=
t lead
> to multiple filters in the af_can.c filter processing. These filters ar=
e
> indenpendent from each other which leads to logical OR'ed filters when =
applied.
>=20
> This patch makes sure that every CAN frame which is filtered for a spec=
ific
> socket is only delivered once to the user space. This is independent fr=
om the
> number of matching CAN filters of this socket.
>=20
> As the can_raw() function is executed from NET_RX softirq the introduce=
d
> variables are implemented as per-CPU variables to avoid extensive locki=
ng at
> CAN frame reception time.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  net/can/raw.c | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
>=20
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 00c13ef..866a9b3 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -86,6 +86,8 @@ struct raw_sock {
>  	struct can_filter dfilter; /* default/single filter */
>  	struct can_filter *filter; /* pointer to filter(s) */
>  	can_err_mask_t err_mask;
> +	struct sk_buff __percpu **uniq_skb;
> +	ktime_t __percpu *uniq_tstamp;
>  };
> =20
>  /*
> @@ -123,6 +125,15 @@ static void raw_rcv(struct sk_buff *oskb, void *da=
ta)
>  	if (!ro->fd_frames && oskb->len !=3D CAN_MTU)
>  		return;
> =20
> +	/* eliminate multiple filter matches for the same skb */
> +	if (*this_cpu_ptr(ro->uniq_skb) =3D=3D oskb &&
> +	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
> +			return;
> +	} else {
> +		*this_cpu_ptr(ro->uniq_skb) =3D oskb;
> +		*this_cpu_ptr(ro->uniq_tstamp) =3D oskb->tstamp;
> +	}
> +

What happens if you're preempted somewhere in this code, it's not
atomic? I think, if we only have to take care about the skb, an atomic
compare exchange would work. But we have two variables....If you use a
struct (see previous mail), I think the usage of get_cpu_ptr(),
git_cpu_ptr() ensures that we're not preempted.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8VlT4Jt1lmIOoutuv9348XjNbaCfEjqQn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGSESAAoJECte4hHFiupU1xEP/10s5TbZMvcx7ZUpKS8BvOzX
0VVgYeLSoqyOgHxq+BRISUFuNmdEkWZ+HLmbjS7daMo38P7MKxQjhS/Q5I6Lb6b2
N5HWpJocTiw9R3kJupSG8EO/JXlLVUmkXxMH9uiuogrWB0MzUwUP1iJCPXdmFvx0
ZZkFGXE0sl7hgrSy5J9QMm6JstItcjZlp/LuE3xoKmwrJZ3gRhDfHp7lgRmfSvh6
uA73ktiDGskWJweYOcKH797EOS2QCVyG1ixj4uLz2wp72ypGB855Qsqz2pIPDDwu
9IROHUeR6k6f0ayobWE0TbL3qorr/yexMmLI6Xw+W0bUGIUPmZCKsevId/imwiKZ
5MWzLlI2P7KQinHxJfTqGKUhIdWjGpc7ovluV3Fhz4pUTLMIHejwZ3z+8GH2RLoF
al8tJxHY40ltiUQWd7a0gQorhsOXYpcYiuZV9gdwnqB5aYdsjoMPnKgKz9HWXiMq
owyWYmKe2qsY6zVWUXkXZzISGoWPHTCo59NFHr8cBaqOzqZ3LulCD5StSeL4iZcG
EkukuHr/SYICgh8l8f/t3g4XGJbUyQzSOFD1P4W2Uh5DHWjq1wli19Au/kpu8dQu
qfyrOUPrkYKcGDACcOdob2NG32WDBlYeo39Ogw6dIyeo/TW8flFfwdrOmzZpDh1+
SfKiqxNH+DF/NxAoWdCI
=4MXn
-----END PGP SIGNATURE-----

--8VlT4Jt1lmIOoutuv9348XjNbaCfEjqQn--
