From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: Re: [PATCH v4 net-next 1/2] ipv4: L3 hash-based multipath
Date: Thu, 24 Sep 2015 01:09:44 +0200
Message-ID: <20150924010944.2a1b066a@pch.odense.ordbogen.com>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
	<1443037777-25390-2-git-send-email-pch@ordbogen.com>
	<CALx6S37RRMvXCK4CnQgt2QicKHGUnoV3w0sycERx44RYMsYeNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:43914 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755037AbbIWXJv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 19:09:51 -0400
In-Reply-To: <CALx6S37RRMvXCK4CnQgt2QicKHGUnoV3w0sycERx44RYMsYeNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2015 14:00:43 -0700
Tom Herbert <tom@herbertland.com> wrote:

> On Wed, Sep 23, 2015 at 12:49 PM, Peter N=C3=B8rlund <pch@ordbogen.co=
m>
> wrote:
> > Replaces the per-packet multipath with a hash-based multipath using
> > source and destination address.
> >
> It's good that round robin is going away, but this still looks very
> different with how multipath routing is done done in IPv6
> (rt6_multipath_select and rt6_info_hash_nhsfn). For instance IPv4
> hashes addresses, but IPv6 includes ports. How can we rectify this?
>=20

I may be wrong, since I haven't delved that much into the IPv6 code, bu=
t
rt6_multipath_select is nice and clean because it doesn't have to burde=
n
with different weights of the paths.

As for not including the ports, it is for the sole purpose of not
disruption the flow when fragmented packets are received. This is more
likely with IPv4 than with IPv6, since PMTUD is optional with IPv4. In
an ideal world, the IPv6 code shouldn't look at anything but addresses
and flow label either, based on the principle that the router shouldn't
care about L4 and above (but then it shouldn't look at ICMP either, heh=
)
- but I know this isn't an ideal world and I have no operational
experience with IPv6, so I can't tell whether clients populate the flow
label properly.

I=CD=84 would argue that L3-based hashing is more than sufficient for
most websites and ISPs, where the number of addresses is high. At least
on the network I have access to, L4 gave very little extra (3%). But I
knew linux users would be demanding L4 hashing despite my beliefs, and
there would probably even be people missing the per-packet multipath.
This is why I started out reintroducing the RTA_MP_ALGO attribute in
my original patch.

To be honest, L4 might almost work in my network which hosts a
few relatively large Danish websites. Fragmentation is only a problem o=
n
clients not doing PMTU (~10%) having large HTTP cookies (very few). But
to these people, they'll have a 50% chance of not being able to access
our sites at all, because packets are distributed to load balancers
which have not been updated with the connection state yet.

My goal is to create the right solution, and to me the right solution
is a solution which doesn't break anything whatsoever. It doesn't cause
out-of-order packets or lost packets just to utilize some links
better. ECMP, Link Aggregation, anycast and load balancers are all
hacks, if you ask me - and these hacks must be careful to not destroy
the illusion that an IP address maps to a single host and the path to
that host is through one cable.

If you all disagree, I'll change it - no problem. Just about anything
is better than the per-packet solution. But I'll have to consider
whether we will be running a modified version of the multipath code in
my network.

Best regards,
 Peter N=C3=B8rlund
