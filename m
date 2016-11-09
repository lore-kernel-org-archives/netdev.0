From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] tcp: remove unaligned accesses from tcp_get_info()
Date: Wed, 9 Nov 2016 14:30:22 -0500
Message-ID: <CACSApvb8hYfJYhKkViJEoetCLJx+3AjtKVT9pKMyWzJ0a42qyg@mail.gmail.com>
References: <1478285672-3195-1-git-send-email-edumazet@google.com>
 <20161109.130319.505221196913812307.davem@davemloft.net> <1478717921.16809.0.camel@edumazet-glaptop3.roam.corp.google.com>
 <1478719462.16809.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:35332 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcKITbD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 14:31:03 -0500
Received: by mail-yw0-f178.google.com with SMTP id i145so121995522ywg.2
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 11:31:03 -0800 (PST)
In-Reply-To: <1478719462.16809.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 9, 2016 at 2:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> After commit 6ed46d1247a5 ("sock_diag: align nlattr properly when
> needed"), tcp_get_info() gets 64bit aligned memory, so we can avoid
> the unaligned helpers.
>
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index a7d54cbcdabbbc0838c00e05074ef15560665f2d..f8f924ca662d5c84e438a6eacbe8f734ff0674ae 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -279,7 +279,6 @@
>
>  #include <asm/uaccess.h>
>  #include <asm/ioctls.h>
> -#include <asm/unaligned.h>
>  #include <net/busy_poll.h>
>
>  int sysctl_tcp_min_tso_segs __read_mostly = 2;
> @@ -2722,11 +2721,11 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>         /* Report meaningful fields for all TCP states, including listeners */
>         rate = READ_ONCE(sk->sk_pacing_rate);
>         rate64 = rate != ~0U ? rate : ~0ULL;
> -       put_unaligned(rate64, &info->tcpi_pacing_rate);
> +       info->tcpi_pacing_rate = rate64;
>
>         rate = READ_ONCE(sk->sk_max_pacing_rate);
>         rate64 = rate != ~0U ? rate : ~0ULL;
> -       put_unaligned(rate64, &info->tcpi_max_pacing_rate);
> +       info->tcpi_max_pacing_rate = rate64;
>
>         info->tcpi_reordering = tp->reordering;
>         info->tcpi_snd_cwnd = tp->snd_cwnd;
> @@ -2792,8 +2791,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>
>         slow = lock_sock_fast(sk);
>
> -       put_unaligned(tp->bytes_acked, &info->tcpi_bytes_acked);
> -       put_unaligned(tp->bytes_received, &info->tcpi_bytes_received);
> +       info->tcpi_bytes_acked = tp->bytes_acked;
> +       info->tcpi_bytes_received = tp->bytes_received;
>         info->tcpi_notsent_bytes = max_t(int, 0, tp->write_seq - tp->snd_nxt);
>
>         unlock_sock_fast(sk, slow);
> @@ -2811,7 +2810,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
>         if (rate && intv) {
>                 rate64 = (u64)rate * tp->mss_cache * USEC_PER_SEC;
>                 do_div(rate64, intv);
> -               put_unaligned(rate64, &info->tcpi_delivery_rate);
> +               info->tcpi_delivery_rate = rate64;
>         }
>  }
>  EXPORT_SYMBOL_GPL(tcp_get_info);
>
>

Very nice! Thanks.
