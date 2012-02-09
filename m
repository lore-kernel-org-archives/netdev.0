From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Thu, 09 Feb 2012 18:45:19 +0100
Message-ID: <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:45291 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059Ab2BIRpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 12:45:23 -0500
Received: by wics10 with SMTP id s10so1424234wic.19
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2012 09:45:22 -0800 (PST)
In-Reply-To: <4F33FC0E.4020701@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 f=C3=A9vrier 2012 =C3=A0 21:02 +0400, Michael Tokarev a =C3=
=A9crit :
> Hello.
>=20
> I'm observing a situation when just one single IP
> address from entirely different segment gets routed
> locally as if it were in a directly-connected network.
>=20
> Here's how.  The short version, to show the idea, first:
>=20
> A host with single eth0 interface and single IP address
> (not counting loopback interface):
>=20
> $ ip addr
> 8: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast =
state UP qlen 1000
>     link/ether 52:54:c0:a8:b1:02 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.177.2/26 scope global eth0
>=20
> $ ip route
> default via 192.168.177.5 dev eth0
> 192.168.177.0/26 dev eth0  proto kernel  scope link  src 192.168.177.=
2
>=20
> $ ip neigh
> ...
> 192.168.177.5 dev eth0 lladdr 00:90:27:30:6d:1c REACHABLE
> 192.168.177.33 dev eth0 lladdr 38:60:77:25:3f:95 REACHABLE
> 192.168.19.166 dev eth0  FAILED
> 192.168.177.21 dev eth0 lladdr 52:54:c0:a8:b1:15 REACHABLE
>=20
> The address in question is this 192.168.19.166 -- it should
> not be tried on locally connected ethernet segment, but instead
> should go to the (default) gateway at 192.168.177.5.
>=20
> This machine is running 3.0.18 kernel.  The gateway (also
> running this kernel) can access the IP in question just fine
> (it is 2 hops away from the gateway, not reachable directly
> neither from the gw nor from the machine in question).
>=20
> After some searching we found a very very similarly looking
> issue:
>=20
>  http://lists.openwall.net/netdev/2011/11/15/126
>   "Unable to flush ICMP redirect routes in kernel 3.0+"
>=20
> with a good reproducer:
>=20
>  http://lists.openwall.net/netdev/2011/11/16/138
>=20
> The issue however is that, in our case, I can't reproduce
> this problem at all using the way described by Ivan Zahariev
> in the last message: sending redirects from the geateay for
> "random" addresses does not make corresponding "persistent"
> cache entries, once the route on the gw gets removed, that
> IP address starts working again from the machine in question.
>=20
> So now we have only one IP address that behaves like this,
> and I can't get other addresses to repeat its behavour.
>=20
> The problem appeared suddenly, while the network was in
> use.
>=20
> What is also interesting here is that the gateway should
> never send a redirect like that because it has explicit
> route for that network pointing to entirely different
> machine.
>=20
> I can work around the _current_ problem we're facing by
> moving the host in question (192.168.19.166) to another
> IP address.  But I'd love to understand what's going on
> here.
>=20
> Also, it appears that the patch that emerged from the
> mentioned discussion hasn't been released in any
> stable kernels so far - is there some issue with it?
>=20
> And since I can't reproduce the issue here as described
> above, I've one more question: should it be reproducible?
>=20
> And finally, here's some more details about our setup.
> It is actually a "bit" more complex, involving bridges,
> vlans, veth and tap devices.
>=20
> The "host" in question is a lxc guest on veth interface.
> Its veth iface is connected to a bridge "tls-br" on the
> host.  I'm omiting some details still (like other lxc
> guests which have very similar config, and also kvm
> guests with tap interfaces).
>=20
>  host$ ip addr
>  2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast=
 state UP qlen 1000
>      link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
>  3: tls-vlan@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc n=
oqueue master tls-br state UP
>      link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
>  4: tls-br: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue =
state UP
>      link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
>      inet 192.168.177.15/26 brd 192.168.177.63 scope global tls-br
>  9: veth-tsrv: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdi=
sc pfifo_fast master tls-br state UP qlen 1000
>      link/ether 5e:e8:4f:67:80:17 brd ff:ff:ff:ff:ff:ff
>=20
> tls-br connects tls-vlan@eth0 and veth-tsrv.  It has an
> address from the same 192.168.177/26 segment as the guest
> in question.
>=20
>  host$ ip route
>  default via 192.168.177.5 dev tls-br
>  192.168.177.0/26 dev tls-br  proto kernel  scope link  src 192.168.1=
77.15
>  (this is a complete routing table, there's no more routes)
>=20
> What is also very interesting is that this problem with
> this single IP address affects ALL lxc machines on this
> host at once, and the host itself:
>=20
>  host$ ip neigh
>  192.168.177.35 dev tls-br lladdr 6c:f0:49:9d:f2:0c STALE
>  192.168.19.166 dev tls-br  FAILED
>  192.168.177.38 dev tls-br lladdr 38:60:77:25:3f:9c STALE
>  192.168.177.5 dev tls-br lladdr 00:90:27:30:6d:1c DELAY
>  ...
>=20
> (after trying to ping it).
>=20
> Each "subdivision" on this host has its own arp table, but
> every subdivision (host itself or any of it lxc guests which
> all have similar config) always tries to reach thiis very
> IP address directly.
>=20
>  otherLXCguest$ ip n
>  192.168.19.166 dev eth0  INCOMPLETE
>  192.168.177.15 dev eth0 lladdr 00:1f:c6:ef:e5:1b STALE
>  192.168.177.5 dev eth0 lladdr 00:90:27:30:6d:1c DELAY
>=20
> So.. it looks like something does not work right across
> namespaces.
>=20
> Any clue what's going on?
>=20
> Thank you!

Did you try to apply by hand commits :

7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae   // added in 3.2
(route: fix ICMP redirect validation)

and
9cc20b268a5a14f5e57b8ad405a83513ab0d78dc
(ipv4: fix redirect handling)
