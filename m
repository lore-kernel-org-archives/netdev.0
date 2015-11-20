From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH 3/3] batman-adv: Less function calls in
 batadv_is_ap_isolated() after error detection
Date: Fri, 20 Nov 2015 16:47:25 +0800
Message-ID: <564EDE1D.7070809__34820.2149071314$1448010656$gmane$org@meshcoding.com>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <56391CF7.9080400@users.sourceforge.net>
 <56391F73.7090605@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="oENwiXGhl1bilLAUx1O73jJ8lVSrd2lTS"
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	"David S. Miller" <davem@davemloft.net>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	netdev@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: elfring@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:16265 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934844AbbKTJHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 04:07:23 -0500
In-Reply-To: <56391F73.7090605@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oENwiXGhl1bilLAUx1O73jJ8lVSrd2lTS
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 04/11/15 04:56, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 3 Nov 2015 21:10:51 +0100
>=20
> The variables "tt_local_entry" and "tt_global_entry" were eventually ch=
ecked
> again despite of a corresponding null pointer test before.
> Let us avoid this double check by reordering a function call sequence
> and the better selection of jump targets.
>=20
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  net/batman-adv/translation-table.c | 21 +++++++++------------
>  1 file changed, 9 insertions(+), 12 deletions(-)
>=20
> diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/transl=
ation-table.c
> index 965a004..3ac32d9 100644
> --- a/net/batman-adv/translation-table.c
> +++ b/net/batman-adv/translation-table.c
> @@ -3323,27 +3323,24 @@ bool batadv_is_ap_isolated(struct batadv_priv *=
bat_priv, u8 *src, u8 *dst,
>  		return false;
> =20
>  	if (!atomic_read(&vlan->ap_isolation))
> -		goto out;
> +		goto vlan_free;
> =20
>  	tt_local_entry =3D batadv_tt_local_hash_find(bat_priv, dst, vid);
>  	if (!tt_local_entry)
> -		goto out;
> +		goto vlan_free;
> =20
>  	tt_global_entry =3D batadv_tt_global_hash_find(bat_priv, src, vid);
>  	if (!tt_global_entry)
> -		goto out;
> +		goto local_entry_free;
> =20
> -	if (!_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
> -		goto out;
> -
> -	ret =3D true;
> +	if (_batadv_is_ap_isolated(tt_local_entry, tt_global_entry))
> +		ret =3D true;
> =20
> -out:
> +	batadv_tt_global_entry_free_ref(tt_global_entry);
> +local_entry_free:
> +	batadv_tt_local_entry_free_ref(tt_local_entry);
> +vlan_free:
>  	batadv_softif_vlan_free_ref(vlan);
> -	if (tt_global_entry)
> -		batadv_tt_global_entry_free_ref(tt_global_entry);
> -	if (tt_local_entry)
> -		batadv_tt_local_entry_free_ref(tt_local_entry);
>  	return ret;

Markus,
if you really want to make this codestyle change, I'd suggest you to go
through the whole batman-adv code and apply the same change where
needed. It does not make sense to change the codestyle in one spot only.

On top of that, by going through the batman-adv code you might agree
that the current style is actually not a bad idea.


Cheers,

--=20
Antonio Quartulli


--oENwiXGhl1bilLAUx1O73jJ8lVSrd2lTS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWTt4dAAoJENpFlCjNi1MR78MQALVT4accqyLRwu+xrq8MAWgY
1vjTsalv/keA2gJ2JyCChWv7XqWqb8JL0UtTHQZJVKSXMvfa+IpYUfQCR/NTb4U9
uyk8RUYtW1QygLBkKYGWRPw0poRnYdVc6W9B8qq7KJafEfGSaz1vd9CkV/Ma13/o
mv80BehlI65hlXI/SCnOfxbQWz8Yr36feMrWLrxPMf03TwkPAJFXUfEx7SJo0ZuG
nRBQXwkLc9sfMRjG7QyEONr9UtpDnbSGNo4iZbMiqELyizeFo+Ij0P4qLMTBJVbq
NFwBvcCdFO7Bpm/MrueALPHjjK6cLWbLgux6ebRIkEcyZB0jMw9gXC/6eDWlgVIX
cPdZWIfSmt4FVZWPzqoPAP9yXHidkr/I/DY+RSUOxj8WN2y9N8Lk2OOJaPT1qYkv
oFB5DL575j6ErNxgdPP+0HTImYKukPf4jMudUd+LPvCh/qQFV5KwUH+VAsS1bdcx
iwnQwGJmwA/0WNW5a8uCH8wXDiADFeZ3KXIIKMpTaZatKKh4aGVOrMF7Q1N17C3Y
pnTQW5kbO2JdxklBN25rbwq18YCN0+zbVH4q0njehrnsuK6VvZc4MpfFXSIWzZm9
SsXrtQH08Nca/2stUNvwPS7/OxWa1K7HcHM7JZTQBSGvQxXMimrU+TxPLP4haJSL
ouphTZfbqIqw94aV526k
=XYHX
-----END PGP SIGNATURE-----

--oENwiXGhl1bilLAUx1O73jJ8lVSrd2lTS--
