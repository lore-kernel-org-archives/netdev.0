From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net] tcp: fix return value for partial writes
Date: Wed, 2 Nov 2016 17:47:23 -0400
Message-ID: <CACSApvaoAdX+x_VPyKY7d72OOobw77JsrvfJW9u7f3pq-_fG4Q@mail.gmail.com>
References: <1478122910.7065.396.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f171.google.com ([209.85.213.171]:33587 "EHLO
        mail-yb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932325AbcKBVsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 17:48:04 -0400
Received: by mail-yb0-f171.google.com with SMTP id o7so10157423ybb.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 14:48:04 -0700 (PDT)
In-Reply-To: <1478122910.7065.396.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2016 at 5:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> After my commit, tcp_sendmsg() might restart its loop after
> processing socket backlog.
>
> If sk_err is set, we blindly return an error, even though we
> copied data to user space before.
>
> We should instead return number of bytes that could be copied,
> otherwise user space might resend data and corrupt the stream.
>
> This might happen if another thread is using recvmsg(MSG_ERRQUEUE)
> to process timestamps.
>
> Issue was diagnosed by Soheil and Willem, big kudos to them !
>
> Fixes: d41a69f1d390f ("tcp: make tcp_sendmsg() aware of socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Tested-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv4/tcp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 3251fe71f39f..19e1468bf8ea 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1164,7 +1164,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>
>         err = -EPIPE;
>         if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
> -               goto out_err;
> +               goto do_error;
>
>         sg = !!(sk->sk_route_caps & NETIF_F_SG);
>
>
>

Nice fix. Thanks, Eric!
