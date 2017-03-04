From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net 1/2] net: fix socket refcounting in skb_complete_wifi_ack()
Date: Fri, 3 Mar 2017 19:43:41 -1000
Message-ID: <CACSApvY_FoJ6E2dZmEri_70aDSkD3ZLgwrUHECKkawfNPnuddA@mail.gmail.com>
References: <20170304050103.12226-1-edumazet@google.com> <20170304050103.12226-2-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:37846 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdCDFxm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Mar 2017 00:53:42 -0500
Received: by mail-it0-f45.google.com with SMTP id 203so25344143ith.0
        for <netdev@vger.kernel.org>; Fri, 03 Mar 2017 21:53:26 -0800 (PST)
In-Reply-To: <20170304050103.12226-2-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 3, 2017 at 7:01 PM, Eric Dumazet <edumazet@google.com> wrote:
> TX skbs do not necessarily hold a reference on skb->sk->sk_refcnt
> By the time TX completion happens, sk_refcnt might be already 0.
>
> sock_hold()/sock_put() would then corrupt critical state, like
> sk_wmem_alloc.
>
> Fixes: bf7fa551e0ce ("mac80211: Resolve sk_refcnt/sk_wmem_alloc issue in wifi ack path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Johannes Berg <johannes@sipsolutions.net>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/core/skbuff.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f3557958e9bf147631a90b51fef0630920acd97b..e2f37a560ec43ccf60a71f190423bd265eccf594 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3893,7 +3893,7 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
>  {
>         struct sock *sk = skb->sk;
>         struct sock_exterr_skb *serr;
> -       int err;
> +       int err = 1;
>
>         skb->wifi_acked_valid = 1;
>         skb->wifi_acked = acked;
> @@ -3903,14 +3903,15 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
>         serr->ee.ee_errno = ENOMSG;
>         serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
>
> -       /* take a reference to prevent skb_orphan() from freeing the socket */
> -       sock_hold(sk);
> -
> -       err = sock_queue_err_skb(sk, skb);
> +       /* Take a reference to prevent skb_orphan() from freeing the socket,
> +        * but only if the socket refcount is not zero.
> +        */
> +       if (likely(atomic_inc_not_zero(&sk->sk_refcnt))) {
> +               err = sock_queue_err_skb(sk, skb);
> +               sock_put(sk);
> +       }
>         if (err)
>                 kfree_skb(skb);
> -
> -       sock_put(sk);
>  }
>  EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
>
> --
> 2.12.0.rc1.440.g5b76565f74-goog
>

Nice fix!
