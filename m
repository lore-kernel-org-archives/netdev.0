From: Harald Welte <laforge@gnumonks.org>
Subject: Re: primary and secondary ip addresses
Date: Thu, 26 May 2005 20:11:18 +0200
Message-ID: <20050526181118.GK13114@sunbeam.de.gnumonks.org>
References: <Pine.LNX.4.61.0412171621200.15793@filer.marasystems.com> <1103550901.1050.292.camel@jzny.localdomain> <20050412105442.GV7510@sunbeam.de.gnumonks.org> <200505081531.16106.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rJP+s0P3Mdby0EAF"
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <200505081531.16106.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--rJP+s0P3Mdby0EAF
Content-Type: multipart/mixed; boundary="tOe3bw3OA0Dbc3H7"
Content-Disposition: inline


--tOe3bw3OA0Dbc3H7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

David, would you consider applying that patch to mainline?  I think
there was concensus on this solution, and it has now received some
amount of testing by Hasso and me.

Thanks!

On Sun, May 08, 2005 at 03:31:15PM +0300, Hasso Tepper wrote:
> Harald Welte wrote:
> > On Mon, Dec 20, 2004 at 08:55:02AM -0500, jamal wrote:
> >=20
> > > Didnt boot ;->
> > > A small silly magic number i missed. Now boots - but doesnt mean it
> > > works. And i dont have much time to spare chasing it.
> >=20
> > Due to a customer having again trouble with this issue, I was forced to
> > actually spend some time testing it (and merging it to a current
> > kernel).  At least in my simple tests, it worked like a charm :)
>=20
> I'm using it for some weeks in production and haven't noticed any issues
> either. Would be really good to see it kernel.
>=20
>=20
> regards,
>=20
> --=20
> Hasso Tepper
> Elion Enterprises Ltd.
> WAN administrator
>=20

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--tOe3bw3OA0Dbc3H7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6.12-rc2-promote_secondaries.patch"
Content-Transfer-Encoding: quoted-printable


Signed-off-by: Harald Welte <laforge@gnumonks.org>

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E12-rc2/include/linux/inetdevice.h linux-2.6.12-rc2-propag/include/linux/=
inetdevice.h
--- linux-2.6.12-rc2/include/linux/inetdevice.h	2005-03-02 08:38:13.0000000=
00 +0100
+++ linux-2.6.12-rc2-propag/include/linux/inetdevice.h	2005-04-12 10:21:45.=
000000000 +0200
@@ -29,6 +29,7 @@
 	int	no_xfrm;
 	int	no_policy;
 	int	force_igmp_version;
+	int	promote_secondaries;
 	void	*sysctl;
 };
=20
@@ -71,6 +72,7 @@
 #define IN_DEV_SEC_REDIRECTS(in_dev)	(ipv4_devconf.secure_redirects || (in=
_dev)->cnf.secure_redirects)
 #define IN_DEV_IDTAG(in_dev)		((in_dev)->cnf.tag)
 #define IN_DEV_MEDIUM_ID(in_dev)	((in_dev)->cnf.medium_id)
+#define IN_DEV_PROMOTE_SECONDARIES(in_dev)	(ipv4_devconf.promote_secondari=
es || (in_dev)->cnf.promote_secondaries)
=20
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E12-rc2/include/linux/sysctl.h linux-2.6.12-rc2-propag/include/linux/sysc=
tl.h
--- linux-2.6.12-rc2/include/linux/sysctl.h	2005-04-09 12:59:20.000000000 +=
0200
+++ linux-2.6.12-rc2-propag/include/linux/sysctl.h	2005-04-12 10:18:38.0000=
00000 +0200
@@ -399,6 +399,7 @@
 	NET_IPV4_CONF_FORCE_IGMP_VERSION=3D17,
 	NET_IPV4_CONF_ARP_ANNOUNCE=3D18,
 	NET_IPV4_CONF_ARP_IGNORE=3D19,
+	NET_IPV4_CONF_PROMOTE_SECONDARIES=3D20,
 	__NET_IPV4_CONF_MAX
 };
=20
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.6=
=2E12-rc2/net/ipv4/devinet.c linux-2.6.12-rc2-propag/net/ipv4/devinet.c
--- linux-2.6.12-rc2/net/ipv4/devinet.c	2005-04-09 12:59:21.000000000 +0200
+++ linux-2.6.12-rc2-propag/net/ipv4/devinet.c	2005-04-12 10:19:53.00000000=
0 +0200
@@ -233,11 +233,14 @@
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy)
 {
+	struct in_ifaddr *promote =3D NULL;
 	struct in_ifaddr *ifa1 =3D *ifap;
=20
 	ASSERT_RTNL();
=20
-	/* 1. Deleting primary ifaddr forces deletion all secondaries */
+	/* 1. Deleting primary ifaddr forces deletion all secondaries=20
+	 * unless alias promotion is set
+	 **/
=20
 	if (!(ifa1->ifa_flags & IFA_F_SECONDARY)) {
 		struct in_ifaddr *ifa;
@@ -251,11 +254,16 @@
 				continue;
 			}
=20
-			*ifap1 =3D ifa->ifa_next;
+			if (!IN_DEV_PROMOTE_SECONDARIES(in_dev)) {
+				*ifap1 =3D ifa->ifa_next;
=20
-			rtmsg_ifa(RTM_DELADDR, ifa);
-			notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
-			inet_free_ifa(ifa);
+				rtmsg_ifa(RTM_DELADDR, ifa);
+				notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa);
+				inet_free_ifa(ifa);
+			} else {
+				promote =3D ifa;
+				break;
+			}
 		}
 	}
=20
@@ -281,6 +289,13 @@
 		if (!in_dev->ifa_list)
 			inetdev_destroy(in_dev);
 	}
+
+	if (promote && IN_DEV_PROMOTE_SECONDARIES(in_dev)) {
+		/* not sure if we should send a delete notify first? */
+		promote->ifa_flags &=3D ~IFA_F_SECONDARY;
+		rtmsg_ifa(RTM_NEWADDR, promote);
+		notifier_call_chain(&inetaddr_chain, NETDEV_UP, promote);
+	}
 }
=20
 static int inet_insert_ifa(struct in_ifaddr *ifa)
@@ -1383,6 +1398,15 @@
 			.proc_handler	=3D &ipv4_doint_and_flush,
 			.strategy	=3D &ipv4_doint_and_flush_strategy,
 		},
+		{
+			.ctl_name	=3D NET_IPV4_CONF_PROMOTE_SECONDARIES,
+			.procname	=3D "promote_secondaries",
+			.data		=3D &ipv4_devconf.promote_secondaries,
+			.maxlen		=3D sizeof(int),
+			.mode		=3D 0644,
+			.proc_handler	=3D &ipv4_doint_and_flush,
+			.strategy	=3D &ipv4_doint_and_flush_strategy,
+		},
 	},
 	.devinet_dev =3D {
 		{

--tOe3bw3OA0Dbc3H7--

--rJP+s0P3Mdby0EAF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFClhFGXaXGVTD0i/8RAieuAKCGQk9ghRjS3KHBAwh2eaAtdnyMcgCfTATK
L/U/7TetWDveEfoV/9Yz8Ho=
=PiZp
-----END PGP SIGNATURE-----

--rJP+s0P3Mdby0EAF--
