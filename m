From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Wed, 24 Jul 2013 04:14:20 +0200
Message-ID: <20130724021420.GA10670@order.stressinduktion.org>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:35698 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab3GXCOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 22:14:22 -0400
Content-Disposition: inline
In-Reply-To: <20130723220221.GP10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Wed, Jul 24, 2013 at 12:02:21AM +0200, Stefan Tomanek wrote:
> This change adds a minimum prefix length to the structures of routing rules.
> If a rule is added with a minimum prefix length >0, only routes meeting this
> threshold will be considered. Any other (more general) routing table entries
> will be ignored.
> 
> When configuring a system with multiple network uplinks and default routes, it
> is often convinient to reference the main routing table multiple times - but
> omitting the default route. Using this patch and a modified "ip" utility, this
> can be achieved by using the following command sequence:

Yeah, it is sometimes pretty hideous to set up, especially if one uses
ppp stuff and such. But I am unsure if this change does actually improve
that considerable. Static setups should be easily doable right now and for
ppp/vpn stuff, I fear, it would still lack a bit of flexibility.

Off-topic:
I had the idea of supporting per process routing tables to deal with
that: ip route exec table foo pppd ...
So that every change of pppd and childs would only affect table foo (the
details could be hairy but currently not enough time to find out).

> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
> index 26aa65d..94e9051 100644
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
> @@ -95,8 +95,17 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
>  		goto errout;
>  
>  	err = fib_table_lookup(tbl, &flp->u.ip4, (struct fib_result *) arg->result, arg->flags);
> -	if (err > 0)
> +	if (err > 0) {
>  		err = -EAGAIN;
> +		goto errout;
> +	}
> +	/* do not accept result if the route does not meet the required prefix length */
> +	if (arg->result) {
> +		if (((struct fib_result *)arg->result)->prefixlen < rule->table_prefixlen_min) {
> +			err = -EAGAIN;
> +			goto errout;
> +		}
> +	}
>  errout:
>  	return err;
>  }

I would try to factor the prefixlen_min check out into a
e.g. fib4_rule_constrain function for which a new field in fib_rules_ops
needs to be created as callback. Also it would be nice to have IPv6
support, too. ;)

Greetings,

  Hannes
