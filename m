From: Jan Stancek <jstancek@redhat.com>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to KVM
 guest
Date: Wed, 5 Mar 2014 09:57:52 -0500 (EST)
Message-ID: <1662523546.13613467.1394031472806.JavaMail.zimbra@redhat.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com> <20140304000041.GY5090@Linus-Debian> <624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com> <20140304105253.GC5090@Linus-Debian> <1663332249.12962360.1393931189285.JavaMail.zimbra@redhat.com> <20140304213757.GJ5090@Linus-Debian> <521731164.13535687.1394021407825.JavaMail.zimbra@redhat.com> <20140305142706.GL5090@Linus-Debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:33241 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbaCEO5z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 09:57:55 -0500
In-Reply-To: <20140305142706.GL5090@Linus-Debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





----- Original Message -----
> From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>,=
 bridge@lists.linux-foundation.org
> Sent: Wednesday, 5 March, 2014 3:27:07 PM
> Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to K=
VM guest

<snip>

>=20
> > I hand-crafted one new packet from malformed one used in previous t=
ests.
> > I modified source address from :: to host B link-scope address and =
changed
> > dst address from ff02::1 to ff02::1:ffaa:aaaa
>=20
> Okay, again according to your capture the guest is receiving the
> MLD query on its interface but does not react with an MLD report.
>=20
> Two things I'd like to know:
>=20
> Is using the link-scope address as a source and "ff02::1" as the
> destination address for the MLD query work for you?

Yes, I could not trigger it with such query:
http://jan.stancek.eu/tmp/neigh_solicit_and_bridge_traces2/guest_mld_qu=
ery_ff02_1.cap
  frame 795 -> query
  frame 1040 -> MLD report from guest
  ~20 seconds later
  frame 1507, 1508 -> neigh solicit/advert
  frame 1580, 1581 -> neigh solicit/advert

>=20
> Is using the link-scope address as a source and "ff02::1:ff00:29"
> as the destination address for the MLD query "work" for you (do
> we see an MLD report from the guest and keep on seeing neighbor
> solicitations from host B then?).

Yes, this also worked (though I received 2 reports):
http://jan.stancek.eu/tmp/neigh_solicit_and_bridge_traces2/guest_mld_qu=
ery_ff02_1_ff0029.cap
  frame 446 -> query
  frame 448 -> MLD report from guest
  frame 465 -> MLD report from guest
  frame 689, 690 -> neigh solicit/advert
  frame 760, 761 -> neigh solicit/advert
  ...

Both host and guest were running 3.14.0-rc5 with your sanity check patc=
h.

Regards,
Jan

>=20
> For the latter, I don't see anything in particular filtering these
> for a general MLD query wrong destination address in the IPv6
> code from igmp6_event_query() on. But I suspect that the query
> doesn't even get that far on the kernel of the guest, as it is not
> listening on ff02::1:ffaa:aaaa. Therefore the test with
> "ff02::1:ff00:29", an address the guest is listening on, would be
> interesting.
>=20
> If that works, then I'm going to make a patch ignore General MLD
> Queries without ff02::1 as their destination address, too.
>=20
>=20
> Hm, looking at more checks in igmp6_event_query(), I'm currently
> wondering whether we should only enable the snooping behaviour in
> the bridge when receiving a General MLD Query, so one with "::" in
> the multicast field of the MLD message, instead of activating it
> upon a Multicast-Address-Specific Query, too. That'd seem more
> sane to me, I'm going to make a patch for that tomorrow.
>=20
> Cheers, Linus
>=20
