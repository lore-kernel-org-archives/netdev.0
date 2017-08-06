From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp_input: move out condition check from
 tcp_data_queue()
Date: Sun, 06 Aug 2017 10:07:27 -0700
Message-ID: <1502039247.25002.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <674DB789-9B28-4A9C-A0BF-D91023CB86F3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ilya Matveychikov <matvejchikov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37585 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdHFRHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 6 Aug 2017 13:07:31 -0400
Received: by mail-wm0-f68.google.com with SMTP id t138so11236791wmt.4
        for <netdev@vger.kernel.org>; Sun, 06 Aug 2017 10:07:30 -0700 (PDT)
In-Reply-To: <674DB789-9B28-4A9C-A0BF-D91023CB86F3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-08-06 at 13:51 +0400, Ilya Matveychikov wrote:
> As tcp_data_queue() function is used just only twice it's better
> to move out the first check and wrap it with inline. It saves a
> single call in case the condition evaluated as true.
> 
> Signed-off-by: Ilya V. Matveychikov <matvejchikov@gmail.com>
> ---
>  net/ipv4/tcp_input.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 2920e0c..141a722 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4585,16 +4585,12 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
>  
>  }
>  
> -static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
> +static void __tcp_data_queue(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	bool fragstolen = false;
>  	int eaten = -1;
>  
> -	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq) {
> -		__kfree_skb(skb);
> -		return;
> -	}
>  	skb_dst_drop(skb);
>  	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
>  
> @@ -4703,6 +4699,14 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
>  	tcp_data_queue_ofo(sk, skb);
>  }
>  
> +static inline void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
> +{
> +	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
> +		__kfree_skb(skb);
> +	else
> +		__tcp_data_queue(sk, skb);
> +}
> +

We wont accept such a change, because this code does not need to be
inlined in the callers, ( and btw inline in .c files are discouraged
these days )
