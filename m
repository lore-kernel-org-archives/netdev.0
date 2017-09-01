From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] flow_dissector: Add limits for encapsulation and EH
Date: Fri, 01 Sep 2017 15:32:25 +0200
Message-ID: <87fuc6zgra.fsf@stressinduktion.org>
References: <20170831222239.21509-1-tom@quantonium.net>
        <20170831222239.21509-3-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, alex.popov@linux.com
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45895 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752314AbdIANc2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 09:32:28 -0400
In-Reply-To: <20170831222239.21509-3-tom@quantonium.net> (Tom Herbert's
        message of "Thu, 31 Aug 2017 15:22:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@quantonium.net> writes:

> In flow dissector there are no limits to the number of nested
> encapsulations that might be dissected which makes for a nice DOS
> attack. This patch limits for dissecting nested encapsulations
> as well as for dissecting over extension headers.

I was actually more referring to your patch, because the flow dissector
right now is not stack recursive. Your changes would make it doing
recursion on the stack. But it seems something along the lines is anyway
needed. See below.

> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  net/core/flow_dissector.c | 48 ++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 45 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 5110180a3e96..1bca748de27d 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -396,6 +396,35 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
>  	key_ip->ttl = iph->hop_limit;
>  }
>  
> +/* Maximum number of nested encapsulations that can be processed in
> + * __skb_flow_dissect
> + */
> +#define MAX_FLOW_DISSECT_ENCAPS	5

I think you can exactly parse one encapsulation layer safely. This is
because you can only keep state on one encapsulation layer protocol
right now.

For example this scenario:

I would like to circumvent tc flower rules that filter based on vlan. I
simply construct a packet looking like:

Ethernet|Vlan|IP|GRE|Ethernet|Vlan|

because we don't recurse in the flow keys either, the second vlan header
would overwrite the information of the first one.

> +
> +static bool skb_flow_dissect_encap_allowed(int *num_encaps, unsigned int *flags)
> +{
> +	++*num_encaps;
> +
> +	if (*num_encaps >= MAX_FLOW_DISSECT_ENCAPS) {
> +		if (*num_encaps == MAX_FLOW_DISSECT_ENCAPS) {
> +			/* Allow one more pass but ignore disregard
> +			 * further encapsulations
> +			 */
> +			*flags |= FLOW_DISSECTOR_F_STOP_AT_ENCAP;
> +		} else {
> +			/* Max encaps reached */
> +			return  false;
> +		}
> +	}
> +
> +	return true;
> +}
> +
> +/* Maximum number of extension headers can be processed in __skb_flow_dissect
> + * per IPv6 packet
> + */
> +#define MAX_FLOW_DISSECT_EH	5

I would at least allow each extension header once, DEST_OPS twice, thus
let's say 12? It is safe in this version because it does not consume
stack space anyway and doesn't update internal state.

> +
>  /**
>   * __skb_flow_dissect - extract the flow_keys struct and return it
>   * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
> @@ -426,6 +455,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>  	struct flow_dissector_key_tags *key_tags;
>  	struct flow_dissector_key_vlan *key_vlan;
>  	enum flow_dissect_ret fdret;
> +	int num_eh, num_encaps = 0;
>  	bool skip_vlan = false;
>  	u8 ip_proto = 0;
>  	bool ret;
> @@ -714,7 +744,9 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>  	case FLOW_DISSECT_RET_OUT_GOOD:
>  		goto out_good;
>  	case FLOW_DISSECT_RET_PROTO_AGAIN:
> -		goto proto_again;
> +		if (skb_flow_dissect_encap_allowed(&num_encaps, &flags))
> +			goto proto_again;

I think you should get the check to the proto_again label. In case you
loop to often you can `goto out_good'.

[...]

Bye,
Hannes
