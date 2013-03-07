From: snakky.zhang@gmail.com
Subject: Re: kernel panic in fib6_age (linux-3.6.6) and sugguested fix
Date: Thu, 07 Mar 2013 10:28:28 +0800
Message-ID: <5137FB4C.60006@gmail.com>
References: <CAABZP2xs4qm7j75Hu5BaXuWOF3ddzrZPJxbTGhxpOvwHxA75Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:63768 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363Ab3CGC2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 21:28:37 -0500
Received: by mail-bk0-f42.google.com with SMTP id jk7so551670bkc.15
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 18:28:36 -0800 (PST)
In-Reply-To: <CAABZP2xs4qm7j75Hu5BaXuWOF3ddzrZPJxbTGhxpOvwHxA75Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B403=E6=9C=8806=E6=97=A5 23:36, Zhouyi Zhou wrote:
> hi,
>    My linux-3.6.6 kernel panics very often during reboot.
>    I have reported in bugzilla.kernel.org as bug id 54731.
>
> Kernel panic backtrace (using remote gdb):
> #0  0xffffffff8176a91a in fib6_age (rt=3D0xffff8800571c6780, arg=3D0x=
0
> <irq_stack_union>) at net/ipv6/ip6_fib.c:1566
> #1  0xffffffff8176a461 in fib6_clean_node (w=3D0xffff8800655fb4e8) at
> net/ipv6/ip6_fib.c:1422
> #2  0xffffffff8176a266 in fib6_walk_continue (w=3D0xffff8800655fb4e8)=
 at
> net/ipv6/ip6_fib.c:1362
> #3  0xffffffff8176a3d5 in fib6_walk (w=3D0xffff8800655fb4e8) at
> net/ipv6/ip6_fib.c:1406
> #4  0xffffffff8176a59d in fib6_clean_tree (net=3D0xffffffff81edb300 <=
init_net>,
> root=3D0xffff880036c41950
> ...
> gdb>p neigh
> (gdb) p neigh
> $18 =3D (struct neighbour *) 0xffffffffffffff97
>
>
>
> There are a lot of ipv6 nodes in my link local environment, and the k=
ernel
> report IPv6: Neighbour table overflow constantly.
>
> I guess the cause of the panic is:
> dst_neigh_lookup calls ip6_neigh_lookup indirectly, and neigh_create =
return
> ENOBUFS in case of neighbour table full.
> 139 static struct neighbour *ip6_neigh_lookup(const struct dst_entry =
*dst,
> 140                                           struct sk_buff *skb,
> 141                                           const void *daddr)
> 142 {
> 143         struct rt6_info *rt =3D (struct rt6_info *) dst;
> 144         struct neighbour *n;
> 145
> 146         daddr =3D choose_neigh_daddr(rt, skb, daddr);
> 147         n =3D __ipv6_neigh_lookup(&nd_tbl, dst->dev, daddr);
> 148         if (n)
> 149                 return n;
> 150         return neigh_create(&nd_tbl, daddr, dst->dev);
> 151 }
>
> A possible fix may be:
>
>              neigh =3D dst_neigh_lookup(&rt->dst, &rt->rt6i_gateway);
> +           if (IS_ERR(neigh))
> +             return PTR_ERR(neigh);
>              else{
>                       neigh_flags =3D neigh->flags;
>                       neigh_release(neigh);
>              }
>
How about this one below? without modifying the return value:
                         __u8 neigh_flags =3D 0;

                         neigh =3D dst_neigh_lookup(&rt->dst,=20
&rt->rt6i_gateway);
-                       if (neigh) {
+                       if (!IS_ERR(neigh)) {
                                 neigh_flags =3D neigh->flags;
                                 neigh_release(neigh);
                         }


Thanks
Xiao


> Thanks for your attention
>
> Zhouyi
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
