From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] fib_rules: add .suppress operation
Date: Sat, 27 Jul 2013 09:07:58 +0200
Message-ID: <20130727070758.GA23904@order.stressinduktion.org>
References: <20130725221116.GC10216@zirkel.wertarbyte.de> <20130726104657.GF10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Andrew Collins <bsderandrew@gmail.com>
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42709 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab3G0HH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 03:07:59 -0400
Content-Disposition: inline
In-Reply-To: <20130726104657.GF10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hm, IPv4 actually seems to have the same problem:

On Fri, Jul 26, 2013 at 12:46:57PM +0200, Stefan Tomanek wrote:
> +static int fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> +	/* do not accept result if the route does not meet the required prefix length */
> +	struct fib_result *result = (struct fib_result *) arg->result;
> +	if (result->prefixlen < rule->table_prefixlen_min) {
> +		return 1;
> +	}
> +	return 0;
> +}

In case of suppressing the route, we need to decrement the reference counter
of fib_info:

if (!(fib_flags & FIB_LOOKUP_NOREF))
	fib_info_put(result->fi);	


Also:

> index e361f48..bb15664 100644
> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -18,6 +18,7 @@ struct fib_rule {
>         u32                     pref;
>         u32                     flags;
>         u32                     table;
> +       u8                      table_prefixlen_min;
>         u8                      action;
>         u32                     target;
>         struct fib_rule __rcu   *ctarget;
> @@ -46,6 +47,8 @@ struct fib_rules_ops {   
>         int                     (*action)(struct fib_rule *,
>                                           struct flowi *, int,
>                                           struct fib_lookup_arg *);
> +       int                     (*suppress)(struct fib_rule *,
> +                                           struct fib_lookup_arg *);

          bool and true/false would be nicer.

>         int                     (*match)(struct fib_rule *,
>                                          struct flowi *, int);
>         int                     (*configure)(struct fib_rule *,
> 

Greetings,

  Hannes
