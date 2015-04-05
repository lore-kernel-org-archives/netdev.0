From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 5/5] ethtool: Support for configurable RSS hash
 function
Date: Sun, 05 Apr 2015 03:55:47 +0100
Message-ID: <1428202547.11260.160.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-6-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-63hWNEMeMh7/qa2QQOnR"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58806 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbbDEC4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 22:56:00 -0400
In-Reply-To: <1422193883-30504-6-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-63hWNEMeMh7/qa2QQOnR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> From: Eyal Perry <eyalpe@mellanox.com>
>=20
> This ethtool patch adds support to set and get the current RSS hash
> function for the device through through the new hfunc mask field in the
> ethtool_rxfh struct. Kernel supported hash function names are queried
> with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
> mask according to its index in the string-set.
>=20
> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  ethtool.8.in |  7 +++++++
>  ethtool.c    | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++---=
--
>  2 files changed, 58 insertions(+), 5 deletions(-)
>=20
> diff --git a/ethtool.8.in b/ethtool.8.in
> index ae56293..bdc77e0 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -297,6 +297,8 @@ ethtool \- query or control network driver and hardwa=
re settings
>  .BI weight\  W0
>  .IR W1
>  .RB ...\ ]
> +.RB [ hfunc
> +.IR FUNC ]
>  .HP
>  .B ethtool \-f|\-\-flash
>  .I devname file
> @@ -796,6 +798,11 @@ Sets RSS hash key of the specified network device. R=
SS hash key should be of dev
>  Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nib=
bles of a byte should be mentioned
>  even if a nibble is zero.
>  .TP
> +.BI hfunc
> +Sets RSS hash function of the specified network device. Requested hash f=
unction
> +should be supported by the kernel and the device.

I think the second sentence is unneeded - obviously requesting an
unsupported hash function will fail.

>  List of RSS hash functions

'A list of ...'

> +which kernel supports is shown as a part of the --show-rxfh comand outpu=
t.

'... which the device supports ...' (since this depends on the hardware
and driver as well as the kernel).

> +.TP
>  .BI equal\  N
>  Sets the receive flow hash indirection table to spread flows evenly
>  between the first \fIN\fR receive queues.
> diff --git a/ethtool.c b/ethtool.c
> index c2f4164..c584333 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3176,10 +3176,11 @@ static int do_grxfh(struct cmd_context *ctx)
>  {
>  	struct ethtool_rxfh rss_head =3D {0};
>  	struct ethtool_rxnfc ring_count;
> +	struct ethtool_gstrings *hfuncs;
>  	struct ethtool_rxfh *rss;
>  	u32 i, indir_bytes;
>  	char *hkey;
> -	int err;
> +	int err, cur_len, max_len =3D 0;
> =20
>  	ring_count.cmd =3D ETHTOOL_GRXRINGS;
>  	err =3D send_ioctl(ctx, &ring_count);
> @@ -3231,6 +3232,23 @@ static int do_grxfh(struct cmd_context *ctx)
>  			printf("%02x:", (u8) hkey[i]);
>  	}
> =20
> +	printf("RSS hash function:\n");
> +	if (!rss->hfunc) {
> +		printf("    Operation not supported\n");
> +		goto out;
> +	}
> +	hfuncs =3D get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
> +	for (i =3D 0; i < hfuncs->len; i++) {
> +		cur_len =3D strlen((const char *)hfuncs->data +
> +				 i * ETH_GSTRING_LEN);
> +		if (cur_len > max_len)
> +			max_len =3D cur_len;
> +	}
> +	for (i =3D 0; i < hfuncs->len; i++)
> +		printf("    %-*s: %s\n", max_len,
> +		       (const char *)hfuncs->data + i * ETH_GSTRING_LEN,
> +		       (rss->hfunc & (1 << i)) ? "on" : "off");

I'm puzzled by this.  Do you remember why the hash functions were given
flag numbers rather than serial numbers?  Would it ever make sense to
have multiple hash functions enabled?

If only one hash function can be enabled (which seems to be true at
least for current drivers) then this only needs to print the one hash
function that is enabled.  (But then, the user needs to be able to list
the available hash functions somehow.)

If multiple hash functions can be enabled, then we should support that
in do_srxfh(), don't we?

> +out:
>  	free(rss);
>  	return 0;
>  }
[...]
> @@ -3410,6 +3454,7 @@ static int do_srxfh(struct cmd_context *ctx)
>  	rss->cmd =3D ETHTOOL_SRSSH;
>  	rss->indir_size =3D rss_head.indir_size;
>  	rss->key_size =3D rss_head.key_size;
> +	rss->hfunc =3D req_hfunc ? req_hfunc : 0;

That's a complicated way to write '=3D req_hfunc;'.

Ben.

>  	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal=
,
>  			     rxfhindir_weight, num_weights)) {
> @@ -4119,7 +4164,8 @@ static const struct option {
>  	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
>  	  "Set Rx flow hash indirection and/or hash key",
>  	  "		[ equal N | weight W0 W1 ... ]\n"
> -	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
> +	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n"
> +	  "		[ hfunc FUNC ]\n"},
>  	{ "-f|--flash", 1, do_flash,
>  	  "Flash firmware image from the specified file to a region on the devi=
ce",
>  	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-63hWNEMeMh7/qa2QQOnR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCkOOe/yOyVhhEJAQpIUhAAgIZ78579kLM+UHy8OM2zflrraUeZzYXZ
UbVATxpyd8Eayowrp10YJsFlhYuuUFtUeQhDvirqn6bPP9OuI4JxnB4BlBH3UIYS
IJjW46EYxKD2ofp+Yh6TAEVwMDp24A6iCZjxER5a4An0p36r5y3wdrqj7iZZQNfM
8nS0ItOvUYAX+MUuJmxLWwLizWC9ysG3gyRgSJDD/Egxuk8JE2nIndzIsnh0HG5B
UHHaOOp8uETfsgedoCKgDhsJGAvMUa3U4WLHxYXn3voRmr/0Jme9z9LT8LOacvdi
zVRIG4yAEId2R1EpHk71Rvg/4BR8Hj9Hbwytz9Od2ZGNw09G3n0NrlbhpwqIUbau
Kwkf0deCmdb4CGGJT3zR9QEhVd1vsWDueBT+EjTMniRZHZp/U0e4Ykj86t21dlhG
7Q9Iro34NBsDMi3T/D6lFZLqs2bI19sNpxg5K3o8yTnkJ3akKUMq9mQxdauEtyi6
Z5joXTexa3yQOt7vFOl517GIOqA0iihCj7z1Lc9vQe8lhrWLDYPeHQ5DgD/3XwWT
BJzK0CH+IuntUx7L9sAQIgDV2Wlntpf426w5/hhlhh76JJ8G8MMu4nyMuS+AMvZB
E78jnNtWfDayd3Urs2Vyi3MC28td3AC0dPcqXFalyyJtYghqW2TGA0fIJY/dInvj
DCB+E/juqrA=
=47CT
-----END PGP SIGNATURE-----

--=-63hWNEMeMh7/qa2QQOnR--
