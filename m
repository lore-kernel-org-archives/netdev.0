From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Wed, 14 Jan 2004 17:22:28 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401141327420.24125@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0401141257200.30270-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>, yoshfuji@linux-ipv6.org
In-Reply-To: <Pine.LNX.4.44.0401141257200.30270-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004, Pekka Savola wrote:

> Please check out draft-thaler-ipv6-ndproxy-xx.txt -- it used ND
> proxying (similar to proxy ARP).

Oh yes, true. I actually checked out the draft some months ago...
(And just re-read it :)

> I fear this change might break that..

I don't think it does. Here's why:

The current proxy ND implementation in the kernel only captures multicast
NS messages. A unicast NS (i.e. a NUD probe) won't be captured by the
proxy, in stead it tries to _route_ it to the proxied node.

No matter what scope the proxied address is, this is incorrect behavior since:

1) the packet will probably be routed back to the original link, unless
   the proxy has a more specific route to the proxied node

2) traffic to a link-local address can't be routed to another link

3) an attempt to route a packet back to the original link would
   just cause the proxy to send another NS for the address it is already
   proxying, eventually resulting in a ICMPv6 Destination Unreachable,
   Code 3 message after the NS has timed out.

4) the unicast ND messages are forwarded to at most one other interface,
   not all of them

5) multicast (ND) messages aren't forwarded at all because of 2 and
   since multicast routing isn't implemented yet AFAIK :(

6) the proxying router decreases the hop count of the packet, thus
   breaking the ND protocols (and other link-local protocols that rely on
   the hop count to remain unchanged.

The traditional proxy described in RFC 2461 is a router, what Thaler
describes is closer to a bridge. The protocol described in Thaler's draft
can't rely on routing for what it is doing, in stead it must AFAICS bypass
the routing altogether, either inside the kernel, or by pushing the
traffic through user space.

These are the real problems you have to address if you want to implement
Thaler's draft on Linux.

In contrast, since 2 always applies (i.e. you can't route link-locals)
this patch only removes the unnecessary steps described in 3 before the
error message is sent.

This shouldn't break anything wrt to draft-thaler-ipv6-ndproxy-01.txt (as
explained), and is a requirement in the MIPv6 specifiaction (as previously
mentioned :)

My other patch with the netfilter module captures the NUD probes once it
proxies an addresses, but the intermediate node faces all the listed
problems before it can even start acting as a proxy for it.

Similarly, issues 1, 2, 5 and 6 will also cause problems for other
protocols than just ND, assuming you don't want all traffic to bypass routing.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
