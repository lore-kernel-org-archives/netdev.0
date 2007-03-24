From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH]: Fix ipv6 round-robin locking
Date: Sun, 25 Mar 2007 00:40:30 +0100
Message-ID: <20070324234030.GG521@postel.suug.ch>
References: <20070324.124436.104040932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:40416 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932875AbXCXXkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 19:40:10 -0400
Content-Disposition: inline
In-Reply-To: <20070324.124436.104040932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2007-03-24 12:44
>     As per RFC2461, section 6.3.6, item #2, when no routers on the
>     matching list are known to be reachable or probably reachable we
>     do round robin on those available routes so that we make sure
>     to probe as many of them as possible to detect when one becomes
>     reachable faster.
>     
> +static struct rt6_info *find_match(struct rt6_info *rt, int oif, int strict,
> +				   int *mpri, struct rt6_info *match)
>  {
> +	int m;
> +
> +	if (rt6_check_expired(rt))
> +		goto out;
> +
> +	m = rt6_score_route(rt, oif, strict);
> +	if (m < 0)
> +		goto out;
> +
> +	if (m > *mpri) {
> +		if (strict & RT6_LOOKUP_F_REACHABLE)
> +			rt6_probe(match);
> +		*mpri = m;
> +		match = rt;
> +	} else if (strict & RT6_LOOKUP_F_REACHABLE) {
> +		rt6_probe(rt);
> +	}
> +
> +out:
> +	return match;
> +}

First of all, I haven't spotted any errors in your patch.

Seondly, I'm not sure I've fully understood why this round robin mechanism
is needed to ensure as many routers as possible are probed as soon as
possible. I'd understand it if we'd only probe just one router per selection
process but to my undertanding we try and probe _all_ routers as long as
its score is positive (and rate limitation doesn't step in). The score can
only be negative  if rt6_check_dev() returns 0, the neighbour state is
NUD_FAILED or not present at all. I don't see how the position in the list
would have any affect on this. rt6_select() is called for all routers
regardless of its score, the position of a router doesn't matter.

The only effect of this code I can see is that we return a different
_probably_ reachable router while no router is reachable. This would implement
what item #1 of 6.3.6 proposes.

I'm just making sure we know what we're doing :-)
