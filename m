From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 19:27:26 +0100
Message-ID: <DUB107-W210F9409862AAA949CB15ED2A0@phx.gbl>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan>,<1357750898.27446.33.camel@edumazet-glaptop>,<1357751372.27446.40.camel@edumazet-glaptop>,<1357801149.27446.1142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc2-s1.dub0.hotmail.com ([157.55.1.140]:8742 "EHLO
	dub0-omc2-s1.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753841Ab3AJSdv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:33:51 -0500
In-Reply-To: <1357801149.27446.1142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Eric,

this is probably a dumb question ... but since the fix is in net/ipv4/tcp.c I was asking myself if this can affect IPv6 as well?



Thanks,

Lukas


> [PATCH] tcp: fix splice() and tcp collapsing interaction
> 
> Under unusual circumstances, TCP collapse can split a big GRO TCP packet
> while its being used in a splice(socket->pipe) operation.
> 
> skb_splice_bits() releases the socket lock before calling
> splice_to_pipe().
> 
> [ 1081.353685] WARNING: at net/ipv4/tcp.c:1330 tcp_cleanup_rbuf+0x4d/0xfc()
> [ 1081.371956] Hardware name: System x3690 X5 -[7148Z68]-
> [ 1081.391820] cleanup rbuf bug: copied AD3BCF1 seq AD370AF rcvnxt AD3CF13
> 
> To fix this problem, we must eat skbs in tcp_recv_skb().
> 
> Remove the inline keyword from tcp_recv_skb() definition since
> it has three call sites.
> 
> Reported-by: Christian Becker <c.becker@traviangames.com>
> Cc: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1ca2536..1f901be 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1428,12 +1428,12 @@ static void tcp_service_net_dma(struct sock *sk, bool wait)
>  }
>  #endif
>  
> -static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
> +static struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
>  {
>  	struct sk_buff *skb;
>  	u32 offset;
>  
> -	skb_queue_walk(&sk->sk_receive_queue, skb) {
> +	while ((skb = skb_peek(&sk->sk_receive_queue)) != NULL) {
>  		offset = seq - TCP_SKB_CB(skb)->seq;
>  		if (tcp_hdr(skb)->syn)
>  			offset--;
> @@ -1441,6 +1441,11 @@ static inline struct sk_buff *tcp_recv_skb(struct sock *sk, u32 seq, u32 *off)
>  			*off = offset;
>  			return skb;
>  		}
> +		/* This looks weird, but this can happen if TCP collapsing
> +		 * splitted a fat GRO packet, while we released socket lock
> +		 * in skb_splice_bits()
> +		 */
> +		sk_eat_skb(sk, skb, false);
>  	}
>  	return NULL;
>  }
> @@ -1520,8 +1525,10 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  	tcp_rcv_space_adjust(sk);
>  
>  	/* Clean up data we have read: This will do ACK frames. */
> -	if (copied > 0)
> +	if (copied > 0) {
> +		tcp_recv_skb(sk, seq, &offset);
>  		tcp_cleanup_rbuf(sk, copied);
> +	}
>  	return copied;
>  }
>  EXPORT_SYMBOL(tcp_read_sock);
> 
 		 	   		  