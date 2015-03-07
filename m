From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: IPv6 GRE sending to undefined destinations
Date: Sat, 07 Mar 2015 17:51:51 +0000
Message-ID: <1425750711.4027.12.camel@decadent.org.uk>
References: <54F9D70C.7030409@baanhofman.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OUHe12KAR/WI4NDEkjIl"
Cc: netdev@vger.kernel.org
To: Wilco Baan Hofman <wilco@baanhofman.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53522 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbbCGRwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 12:52:03 -0500
In-Reply-To: <54F9D70C.7030409@baanhofman.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OUHe12KAR/WI4NDEkjIl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-06 at 17:34 +0100, Wilco Baan Hofman wrote:
> Hi,
>=20
> When using the netlink sendmsg api to pass sockaddr_ll to an IPv6 GRE
> interface, strange things happen.
>=20
> For one, an IPv6 address does not fit into sockaddr_ll.ssl_addr (8 bytes)=
.
> Writing 8 0xff bytes into this field causes it to send the packet, but
> it also leaks 8 bytes of kernel memory into the packet going out of the
> interface.

Oops, that should be fixed first.

> Now, I have a use case for using this, that is to implement DMVPN/NHRP
> over IPv6 GRE, with OpenNHRP for which I need to have a multipoint GRE
> connection. With IPv4 this was already implemented with the sll
> interface, changing the sll_addr changes the destination of the packet
> header.
>=20
> With the following patch I am able to make it work, but I'm not sure
> about the implications of changing the size of the sll_addr buffer.

We can't do that as it will break binary compatibility with existing
applications.  It sounds like there is a need for a new, larger
structure but I don't know all the compatibility implications of that.

Ben.

> -- Wilco Baan Hofman
>=20
>=20
>=20
> From 9cebcdd74cdbdeda0159aebfb5e64d9b8efc4006 Mon Sep 17 00:00:00 2001
> From: Wilco Baan Hofman <wilco@baanhofman.nl>
> Date: Fri, 6 Mar 2015 17:25:05 +0100
> Subject: [PATCH] Fix ip6_gre sending packets to undefined destinations.
>=20
> ---
>  include/uapi/linux/if_packet.h | 2 +-
>  net/ipv6/ip6_gre.c             | 8 ++++++++
>  2 files changed, 9 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packe=
t.h
> index da2d668..415cbc4 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -16,7 +16,7 @@ struct sockaddr_ll {
>      unsigned short    sll_hatype;
>      unsigned char    sll_pkttype;
>      unsigned char    sll_halen;
> -    unsigned char    sll_addr[8];
> +    unsigned char    sll_addr[16];
>  };
> =20
>  /* Packet types */
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index bc28b7d..c9aee7d 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -1205,8 +1205,16 @@ static int ip6gre_header(struct sk_buff *skb,
> struct net_device *dev,
>      return -t->hlen;
>  }
> =20
> +static int ip6gre_header_parse(const struct sk_buff *skb, unsigned char
> *haddr)
> +{
> +    const struct ipv6hdr *ipv6h =3D (const struct ipv6hdr
> *)skb_mac_header(skb);
> +    memcpy(haddr, &ipv6h->saddr, sizeof(struct in6_addr));
> +    return sizeof(struct in6_addr);
> +}
> +
>  static const struct header_ops ip6gre_header_ops =3D {
>      .create    =3D ip6gre_header,
> +    .parse    =3D ip6gre_header_parse,
>  };
> =20
>  static const struct net_device_ops ip6gre_netdev_ops =3D {

--=20
Ben Hutchings
For every action, there is an equal and opposite criticism. - Harrison

--=-OUHe12KAR/WI4NDEkjIl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVPs6u+e/yOyVhhEJAQoicxAAtQ/3GjDn50pk597k3V5dj5YaSA6PGlCZ
TUxqgQevjGf+s3+Hv/UDyJRhpd5dkp7kSWm4XKh6DqleGmqP3LCAsg77S3OZZoDa
agOi4S1Qzbsv1pXlTG/Z5H1/G/6gIN+RcbYXviVUVxpJl7hh9Dp1nURvqPugBYRz
z0aU+DSubvnEdas5iJZbXUYhYyTol9Qfl3JMSGaX8UKYP7EhDXC/mn2PEVZ4KxdY
YPN4BPYh3OZbjoYucVI6QOHy111UCwZqa3chwGwl/KNeQw5CxPiyIerNM50WXdSH
Xl2y67enNpTQFIVHTPBJFvfVVpYSnGxHltNxE81DJPqYafwdWce0vP6CFyf1ZLwp
FSagWQwCLYNBG6lPyOGFHA59lRba962YvjmZdrsIFYSB7hylujFO0QSPmZgU7/bx
jAEHRthVCqwunIqa9EPEoqZMb44OvtHkZidRxFueHZ3eEZBITC+bt8LmVfpDIcCz
VIcyx98MOvG1biAY8xEDD3CQh+ObkYZ82sb6JWvhS3vPcA/h3gUK0w1sy7z2E15q
ty7Ae8zzg44eqhnmK01BKpC+We/dsxJ3VRfMPSqb1Gyudgvf/vvAoYYewv1YuRuv
SIuPXpnjPfhXs9g4rw1WBAMd6zZcDgoO3v94g28ItwJ4+dD+Nal1wag/JJnQ47Nk
Sg2YETIFb38=
=EPvw
-----END PGP SIGNATURE-----

--=-OUHe12KAR/WI4NDEkjIl--
