From: Sascha Hlusiak <mail@saschahlusiak.de>
Subject: [PATCH] Assign linklocal addresses to isatap from link dev
Date: Sun, 1 Mar 2009 01:34:48 +0100
Message-ID: <200903010134.54405.mail@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3751006.zUIDmrs94u";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:64961 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754942AbZCAAek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 19:34:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3751006.zUIDmrs94u
Content-Type: multipart/mixed;
  boundary="Boundary-01=_pgdqJeXUSTg9SlE"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_pgdqJeXUSTg9SlE
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

To use isatap on a client, I use the following command:
# ip tunnel add isatap0 mode isatap remote $REMOTE_V4 dev eth0

(without the attached iproute2-patch that command would fail because of the=
=20
remote option; patch is sent to maintainer).

Old implemention would then add a linklocal address based on the unset 'loc=
al'=20
option, which is obviously wrong: fe80::5efe:0:0/64

With my patch applied and the tunnel created like above, if a link is attac=
hed=20
to the tunnel, all it's ipv4 addresses are added as isatap compatible=20
linklocal addresses to the tunnel device. The wrong isatap ll-address above=
=20
will not be added anymore, if the 'local' option is unset.


# ip addr
2: eth0: UNKNOWN qlen 1000
   [...]
    inet 192.168.6.5/24 brd 192.168.6.255 scope global eth0
    inet 192.168.6.9/32 scope global eth0
   [...]
7: is0@eth0: <POINTOPOINT,NOARP,UP,LOWER_UP>
    link/sit 0.0.0.0 peer x.x.x.x
    inet6 fe80::5efe:c0a8:609/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fe80::5efe:c0a8:605/64 scope link
       valid_lft forever preferred_lft forever

That way stateless autoconf works with isatap tunnels and without knowledge=
 of=20
the local v4 address.


    Signed-off-by: Sascha Hlusiak <mail@saschahlusiak.de>


Thanks,
Sascha Hlusiak


--Boundary-01=_pgdqJeXUSTg9SlE
Content-Type: text/x-patch;
  charset="us-ascii";
  name="iproute2_isatap_remote.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="iproute2_isatap_remote.patch"

commit d08b227e749b57d18222692e284615f38fe7dc24
Author: Sascha Hlusiak <contact@saschahlusiak.de>
Date:   Sat Feb 28 23:14:23 2009 +0100

    Fix isatap tunnels with remote host
   =20
    A remote host is needed for client systems to work so allow creation of=
 those tunnels.

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 0d9a17f..f80019c 100644
=2D-- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -253,10 +253,6 @@ static int parse_args(int argc, char **argv, int cmd, =
struct ip_tunnel_parm *p)
 		return -1;
 	}
 	if (isatap) {
=2D		if (p->iph.daddr) {
=2D			fprintf(stderr, "no remote with isatap.\n");
=2D			return -1;
=2D		}
 		p->i_flags |=3D SIT_ISATAP;
 	}
=20

--Boundary-01=_pgdqJeXUSTg9SlE
Content-Type: text/x-patch;
  charset="us-ascii";
  name="kernel_addrconf_isatap_ll.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="kernel_addrconf_isatap_ll.patch"

=2D-- net/ipv6/addrconf.c.orig	2009-03-01 00:51:40.000000000 +0100
+++ net/ipv6/addrconf.c	2009-03-01 01:07:31.000000000 +0100
@@ -36,6 +36,8 @@
  *	YOSHIFUJI Hideaki @USAGI	:	improved source address
  *						selection; consider scope,
  *						status etc.
+ *	Sascha Hlusiak				isatap: assign linklocal
+ *	<mail@saschahlusiak.de>			addresses from link dev
  */
=20
 #include <linux/errno.h>
@@ -1556,13 +1558,6 @@
 }
 EXPORT_SYMBOL(__ipv6_isatap_ifid);
=20
=2Dstatic int addrconf_ifid_sit(u8 *eui, struct net_device *dev)
=2D{
=2D	if (dev->priv_flags & IFF_ISATAP)
=2D		return __ipv6_isatap_ifid(eui, *(__be32 *)dev->dev_addr);
=2D	return -1;
=2D}
=2D
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1574,8 +1569,6 @@
 		return addrconf_ifid_arcnet(eui, dev);
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
=2D	case ARPHRD_SIT:
=2D		return addrconf_ifid_sit(eui, dev);
 	}
 	return -1;
 }
@@ -2363,6 +2356,25 @@
 }
=20
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
+static void
+isatap_add_v4_addrs(struct inet6_dev *idev, struct net_device *link_dev)
+{
+	struct in_device *in_dev =3D __in_dev_get_rtnl(link_dev);
+	struct in6_addr addr;
+	struct in_ifaddr *ifa;
+
+	if (!link_dev->flags & IFF_UP)
+		return;
+	if (!in_dev)
+		return;
+
+	for (ifa =3D in_dev->ifa_list; ifa; ifa =3D ifa->ifa_next) {
+		ipv6_addr_set(&addr, htonl(0xFE800000), 0, 0, 0);
+		if (!__ipv6_isatap_ifid(addr.s6_addr + 8, ifa->ifa_local))
+			addrconf_add_linklocal(idev, &addr);
+	}
+}
+
 static void addrconf_sit_config(struct net_device *dev)
 {
 	struct inet6_dev *idev;
@@ -2382,11 +2394,23 @@
=20
 	if (dev->priv_flags & IFF_ISATAP) {
 		struct in6_addr addr;
+		struct net_device *link_dev;
+		struct net *net =3D dev_net(dev);
=20
 		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
 		addrconf_prefix_route(&addr, 64, dev, 0, 0);
=2D		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
=2D			addrconf_add_linklocal(idev, &addr);
+
+		if (*(__be32 *)dev->dev_addr) {
+			if (!__ipv6_isatap_ifid(addr.s6_addr + 8,
+						*(__be32 *)dev->dev_addr))
+				addrconf_add_linklocal(idev, &addr);
+		}
+		/* Add all v4 addrs from the tunnel dev */
+		if (idev->dev->iflink &&
+		    (link_dev =3D __dev_get_by_index(net, idev->dev->iflink))) {
+			isatap_add_v4_addrs(idev, link_dev);
+		}
+
 		return;
 	}
=20

--Boundary-01=_pgdqJeXUSTg9SlE--

--nextPart3751006.zUIDmrs94u
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.10 (GNU/Linux)

iEYEABECAAYFAkmp2C4ACgkQOyDtNneHFrMPagCgggc6Z8HGqSSV0iysXMaOLO6Y
Fv8AnA2HkbtO1xKhB9R7nbXzORUutGDK
=UrGz
-----END PGP SIGNATURE-----

--nextPart3751006.zUIDmrs94u--
