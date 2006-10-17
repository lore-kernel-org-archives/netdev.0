From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems
 when source address undefined.
Date: Tue, 17 Oct 2006 20:00:05 +0900 (JST)
Message-ID: <20061017.200005.70903049.yoshfuji@linux-ipv6.org>
References: <4534237B.9090205@tcs.hut.fi>
	<20061017101402.GM12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, davem@davemloft.net, kim.nordlund@nokia.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44557 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1423028AbWJQK5d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 06:57:33 -0400
To: tgraf@suug.ch
In-Reply-To: <20061017101402.GM12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061017101402.GM12964@postel.suug.ch> (at Tue, 17 Oct 2006 12:14:02 +0200), Thomas Graf <tgraf@suug.ch> says:

> * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-10-17 03:27
> > @@ -123,7 +111,7 @@ static int fib6_rule_match(struct fib_ru
> >  		return 0;
> > 
> >  	if (r->src.plen) {
> > -		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
> > +		if (flags & RT6_LOOKUP_F_HAS_SADDR &&
> >  		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
> >  			return 0;
> >  	}
> 
> This is wrong, rules matching on a source prefix must fail if no
> source address is available.

Why?

> >  static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
> > -					     struct flowi *fl, int flags)
> > +					     struct flowi *fl, int flags,
> > +					     struct fib6_rule *rule)
> >  {
> >  	struct fib6_node *fn;
> >  	struct rt6_info *rt, *nrt;
> > @@ -730,6 +733,16 @@ static struct rt6_info *ip6_pol_route_ou
> >  	struct in6_addr saddr;
> > 
> >  	ipv6_addr_copy(&saddr, &fl->fl6_src);
> > +#ifdef CONFIG_IPV6_SUBTREES
> > +	if (!has_saddr && rule->src.plen > 0) {
> > +		/* a source prefix specific policy rule has to override the
> > +		   normal source address selection process */
> > +		if (ipv6_get_saddr(fl->oif, &fl->fl6_dst, &rule->src, &saddr))
> > +			goto no_saddr;
> > +		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
> > +		ipv6_addr_copy(&fl->fl6_src, &saddr);
> > +	}
> > +#endif
> >  relookup:
> >  	read_lock_bh(&table->tb6_lock);
> 
> I can see why you want the above change but we have to find another way.

Please explain.

Do you mean that we should decide source address before we look up
rule and route?


We have to allow users to use auto-bind; user may NOT supply a
source address for the packet.
Routing is done BEFORE the source address selection (RFC3484 Section 7).

We have rule for routing lookup with source address.  To get consistent result,
source address in the rule should be ignored when matching if user is not
supplied the source.  Instead, we try finding appropriate source address
which is compliant to the rule.

--yoshfuji
