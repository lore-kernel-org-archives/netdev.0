From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH net] tcp: do not underestimate skb->truesize in tcp_trim_head()
Date: Thu, 27 Apr 2017 13:49:57 +0200
Message-ID: <CAAeHK+xWDnPu05g4Hqt3wkHEsuW=Ry7p7rLnxL3ct1MuSLBXLw@mail.gmail.com>
References: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com> <1493252140.6453.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f172.google.com ([209.85.213.172]:32913 "EHLO
        mail-yb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936292AbdD0LuE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:50:04 -0400
Received: by mail-yb0-f172.google.com with SMTP id 11so7252748yby.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:50:03 -0700 (PDT)
In-Reply-To: <1493252140.6453.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 2:15 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
> skb_try_coalesce() using syzkaller and a filter attached to a TCP
> socket over loopback interface.
>
> I believe one issue with looped skbs is that tcp_trim_head() can end up
> producing skb with under estimated truesize.
>
> It hardly matters for normal conditions, since packets sent over
> loopback are never truncated.
>
> Bytes trimmed from skb->head should not change skb truesize, since
> skb->head is not reallocated.

Hi Eric,

With all 3 of your patches applied to net-next I don't see the warning any more.

Thanks!

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/tcp_output.c |   19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index c3c082ed38796f65948e7a1042e37813b71d5abf..a85d863c44196e60fd22e25471cf773e72d2c133 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1267,7 +1267,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
>   * eventually). The difference is that pulled data not copied, but
>   * immediately discarded.
>   */
> -static void __pskb_trim_head(struct sk_buff *skb, int len)
> +static int __pskb_trim_head(struct sk_buff *skb, int len)
>  {
>         struct skb_shared_info *shinfo;
>         int i, k, eat;
> @@ -1277,7 +1277,7 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
>                 __skb_pull(skb, eat);
>                 len -= eat;
>                 if (!len)
> -                       return;
> +                       return 0;
>         }
>         eat = len;
>         k = 0;
> @@ -1303,23 +1303,28 @@ static void __pskb_trim_head(struct sk_buff *skb, int len)
>         skb_reset_tail_pointer(skb);
>         skb->data_len -= len;
>         skb->len = skb->data_len;
> +       return len;
>  }
>
>  /* Remove acked data from a packet in the transmit queue. */
>  int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
>  {
> +       u32 delta_truesize;
> +
>         if (skb_unclone(skb, GFP_ATOMIC))
>                 return -ENOMEM;
>
> -       __pskb_trim_head(skb, len);
> +       delta_truesize = __pskb_trim_head(skb, len);
>
>         TCP_SKB_CB(skb)->seq += len;
>         skb->ip_summed = CHECKSUM_PARTIAL;
>
> -       skb->truesize        -= len;
> -       sk->sk_wmem_queued   -= len;
> -       sk_mem_uncharge(sk, len);
> -       sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
> +       if (delta_truesize) {
> +               skb->truesize      -= delta_truesize;
> +               sk->sk_wmem_queued -= delta_truesize;
> +               sk_mem_uncharge(sk, delta_truesize);
> +               sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
> +       }
>
>         /* Any change of skb->len requires recalculation of tso factor. */
>         if (tcp_skb_pcount(skb) > 1)
>
>
