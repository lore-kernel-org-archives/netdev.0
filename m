From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: fix GRO parameters
Date: Wed, 16 Jan 2013 09:01:52 +0200
Message-ID: <50F65060.5000901@broadcom.com>
References: <50F50537.3030608@broadcom.com>
 <1358260752.8744.5677.camel@edumazet-glaptop>
 <50F56178.8000502@broadcom.com>
 <20130115.150914.729025796621947521.davem@davemloft.net>
 <1358312188.19956.1.camel@edumazet-glaptop>
 <1358314662.19956.51.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Eilon Greenstein" <eilong@broadcom.com>, ariele@broadcom.com
To: "Eric Dumazet" <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2812 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963Ab3APILn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 03:11:43 -0500
In-Reply-To: <1358314662.19956.51.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -static u16 bnx2x_set_lro_mss(struct bnx2x *bp, u16 parsing_flags,
> -			     u16 len_on_bd)
> +static void bnx2x_set_gro_params(struct sk_buff *skb, struct bnx2x *bp,
> +				 u16 parsing_flags, u16 len_on_bd,
> +				 unsigned int pkt_len)

This is purely semantic, but our convention is for `struct bnx2x' to be
the first argument in our functions.

>  {
>  	/*
> -	 * TPA arrgregation won't have either IP options or TCP options
> +	 * TPA aggregation won't have either IP options or TCP options
>  	 * other than timestamp or IPv6 extension headers.
>  	 */
>  	u16 hdrs_len = ETH_HLEN + sizeof(struct tcphdr);

TPA_MODE_LRO indicates that an LRO aggregation was made by our FW. It seems
like your patch  eliminates the difference in configuration between the two
(GRO and LRO)

perhaps instead we should do something like:

+ static void bnx2x_set_lro_params(struct bnx2x *bp, struct sk_buff *skb,
+ 				   u16 parsing_flags, u16 len_on_bd,
+ 				   unsigned int pkt_len,
+				   bnx2x_tpa_mode_t mode)

And arrange its suggested code so that only gso_size will be set for LRO.

>  
>  	if (GET_FLAG(parsing_flags, PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) ==
> -	    PRS_FLAG_OVERETH_IPV6)
> +	    PRS_FLAG_OVERETH_IPV6) {
>  		hdrs_len += sizeof(struct ipv6hdr);
> -	else /* IPv4 */
> +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> +	} else {
>  		hdrs_len += sizeof(struct iphdr);
> -
> +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> +	}
>  



>  #ifdef BNX2X_STOP_ON_ERROR
> @@ -651,7 +655,7 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  			       struct sk_buff *skb)
>  {
>  #ifdef CONFIG_INET
> -	if (fp->mode == TPA_MODE_GRO && skb_shinfo(skb)->gso_size) {
> +	if (skb_shinfo(skb)->gso_size) {

This also seems like an incorrect removal, as TPA_MODE_LRO is (again)
a feasible option, and we wouldn't want the a `gro_complete' here.

>  		skb_set_network_header(skb, 0);
>  		switch (be16_to_cpu(skb->protocol)) {
>  		case ETH_P_IP:
> 
