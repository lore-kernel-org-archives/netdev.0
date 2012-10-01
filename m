From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v5 1/1] ipv6: add support of ECMP
Date: Mon, 01 Oct 2012 09:47:57 -0700
Message-ID: <1349110077.7740.23.camel@joe-AO722>
References: <20120921.134833.1294721941180523200.davem@davemloft.net>
	 <1349099807-3907-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1349099807-3907-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bernat@luffy.cx, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36726 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753081Ab2JAQr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 12:47:58 -0400
In-Reply-To: <1349099807-3907-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-01 at 15:56 +0200, Nicolas Dichtel wrote:
> This patch adds the support of equal cost multipath for IPv6.

trivia:

> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
[]
> @@ -47,6 +47,10 @@ struct fib6_config {
>  	unsigned long	fc_expires;
>  	struct nlattr	*fc_mx;
>  	int		fc_mx_len;
> +#ifdef CONFIG_IPV6_MULTIPATH
> +	struct nlattr	*fc_mp;
> +	int		fc_mp_len;
> +#endif

These new entries should be in the reverse order to
avoid having a padding hole in 64-bit systems.

> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c

> @@ -672,6 +672,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
>  			    iter->rt6i_idev == rt->rt6i_idev &&
>  			    ipv6_addr_equal(&iter->rt6i_gateway,
>  					    &rt->rt6i_gateway)) {
> +#ifdef CONFIG_IPV6_MULTIPATH
> +				if (rt->rt6i_nsiblings)
> +					rt->rt6i_nsiblings = 0;
> +#endif

There are a _lot_ of #ifdef CONFIG_IPV6_MULTIPATH blocks.

It might be better to add a few static line functions
in a header file like:

#ifdef CONFIG_IPV6_MULTIPATH
static inline int ipv6_get_multipath_siblings(const struct rt6_info *rt)
{
	return rt->rt6i_nsiblings;
}
#else
static inline int ipv6_get_multipath_siblings(const struct rt6_info *rt)
{
	return 0;
}
#endif

and remove most of the #ifdef blocks.
