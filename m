From: Cedric Lagneau <cedric.lagneau@openwide.fr>
Subject: Fwd: ICMP-REDIRECT paquet & Host ARP TABLE corruption. verified on fedora kernel 3.1.0-7 and ubuntu 11.10 3.0.0
Date: Thu, 08 Dec 2011 09:20:22 +0100 (CET)
Message-ID: <976b21f4-59b8-4ca3-99c0-5f22d25efa02@zimbra2.corp.accelance.fr>
References: <7ff1ebee-b784-4e01-97fa-d8f2dab8de34@zimbra2.corp.accelance.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <dan.carpenter@oracle.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra3.corp.accelance.fr ([213.162.49.233]:46751 "EHLO
	zimbra3.corp.accelance.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445Ab1LHI0O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 03:26:14 -0500
In-Reply-To: <7ff1ebee-b784-4e01-97fa-d8f2dab8de34@zimbra2.corp.accelance.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

original mail:

> hi all,
>=20
> Since kernel =3D> 3.0 we've found some strange behavior with kernel >=
=3D3.0 on our architecture. Some host cannot acces some network anymore=
 after using this Kernel. Verified on ubuntu 11.10 and fedora fc16.
>=20
>=20
> Explaination:
>=20
> Host with simple ip
> default install
> default sysctl.conf :
> net.ipv4.conf.all.accept_redirects=3D1
> net.ipv4.conf.default.accept_redirects=3D1
> no netfilter=20
>=20
> A forged icmp type 5 redirect code 0 or 1 to this host from another h=
ost on the same network corrupt the ARP table with entry for non-local =
network=20
>=20
> sample:
> hostA ip 192.168.2.192/24
> gw 192.168.2.254
>=20
> arp -an=20
> 192.168.2.254 at 00:00:5e:00:01:60
>=20
>=20
> then from a B host , i forge an icmp-redirect paquet like this:
> 192.168.2.254 > 192.168.2.192: ICMP redirect 87.106.170.240 to net 19=
2.168.10.10
>=20
> after that on hostA i do a simple icmp ping to 87.106.170.240 , sent =
arp from hostB and ARP table of hostA is corrupted:
>=20
> arp -an
> 192.168.2.254 at 00:00:5e:00:01:60
> 192.168.10.10 at <incomplete>=20
>=20
>=20
> if i put hostB ip as icmp-redirect gw, hostB receive paquet.=20
>=20
>=20
> Best regards,
>=20
>
> C=C3=A9dric Lagneau


Then :
> So I downloaded an arp forger from:
> http://insecure.org/sploits/arp.games.html
>
> ./icmp_redir 192.168.1.1 192.168.1.101 153.104.63.227 192.168.4.8
>                 (gw)     (3.0 system)   (random ip)   (not on my lan)
>
> I was able to make 153.104.63.227 unroutable on 2.6.39 and higher
> but not on 2.6.38.  The new ip 192.168.4.8 does show up in arp -n
> but it gets cleaned out much faster.
>
>regards,
>dan carpenter

thanks, don't know this tools, i was using python-scarpy to forge icmp =
paquet.

for me bad arp entry is never cleaned and i need to reboot host. arp -d=
 "ip" say this:
SIOCDARP(priv): Network is unreachable

This can cause problems on some architecture like this simplified versi=
on:

----backbone--- "Public network"  with multiple gateways to reach multi=
ple networks. Icmp-redirect allowed.
      |
 Firewall with outgoing NAT 192.168.2.0/24 -> IP from "public network".=
 icmp-redirect blocked on fw to protect internal LAN.
      |
-----LAN------ 192.168.2.0/24  gateway : Firewall

When a lan host want to reach non-local networks  , its ip is natted th=
rough firewall,then session putted inside a state table.

On some firewall like OpenBSD with PF (http://openbsd.org/faq/pf/filter=
=2Ehtml) ICMP-REDIRECT paquet pass through state table nat session.(thi=
s is a feature on openbsd, i've not tested for moment with linux). No w=
ay to block icmp paquet on the firewall because the state table is befo=
re PF...In this case no other choice to use sysctl on all internal host=
 because host insert bad gateway from "public network" provided by icmp=
-redirect.

"
Another advantage of keeping state is that corresponding ICMP traffic w=
ill be passed through the firewall. For example, if a TCP connection pa=
ssing through the firewall is being tracked statefully and an ICMP sour=
ce-quench message referring to this TCP connection arrives, it will be =
matched to the appropriate state entry and passed through the firewall.
"

I know it's a bad idea to use a backbone ip for nat and allow icmp-redi=
rect on a simple host (man in middle inside own network from others hos=
t like you say) but this can happend and this is an example.


regards,

--

C=C3=A9dric Lagneau
