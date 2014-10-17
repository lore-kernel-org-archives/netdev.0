From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv4: clear all TCP_SKB_CB before passing to
 network layer
Date: Fri, 17 Oct 2014 11:18:48 -0700
Message-ID: <1413569928.25949.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413568169-4123-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:37213 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbaJQSSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 14:18:50 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so1202867pdj.40
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 11:18:49 -0700 (PDT)
In-Reply-To: <1413568169-4123-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 10:49 -0700, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> Probably not a big deal, but IP is not the only network protocol,
> don't clear skb->cb just for IP.
> 
> Also, IPv6 header is not always defined in struct tcp_skb_cb.
> 
> Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/tcp_output.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index e13d778..ee356e5 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1005,9 +1005,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
>  	/* Our usage of tstamp should remain private */
>  	skb->tstamp.tv64 = 0;
>  
> -	/* Cleanup our debris for IP stacks */
> -	memset(skb->cb, 0, max(sizeof(struct inet_skb_parm),
> -			       sizeof(struct inet6_skb_parm)));
> +	memset(TCP_SKB_CB(skb), 0, sizeof(*TCP_SKB_CB(skb)));
>  
>  	err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
>  


Usually, each layer is responsible for clearing skb->cb[] at its entry
point. Or more exactly it does not care of previous garbage.

There is no evidence your patch is needed.

I was maybe too defensive when I added this, because I wanted to make
only TCP changes.

We should instead remove the memset() in TCP and fix IP/IPv6 if
necessary.

But this should wait net-next being open.
