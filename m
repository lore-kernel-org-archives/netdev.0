From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next] ipv6: sr: static percpu allocation for hmac_ring
Date: Thu, 12 Jan 2017 21:10:00 +0100
Message-ID: <5877E298.2010806@uclouvain.be>
References: <1484239810.15816.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="LPfukhKGx75nmFQRVacEwkOMNf9iEi0qr"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33192 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdALUJN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:09:13 -0500
In-Reply-To: <1484239810.15816.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--LPfukhKGx75nmFQRVacEwkOMNf9iEi0qr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/12/2017 05:50 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>=20
> Current allocations are not NUMA aware, and lack proper
> cleanup in case of error.
>=20
> It is perfectly fine to use static per cpu allocations for 256 bytes
> per cpu.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Lebrun <david.lebrun@uclouvain.be>
> ---
>  net/ipv6/seg6_hmac.c |   43 ++---------------------------------------
>  1 file changed, 3 insertions(+), 40 deletions(-)
>=20
> diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
> index ef1c8a46e7aceee45b2044d4b4338dc3aed88807..6389bf3e9c9f28cdd3e3017=
5f2880b74e099e273 100644
> --- a/net/ipv6/seg6_hmac.c
> +++ b/net/ipv6/seg6_hmac.c
> @@ -45,7 +45,7 @@
>  #include <net/seg6_hmac.h>
>  #include <linux/random.h>
> =20
> -static char * __percpu *hmac_ring;
> +static DEFINE_PER_CPU(char [SEG6_HMAC_RING_SIZE], hmac_ring);
> =20
>  static int seg6_hmac_cmpfn(struct rhashtable_compare_arg *arg, const v=
oid *obj)
>  {
> @@ -192,7 +192,7 @@ int seg6_hmac_compute(struct seg6_hmac_info *hinfo,=
 struct ipv6_sr_hdr *hdr,
>  	 */
> =20
>  	local_bh_disable();
> -	ring =3D *this_cpu_ptr(hmac_ring);
> +	ring =3D this_cpu_ptr(hmac_ring);
>  	off =3D ring;
> =20
>  	/* source address */
> @@ -353,27 +353,6 @@ int seg6_push_hmac(struct net *net, struct in6_add=
r *saddr,
>  }
>  EXPORT_SYMBOL(seg6_push_hmac);
> =20
> -static int seg6_hmac_init_ring(void)
> -{
> -	int i;
> -
> -	hmac_ring =3D alloc_percpu(char *);
> -
> -	if (!hmac_ring)
> -		return -ENOMEM;
> -
> -	for_each_possible_cpu(i) {
> -		char *ring =3D kzalloc(SEG6_HMAC_RING_SIZE, GFP_KERNEL);
> -
> -		if (!ring)
> -			return -ENOMEM;
> -
> -		*per_cpu_ptr(hmac_ring, i) =3D ring;
> -	}
> -
> -	return 0;
> -}
> -
>  static int seg6_hmac_init_algo(void)
>  {
>  	struct seg6_hmac_algo *algo;
> @@ -422,16 +401,7 @@ static int seg6_hmac_init_algo(void)
> =20
>  int __init seg6_hmac_init(void)
>  {
> -	int ret;
> -
> -	ret =3D seg6_hmac_init_ring();
> -	if (ret < 0)
> -		goto out;
> -
> -	ret =3D seg6_hmac_init_algo();
> -
> -out:
> -	return ret;
> +	return seg6_hmac_init_algo();
>  }
>  EXPORT_SYMBOL(seg6_hmac_init);
> =20
> @@ -450,13 +420,6 @@ void seg6_hmac_exit(void)
>  	struct seg6_hmac_algo *algo =3D NULL;
>  	int i, alg_count, cpu;
> =20
> -	for_each_possible_cpu(i) {
> -		char *ring =3D *per_cpu_ptr(hmac_ring, i);
> -
> -		kfree(ring);
> -	}
> -	free_percpu(hmac_ring);
> -
>  	alg_count =3D sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
>  	for (i =3D 0; i < alg_count; i++) {
>  		algo =3D &hmac_algos[i];
>=20
>=20

Acked-by: David Lebrun <david.lebrun@uclouvain.be>


--LPfukhKGx75nmFQRVacEwkOMNf9iEi0qr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlh34psACgkQjbzn67sZ6AMqYwCfenHRf1K4GIZN0fJ9JIVMA8Rw
3CIAn1SOCsFceWcrh5N9cUzGrFzHc3O2
=tcSZ
-----END PGP SIGNATURE-----

--LPfukhKGx75nmFQRVacEwkOMNf9iEi0qr--
