From: Mike Frysinger <vapier@gentoo.org>
Subject: iproute2-3.5.0: `ip a s` no longer shows addresses
Date: Tue, 7 Aug 2012 15:03:00 -0400
Message-ID: <201208071503.01261.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4413651.qhzU6lK147";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:49598 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2HGTDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 15:03:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart4413651.qhzU6lK147
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

since 3.4.0 works, but 3.5.0, a quick bisect shows the bad commit:
http://git.kernel.org/?p=3Dlinux/kernel/git/shemminger/iproute2.git;a=3Dcom=
mit;h=3D8d07e5f7d995171ee8834eae268e300560de5d4f

the simple test case:
make clean && make -j -s && ./ip/ip a s lo

before that change, i would get:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever

but after, i now get:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN=20
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

seems like the bug was introduced in the middle of that patch:
=20
=2D	if (filter.family !=3D AF_PACKET) {
+	if (filter.family && filter.family !=3D AF_PACKET) {
+		if (filter.oneline)
+			no_link =3D 1;
+
 		if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 			perror("Cannot send dump request");
 			exit(1);

if i revert the change to the if statement there, `ip a s` works for me aga=
in.
(see below)
=2Dmike

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 37deda5..69a63b3 100644
=2D-- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1018,7 +1018,7 @@ static int ipaddr_list_or_flush(int argc, char **argv=
, int flush)
 		exit(1);
 	}
=20
=2D	if (filter.family && filter.family !=3D AF_PACKET) {
+	if (filter.family !=3D AF_PACKET) {
 		if (filter.oneline)
 			no_link =3D 1;
=20

--nextPart4413651.qhzU6lK147
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQIWZlAAoJEEFjO5/oN/WBl+QQANDd+NfizX3Q/HwGQD4QDP8J
jmT76Ne0vJL5noASsmQkuQI3/kqHA1Ig6Q4yyjEe4/LHaQhKk/J2m+ZCqe1DUOl5
PeB9TsqlSDsZVup5xRNs1fVyXJ8zOJDHU98V7dWWGKeXURzo1MnqB30v6DUiMjs9
2G/gtbPsqCr/ZHCX0GqAcgg+Ma2k9Py5JmEuwaOBXaVs2ULiLp6TYBQ3NCIxN0Oy
U8wUCOBbx8SkBOJ0qgP+JfInM0QIJ6FZ5nAEn92pHXRxX8pDmdjdcB3U/XJWGwD6
F8BXaTr8N4P36zIHm+1+KAQyTxMgp8AxQRoXlRr3NTJXOOcoM6RfhYbcJm668zcS
nH1DnIVsiMd1QvdmoIkNedHw33C29KZ8KVvLkikdU9CBnwdsfvyy4mxmN+zLKr0l
akl4VVzaa9Ob3qEFJ7JF+cJqyEenvp5VZt9nEwGvGL3iFOLOItEuvhjBqQmHATOy
OLyP600ZDzuMDYvMAXf4vgC6WvuE48CSZzOeK4db1Kaxvp0wLgaxyWvwlhs6jZeP
ZapgssYypWxvygVBcDeBNU3tHH2RAqKm9rgKlQSq6T9R7SrN37u+WaN2p0KhJOpV
8ClIzzN/2tm6hbZcRklyONRs9h976H4hUT5ersMLK7ecapbrnHgfh2bCEzqNUo33
73SMqE0npMOaggj3DXLK
=a4EB
-----END PGP SIGNATURE-----

--nextPart4413651.qhzU6lK147--
