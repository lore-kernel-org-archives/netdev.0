From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Tue, 3 Jun 2003 00:42:25 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <OFC24CC8C1.0DBE47E0-ON88256D3A.00212C36@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>, krkumar@us.ibm.com, <davem@redhat.com>,
	<kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
List-Id: netdev.vger.kernel.org






>Umm.. every prefix should have an interface route, so they're a required
>subset of the routing table, correct?

I'm not sure that it has to be, except if you make that the only way to
access prefix list information. :-)

Administrators and routing daemons are free to mess with the routing table
in creative ways (aggregating,
creating static routes to enforce some policy, whatever), but when the
routing table holds more than just routing
information, either those routes can't be messed with, or the prefix
information is lost. And that's more relevant
when not using address autoconfiguration. The prefix list information
that's relevant is the prefix, the prefix length
and the M and O bits, as they were in the router advertisement. For routing
purposes, it wouldn't be a problem
to aggregate interface routes that cover a contiguous portion of the
address space, but doing that would lose
the prefix information if the routing table is your only source. So,
routing daemons would have to check a
funky flag and leave prefix-list-relevant routes alone.

M and O bits are per-interface; they have no relevance at all in the
routing table, but they'd all have to be
updated if they changed.

There is an example already where routes are installed for per-interface
information: local addresses. There
are host routes corresponding to local addresses in the routing table now,
but there is also a list of local
addresses associated with the interface. Is that a bad idea? Certainly,
it's possible to flag all of the host
routes that are for local addresses (really, just check for interface
loopback) and search the entire routing
table when trying to answer the question "what addresses are on this
interface," but it's much better to have
that address list associated directly with the interface (especially for
source selection).

The consumers of prefix list (DHCPv6 and mobile IPv6) need the entire
prefix list, length and M&O bits for a
given interface. The prefixes (the key) aren't known for the search, and no
other interfaces or destination routes
are ever interesting for those consumers. The interface routes can be
deleted, forced to something else, or
modified now without losing any information, because they are only relevant
for packet routing. If the prefix
information is divined from the routing table, the interface routes
suddenly contain more than routing information,
and should then have special restrictions on them that other routes don't
have (they should be immutable).

I don't think that's a good idea, when you can hang the prefix list right
off the interface and return the full list
whenever you need it. The interface routes can be overridden or aggregated
without messing at all with the
prefix list information. That seems pretty simple to me.

                        +-DLS

