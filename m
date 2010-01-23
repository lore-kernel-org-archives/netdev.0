From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Sat, 23 Jan 2010 15:29:40 +0000
Message-ID: <1264260580.373.77.camel@localhost>
References: <CDAFEDABF718A54BABD0DA5476695307443F1E8D@SHEXMB-01.global.atheros.com>
	 <20100120.102704.295948365864962720.anders@netinsight.net>
	 <CDAFEDABF718A54BABD0DA5476695307455062E7@SHEXMB-01.global.atheros.com>
	 <20100121.174247.769487074466946522.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-bCg7B8Yy9SXTnyrfOHb5"
Cc: Jie.Yang@Atheros.com, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Anders =?ISO-8859-1?Q?Bostr=F6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39664 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755839Ab0AWP3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 10:29:46 -0500
In-Reply-To: <20100121.174247.769487074466946522.anders@netinsight.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bCg7B8Yy9SXTnyrfOHb5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-01-21 at 17:42 +0100, Anders Bostr=C3=B6m wrote:
> >>>>> "JY" =3D=3D Jie Yang <Jie.Yang@Atheros.com> writes:
>=20
>  >> Have you tested NFS over TCP? The block-size the application
>  >> uses can have an effect on this. What application did you
>  >> use? Block-size?
>  >>=20
>  JY> yes, I tested NFS over TCP.
>=20
> One strange observation is that I can only reproduce this problem when
> transmitting data from a NFS-server using TCP with Atheros
> AR8121/AR8113/AR8114.
>=20
> I've tried to reproduce the problem using test-programs, like nttcp
> and netpipe, without any success. One observation is that the
> test-programs *only* generates 1500 bytes IP-packets. When
> the NFS-server sends data, a sequence of 1500 bytes IP-packets are
> generated, ending with a shorter packet. And this last packet in the
> sequence has 1500 in the IP-header length field, but is shorter.

I ran tcpdump over your packet capture and saw:

13:48:39.122723 00:26:18:ae:69:6d > 00:18:f3:52:22:3f, ethertype IPv4 (0x08=
00), length 1514: (tos 0x0, ttl 64, id 32664, offset 0, flags [DF], proto T=
CP (6), length 1500)
    10.100.0.88.2049 > 10.100.1.25.888: Flags [.], cksum 0x3ebd (correct), =
seq 21720:23168, ack 157, win 501, options [nop,nop,TS val 152460082 ecr 12=
12787170], length 1448
13:48:39.122733 00:18:f3:52:22:3f > 00:26:18:ae:69:6d, ethertype IPv4 (0x08=
00), length 66: (tos 0x0, ttl 64, id 39773, offset 0, flags [DF], proto TCP=
 (6), length 52)
    10.100.1.25.888 > 10.100.0.88.2049: Flags [.], cksum 0x5cfc (correct), =
ack 23168, win 58293, options [nop,nop,TS val 1212787170 ecr 152460082], le=
ngth 0
13:48:39.122742 00:26:18:ae:69:6d > 00:18:f3:52:22:3f, ethertype IPv4 (0x08=
00), length 1462: truncated-ip - 52 bytes missing! (tos 0x0, ttl 64, id 326=
64, offset 0, flags [DF], proto TCP (6), length 1500)
    10.100.0.88.2049 > 10.100.1.25.888: Flags [.], seq 23168:24616, ack 157=
, win 501, options [nop,nop,TS val 152460082 ecr 1212787170], length 1448
13:48:39.122747 00:26:18:ae:69:6d > 00:18:f3:52:22:3f, ethertype IPv4 (0x08=
00), length 1514: (tos 0x0, ttl 64, id 32666, offset 0, flags [DF], proto T=
CP (6), length 1500)
    10.100.0.88.2049 > 10.100.1.25.888: Flags [.], cksum 0x33a1 (correct), =
seq 24564:26012, ack 157, win 501, options [nop,nop,TS val 152460082 ecr 12=
12787170], length 1448

Based on the TCP sequence numbers, it seems that the length of the
broken packet is correct but its IP header is wrong.

My understanding is that the length of the TCP payload in a GSO skb must
always be a multiple of the gso_size, so that hardware is not required
to adjust length fields.  So I see several possible explanations:

1. Something generated invalid GSO skbs (unlikely; other hardware should
show the same problem)
2. The driver constructed TSO DMA descriptors for a non-GSO skb
3. The hardware is continuing to apply TSO to packets with non-TSO DMA
descriptors

Ben.

--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-bCg7B8Yy9SXTnyrfOHb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS1sV4Oe/yOyVhhEJAQK2gBAAnVnFXSQKGtomySTNU3bY112yis8rVsVY
S8MfLnMK6prHayC0paKJ4gfnvv7ZSMYIL9hfgUi88iaIFU3D93OlOchRtpzpygxn
VtUTEMtY8eY2cQhPI2L2sA9iic1H1EqXXjuZKiL2nnR3y3Te6g3vnNtxoLKFABJY
FwDgWQRMVcPm7Q8PdgLN1PT/3VaJmqBlMeTqWsOccqTqqJ1TUTfIAJxsupRarKxm
fHpn4lrgCcv5TvYVsvYv9q5s1CGd/Hz4ayze/wWXrxBIHMVpEaBNtu4dsrFAHGDe
jEbGcw3mPeIZyjcIhWy2vadi7aZ06Wnw8HOR7Smkeb48FUjo2sxTWU6dHqKqL5Xp
MqkXKtI1+jS7Fn9qPQzz2EL8lnoKzMIC0MG/8r/eOjNZIaod1wNfnGQxb/GsNRCe
loNgPD7M2W102iXLT+nJtYm3tn+PCFPnqvnXwareeSDpAhaSMuM6MOpuatAExVsf
ovRrJzb3nfD8KSKlfY34TG1Q6HS/DEJOSMXmoGIK4wOYoS5vJ1DoRwalA6Gfvz5s
cZfLnEUMU+CaJk25Se3YwzKLIVT28gjT/BWWQ8jZ1vXSySNFUnqjLdszRNbmRohL
wbmCSQMRgw7nAxtvzwBIJHon9zdqdcegYfE3+cm96kuAhshxuL5kal9o7MGfxryw
FfJPsm9NVl4=
=w9HR
-----END PGP SIGNATURE-----

--=-bCg7B8Yy9SXTnyrfOHb5--
