From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [PATCH] xen/netfront: handle compound page fragments on transmit
Date: Tue, 20 Nov 2012 14:30:54 +0100
Message-ID: <50AB860E.3090106@canonical.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com> <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig31733BF0961A95AEC5CF5C5D"
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:50828 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab2KTNbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 08:31:00 -0500
In-Reply-To: <1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig31733BF0961A95AEC5CF5C5D
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Aside from Jans comments about error handling, I tried below patch and it=
 seems
to solve the problem with transfers out of the domU for me (though only s=
hallow
testing done, otoh 5 times is more than getting stuck the first time).

-Stefan

On 20.11.2012 12:40, Ian Campbell wrote:
> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.
>=20
> Handle this in xennet_make_frags by iterating over the frames which
> make up the page.
>=20
> This is the netfront equivalent to 6a8ed462f16b for netback.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: xen-devel@lists.xen.org
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> Cc: ANNIE LI <annie.li@oracle.com>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> Cc: Stefan Bader <stefan.bader@canonical.com>
Tested-by: Stefan Bader <stefan.bader@canonical.com>
> ---
>  drivers/net/xen-netfront.c |   58 +++++++++++++++++++++++++++++++++---=
-------
>  1 files changed, 44 insertions(+), 14 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index caa0110..a12b99a 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -452,24 +452,54 @@ static void xennet_make_frags(struct sk_buff *skb=
, struct net_device *dev,
>  	/* Grant backend access to each skb fragment page. */
>  	for (i =3D 0; i < frags; i++) {
>  		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
> +		struct page *page =3D skb_frag_page(frag);
> +		unsigned long size =3D skb_frag_size(frag);
> +		unsigned long offset =3D frag->page_offset;
> =20
> -		tx->flags |=3D XEN_NETTXF_more_data;
> +		/* Data must not cross a page boundary. */
> +		BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
> =20
> -		id =3D get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> -		np->tx_skbs[id].skb =3D skb_get(skb);
> -		tx =3D RING_GET_REQUEST(&np->tx, prod++);
> -		tx->id =3D id;
> -		ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
> -		BUG_ON((signed short)ref < 0);
> +		/* Skip unused frames from start of page */
> +		page +=3D offset >> PAGE_SHIFT;
> +		offset &=3D ~PAGE_MASK;
> =20
> -		mfn =3D pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
> -		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> -						mfn, GNTMAP_readonly);
> +		while (size > 0) {
> +			unsigned long bytes;
> =20
> -		tx->gref =3D np->grant_tx_ref[id] =3D ref;
> -		tx->offset =3D frag->page_offset;
> -		tx->size =3D skb_frag_size(frag);
> -		tx->flags =3D 0;
> +			BUG_ON(offset >=3D PAGE_SIZE);
> +
> +			bytes =3D PAGE_SIZE - offset;
> +			if (bytes > size)
> +				bytes =3D size;
> +
> +			tx->flags |=3D XEN_NETTXF_more_data;
> +
> +			id =3D get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> +			np->tx_skbs[id].skb =3D skb_get(skb);
> +			tx =3D RING_GET_REQUEST(&np->tx, prod++);
> +			tx->id =3D id;
> +			ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
> +			BUG_ON((signed short)ref < 0);
> +
> +			mfn =3D pfn_to_mfn(page_to_pfn(page));
> +			gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> +							mfn, GNTMAP_readonly);
> +
> +			tx->gref =3D np->grant_tx_ref[id] =3D ref;
> +			tx->offset =3D offset;
> +			tx->size =3D bytes;
> +			tx->flags =3D 0;
> +
> +			offset +=3D bytes;
> +			size -=3D bytes;
> +
> +			/* Next frame */
> +			if (offset =3D=3D PAGE_SIZE && size) {
> +				BUG_ON(!PageCompound(page));
> +				page++;
> +				offset =3D 0;
> +			}
> +		}
>  	}
> =20
>  	np->tx.req_prod_pvt =3D prod;
>=20



--------------enig31733BF0961A95AEC5CF5C5D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQq4YOAAoJEOhnXe7L7s6j5J8QAKyiFdtq2szKHCT3Ay4xZ5EF
auXUvtLlHo9hS6EFXfh4mp9wUzJsWtjqHT+X3U8htaPbxdkeOFQnPJZMcfKNePqu
2YAWfDfuPo41Z64ViXC/3ugj6PPdikpXCPZl2WSSKcmP1dL7vwNhHYSRGqPyw4Rg
vkutmUhHEQ5V5xQ5fWNQoa65euiPyudTqjWi2CTekr9i/XBw/CamTUP6kakffbgh
Z3v1+QMiG6rZhUrpfzIJcN/rTD9e0+X8MO3y3dL5gR5H0gLxS98U5wicSOp6Inqk
rgn85OMkAZ99diIYRO6DLrIXJyHPbXW2ROLMtLGGhxFqoMA9wr02ae1UaGS+5LMQ
i+9bGLDScMeAkZeMu1IlLHM5R69t9MIcn733+dq+wqN8/tdeCC0eZmFv1i3SR8ds
pDjHLB5jI3jXafwHG+x6i8e6zVEvd01mK/3F9QxDgnblnyJWV9i1RdR85ujae/D2
zKUsYFBw9BVGgwuFVlXWT80PwB5xRq/WUfBo8Yc3SAwU4SsnwgiD3iSqQuEpA00x
5wMU1sYssfZ03BiYExBSoWSKtpgG8oDU1jaN/FTn3W7qaACQcWnVTjsXemJzgz0Y
iXaApEdfvCg8buPNrQC/9NBzjVIY74YXfh4nDiUar20Nu7zc3Pv1udsiC9PhPAeY
B4oBTxvrRrURaVDm4SHT
=/1Ia
-----END PGP SIGNATURE-----

--------------enig31733BF0961A95AEC5CF5C5D--
