From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] rps: changes to bnx2x to get device hash
Date: Wed, 11 Nov 2009 10:19:21 -0800
Message-ID: <20091111101921.448d5f05@s6510>
References: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59173 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758348AbZKKSTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 13:19:43 -0500
In-Reply-To: <65634d660911102253lbfc0927i4e4c0eba6d7d765d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 22:53:36 -0800
Tom Herbert <therbert@google.com> wrote:

> +
> +			if (get_hdrhash && (cqe_fp_status_flags &
> +			    ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG)) {
> +				u8 hash_type = cqe_fp_status_flags &
> +					ETH_FAST_PATH_RX_CQE_RSS_HASH_TYPE;
> +
> +				skb->rxhash = le32_to_cpu(
> +				      cqe->fast_path_cqe.rss_hash_result);
> +				if (!skb->rxhash)
> +					skb->rxhash = 1;
> +
> +				/* unicast IPv4 packet? */
> +				if (((hash_type == IPV4_HASH_TYPE) ||
> +				     (hash_type == TCP_IPV4_HASH_TYPE)) &&
> +				    (cqe_fp_pars_flags &
> +					PARSING_FLAGS_ETHERNET_ADDRESS_TYPE)) {
> +					skb->dev = bp->dev;
> +					skb_reset_mac_header(skb);
> +					skb_pull(skb, ETH_HLEN);
> +					skb->protocol =
> +					    __constant_htons(ETH_P_IP);
> +				} else
> +					skb->protocol =
> +					    eth_type_trans(skb, bp->dev);
> +			} else
> +				skb->protocol = eth_type_trans(skb, bp->dev);

How about putting this all in an inline function:

static inline u16 bn2x_get_type(...) {
}


	skb->protocol = bn2x_get_type(...);

Then you won't have two calls to eth_type_trans,

Also: __constant_htons() should not be used directly (except switch statements),
macro for htons() does it automatically if argument is constant.
