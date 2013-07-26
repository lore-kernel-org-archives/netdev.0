From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Fri, 26 Jul 2013 19:05:56 +0200
Message-ID: <20130726170556.GA11434@order.stressinduktion.org>
References: <20130725221116.GC10216@zirkel.wertarbyte.de> <20130726104657.GF10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41591 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab3GZRF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 13:05:58 -0400
Content-Disposition: inline
In-Reply-To: <20130726104657.GF10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 12:46:57PM +0200, Stefan Tomanek wrote:
>  		if (err != -EAGAIN) {
> +			if (ops->suppress && ops->suppress(rule, arg)) {
> +				continue;
> +			}
>  			if ((arg->flags & FIB_LOOKUP_NOREF) ||
>  			    likely(atomic_inc_not_zero(&rule->refcnt))) {
>  				arg->rule = rule;
>
> [...]
>
> +static int fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> +	struct rt6_info *rt = (struct rt6_info *) arg->result;
> +	/*
> +	 * do not accept result if the route does
> +	 * not meet the required prefix length
> +	 */
> +	if (rt->rt6i_dst.plen < rule->table_prefixlen_min) {
> +		return 1;
> +	}
> +	return 0;
> +}

Urks, fib6_rule_action is broken. The switch (rule->action) does update the rt
entry but does not signal the correct error code to stop iterating the rules
in case it finds a blackhole, prohibit etc. action (it always signals
-EAGAIN).

A change in this logic could have impact to your patch as I currently
don't know how the null handling of arg->result will turn out. IPv6 does not
preinitialize arg->result as IPv4 does.

I am looking for a solution.

Thanks,

  Hannes
