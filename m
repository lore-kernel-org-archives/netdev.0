From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Wed, 26 Apr 2017 20:00:02 -0400
Message-ID: <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-6-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32864 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032854AbdD0AAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 20:00:43 -0400
Received: by mail-oi0-f67.google.com with SMTP id w12so3957563oiw.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 17:00:43 -0700 (PDT)
In-Reply-To: <20170426145035.25846-6-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 81ef53f..42bff22 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -3300,8 +3300,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>
>  static inline void sw_tx_timestamp(struct sk_buff *skb)
>  {
> -       if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
> -           !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
> +       if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP)
>                 skb_tstamp_tx(skb, NULL);
>  }
>
> diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
> index 8fcae35..d251972 100644
> --- a/include/uapi/linux/net_tstamp.h
> +++ b/include/uapi/linux/net_tstamp.h
> @@ -27,8 +27,9 @@ enum {
>         SOF_TIMESTAMPING_OPT_TSONLY = (1<<11),
>         SOF_TIMESTAMPING_OPT_STATS = (1<<12),
>         SOF_TIMESTAMPING_OPT_PKTINFO = (1<<13),
> +       SOF_TIMESTAMPING_OPT_TX_SWHW = (1<<14),
>
> -       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_PKTINFO,
> +       SOF_TIMESTAMPING_LAST = SOF_TIMESTAMPING_OPT_TX_SWHW,
>         SOF_TIMESTAMPING_MASK = (SOF_TIMESTAMPING_LAST - 1) |
>                                  SOF_TIMESTAMPING_LAST
>  };
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 58604c1..db5aa19 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3874,6 +3874,10 @@ void __skb_tstamp_tx(struct sk_buff *orig_skb,
>         if (!sk)
>                 return;
>
> +       if (!hwtstamps && !(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW) &&
> +           skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)
> +               return;
> +

This check should only happen for software transmit timestamps, so simpler to
revise the check in sw_tx_timestamp above to

  if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
-        !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
+      (!(skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)) ||
+      (skb->sk && skb->sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)

> diff --git a/net/socket.c b/net/socket.c
> index 68b9304..14b7688 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>                 empty = 0;
>         if (shhwtstamps &&
>             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> +           (empty || !skb_is_err_queue(skb)) &&
>             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {

I find skb->tstamp == 0 easier to understand than the condition on empty.

Indeed, this is so non-obvious that I would suggest another helper function
skb_is_hwtx_tstamp with a concise comment about the race condition
between tx software and hardware timestamps (as in the last sentence of
the commit message).
