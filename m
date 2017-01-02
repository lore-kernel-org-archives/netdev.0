From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH] tcp: provide tx timestamps for partial writes
Date: Mon, 2 Jan 2017 15:23:51 -0500
Message-ID: <CACSApvbYBv4GTGDKFT9jg3p9_w=3WD6aQZh7qwB2HbgCCTFxog@mail.gmail.com>
References: <1483388457-4041-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:34448 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756287AbdABUYd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 15:24:33 -0500
Received: by mail-yw0-f180.google.com with SMTP id t125so274115700ywc.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 12:24:32 -0800 (PST)
In-Reply-To: <1483388457-4041-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 3:20 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
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

I'm sorry for the incomplete annotation. This is for [net-next].

Thanks,
Soheil
