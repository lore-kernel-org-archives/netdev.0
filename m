From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] tcp: allow segment with FIN in
 tcp_try_coalesce()
Date: Mon, 15 Sep 2014 03:57:06 -0700
Message-ID: <1410778626.7106.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410749780-30613-1-git-send-email-edumazet@google.com>
	 <1410749780-30613-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:52833 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbaIOK5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:57:07 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so6174523pad.37
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:57:06 -0700 (PDT)
In-Reply-To: <1410749780-30613-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-14 at 19:56 -0700, Eric Dumazet wrote:
> There is nothing special with allowing a segment with FIN to be aggregated,
> if we take care to add tcp flags.
> 
> Signed-of-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_input.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 8f639a4face9..228bf0c5ff19 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4143,9 +4143,6 @@ static bool tcp_try_coalesce(struct sock *sk,
>  
>  	*fragstolen = false;
>  
> -	if (tcp_hdr(from)->fin)
> -		return false;
> -
>  	/* Its possible this segment overlaps with prior segment in queue */
>  	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
>  		return false;
> @@ -4158,6 +4155,7 @@ static bool tcp_try_coalesce(struct sock *sk,
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
>  	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
>  	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
> +	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
>  	return true;
>  }
>  

This patch needs to be refined.

skb_try_coalesce() should not do an unconditional 
BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));

And do it only if len is non 0

I will send a v2
