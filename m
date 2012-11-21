From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] [PATCH V3] xen/netfront: handle compound page fragments
 on transmit
Date: Wed, 21 Nov 2012 14:45:25 +0100
Message-ID: <50ACDAF5.2030404@canonical.com>
References: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig91DCED7CD60A1DB594E4A616"
Cc: netdev@vger.kernel.org, Sander Eikelenboom <linux@eikelenboom.it>,
	ANNIE LI <annie.li@oracle.com>, xen-devel@lists.xen.org,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56621 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab2KUNpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 08:45:32 -0500
In-Reply-To: <1353499336-28952-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig91DCED7CD60A1DB594E4A616
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

FWIW, I ran the v3 version and it appears to be good from that point of v=
iew.
If it looks good to everyone else, it would be great if that could reach =
3.7
final. :)

-Stefan

On 21.11.2012 13:02, Ian Campbell wrote:
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
> ---
> v3: limit to 80-characters. Use net_alert_ratelimited.
> v2: check we have enough room in the ring and that the other end can
>     cope with the number of slots in a single frame
> ---
>  drivers/net/xen-netfront.c |   98 ++++++++++++++++++++++++++++++++++--=
-------
>  1 files changed, 77 insertions(+), 21 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index caa0110..fc24eb9 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -452,29 +452,85 @@ static void xennet_make_frags(struct sk_buff *skb=
, struct net_device *dev,
>  	/* Grant backend access to each skb fragment page. */
>  	for (i =3D 0; i < frags; i++) {
>  		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
> +		struct page *page =3D skb_frag_page(frag);
> =20
> -		tx->flags |=3D XEN_NETTXF_more_data;
> +		len =3D skb_frag_size(frag);
> +		offset =3D frag->page_offset;
> =20
> -		id =3D get_id_from_freelist(&np->tx_skb_freelist, np->tx_skbs);
> -		np->tx_skbs[id].skb =3D skb_get(skb);
> -		tx =3D RING_GET_REQUEST(&np->tx, prod++);
> -		tx->id =3D id;
> -		ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
> -		BUG_ON((signed short)ref < 0);
> +		/* Data must not cross a page boundary. */
> +		BUG_ON(len + offset > PAGE_SIZE<<compound_order(page));
> =20
> -		mfn =3D pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
> -		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> -						mfn, GNTMAP_readonly);
> +		/* Skip unused frames from start of page */
> +		page +=3D offset >> PAGE_SHIFT;
> +		offset &=3D ~PAGE_MASK;
> =20
> -		tx->gref =3D np->grant_tx_ref[id] =3D ref;
> -		tx->offset =3D frag->page_offset;
> -		tx->size =3D skb_frag_size(frag);
> -		tx->flags =3D 0;
> +		while (len > 0) {
> +			unsigned long bytes;
> +
> +			BUG_ON(offset >=3D PAGE_SIZE);
> +
> +			bytes =3D PAGE_SIZE - offset;
> +			if (bytes > len)
> +				bytes =3D len;
> +
> +			tx->flags |=3D XEN_NETTXF_more_data;
> +
> +			id =3D get_id_from_freelist(&np->tx_skb_freelist,
> +						  np->tx_skbs);
> +			np->tx_skbs[id].skb =3D skb_get(skb);
> +			tx =3D RING_GET_REQUEST(&np->tx, prod++);
> +			tx->id =3D id;
> +			ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
> +			BUG_ON((signed short)ref < 0);
> +
> +			mfn =3D pfn_to_mfn(page_to_pfn(page));
> +			gnttab_grant_foreign_access_ref(ref,
> +							np->xbdev->otherend_id,
> +							mfn, GNTMAP_readonly);
> +
> +			tx->gref =3D np->grant_tx_ref[id] =3D ref;
> +			tx->offset =3D offset;
> +			tx->size =3D bytes;
> +			tx->flags =3D 0;
> +
> +			offset +=3D bytes;
> +			len -=3D bytes;
> +
> +			/* Next frame */
> +			if (offset =3D=3D PAGE_SIZE && len) {
> +				BUG_ON(!PageCompound(page));
> +				page++;
> +				offset =3D 0;
> +			}
> +		}
>  	}
> =20
>  	np->tx.req_prod_pvt =3D prod;
>  }
> =20
> +/*
> + * Count how many ring slots are required to send the frags of this
> + * skb. Each frag might be a compound page.
> + */
> +static int xennet_count_skb_frag_slots(struct sk_buff *skb)
> +{
> +	int i, frags =3D skb_shinfo(skb)->nr_frags;
> +	int pages =3D 0;
> +
> +	for (i =3D 0; i < frags; i++) {
> +		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
> +		unsigned long size =3D skb_frag_size(frag);
> +		unsigned long offset =3D frag->page_offset;
> +
> +		/* Skip unused frames from start of page */
> +		offset &=3D ~PAGE_MASK;
> +
> +		pages +=3D PFN_UP(offset + size);
> +	}
> +
> +	return pages;
> +}
> +
>  static int xennet_start_xmit(struct sk_buff *skb, struct net_device *d=
ev)
>  {
>  	unsigned short id;
> @@ -487,23 +543,23 @@ static int xennet_start_xmit(struct sk_buff *skb,=
 struct net_device *dev)
>  	grant_ref_t ref;
>  	unsigned long mfn;
>  	int notify;
> -	int frags =3D skb_shinfo(skb)->nr_frags;
> +	int slots;
>  	unsigned int offset =3D offset_in_page(data);
>  	unsigned int len =3D skb_headlen(skb);
>  	unsigned long flags;
> =20
> -	frags +=3D DIV_ROUND_UP(offset + len, PAGE_SIZE);
> -	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
> -		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
> -		       frags);
> -		dump_stack();
> +	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> +		xennet_count_skb_frag_slots(skb);
> +	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> +		net_alert_ratelimited(
> +			"xennet: skb rides the rocket: %d slots\n", slots);
>  		goto drop;
>  	}
> =20
>  	spin_lock_irqsave(&np->tx_lock, flags);
> =20
>  	if (unlikely(!netif_carrier_ok(dev) ||
> -		     (frags > 1 && !xennet_can_sg(dev)) ||
> +		     (slots > 1 && !xennet_can_sg(dev)) ||
>  		     netif_needs_gso(skb, netif_skb_features(skb)))) {
>  		spin_unlock_irqrestore(&np->tx_lock, flags);
>  		goto drop;
>=20



--------------enig91DCED7CD60A1DB594E4A616
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iQIcBAEBCgAGBQJQrNr1AAoJEOhnXe7L7s6jVJgP/Ri1PSISucuJDNdgj/1ievSj
GVFnGTgYDMVCh2/afk8CAnkmlfIiVyPyhko/EDtkd9BJYucPjwg8VHWnDFUyNqbG
vG1KLxddOd0YERQjSzr9eZltwyUlsVWLuJYZcF75D4Jq7F9e+Qv4b8GHH6m+0O+r
vaEuRA/KvKzLzLlqcneV2SBy8YrqI6YgPlViE0fAZV8jTthL6oR1jVBerWeMuM9p
J/YllFICR+JxIB6HHnI8U1c9uHgeL/wzZnmyXIAZxAMBKrzracmmQ5J3xIfx0DRS
Mu19JhXGwcYZl7Vcuc4uR9BLef4Icy0IhxVGiKfJITqA1LIEo2drQtQSGYFgwU0g
nRzW4VEhllmbuCtOh5O4RAShjkihRcnhgQypO/mU5R0VAw/9dnasG/9E/r4P65no
V2vGr6K1ewJWvmZ7vl+cNRHX84JHDU3SBdjfAnsDNDcjijJeMX0m5ltP0Tq9IgCZ
g0nniIhXTSyiJSNvEvipMHhJ80GErgQQTtaFcbtOlzgIqi5uX1vCD+MdxV7Y49qj
L9OAf+elF7D+tvRauwaJ/++/Wh84ELI9d4lGatU1aLjDJ6RB9Vi9j8iBnT9p03m4
oMS2PMOMatEX09HwFHL7dKYU1xjtt6N2NDpyzTrdbtQQPkf1YKsLbqFFfy2GNsWa
D47SCm83pidUfYIZEOuw
=2+Ly
-----END PGP SIGNATURE-----

--------------enig91DCED7CD60A1DB594E4A616--
