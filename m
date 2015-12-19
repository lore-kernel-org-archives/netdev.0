From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC 2/5] net/ethtool: support get coalesce per queue
Date: Sat, 19 Dec 2015 03:35:43 +0000
Message-ID: <1450496143.30687.10.camel@decadent.org.uk>
References: <1450335081-3012-1-git-send-email-kan.liang@intel.com>
	 <1450335081-3012-2-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u79x8zR+iKhyx4WCIrN1"
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
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53523 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbbLSDgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 22:36:01 -0500
In-Reply-To: <1450335081-3012-2-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-u79x8zR+iKhyx4WCIrN1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-12-17 at 06:51 +0000, kan.liang@intel.com wrote:
> From: Kan Liang <kan.liang@intel.com>
>=20
> Device driver has to provide an interface to get per queue coalesce.
> The interrupt coalescing parameters of each masked queue will be
> copied back to user space one by one.
>=20
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
> =C2=A0include/linux/ethtool.h |=C2=A0=C2=A05 ++++-
> =C2=A0net/core/ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0| 33 ++++++++=
++++++++++++++++++++++++-
> =C2=A02 files changed, 36 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 653dc9c..107f75f 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -201,6 +201,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 inde=
x, u32 n_rx_rings)
> =C2=A0 * @get_module_eeprom: Get the eeprom information from the plug-in =
module
> =C2=A0 * @get_eee: Get Energy-Efficient (EEE) supported and status.
> =C2=A0 * @set_eee: Set EEE status (enable/disable) as well as LPI timers.
> + * @get_per_queue_coalesce: Get interrupt coalescing parameters per queu=
e.
> + *=C2=A0	Returns a negative error code or zero.

Is the ethtool core or the driver responsible for range-checking the
queue number?

What is reported if the queue number is in range for RX queues but not
for TX queues (or vice versa)?

> =C2=A0 *
> =C2=A0 * All operations are optional (i.e. the function pointer may be se=
t
> =C2=A0 * to %NULL) and callers must take this into account.=C2=A0=C2=A0Ca=
llers must
> @@ -279,7 +281,8 @@ struct ethtool_ops {
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const struct ethtool_t=
unable *, void *);
> =C2=A0	int	(*set_tunable)(struct net_device *,
> =C2=A0			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const struct ethtool_t=
unable *, const void *);
> -
> +	int	(*get_per_queue_coalesce)(struct net_device *, int,
> +					=C2=A0=C2=A0struct ethtool_coalesce *);
> =C2=A0
> =C2=A0};
> =C2=A0#endif /* _LINUX_ETHTOOL_H */
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index 125fb32..22ff69a 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1748,6 +1748,36 @@ out:
> =C2=A0	return ret;
> =C2=A0}
> =C2=A0
> +static int ethtool_get_per_queue_coalesce(struct net_device *dev,
> +					=C2=A0=C2=A0void __user *useraddr,
> +					=C2=A0=C2=A0struct ethtool_per_queue_op *per_queue_opt)
> +{
> +	u64 queue_mask;
> +	int bit, i, ret;
> +
> +	if (!dev->ethtool_ops->get_per_queue_coalesce)
> +		return -EOPNOTSUPP;
> +
> +	useraddr +=3D sizeof(*per_queue_opt);
> +	for (i =3D 0; i < MAX_QUEUE_MASK; i++) {
> +		queue_mask =3D per_queue_opt->queue_mask[i];
> +		if (queue_mask > 0) {
> +			for_each_set_bit(bit, (unsigned long *)&queue_mask, 64) {
[...]

This assumes a little-endian system.

You should probably build on top of David Decotigny's recent patch
series that adds conversion of u32-based bitmaps to kernel bitmaps.

Ben.

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.
--=-u79x8zR+iKhyx4WCIrN1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVnTQj+e/yOyVhhEJAQpyLw//dey6dGJmE2JqewxmXHoX4wPSKd2u6VTh
GkhdVbUEpvyzc1PUiI6POjYxZEQKzK1V3z+aAb4pWlVDC9DszrFvtyOIMk8BfLeC
NyD8DTTRV5Qrhmf00U/iQWPpBdGBQKCdlBZlHKL9j0bpuDfDG12grhb8JZExa/Qr
nejbHGKxvFNp36MhxsP8iZLeMcvhdh3ITI0mz/Hp34d08EYZEMWJ+1CN2sRi5mZ/
GFqL1+pMKPGUPMQH8ooZezU9ty2LR3TvUXK8fxHge2KTyIci8uYMxKsXIV6QCg24
1Rq81n2XOKwAhuQXtZjoZy1lgE0gNkjP59Yr1ya14PNuClMPmPIUDTwNtVJP9Oxz
XHazEhB5NGnJUGp+/3XJK3jNzJSqbZFnHQak3EtL4lK4rl5ZhITv9ZSdyfUrkalr
0GVsTOnQ4hmUyocV2CvdbKUJV4TLl2ccBxOeURwI1tWOiM2RLBs1P4JcWK4GlivW
G3VsOLn+5OFztyBqTtdSMQ0zaoOtRfNJrG83Mx2f5xY9qBxgxdnjJd9VH4H5feS0
yLbyC2P6bvNE9u11OTh/aFm5fryC96zXInObvlVoNZ7LGx1Xqh7RbwzqZbx7U2Vx
cJjJTdCrD4u2cVAoEBDtBGzRfEWIawoiFPPdzVayU/MKRArekcv/KNLfUnsiYarS
cz5sgrOETjE=
=OrLL
-----END PGP SIGNATURE-----

--=-u79x8zR+iKhyx4WCIrN1--
