From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: refine tcp_prune_ofo_queue() to not drop
 all packets
Date: Thu, 18 Aug 2016 10:55:39 -0700
Message-ID: <CAK6E8=cVpvGLLzXBGsTm1E692bi1jvQ70Dp0QsaB94smvhzrGQ@mail.gmail.com>
References: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        "C. Stephen Gun" <csg@google.com>, Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:32928 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754101AbcHSAuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:50:07 -0400
Received: by mail-io0-f180.google.com with SMTP id 38so35020206iol.0
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:50:06 -0700 (PDT)
In-Reply-To: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 2:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> Over the years, TCP BDP has increased a lot, and is typically
> in the order of ~10 Mbytes with help of clever Congestion Control
> modules.
>
> In presence of packet losses, TCP stores incoming packets into an out of
> order queue, and number of skbs sitting there waiting for the missing
> packets to be received can match the BDP (~10 Mbytes)
>
> In some cases, TCP needs to make room for incoming skbs, and current
> strategy can simply remove all skbs in the out of order queue as a last
> resort, incurring a huge penalty, both for receiver and sender.
>
> Unfortunately these 'last resort events' are quite frequent, forcing
> sender to send all packets again, stalling the flow and wasting a lot of
> resources.
>
> This patch cleans only a part of the out of order queue in order
> to meet the memory constraints.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: C. Stephen Gun <csg@google.com>
> Cc: Van Jacobson <vanj@google.com>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>

Nice patch


>  net/ipv4/tcp_input.c |   47 ++++++++++++++++++++++++-----------------
>  1 file changed, 28 insertions(+), 19 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 3ebf45b38bc309f448dbc4f27fe8722cefabaf19..8cd02c0b056cbc22e2e4a4fe8530b74f7bd25419 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4392,12 +4392,9 @@ static int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb,
>                 if (tcp_prune_queue(sk) < 0)
>                         return -1;
>
> -               if (!sk_rmem_schedule(sk, skb, size)) {
> +               while (!sk_rmem_schedule(sk, skb, size)) {
>                         if (!tcp_prune_ofo_queue(sk))
>                                 return -1;
> -
> -                       if (!sk_rmem_schedule(sk, skb, size))
> -                               return -1;
>                 }
>         }
>         return 0;
> @@ -4874,29 +4871,41 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
>  }
>
>  /*
> - * Purge the out-of-order queue.
> - * Return true if queue was pruned.
> + * Clean the out-of-order queue to make room.
> + * We drop high sequences packets to :
> + * 1) Let a chance for holes to be filled.
> + * 2) not add too big latencies if thousands of packets sit there.
> + *    (But if application shrinks SO_RCVBUF, we could still end up
> + *     freeing whole queue here)
> + *
> + * Return true if queue has shrunk.
>   */
>  static bool tcp_prune_ofo_queue(struct sock *sk)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
> -       bool res = false;
> +       struct sk_buff *skb;
>
> -       if (!skb_queue_empty(&tp->out_of_order_queue)) {
> -               NET_INC_STATS(sock_net(sk), LINUX_MIB_OFOPRUNED);
> -               __skb_queue_purge(&tp->out_of_order_queue);
> +       if (skb_queue_empty(&tp->out_of_order_queue))
> +               return false;
>
> -               /* Reset SACK state.  A conforming SACK implementation will
> -                * do the same at a timeout based retransmit.  When a connection
> -                * is in a sad state like this, we care only about integrity
> -                * of the connection not performance.
> -                */
> -               if (tp->rx_opt.sack_ok)
> -                       tcp_sack_reset(&tp->rx_opt);
> +       NET_INC_STATS(sock_net(sk), LINUX_MIB_OFOPRUNED);
> +
> +       while ((skb = __skb_dequeue_tail(&tp->out_of_order_queue)) != NULL) {
> +               tcp_drop(sk, skb);
>                 sk_mem_reclaim(sk);
> -               res = true;
> +               if (atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf &&
> +                   !tcp_under_memory_pressure(sk))
> +                       break;
>         }
> -       return res;
> +
> +       /* Reset SACK state.  A conforming SACK implementation will
> +        * do the same at a timeout based retransmit.  When a connection
> +        * is in a sad state like this, we care only about integrity
> +        * of the connection not performance.
> +        */
> +       if (tp->rx_opt.sack_ok)
> +               tcp_sack_reset(&tp->rx_opt);
I am curious what if we don't reset. It seems SACK will continue to
function properly (at least for Linux sender). But this of course
belongs  to a different patch / discussion.

> +       return true;
>  }
>
>  /* Reduce allocated memory if we can, trying to get
>
>
