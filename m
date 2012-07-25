From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 03/17] Drivers: hv: kvp: Cleanup error handling in KVP
Date: Wed, 25 Jul 2012 02:10:44 +0100
Message-ID: <1343178644.5132.103.camel@deadeye.wl.decadent.org.uk>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
	 <1343145701-3691-1-git-send-email-kys@microsoft.com>
	 <1343145701-3691-3-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dVLjE4k0PQLzniyVIprS"
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343145701-3691-3-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-dVLjE4k0PQLzniyVIprS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-07-24 at 09:01 -0700, K. Y. Srinivasan wrote:
> In preparation to implementing IP injection, cleanup the way we propagate
> and handle errors both in the driver as well as in the user level daemon.
>=20
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> ---
>  drivers/hv/hv_kvp.c      |  112 +++++++++++++++++++++++++++++++++++++---=
------
>  include/linux/hyperv.h   |   17 +++++---
>  tools/hv/hv_kvp_daemon.c |   70 +++++++++++++++-------------
>  3 files changed, 138 insertions(+), 61 deletions(-)
>=20
> diff --git a/drivers/hv/hv_kvp.c b/drivers/hv/hv_kvp.c
> index 0012eed..9b7fc4a 100644
> --- a/drivers/hv/hv_kvp.c
> +++ b/drivers/hv/hv_kvp.c
[...]
> @@ -109,27 +154,52 @@ kvp_cn_callback(struct cn_msg *msg, struct netlink_=
skb_parms *nsp)
>  {
>  	struct hv_kvp_msg *message;
>  	struct hv_kvp_msg_enumerate *data;
> +	int	error =3D 0;
> =20
>  	message =3D (struct hv_kvp_msg *)msg->data;
> -	switch (message->kvp_hdr.operation) {
> +
> +	/*
> +	 * If we are negotiating the version information
> +	 * with the daemon; handle that first.
> +	 */
> +
> +	if (in_hand_shake) {
> +		if (kvp_handle_handshake(message))
> +			in_hand_shake =3D false;
> +		return;
> +	}
> +
> +	/*
> +	 * Based on the version of the daemon, we propagate errors from the
> +	 * daemon differently.
> +	 */
> +
> +	data =3D &message->body.kvp_enum_data;
> +
> +	switch (dm_reg_value) {
>  	case KVP_OP_REGISTER:
> -		pr_info("KVP: user-mode registering done.\n");
> -		kvp_register();
> -		kvp_transaction.active =3D false;
> -		hv_kvp_onchannelcallback(kvp_transaction.kvp_context);
> +		/*
> +		 * Null string is used to pass back error condition.
> +		 */
> +		if (!strlen(data->data.key))

Do we know that the key is null-terminated here?  Shouldn't we just
check whether data->data.key[0] =3D=3D 0?

> +			error =3D HV_S_CONT;
>  		break;
> =20
> -	default:
> -		data =3D &message->body.kvp_enum_data;
> +	case KVP_OP_REGISTER1:
>  		/*
> -		 * Complete the transaction by forwarding the key value
> -		 * to the host. But first, cancel the timeout.
> +		 * We use the message header information from
> +		 * the user level daemon to transmit errors.
>  		 */
> -		if (cancel_delayed_work_sync(&kvp_work))
> -			kvp_respond_to_host(data->data.key,
> -					 data->data.value,
> -					!strlen(data->data.key));
> +		error =3D *((int *)(&message->kvp_hdr.operation));
[...]

What's with the casting (repeated in many other places)?  Wouldn't it be
better to redefine struct hv_kvp_msg to start with something like:

	union {
		struct hv_kvp_hdr	request;
		int			error;
	} kvp_hdr;

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-dVLjE4k0PQLzniyVIprS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUA9Hlee/yOyVhhEJAQouXw//ahPlqa1CElOe4nmUzBItnMKsMz4rfsTK
SbfYiVQh7VCrbXzBCvB/I/C7/fJKThIGxIRFJmkTUKAneRtHoXkteIW4RmhBPGRz
aieXq/kK+blC4BbBQnnw4ZG5TCemBd5DUFvmaG6M5APnq2W9ljlGcMb5W2ezUNle
3z6zAN/MGy+Qw99b3nWhJC2oI6jkxcZ1wfyvSOus1T1dgIOVLmrlyvqIyBthnrAK
bdPfFnRDaJDXHR4g08F1HdarXZew3nttY8Cd41xrv2O4cpSLdCJTLeM9AqlW3QEq
fxnugoe7Fr64VxVDXLv/Wdua9Ip7TVZvBp/6MwmMbA8TFdIbq8u/7hJJQREWPg/W
7fD+AiJRvjrTI5Hdz/wnWxKZd6N0Xuwc++VtTXYV2seDAQ1v6WfhwBg1XMJ1A6wH
QpR9w5CdCRk9bKyRya6D4FyJJfTqTZdKuugNceGQf5Ga/xN5KXGfRLbfHPV8Fu9/
3Ti/Fa3A/Dp0j4Cm4ienZxC5HaC+yRuDeylhmfMa98G6IxQ9LngqkqIdupzEP4wq
NMM+zO6zHZZOwBQZkfWF6qfrm1c/Aj/zZQkDh8QMSVi33vDOalkOIeSquSU2cM7M
K8XvlJ66f53ytcrbc5UiwQor62l+IYaROBUR7LECUf0MNlWQrB+XD5WwlPpZktJ7
nFK1HJJoVFk=
=hjHy
-----END PGP SIGNATURE-----

--=-dVLjE4k0PQLzniyVIprS--
