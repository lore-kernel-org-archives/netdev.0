From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: net: Fix skb_set_peeked use-after-free bug
Date: Tue, 4 Aug 2015 08:30:23 -0700
Message-ID: <CAMUH3-Uu4FH1hkMYeLb8BTRDPEC3WPhb7hksn9-FPfEy_2dBJg@mail.gmail.com>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
 <20150804074247.GA29951@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	khlebnikov@yandex-team.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:35044 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbHDPan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 11:30:43 -0400
Received: by ykcq64 with SMTP id q64so5933541ykc.2
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 08:30:43 -0700 (PDT)
In-Reply-To: <20150804074247.GA29951@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The commit 738ac1ebb96d02e0d23bc320302a6ea94c612dec ("net: Clone
> skb before setting peeked flag") introduced a use-after-free bug
> in skb_recv_datagram.  This is because skb_set_peeked may create
> a new skb and free the existing one.  As it stands the caller will
> continue to use the old freed skb.
>
> This patch fixes it by making skb_set_peeked return the new skb
> (or the old one if unchanged).
>
> Fixes: 738ac1ebb96d ("net: Clone skb before setting peeked flag")
> Reported-by: Brenden Blanco <bblanco@plumgrid.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 4967262..617088a 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -131,12 +131,12 @@ out_noerr:
>         goto out;
>  }
>
> -static int skb_set_peeked(struct sk_buff *skb)
> +static struct sk_buff *skb_set_peeked(struct sk_buff *skb)
>  {
>         struct sk_buff *nskb;
>
>         if (skb->peeked)
> -               return 0;
> +               return skb;
>
>         /* We have to unshare an skb before modifying it. */
>         if (!skb_shared(skb))
> @@ -144,7 +144,7 @@ static int skb_set_peeked(struct sk_buff *skb)
>
>         nskb = skb_clone(skb, GFP_ATOMIC);
>         if (!nskb)
> -               return -ENOMEM;
> +               return ERR_PTR(-ENOMEM);
>
>         skb->prev->next = nskb;
>         skb->next->prev = nskb;
> @@ -157,7 +157,7 @@ static int skb_set_peeked(struct sk_buff *skb)
>  done:
>         skb->peeked = 1;
>
> -       return 0;
> +       return skb;
>  }
>
>  /**
> @@ -229,8 +229,9 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>                                         continue;
>                                 }
>
> -                               error = skb_set_peeked(skb);
> -                               if (error)
> +                               skb = skb_set_peeked(skb);
> +                               error = PTR_ERR(skb);
> +                               if (IS_ERR(skb))
>                                         goto unlock_err;
>
>                                 atomic_inc(&skb->users);

This patch holds good in my testing. Thanks!
