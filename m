From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Avoid overhead when no custom FIB rules are
 installed.
Date: Fri, 06 Jul 2012 07:41:22 +0200
Message-ID: <1341553282.3265.49.camel@edumazet-glaptop>
References: <20120705.223142.2236039770560842377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61611 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab2GFFl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 01:41:28 -0400
Received: by eeit10 with SMTP id t10so3466745eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 22:41:27 -0700 (PDT)
In-Reply-To: <20120705.223142.2236039770560842377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 22:31 -0700, David Miller wrote:
> If the user hasn't actually installed any custom rules, or fiddled
> with the default ones, don't go through the whole FIB rules layer.
> 
> It's just pure overhead.
> 
> Instead do what we do with CONFIG_IP_MULTIPLE_TABLES disabled, check
> the individual tables by hand, one by one.
> 
> Also, move fib_num_tclassid_users into the ipv4 network namespace.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

> +static inline int fib_lookup(struct net *net, struct flowi4 *flp,
> +			     struct fib_result *res)
> +{
> +	if (!net->ipv4.fib_has_custom_rules) {
> +		if (net->ipv4.fib_local &&
> +		    !fib_table_lookup(net->ipv4.fib_local, flp, res,
> +				      FIB_LOOKUP_NOREF))
> +			return 0;
> +		if (net->ipv4.fib_main &&
> +		    !fib_table_lookup(net->ipv4.fib_main, flp, res,
> +				      FIB_LOOKUP_NOREF))
> +			return 0;
> +		if (net->ipv4.fib_default &&
> +		    !fib_table_lookup(net->ipv4.fib_default, flp, res,
> +				      FIB_LOOKUP_NOREF))
> +			return 0;
> +		return -ENETUNREACH;
> +	}
> +	return __fib_lookup(net, flp, res);
> +}
> +

Hmm, this seems quite big to be inlined ?
