From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: [PATCH] IPv6: Fix broken anycast usage
Date: 12 Jul 2003 11:13:10 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057997590.1142.31.camel@hades>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-z/elxEQiE2HR9qGdA6GJ"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-z/elxEQiE2HR9qGdA6GJ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is against 2.5.75.

The patch fixes several places where anycast addresses should be treated
equivalently with unicast addresses. In particular, this includes
tunnels and routes pointing to anycast addresses.

I modified ipv6_addr_type() to return IPV6_ADDR_UNICAST also for anycast
addresses. IPV6_ADDR_ANYCAST is now added as an additional flag when the
address is one of the known anycast addresses.

I looked very hard at neighbor discovery and didn't see anything that
needs to be changed, but you might want to have a second look. One small
difference is that ND will now also try respond to neighbor
solicitations coming from known anycast addresses (very unlikely). IMHO,
this doesn't need to be policed. In general, there is no reliable way to
check if a remote address is anycast, anyway. From RFC2461:

                 Note that an anycast address is syntactically
                 indistinguishable from a unicast address.  Thus, nodes
                 sending packets to anycast addresses don't generally
                 know that an anycast address is being used.  Throughout
                 the rest of this document, references to unicast
                 addresses also apply to anycast addresses in those
                 cases where the node is unaware that a unicast address
                 is actually an anycast address.

Thanks,

	MikaL


--=-z/elxEQiE2HR9qGdA6GJ
Content-Disposition: attachment; filename=2.5.75-anycast.udiff
Content-Type: text/x-patch; name=2.5.75-anycast.udiff; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

diff -ur orig/linux-2.5.75/net/ipv6/addrconf.c linux-2.5.75/net/ipv6/addrco=
nf.c
--- orig/linux-2.5.75/net/ipv6/addrconf.c	2003-07-10 23:14:49.000000000 +03=
00
+++ linux-2.5.75/net/ipv6/addrconf.c	2003-07-12 10:01:57.000000000 +0300
@@ -208,16 +208,15 @@
 				break;
 		};
 		return type;
-	}
+	} else
+		type =3D IPV6_ADDR_UNICAST;
+
 	/* check for reserved anycast addresses */
-=09
 	if ((st & htonl(0xE0000000)) &&
 	    ((addr->s6_addr32[2] =3D=3D htonl(0xFDFFFFFF) &&
 	    (addr->s6_addr32[3] | htonl(0x7F)) =3D=3D (u32)~0) ||
 	    (addr->s6_addr32[2] =3D=3D 0 && addr->s6_addr32[3] =3D=3D 0)))
-		type =3D IPV6_ADDR_ANYCAST;
-	else
-		type =3D IPV6_ADDR_UNICAST;
+		type |=3D IPV6_ADDR_ANYCAST;
=20
 	/* Consider all addresses with the first three bits different of
 	   000 and 111 as finished.

--=-z/elxEQiE2HR9qGdA6GJ--
