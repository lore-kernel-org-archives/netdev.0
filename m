From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 21:14:50 -0700
Message-ID: <1341980090.13724.43.camel@joe2Laptop>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56393 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753451Ab2GKEOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 00:14:51 -0400
In-Reply-To: <1341978558.3265.6609.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 05:49 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
> use long words to reduce number of instructions for free.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Joe Perches <joe@perches.com>
> ---
>  include/net/ipv6.h |   22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index aecf884..9ac5ded 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -302,10 +302,19 @@ static inline int
>  ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
>  		     const struct in6_addr *a2)
>  {
> +#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
> +	const unsigned long *ul1 = (const unsigned long *)a1;
> +	const unsigned long *ulm = (const unsigned long *)m;
> +	const unsigned long *ul2 = (const unsigned long *)a2;
> +
> +	return !!(((ul1[0] ^ ul2[0]) & ulm[0]) |
> +		  ((ul1[1] ^ ul2[1]) & ulm[1]));
> +#else
>  	return !!(((a1->s6_addr32[0] ^ a2->s6_addr32[0]) & m->s6_addr32[0]) |
>  		  ((a1->s6_addr32[1] ^ a2->s6_addr32[1]) & m->s6_addr32[1]) |
>  		  ((a1->s6_addr32[2] ^ a2->s6_addr32[2]) & m->s6_addr32[2]) |
>  		  ((a1->s6_addr32[3] ^ a2->s6_addr32[3]) & m->s6_addr32[3]));
> +#endif
>  }

Come to think of it, this should probably be bool to
avoid anyone possibly using this in a sorting function.
