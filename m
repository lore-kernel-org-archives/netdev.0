From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: Cannot set IPv6 address
Date: Wed, 16 Nov 2016 16:34:42 +0100
Message-ID: <582C7C92.2000306@uclouvain.be>
References: <CALzJLG9B52CbMEiWgroaihq4Ar2Jc9H3BZdA_xjF37CZESbZ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="rbwHJXFMb9tVeT0fFxHtq9hPHusgP2ClM"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Doron Tsur <doront@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:37825 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753157AbcKPPcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:32:47 -0500
In-Reply-To: <CALzJLG9B52CbMEiWgroaihq4Ar2Jc9H3BZdA_xjF37CZESbZ8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--rbwHJXFMb9tVeT0fFxHtq9hPHusgP2ClM
Content-Type: multipart/mixed;
 boundary="------------040004010700070209040105"

This is a multi-part message in MIME format.
--------------040004010700070209040105
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/16/2016 04:22 PM, Saeed Mahameed wrote:
> Hi David,
>=20
> The following commit introduced a new issue when setting IPv6 address
> via the following command:
>=20
> /sbin/ip -6 addr add 2001:0db8:0:f112::1/64 dev enp2s2
> RTNETLINK answers: Operation not supported
>=20
> Offending commit:
>=20
> commit 6c8702c60b88651072460f3f4026c7dfe2521d12

Saeed,

Do you have LWTUNNEL enabled ? This commit introduced a bug causing IPv6
initialization to fail if LWTUNNEL is disabled. The patch has been
submitted to the list and is pending approval from DaveM.

If you see something like

NET: Registered protocol family 10
IPv6: Attempt to unregister permanent protocol 6
IPv6: Attempt to unregister permanent protocol 136
IPv6: Attempt to unregister permanent protocol 17
NET: Unregistered protocol family 10

in you dmesg logs then it would confirm my theory.

Short fix: enable CONFIG_LWTUNNEL or apply patch in attachment

David

--------------040004010700070209040105
Content-Type: text/x-patch;
 name="0001-ipv6-sr-add-option-to-control-lwtunnel-support.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="0001-ipv6-sr-add-option-to-control-lwtunnel-support.patch"

=46rom 51775d7223b6d5bd16cb5d09df9ba494fac8ffda Mon Sep 17 00:00:00 2001
From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 15 Nov 2016 14:57:52 +0100
Subject: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel su=
pport

This patch adds a new option CONFIG_IPV6_SEG6_LWTUNNEL to enable/disable
support of encapsulation with the lightweight tunnels. When this option
is enabled, CONFIG_LWTUNNEL is automatically selected.

Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and=
 injection with lwtunnels")

Without a proper option to control lwtunnel support for SR-IPv6, if
CONFIG_LWTUNNEL=3Dn then the IPv6 initialization fails as a consequence
of seg6_iptunnel_init() failure with EOPNOTSUPP:

NET: Registered protocol family 10
IPv6: Attempt to unregister permanent protocol 6
IPv6: Attempt to unregister permanent protocol 136
IPv6: Attempt to unregister permanent protocol 17
NET: Unregistered protocol family 10

Tested (compiling, booting, and loading ipv6 module when relevant)
with possible combinations of CONFIG_IPV6=3D{y,m,n},
CONFIG_IPV6_SEG6_LWTUNNEL=3D{y,n} and CONFIG_LWTUNNEL=3D{y,n}.

Reported-by: Lorenzo Colitti <lorenzo@google.com>
Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/Kconfig  | 13 ++++++++++++-
 net/ipv6/Makefile |  5 +++--
 net/ipv6/seg6.c   |  8 ++++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 0f00811..ec1267e 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -289,9 +289,20 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
=20
+config IPV6_SEG6_LWTUNNEL
+	bool "IPv6: Segment Routing Header encapsulation support"
+	depends on IPV6
+	select LWTUNNEL
+	---help---
+	  Support for encapsulation of packets within an outer IPv6
+	  header and a Segment Routing Header using the lightweight
+	  tunnels mechanism.
+
+	  If unsure, say N.
+
 config IPV6_SEG6_INLINE
 	bool "IPv6: direct Segment Routing Header insertion "
-	depends on IPV6
+	depends on IPV6_SEG6_LWTUNNEL
 	---help---
 	  Support for direct insertion of the Segment Routing Header,
 	  also known as inline mode. Be aware that direct insertion of
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 129cad2..a9e9fec 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -9,7 +9,7 @@ ipv6-objs :=3D	af_inet6.o anycast.o ip6_output.o ip6_inpu=
t.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
-		udp_offload.o seg6.o seg6_iptunnel.o
+		udp_offload.o seg6.o
=20
 ipv6-offload :=3D	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
=20
@@ -23,6 +23,8 @@ ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) +=3D fib6_rules.o
 ipv6-$(CONFIG_PROC_FS) +=3D proc.o
 ipv6-$(CONFIG_SYN_COOKIES) +=3D syncookies.o
 ipv6-$(CONFIG_NETLABEL) +=3D calipso.o
+ipv6-$(CONFIG_IPV6_SEG6_LWTUNNEL) +=3D seg6_iptunnel.o
+ipv6-$(CONFIG_IPV6_SEG6_HMAC) +=3D seg6_hmac.o
=20
 ipv6-objs +=3D $(ipv6-y)
=20
@@ -44,7 +46,6 @@ obj-$(CONFIG_IPV6_SIT) +=3D sit.o
 obj-$(CONFIG_IPV6_TUNNEL) +=3D ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) +=3D ip6_gre.o
 obj-$(CONFIG_IPV6_FOU) +=3D fou6.o
-obj-$(CONFIG_IPV6_SEG6_HMAC) +=3D seg6_hmac.o
=20
 obj-y +=3D addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) +=3D output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 50f6e06..b172d85 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -451,9 +451,11 @@ int __init seg6_init(void)
 	if (err)
 		goto out_unregister_genl;
=20
+#ifdef CONFIG_IPV6_SEG6_LWTUNNEL
 	err =3D seg6_iptunnel_init();
 	if (err)
 		goto out_unregister_pernet;
+#endif
=20
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	err =3D seg6_hmac_init();
@@ -467,10 +469,14 @@ int __init seg6_init(void)
 	return err;
 #ifdef CONFIG_IPV6_SEG6_HMAC
 out_unregister_iptun:
+#ifdef CONFIG_IPV6_SEG6_LWTUNNEL
 	seg6_iptunnel_exit();
 #endif
+#endif
+#ifdef CONFIG_IPV6_SEG6_LWTUNNEL
 out_unregister_pernet:
 	unregister_pernet_subsys(&ip6_segments_ops);
+#endif
 out_unregister_genl:
 	genl_unregister_family(&seg6_genl_family);
 	goto out;
@@ -481,7 +487,9 @@ void seg6_exit(void)
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	seg6_hmac_exit();
 #endif
+#ifdef CONFIG_IPV6_SEG6_LWTUNNEL
 	seg6_iptunnel_exit();
+#endif
 	unregister_pernet_subsys(&ip6_segments_ops);
 	genl_unregister_family(&seg6_genl_family);
 }
--=20
2.7.3


--------------040004010700070209040105--

--rbwHJXFMb9tVeT0fFxHtq9hPHusgP2ClM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlgsfJIACgkQjbzn67sZ6AOH1ACeJVoCh1WipSjQZVn2XajZE2iy
XdkAn2D9cDl4kX1TOC9QBxqznxFirMpM
=JKR5
-----END PGP SIGNATURE-----

--rbwHJXFMb9tVeT0fFxHtq9hPHusgP2ClM--
