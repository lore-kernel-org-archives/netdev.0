From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] net: Use Toeplitz for IPv4 and IPv6 connection hashing
Date: Tue, 24 Sep 2013 01:17:52 +0200
Message-ID: <20130923231752.GA2593@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231543330.23714@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46531 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab3IWXRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:17:53 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309231543330.23714@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 23, 2013 at 03:44:51PM -0700, Tom Herbert wrote:
> diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
> index f52fa88..492a45b 100644
> --- a/include/net/inet6_hashtables.h
> +++ b/include/net/inet6_hashtables.h
> @@ -32,12 +32,28 @@ static inline unsigned int inet6_ehashfn(struct net *net,
>  				const struct in6_addr *laddr, const u16 lport,
>  				const struct in6_addr *faddr, const __be16 fport)
>  {
> +#if IS_ENABLED(CONFIG_IP_HASH_TOEPLITZ)
> +	struct {
> +		struct in6_addr saddr;
> +		struct in6_addr daddr;
> +		u16 sport;
> +		u16 dport;
> +	} input;
> +
> +        input.daddr = *laddr;
> +        input.saddr = *faddr;
> +        input.sport = htons(lport);
> +        input.dport = fport;
> +
> +        return toeplitz_hash((u8 *)&input, toeplitz_net, sizeof(input));
> +#else
>  	u32 ports = (((u32)lport) << 16) | (__force u32)fport;
>  
>  	return jhash_3words((__force u32)laddr->s6_addr32[3],
>  			    ipv6_addr_jhash(faddr),
>  			    ports,
>  			    inet_ehash_secret + net_hash_mix(net));
> +#endif

You seem to discard the secret inputs. This should make the hashing
considerable more insecure.

I always believed the reason for choosing linear feedback shift register
based hash functions was because of the parallelism a pure hardware
based implementation could exploit. This does not matter for the kernel.

IMHO jhash should be considered more secure just because of its wider usage.
;)

Greetings,

  Hannes
