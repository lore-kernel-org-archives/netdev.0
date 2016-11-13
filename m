From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net-next v2] ipv6: sr: fix IPv6 initialization failure
 without lwtunnels
Date: Sun, 13 Nov 2016 20:59:21 +0100
Message-ID: <5828C619.2020008@uclouvain.be>
References: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>        <1478780813-20005-1-git-send-email-david.lebrun@uclouvain.be>        <20161113.002055.1386089188095640295.davem@davemloft.net> <20161113.002348.81553025732356797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="32nCte3irAxXuVnkqXJxTsDbHnq11KkI6"
Cc: <netdev@vger.kernel.org>, <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47810 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934338AbcKMT50 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 14:57:26 -0500
In-Reply-To: <20161113.002348.81553025732356797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--32nCte3irAxXuVnkqXJxTsDbHnq11KkI6
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/13/2016 06:23 AM, David Miller wrote:
> This seems like such a huge mess, quite frankly.
>=20
> IPV6-SR has so many strange dependencies, a weird Kconfig option that i=
s
> simply controlling what a responsible sysadmin should be allow to do if=

> he chooses anyways.
>=20
> Every distribution is going to say "=C2=AF\_(=E3=83=84)_/=C2=AF" and ju=
st turn the thing
> on in their builds.

Indeed, the issue is that seg6_iptunnel.o was included in obj-y instead
of ipv6-y, triggering the bug when CONFIG_IPV6=3Dm. Fixed with the
following modification to the patch (tested with allyesconfig and
allmodconfig):

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 8979d53..a233136 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -53,6 +53,6 @@ obj-$(subst m,y,$(CONFIG_IPV6)) +=3D inet6_hashtables.o=


 ifneq ($(CONFIG_IPV6),)
 obj-$(CONFIG_NET_UDP_TUNNEL) +=3D ip6_udp_tunnel.o
-obj-$(CONFIG_LWTUNNEL) +=3D seg6_iptunnel.o
+ipv6-$(CONFIG_LWTUNNEL) +=3D seg6_iptunnel.o
 obj-y +=3D mcast_snoop.o
 endif

I agree with you that the way to combine the dependencies is strange,
even if they are very few. The part of the IPv6-SR patch that is enabled
by default depends on two things: IPV6 and LWTUNNEL. The problem is that
LWTUNNEL does not depend on IPV6 and is not necessarily enabled. To fix
the bug reported by Lorenzo, I propose to select one the three following
solutions:

1. Make LWTUNNEL always enabled (removing the option).
   Pros: remove an option
   Cons: add always-enabled code

2. Create an option IPV6_SEG6_LWTUNNEL, which would select LWTUNNEL and
enable the compilation of seg6_iptunnel.o.
   Pros: logically dissociate the part of IPv6-SR that depends on
LWTUNNEL from the core patch and simplifies compilation
   Cons: add an option

3. Apply the proposed patch with the fix
   Pros: do not modify options
   Cons: weird conditional compilation

What do you think ?

David


--32nCte3irAxXuVnkqXJxTsDbHnq11KkI6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgoxh4ACgkQjbzn67sZ6ANk4gCcDS4PTuDLkZMzNXxRoj1pdjjR
fI4An10Lo64Nk7PW9BzlurTeYBpp2WmR
=XYvQ
-----END PGP SIGNATURE-----

--32nCte3irAxXuVnkqXJxTsDbHnq11KkI6--
