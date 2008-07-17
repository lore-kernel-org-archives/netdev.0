From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Thu, 17 Jul 2008 09:16:41 -0700
Message-ID: <20080717091641.18684218@extreme>
References: <20080710.035713.204601759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753101AbYGQQQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 12:16:42 -0400
In-Reply-To: <20080710.035713.204601759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jul 2008 03:57:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> It just xor hashes over IPv4/IPv6 addresses and ports of transport.
> 
> The only assumption it makes is that skb_network_header() is set
> correctly.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dev.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 52 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index db95b49..62459ea 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -121,6 +121,9 @@
>  #include <linux/ctype.h>
>  #include <linux/if_arp.h>
>  #include <linux/if_vlan.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/in.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -1665,6 +1668,53 @@ out_kfree_skb:
>   *          --BLG
>   */
>  
> +static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
> +{
> +	u32 *addr, *ports, hash, ihl;
> +	u8 ip_proto;
> +	int alen;
> +
> +	switch (skb->protocol) {
> +	case __constant_htons(ETH_P_IP):
> +		ip_proto = ip_hdr(skb)->protocol;
> +		addr = &ip_hdr(skb)->saddr;
> +		ihl = ip_hdr(skb)->ihl;
> +		alen = 2;
> +		break;
> +	case __constant_htons(ETH_P_IPV6):
> +		ip_proto = ipv6_hdr(skb)->nexthdr;
> +		addr = &ipv6_hdr(skb)->saddr.s6_addr32[0];
> +		ihl = (40 >> 2);
> +		alen = 8;
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
> +
> +	hash = 0;
> +	while (alen--)
> +		hash ^= *addr++;
> +
> +	switch (ip_proto) {
> +	case IPPROTO_TCP:
> +	case IPPROTO_UDP:
> +	case IPPROTO_DCCP:
> +	case IPPROTO_ESP:
> +	case IPPROTO_AH:
> +	case IPPROTO_SCTP:
> +	case IPPROTO_UDPLITE:
> +		hash ^= *ports;
> +		break;
> +
> +	default:
> +		break;
> +	}
> +
> +	return hash % dev->real_num_tx_queues;
> +}

What about VLAN's? and PPPoE?
