From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Fri, 18 Jan 2013 00:44:11 +0900
Message-ID: <50F81C4B.3050406@linux-ipv6.org>
References: <20130117033258.GA23782@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44255 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756710Ab3AQPoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:44:14 -0500
In-Reply-To: <20130117033258.GA23782@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This patch adds anti-spoofing checks in sit.c as specified in RFC3964
> section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
> checks which could easily be implemented with netfilter.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/ipv6/sit.c | 27 +++++++++++++++++++++++++--
>  1 file changed, 25 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index cfba99b..2b4c15a 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -590,6 +590,22 @@ out:
>  	return err;
>  }
>  
> +static int sit_chksrc(struct ip_tunnel *tunnel, const __be32 *addr,
> +		const struct in6_addr *addr6)
> +{
> +#ifdef CONFIG_IPV6_SIT_6RD
> +	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
> +				tunnel->ip6rd.prefixlen) &&
> +		memcmp(addr, &addr6->s6_addr16[1], 4))
> +		return 0;
> +#else
> +	if (addr6->s6_addr16[0] == htons(0x2002) &&
> +		memcmp(addr, &addr6->s6_addr16[1], 4))
> +		return 0;
> +#endif
> +	return 1;
>

It seems wrong.  Check should be done for
- inner source prefix
- embedded source with relay_prefix.
- inner destination prefix.

Note: embedded destination is not being checked.

--yoshfuji
