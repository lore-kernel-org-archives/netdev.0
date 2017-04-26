From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH net] net: adjust skb->truesize in ___pskb_trim()
Date: Wed, 26 Apr 2017 19:08:40 +0200
Message-ID: <CAAeHK+xTtA-L7VJsP9GXHpVD=o-WOEJ+xD_sJ4b4O-F_aZx_aw@mail.gmail.com>
References: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:36361 "EHLO
        mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdDZRIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:08:42 -0400
Received: by mail-yw0-f178.google.com with SMTP id l18so3586737ywh.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:08:41 -0700 (PDT)
In-Reply-To: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
> skb_try_coalesce() using syzkaller and a filter attached to a TCP
> socket.
>
> As we did recently in commit 158f323b9868 ("net: adjust skb->truesize in
> pskb_expand_head()") we can adjust skb->truesize from ___pskb_trim(),
> via a call to skb_condense().
>
> If all frags were freed, then skb->truesize can be recomputed.
>
> This call can be done if skb is not yet owned, or destructor is
> sock_edemux().

Hi Eric,

I still see the warning even with your patch.

Thanks!

>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  net/core/skbuff.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f86bf69cfb8d8bc17262cdba5d9f57a4726cd476..f1d04592ace02f32efa6e05df89c9a5e0023157f 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1576,6 +1576,8 @@ int ___pskb_trim(struct sk_buff *skb, unsigned int len)
>                 skb_set_tail_pointer(skb, len);
>         }
>
> +       if (!skb->sk || skb->destructor == sock_edemux)
> +               skb_condense(skb);
>         return 0;
>  }
>  EXPORT_SYMBOL(___pskb_trim);
>
>
