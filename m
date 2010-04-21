From: Sam Cannell <sam.cannell@catalyst.net.nz>
Subject: IPv6 duplicate address detection erroneously marking address as
 duplicate when a host receives its own multicast packets?
Date: Thu, 22 Apr 2010 08:13:51 +1200
Message-ID: <1271880831.6685.6.camel@spathi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VKBgRElfqgK75OXC2wfB"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bertrand.catalyst.net.nz ([202.78.240.40]:38470 "EHLO
	mail.catalyst.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756426Ab0DUUVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 16:21:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.catalyst.net.nz (Postfix) with ESMTP id B37203353F
	for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 08:15:21 +1200 (NZST)
Received: from mail.catalyst.net.nz ([127.0.0.1])
	by localhost (bertrand.catalyst.net.nz [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xwn3tv8lPbxb for <netdev@vger.kernel.org>;
	Thu, 22 Apr 2010 08:15:21 +1200 (NZST)
Received: from [IPv6:2404:130:0:1000:8:20ff:fe89:5d3] (unknown [IPv6:2404:130:0:1000:8:20ff:fe89:5d3])
	by mail.catalyst.net.nz (Postfix) with ESMTPS id 038F4324B4
	for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 08:15:21 +1200 (NZST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VKBgRElfqgK75OXC2wfB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[c&p from my email to lkml; I was asked to forward it here too.  This
occurs on the stock kernels in Debian Lenny and Ubuntu Karmic, as well
as a 2.6.33 I built myself]

Hi,

I've been having some trouble with ip6 duplicate address detection in a
Linux VM (under XVM on OpenSolaris).  It seems that the ethernet bridge
in XVM sends a host's own multicast packets back to it, which the
duplicate address detection code in linux decide that another host on
the network is using the same address.

For instance, running:

router4:~ # ip addr add fe80::216:36ff:fe4e:461c/64 dev eth0


I get the following output in tcpdump:

router4:~ # tcpdump -nevpi eth0 ip6=20
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96
bytes
12:33:03.755897 00:16:36:4e:46:1c > 33:33:00:00:00:16, ethertype IPv6
(0x86dd), length 90: (hlim 1, next-header Options (0) payload length:
36) :: > ff02::16: HBH (rtalert: 0x0000) (padn)[icmp6 sum ok] ICMP6,
multicast listener report v2, length 28, 1 group record(s) [gaddr
ff02::1:ff4e:461c to_ex, 0 source(s)]
12:33:04.551772 00:16:36:4e:46:1c > 33:33:ff:4e:46:1c, ethertype IPv6
(0x86dd), length 78: (hlim 255, next-header ICMPv6 (58) payload length:
24) :: > ff02::1:ff4e:461c: [icmp6 sum ok] ICMP6, neighbor solicitation,
length 24, who has fe80::216:36ff:fe4e:461c
12:33:04.551998 00:16:36:4e:46:1c > 33:33:ff:4e:46:1c, ethertype IPv6
(0x86dd), length 78: (hlim 255, next-header ICMPv6 (58) payload length:
24) :: > ff02::1:ff4e:461c: [icmp6 sum ok] ICMP6, neighbor solicitation,
length 24, who has fe80::216:36ff:fe4e:461c
^C
3 packets captured
3 packets received by filter
0 packets dropped by kernel


And dmesg says:

router4:~ # dmesg
[  371.024287] eth0: IPv6 duplicate address fe80::216:36ff:fe4e:461c
detected!


And the address sits in 'tentative' mode:

router4:~ # ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 00:16:36:4e:46:1c brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.128/24 brd 192.168.2.255 scope global eth0
    inet6 fe80::216:36ff:fe4e:461c/64 scope link tentative flags 08=20
       valid_lft forever preferred_lft forever


This happens for link-local and global scope address, both when they try
to auto-configure and when set by hand:

[  463.500328] eth0: IPv6 duplicate address
2404:130:0:1000:216:36ff:fe4e:461c detected!
[  732.428312] eth0: IPv6 duplicate address
2404:130:0:1000:216:36ff:fe4e:461c detected!
[  883.812328] eth0: IPv6 duplicate address 2404:130::3:2:1 detected!


I'd happily put this down to a failing in XVM, however the stateless
autoconfiguration RFC (4862) states that the stack shouldn't decide an
address is duplicate based on receipt of a neighbor solicitation message
that it sent itself:

5.4.3.  Receiving Neighbor Solicitation Messages
[...]
If the source address of the Neighbor Solicitation is the unspecified
   address, the solicitation is from a node performing Duplicate Address
   Detection.  If the solicitation is from another node, the tentative
   address is a duplicate and should not be used (by either node).  If
   the solicitation is from the node itself (because the node loops back
   multicast packets), the solicitation does not indicate the presence
   of a duplicate address.


Assuming my understanding of the RFC is correct, this suggests to me
that duplicate address detection in Linux is being a little too hasty to
mark the address as invalid.  Thoughts?


Thanks,

Sam Cannell

--=-VKBgRElfqgK75OXC2wfB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (SunOS)

iEYEABECAAYFAkvPXH8ACgkQcuIanIzWkBJgEwCdEfEV6HJdQvh6tosMG88nhnJh
B8UAn3fQyL+30IZXczRU4Gtj1TlMgfE0
=B49K
-----END PGP SIGNATURE-----

--=-VKBgRElfqgK75OXC2wfB--

