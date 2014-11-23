From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 13/17] i40evf: refactor ethtool RSS handling
Date: Sun, 23 Nov 2014 03:44:35 +0000
Message-ID: <1416714275.7215.38.camel@decadent.org.uk>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416635708-4765-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Ugi3Pw0Q8XZlCJAFQvOI"
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:45532 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752349AbaKWDoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 22:44:54 -0500
In-Reply-To: <1416635708-4765-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Ugi3Pw0Q8XZlCJAFQvOI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-21 at 21:55 -0800, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
>=20
> Add support for setting the RSS key as it is now implemented.
>=20
> Change-ID: I9290ae3ea99d0e46053540650f95e24a24e453f1
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 66 ++++++++++++++++=
------
>  1 file changed, 50 insertions(+), 16 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers=
/net/ethernet/intel/i40evf/i40evf_ethtool.c
> index 69a269b..ed0e4dc 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
> @@ -608,6 +608,19 @@ static void i40evf_get_channels(struct net_device *n=
etdev,
>  	ch->combined_count =3D adapter->num_active_queues;
>  }
> =20
> +#define I40EVF_HLUT_ARRAY_SIZE ((I40E_VFQF_HLUT_MAX_INDEX + 1) * 4)
> +#define I40EVF_HKEY_ARRAY_SIZE ((I40E_VFQF_HKEY_MAX_INDEX * 1) * 4)

The '* 1' should be '+ 1' as on the previous line?

[...]
> @@ -631,19 +644,28 @@ static int i40evf_get_rxfh(struct net_device *netde=
v, u32 *indir, u8 *key)
>  {
>  	struct i40evf_adapter *adapter =3D netdev_priv(netdev);
>  	struct i40e_hw *hw =3D &adapter->hw;
> -	u32 hlut_val;
> +	u32 reg_val;
>  	int i, j;
>  	for (i =3D 0, j =3D 0; i <=3D I40E_VFQF_HLUT_MAX_INDEX; i++) {
> -		hlut_val =3D rd32(hw, I40E_VFQF_HLUT(i));
> -		indir[j++] =3D hlut_val & 0xff;
> -		indir[j++] =3D (hlut_val >> 8) & 0xff;
> -		indir[j++] =3D (hlut_val >> 16) & 0xff;
> -		indir[j++] =3D (hlut_val >> 24) & 0xff;
> +		reg_val =3D rd32(hw, I40E_VFQF_HLUT(i));
> +		indir[j++] =3D reg_val & 0xff;
> +		indir[j++] =3D (reg_val >> 8) & 0xff;
> +		indir[j++] =3D (reg_val >> 16) & 0xff;
> +		indir[j++] =3D (reg_val >> 24) & 0xff;
> +	}

You need an 'if (indir)' around that block now.

> +	if (key) {
> +		for (i =3D 0, j =3D 0; i <=3D I40E_VFQF_HKEY_MAX_INDEX; i++) {
> +			reg_val =3D rd32(hw, I40E_VFQF_HKEY(i));
> +			key[j++] =3D (u8)(reg_val & 0xff);
> +			key[j++] =3D (u8)((reg_val >> 8) & 0xff);
> +			key[j++] =3D (u8)((reg_val >> 16) & 0xff);
> +			key[j++] =3D (u8)((reg_val >> 24) & 0xff);
> +		}
>  	}
>  	return 0;
>  }
> -

You should keep the blank line between functions.

[...]
> @@ -687,10 +719,12 @@ static const struct ethtool_ops i40evf_ethtool_ops =
=3D {
>  	.set_coalesce		=3D i40evf_set_coalesce,
>  	.get_rxnfc		=3D i40evf_get_rxnfc,
>  	.set_rxnfc		=3D i40evf_set_rxnfc,
> +	.get_rxfh_key_size	=3D i40evf_get_rxfh_key_size,
>  	.get_rxfh_indir_size	=3D i40evf_get_rxfh_indir_size,
>  	.get_rxfh		=3D i40evf_get_rxfh,
>  	.set_rxfh		=3D i40evf_set_rxfh,
>  	.get_channels		=3D i40evf_get_channels,
> +

But you don't need a blank line here.

Ben.

>  };
> =20
>  /**

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-Ugi3Pw0Q8XZlCJAFQvOI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHFYKee/yOyVhhEJAQoMBxAAltituYKr23Gtge4MECVVxabkv4EOnKxw
s+48LnYcMyrqZo3okggX0KrrqH2I6IOCEAfxl0LghurO4QsyXNq+IbNn0TOW+oTq
b7qxhJ8cIl4hYAnxkCFtAWxiGKNSCF6zDLaFweTM4v6hOy+YRwBMofAFPKcdJ/tX
SjtMcStVHwkEga0itR+jUMA20nFPzrj4P8uilo25BlkOWAaiwEKOyX0I19iREAWQ
3ZaiRf8ZAXbKmAorP0b3ekh/1Zb399utnT3H7qhQaoM8iii012Qy74CnVWUH09v8
JWC0sGh6AU1q6OB4TqYPtcC0a8REC7wyWgGluKiNfsdocp31cmHtgBgAfXJq7TWT
SWfdu8d+yqXTcD6oMHsA6HywQtTKkOYzh6ySD8cJGVBGMopADrRoVB184y7QJk3J
xFy1JEwkd+IjvH15KgCCsVLYu5wLR3NLj413dyvuaGG1oLLFqv6afQhrB5DGaGeW
LYR286ku4fAhU2tSfd2AS80XrvPS/RdHZGNpgx4sgX4jjnUxbviH1iZpbZmwUoys
mHARNz69c/DAfEAfasDpSUdznNTIvsK2iqUmcaosklv/yF9CbOA7CSVtgBkHHWd7
xMDuPqDa4Vk226/8Dyd7ZaO1Wa+HM+QioFyVPvrJQQDPz3R5v5+6ySl9F55pjr8g
+tj7xfzarGA=
=04xr
-----END PGP SIGNATURE-----

--=-Ugi3Pw0Q8XZlCJAFQvOI--
