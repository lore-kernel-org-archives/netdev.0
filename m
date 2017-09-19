From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get
 tunnel routes and add dst_cache
Date: Mon, 18 Sep 2017 21:17:51 -0700 (PDT)
Message-ID: <20170918.211751.1871429944584121281.davem@davemloft.net>
References: <20170919003904.5124-1-tom@quantonium.net>
        <20170919003904.5124-4-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750713AbdISERx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 00:17:53 -0400
In-Reply-To: <20170919003904.5124-4-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 18 Sep 2017 17:38:53 -0700

> Call ip_tunnel_get_route and dst_cache to pdp context which should
> improve performance by obviating the need to perform a route lookup
> on every packet.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>

Not caused by your changes, but something to think about:

> -static struct rtable *ip4_route_output_gtp(struct flowi4 *fl4,
> -					   const struct sock *sk,
> -					   __be32 daddr)
> -{
> -	memset(fl4, 0, sizeof(*fl4));
> -	fl4->flowi4_oif		= sk->sk_bound_dev_if;
> -	fl4->daddr		= daddr;
> -	fl4->saddr		= inet_sk(sk)->inet_saddr;
> -	fl4->flowi4_tos		= RT_CONN_FLAGS(sk);
> -	fl4->flowi4_proto	= sk->sk_protocol;
> -
> -	return ip_route_output_key(sock_net(sk), fl4);
> -}

This and the new dst caching code ignores any source address selection
done by ip_route_output_key() or the new tunnel route lookup helpers.

Either source address selection should be respected, or if saddr will
never be modified by a route lookup for some specific reason here,
that should be documented.
