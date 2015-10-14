From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: Use kcalloc instead of kmalloc for
 ethtool_get_strings
Date: Wed, 14 Oct 2015 21:36:19 +0100
Message-ID: <1444854979.31451.39.camel@decadent.org.uk>
References: <1444805996-3877-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444805996-3877-16-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444810180.2718.16.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aehxVmzC4QJhmdDa8v9K"
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36837 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932172AbbJNUgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 16:36:36 -0400
In-Reply-To: <1444810180.2718.16.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aehxVmzC4QJhmdDa8v9K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-10-14 at 01:09 -0700, Joe Perches wrote:
> It seems that kernel memory can leak into userspace by a
> kmalloc, ethtool_get_strings, then copy_to_user sequence.
>=20
> Avoid this by using kcalloc to zero fill the copied buffer.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>=20
> stable too...
>=20
> On Tue, 2015-10-13 at 23:59 -0700, Jeff Kirsher wrote:
> > From: Jacob Keller <jacob.e.keller@intel.com>
> []
> > diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers=
/net/ethernet/intel/fm10k/fm10k_ethtool.c
> []
> > @@ -206,13 +206,13 @@ static void fm10k_get_stat_strings(struct net_dev=
ice *dev, u8 *data)
> > =C2=A0> > 	> > }
> > =C2=A0
> > =C2=A0> > 	> > for (i =3D 0; i < interface->hw.mac.max_queues; i++) {
> > -> > 	> > 	> > sprintf(p, "tx_queue_%u_packets", i);
> > +> > 	> > 	> > snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_packets", i);
>=20
> It seems these need a memset after the snprintf to zero fill
> bytes after the string terminating \0 to avoid leaking
> contents of any unset bytes.

Right. =C2=A0It used to be that all drivers were memcpy()ing from a static
array which had all the necessary zero bytes, but now there are a bunch
of them using s{,n}printf() or otherwise dynamically generating names
for statistics or tests. =C2=A0And I don't think there's any snprintf()-
alike function that will fix that.

At least these drivers aren't zero-padding all strings: bnx2x, bnad,
i40e, i40evf, igb, ixgbe, liquidio, mlx4_en, mlx5e, nicvf, qlcnic, sfc,
vxge.

Acked-by: Ben Hutchings <ben@decadent.org.uk>

Ben.

> It'd probably be better to allocate a zeroed buffer instead.
>=20
> > =C2=A0		p +=3D ETH_GSTRING_LEN;
> > -		sprintf(p, "tx_queue_%u_bytes", i);
> > +> > 	> > 	> > snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_bytes", i);
>=20
> so...
>=20
> =C2=A0net/core/ethtool.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index b495ab1..29edf74 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1284,7 +1284,7 @@ static int ethtool_get_strings(struct net_device *d=
ev, void __user *useraddr)
> =C2=A0
> =C2=A0	gstrings.len =3D ret;
> =C2=A0
> -	data =3D kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
> +	data =3D kcalloc(gstrings.len, ETH_GSTRING_LEN, GFP_USER);
> =C2=A0	if (!data)
> =C2=A0		return -ENOMEM;
> =C2=A0
>=20
>=20
--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-aehxVmzC4QJhmdDa8v9K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVh68w+e/yOyVhhEJAQrr+g//Y4qMXMy5MzYr+R6n1VGFIfR6pUjWHAlS
O7o+W7BxWBSPY/dpedsG0B4WCTKUS3LIpKGfI8QwE2i6HI908NfgTUaAxcfm4nMg
hvcdRlrf07j8vyIbeYkE/xSBgkfnss6jRwcnD0clwSAb2z+s1ZW5SIdJyRPQ8YC8
DkR/Jxb3MkVWtXdpFr7exgaKUOpRvCdOJGqX3631SycJgB/g1qJCtbDCdxAzdEhz
KsRSKg8g4JbYM5awnIChCdvjwvPIoUy2uMcxCvPBJEYz2LxQHF0xQqHlTjq/XF81
pQIknwqomSLOnpdWfgoibjFBDISMitXwRVG+r/j3jgvixetxBuPsnF9r3DbewmJO
uPcBgswjtqE1C3F0qgiXzjnZipfXfYTqZ9QH2aieIfdNdGIDc/ox5HSr4aKKxsNh
donIh5CTKJtvKkDg9pZrgMBKhIcJkyigvOAAlFGLKK7m9Aszchm+fguiGznF3y+c
nJ0Xs2AwOG5CA2fpdPVXfLfaO2gb9ucUp4VspVzD55gXH8HqlApdWuJDQqTdZePp
/phvpwewIR+950LayOqDJpmGwnnaLKggNX4YXnJRqe1RwT25y6/uO8Y/OPiJ454j
FLrLKEsmzJh1gAyzftASF9kzNWM/EVJYIR5GQezDeBOR3ybH2fVB6TIV6zsx4Vj8
pQeyj2j5ddA=
=7JuK
-----END PGP SIGNATURE-----

--=-aehxVmzC4QJhmdDa8v9K--
