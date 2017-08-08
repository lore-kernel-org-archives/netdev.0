From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should conform
 to RFC5482
Date: Tue, 8 Aug 2017 10:25:26 -0700
Message-ID: <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
References: <20170807181614.GA16700@caduceus5>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>
To: Rao Shoaib <rao.shoaib@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35880 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752221AbdHHR0I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 13:26:08 -0400
Received: by mail-wm0-f50.google.com with SMTP id t201so12879034wmt.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 10:26:07 -0700 (PDT)
In-Reply-To: <20170807181614.GA16700@caduceus5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 7, 2017 at 11:16 AM, Rao Shoaib <rao.shoaib@oracle.com> wrote:
> Change from version 0: Rationale behind the change:
>
> The man page for tcp(7) states
>
> when used with the TCP keepalive (SO_KEEPALIVE) option, TCP_USER_TIMEOUT will
> override keepalive to  determine  when to close a connection due to keepalive
> failure.
>
> This is ambigious at best. user expectation is most likely that the connection
> will be reset after TCP_USER_TIMEOUT milliseconds of inactivity.
ccing the original author Jerry Chu who can tell more.

>
> The code however waits for the keepalive to kick-in (default 2hrs) and than
> after one failure resets the conenction.
>
> What is the rationale for that ? The same effect can be obtained by simply
> changing the value of tcp_keep_alive_probes.
>
> Since the TCP_USER_TIMEOUT option was added based on RFC 5482 we need to follow
> the RFC. Which states
>
> 4.2 TCP keep-Alives:
>    Some TCP implementations, such as those in BSD systems, use a
>    different abort policy for TCP keep-alives than for user data.  Thus,
>    the TCP keep-alive mechanism might abort a connection that would
>    otherwise have survived the transient period without connectivity.
>    Therefore, if a connection that enables keep-alives is also using the
>    TCP User Timeout Option, then the keep-alive timer MUST be set to a
>    value larger than that of the adopted USER TIMEOUT.
>
> This patch enforces the MUST and also dis-associates user timeout from keep
> alive.  A man page patch will be submitted separately.
>
> Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
> ---
>  net/ipv4/tcp.c       | 10 ++++++++--
>  net/ipv4/tcp_timer.c |  9 +--------
>  2 files changed, 9 insertions(+), 10 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 71ce33d..f2af44d 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2628,7 +2628,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>                 break;
>
>         case TCP_KEEPIDLE:
> -               if (val < 1 || val > MAX_TCP_KEEPIDLE)
> +               /* Per RFC5482 keepalive_time must be > user_timeout */
> +               if (val < 1 || val > MAX_TCP_KEEPIDLE ||
> +                   ((val * HZ) <= icsk->icsk_user_timeout))
>                         err = -EINVAL;
>                 else {
>                         tp->keepalive_time = val * HZ;
> @@ -2724,8 +2726,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>         case TCP_USER_TIMEOUT:
>                 /* Cap the max time in ms TCP will retry or probe the window
>                  * before giving up and aborting (ETIMEDOUT) a connection.
> +                * Per RFC5482 TCP user timeout must be < keepalive_time.
> +                * If the default value changes later -- all bets are off.
>                  */
> -               if (val < 0)
> +               if (val < 0 || (tp->keepalive_time &&
> +                               tp->keepalive_time <= msecs_to_jiffies(val)) ||
> +                  net->ipv4.sysctl_tcp_keepalive_time <= msecs_to_jiffies(val))
>                         err = -EINVAL;
>                 else
>                         icsk->icsk_user_timeout = msecs_to_jiffies(val);
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index c0feeee..d39fe60 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -664,14 +664,7 @@ static void tcp_keepalive_timer (unsigned long data)
>         elapsed = keepalive_time_elapsed(tp);
>
>         if (elapsed >= keepalive_time_when(tp)) {
> -               /* If the TCP_USER_TIMEOUT option is enabled, use that
> -                * to determine when to timeout instead.
> -                */
> -               if ((icsk->icsk_user_timeout != 0 &&
> -                   elapsed >= icsk->icsk_user_timeout &&
> -                   icsk->icsk_probes_out > 0) ||
> -                   (icsk->icsk_user_timeout == 0 &&
> -                   icsk->icsk_probes_out >= keepalive_probes(tp))) {
> +               if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
>                         tcp_send_active_reset(sk, GFP_ATOMIC);
>                         tcp_write_err(sk);
>                         goto out;
> --
> 2.7.4
>
