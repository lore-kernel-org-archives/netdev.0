From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 08/17] {macvtap,tun}_get_user(): switch to iov_iter
Date: Mon, 24 Nov 2014 00:27:42 +0000
Message-ID: <1416788862.7215.65.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043352.GH30478@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3S4thgiAxKwRXEPZti8u"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141122043352.GH30478@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-3S4thgiAxKwRXEPZti8u
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 04:33 +0000, Al Viro wrote:
> allows to switch macvtap and tun from ->aio_write() to ->write_iter()
>=20
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/net/macvtap.c |   43 ++++++++++++++++++++-----------------------
>  drivers/net/tun.c     |   43 +++++++++++++++++++++++--------------------
>  2 files changed, 43 insertions(+), 43 deletions(-)
>=20
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index cdd820f..2bf08c6 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -640,12 +640,12 @@ static void macvtap_skb_to_vnet_hdr(const struct sk=
_buff *skb,
> =20
>  /* Get packet from user space buffer */
>  static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *=
m,
> -				const struct iovec *iv, unsigned long total_len,
> -				size_t count, int noblock)
> +				struct iov_iter *from, int noblock)
>  {
>  	int good_linear =3D SKB_MAX_HEAD(NET_IP_ALIGN);
>  	struct sk_buff *skb;
>  	struct macvlan_dev *vlan;
> +	unsigned long total_len =3D iov_iter_count(from);
>  	unsigned long len =3D total_len;
>  	int err;
>  	struct virtio_net_hdr vnet_hdr =3D { 0 };
> @@ -653,6 +653,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue =
*q, struct msghdr *m,
>  	int copylen =3D 0;
>  	bool zerocopy =3D false;
>  	size_t linear;
> +	ssize_t n;
> =20
>  	if (q->flags & IFF_VNET_HDR) {
>  		vnet_hdr_len =3D q->vnet_hdr_sz;
> @@ -662,10 +663,11 @@ static ssize_t macvtap_get_user(struct macvtap_queu=
e *q, struct msghdr *m,
>  			goto err;
>  		len -=3D vnet_hdr_len;
> =20
> -		err =3D memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
> -					   sizeof(vnet_hdr));
> -		if (err < 0)
> +		err =3D -EFAULT;
> +		n =3D copy_from_iter(&vnet_hdr, sizeof(vnet_hdr), from);
> +		if (n !=3D sizeof(vnet_hdr))
>  			goto err;
> +		iov_iter_advance(from, vnet_hdr_len - sizeof(vnet_hdr));
>  		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
>  		     vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
>  							vnet_hdr.hdr_len)
> @@ -680,17 +682,15 @@ static ssize_t macvtap_get_user(struct macvtap_queu=
e *q, struct msghdr *m,
>  	if (unlikely(len < ETH_HLEN))
>  		goto err;
> =20
> -	err =3D -EMSGSIZE;
> -	if (unlikely(count > UIO_MAXIOV))
> -		goto err;
> -
>  	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
> +		struct iov_iter i;

Blank line needed after a declaration.

>  		copylen =3D vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
>  		if (copylen > good_linear)
>  			copylen =3D good_linear;
>  		linear =3D copylen;
> -		if (iov_pages(iv, vnet_hdr_len + copylen, count)
> -		    <=3D MAX_SKB_FRAGS)
> +		i =3D *from;
> +		iov_iter_advance(&i, copylen);
> +		if (iov_iter_npages(&i, INT_MAX) <=3D MAX_SKB_FRAGS)

The maxpages argument should be MAX_SKB_FRAGS + 1 as we don't need the
exact number.

>  			zerocopy =3D true;
>  	}
> =20
> @@ -708,10 +708,9 @@ static ssize_t macvtap_get_user(struct macvtap_queue=
 *q, struct msghdr *m,
>  		goto err;
> =20
>  	if (zerocopy)
> -		err =3D zerocopy_sg_from_iovec(skb, iv, vnet_hdr_len, count);
> +		err =3D zerocopy_sg_from_iter(skb, from);
>  	else {
> -		err =3D skb_copy_datagram_from_iovec(skb, 0, iv, vnet_hdr_len,
> -						   len);
> +		err =3D skb_copy_datagram_from_iter(skb, 0, from, len);

Does skb_copy_datagram_from_iter() really need a len parameter?  Here it
is equal to iov_iter_count(from).

[...]
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1012,28 +1012,29 @@ static struct sk_buff *tun_alloc_skb(struct tun_f=
ile *tfile,
> =20
>  /* Get packet from user space buffer */
>  static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfi=
le,
> -			    void *msg_control, const struct iovec *iv,
> -			    size_t total_len, size_t count, int noblock)
> +			    void *msg_control, struct iov_iter *from,
> +			    int noblock)
>  {
>  	struct tun_pi pi =3D { 0, cpu_to_be16(ETH_P_IP) };
>  	struct sk_buff *skb;
> +	size_t total_len =3D iov_iter_count(from);
>  	size_t len =3D total_len, align =3D NET_SKB_PAD, linear;
>  	struct virtio_net_hdr gso =3D { 0 };
>  	int good_linear;
> -	int offset =3D 0;
>  	int copylen;
>  	bool zerocopy =3D false;
>  	int err;
>  	u32 rxhash;
> +	ssize_t n;
> =20
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if (len < sizeof(pi))
>  			return -EINVAL;
>  		len -=3D sizeof(pi);
> =20
> -		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
> +		n =3D copy_from_iter(&pi, sizeof(pi), from);
> +		if (n !=3D sizeof(pi))
>  			return -EFAULT;
> -		offset +=3D sizeof(pi);
>  	}
> =20
>  	if (tun->flags & TUN_VNET_HDR) {
> @@ -1041,7 +1042,8 @@ static ssize_t tun_get_user(struct tun_struct *tun,=
 struct tun_file *tfile,
>  			return -EINVAL;
>  		len -=3D tun->vnet_hdr_sz;
> =20
> -		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
> +		n =3D copy_from_iter(&gso, sizeof(gso), from);
> +		if (n !=3D sizeof(gso))
>  			return -EFAULT;
> =20
>  		if ((gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
> @@ -1050,7 +1052,7 @@ static ssize_t tun_get_user(struct tun_struct *tun,=
 struct tun_file *tfile,
> =20
>  		if (gso.hdr_len > len)
>  			return -EINVAL;
> -		offset +=3D tun->vnet_hdr_sz;
> +		iov_iter_advance(from, tun->vnet_hdr_sz);

                                        tun->vnet_hdr_sz - sizeof(gso)

>  	}
> =20
>  	if ((tun->flags & TUN_TYPE_MASK) =3D=3D TUN_TAP_DEV) {
> @@ -1063,6 +1065,7 @@ static ssize_t tun_get_user(struct tun_struct *tun,=
 struct tun_file *tfile,
>  	good_linear =3D SKB_MAX_HEAD(align);
> =20
>  	if (msg_control) {
> +		struct iov_iter i =3D *from;

Blank line needed after a declaration.

>  		/* There are 256 bytes to be copied in skb, so there is
>  		 * enough room for skb expand head in case it is used.
>  		 * The rest of the buffer is mapped from userspace.
> @@ -1071,7 +1074,8 @@ static ssize_t tun_get_user(struct tun_struct *tun,=
 struct tun_file *tfile,
>  		if (copylen > good_linear)
>  			copylen =3D good_linear;
>  		linear =3D copylen;
> -		if (iov_pages(iv, offset + copylen, count) <=3D MAX_SKB_FRAGS)
> +		iov_iter_advance(&i, copylen);
> +		if (iov_iter_npages(&i, INT_MAX) <=3D MAX_SKB_FRAGS)

Again, the maxpages argument should be MAX_SKB_FRAGS + 1.

>  			zerocopy =3D true;
>  	}
> =20
> @@ -1091,9 +1095,9 @@ static ssize_t tun_get_user(struct tun_struct *tun,=
 struct tun_file *tfile,
>  	}
> =20
>  	if (zerocopy)
> -		err =3D zerocopy_sg_from_iovec(skb, iv, offset, count);
> +		err =3D zerocopy_sg_from_iter(skb, from);
>  	else {
> -		err =3D skb_copy_datagram_from_iovec(skb, 0, iv, offset, len);
> +		err =3D skb_copy_datagram_from_iter(skb, 0, from, len);
[...]

Again len is equal to iov_iter_count(from), so I think that parameter is
redundant.

Ben.

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-3S4thgiAxKwRXEPZti8u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHJ7iOe/yOyVhhEJAQpJiBAAqqsjhOxOtECnydy4DSWpXI4qkSQljs+I
791mFMnCHrKCLz8el8+xXyf+5PPzTt7aeHYz7u1HlmLUdhhyXMobgwQeFCX5n3fU
n0+HXdkHw3rNeI/M4dhbbP2p/3nOuLNPY3z/v5yrU1vejkcUCvfFJg144Z5UerqM
e71bmwGDtKd7gSQ0d6EgjLlftqZuDBSlNqsh+YS/rdC+b9gKIGjGPExoywSDDYrZ
T6qWbPe51n3WhWVolA7uzujz/sLTAxfMmySiFIYCRl29J+z7i/vGtIooMxiyMXBa
hBzHE6KRjunjAWSJLijrQq00tbV6Zfp/OKQGyVK+Ty9QyYkiJDWCKAcTG/ahyi90
deASFyVT9pUU9Yz2bAKj14Db0gRR8ZDrvWumz9DnY9dTkZlXJl6Js+j0j+E0h86I
VsAVuEJQ2qyasLmlXh6ipyz1MCqOm6AJ7m9gr2pZW7+YyPPd5WDwxfJm3hxWjRvv
7Z4KIBzRic9QeWUFQBfLYk/63uBloN86Cf+C8KKrf+OsyOnUeuKltOE7Yh6NoI5u
2PyTgv/RVIyM4CPnM4ExQV//UI+Pz18LwpW4jvhFo82xQ6rYKzRB556IWghrRaRt
WR4HRMDIyleV8tHTbxRhVKsfiYK+bLzWB16PYSbIJQSelTZqlLxD7vhmRgPLxFWK
UwicYVPgG7I=
=oG+G
-----END PGP SIGNATURE-----

--=-3S4thgiAxKwRXEPZti8u--
