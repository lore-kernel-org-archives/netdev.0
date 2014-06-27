From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipv6: Fix MLD Query message check
Date: Thu, 26 Jun 2014 17:33:41 -0700 (PDT)
Message-ID: <20140626.173341.1309075773440112452.davem@davemloft.net>
References: <1403659867-8323-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: liuhangbin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaF0Adm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:33:42 -0400
In-Reply-To: <1403659867-8323-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <liuhangbin@gmail.com>
Date: Wed, 25 Jun 2014 09:31:07 +0800

> @@ -1301,8 +1301,18 @@ int igmp6_event_query(struct sk_buff *skb)
>  	len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
>  	len -= skb_network_header_len(skb);
>  
> -	/* Drop queries with not link local source */
> -	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL))
> +	/* RFC3810 6.2
> +	 * Upon reception of an MLD message that contains a Query, the node
> +	 * checks if the source address of the message is a valid link-local
> +	 * address, if the Hop Limit is set to 1, and if the Router Alert
> +	 * option is present in the Hop-By-Hop Options header of the IPv6
> +	 * packet.  If any of these checks fails, the packet is dropped.
> +	 */
> +	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL) ||
> +	    ipv6_hdr(skb)->hop_limit != 1 ||
> +	    ipv6_hdr(skb)->nexthdr != NEXTHDR_HOP ||
> +	    !(IP6CB(skb)->flags & IP6SKB_ROUTERALERT) ||
> +	    IP6CB(skb)->ra != htons(IPV6_OPT_ROUTERALERT_MLD))
>  		return -EINVAL;
>  

Does the NEXTHDR_HOP have the be exactly the next extension header
present?  I think you need to allow for more flexibility here.

In any event, the only way the IP6SKB_ROUTERALERT bit can be set
is if there were hop-by-hop options present, so testing only the
bit itself is sufficient.

The forwarding path simplifies the check in this way too.

So please adjust this to only check the bit and remove the NEXTHDR_HOP
test.

Thanks.
