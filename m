From: martin f krafft <madduck@madduck.net>
Subject: iproute2: removing primary address removes secondaries
Date: Fri, 11 Jan 2008 17:31:55 +0100
Message-ID: <20080111163155.GA17637@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seamus.madduck.net ([213.203.238.82]:41310 "EHLO
	seamus.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757464AbYAKQ6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 11:58:54 -0500
Received: from wall.oerlikon.madduck.net (84-75-158-163.dclient.hispeed.ch [84.75.158.163])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "wall.oerlikon.madduck.net", Issuer "CAcert Class 3 Root" (verified OK))
	by seamus.madduck.net (postfix) with ESMTP id 4EEA84197C0
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:32:06 +0100 (CET)
Received: from piper.oerlikon.madduck.net (piper.oerlikon.madduck.net [192.168.14.3])
	by wall.oerlikon.madduck.net (Postfix) with ESMTP id A85E49F13A
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:31:55 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dear list,

When I add an address to an interface whose network prefix is the
same as that of an address already bound to the interface, the new
address becomes a secondary address. As per
http://www.policyrouting.org/iproute2.doc.html:

  "secondary --- this address is not used when selecting the default
  source address for outgoing packets. An IP address becomes
  secondary if another address within the same prefix (network)
  already exists. The first address within the prefix is primary and
  is the tag address for the group of all the secondary addresses.
  When the primary address is deleted all of the secondaries are
  purged too."

In the following, I want to argue that this is not necessary.
I think that removal of a primary address should cause the next
address to be promoted to be the default source address and the
link-scoped route to be retained. This is basically out of
http://bugs.debian.org/429689, the maintainer asked me to turn
directly to this list.

If I add an address to a device with 'ip add', ip also implicitly
adds a link-scoped route according to the netmask. It only does this
for primary addresses, so if I add a second address within the same
network, the route is not duplicated.

Thus, the net effect on the routing table is the same for the
following two commands:

  ip a a 172.16.0.100/12 dev eth0 && ip a a 172.16.0.200/12 dev eth0
  ip a a 172.16.0.100/12 dev eth0 && ip a a 172.16.0.200/32 dev eth0
                                                        ^^^^
In the first case, the .200 address becomes a secondary of the .100
address. In the second case, they are both primaries. In both cases,
only one /12 link-scoped route will be created.

However, in both cases, if I remove the .100 address, the .200 is
affected: if it's secondary, it ceases to exist, and if it's
primary (i.e. in the /32 case), then the host can no longer use it
to communicate to hosts in the same link segment, only to hosts on
the other side of the default gateway.

I thus question the point of purging secondary addresses. Obviously,
only one address can be primary (it is used as source address for
packets leaving the machine by the respective route). But if the
primary address is removed, the next secondary should be promoted
and the route should *not* be deleted.

Comments?

Cheers,

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
microsoft: for when quality, reliability, and security
           just aren't that important!
=20
spamtraps: madduck.bogus@madduck.net

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHh5n7IgvIgzMMSnURAsE4AJ9bPi8bsH6LIeh3u8Ch+zLK2JJavgCeMCBq
2IbinoOJ2dzbjtaPK9BqKCY=
=Jdki
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
