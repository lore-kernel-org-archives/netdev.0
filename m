From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to
	KVM guest
Date: Wed, 5 Mar 2014 15:27:07 +0100
Message-ID: <20140305142706.GL5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
	<20140303212759.GW5090@Linus-Debian>
	<1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
	<20140304000041.GY5090@Linus-Debian>
	<624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com>
	<20140304105253.GC5090@Linus-Debian>
	<1663332249.12962360.1393931189285.JavaMail.zimbra@redhat.com>
	<20140304213757.GJ5090@Linus-Debian>
	<521731164.13535687.1394021407825.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Jan Stancek <jstancek@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <521731164.13535687.1394021407825.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Wed, Mar 05, 2014 at 07:10:07AM -0500, Jan Stancek wrote:
>=20
>=20
> ----- Original Message -----
> > From: "Linus L=C3=BCssing" <linus.luessing@web.de>
> > To: "Jan Stancek" <jstancek@redhat.com>
> > Cc: netdev@vger.kernel.org, "Florian Westphal" <fwestpha@redhat.com>,=
 bridge@lists.linux-foundation.org
> > Sent: Tuesday, 4 March, 2014 10:37:57 PM
> > Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to K=
VM guest
> > > I'm not sure if it's Linux (I'm trying to locate that system by MAC=
), but I
> > > see
> > > packets like these on my network every ~125 seconds:
> > >=20
> > > No.     Time        Source                Destination           Pro=
tocol
> > > Length Info
> > >   22675 1334.751135 ::                    ff02::1               ICM=
Pv6   86
> > >   Multicast Listener Query
> >=20
> > It's probably the bridge on this ancient kernel, you might want to
> > backport the following patch:
>=20
> Hi,
>=20
> The example above was from box, which turned out not be running Linux.

Okay, yeah, there's somehow the misconception flying around, that
a snooping switch could use "::" as a source address. Even the
informational RFC4541 writes about "proxy IGMP queries"
disregarding the source address requirements for MLDv1/2, feeding
this misconception. I just skimmed RFC4605 ("IGMP/MLD Proxying")
briefly, but couldn't find any note for "0.0.0.0" or "::" there.
But I think we could see with your practical example, that "::"
MLD query source addresses should be considered broken.

>=20
> >=20
> > If these patches on host B xor the sanity check I just submitted appl=
ied
> > on your host A / VM host fix your issue, then they might be worth
> > considering for the stable queue.
>=20
> Is it necessary to apply same patch also on any (older) kernel running =
in VM?

The source address patches are only required on boxes where the
internal MLD querier code of the bridge is used. Afaik tell the
source address patch is present on all kernels since v2.6.38 and
all kernels listed on the kernel.org frontpage, except 2.6.34.15
and 2.6.32.61.

For the sanity check patch, it should probably be added to any
kernel having a bridge (though in your particular scenario and
what we are currently debugging at, having it on host A should
be sufficient).

> I hand-crafted one new packet from malformed one used in previous tests=
.
> I modified source address from :: to host B link-scope address and chan=
ged
> dst address from ff02::1 to ff02::1:ffaa:aaaa

Okay, again according to your capture the guest is receiving the
MLD query on its interface but does not react with an MLD report.

Two things I'd like to know:

Is using the link-scope address as a source and "ff02::1" as the
destination address for the MLD query work for you?

Is using the link-scope address as a source and "ff02::1:ff00:29"
as the destination address for the MLD query "work" for you (do
we see an MLD report from the guest and keep on seeing neighbor
solicitations from host B then?).

For the latter, I don't see anything in particular filtering these
for a general MLD query wrong destination address in the IPv6
code from igmp6_event_query() on. But I suspect that the query
doesn't even get that far on the kernel of the guest, as it is not
listening on ff02::1:ffaa:aaaa. Therefore the test with
"ff02::1:ff00:29", an address the guest is listening on, would be
interesting.

If that works, then I'm going to make a patch ignore General MLD
Queries without ff02::1 as their destination address, too.


Hm, looking at more checks in igmp6_event_query(), I'm currently
wondering whether we should only enable the snooping behaviour in
the bridge when receiving a General MLD Query, so one with "::" in
the multicast field of the MLD message, instead of activating it
upon a Multicast-Address-Specific Query, too. That'd seem more
sane to me, I'm going to make a patch for that tomorrow.

Cheers, Linus
