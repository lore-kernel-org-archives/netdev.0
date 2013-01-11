From: Roman Mamedov <rm@romanrm.ru>
Subject: Problem with IPv6 Route Cache
Date: Fri, 11 Jan 2013 18:51:26 +0600
Message-ID: <20130111185126.56cababe@natsu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MWHwlvoqgj18s4414=5d4U8"; protocol="application/pgp-signature"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from len.romanrm.net ([176.31.121.172]:41135 "EHLO len.romanrm.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab3AKNAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 08:00:19 -0500
Received: from natsu (unknown [IPv6:fd39::1e6f:65ff:fea1:3ea6])
	by len.romanrm.net (Postfix) with ESMTPS id 46BB8203C6
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2013 12:51:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/MWHwlvoqgj18s4414=5d4U8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hello,

I am trying to set up a VPN (tinc) connection and add a route to an ULA sub=
net
via another host on it.

My VPN setup script basically does:

  ip addr add fd39:20::3/64 dev tun-rm
  ip route add fd39::/64 via fd39:20::39 dev tun-rm
  ip link set tun-rm up

And then I have:

root@neru:~# ip -6 route
2a02:e00:ffff:56::/64 dev eth0  proto kernel  metric 256=20
fd39::/64 via fd39:20::39 dev tun-rm  metric 1024=20
fd39:20::/64 dev tun-rm  proto kernel  metric 256=20
fe80::/64 dev eth0  proto kernel  metric 256=20
fe80::/64 dev tun-rm  proto kernel  metric 256=20
default via 2a02:e00:ffff:56::1 dev eth0  metric 1=20

root@neru:~# ip -6 addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536=20
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
    inet6 2a02:e00:ffff:56:ffff:ffff:xxxx:xxxx/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3eff:fe17:4a21/64 scope link=20
       valid_lft forever preferred_lft forever
26: tun-rm: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 500
    inet6 fd39:20::3/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::40f7:7eff:fe6a:3901/64 scope link=20
       valid_lft forever preferred_lft forever

The problem is, at some point presumably while the VPN interface is being a=
nd
at the same time the destination ULA subnet is being actively communicated
with, a wrong route entry (over the main default g/w) gets into the routing
cache, so despite the above table, I have for example:

# ip -6 route get fd39::100
fd39::100 from :: via 2a02:e00:ffff:56::1 dev eth0  src 2a02:e00:ffff:56:ff=
ff:ffff:xxxx:xxxx  metric 0=20
    cache


And even flushing the route cache does not help to get rid of it:

root@neru:~# ip -6 route get fd39::100
fd39::100 from :: via 2a02:e00:ffff:56::1 dev eth0  src 2a02:e00:ffff:56:ff=
ff:ffff:xxxx:xxxx  metric 0=20
    cache=20
root@neru:~# ip -6 route flush cache
root@neru:~# ip -6 route get fd39::100
fd39::100 from :: via 2a02:e00:ffff:56::1 dev eth0  src 2a02:e00:ffff:56:ff=
ff:ffff:xxxx:xxxx  metric 0=20
    cache


This is on kernel version 3.7.1 inside a Xen VPS (if this matters).

Can anyone advice how to deal with this problem?
Can I disable/remove the IPv6 route cache?
I know the IPv4 route cache was recently removed from the kernel.

Things I tried so far to mitigate this:

1) ip6tables -I OUTPUT -d fc00::/7 -o eth0 -j REJECT --reject-with icmp6-no=
-route
2)  ip -6 route add unreachable fc00::/7 dev eth0

=3D> but both simply make the desired subnet completely unreachable in thei=
r own ways,
rather than solving the issue.

3) adding my route to "fd39::/64 via fd39:20::39" with metric 1 (can't add =
with
metric 0, it changes to 1024)

=3D> no effect.

--=20
With respect,
Roman

~~~~~~~~~~~~~~~~~~~~~~~~~~~
"Stallman had a printer,
with code he could not see.
So he began to tinker,
and set the software free."

--Sig_/MWHwlvoqgj18s4414=5d4U8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlDwCs4ACgkQTLKSvz+PZwjslACcCDMQsmr6eyUf6tHNKzjWW5Xr
6rAAn3l8QrS6h0eO1v14mQAz5T6Eqw+2
=nVaI
-----END PGP SIGNATURE-----

--Sig_/MWHwlvoqgj18s4414=5d4U8--
