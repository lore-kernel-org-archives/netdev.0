From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound
 (v2)
Date: Sun, 01 Nov 2015 11:47:30 -0500 (EST)
Message-ID: <20151101.114730.490692280193173443.davem@davemloft.net>
References: <1443145960-20514-1-git-send-email-wen.gang.wang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wen.gang.wang@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbbKAQre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 11:47:34 -0500
In-Reply-To: <1443145960-20514-1-git-send-email-wen.gang.wang@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wengang Wang <wen.gang.wang@oracle.com>
Date: Fri, 25 Sep 2015 09:52:40 +0800

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5f4a556..c0534c2 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2097,7 +2097,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
>  			 */
>  
>  			fl4->flowi4_oif = dev_out->ifindex;
> -			goto make_route;
> +			if (dev_out->flags & IFF_LOOPBACK)
> +				goto make_route;
> +			else
> +				goto lookup;
>  		}

This is still broken.

By definition invoking fib_lookup() and depending upon it finding
something in this path is going to break things for somebody,
somewhere.  Before your change, if we lacked a multicast route,
the user would still get a functioning path.

Furthermore, most of the other "goto make_route" cases in this
function suffer from the same exact problem you're trying to
solve.  Therefore, special casing one instance makes no sense
at all.

I want you to, instead of making potentially lethal semantic changes
here, fix the real problem instead.

That is, I want you to fix how we do not cache routes we create merely
because we lack a fib_info.

Thanks.
