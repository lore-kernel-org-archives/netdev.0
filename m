From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V3 net-next] ixgbe: Avoid unaligned access in
 ixgbe_atr() for LLC packets
Date: Wed, 16 Mar 2016 15:58:52 -0700
Message-ID: <1458169132.2878.25.camel@intel.com>
References: <20160314194716.GM5084@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+mj/uuR/JeJVcvwLyIDz"
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38948 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932788AbcCPW67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 18:58:59 -0400
In-Reply-To: <20160314194716.GM5084@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+mj/uuR/JeJVcvwLyIDz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-03-14 at 15:47 -0400, Sowmini Varadhan wrote:
>=20
> For LLC based protocols like lldp, stp etc., the ethernet header
> is an 802.3 header with a h_proto that is not 0x800, 0x86dd, or
> even 0x806.=C2=A0 In this world, the skb_network_header() points at
> the DSAP/SSAP/..=C2=A0 and is not likely to be NET_IP_ALIGNed in
> ixgbe_atr().
>=20
> With LLC, drivers are not likely to correctly find IPVERSION,
> or "6", at hdr.ipv4->version, but will instead just needlessly
> trigger an unaligned access. (IPv4/IPv6 over LLC is almost never
> implemented).
>=20
> The unaligned access is thus avoidable: bail out quickly after
> examining skb->protocol. The only Ethernet II protocols handled
> are IPv4 and IPv6
>=20
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: Alexander Duyck comments
> v3: filter out all ethertypes=C2=A0 except for Ethernet II and (IPv4 or
> IPv6)
>=20
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |=C2=A0=C2=A0=C2=A0 5=
 +++++
> =C2=A01 files changed, 5 insertions(+), 0 deletions(-)

This does not apply since Alex Duyck beat you to the fix. =C2=A0Here is the
patch he submitted on 3/15 which corrects the issue. =C2=A0So I am dropping
your patch from the queue.

commit 04b8b51c34837765cf6250f69d419c439dc393bf
Author: Alexander Duyck <aduyck@mirantis.com>
Date:=C2=A0=C2=A0=C2=A0Tue Mar 15 15:10:22 2016 -0700

=C2=A0=C2=A0=C2=A0=C2=A0ixgbe: Fix ATR so that it correctly handles IPv6 ex=
tension headers
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0The ATR code was assuming that it would be able to =
use tcp_hdr for
=C2=A0=C2=A0=C2=A0=C2=A0every TCP frame that came through.=C2=A0=C2=A0Howev=
er this isn't the case as
it
=C2=A0=C2=A0=C2=A0=C2=A0is possible for a frame to arrive that is TCP but s=
ent through
something
=C2=A0=C2=A0=C2=A0=C2=A0like a raw socket.=C2=A0=C2=A0As a result the drive=
r was setting up bad
filters in
=C2=A0=C2=A0=C2=A0=C2=A0which tcp_hdr was really pointing to the network he=
ader so the data
was
=C2=A0=C2=A0=C2=A0=C2=A0all invalid.
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0In order to correct this I have added a bit of pars=
ing logic that
will
=C2=A0=C2=A0=C2=A0=C2=A0determine the TCP header location based off of the =
network header
and
=C2=A0=C2=A0=C2=A0=C2=A0either the offset in the case of the IPv4 header, o=
r a walk through
the
=C2=A0=C2=A0=C2=A0=C2=A0IPv6 extension headers until it encounters the head=
er that
indicates
=C2=A0=C2=A0=C2=A0=C2=A0IPPROTO_TCP.=C2=A0=C2=A0In addition I have added ch=
ecks to verify that the
lowest
=C2=A0=C2=A0=C2=A0=C2=A0protocol provided is recognized as IPv4 or IPv6 to =
help mitigate
raw
=C2=A0=C2=A0=C2=A0=C2=A0sockets using ETH_P_ALL from having ATR applied to =
them.
=C2=A0=C2=A0=C2=A0=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0Signed-off-by: Alexander Duyck <aduyck@mirantis.com=
>
--=-+mj/uuR/JeJVcvwLyIDz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW6eUsAAoJEOVv75VaS+3OjNMP/3RTIUIRbxyb05lQpNvccY+v
CsBed46aSsxGybnNFJYwMNs15m7AQ1kuBvOUKysfIzDN+lIXOxkrEtu7ORdX66ba
wAMBhEr+A+GGCkb/no6p2O3Xm1nCTeFv54z+VnkXpEKa0DCpvBpsIavIo7FN+CIK
o5+Iz6o3IpEJ+XWvQkfYnKnUgsNHHuGdzH8dXdeG9vSw/sz9lw7DvKIr3EHQjkr8
4kt3b1mqcCOuV5IeboWQdcFMroD98N18/pXb2WhC8+RuXd55Qmpse4fq1XCiugFc
/eiYzocKCOztA2xXj/BGXTvqE0iCMQDpPLp7zqj2y7b5sQ7Ju2Wv7BLLkJm0Skmv
dmwdSYkOuAC+jd3gaPCGh0qVBOpiJEZU0V47LgSAbnMtKULSdOsXJ1+1HFA8wFK7
dCFCPXhj6c6JAbatxcda5eXLGysLibjdLbt5udme2g1bb9ZVfh5i5cTvBqaKCXNw
16FLbMScJ3LDc+MunD8An7I6NF+6oFs9+DUqAkR5bZZCnFD+KHCi5RVOI3Um76S0
vyXzsghg8i6ZySw3e0BX4b6P0ca4Mo/P4B6W5Kf1OOJvXf9iqqORvXDRT0ONfpu9
q6G9JxfEkP8ycWzTRfS7cYr6N7iQSCaVc/YXwId55KrIRHF21vxJ7+jqtWDqmUeB
c2VArBvYwS1nRROZmrZ/
=ooDZ
-----END PGP SIGNATURE-----

--=-+mj/uuR/JeJVcvwLyIDz--
