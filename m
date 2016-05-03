From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] tcp: guarantee forward progress in tcp_sendmsg()
Date: Tue, 3 May 2016 00:53:09 -0400
Message-ID: <CACSApvY_eRfr4ukOha6ebxz1VHiSYQGAhP9hRJApbL3zHsAzUw@mail.gmail.com>
References: <1461964613-4872-1-git-send-email-edumazet@google.com>
 <1461964613-4872-8-git-send-email-edumazet@google.com> <1462250965.5535.286.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33497 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbcECExt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 00:53:49 -0400
Received: by mail-oi0-f47.google.com with SMTP id v145so11525419oie.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 21:53:49 -0700 (PDT)
In-Reply-To: <1462250965.5535.286.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 3, 2016 at 12:49 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Under high rx pressure, it is possible tcp_sendmsg() never has a
> chance to allocate an skb and loop forever as sk_flush_backlog()
> would always return true.
>
> Fix this by calling sk_flush_backlog() only if one skb had been
> allocated and filled before last backlog check.
>
> Fixes: d41a69f1d390 ("tcp: make tcp_sendmsg() aware of socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
> ---
>  net/ipv4/tcp.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b945c2b046c5ead5503505f250c3c67761b284ae..5c7ed147449c1b7ba029b12e033ad779a631460a 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1084,6 +1084,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>         struct sockcm_cookie sockc;
>         int flags, err, copied = 0;
>         int mss_now = 0, size_goal, copied_syn = 0;
> +       bool process_backlog = false;
>         bool sg;
>         long timeo;
>
> @@ -1167,9 +1168,10 @@ new_segment:
>                         if (!sk_stream_memory_free(sk))
>                                 goto wait_for_sndbuf;
>
> -                       if (sk_flush_backlog(sk))
> +                       if (process_backlog && sk_flush_backlog(sk)) {
> +                               process_backlog = false;
>                                 goto restart;
> -
> +                       }
>                         skb = sk_stream_alloc_skb(sk,
>                                                   select_size(sk, sg),
>                                                   sk->sk_allocation,
> @@ -1177,6 +1179,7 @@ new_segment:
>                         if (!skb)
>                                 goto wait_for_memory;
>
> +                       process_backlog = true;
>                         /*
>                          * Check whether we can use HW checksum.
>                          */
>
>

Nice catch! Thanks.
