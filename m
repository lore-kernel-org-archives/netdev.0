From: David Miller <davem@davemloft.net>
Subject: Re: Bug in net/ipv6/ip6_fib.c:fib6_dump_table()
Date: Sat, 23 Jun 2012 16:02:23 -0700 (PDT)
Message-ID: <20120623.160223.2001034730073626964.davem@davemloft.net>
References: <20120622.170237.1504103690155447356.davem@davemloft.net>
	<1340429851.4604.11942.camel@edumazet-glaptop>
	<20120623205546.GA15964@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, johunt@akamai.com, kaber@trash.net,
	dbavatar@gmail.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jmorris@namei.org, pekkas@netcore.fi,
	linux-kernel@vger.kernel.org, greearb@candelatech.com
To: kuznet@ms2.inr.ac.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120623205546.GA15964@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Sun, 24 Jun 2012 00:55:46 +0400

> IPv6 routing table has a capital management drawback: core policy
> rules are mixed with dynamic cache and addrconf routes in one
> structure.  (BTW it is one of reasons why I did not want to
> integrate routing cache to fib for IPv4)

Yes, and this causes other problems too.  Recently I had to make the
dst cache not count pure ipv6 routes otherwise cache size limited how
many actual routes administrator could add.

I would like to eventually make ipv4 and ipv6 more similar rather than
more different.  BTW, decision to use different host models (weak vs.
strong) in the two stacks was another idiotic move which makes
consolidation and code auditing harder.

I think once my long work to kill the ipv4 routing cache is complete
and successful we can model ipv6 after the results.

Major blockers are in two areas, reliance upon rt->rt_dst and...
performance :-)

Main reliance upon rt->rt_dst are:

1) Neighbours, which I plan to move to a model where lookups are
   done on demand using RCU and lack of refcounts.

   There are a few stragglers in infiniband and elsewhere that still
   want to get a neighbour from a dst and I haven't converted over to
   a lookup-on-demand model.  I'm slowly working through those but it
   is painful and thankless work.

   It also involved trying to figure out reliable replacements for
   magic tests like:

	if (!dst_get_neighbour_noref_raw(&rt->dst) && !(rt->rt6i_flags & RTF_NONEXTHOP))

   in ipv6.  Really, the set of ipv6 dsts which have a neighbour
   pre-attached is non-trivial to describe via other means.

   dst_confirm() is left, which I'll handle by setting a "neigh
   confirm pending bit", and next packet output when we have the neigh
   looked up we'll update it's state and clear the bit in the dst.  Or
   something like this.  Maybe a u8 or an int instead of a flag so we
   don't need atomic ops.

   Divorcing neigh from dst can have another huge benefit, no more
   neighbour table overflow because small prefixed route for very
   active subnets with improperly adjusted neighbour cache sizing.
   We'll have more freedom to toss neighs because they'll be largely
   ref-less unlike now where every route to external place holds onto
   neigh.

2) Metrics, which really must be done differently.

   Currently the scheme I have in mind is:

   a) Pure TCP metrics move into RCU ref-count-free table and are
      accessed on-demand.  When TCP connection starts up, TCP fetches
      metrics block from table.  When TCP connection closes, TCP
      pushes new metrics values into table.

   b) PMTU and redirect information is moved back into route.

      We clone new routes in FIB trie when PMTU or redirects are
      received.

   Metric table will be rooted in FIB table like inetpeer is now.

   Inetpeer will become nearly orphan once more, only used for IP ID
   generation and IPv4 fragment ID wrap detection.

Then we have no more need for rt->rt_dst to point to a specific IP
address once the routing cache is removed.  It means we can use
routes constructed completely inside of FIB trie entries.

Next is worse area, performance.  I can easily make output route
lookups fast without the routing cache, but input... mama mia!

Problems are two-fold:

1) Separation of local and main table, I plan to combine them.  Well,
   this applies to output and input routes.

   This was really a terrible design decision.  Only the most obscure
   critters take advantage of this separation, yet everyone pays the
   price.  What's more their goals can be achieved by other means.

   It means that every fib_lookup() is essentially two FIB trie
   traversals instead of just one.

2) fib_validate_source(), really it is the most painful monster and
   should never have been put into the FIB.  It is really a netfilter
   service, at best.

   It means that, for forwarding global routes, we currently make 4
   FIB trie traversals.  FOUR.  So no matter how fast Robert Olsson
   made fib_trie, it still needs to be consulted 4 times.

   I've tried to come up with algorithms that do this validation
   cheaply.  Especially for default typical configuration where this
   kind of check is especially stupid and pointless.  I have not had
   any major breakthroughs.

   For a workstation or typical one-interface server, it we eliminate
   loopback anomalies earlier in the path, it can be a simple check I
   suppose.

   I plan to facilitate this also by making non-unicast specific
   destination determination on-demand.  Then there is class ID
   determination, another huge hardship on everyone created by a
   feature with a tiny class of users.

Anyways, that is brain dump.
