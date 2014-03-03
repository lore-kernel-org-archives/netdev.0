From: Jan Stancek <jstancek@redhat.com>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM
 guest
Date: Mon, 3 Mar 2014 17:45:49 -0500 (EST)
Message-ID: <1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com> <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com> <20140303212759.GW5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:56161 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbaCCWpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 17:45:51 -0500
In-Reply-To: <20140303212759.GW5090@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>,=
 bridge@lists.linux-foundation.org
> Sent: Monday, 3 March, 2014 10:27:59 PM
> Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to K=
VM guest
>=20
> Hi Jan,
>=20
> On Mon, Mar 03, 2014 at 02:47:15PM -0500, Jan Stancek wrote:
> > I'm seeing an issue where bridge (sometimes) stops forwarding ICMP6
> > neighbor solicitation packets to KVM guest and as result KVM guest =
doesn't
> > respond with neighbor advertisement.
>=20
> Hm, okay, that's not supposed to happen.
>=20
> > The reason I think this packet is related is because when I send sa=
me exact
> > packet I'm often hitting same issue - bridge stops forwarding ICMP6=
 neigh.
> > solicitation packets to KVM guest.
>=20
> Yes, the MLD query is kicking the multicast snooping into gear. If
> there's never a query, then snooping is basically disabled
> (compare: "bridge: disable snooping if there is no querier").
>=20
> >=20
> > My current way to reproduce this is:
> > 0. host B IP / MAC is: 2620:52:0:1040:221:5aff:fe47:931c /
> > 00:21:5a:47:93:1c
> >    guest IP / MAC is: 2620:52:0:1040:5056:ff:fe00:29 / 52:56:00:00:=
00:29
> > 1. host B is sending neigh solicit packets every 5 seconds with KVM=
 guest
> > IP
> >    using ns6 from ipv6toolkit:
> >    http://www.si6networks.com/tools/ipv6toolkit/
> >    with parameters:
> >    --src-address=3D2620:52:0:1040:221:5aff:fe47:931c
> >    --dst-address=3Dff02::1:ff00:0029
> >    -t 2620:52:0:1040:5056:ff:fe00:29 --link-src-address=3D00:21:5a:=
47:93:1c
> >    --source-lla-opt=3D00:21:5a:47:93:1c --link-dst-address=3D33:33:=
ff:00:00:29
> >    tcpdump running on guest can see both solicit and advertisement =
packets
> > 2. wait ~5 minutes
> > 3. host B sends Multicast Listener Query packet described above
> > 4. tcpdump running on guest is no longer seeing any neigh solicit p=
ackets
>=20
> Just to clarify, host B is behind eno1 and vnet0 is directly
> connected to the interface of the guest, no additional bridge or
> anything else on top of that, right?

Yes, host B should be behind eno1 (All hosts are remote to me).
There should be only single bridge on host A. Host A has 3 more
interfaces but those are all down.

# cat /etc/sysconfig/network-scripts/ifcfg-eno1
DEVICE=3Deno1
ONBOOT=3Dyes
BRIDGE=3Dbr1
HWADDR=3D00:23:ae:ed:1a:00

# cat /etc/sysconfig/network-scripts/ifcfg-br1
DEVICE=3Dbr1
BOOTPROTO=3Ddhcp
ONBOOT=3Dyes
TYPE=3DBridge
DELAY=3D0

There is also bridge on host B. I assume that doesn't matter
but I could set up host B without bridge if needed.

>=20
> Would it be possible for you to upload the tcpdumps from host B
> (or if you can't tcpdump on host B, then capturing on eno1)
> and the guest somewhere and saying at which time/packet in the dumps
> it stops working (probably ~10 seconds after the query). Filtering
> for ICMPv6 should be sufficient.

Here are tcpdumps from hostA, hostB and guest (on hostA):
http://jan.stancek.eu/tmp/neigh_solicit_and_bridge_traces1/

I didn't apply any filter, because that multicast query wasn't showing =
up
for some reason when I tried to filter by icmp6.

What I did:
1. started tcpdump on all systems
2. send 3 neigh. solicit from hostB manually with couple seconds in bet=
ween
3. send multicast listener query from hostB manually
4. send 5 neigh. solicit from hostB manually with couple seconds in bet=
ween

hostA.cap
tcpdump -i eno1 -w hostA.cap
  frame 124, 125 -> OK
  frame 217, 218 -> OK
  frame 291, 292 -> OK
  frame 373 -> Multicast Listener Query
  frame 484 -> no reply?
  frame 572 -> no reply?
  frame 665 -> no reply?

hostB.cap
tcpdump -i br0 -w hostB.cap
  frame 106, 108 -> OK
  frame 214, 216 -> OK
  frame 300, 302 -> OK
  frame 396 -> Multicast Listener Query
  frame 523 -> no reply?
  frame 623 -> no reply?
  frame 730 -> no reply?

guest.cap
tcpdump -i eth0 -w guest.cap
  frame 89, 90 -> OK
  frame 181, 182 -> OK
  frame 254, 255 -> OK
  frame 334 -> Multicast Listener Query
  no more neigh. solicit packets

>=20
> What I'm curious about is, whether the guest receives
> the MLD query and responds with an MLD report. I suspect that
> either the bridge doesn't get an MLD report and therefore is
> shutting down the according port or there's a bug in parsing the
> MLD report in the bridge code.

I'm no expert in this area, but shouldn't neigh. solicit packets
be forwarded to all ports regardless of any/no MLD reports?

Regards,
Jan

>=20
>=20
> Thanks for the detailed report so far!
>=20
> Cheers, Linus
>=20
