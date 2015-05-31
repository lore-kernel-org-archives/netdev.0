From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net/ibm/emac: fix size of emac dump memory areas
Date: Sun, 31 May 2015 21:46:43 +0100
Message-ID: <1433105203.6319.129.camel@decadent.org.uk>
References: <20150521191102.45bd4a18@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-iSYw3NOxjspWZ+ijU1lq"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Ivan Mikhaylov <ivan@ru.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58673 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758488AbbEaUq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 16:46:58 -0400
In-Reply-To: <20150521191102.45bd4a18@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iSYw3NOxjspWZ+ijU1lq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-05-21 at 19:11 +0400, Ivan Mikhaylov wrote:
> Fix in send of emac regs dump to ethtool which
> causing in wrong data interpretation on ethtool
> layer for MII and EMAC.
>=20
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>

Although this enables an improvement for EMAC4SYNC, this is a regression
for the EMAC and EMAC4 hardware versions.  The driver now reads
registers at undefined addresses and produces a register dump that is
incompatible with existing ethtool releases.

Although you've tried to change ethtool to match this, the kernel and
ethtool don't generally get upgraded in lockstep so the driver should
keep working with old versions of ethtool if possible (which it is).

The size of the MAC register dumps for EMAC and EMAC4 should continue to
be what ethtool assumes they are now - 112 and 116 bytes respectively.
Please fix this.

Ben.

> ---
>  drivers/net/ethernet/ibm/emac/core.c |   16 ++++++----------
>  drivers/net/ethernet/ibm/emac/core.h |    7 ++-----
>  2 files changed, 8 insertions(+), 15 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/=
ibm/emac/core.c
> index de79193..b9df0cb 100644
> --- a/drivers/net/ethernet/ibm/emac/core.c
> +++ b/drivers/net/ethernet/ibm/emac/core.c
> @@ -2084,12 +2084,8 @@ static void emac_ethtool_get_pauseparam(struct net=
_device *ndev,
> =20
>  static int emac_get_regs_len(struct emac_instance *dev)
>  {
> -	if (emac_has_feature(dev, EMAC_FTR_EMAC4))
> -		return sizeof(struct emac_ethtool_regs_subhdr) +
> -			EMAC4_ETHTOOL_REGS_SIZE(dev);
> -	else
>  		return sizeof(struct emac_ethtool_regs_subhdr) +
> -			EMAC_ETHTOOL_REGS_SIZE(dev);
> +			sizeof(struct emac_regs);
>  }
> =20
>  static int emac_ethtool_get_regs_len(struct net_device *ndev)
> @@ -2114,15 +2110,15 @@ static void *emac_dump_regs(struct emac_instance =
*dev, void *buf)
>  	struct emac_ethtool_regs_subhdr *hdr =3D buf;
> =20
>  	hdr->index =3D dev->cell_index;
> -	if (emac_has_feature(dev, EMAC_FTR_EMAC4)) {
> +	if (emac_has_feature(dev, EMAC_FTR_EMAC4SYNC)) {
> +		hdr->version =3D EMAC4SYNC_ETHTOOL_REGS_VER;
> +	} else if (emac_has_feature(dev, EMAC_FTR_EMAC4)) {
>  		hdr->version =3D EMAC4_ETHTOOL_REGS_VER;
> -		memcpy_fromio(hdr + 1, dev->emacp, EMAC4_ETHTOOL_REGS_SIZE(dev));
> -		return (void *)(hdr + 1) + EMAC4_ETHTOOL_REGS_SIZE(dev);
>  	} else {
>  		hdr->version =3D EMAC_ETHTOOL_REGS_VER;
> -		memcpy_fromio(hdr + 1, dev->emacp, EMAC_ETHTOOL_REGS_SIZE(dev));
> -		return (void *)(hdr + 1) + EMAC_ETHTOOL_REGS_SIZE(dev);
>  	}
> +	memcpy_fromio(hdr + 1, dev->emacp, sizeof(struct emac_regs));
> +	return (void *)(hdr + 1) + sizeof(struct emac_regs);
>  }
> =20
>  static void emac_ethtool_get_regs(struct net_device *ndev,
> diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/=
ibm/emac/core.h
> index 67f342a..28df374 100644
> --- a/drivers/net/ethernet/ibm/emac/core.h
> +++ b/drivers/net/ethernet/ibm/emac/core.h
> @@ -461,10 +461,7 @@ struct emac_ethtool_regs_subhdr {
>  };
> =20
>  #define EMAC_ETHTOOL_REGS_VER		0
> -#define EMAC_ETHTOOL_REGS_SIZE(dev) 	((dev)->rsrc_regs.end - \
> -					 (dev)->rsrc_regs.start + 1)
> -#define EMAC4_ETHTOOL_REGS_VER      	1
> -#define EMAC4_ETHTOOL_REGS_SIZE(dev)	((dev)->rsrc_regs.end -	\
> -					 (dev)->rsrc_regs.start + 1)
> +#define EMAC4_ETHTOOL_REGS_VER		1
> +#define EMAC4SYNC_ETHTOOL_REGS_VER	2
> =20
>  #endif /* __IBM_NEWEMAC_CORE_H */

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-iSYw3NOxjspWZ+ijU1lq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWtzOee/yOyVhhEJAQq1lRAAsuTO2GyfWGPyLl4W8iBrnQxlARpPI7U1
Zo/NWtdTU/n7AXNFXc/JRunf1woenWVvj7eSK96DnZyL2S9vWg8c8IN970fMM3Pg
2YkLncOmy//PIyIsQO+epr0yKsvPy0+SPrN/Rc6oTq83meW8BhNVMz9DeRl8CO8U
GXJRL+oQGVVDoikxB2AbIN9vcLmJOCmlJPKNjRHk2er3RmQstEfjBnz0k1r/TK7R
Q28tncXuF10tEsxGaDV8d4KAHhDLF3d2lD3OF3k/bnBIio4a4x8AoBar/mMEg9WB
OTd1VY7Tp+Ja7E5xFspOunH8ikmhEggkWP6ckMnnoLXVqLngGL5olWOX16t0wx5v
xE3qarVOFWSJ1Ae1V1WIkHHP0pH16UcYWcxhrnfr+k+jPoN+lQXoskTvfYoF514u
62JLQF/53jSw4gTRnDrUErnmMPtFT/O9sDfgfSU1KfueW5y8AKgCJkeC7VEgtGyj
QMol77vkXj4VXPKdmOBsAcNQWqmTK1cSEFeFIDF3RjhuVVxInmMzGkZM3k4qqrw6
Anoiw9I1l1Lb1ZslJR1AnBtD3bHY3IXVKeWrrYY+YIzGiG0VuvVmQST1DEed/DaG
Ynmwnd8aa96hBdxg6t73UQoePhoYfymlKC+TARfj5oxFKrfrSyg2+YCZdOH4aN01
zr2WgNk/YUI=
=OSob
-----END PGP SIGNATURE-----

--=-iSYw3NOxjspWZ+ijU1lq--
