From: David Lamparter <equinox@diac24.net>
Subject: Re: ebtables on a stick
Date: Mon, 28 Nov 2011 15:39:01 +0100
Message-ID: <20111128143901.GA589422@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com>
 <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:51747 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab1K1OjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 09:39:06 -0500
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2011 at 09:10:08AM -0600, Greg Scott wrote:
> I have a situation that needs to route mostly and bridge only a littl=
e bit.=C2=A0=20
>=20
> I have a private internal LAN, 192.168.10.nnn.=C2=A0 But one host in =
the internal side needs a real public IP Address, call it 1.2.115.157.=C2=
=A0 Everything except that public IP host needs to route.  The public h=
ost needs to bridge so it can interact with the world.  But it also nee=
ds to interact with the internal LAN. =20
>=20
> I have a Linux brouter set up with eth0 facing the Internet, eth1 fac=
ing the LAN as follows:
>=20
> ifconfig eth0 1.2.115.146 mask 255.255.255.240
> ifconfig eth1 192.168.10.1 mask 255.255.255.0
[...]

This doesn't answer your question, but your use case is better solved
with proxy arp.

ip route add 1.2.115.157/32 dev eth1
ip neigh add proxy 1.2.115.157 dev eth0
# ... adjust iptables rules to make sure traffic is allowed
# optional, but I'd recommend:
iptables -t raw -I PREROUTING -d 1.2.115.157 -j NOTRACK
iptables -t raw -I PREROUTING -s 1.2.115.157 -j NOTRACK

on the target host:

ip addr add 1.2.115.157/32 dev ethX
ip route add 192.168.10.1/24 dev ethX
ip route add default via 192.168.10.1

no bridge, no ebtables.

you may need to tweak shared_media/icmp redirect settings on the router=
,
should work as-is though.


-David
