From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 4/6] tcp: remove header prediction
Date: Tue, 1 Aug 2017 13:23:55 -0400
Message-ID: <CADVnQy=PTR+uPTaEBrTt37j0v-2+-YBxkP0PdOnG7dAwPQEHcg@mail.gmail.com>
References: <20170730015723.25587-1-fw@strlen.de> <20170730015723.25587-5-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33280 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdHARY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 13:24:27 -0400
Received: by mail-oi0-f47.google.com with SMTP id d71so16927266oih.0
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 10:24:26 -0700 (PDT)
In-Reply-To: <20170730015723.25587-5-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 29, 2017 at 9:57 PM, Florian Westphal <fw@strlen.de> wrote:
> @@ -5519,11 +5347,10 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
>         if (sock_flag(sk, SOCK_KEEPOPEN))
>                 inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
>
> -       if (!tp->rx_opt.snd_wscale)
> -               __tcp_fast_path_on(tp, tp->snd_wnd);
> -       else
> -               tp->pred_flags = 0;
> -
> +       if (!sock_flag(sk, SOCK_DEAD)) {
> +               sk->sk_state_change(sk);
> +               sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT);
> +       }
>  }
>

This patch hunk seems like it introduces a minor bug. It seems like
after this change, the sk_state_change() and sk_wake_async() calls for
a completed active connection happen twice: once in this new spot
inside tcp_finish_connect() and once in the existing code in
tcp_rcv_synsent_state_process() immediately after it calls
tcp_finish_connect().

I would vote for removing this new code snippet and retaining the old
one, in case there are subtle interactions with
tcp_rcv_fastopen_synack(), which happens in between the new wake-up
location and the old wake-up location.

neal
