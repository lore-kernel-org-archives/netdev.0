From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 2/3] igb: use new eth_get_headlen interface
Date: Fri, 05 Sep 2014 16:34:24 -0700
Message-ID: <1409960064.2460.37.camel@jtkirshe-mobl>
References: <20140905231807.2035.33588.stgit@ahduyck-bv4.jf.intel.com>
	 <20140905232031.2035.70831.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DoCTx/e5WNUOVXS4q81T"
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:15376 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbaIEXe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:34:26 -0400
In-Reply-To: <20140905232031.2035.70831.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DoCTx/e5WNUOVXS4q81T
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-09-05 at 19:20 -0400, Alexander Duyck wrote:
> Update igb to drop the igb_get_headlen function in favor of eth_get_headl=
en.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by:  Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |  109 -----------------------=
------
>  1 file changed, 1 insertion(+), 108 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethe=
rnet/intel/igb/igb_main.c
> index 89de7fe..4c023f0 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -6769,113 +6769,6 @@ static bool igb_is_non_eop(struct igb_ring *rx_ri=
ng,
>  }
> =20
>  /**
> - *  igb_get_headlen - determine size of header for LRO/GRO
> - *  @data: pointer to the start of the headers
> - *  @max_len: total length of section to find headers in
> - *
> - *  This function is meant to determine the length of headers that will
> - *  be recognized by hardware for LRO, and GRO offloads.  The main
> - *  motivation of doing this is to only perform one pull for IPv4 TCP
> - *  packets so that we can do basic things like calculating the gso_size
> - *  based on the average data per packet.
> - **/
> -static unsigned int igb_get_headlen(unsigned char *data,
> -				    unsigned int max_len)
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
> -	} else {
> -		return hdr.network - data;
> -	}
> -
> -	/* relocate pointer to start of L4 header */
> -	hdr.network +=3D hlen;
> -
> -	/* finally sort out TCP */
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
> -	/* If everything has gone correctly hdr.network should be the
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
> -/**
>   *  igb_pull_tail - igb specific version of skb_pull_tail
>   *  @rx_ring: rx descriptor ring packet is being transacted on
>   *  @rx_desc: pointer to the EOP Rx descriptor
> @@ -6919,7 +6812,7 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
>  	/* we need the header to contain the greater of either ETH_HLEN or
>  	 * 60 bytes if the skb->len is less than 60 for skb_pad.
>  	 */
> -	pull_len =3D igb_get_headlen(va, IGB_RX_HDR_LEN);
> +	pull_len =3D eth_get_headlen(va, IGB_RX_HDR_LEN);
> =20
>  	/* align pull length to size of long to optimize memcpy performance */
>  	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>=20



--=-DoCTx/e5WNUOVXS4q81T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUCkiAAAoJEOVv75VaS+3OgUMP/1EpSdUkYkdWrUEpTwt/hdyQ
jW13XJeF7g3zsDDByZ8y4KhqLHDw4wLIqVIrq+KFTv1B+u4PEl5NWErRqF4Ki/eE
k+DrxQ1tkCjjEGQJCzyX5rmQ6XWNv6I10NX6W3F4wktRWhuzxUv1TfCK3uNtPalB
aJtQ+JJ/l9F1reup4tQKxErGapj/QFX2ZmpFh/GvRdNE59utQjggXlF0qlipoY+/
+C3DLWyHTIp/mQL6mr1mydCvG6zAF8AAvyhdmsDC1rK35oqTbOSinwxfb1RvnOdW
zdEd8pA3KC3r3Tf0zHNmEYO6DufNLBRIiva40+lggO9GTkqcQRUnE/uO2E2OvOZm
ZvHs/qLZfdhSYkKEH4YOFHyqmQ3xnECDZcu1cdLY+fWAuqULRsCU1+IkbNLDBy5f
/nktCBLvV7GPgckwcv9iGAKVX2EfvWl26JDVW12yX2LMdXnDval12kfjfHgKvK6e
RQ5/jABECd2BkAdxZo7BIcBB6ozDJCYQf/2F4FuPL7iAVPtelx88QgkBusbHCO5Z
Dn6ANYFH1al0aIT+jt2rH04TzX9vMSASfrKl9BS1Fx0fHGkPldoGrVtPgSpP1xt9
34l6RqsC2x9SFAArBFLW0biwoCPHvhE5msfFpp/QIQSX9U0jd2NsJ2F5eePJzDsJ
mvy0DYldDwWoLvamQlOB
=hxRe
-----END PGP SIGNATURE-----

--=-DoCTx/e5WNUOVXS4q81T--
