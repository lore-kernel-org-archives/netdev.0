From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: Add skb_unclone() helper function.
Date: Fri, 25 Jan 2013 02:21:06 +0100
Message-ID: <CAHXqBF+uHoGRXP3HdiL2Zm9RUhT-+7RsrRhAYZyEg-FjzH2-eQ@mail.gmail.com>
References: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse@nicira.com, eric.dumazet@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:43232 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab3AYBV1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 20:21:27 -0500
Received: by mail-oa0-f47.google.com with SMTP id h1so10727885oag.6
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 17:21:26 -0800 (PST)
In-Reply-To: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/24 Pravin B Shelar <pshelar@nicira.com>:
[...]
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -798,6 +798,19 @@ static inline int skb_cloned(const struct sk_buf=
f *skb)
>  }
>
>  /**
> + *     skb_unclone - creates separate copy if skb is cloned.
> + */
> +static inline bool skb_unclone(struct sk_buff *skb, gfp_t pri)
> +{
> +       might_sleep_if(pri & __GFP_WAIT);
> +
> +       if (skb_cloned(skb))
> +               return pskb_expand_head(skb, 0, 0, pri);
> +
> +       return 0;
> +}

This should return int. pskb_expand_head() returns 0 or -ENOMEM.

[...]
> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunne=
l.c
> index ddee0a0..c1f00ef 100644
> --- a/net/ipv4/xfrm4_mode_tunnel.c
> +++ b/net/ipv4/xfrm4_mode_tunnel.c
> @@ -142,8 +142,7 @@ static int xfrm4_mode_tunnel_input(struct xfrm_st=
ate *x, struct sk_buff *skb)
>         for_each_input_rcu(rcv_notify_handlers, handler)
>                 handler->handler(skb);
>
> -       if (skb_cloned(skb) &&
> -           (err =3D pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
> +       if (skb_unclone(skb, GFP_ATOMIC))
>                 goto out;

And here return -ENOMEM is replaced with return -EINVAL because of this=
=2E

Best Regards,
Micha=C5=82 Miros=C5=82aw
