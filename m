From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix double-counted receiver RTT when leaving
 receiver fast path
Date: Mon, 04 Mar 2013 08:55:33 -0800
Message-ID: <1362416133.15793.105.camel@edumazet-glaptop>
References: <1362414185-9874-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ycheng@google.com, nanditad@google.com, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:36626 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756866Ab3CDQzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 11:55:37 -0500
Received: by mail-da0-f54.google.com with SMTP id p1so2630851dad.27
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 08:55:37 -0800 (PST)
In-Reply-To: <1362414185-9874-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 11:23 -0500, Neal Cardwell wrote:
> We should not update ts_recent and call tcp_rcv_rtt_measure_ts() both
> before and after going to step5. That wastes CPU and double-counts the
> receiver-side RTT sample.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a759e19..0d9bdac 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5485,6 +5485,9 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>  				if (tcp_checksum_complete_user(sk, skb))
>  					goto csum_error;
>  
> +				if ((int)skb->truesize > sk->sk_forward_alloc)
> +					goto step5;
> +
>  				/* Predicted packet is in window by definition.
>  				 * seq == rcv_nxt and rcv_wup <= rcv_nxt.
>  				 * Hence, check seq<=rcv_wup reduces to:
> @@ -5496,9 +5499,6 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>  
>  				tcp_rcv_rtt_measure_ts(sk, skb);
>  
> -				if ((int)skb->truesize > sk->sk_forward_alloc)
> -					goto step5;
> -
>  				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPHPHITS);
>  
>  				/* Bulk data transfer: receiver */

Acked-by: Eric Dumazet <edumazet@google.com>
