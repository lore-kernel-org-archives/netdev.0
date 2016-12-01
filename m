From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] net/act_pedit: Support using offset
 relative to the conventional network headers
Date: Thu, 01 Dec 2016 14:41:14 -0500 (EST)
Message-ID: <20161201.144114.648583754166260714.davem@davemloft.net>
References: <20161130090928.14816-1-amir@vadai.me>
        <20161130090928.14816-3-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, ogerlitz@mellanox.com,
        hadarh@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758282AbcLATl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 14:41:28 -0500
In-Reply-To: <20161130090928.14816-3-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Wed, 30 Nov 2016 11:09:27 +0200

> @@ -119,18 +119,45 @@ static bool offset_valid(struct sk_buff *skb, int offset)
>  	return true;
>  }
>  
> +static int pedit_skb_hdr_offset(struct sk_buff *skb,
> +				enum pedit_header_type htype, int *hoffset)
> +{
> +	int ret = -1;
> +
> +	switch (htype) {
> +	case PEDIT_HDR_TYPE_ETH:
> +		if (skb_mac_header_was_set(skb)) {
> +			*hoffset = skb_mac_offset(skb);
> +			ret = 0;
> +		}
> +		break;
> +	case PEDIT_HDR_TYPE_RAW:
> +	case PEDIT_HDR_TYPE_IP4:
> +	case PEDIT_HDR_TYPE_IP6:
> +		*hoffset = skb_network_offset(skb);
> +		ret = 0;
> +		break;
> +	case PEDIT_HDR_TYPE_TCP:
> +	case PEDIT_HDR_TYPE_UDP:
> +		if (skb_transport_header_was_set(skb)) {
> +			*hoffset = skb_transport_offset(skb);
> +			ret = 0;
> +		}
> +		break;
> +	};
> +
> +	return ret;
> +}
> +

The only distinction between the cases is "L2", "L3", and "L4".

Therefore I don't see any reason to break it down into IP4 vs. IP6 vs.
RAW, for example.  They all map to the same thing.

So why not just have PEDIT_HDR_TYPE_L2, PEDIT_HDR_TYPE_L3, and
PEDIT_HDR_TYPE_L4?  It definitely seems more straightforward
and cleaner that way.

Thanks.
