From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v3 1/2] net: implement dma cache skb allocator
Date: Sat, 14 Mar 2015 20:08:45 +0000
Message-ID: <1426363725.4173.113.camel@decadent.org.uk>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com>
	 <1426009384-11544-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Xc8b6xFcB71Gm/+G+6jP"
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53833 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbbCNUI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 16:08:59 -0400
In-Reply-To: <1426009384-11544-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Xc8b6xFcB71Gm/+G+6jP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-10 at 23:13 +0530, Govindarajulu Varadarajan wrote:
[...]
> +static struct netdev_dma_node *netdev_dma_alloc(struct netdev_dma_head *=
nc_head,
> +						size_t sz)
> +{
> +	struct netdev_dma_node *nc =3D nc_head->nc;
> +	int offset;
> +
> +	if (unlikely(!nc)) {
> +refill:
> +		__dma_cache_refill(nc_head, sz);
> +		nc =3D nc_head->nc;
> +		if (unlikely(!nc))
> +			return NULL;
> +	}
> +
> +	offset =3D nc->frag.offset - sz;
> +	if (offset < 0) {
> +		if (!atomic_sub_and_test(nc->pagecnt_bias,
> +					 &nc->frag.page->_count)) {
> +			/* the caller has processed all the frags belonging to
> +			 * this page. Since page->_count is not 0 and
> +			 * nc->dma_count is 0 these frags should be in stack.
> +			 * We should unmap the page here.

Unmapping potentially copies data back from a bounce buffer (even if
it's already been synchronised).  This is OK in the case of a buffer
that's attached to the skb as a page fragment, because in that case it's
read-only for the stack.  It's not OK for a buffer that has been passed
to build_skb(), as this may legitimately have been changed by the stack
and this will overwrite the changes.

So you have to choose between DMA buffer recycling and build_skb().

> +			 */
> +			if (!nc->dma_count) {
> +				dma_unmap_single(nc_head->dev, nc->dma_addr,
> +						 nc->frag.size,
> +						 DMA_FROM_DEVICE);
[...]

Don't mix dma_map_page() and dma_unmap_single().

Ben.

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-Xc8b6xFcB71Gm/+G+6jP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQSVUue/yOyVhhEJAQpu0hAAjOA7G8UD7mkSZ/PvvPF8tXH7wzqU1VQy
mHlvCCsYAu4xLW3e9nwkXN5A6XSD1+LhzE7/+XcH27mm/wiKqFuQLugH73GdppYe
ZRhJjV6nlnsu1dafhmNq6nQ3KWK9cCTm3+4UrZ6GQdInvpbrkSkhKXGVnjYU+3cS
B8cvXRUZ7lhjQxdtYzlKMWLS4cQOm9sPpgkJRWe5THgrSqHmhyb9gsAMi3ArACj6
+xhnpSNyyp3K8tBBCxl/P890mWFM5pDUukNqploeifBlBcf7Hg3c4gHDKsYj2uSD
bvf8iYMSyazideeNG0oS9IoIIMN+dd70akXFY69hAIAmpLm6R5xyBlamRaX1Jp9B
8rtZ7YiZHXj+H9U+NlFUtjiHdK+DTl81evPZtA/LoPCExdMZsd0HGbxx5WhgVnBP
6yQFjMZqTSTZEg7WMHQxk7B2zfe934gB9FRZG7Kn0HFiKdG14QSSmcQG1AfqEPHx
uuivYtCFvqyD/Z9DnUVXQySJSDFBzKtJYWs6eH2OvzQJR57dDS5LizBRBR29/b+1
6OULK1yKAxyiEkUxLQBOyEC1cCVENU2+n5G0NZRsy5tDBbQaNlvk2Q22ttO8wMHX
K9/WBgJ8zDfn5G4VCQRXVuviqEN/lCPqTjxC+SmwkIYIAeQMry36yICz60uunD2g
/vfSL2+Qz/w=
=qDri
-----END PGP SIGNATURE-----

--=-Xc8b6xFcB71Gm/+G+6jP--
