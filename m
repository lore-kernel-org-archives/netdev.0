From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ioc3: fix incorrect use of htons/ntohs
Date: Mon, 01 Dec 2014 04:09:36 +0000
Message-ID: <1417406976.7215.126.camel@decadent.org.uk>
References: <1417344054-4374-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-UGX2vLT14XDID0ifDBcC"
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417344054-4374-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UGX2vLT14XDID0ifDBcC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-11-30 at 11:40 +0100, Lino Sanfilippo wrote:
> The protocol type in the ip header struct is a single byte variable. So t=
here
> is no need to swap bytes depending on host endianness.
>=20
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> ---
>=20
> Please note that I could not test this, since I dont have access to the
> concerning hardware.
>=20
>  drivers/net/ethernet/sgi/ioc3-eth.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/s=
gi/ioc3-eth.c
> index 7a254da..0bb303d 100644
> --- a/drivers/net/ethernet/sgi/ioc3-eth.c
> +++ b/drivers/net/ethernet/sgi/ioc3-eth.c
> @@ -540,8 +540,7 @@ static void ioc3_tcpudp_checksum(struct sk_buff *skb,=
 uint32_t hwsum, int len)
> =20
>  	/* Same as tx - compute csum of pseudo header  */
>  	csum =3D hwsum +
> -	       (ih->tot_len - (ih->ihl << 2)) +
> -	       htons((uint16_t)ih->protocol) +
> +	       (ih->tot_len - (ih->ihl << 2)) + ih->protocol +
>  	       (ih->saddr >> 16) + (ih->saddr & 0xffff) +
>  	       (ih->daddr >> 16) + (ih->daddr & 0xffff);
>

The pseudo-header is specified as:

                     +--------+--------+--------+--------+
                     |           Source Address          |
                     +--------+--------+--------+--------+
                     |         Destination Address       |
                     +--------+--------+--------+--------+
                     |  zero  |  PTCL  |    TCP Length   |
                     +--------+--------+--------+--------+

The current code zero-extends the protocol number to produce the 5th
16-bit word of the pseudo-header, then uses htons() to put it in
big-endian order, consistent with the other fields.  (Yes, it's doing
addition on big-endian words; this works even on little-endian machines
due to the way the checksum is specified.)

The driver should not be doing this at all, though.  It should set
skb->csum =3D hwsum; skb->ip_summed =3D CHECKSUM_COMPLETE; and let the
network stack adjust the hardware checksum.

> @@ -1417,7 +1416,7 @@ static int ioc3_start_xmit(struct sk_buff *skb, str=
uct net_device *dev)
>  	 */
>  	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
>  		const struct iphdr *ih =3D ip_hdr(skb);
> -		const int proto =3D ntohs(ih->protocol);
> +		const int proto =3D ih->protocol;
>  		unsigned int csoff;
>  		uint32_t csum, ehsum;
>  		uint16_t *eh;

This should logically be __be16 proto =3D htons(ih->protocol), but the
current version should work in practice.

However, the driver should really use skb->csum_start and
skb->csum_offset to work out where the checksum belongs and which bytes
to cancel out.

Ben.

--=20
Ben Hutchings
The first rule of tautology club is the first rule of tautology club.

--=-UGX2vLT14XDID0ifDBcC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHvqBee/yOyVhhEJAQq7CBAAxe1OoSuOlTy6Asn0VtQjYwo1jRxplsw1
gEvf4s8Ggh2BTiAs0wNltIX/xvdb2XzMW2u6J3BuHJeaCMl29jo+9y60g3ArhhLF
szj/QzEq3+tPZm97K8ZoEZKcYKILseUz/1Bv4+Uf4u0QnNpcVwINdmp1x5QGKHPX
MWNFWsxulR5aTvX78ytFmb7VHEyXtHZQUsHLaye/1fsn4YChTNvb+GkIE7dvm5N+
/HjEgjtg3XhRVBiZPhQQfGBa+hqYjf0FE9Ey869XTXenNGP9AYbwTZqW9D1qKNWS
1XZxtHcn1ciERL8tPChDXymMMHmn/kOKRP+LnoZJPx4avd5yfMW9jJSxfrfEbXVS
BLKCStrFxQvSJcco+pPnYtmgOGlKTVH270TnfJ/VjjNem1x/5HhxJfUHAk3zQRHy
F2VDndqmamW8Eqk3XGEQuDApGaUnzA1SEtlf1g9nshKFf5Cvi3GLlUHvb/U8aJ2z
4dM1qL7qDz9RZcIjwJzA7pCPX/o9oSJIT4rXaG57rYR+58mENrDJNnHghBVIymIU
o6THjUf4g1raDU6Hf7WhK/ktcgjDTRICGdVBS8XPeccp6YfZd2ENm4TxbUJWhZUu
4jFe2oIYBpZgwoMP8BFMNFksGX1RaigLAveaQuFcKunA6qM7mz+gMY9CRjDX+oam
x9btSGEYL+c=
=Q8ry
-----END PGP SIGNATURE-----

--=-UGX2vLT14XDID0ifDBcC--
