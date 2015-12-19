From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 1/5] net/ethtool: introduce a new ioctl for per queue
 setting
Date: Sat, 19 Dec 2015 03:27:12 +0000
Message-ID: <1450495632.30687.3.camel@decadent.org.uk>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-v1tUuh5xKq/Oi0CYst2P"
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53486 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752753AbbLSD13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:27:29 -0500
In-Reply-To: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v1tUuh5xKq/Oi0CYst2P
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-17 at 06:51 +0000, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> Introduce a new ioctl ETHTOOL_PERQUEUE for per queue parameters setting.
> The following patches will enable some SUB_COMMANDs for per queue
> setting.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0include/uapi/linux/ethtool.h | 18 ++++++++++++++++++
> =C2=A0net/core/ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0| 17 +++++++++++++++++
> =C2=A02 files changed, 35 insertions(+)
>=20
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index cd16291..05bc92a 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1144,6 +1144,22 @@ enum ethtool_sfeatures_retval_bits {
> =C2=A0#define ETHTOOL_F_WISH=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0(1 << ETHTOOL_F_WISH__BIT)
> =C2=A0#define ETHTOOL_F_COMPAT=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0(1 << ETHTOOL_F_COMPAT__BIT)
> =C2=A0
> +#define MAX_QUEUE		4096
> +#define MAX_QUEUE_MASK		(MAX_QUEUE / 64)
> +
> +/**
> + * struct ethtool_per_queue_op - apply sub command to the queues in mask=
.
> + * @cmd: ETHTOOL_PERQUEUE
> + * @queue_mask: Mask the queues which sub command apply to
> + * @sub_command: the sub command
> + * @data: parameters of the command
> + */
> +struct ethtool_per_queue_op {
> +	__u32	cmd;
> +	__u64	queue_mask[MAX_QUEUE_MASK];
> +	__u32	sub_command;

This leaves a hole in the structure on i386, which would then require
conversion in the compat ioctl implementation. =C2=A0I suggest you move the
sub_command next to cmd.

> +	char	data[];
> +};
> =C2=A0
> =C2=A0/* CMDs currently supported */
> =C2=A0#define ETHTOOL_GSET		0x00000001 /* Get settings. */
> @@ -1226,6 +1242,8 @@ enum ethtool_sfeatures_retval_bits {
> =C2=A0#define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
> =C2=A0#define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
> =C2=A0
> +#define ETHTOOL_PERQUEUE	0x0000004a /* Set per queue options */

But it will actually be used for both set and get, right?

> +
> =C2=A0/* compatibility with older code */
> =C2=A0#define SPARC_ETH_GSET		ETHTOOL_GSET
> =C2=A0#define SPARC_ETH_SSET		ETHTOOL_SSET
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 29edf74..125fb32 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1748,6 +1748,20 @@ out:
> =C2=A0	return ret;
> =C2=A0}
> =C2=A0
> +static int ethtool_set_per_queue(struct net_device *dev, void __user *us=
eraddr)
> +{
> +	struct ethtool_per_queue_op per_queue_opt;
> +
> +	if (copy_from_user(&per_queue_opt, useraddr, sizeof(per_queue_opt)))
> +		return -EFAULT;
> +
> +	switch (per_queue_opt.sub_command) {
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	};
> +}
> +
> =C2=A0/* The main entry point in this file.=C2=A0=C2=A0Called from net/co=
re/dev_ioctl.c */
> =C2=A0
> =C2=A0int dev_ethtool(struct net *net, struct ifreq *ifr)
> @@ -1991,6 +2005,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
> =C2=A0	case ETHTOOL_STUNABLE:
> =C2=A0		rc =3D ethtool_set_tunable(dev, useraddr);
> =C2=A0		break;
> +	case ETHTOOL_PERQUEUE:
> +		rc =3D ethtool_set_per_queue(dev, useraddr);
> +		break;
> =C2=A0	default:
> =C2=A0		rc =3D -EOPNOTSUPP;
> =C2=A0	}

I think the first switch statement to determine whether the command
requires CAP_NET_ADMIN should also handle ETHTOOL_PERQUEUE, checking
the sub-command number.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.
--=-v1tUuh5xKq/Oi0CYst2P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVnTOkOe/yOyVhhEJAQrBZQ//ROYNFLQPfQuV/wWmMEo2aEPZioVDXL/3
7olhxTKBjQbCo3pqa9DL+nuAVykY3MZU20Dmit8HZ4BYN0DDyQtVkK7g5Dur9OWq
djdBCZATLTtrZ+v+OmmZco33vFTTNNEze/xhN5UOX/RaF2TUpwT1PV0eQ60uUxcJ
P7LB8zra2wQVo8+1NJmlePNzt3yOGnerzlVkl4Ywbad8qBhsULIZ6PGgJtQHsBMS
AFLcuGpdYJ+7fwE/FrU2EKniR2/g1ut+hZjydQ5Y0g/6eqP4N5vKFCdUg8BzIZgl
Sxv9ZzGMyeAfRix5w0e1BV7TJq8OAnIcs67Eppp8eA5MyrqKczGI+x60MQxbDrfm
YNFnst2C2sqpca6SFQbvUZFcSfzDebwwUBLSLxNujtcyGnPJXcbZvwb2v96OjpHb
X3/2nWMTY0SJ3pToCz0iddRy1TZmGHmZK9IoDK6WVQ260mfLMjP73tyUTAvuJQU2
3ckOAgJiUdcqIP5xrsyufsgFNF+KTbDqWLvwk2jf6Scqq/t2hB/sGIFVdH19SYHL
UwVNBKvEyrl3kcAlaRZ42yPihgQxe1cxcIShEOGGsTGCsuQ0Tdi2yyCFyiGvrNgc
NGgEMEByaKYwsyM4VRQjjEnCFEt7n9HKLbQp1CWBpPhUNCIRZ02A0IavGo4VU5Oy
xgq2jMBKeoA=
=sD/M
-----END PGP SIGNATURE-----

--=-v1tUuh5xKq/Oi0CYst2P--
