From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: refresh skb timestamp at retransmit time
Date: Tue, 10 May 2016 08:01:07 -0700
Message-ID: <CAK6E8=eGaBL9O55xCbtoZuuisvUGF5NRv6qV5bbvQB-JFw6Zjg@mail.gmail.com>
References: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36667 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbcEJPBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 11:01:49 -0400
Received: by mail-wm0-f54.google.com with SMTP id n129so182720898wmn.1
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 08:01:48 -0700 (PDT)
In-Reply-To: <1462852516.23934.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 8:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In the very unlikely case __tcp_retransmit_skb() can not use the cloning
> done in tcp_transmit_skb(), we need to refresh skb_mstamp before doing
> the copy and transmit, otherwise TCP TS val will be an exact copy of
> original transmit.
>
> Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Nice catch Eric. Recovery algorithm like RACK definitely requires this
patch b/c it relies on skb mstamps.
does the failure usually occur under memory stress?

> ---
>  net/ipv4/tcp_output.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 441ae9da3a23..79a03b87a771 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2640,8 +2640,10 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
>          */
>         if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
>                      skb_headroom(skb) >= 0xFFFF)) {
> -               struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
> -                                                  GFP_ATOMIC);
> +               struct sk_buff *nskb;
> +
> +               skb_mstamp_get(&skb->skb_mstamp);
> +               nskb = __pskb_copy(skb, MAX_TCP_HEADER, GFP_ATOMIC);
>                 err = nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
>                              -ENOBUFS;
>         } else {
>
>
