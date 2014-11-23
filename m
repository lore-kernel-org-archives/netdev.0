From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 06/17] switch macvtap to ->read_iter()
Date: Sun, 23 Nov 2014 23:29:50 +0000
Message-ID: <1416785390.7215.61.camel@decadent.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <20141120.182339.972861702759954603.davem@davemloft.net>
	 <20141121.122615.1091044030302005883.davem@davemloft.net>
	 <20141122042856.GZ7996@ZenIV.linux.org.uk>
	 <20141122043230.GF30478@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8IN9vrfdcFEDwDBwMRje"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141122043230.GF30478@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-8IN9vrfdcFEDwDBwMRje
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-11-22 at 04:32 +0000, Al Viro wrote:
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  drivers/net/macvtap.c |   39 ++++++++++++++++-----------------------
>  1 file changed, 16 insertions(+), 23 deletions(-)
>=20
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index cea99d4..cdd820f 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -829,16 +829,17 @@ done:
>  }
> =20
>  static ssize_t macvtap_do_read(struct macvtap_queue *q,
> -			       const struct iovec *iv, unsigned long segs,
> -			       unsigned long len,
> +			       struct iov_iter *to,
>  			       int noblock)
>  {
>  	DEFINE_WAIT(wait);
>  	struct sk_buff *skb;
>  	ssize_t ret =3D 0;
> -	struct iov_iter iter;
> =20
> -	while (len) {
> +	if (!iov_iter_count(to))
> +		return 0;
> +
> +	while (1) {
>  		if (!noblock)
>  			prepare_to_wait(sk_sleep(&q->sk), &wait,
>  					TASK_INTERRUPTIBLE);
> @@ -856,37 +857,27 @@ static ssize_t macvtap_do_read(struct macvtap_queue=
 *q,
>  			}
>  			/* Nothing to read, let's sleep */
>  			schedule();
> -			continue;
>  		}
> -		iov_iter_init(&iter, READ, iv, segs, len);
> -		ret =3D macvtap_put_user(q, skb, &iter);
> +	}
> +	if (skb) {
> +		ret =3D macvtap_put_user(q, skb, to);
>  		kfree_skb(skb);
> -		break;
[...]

You need to leave this break at the bottom of the loop body, or change
it to:

	do {
		...
	} while (!skb);

Ben.

--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.

--=-8IN9vrfdcFEDwDBwMRje
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHJt8+e/yOyVhhEJAQpr6RAAh1Jug0kP//dh4IOWq7c7Dw8faw0bc51z
XSQBvrg7bUU/9ETjrW6Dcpoyp2ZyIF8GFGjknDbddXRYg5+hRUD29pLF1cs0f6MB
O/L7uhArjhGRyJd3TR3wsxkw9pbzuBgtJQfo+JOxWUB3kXLa992A641p4JX/5eSF
VUmI6tZoLwEIgsJ4D1MehFiSdzQraM6cZCaci91iSzVr9zjB5MVRt2kYjcFo5oEY
lbeGktE/G60+q6LPB4VlLceVHASNlE8syaZC8cQ2PAEyRVn7D7tiz5f9kJt2twJ8
ZhdMfOPZBpPlCCGvor0dy062kqGa2OMaI1Cl/UetjdwZcciq8yhvDm1ZvSCvzZUh
UcejycyxrAJoftL8yEyzPOWM5frNFV2IdbL+Mu9yftKEytVnMTHNParWloh5Z+w1
/4Jq1HSZaSQPLajbOwsm1imASMxne5rMDrDXqtjwHa+5FHw26k4SIsqydj8ALrfx
3iI/KPPNtyklFfYxBNFVYBsXsr/A9JaN65Iiv5Jw5Cj6W8XV9wkp7svB8dpqGUCn
HZnsgRFEDpwFdSbquO+qIrYS14xm/VqmBlzSjcIMS7NvNiii8jqpv4qQ4K7Hysay
TTPY6tdGb+wBqnxQElRIg5dMZM1eToyVFw5Hn4qXzfz6w1EzeLF0SWV9pu3nYMxt
yesY7BmZMos=
=Memq
-----END PGP SIGNATURE-----

--=-8IN9vrfdcFEDwDBwMRje--
