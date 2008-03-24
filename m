From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/3] [LLC]: bogus llc packet length
Date: Mon, 24 Mar 2008 13:43:10 -0300
Message-ID: <20080324164310.GD32612@ghostprotocols.net>
References: <47e7678b.1aba720a.6925.fffff466@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808AbYCXQn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 12:43:26 -0400
Content-Disposition: inline
In-Reply-To: <47e7678b.1aba720a.6925.fffff466@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 24, 2008 at 05:34:16PM +0900, joonwpark81@gmail.com escreveu:
> From: Joonwoo Park <joonwpark81@gmail.com>
> 
> discard llc packet which has bogus packet length.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
> diff --git a/net/llc/llc_input.c b/net/llc/llc_input.c
> index c40c9b2..a2bbc7c 100644
> --- a/net/llc/llc_input.c
> +++ b/net/llc/llc_input.c
> @@ -117,8 +117,12 @@ static inline int llc_fixup_skb(struct sk_buff *skb)
>  	skb_pull(skb, llc_len);
>  	if (skb->protocol == htons(ETH_P_802_2)) {
>  		__be16 pdulen = eth_hdr(skb)->h_proto;
> -		u16 data_size = ntohs(pdulen) - llc_len;
> +		s32 data_size = ntohs(pdulen) - llc_len;
>  
> +		if (data_size < 0
> +		    || ((skb_tail_pointer(skb) - (u8 *)pdu) - llc_len)
> +			< data_size)
> +			return 0;

Rewrite this as:

		if (data_size < 0 ||
		    ((skb_tail_pointer(skb) -
		      (u8 *)pdu) - llc_len) < data_size)

And stick my:

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

:-)

>  		if (unlikely(pskb_trim_rcsum(skb, data_size)))
>  			return 0;
>  	}
> -- 
> 1.5.4.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
