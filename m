From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC net-next 1/2] net: add SOCK_RCU_FREE socket flag
Date: Fri, 25 Mar 2016 17:08:50 -0700
Message-ID: <CALx6S37=gjXKrPMf=fbEe-k_HHO38COXAAaP70-70vfNQ0C0_Q@mail.gmail.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	<1458944964-12890-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36467 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbcCZAIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 20:08:51 -0400
Received: by mail-io0-f178.google.com with SMTP id 124so126077962iov.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 17:08:51 -0700 (PDT)
In-Reply-To: <1458944964-12890-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 3:29 PM, Eric Dumazet <edumazet@google.com> wrote:
> We want a generic way to insert an RCU grace period before socket
> freeing for cases where RCU_SLAB_DESTROY_BY_RCU is adding too
> much overhead.
>
> SLAB_DESTROY_BY_RCU strict rules force us to take a reference
> on the socket sk_refcnt, and it is a performance problem for UDP
> encapsulation, or TCP synflood behavior, as many CPUs might
> attempt the atomic operations on a shared sk_refcnt
>
> UDP sockets and TCP listeners can set SOCK_RCU_FREE so that their
> lookup can use traditional RCU rules, without refcount changes.
> They can set the flag only once hashed and visible by other cpus.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/sock.h |  2 ++
>  net/core/sock.c    | 14 +++++++++++++-
>  2 files changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 255d3e03727b..c88785a3e76c 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -438,6 +438,7 @@ struct sock {
>                                                   struct sk_buff *skb);
>         void                    (*sk_destruct)(struct sock *sk);
>         struct sock_reuseport __rcu     *sk_reuseport_cb;
> +       struct rcu_head         sk_rcu;
>  };
>
>  #define __sk_user_data(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
> @@ -720,6 +721,7 @@ enum sock_flags {
>                      */
>         SOCK_FILTER_LOCKED, /* Filter cannot be changed anymore */
>         SOCK_SELECT_ERR_QUEUE, /* Wake select on error queue */
> +       SOCK_RCU_FREE, /* wait rcu grace period in sk_destruct() */
>  };
>
>  #define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
> diff --git a/net/core/sock.c b/net/core/sock.c
> index b67b9aedb230..238a94f879ca 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1418,8 +1418,12 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>  }
>  EXPORT_SYMBOL(sk_alloc);
>
> -void sk_destruct(struct sock *sk)
> +/* Sockets having SOCK_RCU_FREE will call this function after one RCU
> + * grace period. This is the case for UDP sockets and TCP listeners.
> + */
> +static void __sk_destruct(struct rcu_head *head)
>  {
> +       struct sock *sk = container_of(head, struct sock, sk_rcu);
>         struct sk_filter *filter;
>
>         if (sk->sk_destruct)
> @@ -1448,6 +1452,14 @@ void sk_destruct(struct sock *sk)
>         sk_prot_free(sk->sk_prot_creator, sk);
>  }
>
> +void sk_destruct(struct sock *sk)
> +{
> +       if (sock_flag(sk, SOCK_RCU_FREE))
> +               call_rcu(&sk->sk_rcu, __sk_destruct);
> +       else
> +               __sk_destruct(&sk->sk_rcu);
> +}
> +

Very nice!

>  static void __sk_free(struct sock *sk)
>  {
>         if (unlikely(sock_diag_has_destroy_listeners(sk) && sk->sk_net_refcnt))
> --
> 2.8.0.rc3.226.g39d4020
>
