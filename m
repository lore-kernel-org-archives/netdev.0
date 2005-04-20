From: folkert@vanheusden.com
Subject: [PATCH] optimize check in port-allocation code
Date: Wed, 20 Apr 2005 20:44:21 +0200
Message-ID: <20050420184419.GM20290@vanheusden.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TdMwOTenGjBWB1uY"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--TdMwOTenGjBWB1uY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

In the 2.6.11 code, I found this:
static int tcp_v6_get_port(struct sock *sk, unsigned short snum)
also in:
static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
{
=2E..
        if (snum =3D=3D 0) {
                int low =3D sysctl_local_port_range[0];
                int high =3D sysctl_local_port_range[1];

                spin_lock(&tcp_portalloc_lock);
		rover =3D tcp_port_rover;
                do {    rover++;
                        if ((rover < low) || (rover > high))
                                rover =3D low;

That 'rover < low' check is redundant?
ints are bigger then the maximum portnumber (65535) so when
rover++ gets too high, the check for 'rover > high' will truncate
it to low (in the next line) waaay before the int itself wraps.
It is needed because tcp_port_rover might be < low before the
function starts, in that case the check for <low can be taken out
of the loop.

Patch:

diff -uNr net/ipv4/tcp_ipv4.c.org net/ipv4/tcp_ipv4.c
--- net/ipv4/tcp_ipv4.c.org     2005-03-04 22:39:37.340950747 +0100
+++ net/ipv4/tcp_ipv4.c 2005-03-04 22:40:35.570059217 +0100
@@ -222,10 +222,13 @@
                int rover;

                spin_lock(&tcp_portalloc_lock);
-               rover =3D tcp_port_rover;
+               if (tcp_port_rover < low)
+                       rover =3D low;
+               else
+                       rover =3D tcp_port_rover;
                do {
                        rover++;
-                       if (rover < low || rover > high)
+                       if (rover > high)
                                rover =3D low;
                        head =3D &tcp_bhash[tcp_bhashfn(rover)];
                        spin_lock(&head->lock);

diff -uNr net/ipv6/tcp_ipv6.c.org net/ipv6/tcp_ipv6.c
--- net/ipv6/tcp_ipv6.c.org     2005-03-04 22:41:44.043007791 +0100
+++ net/ipv6/tcp_ipv6.c 2005-03-04 22:42:17.604728073 +0100
@@ -139,9 +139,12 @@
                int rover;

                spin_lock(&tcp_portalloc_lock);
-               rover =3D tcp_port_rover;
+               if (tcp_port_rover < low)
+                       rover =3D low;
+               else
+                       rover =3D tcp_port_rover;
                do {    rover++;
-                       if ((rover < low) || (rover > high))
+                       if (rover > high)
                                rover =3D low;
                        head =3D &tcp_bhash[tcp_bhashfn(rover)];
                        spin_lock(&head->lock);


Signed-off-by: Folkert van Heusden <folkert@vanheusden.com>
(please cc me, i'm not (yet) on the list)


Folkert van Heusden

Auto te koop, zie: http://www.vanheusden.com/daihatsu.php
Op zoek naar een IT of Finance baan? Mail me voor de mogelijkheden.
--------------------------------------------------------------------
 UNIX admin? Then give MultiTail (http://vanheusden.com/multitail/)=20
 a try, it brings monitoring logfiles to a different level! See    =20
 http://vanheusden.com/multitail/features.html for a feature-list. =20
--------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE
Get your PGP/GPG key signed at www.biglumber.com!

--TdMwOTenGjBWB1uY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iIMEARECAEMFAkJmowI8Gmh0dHA6Ly93d3cudmFuaGV1c2Rlbi5jb20vZGF0YS1z
aWduaW5nLXdpdGgtcGdwLXBvbGljeS5odG1sAAoJEDAZDowfKNiumsUAmQEmtWwC
gITCxZYScgOik1iqp/btAJ9+yC73ficq5h4fUcpVvpnB5MZldg==
=IQ8N
-----END PGP SIGNATURE-----

--TdMwOTenGjBWB1uY--
