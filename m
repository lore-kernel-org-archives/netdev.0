From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems when source address undefined.
Date: Tue, 17 Oct 2006 13:35:11 +0200
Message-ID: <20061017113511.GN12964@postel.suug.ch>
References: <4534237B.9090205@tcs.hut.fi> <20061017101402.GM12964@postel.suug.ch> <20061017.200005.70903049.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vnuorval@tcs.hut.fi, davem@davemloft.net, kim.nordlund@nokia.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:37094 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750838AbWJQLeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 07:34:50 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20061017.200005.70903049.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2006-10-17 20:00
> In article <20061017101402.GM12964@postel.suug.ch> (at Tue, 17 Oct 2006 12:14:02 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-10-17 03:27
> > > @@ -123,7 +111,7 @@ static int fib6_rule_match(struct fib_ru
> > >  		return 0;
> > > 
> > >  	if (r->src.plen) {
> > > -		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
> > > +		if (flags & RT6_LOOKUP_F_HAS_SADDR &&
> > >  		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
> > >  			return 0;
> > >  	}
> > 
> > This is wrong, rules matching on a source prefix must fail if no
> > source address is available.
> 
> Why?

Because otherwise a rule containing only a source prefix match is
equivalent to a catch-all rule for all lookups not providing a
source address. An example: Someone adding the rule

	ip rule add from 2001::1/128 unreachable

results in _all_ lookups not providing a source address to
resolve to unreachable which means that all source address
lookups will fail.

> Do you mean that we should decide source address before we look up
> rule and route?

Not necessarly, allowing route lookups with a "any" source address 
and delaying the source address selection is fine but the proposed
way of achieving this is not working.

> We have to allow users to use auto-bind; user may NOT supply a
> source address for the packet.
> Routing is done BEFORE the source address selection (RFC3484 Section 7).

I'm sure you know the RFC better than I do but it is my opinion
that the RFC is not very clear on this point and doesn't consider
the side effects of policy routing and implementation specific
problems at all.

> We have rule for routing lookup with source address.  To get consistent result,
> source address in the rule should be ignored when matching if user is not
> supplied the source.  Instead, we try finding appropriate source address
> which is compliant to the rule.

See the example in my first paragraph and you see this can't possibly
work in its current form.

The problem starts that both the routing decision and source address
selection is both a routing decision sharing the same logic which
are now conflicting as the behaviour for a "from ANY" requires
different logic. In order to solve this, rules must be restricted to
one of these paths, i.e. a rule intending to make certain prefixes
unreachable may not apply to the source selection logic. This can be
achieved using the 'reason' field I proposed in my netconf slides, it
would allow turning the first rule example into

	rule add from 2001::1/128 for INPUT unreachable

which would no longer apply when looking up the source address or
deciding the outgoing route.



