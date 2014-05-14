From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: set retransmit_high on loop exit
Date: Wed, 14 May 2014 14:08:28 -0400 (EDT)
Message-ID: <20140514.140828.379626997254455792.davem@davemloft.net>
References: <b1093d318477c57478b0b64475d9066710d7c75b.1399812676.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaENSI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:08:29 -0400
In-Reply-To: <b1093d318477c57478b0b64475d9066710d7c75b.1399812676.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Sun, 11 May 2014 20:57:30 +0800

> To save some CPU cycles slightly.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Can a TCP expert please review this?

> ---
>  net/ipv4/tcp_input.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index d6b46eb..e431037 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1941,8 +1941,13 @@ void tcp_enter_loss(struct sock *sk, int how)
>  	tcp_clear_all_retrans_hints(tp);
>  
>  	tcp_for_write_queue(skb, sk) {
> -		if (skb == tcp_send_head(sk))
> +		if (skb == tcp_send_head(sk)) {
> +			if (skb != tcp_write_queue_head(sk)) {
> +				skb = tcp_write_queue_prev(sk, skb);
> +				tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
> +			}
>  			break;
> +		}
>  
>  		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
>  			tp->undo_marker = 0;
> @@ -1952,7 +1957,6 @@ void tcp_enter_loss(struct sock *sk, int how)
>  			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
>  			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
>  			tp->lost_out += tcp_skb_pcount(skb);
> -			tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
>  		}
>  	}
>  	tcp_verify_left_out(tp);
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
