From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 22:15:16 +0800
Message-ID: <CAF1ivSaU_ur9BkKG3eAsNw7d+ND5xgYbPKutemVqNec3X9m4SA@mail.gmail.com>
References: <20120818021918.GA6499@localhost>
	<1345380682.5158.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:49058 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752941Ab2HSOQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 10:16:07 -0400
In-Reply-To: <1345380682.5158.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 19, 2012 at 8:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
<snip...>
> Hi Fengguang, thanks for this report.
>
> Hmm, this looks like sk_reset_timer() is called on a socket, and timer
> triggers _before_ the sock_hold()
>
> So the timer handler decrements sk_refcnt to 0 and calls sk_free()
>
> Its probably a bug introduced (or uncovered) by commit 6f458dfb40 (tcp:
> improve latencies of timer triggered events)
>
> I always found sk_reset_timer() a bit racy...
>
> void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>                     unsigned long expires)
> {
>         if (!mod_timer(timer, expires))
>                 sock_hold(sk); // MIGHT BE TOO LATE
> }
>
> Following should be safer...
>
> void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>                     unsigned long expires)
> {
>         sock_hold(sk);
>         if (mod_timer(timer, expires))
>                 sock_put(sk);
> }
>
> Could you test following patch ?
>
> By the way, there is a typo in tcp_delack_timer()
> (should use TCP_DELACK_TIMER_DEFERRED instead of
> TCP_WRITE_TIMER_DEFERRED)
>
>
> Thanks !
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 7678237..6278a11 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -417,10 +417,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
>
>                 if (code == ICMP_FRAG_NEEDED) { /* PMTU discovery (RFC1191) */
>                         tp->mtu_info = info;
> -                       if (!sock_owned_by_user(sk))
> +                       if (!sock_owned_by_user(sk)) {
>                                 tcp_v4_mtu_reduced(sk);
> -                       else
> -                               set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags);
> +                       } else {
> +                               if (!test_and_set_bit(TCP_MTU_REDUCED_DEFERRED, &tp->tsq_flags))
> +                                       sock_hold(sk);
> +                       }
>                         goto out;
>                 }
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 20dfd89..d046326 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -910,14 +910,18 @@ void tcp_release_cb(struct sock *sk)
>         if (flags & (1UL << TCP_TSQ_DEFERRED))
>                 tcp_tsq_handler(sk);
>
> -       if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED))
> +       if (flags & (1UL << TCP_WRITE_TIMER_DEFERRED)) {
>                 tcp_write_timer_handler(sk);
> -
> -       if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED))
> +               __sock_put(sk);
> +       }
> +       if (flags & (1UL << TCP_DELACK_TIMER_DEFERRED)) {
>                 tcp_delack_timer_handler(sk);
> -
> -       if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED))
> +               __sock_put(sk);
> +       }
> +       if (flags & (1UL << TCP_MTU_REDUCED_DEFERRED)) {
>                 sk->sk_prot->mtu_reduced(sk);
> +               __sock_put(sk);
> +       }
>  }
>  EXPORT_SYMBOL(tcp_release_cb);
>
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 6df36ad..b774a03 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -252,7 +252,8 @@ static void tcp_delack_timer(unsigned long data)
>                 inet_csk(sk)->icsk_ack.blocked = 1;
>                 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
>                 /* deleguate our work to tcp_release_cb() */
> -               set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
> +               if (!test_and_set_bit(TCP_DELACK_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags))
> +                       sock_hold(sk);
>         }
>         bh_unlock_sock(sk);
>         sock_put(sk);
> @@ -481,7 +482,8 @@ static void tcp_write_timer(unsigned long data)
>                 tcp_write_timer_handler(sk);

Will it still has problem if code goes here without sock_hold(sk)?

>         } else {
>                 /* deleguate our work to tcp_release_cb() */
> -               set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags);
> +               if (!test_and_set_bit(TCP_WRITE_TIMER_DEFERRED, &tcp_sk(sk)->tsq_flags))
> +                       sock_hold(sk);
>         }
>         bh_unlock_sock(sk);
>         sock_put(sk);
>
