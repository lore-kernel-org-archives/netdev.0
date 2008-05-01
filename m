From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 13:38:33 +0200
Message-ID: <1209641914.3904.0.camel@johannes.berg>
References: <20080501.024320.212547875.davem@davemloft.net>
	 <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
	 <20080501.034950.261408566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wDIw3NS3dGv42rxbB5ci"
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080501.034950.261408566.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-wDIw3NS3dGv42rxbB5ci
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> That makes more sense, good catch Herbert.
>=20
> I guess it's the pskb_expand_head() calls done by net/mac80211/tx.c
> I suspect we'll need to orphan early in order to accomodate these
> adjustments, otherwise socket memory buffer allocations will
> be corrupted.
>=20
> Once that is cured, I think we can detect this better, by adding a
> carefully constructed assertion to pskb_expand_head().  Basically, the
> idea is, if "nhead" or "ntail" are non-zero, and there is a socket
> still attached to the SKB, print a warning message.
>=20
> Something like:
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 4fe605f..9bfca08 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -699,6 +699,12 @@ int pskb_expand_head(struct sk_buff *skb, int nhead,=
 int ntail,
>  	if (skb_shared(skb))
>  		BUG();
> =20
> +	if (unlikely((nhead || ntail) && skb->sk)) {
> +		printk(KERN_ERR "SKB BUG: Illegal pskb expand (%d:%d) "
> +		       "with socket attached\n",
> +		       nhead, ntail);
> +	}
> +
>  	size =3D SKB_DATA_ALIGN(size);

Ok I think I'm starting to understand this a little better. However,
shouldn't this function update skb->truesize so if the skb is later
attached to a different socket again it has the right size?

johannes

--=-wDIw3NS3dGv42rxbB5ci
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmruKVg1VMiehFYAQIzlw//WgVpTDMA4vCcbfucAH2Wi8H3jQnSZJUR
8M3PCwdyigHkKofzLV7kg8N5fG6gkSdzNyYFj8PbFlWI6Ab8i3SUcaffBTUzcSAG
TOemBWdKETeXoeEICQzGIj8rye3oG6nowwKCxohjsrHmcrXv1ETux8bqo1nZWACz
KzXDGQqWUNFw/Z6gPPDWN5TZAdehDkQOtx38pC7OwuQlGEkQH3JkJjyWRUwWNur5
Rukx/KpgsUiIcncRJGxDFHwWu9awg9e3qw5IaTDu6jxA4idcaWXm5FAeXsPMtw2U
re/Zkdm6pxlRialE/ztMrFkces5ZVqdMMYre8/fAVB6gftmwc9XHNUnsppGiLpkl
VLyWoZmiL8cLC8YzS3o6FdaI/jUPTzM0YpvZVCsa/zCYur0KDIkqHRo8xsBWuOFg
kTN+iIbc59KlXojW/Nc6HrCPJkagSkIY3/CvrsOZ/ibpgyO0ED5KDVV04+8klmAd
WQrFuj587o7apddyosqb4pRPsS31U3rCYkJr29xX+p5kZ2+uhXWqil3hm0Y+j+Ov
ZZUHgPCy/7aVbI5Owbl6PkShk69WlD1qIFL+lj1+jG4v2pRGHrSrkrQa48GG2Bif
Vw8ps3RSbyzhQdKSlj6DrGNYwkczjsESorlK+4X5fGGwtshut6qV3jOxOA7K9ADP
/27SnmcTmAA=
=0gg5
-----END PGP SIGNATURE-----

--=-wDIw3NS3dGv42rxbB5ci--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
