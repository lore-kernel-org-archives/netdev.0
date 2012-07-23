From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 11/16] ipv4: Cache input routes in fib_info nexthops.
Date: Mon, 23 Jul 2012 12:13:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207231157590.1626@ja.ssi.bg>
References: <20120720.142622.1447419081262029885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57093 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab2GWJFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 05:05:40 -0400
In-Reply-To: <20120720.142622.1447419081262029885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 20 Jul 2012, David Miller wrote:

> 
> Caching input routes is slightly simpler than output routes, since we
> don't need to be concerned with nexthop exceptions.  (locally
> destined, and routed packets, never trigger PMTU events or redirects
> that will be processed by us).
> 
> However, we have to elide caching for the DIRECTSRC and non-zero itag
> cases.

	I see only one user for RTCF_DIRECTSRC:
icmp_address_reply, may be we can do some magic there and
avoid using this flag. By this way we can cache in
nh_rth_input not depending on it.

	The problem with rt_iif is worse. May be we
can cache only the first iif, other packets will see
different iif in nh_rth_input and will get non-cached
result. For boxes with 2 or more interfaces only one
can use the cache. One setup can have large traffic
from LAN, other can be server for remote clients.

	For forwarding such ambiguity should be lower
and also rt_iif is mostly used for local targets.

>  local_input:
> +	do_cache = false;
> +	if (res.fi) {
> +		if (!(flags & RTCF_DIRECTSRC) && !itag) {
> +			rth = FIB_RES_NH(res).nh_rth_input;

			rt_iif here should be same!!!

> +			if (rt_cache_valid(rth)) {
> +				dst_use(&rth->dst, jiffies);
> +				goto set_and_out;
> +			}
> +			do_cache = true;
> +		}
> +	}
> +
>  	rth = rt_dst_alloc(net->loopback_dev,
> -			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, false);
> +			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
>  	if (!rth)
>  		goto e_nobufs;
>  
> @@ -1622,6 +1651,9 @@ local_input:
>  		rth->dst.error= -err;
>  		rth->rt_flags 	&= ~RTCF_LOCAL;
>  	}
> +	if (do_cache)
> +		rt_cache_route(&FIB_RES_NH(res), rth);

Regards

--
Julian Anastasov <ja@ssi.bg>
