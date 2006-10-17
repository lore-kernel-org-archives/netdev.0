From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 13/13] [RFC] [IPV6] Fix source prefix routing problems when source address undefined.
Date: Tue, 17 Oct 2006 12:14:02 +0200
Message-ID: <20061017101402.GM12964@postel.suug.ch>
References: <4534237B.9090205@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:36325 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932173AbWJQKNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 06:13:41 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <4534237B.9090205@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-10-17 03:27
> @@ -123,7 +111,7 @@ static int fib6_rule_match(struct fib_ru
>  		return 0;
> 
>  	if (r->src.plen) {
> -		if (!(flags & RT6_LOOKUP_F_HAS_SADDR) ||
> +		if (flags & RT6_LOOKUP_F_HAS_SADDR &&
>  		    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
>  			return 0;
>  	}

This is wrong, rules matching on a source prefix must fail if no
source address is available.

>  static struct rt6_info *ip6_pol_route_output(struct fib6_table *table,
> -					     struct flowi *fl, int flags)
> +					     struct flowi *fl, int flags,
> +					     struct fib6_rule *rule)
>  {
>  	struct fib6_node *fn;
>  	struct rt6_info *rt, *nrt;
> @@ -730,6 +733,16 @@ static struct rt6_info *ip6_pol_route_ou
>  	struct in6_addr saddr;
> 
>  	ipv6_addr_copy(&saddr, &fl->fl6_src);
> +#ifdef CONFIG_IPV6_SUBTREES
> +	if (!has_saddr && rule->src.plen > 0) {
> +		/* a source prefix specific policy rule has to override the
> +		   normal source address selection process */
> +		if (ipv6_get_saddr(fl->oif, &fl->fl6_dst, &rule->src, &saddr))
> +			goto no_saddr;
> +		has_saddr = RT6_LOOKUP_F_HAS_SADDR;
> +		ipv6_addr_copy(&fl->fl6_src, &saddr);
> +	}
> +#endif
>  relookup:
>  	read_lock_bh(&table->tb6_lock);

I can see why you want the above change but we have to find another way.
