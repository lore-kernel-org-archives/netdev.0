From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 10/15] ipv4: Cache input routes in fib_info nexthops.
Date: Wed, 18 Jul 2012 12:27:55 -0700
Message-ID: <1342639675.2013.18.camel@joe2Laptop>
References: <20120718.112413.1969496621247659288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54852 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752115Ab2GRT14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 15:27:56 -0400
In-Reply-To: <20120718.112413.1969496621247659288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 11:24 -0700, David Miller wrote:
> Caching input routes is slightly simpler than output routes, since we
> don't need to be concerned with nexthop exceptions.  (locally
> destined, and routed packets, never trigger PMTU events or redirects
> that will be processed by us).
[]
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
[]
> @@ -1355,11 +1357,11 @@ static int __mkroute_input(struct sk_buff *skb,
[]
> +	do_cache = false;
> +	if (res->fi) {
> +		if (!(flags & RTCF_DIRECTSRC) && !itag) {
> +			rth = FIB_RES_NH(*res).nh_rth_input;
> +			if (rth) {
> +				dst_use(&rth->dst, jiffies);
> +				goto out;
> +			}
> +			do_cache = true;
> +		}
> +	}
[]
> @@ -1568,8 +1580,20 @@ brd_input:
[]
> +	do_cache = false;
> +	if (res.fi) {
> +		if (!(flags & RTCF_DIRECTSRC) && !itag) {
> +			rth = FIB_RES_NH(res).nh_rth_input;
> +			if (rth) {
> +				dst_use(&rth->dst, jiffies);
> +				goto set_and_out;
> +			}
> +			do_cache = true;
> +		}
> +	}

Maybe a helper like:

	if (some_do_cache_name(rth, res, itag, flags, &do_cache))
		goto foo;
