From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3 3/6] net/ethtool: support set coalesce per queue
Date: Sun, 17 Jan 2016 02:13:13 +0000
Message-ID: <1452996793.2519.39.camel@decadent.org.uk>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
	 <1452780487-10581-3-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+Qddr6r7XThs4g424WB7"
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
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54006 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbcAQCNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 21:13:31 -0500
In-Reply-To: <1452780487-10581-3-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+Qddr6r7XThs4g424WB7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-01-14 at 09:08 -0500, kan.liang@intel.com wrote:
[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1773,6 +1773,63 @@ static int ethtool_get_per_queue_coalesce(struct n=
et_device *dev,
> =C2=A0	return 0;
> =C2=A0}
> =C2=A0
> +static int ethtool_set_per_queue_coalesce(struct net_device *dev,
> +					=C2=A0=C2=A0void __user *useraddr,
> +					=C2=A0=C2=A0struct ethtool_per_queue_op *per_queue_opt)
> +{
> +	int bit, i, ret =3D 0;
> +	int queue_num =3D bitmap_weight(per_queue_opt->queue_mask, MAX_NUM_QUEU=
E);
> +	struct ethtool_coalesce *backup =3D NULL, *tmp =3D NULL;
> +	bool rollback =3D true;
> +
> +	if (!dev->ethtool_ops->set_per_queue_coalesce)
> +		return -EOPNOTSUPP;
> +
> +	if (!dev->ethtool_ops->get_per_queue_coalesce)
> +		rollback =3D false;

I think that get_per_queue_coalesce should be a required operation.
Why would a driver not implement both?

Then there's no need to make the rollback code conditional.

> +	useraddr +=3D sizeof(*per_queue_opt);
> +
> +	if (rollback)
> +		tmp =3D backup =3D kmalloc(queue_num * sizeof(*backup), GFP_KERNEL);

Use kmalloc_array() as it checks for overflow (shouldn't be possible
here, but it's best to check).

> +	for_each_set_bit(bit, per_queue_opt->queue_mask, MAX_NUM_QUEUE) {
> +		struct ethtool_coalesce coalesce;
> +
> +		if (rollback) {
> +			if (dev->ethtool_ops->get_per_queue_coalesce(dev, bit, tmp)) {
> +				ret =3D -EFAULT;

This should propagate the error code from get_per_queue_coalesce rather
than substituting EFAULT.

> +				goto roll_back;
> +			}
> +			tmp +=3D sizeof(struct ethtool_coalesce);
> +		}
> +
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
> +	if (rollback) {
> +		if (ret !=3D 0) {
> +			tmp =3D backup;
> +			for_each_set_bit(i, per_queue_opt->queue_mask, bit - 1) {

The upper bound is excluded so it should be bit, not bit - 1.

Ben.

> +				dev->ethtool_ops->set_per_queue_coalesce(dev, i, tmp);
> +				tmp +=3D sizeof(struct ethtool_coalesce);
> +			}
> +		}
> +		kfree(backup);
> +	}
> +	return ret;
> +}
[...]

--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers
--=-+Qddr6r7XThs4g424WB7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVpr4uee/yOyVhhEJAQrkJg//Z8bKYEiuEQCtuefb4HKc9XKF+NGCQufp
FyHoliwYmO69ScxyuOSklP6iHY/NRZdJAGaZXdCmpWB/VAOV8E9uh74H1+s/Opu+
PWvyLctjuSGtW1xe5jyFpBGRbemCGVboHCxCVEMPH78mR0J4yExekYmkAhK9E15+
jL54BEcucnkv1lD3TOJ0v0COuow2xaZgv1VWzx06GUJem+WqI12nvh5vJLG49He9
wxO9UpwLXpEJrTKw3KnWBX3OyDwrIlCUQOuJv3JG8o1L1IF5pTCUygOZEX10RDWq
h6G2v8sRxFeDaZW/dXc3dDGOk4renBZ5bO6XLP8sfDpoebsahfPIOTYw9GcH+CeU
LW0CdvHVjRY9RDTeuWXBxOEQUdnjwIRF4h6IiHvXLv+snOUI0pt8vUu7uJuD9PNU
Oo4DwpC+4hEWGWKVKFlR5t0UV8mdpqM5Uez/1Asn4ELGJBlhZAvZSntoIZ0ul9sC
wsusb2ke/oVyDqejF7ww4na8qpNn3MK9dHb+b9PtzfpaD9bEIjLzl0NJ4di/UX2/
F7t0kr82ObC/O4r/m1oNhvfL24Ywe/wp38TOU3ensA3e+QaD5KolQWosX/h1hMzk
OA+li2HTBe3mEHM+NqCHSyJS4sFlS+1EIw5MFE4bpknmNt6xqM07S1t1d17DEnV8
1IBAXArxzH0=
=8kTc
-----END PGP SIGNATURE-----

--=-+Qddr6r7XThs4g424WB7--
