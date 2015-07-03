From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] gro: Pull headers into skb head for 1st
 skb in gro list
Date: Fri, 03 Jul 2015 06:50:17 +0200
Message-ID: <1435899017.11970.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435871054-635096-1-git-send-email-tom@herbertland.com>
	 <1435871054-635096-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:35233 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbbGCEuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 00:50:20 -0400
Received: by wgjx7 with SMTP id x7so78471638wgj.2
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 21:50:19 -0700 (PDT)
In-Reply-To: <1435871054-635096-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 14:04 -0700, Tom Herbert wrote:
> When setting up the first skb in a gro list we ensure that all the
> headers up to skb_gro_offset have been pulled into head. In subsequent
> uses of this skb (e.g. determining same_flow) it is assumed that the
> headers can be accessed in the skb head.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/core/dev.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6778a99..05e0e37 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4228,6 +4228,10 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
>  	} else {
>  		napi->gro_count++;
>  	}
> +
> +	/* Ensure all headers are pulled into head for 1st skb */
> +	skb_gro_header_slow(skb, skb_gro_offset(skb), 0);
> +
>  	NAPI_GRO_CB(skb)->count = 1;
>  	NAPI_GRO_CB(skb)->age = jiffies;
>  	NAPI_GRO_CB(skb)->last = skb;

I do not see how we can reach this point without having headers already
pulled.

For example, tcp_gro_receive() has :

        off = skb_gro_offset(skb);
        hlen = off + sizeof(*th);
        th = skb_gro_header_fast(skb, off);
        if (skb_gro_header_hard(skb, hlen)) {
                th = skb_gro_header_slow(skb, hlen, off);
                if (unlikely(!th))
                        goto out;
        }

So by definition, skb is put in gro_list only if it was fully validated as a GRO
candidate.

Given the complexity of your 2nd patch, I am stopping the review right
now.
