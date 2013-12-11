From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net-gro: Prepare GRO stack for the upcoming
 tunneling support
Date: Wed, 11 Dec 2013 11:37:18 -0800
Message-ID: <1386790638.30495.379.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386788641-16200-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:59731 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab3LKThV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:37:21 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so10000255pdi.5
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 11:37:21 -0800 (PST)
In-Reply-To: <1386788641-16200-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-11 at 11:04 -0800, H.K. Jerry Chu wrote:

> -int tcp_gro_complete(struct sk_buff *skb)
> +int __tcp_gro_complete(struct sk_buff *skb, struct tcphdr *th)
>  {
> -	struct tcphdr *th = tcp_hdr(skb);
> -
> -	skb->csum_start = skb_transport_header(skb) - skb->head;
> +	skb->csum_start = (unsigned char *)th - skb->head;
>  	skb->csum_offset = offsetof(struct tcphdr, check);
>  	skb->ip_summed = CHECKSUM_PARTIAL;
>  
> @@ -251,6 +250,12 @@ int tcp_gro_complete(struct sk_buff *skb)
>  
>  	return 0;
>  }
> +EXPORT_SYMBOL(__tcp_gro_complete);
> +
> +int tcp_gro_complete(struct sk_buff *skb)
> +{
> +	return __tcp_gro_complete(skb,  tcp_hdr(skb));
> +}


I have no idea why you kept this change.

As we said, the transport offset is set, so it looks like a lot of your
changes can be removed to ease the review

tcp_gro_receive() sets the transport header, so the xxx_complete()
handlers can rely on it.

The only part that you could keep is the following optim :

- skb->csum_start = skb_transport_header(skb) - skb->head;
+ skb->csum_start = (unsigned char *)th - skb->head;
