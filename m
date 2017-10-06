From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 11/16] ipv6: replace dst_hold() with
 dst_hold_safe() in routing code
Date: Sat, 7 Oct 2017 08:57:49 +0900
Message-ID: <CAPA1RqB14m4BERjrOO5Fryu2WAU9iwqAbC8H7Sb_bNUi9jfLAg@mail.gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com> <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com> <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com> <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com> <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com> <20171006190611.110633-10-tracywwnj@gmail.com>
 <20171006190611.110633-11-tracywwnj@gmail.com> <20171006190611.110633-12-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:55917 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbdJFX6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:58:11 -0400
Received: by mail-it0-f44.google.com with SMTP id p185so7151102itc.4
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 16:58:11 -0700 (PDT)
In-Reply-To: <20171006190611.110633-12-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2017-10-07 4:06 GMT+09:00 Wei Wang <weiwan@google.com>:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 941c062389d2..aeb349aea429 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
:
> @@ -1625,12 +1643,17 @@ struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
>         if (rt_cache)
>                 rt = rt_cache;
>
> -       if (rt == net->ipv6.ip6_null_entry || (rt->rt6i_flags & RTF_CACHE)) {
> -               dst_use(&rt->dst, jiffies);
> +       if (rt == net->ipv6.ip6_null_entry) {
> +               read_unlock_bh(&table->tb6_lock);
> +               dst_hold(&rt->dst);
> +               trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
> +               return rt;
> +       } else if (rt->rt6i_flags & RTF_CACHE) {
> +               if (ip6_hold_safe(net, &rt, true)) {
> +                       dst_use_noref(&rt->dst, jiffies);
> +                       rt6_dst_from_metrics_check(rt);
> +               }
>                 read_unlock_bh(&table->tb6_lock);
> -
> -               rt6_dst_from_metrics_check(rt);
> -
>                 trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
>                 return rt;
>         } else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&

Is it intended to move rt6_dst_from_metrics_check() inside the table lock?

--yoshfuji
