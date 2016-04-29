From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v2 net-next 2/7] tcp: do not block bh during prequeue processing
Date: Fri, 29 Apr 2016 09:20:19 -0400
Message-ID: <CACSApvY_StBa121b8o+QDR7F+aPVT2Xj+AFxdWZ-HvEzcKie7w@mail.gmail.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com> <1461899449-8096-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34667 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbcD2NVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:21:00 -0400
Received: by mail-oi0-f51.google.com with SMTP id k142so117983304oib.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:21:00 -0700 (PDT)
In-Reply-To: <1461899449-8096-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:
> AFAIK, nothing in current TCP stack absolutely wants BH
> being disabled once socket is owned by a thread running in
> process context.
>
> As mentioned in my prior patch ("tcp: give prequeue mode some care"),
> processing a batch of packets might take time, better not block BH
> at all.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/ipv4/tcp.c       |  4 ----
>  net/ipv4/tcp_input.c | 30 ++----------------------------
>  2 files changed, 2 insertions(+), 32 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b24c6ed4a04f..4787f86ae64c 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1449,12 +1449,8 @@ static void tcp_prequeue_process(struct sock *sk)
>
>         NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPPREQUEUED);
>
> -       /* RX process wants to run with disabled BHs, though it is not
> -        * necessary */
> -       local_bh_disable();
>         while ((skb = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
>                 sk_backlog_rcv(sk, skb);
> -       local_bh_enable();
>
>         /* Clear memory counter. */
>         tp->ucopy.memory = 0;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ac85fb42a5a2..6171f92be090 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4611,14 +4611,12 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
>
>                         __set_current_state(TASK_RUNNING);
>
> -                       local_bh_enable();
>                         if (!skb_copy_datagram_msg(skb, 0, tp->ucopy.msg, chunk)) {
>                                 tp->ucopy.len -= chunk;
>                                 tp->copied_seq += chunk;
>                                 eaten = (chunk == skb->len);
>                                 tcp_rcv_space_adjust(sk);
>                         }
> -                       local_bh_disable();
>                 }
>
>                 if (eaten <= 0) {
> @@ -5134,7 +5132,6 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
>         int chunk = skb->len - hlen;
>         int err;
>
> -       local_bh_enable();
>         if (skb_csum_unnecessary(skb))
>                 err = skb_copy_datagram_msg(skb, hlen, tp->ucopy.msg, chunk);
>         else
> @@ -5146,32 +5143,9 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
>                 tcp_rcv_space_adjust(sk);
>         }
>
> -       local_bh_disable();
>         return err;
>  }
>
> -static __sum16 __tcp_checksum_complete_user(struct sock *sk,
> -                                           struct sk_buff *skb)
> -{
> -       __sum16 result;
> -
> -       if (sock_owned_by_user(sk)) {
> -               local_bh_enable();
> -               result = __tcp_checksum_complete(skb);
> -               local_bh_disable();
> -       } else {
> -               result = __tcp_checksum_complete(skb);
> -       }
> -       return result;
> -}
> -
> -static inline bool tcp_checksum_complete_user(struct sock *sk,
> -                                            struct sk_buff *skb)
> -{
> -       return !skb_csum_unnecessary(skb) &&
> -              __tcp_checksum_complete_user(sk, skb);
> -}
> -
>  /* Does PAWS and seqno based validation of an incoming segment, flags will
>   * play significant role here.
>   */
> @@ -5386,7 +5360,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>                                 }
>                         }
>                         if (!eaten) {
> -                               if (tcp_checksum_complete_user(sk, skb))
> +                               if (tcp_checksum_complete(skb))
>                                         goto csum_error;
>
>                                 if ((int)skb->truesize > sk->sk_forward_alloc)
> @@ -5430,7 +5404,7 @@ no_ack:
>         }
>
>  slow_path:
> -       if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
> +       if (len < (th->doff << 2) || tcp_checksum_complete(skb))
>                 goto csum_error;
>
>         if (!th->ack && !th->rst && !th->syn)
> --
> 2.8.0.rc3.226.g39d4020
>
Very nice!
