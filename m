From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Mon, 26 May 2003 11:34:37 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <87wuge59w2.fsf@deneb.enyo.de>
References: <20030519.181405.35017608.davem@redhat.com>
	<20030519212209.P39592@shell.cyberus.ca>
	<87adda6uro.fsf@deneb.enyo.de>
	<20030526.002934.132904126.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030526.002934.132904126.davem@redhat.com> (David S. Miller's
 message of "Mon, 26 May 2003 00:29:34 -0700 (PDT)")
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

> Let their loss be our gain :-)  No, I am serious, their solution to
> misbehaving flows seems to be just using slow path always and
> continually optimize the slow path.

Exactly, as a result you get stateless IP forwarding whose performance
is mostly independent of the traffic characteristics.

> Now, how about some real explanation about what they are actually
> doing?  Are they replicating the routing table all over the place?

They do this for dCEF.  In this case the CEF data structure are
replicated on every linecard that supports autonomous routing
decisions.  (This is essential for GSRs because the internal bus is
too narrow for almost any communications.  You are lucky if the
routing tables updates do not saturate it.)

> That's one possibility, and would match up to their saying that more
> router memory is required when using CEF.

CEF is essentially yet another copy of the routing table and therefore
requires memory (they do not aggregate prefixes, so some memory is
required for a full Internet routing table.)

> The other possibility is that it's a faster-trie thing generated
> from the normal routing tables.

Yeah, it's some kind of a trie according to a few Cisco documents
(which are a bit self-contradictory, though).

> Since CEF aparently works with QoS and other features, the key must
> be many bits wide.  Probably similar in size to our flowi's.

I don't think IOS QoS is based on (d)CEF.  It's true that on some
Cisco routers, QoS requires (d)CEF-enabled linecards, but I believe
this is just a software design issue and not inherently tied to the
CEF data structures.

So far I've only seen CEF tables with IPv4 addresses as indices. 8-)

> So some bit branching trie based upon flow parameters.  There are
> hundreds of patented such schemes :-)

Just ignore them. 8-)

> Anyways, you keep saying that flow hashing is stupid, can you propose
> an alternative?

Only for pure IPv4 CIDR routing (based on prefixes and destination
addresses).  I'd try the following scheme: split the destination
address into two parts, and use the more significant one as an index
into a table of (function pointer, closure data pointer) pairs.  These
functions return a pointer to the adjacency information.  They can be
implemented in various ways, depending on the structure of the less
significant part (e.g. if only one subnet is routed differently from
the others, a few comparisons are sufficent to identify it).  As a
result, the routing decision could made with one or two indirect calls
and a couple of memory accesses.

For hosts, if the routing table contains less than (say) ten routes,
order it by decreasing prefix length and scan it sequentially for a
match.

In all cases, L2 addresses should be stored indexed by the least
significant bits of the corresponding IP addresses (no hashing
required).

Of course, this will result in vastly decreased functionality (no
arbitary netmasks, no policy-based routing, code will be fine-tuned
for typical Internet routing tables), so this proposal definitely
comes at a price.

(In the meantime, it might be beneficial to use more buckets in the
routing cache and rely less on collision chaining.)
