From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: provide tx timestamps for partial writes
Date: Tue, 3 Jan 2017 13:21:34 -0800
Message-ID: <CAK6E8=c6HmqQ=D0FnXB23ftCKvt08JC8=nRNkzBoi_B-G75NXA@mail.gmail.com>
References: <1483388457-4041-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38868 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757176AbdACVWP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 16:22:15 -0500
Received: by mail-it0-f46.google.com with SMTP id x2so307571765itf.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 13:22:15 -0800 (PST)
In-Reply-To: <1483388457-4041-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 12:20 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
>
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> For TCP sockets, tx timestamps are only captured when the user data
> is successfully and fully written to the socket. In many cases,
> however, TCP writes can be partial for which no timestamp is
> collected.
>
> Collect timestamps when the user data is partially copied into
> the socket.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>
> ---
Acked-by: Yuchung Cheng <ycheng@google.com>

>  net/ipv4/tcp.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 2e3807d..c207b16 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -992,8 +992,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
>         return copied;
>
>  do_error:
> -       if (copied)
> +       if (copied) {
> +               tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
>                 goto out;
> +       }
>  out_err:
>         /* make sure we wake any epoll edge trigger waiter */
>         if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
> @@ -1329,8 +1331,10 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>         }
>
>  do_error:
> -       if (copied + copied_syn)
> +       if (copied + copied_syn) {
> +               tcp_tx_timestamp(sk, sk->sk_tsflags, tcp_write_queue_tail(sk));
>                 goto out;
> +       }
>  out_err:
>         err = sk_stream_error(sk, flags, err);
>         /* make sure we wake any epoll edge trigger waiter */
> --
> 2.8.0.rc3.226.g39d4020
>
