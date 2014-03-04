From: Jan Stancek <jstancek@redhat.com>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM
 guest
Date: Tue, 4 Mar 2014 03:02:36 -0500 (EST)
Message-ID: <624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com> <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com> <20140303212759.GW5090@Linus-Debian> <1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com> <20140304000041.GY5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:52282 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756262AbaCDICi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 03:02:38 -0500
In-Reply-To: <20140304000041.GY5090@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>,=
 bridge@lists.linux-foundation.org
> Sent: Tuesday, 4 March, 2014 1:00:41 AM
> Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to K=
VM guest
>=20
> Hi Jan,
>=20
> On Mon, Mar 03, 2014 at 05:45:49PM -0500, Jan Stancek wrote:
> > There is also bridge on host B. I assume that doesn't matter
> > but I could set up host B without bridge if needed.
>=20
> It can matter, but in this case it doesn't :).
>=20
> > > What I'm curious about is, whether the guest receives
> > > the MLD query and responds with an MLD report. I suspect that
> > > either the bridge doesn't get an MLD report and therefore is
> > > shutting down the according port or there's a bug in parsing the
> > > MLD report in the bridge code.
> >=20
> > I'm no expert in this area, but shouldn't neigh. solicit packets
> > be forwarded to all ports regardless of any/no MLD reports?
>=20
> That's the beauty of IPv6 Neighbor Discovery using these neat
> solicited-node multicast addresses :). With IPv4 and ARP
> requests there's no other way than flooding. But for IPv6 we know
> in advance behind which bridge port someone interested in the
> neighbor solicitation message might be (assuming MLD is working,
> properly), allowing us to save bandwidth.
>=20
> In this case, MLD is not working properly, the main issue is the
> following:
>=20
> Host B sends broken MLD queries, the source address should be an
> IPv6 link-local one, not "100:0:600:0:78fb:100::". MLDv2 mandates
> this (see RFC3810, section 5.1.14.: "Source Addresses for
> Queries").
>=20
> Though I couldn't find that requirement for MLDv1, Linux ignores
> MLDv1 queries with a non-link-local source address, too (see
> net/ipv6/mcast.c, igmp6_event_query() ). So Linux never sends an
> MLD report in reply to these broken queries.
>=20
>=20
> The second "minor" but in this case fatal issue is, that the
> bridge code doesn't have this link-local-src check, therefore
> kicking the snooping into gear even though it shouldn't because we
> don't have a _working_ querier.
>=20
> I'm going to make a patch for the bridge code adding this sanity
> check.
>=20
>=20
> For the broken query, ok, it's your manually crafted query. But
> did you see a query with such a bogus source address "in the
> wild", too? (I'm curious how urgent this sanity check is)

It's real packet I managed to capture during one such occurrence.
I'm sending it with small C program over raw socket, but it's byte
by byte exact copy of what I captured with tcpdump previously.

I'm not sure how that packet came to existence. Based on IPv6 address
it came from host B, but all host B was doing at the time
was running RHEL6 with couple qemu-kvm instances. KVM guests were
set up to use bridge, so I'm assuming if any of them crafted
this packet, source IPv6 address would be different.

Regards,
Jan

>=20
> Cheers, Linus
>=20
