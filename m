From: Sergey Popov <pinkbyte@gentoo.org>
Subject: Issue with GRE tunnel, created with "local any" on kernel 3.14
Date: Fri, 18 Jul 2014 17:01:23 +0400
Message-ID: <53C91AA3.1020106@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OvaKHXGaQE9P51iT2c5XCGxTCdVwodRHO"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:41042 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755528AbaGRNB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 09:01:29 -0400
Received: from [192.168.1.11] (unknown [80.80.98.176])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: pinkbyte)
	by smtp.gentoo.org (Postfix) with ESMTPSA id C9DDD340036
	for <netdev@vger.kernel.org>; Fri, 18 Jul 2014 13:01:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OvaKHXGaQE9P51iT2c5XCGxTCdVwodRHO
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi. I have updated kernel on one of my servers to 3.14 and hit strange
issue:

Simple setup:

serv1(172.30.0.100) <-> serv2(172.30.0.251)

Serv1 is on 3.11.7
Serv2 is on 3.13.6

Gre tunnel(serv1):
ip tunnel add tun_test mode gre remote 172.30.0.251 local any ttl 225
ifconfig tun_test 192.168.0.1/30

Gre tunnel(serv2):
ip tunnel add tun_test mode gre remote 172.30.0.100 local any ttl 225
ifconfig tun_test 192.168.0.2/30

Everything work as expected.

Now, with updated kernel on serv2 i have this:


serv2 ~ # ping 192.168.0.1 -c 10
PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
64 bytes from 192.168.0.1: icmp_seq=3D1 ttl=3D64 time=3D0.339 ms
64 bytes from 192.168.0.1: icmp_seq=3D2 ttl=3D64 time=3D0.303 ms

--- 192.168.0.1 ping statistics ---
10 packets transmitted, 2 received, 80% packet loss, time 9002ms
rtt min/avg/max/mdev =3D 0.303/0.321/0.339/0.018 ms

Huh? tcpdump on serv1 show me really strange thing:

bgp ~ # tcpdump -i lan0 -nn ip proto gre
tcpdump: verbose output suppressed, use -v or -vv for full protocol decod=
e
listening on lan0, link-type EN10MB (Ethernet), capture size 65535 bytes
16:49:33.338964 IP 172.30.0.251 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 1, length 64
16:49:33.339010 IP 172.30.0.100 > 172.30.0.251: GREv0, length 88: IP
192.168.0.1 > 192.168.0.2: ICMP echo reply, id 5259, seq 1, length 64
16:49:34.337945 IP 172.30.0.251 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 2, length 64
16:49:34.337988 IP 172.30.0.100 > 172.30.0.251: GREv0, length 88: IP
192.168.0.1 > 192.168.0.2: ICMP echo reply, id 5259, seq 2, length 64
16:49:35.336948 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 3, length 64
16:49:36.340999 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 4, length 64
16:49:37.340971 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 5, length 64
16:49:38.340985 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 6, length 64
16:49:39.340971 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 7, length 64
16:49:40.340918 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 8, length 64
16:49:41.340947 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 9, length 64
16:49:42.340970 IP 0.0.0.0 > 172.30.0.100: GREv0, length 88: IP
192.168.0.2 > 192.168.0.1: ICMP echo request, id 5259, seq 10, length 64
^C
12 packets captured
14 packets received by filter
0 packets dropped by kernel

Huh? 0.0.0.0? o_O

I have tried to up and done tunnels few times. Sometimes 0.0.0.0 is
replaced by correct address in the middle of icmp "session" for one or
two packets, but usually only first one or two packets have correct src
address.

I have tried some(not all of them) kernels from 3.14.2 up to 3.15.5 -
all have the same issue.

If i set "local 172.30.0.251" on serv2 the issue is gone completely.

Looking on changelog i discovered some fixes to gre, but i could not
understand if they can be culprit or not.

MTU on both real network ifaces are 1500, MTU on gre tunnels are 1476,
so i suppose that's right(and not an issue, cause mentioned icmp packets
are too small to hit MTU problem).

I am running Gentoo Linux, but issue is detected in vanilla kernel too,
so it's not distro problem, i suppose.

Can anybody help me to track this issue down?

--=20
Best regards, Sergey Popov
Gentoo developer
Gentoo Desktop-effects project lead
Gentoo Proxy maintainers project lead


--OvaKHXGaQE9P51iT2c5XCGxTCdVwodRHO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTyRqkAAoJECo/aRed92679IcH+QF2ys63LHbbrux7m2GGhFMy
Tgicb4IUu4UXW/xUDC4VaYokp5KxB6nINyREC3VgkYlSEB7mhNSKW5hu3M5afZYA
47+GNkYU3FWKkK2R3BMysUJ7s014bcwoBQEImkxMOiOjNoaAN+saQCgjGCBQKbMz
Hao9m6dzmRb02wK042vkpHK5kbR/Wq/Xbho9FFalOtK0DVDlJhEoQmtOflYmztLV
9KKXKBDCllrXd7zNeSswvvQrQ+8O4qVT/D990P1eA9nEarmNSisaQcksvaiq80FF
jNq+a+geSSD73SY1UdVkcsAF0CMX4iNg1jJv8yYyUvPm5It/mL/0CRdnlEayVxE=
=Sqle
-----END PGP SIGNATURE-----

--OvaKHXGaQE9P51iT2c5XCGxTCdVwodRHO--
