From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 17:35:23 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089898523.6114.865.camel@uganda>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-O7aaoy7k985PjxHfVPSj"
Cc: netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-O7aaoy7k985PjxHfVPSj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hello, network developers.

I'm glad to introduce CARP failover mechanism implementation.
It is based on OpenBSD's CARP protocol but is not compatible with it
since OpenBSD's implementation does not contain protection against
repeated message sending.

The main goal of the project is to implement CARP + firewall sync, but
second part already implemented by Harald Welte <laforge@gnumonks.org> and=20
KOVACS Krisztian <hidden@sch.bme.hu> in ct_sync.

By design each node has it's own advertisement base and skew, node with
the least timeval constructed from them became a master.
It begins to advertise it's base and skew until shutdown or other node
lower it's base+skew pair.
CARP uses currently only IPv4 multicast, but can be easily changed to
use IPv6.=20
Each CARP packet contains unique 64bit counter with it's SHA1 hmac
digest with 20byte secret key. By design this counter is incremented in
both master and backup before sending and while receiving accordingly.
If master and backup counters do not coincide with each other while
receiving backup node drops this packet and thus preventing repeated
sending attack.
When after predefined interval master didn't send any packet or it's
base+skew is bigger than that in the remote node those node becomes a
master and begins to advertise.

CARP has 2 work queues for "became_master" and "became_backup" events.
Such events may be easily registered in runtime by external modules.
One of such event handlers may send netlink message to ct_sync and/or
userspace daemon which will flush iptables rules, up/down interfaces and
so on...

Please review and comment.

Code against 2.6 attached=20
in next 2 e-mails since netfilter-failover@lists.netfilter.org doesn't acce=
pt
e-mail greater than 40kb.

Code also is available at
http://www.2ka.mipt.ru/~johnpol/carp_latest.tar.gz

--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-O7aaoy7k985PjxHfVPSj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9ogbIKTPhE+8wY0RAuX7AJ4674eNuTtvoUVdQqkU42vRhU23vwCdFE6G
K9Sno/av6js48cchFHTUxuI=
=3Oms
-----END PGP SIGNATURE-----

--=-O7aaoy7k985PjxHfVPSj--
