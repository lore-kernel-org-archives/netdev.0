From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 07/17] new helpers: skb_copy_datagram_from_iter() and
 zerocopy_sg_from_iter()
Date: Mon, 24 Nov 2014 00:02:45 +0000
Message-ID: <1416787365.7215.63.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043320.GG30478@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6bdp5MQyREEVBXkJcpNp"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <20141122043320.GG30478@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6bdp5MQyREEVBXkJcpNp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 04:33 +0000, Al Viro wrote:
[...]
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -572,6 +572,77 @@ fault:
>  }
>  EXPORT_SYMBOL(skb_copy_datagram_from_iovec);
> =20

Missing kernel-doc.

> +int skb_copy_datagram_from_iter(struct sk_buff *skb, int offset,
> +				 struct iov_iter *from,
> +				 int len)
> +{
> +	int start =3D skb_headlen(skb);
> +	int i, copy =3D start - offset;
> +	struct sk_buff *frag_iter;
> +
> +	/* Copy header. */
> +	if (copy > 0) {
> +		if (copy > len)
> +			copy =3D len;
> +		if (copy_from_iter(skb->data + offset, copy, from) !=3D copy)
> +			goto fault;
> +		if ((len -=3D copy) =3D=3D 0)
> +			return 0;
> +		offset +=3D copy;
> +	}
> +
> +	/* Copy paged appendix. Hmm... why does this look so complicated? */
> +	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		int end;
> +		const skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> +
> +		WARN_ON(start > offset + len);
> +
> +		end =3D start + skb_frag_size(frag);
> +		if ((copy =3D end - offset) > 0) {
> +			size_t copied;

Blank line needed after a declaration.

> +			if (copy > len)
> +				copy =3D len;
> +			copied =3D copy_page_from_iter(skb_frag_page(frag),
> +					  frag->page_offset + offset - start,
> +					  copy, from);
> +			if (copied !=3D copy)
> +				goto fault;
> +
> +			if (!(len -=3D copy))
> +				return 0;

The other two instances of this condition are written as:

			if ((len -=3D copy) =3D=3D 0)

Similarly in skb_copy_bits().

> +			offset +=3D copy;
> +		}
> +		start =3D end;
> +	}
> +
> +	skb_walk_frags(skb, frag_iter) {
> +		int end;
> +
> +		WARN_ON(start > offset + len);
> +
> +		end =3D start + frag_iter->len;
> +		if ((copy =3D end - offset) > 0) {
> +			if (copy > len)
> +				copy =3D len;
> +			if (skb_copy_datagram_from_iter(frag_iter,
> +							offset - start,
> +							from, copy))
> +				goto fault;
> +			if ((len -=3D copy) =3D=3D 0)
> +				return 0;
> +			offset +=3D copy;
> +		}
> +		start =3D end;
> +	}
> +	if (!len)
> +		return 0;
> +
> +fault:
> +	return -EFAULT;
> +}
> +EXPORT_SYMBOL(skb_copy_datagram_from_iter);
> +
>  /**
>   *	zerocopy_sg_from_iovec - Build a zerocopy datagram from an iovec
>   *	@skb: buffer to copy
> @@ -643,6 +714,50 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, cons=
t struct iovec *from,
>  }
>  EXPORT_SYMBOL(zerocopy_sg_from_iovec);
> =20

Missing kernel-doc.

> +int zerocopy_sg_from_iter(struct sk_buff *skb, struct iov_iter *from)
> +{
> +	int len =3D iov_iter_count(from);
> +	int copy =3D min_t(int, skb_headlen(skb), len);
> +	int i =3D 0;
> +
> +	/* copy up to skb headlen */
> +	if (skb_copy_datagram_from_iter(skb, 0, from, copy))
> +		return -EFAULT;
> +
> +	while (iov_iter_count(from)) {
> +		struct page *pages[MAX_SKB_FRAGS];
> +		size_t start;
> +		ssize_t copied;
> +		unsigned long truesize;
> +		int n =3D 0;
> +
> +		copied =3D iov_iter_get_pages(from, pages, ~0U, MAX_SKB_FRAGS, &start)=
;
> +		if (copied < 0)
> +			return -EFAULT;
> +
> +		truesize =3D DIV_ROUND_UP(copied + start, PAGE_SIZE) * PAGE_SIZE;

PAGE_ALIGN(copied + start) ?

> +		skb->data_len +=3D copied;
> +		skb->len +=3D copied;
> +		skb->truesize +=3D truesize;
> +		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
> +		while (copied) {
> +			int off =3D start;

This variable seems redundant.  Can't we use start directly and move the
'start =3D 0' to the bottom of the loop?

> +			int size =3D min_t(int, copied, PAGE_SIZE - off);
> +			start =3D 0;
> +			if (i < MAX_SKB_FRAGS)
> +				skb_fill_page_desc(skb, i, pages[n], off, size);
> +			else
> +				put_page(pages[n]);

Why is this condition needed, given we told iov_iter_get_pages() to
limit to MAX_SKB_FRAGS pages?

> +			copied -=3D size;
> +			i++, n++;
> +		}
> +		if (i > MAX_SKB_FRAGS)
> +			return -EMSGSIZE;

Same here.

Ben.

> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL(zerocopy_sg_from_iter);
> +
>  static int skb_copy_and_csum_datagram(const struct sk_buff *skb, int off=
set,
>  				      u8 __user *to, int len,
>  				      __wsum *csump)

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-6bdp5MQyREEVBXkJcpNp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHJ1que/yOyVhhEJAQrQ1xAArYpNNrLZoTW6e6xEwkUNM6YOj/dNDLoH
cOxn63Fdm5I4jeU5r7M6EUgZflKJgVqarJhw4d5/VO1myvPjFO88dVrcJrgteGN9
0+rv/rPtA+9tQHiCVy4RuNKoCVp8xqiTCewAFigafMaNQkioSaMoFwb+TBXnbAV8
8p1XeQUd8ZBz7CUB6NkdYdtKzokoyFlgQkwl1z2CJtbnAEjyMZ+ywn/H7qHV6tY1
8iRHaAmt0Vn7VasIUCKuvVNSRxmYoxtjt6UWmLrxx9wpkMR6XLX1yLk0U3LmOSj/
7vg5fTJCncsbfaKsq8OCuGbf4SSM/Hli0uE0cZ73VVMahXowC+R2+PfLqU19/imv
J3WeY0BetMukAofrdxo4y5uL3lpfsd7ts1glQReV77DBKLHo+cdEcpcgQr9SGqI/
aYxpOaumjVN+imXKWfsEaH8GpzGYPOlhDEiuHLpHu7JwgEDKWh6k9VmCWQ+tBKD8
d64mrULKJhD2KnyTF1L16TQ0qws3A2E1KRtLIgD2KsK4Y0KNYLrgiVO4Cvzstpf7
pPK6K1gp8HzarYY2yhdMv68fZbEdcgOWnKwDYiNULjAfl/iQCiZwKb6JXiGh1/Ra
sA0JPzdQfSF2Q/nUr+3x/nmQDVPUMHtJNBXRIgNKaywU2fVZ/zbeIfLaJKqsE/z8
Fwh1vWDXjUQ=
=EqO7
-----END PGP SIGNATURE-----

--=-6bdp5MQyREEVBXkJcpNp--
