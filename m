From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: question on ipv6 support for duplicate nexthops
Date: Fri, 27 Jun 2014 09:15:27 +0200
Message-ID: <1403853327.7028.7.camel@localhost>
References: <53AB41B3.1020201@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Walton <dwalton@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40555 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbaF0HPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:15:31 -0400
Received: from compute5.internal (compute5.nyi.mail.srv.osa [10.202.2.45])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 15EE321DFA
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 03:15:29 -0400 (EDT)
In-Reply-To: <53AB41B3.1020201@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-06-25 at 14:40 -0700, Roopa Prabhu wrote:
> ipv4 allows duplicate nexthops. Multiple instances of same
>   nexthops maybe used to give higher weights to some nexthops
> (though the "weight" attribute can be used for the same purpose).
> 
> ipv6 does not seem to support duplicate nexthops.
> 
> Example: The below ipv6 route is rejected by the kernel
> #ip -6 route add 2001:10:1:3::/64 nexthop via 2001:10:1:2::99 nexthop 
> via 2001:10:1:2::99
> 
> The below patch points to the code that is preventing the addition of 
> duplicate nexthops.
> 
> I am not sure yet if there are other side effects to the patch below.
> If there is interest in making ipv6 consistent with ipv4 for duplicate 
> nexthop handling, i can submit a patch.

ECMP routes are normal routing entries in the fib, just hold together
via an internal list and thus behave differently than IPv4 ECMP routes.

I don't see that just removing the check for duplicate entries will make
that work correctly.

Also you remove some pretty important expire update code.

Bye,
Hannes

> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index cb4459b..afecc87 100644
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -698,20 +698,6 @@ static int fib6_add_rt2node(struct fib6_node *fn, 
> struct rt6_info *rt,
>                                  break;
>                          }
> 
> -                       if (iter->dst.dev == rt->dst.dev &&
> -                           iter->rt6i_idev == rt->rt6i_idev &&
> - ipv6_addr_equal(&iter->rt6i_gateway,
> - &rt->rt6i_gateway)) {
> -                               if (rt->rt6i_nsiblings)
> -                                       rt->rt6i_nsiblings = 0;
> -                               if (!(iter->rt6i_flags & RTF_EXPIRES))
> -                                       return -EEXIST;
> -                               if (!(rt->rt6i_flags & RTF_EXPIRES))
> -                                       rt6_clean_expires(iter);
> -                               else
> -                                       rt6_set_expires(iter, 
> rt->dst.expires);
> -                               return -EEXIST;
> -                       }
>                          /* If we have the same destination and the same 
> metric,
>                           * but not the same gateway, then the route we 
> try to
>                           * add is sibling to this route, increment our 
> counter
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
