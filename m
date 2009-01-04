From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless
	stack
Date: Sun, 04 Jan 2009 17:05:50 +0100
Message-ID: <1231085150.3296.3.camel@johannes>
References: <20090104151819.GA6590@basil.nowhere.org>
	 (sfid-20090104_161709_234776_1A23AA01)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tHlJVuWoArXUllgvWLnM"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090104151819.GA6590-3rXA9MLqAseW/qJFnhkgxti2O/JbrIOy@public.gmane.org> (sfid-20090104_161709_234776_1A23AA01)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-tHlJVuWoArXUllgvWLnM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-01-04 at 16:18 +0100, Andi Kleen wrote:
> Fix up truesize after pskb_expand_head() in wireless stack
> =20
> When using a zd1211rw wireless usb stick I regularly got truesize
> warnings in the kernel log.
>=20
> This patch fixes those up in the wireless layer. tx.c already
> did that, but not rx.c. I think my messages only came from
> the middle case, but I fixed up all three users in rx.c=20
>=20
> The underlying problem seems to be that pskb_expand_head() doesn't=20
> manipulate truesize. Perhaps it should? I suspect more users of it have=20
> the same problem. I didn't change the low level code because
> I was afraid to break some callers, but perhaps it would be
> better to do it this way. Anyways here's a patch that only
> changes it in the wireless layer with minimal risk.
>=20
> Patch against 2.6.28, but I think linus git still has the same
> issue.
>=20
> I believe this is a 2.6.28 stable candidate. I even saw
> the same problem in 2.6.27.
>=20
> Signed-off-by: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Thanks, but I'll need to look at this in more detail, we need to make
sure that we orphan the skb before etc. And then, we need to check
whether it makes sense to do this in pskb_expand_head().

> ---
>  net/mac80211/rx.c |   19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
>=20
> Index: linux-2.6.28-test/net/mac80211/rx.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.28-test.orig/net/mac80211/rx.c	2008-10-24 13:35:11.00000000=
0 +0200
> +++ linux-2.6.28-test/net/mac80211/rx.c	2009-01-01 15:51:34.000000000 +01=
00
> @@ -263,10 +263,12 @@
>  		 * probably export the length to drivers so that we can have
>  		 * them allocate enough headroom to start with.
>  		 */
> -		if (skb_headroom(skb) < needed_headroom &&
> -		    pskb_expand_head(skb, needed_headroom, 0, GFP_ATOMIC)) {
> -			dev_kfree_skb(skb);
> -			return NULL;
> +		if (skb_headroom(skb) < needed_headroom) {
> +			if (pskb_expand_head(skb, needed_headroom, 0, GFP_ATOMIC)) {
> +				dev_kfree_skb(skb);
> +				return NULL;
> +			}
> +			skb->truesize +=3D needed_headroom;
>  		}
>  	} else {
>  		/*
> @@ -945,6 +947,7 @@
>  			__skb_queue_purge(&entry->skb_list);
>  			return RX_DROP_UNUSABLE;
>  		}
> +		rx->skb->truesize +=3D entry->extra_len;
>  	}
>  	while ((skb =3D __skb_dequeue(&entry->skb_list))) {
>  		memcpy(skb_put(rx->skb, skb->len), skb->data, skb->len);
> @@ -1691,9 +1694,11 @@
>  	if (rx->flags & IEEE80211_RX_CMNTR_REPORTED)
>  		goto out_free_skb;
> =20
> -	if (skb_headroom(skb) < sizeof(*rthdr) &&
> -	    pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC))
> -		goto out_free_skb;
> +	if (skb_headroom(skb) < sizeof(*rthdr)) {
> +		if (pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC))
> +			goto out_free_skb;
> +		skb->truesize +=3D sizeof(*rthdr);
> +	}
> =20
>  	rthdr =3D (void *)skb_push(skb, sizeof(*rthdr));
>  	memset(rthdr, 0, sizeof(*rthdr));
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"=
 in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=-tHlJVuWoArXUllgvWLnM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJYN5YAAoJEKVg1VMiehFYmNsP/0mtX4Ry+vOgCB5rckxOeE5T
DMKtAjQHa1ZjRNoTaNzOxkoFn0EcE2ahH+3RMqCiM256lkHIGeEBSRuMnPN0I8Rj
6+kEm7s5sCuAGvgUR3RW2AKjQx/Orog2zDkj+ufohuKogD70CXBfddMA46VZi+Hl
DSVz4L4uHBHqqkiWu5XGiJ3aZXnn0Gxo2LL+lb4CKIjUMhWN43AOIjiLZZQWruLX
pWY5Q2jQGPwFnKepXWgZTNYGTTZ/aNsqGytdXxDtTXpEZXuRmWCrV0Zyr2m0EHpx
ffM2j8SjpUdr2Q4qZPd69NZ1aJJqyrZkp4inKluLtVoei2784YdjJKAaDhUfgRLj
WJBuTt6+mRfsP3ng0upU2swf6ESmUTR/9Gnsqx7NJlQ4kDSXD+GDIwynmfWN2Ocv
VQ+mciRoRggdIaNxuowjL5FlZ75nmzzqbcdHFAwffvwqZuVHLJd/9WbD5LTyYBl6
vl3VdbFUWzh3IFdoxKAcwv56Be7eryNNN/fUOoDbYsKIdwhcgvw/N3OSB+SKtaWG
xVeVqZ3Mfbvp3cM8QwioqrOQCNDeNMg9EgcgvOIhdojofPEXVWdgGnv5G+ItGhcK
PEhK3U92DVb1cTq0GFrBLSFtPJERYhAl8ipEMTd6FYAUruVHrhLLdI84ND/GpCB0
HBa1N7DAncjR4sEWbuJB
=3jmV
-----END PGP SIGNATURE-----

--=-tHlJVuWoArXUllgvWLnM--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
