From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 09/11] net: Add IPv6 flow label to flow_keys
Date: Thu, 28 May 2015 17:36:36 -0700
Message-ID: <1432859796.7456.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
	 <1432837148-1359931-10-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38279 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794AbbE2Agj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 20:36:39 -0400
Received: by igbjd9 with SMTP id jd9so2485525igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 17:36:38 -0700 (PDT)
In-Reply-To: <1432837148-1359931-10-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 11:19 -0700, Tom Herbert wrote:
> In flow_dissector set the flow label in flow_keys for IPv6. This also
> removes the shortcircuiting of flow dissection when a non-zero label
> is present, the flow label can be considered to provide additional
> entropy for a hash.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/flow_dissector.h |  4 +++-
>  net/core/flow_dissector.c    | 31 +++++++++++--------------------
>  2 files changed, 14 insertions(+), 21 deletions(-)
> 
> diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
> index 08480fb..14d8483 100644
> --- a/include/net/flow_dissector.h
> +++ b/include/net/flow_dissector.h
> @@ -28,7 +28,8 @@ struct flow_dissector_key_basic {
>  };
>  
>  struct flow_dissector_key_tags {
> -	u32	vlan_id:12;
> +	u32	vlan_id:12,
> +		flow_label:20;
>  };
>  
>  /**
> @@ -111,6 +112,7 @@ enum flow_dissector_key_id {
>  	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
>  	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
>  	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
> +	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_tags */
>  
>  	FLOW_DISSECTOR_KEY_MAX,
>  };
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5c66cb2..ba089d9 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -190,7 +190,7 @@ ip:
>  	case htons(ETH_P_IPV6): {
>  		const struct ipv6hdr *iph;
>  		struct ipv6hdr _iph;
> -		__be32 flow_label;
> +		u32 flow_label;

You change flow_label from __be32 to u32.

>  
>  ipv6:
>  		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
> @@ -210,30 +210,17 @@ ipv6:
>  
>  			memcpy(key_ipv6_addrs, &iph->saddr, sizeof(*key_ipv6_addrs));
>  			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
> -			goto flow_label;
>  		}
> -		break;
> -flow_label:
> +
>  		flow_label = ip6_flowlabel(iph);

But ip6_flowlabel() returns a __be32. This should not please sparse.


>  		if (flow_label) {
> -			/* Awesome, IPv6 packet has a flow label so we can
> -			 * use that to represent the ports without any
> -			 * further dissection.
> -			 */
> -
> -			key_basic->n_proto = proto;
> -			key_basic->ip_proto = ip_proto;
> -			key_control->thoff = (u16)nhoff;
> -
>  			if (skb_flow_dissector_uses_key(flow_dissector,
> -							FLOW_DISSECTOR_KEY_PORTS)) {
> -				key_ports = skb_flow_dissector_target(flow_dissector,
> -								      FLOW_DISSECTOR_KEY_PORTS,
> -								      target_container);
> -				key_ports->ports = flow_label;
> +				FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
> +				key_tags = skb_flow_dissector_target(flow_dissector,
> +								     FLOW_DISSECTOR_KEY_FLOW_LABEL,
> +								     target_container);
> +				key_tags->flow_label = ntohl(flow_label);

Then you call ntohl() on u32 variable. This should also complain.

Have you run sparse ?

make C=2 CF=-D__CHECK_ENDIAN__ net/core/flow_dissector.o

Thanks.
