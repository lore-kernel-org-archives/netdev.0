From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH RFC v2 2/2] can: introduce new raw socket option
 to join the given CAN filters
Date: Tue, 31 Mar 2015 14:36:32 +0200
Message-ID: <551A94D0.1010608@pengutronix.de>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-3-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mHv4h3Vq5P6w8HiUFlao34nE5FjwxNmCk"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57137 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbbCaMgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 08:36:36 -0400
In-Reply-To: <1427652564-32181-3-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mHv4h3Vq5P6w8HiUFlao34nE5FjwxNmCk
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
> This socket option joines the given CAN filters in the way that only CA=
N frames
> are passed to user space that matched *all* given CAN filters. The sema=
ntic for
> the applied filters is therefore changed to a logical AND.
>=20
> This is useful especially when the filterset is a combination of filter=
s where
> the CAN_INV_FILTER flag is set in order to notch single CAN IDs or CAN =
ID
> ranges from the incoming traffic.
>=20
> As the can_raw() function is executed from NET_RX softirq the introduce=
d
> variables are implemented as per-CPU variables to avoid extensive locki=
ng at
> CAN frame reception time.
>=20
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>  Documentation/networking/can.txt | 20 ++++++++++++++++++--
>  include/uapi/linux/can/raw.h     |  1 +
>  net/can/raw.c                    | 36 ++++++++++++++++++++++++++++++++=
++++
>  3 files changed, 55 insertions(+), 2 deletions(-)
>=20
> diff --git a/Documentation/networking/can.txt b/Documentation/networkin=
g/can.txt
> index 0a2859a..5abad1e 100644
> --- a/Documentation/networking/can.txt
> +++ b/Documentation/networking/can.txt
> @@ -22,7 +22,8 @@ This file contains
>        4.1.3 RAW socket option CAN_RAW_LOOPBACK
>        4.1.4 RAW socket option CAN_RAW_RECV_OWN_MSGS
>        4.1.5 RAW socket option CAN_RAW_FD_FRAMES
> -      4.1.6 RAW socket returned message flags
> +      4.1.6 RAW socket option CAN_RAW_JOIN_FILTERS
> +      4.1.7 RAW socket returned message flags
>      4.2 Broadcast Manager protocol sockets (SOCK_DGRAM)
>        4.2.1 Broadcast Manager operations
>        4.2.2 Broadcast Manager message flags
> @@ -601,7 +602,22 @@ solution for a couple of reasons:
>    CAN FD frames by checking if the device maximum transfer unit is CAN=
FD_MTU.
>    The CAN device MTU can be retrieved e.g. with a SIOCGIFMTU ioctl() s=
yscall.
> =20
> -  4.1.6 RAW socket returned message flags
> +  4.1.6 RAW socket option CAN_RAW_JOIN_FILTERS
> +
> +  The CAN_RAW socket can set multiple CAN identifier specific filters =
that
> +  lead to multiple filters in the af_can.c filter processing. These fi=
lters
> +  are indenpendent from each other which leads to logical OR'ed filter=
s when
> +  applied (see 4.1.1).
> +
> +  This socket option joines the given CAN filters in the way that only=
 CAN
> +  frames are passed to user space that matched *all* given CAN filters=
=2E The
> +  semantic for the applied filters is therefore changed to a logical A=
ND.
> +
> +  This is useful especially when the filterset is a combination of fil=
ters
> +  where the CAN_INV_FILTER flag is set in order to notch single CAN ID=
s or
> +  CAN ID ranges from the incoming traffic.
> +
> +  4.1.7 RAW socket returned message flags
> =20
>    When using recvmsg() call, the msg->msg_flags may contain following =
flags:
> =20
> diff --git a/include/uapi/linux/can/raw.h b/include/uapi/linux/can/raw.=
h
> index 78ec76f..8735f108 100644
> --- a/include/uapi/linux/can/raw.h
> +++ b/include/uapi/linux/can/raw.h
> @@ -57,6 +57,7 @@ enum {
>  	CAN_RAW_LOOPBACK,	/* local loopback (default:on)       */
>  	CAN_RAW_RECV_OWN_MSGS,	/* receive my own msgs (default:off) */
>  	CAN_RAW_FD_FRAMES,	/* allow CAN FD frames (default:off) */
> +	CAN_RAW_JOIN_FILTERS,	/* all filters must match to trigger */
>  };
> =20
>  #endif /* !_UAPI_CAN_RAW_H */
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 866a9b3..dc68fa0 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -82,6 +82,8 @@ struct raw_sock {
>  	int loopback;
>  	int recv_own_msgs;
>  	int fd_frames;
> +	int join_filters;
> +	int __percpu *join_rx_count;
>  	int count;                 /* number of active filters */
>  	struct can_filter dfilter; /* default/single filter */
>  	struct can_filter *filter; /* pointer to filter(s) */
> @@ -128,10 +130,20 @@ static void raw_rcv(struct sk_buff *oskb, void *d=
ata)
>  	/* eliminate multiple filter matches for the same skb */
>  	if (*this_cpu_ptr(ro->uniq_skb) =3D=3D oskb &&
>  	    ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
> +		if (ro->join_filters) {
> +			this_cpu_inc(*ro->join_rx_count);
> +			/* drop frame until all enabled filters matched */
> +			if (*this_cpu_ptr(ro->join_rx_count) < ro->count)

Can we be sure, that all skbs are processed on the same CPU? So that
it's sufficient to just compare the "ro->join_rx_count" of this CPU with
"ro->count" (or do we have to use join_rx_count of all CPUs?)

> +				return;
> +		} else
>  			return;

nitpick: please use { } on both sides of the else.

>  	} else {
>  		*this_cpu_ptr(ro->uniq_skb) =3D oskb;
>  		*this_cpu_ptr(ro->uniq_tstamp) =3D oskb->tstamp;
> +		*this_cpu_ptr(ro->join_rx_count) =3D 1;
> +		/* drop first frame to check all enabled filters? */
> +		if (ro->join_filters && ro->count > 1)
> +			return;
>  	}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mHv4h3Vq5P6w8HiUFlao34nE5FjwxNmCk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJVGpTRAAoJECte4hHFiupUwBQQAJgz5PfXDmUvIRekTvJMR7Z2
ChDy35cgSzmRlFloWiZWu4vtINvMWPIXASxDEbrQFmuWEew/5PfWChJ08pNYkzYL
bzRw0hHg3a4RhdykCpglLDspclBScm/GcvCER4gPOhooq08OpblH1JNxkZI2J77k
fzjUYTqe857eDmdiYOPtOkDkq0arCd2frxL+5fWIuMDHp8rD7W4+qij44wVg7a3w
7bOrZVTk/PjRKbO/Dh8NUHccjl09GoO5+49+rBluY9kFgorJO4YCbemCojR4sF8r
sJTVP4vOqeXRJZneEpfq5tq3wJg+iIz8A9Vc1/fWv3INEd1Q0hwS2pOoTG8zbNWj
Sy6jEz/dzDB8zjx6xU11dpk7GEVwcOVdSTNLbB0JIKeE+I8o9Hq3Ke7mRGJqfDza
QQTo93Qcs6FQVMTnWkI5+yMIqy5eOU74GjTf4S/Wwme1/Oft3Fupv4FMo0rTcPHC
mH2E0fHu7Bth89ty7Hz4dteFwBPHv1c9nUzMrtbaCPqzlwynUjYMKNWkD7GRVAXj
aGowMGr/RkEiIq66pMVfcw5kIENyrgdN5xxRnY2ij5rbgQi5tYyCu7n6MlrrFRyU
qYl7xdtE7igg7zWv+NbVW1YgDiBEnVIAR3xJjo6WrqCs0eNJcqAjgvLDFtnesqmL
dcf8uquTREOQJtt+PjZ2
=mYn9
-----END PGP SIGNATURE-----

--mHv4h3Vq5P6w8HiUFlao34nE5FjwxNmCk--
