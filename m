From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: update Destination Cache entries when gateway turn
 into host
Date: Sun, 11 May 2014 17:54:57 -0700
Message-ID: <1399856097.16759.116198185.2A93B8D8@webmail.messagingengine.com>
References: <536C4A74.2050103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:33593 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750822AbaELAy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 20:54:59 -0400
In-Reply-To: <536C4A74.2050103@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 8, 2014, at 20:24, Duan Jiong wrote:
> 
> RFC 4861 states in 7.2.5:
> 
> 	The IsRouter flag in the cache entry MUST be set based on the
>          Router flag in the received advertisement.  In those cases
>          where the IsRouter flag changes from TRUE to FALSE as a result
>          of this update, the node MUST remove that router from the
>          Default Router List and update the Destination Cache entries
>          for all destinations using that neighbor as a router as
>          specified in Section 7.3.3.  This is needed to detect when a
>          node that is used as a router stops forwarding packets due to
>          being configured as a host.
> 
> Currently, when dealing with NA Message which IsRouter flag changes from
> TRUE to FALSE, the kernel only removes router from the Default Router List,
> and don't update the Destination Cache entries.
> 
> Now in order to update those Destination Cache entries, i introduce
> function rt6_clean_tohost().
>
> [...]
>
> +/*remove routers and update dst entries when gateway turn into host.*/
> +static int fib6_clean_tohost(struct rt6_info *rt, void *arg)
> +{
> +	struct in6_addr *gateway = (struct in6_addr *)arg;
> +
> +	if (((rt->rt6i_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> +	    == (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> +	    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
> +		return -1;
> +	} else if (((rt->rt6i_flags & (RTF_GATEWAY | RTF_CACHE))
> +		      == (RTF_GATEWAY | RTF_CACHE))
> +		    && ipv6_addr_equal(gateway, &rt->rt6i_gateway)) {
> +		rt->rt6i_flags |= RTF_REJECT;
> +		rt->dst.error = -ENETUNREACH;
> +	}
> +	return 0;
> +}

I am not so happy with that but have not tried that.

The Destination Cache you quote from the RFC (if you follow 7.3.3.) actually refers to the neighbouring
subsystem, where we would need to generate subsequent errors in case we try to forward a packet
through a this particular router.

The reason why I am not that happy is, that the semantics when neighbour nodes are cleared is well
defined but we don't have that semantics when those rt6_nodes get cleared up. E.g. consider a router which just temporarily switches forwarding off and on.

I guess we need to inspect NTF_ROUTER flag in the output path somehow. :/

Greetings,

  Hannes
