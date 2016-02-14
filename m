From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V4 5/8] net/ethtool: support set coalesce per queue
Date: Sun, 14 Feb 2016 18:55:05 +0000
Message-ID: <1455476105.2801.148.camel@decadent.org.uk>
References: <1454917540-10648-1-git-send-email-kan.liang@intel.com>
	 <1454917540-10648-6-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Z1VJcKuJq9hJ8Lz1DyBJ"
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: Kan Liang <kan.liang@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58107 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751074AbcBNSzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 13:55:23 -0500
In-Reply-To: <1454917540-10648-6-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Z1VJcKuJq9hJ8Lz1DyBJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-08 at 02:45 -0500, Kan Liang wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> This patch implements sub command ETHTOOL_SCOALESCE for ioctl
> ETHTOOL_PERQUEUE. It introduces an interface set_per_queue_coalesce to
> set coalesce of each masked queue to device driver. The wanted coalesce
> information are stored in "data" for each masked queue, which can copy
> from userspace.
> If it fails to set coalesce to device driver, the value which already
> set to specific queue will be tried to rollback.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0include/linux/ethtool.h |=C2=A0=C2=A08 +++++++
> =C2=A0net/core/ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 60 ++++++++=
+++++++++++++++++++++++++++++++++++++++++
> =C2=A02 files changed, 68 insertions(+)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index a83566f..0c699b8 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -208,6 +208,12 @@ static inline u32 ethtool_rxfh_indir_default(u32 ind=
ex, u32 n_rx_rings)
> =C2=A0 *	zero should return. But related unavailable fields should be set=
 to ~0,
> =C2=A0 *	which indicates RX or TX is not in the range.
> =C2=A0 *	Returns a negative error code or zero.
> + * @set_per_queue_coalesce: Set interrupt coalescing parameters per queu=
e.
> + *	It needs to do range check for the input queue number. Only if
> + *	neither RX nor TX queue number is in the range, a negative error code
> + *	returns. For the case that only RX or only TX is not in the range,
> + *	zero should return. The related unavailable fields should be avoid.
> + *	Returns a negative error code or zero.

This is poorly worded.=C2=A0=C2=A0I suggest:

"It must check that the given queue number is valid. If neither a RX
nor a TX queue has this number, return -EINVAL. If only a RX queue or a
TX queue has this number, ignore the inapplicable fields."

> =C2=A0 *
> =C2=A0 * All operations are optional (i.e. the function pointer may be se=
t
> =C2=A0 * to %NULL) and callers must take this into account.=C2=A0=C2=A0Ca=
llers must
> @@ -288,6 +294,8 @@ struct ethtool_ops {
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const struct ethtool_t=
unable *, const void *);
> =C2=A0	int	(*get_per_queue_coalesce)(struct net_device *, int,
> =C2=A0					=C2=A0=C2=A0struct ethtool_coalesce *);
> +	int	(*set_per_queue_coalesce)(struct net_device *, int,
> +					=C2=A0=C2=A0struct ethtool_coalesce *);

Again, please use unsigned int for the queue number.

[...]
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index ccefbf5..933de09 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1854,6 +1854,64 @@ static int ethtool_get_per_queue_coalesce(struct n=
et_device *dev,
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static int ethtool_set_per_queue_coalesce(struct net_device *dev,
> +					=C2=A0=C2=A0void __user *useraddr,
> +					=C2=A0=C2=A0struct ethtool_per_queue_op *per_queue_opt)
> +{
> +	int bit, i, ret =3D 0;
> +	int queue_num;

It would be clearer to call this n_queues ('number of queues') rather
than queue_num.

> +	struct ethtool_coalesce *backup =3D NULL, *tmp =3D NULL;
> +	DECLARE_BITMAP(queue_mask, MAX_NUM_QUEUE);
> +
> +	if ((!dev->ethtool_ops->set_per_queue_coalesce) ||
> +	=C2=A0=C2=A0=C2=A0=C2=A0(!dev->ethtool_ops->get_per_queue_coalesce))
> +		return -EOPNOTSUPP;
> +
> +	useraddr +=3D sizeof(*per_queue_opt);
> +
> +	bitmap_from_u32array(queue_mask,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0MAX_NUM_QUEUE,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0per_queue_opt->queue_mask,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0DIV_ROUND_UP(MAX_NUM_QUEUE, 32));
> +	queue_num =3D bitmap_weight(queue_mask, MAX_NUM_QUEUE);
> +	tmp =3D backup =3D kmalloc_array(queue_num, sizeof(*backup), GFP_KERNEL=
);
> +	if (!backup)
> +		return -ENOMEM;
> +
> +	for_each_set_bit(bit, queue_mask, MAX_NUM_QUEUE) {
> +		struct ethtool_coalesce coalesce;
> +
> +		ret =3D dev->ethtool_ops->get_per_queue_coalesce(dev, bit, tmp);
> +		if (ret !=3D 0)
> +			goto roll_back;
> +
> +		tmp +=3D sizeof(struct ethtool_coalesce);

No! =C2=A0tmp is a pointer to struct ethtool_coalesce, so it must be
incremented by 1.

> +		if (copy_from_user(&coalesce, useraddr, sizeof(coalesce))) {
> +			ret =3D -EFAULT;
> +			goto roll_back;
> +		}
> +
> +		ret =3D dev->ethtool_ops->set_per_queue_coalesce(dev, bit, &coalesce);
> +		if (ret !=3D 0)
> +			goto roll_back;
> +
> +		useraddr +=3D sizeof(coalesce);
> +	}
> +
> +roll_back:
> +	if (ret !=3D 0) {
> +		tmp =3D backup;
> +		for_each_set_bit(i, queue_mask, bit) {
> +			dev->ethtool_ops->set_per_queue_coalesce(dev, i, tmp);
> +			tmp +=3D sizeof(struct ethtool_coalesce);
[...]

Again, increment by 1.

Ben.

--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-Z1VJcKuJq9hJ8Lz1DyBJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsDNiee/yOyVhhEJAQpy3g//ZPIe3Q5Juk5XM5XPgaugf7nUOfCKaTiw
MkOae4Zm1t4kYKui0TV2mVlxec10196hOOOQ/M8Dr40NzGNByVi70ROWJOICqRgF
tjlsS79aFZv5FBR+Blk7ahAELvbilc0IIT9TCG4hCP849CACsbTiCDhQhncIaQfC
rQlNSYnTNLQRTY5r4lBJ/EhWeCCcMwADSWuLRg9uNeZsALjzFtOixbAGLqqH/4TX
HYPlNYTaNBfT6aIWnSiIdm9M2gj8SmBcxvV1YXcyUMQGaohaBP337JeuPoY4UfDX
byilLUZZcM6tmy25X9QNPr6Fy7EAr0fGbKAQtx1fHJdsGLoYXCnGcC6AxpAEbykO
EsViW2pnvc98qTkzTz+PCqqysKQYSWuVd07V0KHQkoAZvoBd2nGs6yZIYLADc5VL
VW/TO6rEd80EFl4QJWNeh1uGVu6moa0VocbuOtg34QtB8cr1I0Agr1syeWhF+asR
ZJ7RifAjTODm4qfi/UPtY61fQgI0+OsFEmSkbVikXea9pMh5akp59/sKTBXruFZu
z3envCeHXmOol/BPlyTGZHC1Saj62I4qPsW5S0P312VUIz8C9xjANouv09ZgMNoz
CO4JUoH49/CDSykQDxmqm/3X/QDta+M/EMMUrGlSUmIYDcIrYofZ0r1zEYKIAQw7
th0BnltPwWY=
=LxrN
-----END PGP SIGNATURE-----

--=-Z1VJcKuJq9hJ8Lz1DyBJ--
