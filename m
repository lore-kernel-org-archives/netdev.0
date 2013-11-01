From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 1/2] ipv6: select oif corresponding to source address
Date: Fri, 1 Nov 2013 19:04:33 +0100
Message-ID: <20131101180433.GB30284@order.stressinduktion.org>
References: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43731 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab3KASEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 14:04:34 -0400
Content-Disposition: inline
In-Reply-To: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 01, 2013 at 06:17:36PM +0100, Emmanuel Thierry wrote:
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -848,8 +848,14 @@ static int ip6_dst_lookup_tail(struct sock *sk,
>  #endif
>  	int err;
>  
> -	if (*dst == NULL)
> +	if (*dst == NULL) {
> +		struct inet6_ifaddr *ifp;
> +		if (!ipv6_addr_any(&fl6->saddr)) {
> +			ifp = ipv6_get_ifaddr(net, &fl6->saddr, NULL, 1);
> +			fl6->flowi6_oif = ifp->idev->dev->ifindex;

Cool that you are working on this! :)

Small feedback that might help while you play with this:

You have to be careful here, ipv6_get_ifaddr increments the reference
count of the ifp, so you have to drop it again: in6_ifa_put(ifp);

For such short periods holding a reference does not always make sense. You
could check ipv6_get_lladdr/__ipv6_get_lladdr how you could do this
without touching the reference counters if you put this section in
a rcu_read_lock. This especially makes sense if this is a often used
code path.

> +		}
>  		*dst = ip6_route_output(net, sk, fl6);
> +	}
>  
>  	if ((err = (*dst)->error))
>  		goto out_err_release;

I'll have to think about this carefully.

Thanks,

  Hannes
