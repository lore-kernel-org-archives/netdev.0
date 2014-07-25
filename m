From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH v2 net] ip: make IP identifiers less predictable
Date: Sat, 26 Jul 2014 00:35:52 +0200
Message-ID: <1406327752.14815.8.camel@localhost>
References: <1406189276.3363.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jeffrey Knockel <jeffk@cs.unm.edu>,
	"Jedidiah R. Crandall" <crandall@cs.unm.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Willy Tarreau <w@1wt.eu>, security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbaGYWg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 18:36:26 -0400
In-Reply-To: <1406317840.3363.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-07-25 at 21:50 +0200, Eric Dumazet wrote:
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index cb9df0eb4023..73372e8016b9 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -545,6 +545,7 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
>  	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
>  
>  	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
> +	hash ^= __ipv6_addr_jhash(&rt->rt6i_src.addr, fhdr->nexthdr);

I am not sure if we should hash fhdr->nexthdr for IPv6.

If you look at the reassembly engine, we compare protocol value for IPv4
but not for IPv6 (we even don't save it).

Even if we only transmit packets with UDP protocol type we might end up
having an extension header right after the fragmentation header of
another type later in the flow. We can end up using a different bucket
and thus reusing a fragmentation id wich has been seen before in this
flow possibly resulting in reassembly issues.

I don't see such a problem for IPv4.

Otherwise very nice patch, thanks,
Hannes
