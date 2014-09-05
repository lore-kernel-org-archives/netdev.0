From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 3/3] ixgbe: use new eth_get_headlen interface
Date: Fri, 05 Sep 2014 16:35:12 -0700
Message-ID: <1409960112.2460.38.camel@jtkirshe-mobl>
References: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
	 <20140905232053.2035.65715.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PwEowLDYDJdOdF8QmJY/"
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1800 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbaIEXfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:35:13 -0400
In-Reply-To: <20140905232053.2035.65715.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PwEowLDYDJdOdF8QmJY/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-09-05 at 19:22 -0400, Alexander Duyck wrote:
> Update ixgbe to drop the ixgbe_get_headlen function in favor of eth_get_h=
eadlen.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  116 -------------------=
------
>  1 file changed, 1 insertion(+), 115 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/=
ethernet/intel/ixgbe/ixgbe_main.c
> index 53fbf06..09c3746 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1521,120 +1521,6 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx=
_ring, u16 cleaned_count)
>  		ixgbe_release_rx_desc(rx_ring, i);
>  }
> =20
> -/**
> - * ixgbe_get_headlen - determine size of header for RSC/LRO/GRO/FCOE
> - * @data: pointer to the start of the headers
> - * @max_len: total length of section to find headers in
> - *
> - * This function is meant to determine the length of headers that will
> - * be recognized by hardware for LRO, GRO, and RSC offloads.  The main
> - * motivation of doing this is to only perform one pull for IPv4 TCP
> - * packets so that we can do basic things like calculating the gso_size
> - * based on the average data per packet.
> - **/
> -static unsigned int ixgbe_get_headlen(unsigned char *data,
> -				      unsigned int max_len)
> -{
> -	union {
> -		unsigned char *network;
> -		/* l2 headers */
> -		struct ethhdr *eth;
> -		struct vlan_hdr *vlan;
> -		/* l3 headers */
> -		struct iphdr *ipv4;
> -		struct ipv6hdr *ipv6;
> -	} hdr;
> -	__be16 protocol;
> -	u8 nexthdr =3D 0;	/* default to not TCP */
> -	u8 hlen;
> -
> -	/* this should never happen, but better safe than sorry */
> -	if (max_len < ETH_HLEN)
> -		return max_len;
> -
> -	/* initialize network frame pointer */
> -	hdr.network =3D data;
> -
> -	/* set first protocol and move network header forward */
> -	protocol =3D hdr.eth->h_proto;
> -	hdr.network +=3D ETH_HLEN;
> -
> -	/* handle any vlan tag if present */
> -	if (protocol =3D=3D htons(ETH_P_8021Q)) {
> -		if ((hdr.network - data) > (max_len - VLAN_HLEN))
> -			return max_len;
> -
> -		protocol =3D hdr.vlan->h_vlan_encapsulated_proto;
> -		hdr.network +=3D VLAN_HLEN;
> -	}
> -
> -	/* handle L3 protocols */
> -	if (protocol =3D=3D htons(ETH_P_IP)) {
> -		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
> -			return max_len;
> -
> -		/* access ihl as a u8 to avoid unaligned access on ia64 */
> -		hlen =3D (hdr.network[0] & 0x0F) << 2;
> -
> -		/* verify hlen meets minimum size requirements */
> -		if (hlen < sizeof(struct iphdr))
> -			return hdr.network - data;
> -
> -		/* record next protocol if header is present */
> -		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
> -			nexthdr =3D hdr.ipv4->protocol;
> -	} else if (protocol =3D=3D htons(ETH_P_IPV6)) {
> -		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
> -			return max_len;
> -
> -		/* record next protocol */
> -		nexthdr =3D hdr.ipv6->nexthdr;
> -		hlen =3D sizeof(struct ipv6hdr);
> -#ifdef IXGBE_FCOE
> -	} else if (protocol =3D=3D htons(ETH_P_FCOE)) {
> -		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
> -			return max_len;
> -		hlen =3D FCOE_HEADER_LEN;
> -#endif
> -	} else {
> -		return hdr.network - data;
> -	}
> -
> -	/* relocate pointer to start of L4 header */
> -	hdr.network +=3D hlen;
> -
> -	/* finally sort out TCP/UDP */
> -	if (nexthdr =3D=3D IPPROTO_TCP) {
> -		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
> -			return max_len;
> -
> -		/* access doff as a u8 to avoid unaligned access on ia64 */
> -		hlen =3D (hdr.network[12] & 0xF0) >> 2;
> -
> -		/* verify hlen meets minimum size requirements */
> -		if (hlen < sizeof(struct tcphdr))
> -			return hdr.network - data;
> -
> -		hdr.network +=3D hlen;
> -	} else if (nexthdr =3D=3D IPPROTO_UDP) {
> -		if ((hdr.network - data) > (max_len - sizeof(struct udphdr)))
> -			return max_len;
> -
> -		hdr.network +=3D sizeof(struct udphdr);
> -	}
> -
> -	/*
> -	 * If everything has gone correctly hdr.network should be the
> -	 * data section of the packet and will be the end of the header.
> -	 * If not then it probably represents the end of the last recognized
> -	 * header.
> -	 */
> -	if ((hdr.network - data) < max_len)
> -		return hdr.network - data;
> -	else
> -		return max_len;
> -}
> -
>  static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
>  				   struct sk_buff *skb)
>  {
> @@ -1793,7 +1679,7 @@ static void ixgbe_pull_tail(struct ixgbe_ring *rx_r=
ing,
>  	 * we need the header to contain the greater of either ETH_HLEN or
>  	 * 60 bytes if the skb->len is less than 60 for skb_pad.
>  	 */
> -	pull_len =3D ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
> +	pull_len =3D eth_get_headlen(va, IXGBE_RX_HDR_SIZE);
> =20
>  	/* align pull length to size of long to optimize memcpy performance */
>  	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>=20



--=-PwEowLDYDJdOdF8QmJY/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUCkiwAAoJEOVv75VaS+3O0JkP/ifaTm1s5US1E0gqUdAsdpDP
9LSMt1lMykeV8J/Y5oo+v+NWajrYZGOot5fFUfZ4vL3s5HKE7VQAujPFVe+8xy4w
3pVtmShnROeNvdeB9MI3qGBlzAC4+TVbu5T6ICPlndjRgYDtydMSknCFjGMQ1ska
5WBf24mfEmfAB1gqROmkK0p3pu9RzS+Xlq98huYhmc247x6ofvS9jrQf+U3gFIt8
Tszye6gFSf7EDhGNy7yp7cjHpYqkP5pIJCUzqopZ/OYai9NK6VOeThFKI9EB+jIa
TQnGOp8Ad+/9rpgR17qVirgQnFkyk+SjgMCBtel8C3ZZubskqGfzMaJG1JH3MmTn
6qsUPqVxgtCIAhwQsSajT35opOp3CCl03z7/lEMLXVlsIy7uPmR4syBWt2jouMbg
IIlev8XgKM998/DpIJUAAxaIb1pnlJCG1d0putYRv9XB4+Sj/lbY1KjGNKOip4iT
JV+c8Xa0qV1APgcgD7QktnCBMGYZkmZ77SlaBejbAvDqGF74rE4GGXBNfPVIB8DX
t66NbJxv4xyUeM4RTu6eRb0fh3aT83hJPtclZQ7XlWYjdeKDm1asXaQ6HG0wAPUb
esWT8cD9fWqYWaGjva9zoYlAHZtGqh03Fq0VP/4lO3EzkzlkblENR5ldApvd1dRy
g8dmRbHWV1o1gPlGk506
=AICu
-----END PGP SIGNATURE-----

--=-PwEowLDYDJdOdF8QmJY/--
