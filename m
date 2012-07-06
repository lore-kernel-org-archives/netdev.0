From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ipv4: Avoid overhead when no custom FIB rules are
 installed.
Date: Fri, 6 Jul 2012 18:19:31 +0100
Message-ID: <1341595171.2923.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120705.223142.2236039770560842377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28217 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757873Ab2GFRTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 13:19:37 -0400
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
[...]
> --- a/net/ipv4/fib_rules.c
> +++ b/net/ipv4/fib_rules.c
[...]
> @@ -189,12 +190,14 @@ errout:
>  
>  static void fib4_rule_delete(struct fib_rule *rule)
>  {
> +	struct net *net = rule->fr_net;
>  #ifdef CONFIG_IP_ROUTE_CLASSID
>  	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
>  
>  	if (rule4->tclassid)
> -		fib_num_tclassid_users--;
> +		net->ipv4.fib_num_tclassid_users--;
>  #endif
> +	net->ipv4.fib_has_custom_rules = true;
>  }
[...]

Do you really mean to set fib_has_custom_rules = true on deletion?
Shouldn't it conditionally be set false?  (Though the condition may be
too expensive to evaluate here without maintaining a separate counter.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
