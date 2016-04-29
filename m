From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH v2 net-next 7/7] tcp: make tcp_sendmsg() aware of socket backlog
Date: Fri, 29 Apr 2016 09:13:39 -0400
Message-ID: <CACSApvYfhn9vUR3BDGqcj1-sYxvKcK_C_J-5a1fRT7UUqBr4mA@mail.gmail.com>
References: <1461899449-8096-1-git-send-email-edumazet@google.com> <1461899449-8096-8-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36559 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbcD2NOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:14:20 -0400
Received: by mail-oi0-f48.google.com with SMTP id x201so117752230oif.3
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:14:20 -0700 (PDT)
In-Reply-To: <1461899449-8096-8-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 11:10 PM, Eric Dumazet <edumazet@google.com> wrote:
> Large sendmsg()/write() hold socket lock for the duration of the call,
> unless sk->sk_sndbuf limit is hit. This is bad because incoming packets
> are parked into socket backlog for a long time.
> Critical decisions like fast retransmit might be delayed.
> Receivers have to maintain a big out of order queue with additional cpu
> overhead, and also possible stalls in TX once windows are full.
>
> Bidirectional flows are particularly hurt since the backlog can become
> quite big if the copy from user space triggers IO (page faults)
>
> Some applications learnt to use sendmsg() (or sendmmsg()) with small
> chunks to avoid this issue.
>
> Kernel should know better, right ?
>
> Add a generic sk_flush_backlog() helper and use it right
> before a new skb is allocated. Typically we put 64KB of payload
> per skb (unless MSG_EOR is requested) and checking socket backlog
> every 64KB gives good results.
>
> As a matter of fact, tests with TSO/GSO disabled give very nice
> results, as we manage to keep a small write queue and smaller
> perceived rtt.
>
> Note that sk_flush_backlog() maintains socket ownership,
> so is not equivalent to a {release_sock(sk); lock_sock(sk);},
> to ensure implicit atomicity rules that sendmsg() was
> giving to (possibly buggy) applications.
>
> In this simple implementation, I chose to not call tcp_release_cb(),
> but we might consider this later.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-By: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  include/net/sock.h | 11 +++++++++++
>  net/core/sock.c    |  7 +++++++
>  net/ipv4/tcp.c     |  8 ++++++--
>  3 files changed, 24 insertions(+), 2 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3df778ccaa82..1dbb1f9f7c1b 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -926,6 +926,17 @@ void sk_stream_kill_queues(struct sock *sk);
>  void sk_set_memalloc(struct sock *sk);
>  void sk_clear_memalloc(struct sock *sk);
>
> +void __sk_flush_backlog(struct sock *sk);
> +
> +static inline bool sk_flush_backlog(struct sock *sk)
> +{
> +       if (unlikely(READ_ONCE(sk->sk_backlog.tail))) {
> +               __sk_flush_backlog(sk);
> +               return true;
> +       }
> +       return false;
> +}
> +
>  int sk_wait_data(struct sock *sk, long *timeo, const struct sk_buff *skb);
>
>  struct request_sock_ops;
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 70744dbb6c3f..f615e9391170 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2048,6 +2048,13 @@ static void __release_sock(struct sock *sk)
>         sk->sk_backlog.len = 0;
>  }
>
> +void __sk_flush_backlog(struct sock *sk)
> +{
> +       spin_lock_bh(&sk->sk_lock.slock);
> +       __release_sock(sk);
> +       spin_unlock_bh(&sk->sk_lock.slock);
> +}
> +
>  /**
>   * sk_wait_data - wait for data to arrive at sk_receive_queue
>   * @sk:    sock to wait on
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 4787f86ae64c..b945c2b046c5 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1136,11 +1136,12 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>         /* This should be in poll */
>         sk_clear_bit(SOCKWQ_ASYNC_NOSPACE, sk);
>
> -       mss_now = tcp_send_mss(sk, &size_goal, flags);
> -
>         /* Ok commence sending. */
>         copied = 0;
>
> +restart:
> +       mss_now = tcp_send_mss(sk, &size_goal, flags);
> +
>         err = -EPIPE;
>         if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
>                 goto out_err;
> @@ -1166,6 +1167,9 @@ new_segment:
>                         if (!sk_stream_memory_free(sk))
>                                 goto wait_for_sndbuf;
>
> +                       if (sk_flush_backlog(sk))
> +                               goto restart;
> +
>                         skb = sk_stream_alloc_skb(sk,
>                                                   select_size(sk, sg),
>                                                   sk->sk_allocation,
> --
> 2.8.0.rc3.226.g39d4020
>

This is superb Eric! Thanks.
