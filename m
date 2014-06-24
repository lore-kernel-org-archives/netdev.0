From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] ipv6: Fix MLD Query message check
Date: Tue, 24 Jun 2014 18:27:13 +0400
Message-ID: <53A98AC1.3010107@cogentembedded.com>
References: <1403610628-19676-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Hangbin Liu <liuhangbin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:32945 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213AbaFXO1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:27:12 -0400
Received: by mail-lb0-f169.google.com with SMTP id l4so561768lbv.14
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:27:10 -0700 (PDT)
In-Reply-To: <1403610628-19676-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/24/2014 03:50 PM, Hangbin Liu wrote:

> Based on RFC3810 6.2, we also need to check the hop limit and router alert
> option besides source address.

> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>   net/ipv6/mcast.c | 14 ++++++++++++--
>   1 file changed, 12 insertions(+), 2 deletions(-)

> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 08b367c..fdf7455 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1301,8 +1301,18 @@ int igmp6_event_query(struct sk_buff *skb)
>   	len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
>   	len -= skb_network_header_len(skb);
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
> +			ipv6_hdr(skb)->hop_limit != 1 ||
> +			ipv6_hdr(skb)->nexthdr != NEXTHDR_HOP ||
> +			!(IP6CB(skb)->flags & IP6SKB_ROUTERALERT) ||
> +			IP6CB(skb)->ra != htons(IPV6_OPT_ROUTERALERT_MLD))

    The continuation lines should start exactly under '!' on the broken up line.

WBR, Sergei
