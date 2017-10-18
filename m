From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: fix tcp_send_syn_data()
Date: Wed, 18 Oct 2017 14:40:02 -0700
Message-ID: <CAK6E8=chd=g9Lfjj8t5eFUd6Uev6BPozxOBq3pCQYkSyHTCp2A@mail.gmail.com>
References: <1508361630.31614.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:52540 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdJRVko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 17:40:44 -0400
Received: by mail-wr0-f194.google.com with SMTP id k62so6406766wrc.9
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 14:40:44 -0700 (PDT)
In-Reply-To: <1508361630.31614.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 2:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> syn_data was allocated by sk_stream_alloc_skb(), meaning
> its destructor and _skb_refdst fields are mangled.
>
> We need to call tcp_skb_tsorted_anchor_cleanup() before
> calling kfree_skb() or kernel crashes.
>
> Bug was reported by syzkaller bot.
>
> Fixes: e2080072ed2d ("tcp: new list for sent but unacked skbs for RACK recovery")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Thanks for the fix!
> ---
>  net/ipv4/tcp_output.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 53dc1267c85e668d9a6d5d60d24e6101f7a9c56b..988733f289c8c43f3ed88a9ae1b7f272ab8de1a2 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3383,6 +3383,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
>                 int copied = copy_from_iter(skb_put(syn_data, space), space,
>                                             &fo->data->msg_iter);
>                 if (unlikely(!copied)) {
> +                       tcp_skb_tsorted_anchor_cleanup(syn_data);
>                         kfree_skb(syn_data);
>                         goto fallback;
>                 }
>
>
