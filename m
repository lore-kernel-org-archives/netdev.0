From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: remove poll() flakes when receiving RST
Date: Tue, 18 Apr 2017 13:49:10 -0400
Message-ID: <CADAM+B2WsyLzvugHHhDAoSt6sSwf3FRB-jizEnqMpv2skLcQEw@mail.gmail.com>
References: <20170418164552.29261-1-edumazet@google.com> <20170418164552.29261-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:32970 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757316AbdDRRtL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:49:11 -0400
Received: by mail-ua0-f193.google.com with SMTP id f10so24939uaa.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:49:11 -0700 (PDT)
In-Reply-To: <20170418164552.29261-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 12:45 PM, Eric Dumazet <edumazet@google.com> wrote:
> When a RST packet is processed, we send two wakeup events to interested
> polling users.
>
> First one by a sk->sk_error_report(sk) from tcp_reset(),
> followed by a sk->sk_state_change(sk) from tcp_done().
>
> Depending on machine load and luck, poll() can either return POLLERR,
> or POLLIN|POLLOUT|POLLERR|POLLHUP (this happens on 99 % of the cases)
>
> This is probably fine, but we can avoid the confusion by reordering
> things so that we have more TCP fields updated before the first wakeup.
>
> This might even allow us to remove some barriers we added in the past.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp_input.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index a5838858c362cd3270296001ceaae341e9e9bf01..37e2aa925f62395cfb48145cd3a76b6afebb64b1 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4008,10 +4008,10 @@ void tcp_reset(struct sock *sk)
>         /* This barrier is coupled with smp_rmb() in tcp_poll() */
>         smp_wmb();
>
> +       tcp_done(sk);
> +
>         if (!sock_flag(sk, SOCK_DEAD))
>                 sk->sk_error_report(sk);
> -
> -       tcp_done(sk);
>  }
>
>  /*
> --
> 2.12.2.762.g0e3151a226-goog
>

Thanks, Eric. Nice improvement!
