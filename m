From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC ipsec-next 5/5] esp: Add a software GRO codepath
Date: Tue, 07 Feb 2017 11:45:06 -0800
Message-ID: <1486496706.7793.66.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486458851-4920-1-git-send-email-steffen.klassert@secunet.com>
         <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33724 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdBGTpI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:45:08 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so12905473pgd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 11:45:08 -0800 (PST)
In-Reply-To: <1486458851-4920-6-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-07 at 10:14 +0100, Steffen Klassert wrote:
> This patch adds GRO ifrastructure and callbacks for ESP on
> ipv4 and ipv6.
> 


I am a bit confused.

>  
> -struct xfrm_tunnel_skb_cb {
> +/*
> + * This structure is used if we get the packet from the gro layer.
> + */
> +struct xfrm_gro_skb_cb {
>  	union {
>  		struct inet_skb_parm h4;
>  		struct inet6_skb_parm h6;
> -	} header;
> +
> +		struct {
> +			__be32 seq;
> +			bool skb_is_gro;
> +		} input;
> +	} gro;
> +};
> +
> +#define XFRM_GRO_SKB_CB(__skb) ((struct xfrm_gro_skb_cb *)&((__skb)->cb[0]))
> +

Then :

> +
> +	x = xfrm_state_lookup(dev_net(skb->dev), skb->mark,
> +			      (xfrm_address_t *)&ip_hdr(skb)->daddr,
> +			      spi, IPPROTO_ESP, AF_INET);
> +	if (!x)
> +		goto out;
> +
> +	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
> +	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
> +	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
> +	XFRM_GRO_SKB_CB(skb)->gro.input.seq = seq;
> +	skb->sp->xvec[skb->sp->len++] = x;
> +
> +	/* We don't need to handle errors from xfrm_input, it does all
> +	 * the error handling and frees the resources on error. */
> +	xfrm_input(skb, IPPROTO_ESP, spi, -2);
> +
> +	return ERR_PTR(-EINPROGRESS);
> +out:
> +	skb_push(skb, offset);
> +	NAPI_GRO_CB(skb)->same_flow = 0;
> +	NAPI_GRO_CB(skb)->flush = 1;
> +


How can you mix XFRM_SPI_SKB_CB(), XFRM_GRO_SKB_CB() and NAPI_GRO_CB()
at the same time on one skb ?
