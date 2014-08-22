From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 2/3] ethtool: Add generic options for
 tunables
Date: Fri, 22 Aug 2014 16:26:05 -0700
Message-ID: <1408749965.4672.29.camel@deadeye.wl.decadent.org.uk>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
	 <1408008560-1067-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OVYlsHsU7dKNDhSDTvnQ"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, ssujith@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51278 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752308AbaHVX0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 19:26:22 -0400
In-Reply-To: <1408008560-1067-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OVYlsHsU7dKNDhSDTvnQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-08-14 at 14:59 +0530, Govindarajulu Varadarajan wrote:
> This patch adds new ethtool cmd, ETHTOOL_GTUNABLE & ETHTOOL_STUNABLE for =
getting
> tunable values from driver.
>=20
> Add ethtool_tunable_ops array to ethtool_ops. The array index will be
> the tunable tcmd as defined in enum tunable_cmd. ethtool_tunable_ops has =
two
> function pointers set & get. This is set by the driver for getting/settin=
g
> particular tunable.
>=20
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  include/linux/ethtool.h      |  6 ++++++
>  include/uapi/linux/ethtool.h | 17 +++++++++++++++
>  net/core/ethtool.c           | 51 ++++++++++++++++++++++++++++++++++++++=
++++++
>  3 files changed, 74 insertions(+)
>=20
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e658229..33bff94 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -77,6 +77,11 @@ static inline u32 ethtool_rxfh_indir_default(u32 index=
, u32 n_rx_rings)
>  	return index % n_rx_rings;
>  }
> =20
> +struct ethtool_tunable_ops {
> +	int (*set)(struct net_device *, struct ethtool_tunable *);

The second pointer type should be const-qualified.

> +	int (*get)(struct net_device *, struct ethtool_tunable *);
> +};
> +
>  /**
>   * struct ethtool_ops - optional netdev operations
>   * @get_settings: Get various device settings including Ethernet link
> @@ -257,6 +262,7 @@ struct ethtool_ops {
>  				     struct ethtool_eeprom *, u8 *);
>  	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
>  	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
> +	struct ethtool_tunable_ops tunable_ops[ETHTOOL_TUNABLE_MAX];

This is OK but if we add a lot of tunables then it bloats up each driver
with a (probably quite sparse) array of function pointers.

> =20
>=20
>  };
> diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
> index e3c7a71..99e43ca 100644
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -209,6 +209,21 @@ struct ethtool_value {
>  	__u32	data;
>  };
> =20
> +enum tunable_cmd {
> +	ETHTOOL_RX_COPYBREAK =3D 0,
> +	ETHTOOL_TUNABLE_MAX,
> +};
> +
> +struct ethtool_tunable {
> +	u32 cmd;
> +	u32 tcmd;
> +	u32 len;
> +	union {
> +		u32 rx_copybreak;
> +		u32 data[48];
> +	} data;
[...]

This is not at all generic.  If tunables don't all have the same type,
then the type - not just the length - should be explicit.

I also think that if the length of a value can vary then we should not
declare a data member at all.  So we would have something like:

struct ethtool_tunable {
	__u32	cmd;
	__u32	id;
	__u32	type_id;
	__u32	len;
	__u8	data[0];
};

Then the value buffer would be passed to the driver functions separately
(as for other variable-length command structures).

By the way, you must use double-underscore prefixes on fixed-width
integer type names in UAPI headers.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-OVYlsHsU7dKNDhSDTvnQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU/fRk+e/yOyVhhEJAQpG9g//WVJUq9LSZI8h9f/Xu3TiG6IZralfss2k
Lmue7SD1qbrkgM8SoEO5dACzuHxzhy9NZxXlPBdRHvMz3JbJpC1IpdfeKVkMjlgZ
4oIqOgpv/+pBERkd0+CkrijwOnK35awxdxiunt3K4utF2DxG9bAqsE4sHjNesT2r
JO/+PnbCIwDZsmX6H7lR0vXrP3epaG2meyX5m+lr197Oxahi7uvxFkx7oIq7hjY1
PsSy4XE7HWN4JCk45Cr7DTVDj+hjY6f4wWoKaPfIfAUHl4fl0UWsTX1FP4nm/xpR
3nLpehqrDzw1sU+SqVfY3IUmWwggJtJwR/Ot1sev54IvwNhPQ2flHIxC1TyFZxNn
6+uZD4jBApyLBJk8n7Ll824jquPIkAbFbBJbZ5b4jVZKYvkarfDTcUQ4iSQLIywh
e5w4eGJv5PFopHLzZdbrlSYyzH5+wg7rqJS+S2JROUMS5a20HRfXi+TOj/kVmYiR
WE9XQm0nokpZXhAoN8BEzFhAMXtP8amhoj+elvn2/pigsDIfeK+i2yi6STTcykjk
YE8Q2PeVG47bLxzoAzI6oh/GZGgRBoCH95zQJP1asKDXz06SrrSUKYlTIvdGBfWr
EC8zPXe3K1jbeq0OOxNLMBAynKwyBVLLmXqm0qaZ7oMFiHp3fddMMlLCoRSCne2L
mzLGF7vQyEQ=
=8oXL
-----END PGP SIGNATURE-----

--=-OVYlsHsU7dKNDhSDTvnQ--
