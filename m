From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next 2/2] ipv6: dont cache cloned routes
Date: Wed, 12 Sep 2012 13:52:44 -0700
Message-ID: <CANP3RGe41V_he=8mARs9FXc+vfrf=N+ipw5YoadiWx5hZuyyrw@mail.gmail.com>
References: <1347451307.13103.885.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:59459 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab2ILUwp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 16:52:45 -0400
Received: by ieje11 with SMTP id e11so3685947iej.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 13:52:45 -0700 (PDT)
In-Reply-To: <1347451307.13103.885.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>

On Wed, Sep 12, 2012 at 5:01 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> We can now destroy cloned routes immediately from dst_release() inste=
ad
> of depending on garbage collection.
>
> Set DST_NOCACHE in rt6_alloc_clone() so that :
>
> 1) we avoid calling ip6_ins_rt() on such routes
>
> 2) dst_release() can call destroy when refcount becomes 0
>
> This allows machines to resist to DDOS.
>
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Tom Herbert <therbert@google.com>
> ---
>  net/ipv6/route.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index d4ba3fc..fedbb41 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -840,6 +840,7 @@ static struct rt6_info *rt6_alloc_clone(struct rt=
6_info *ort,
>         struct rt6_info *rt =3D ip6_rt_copy(ort, daddr);
>
>         if (rt) {
> +               rt->dst.flags |=3D DST_NOCACHE;
>                 rt->rt6i_flags |=3D RTF_CACHE;
>                 rt->n =3D neigh_clone(ort->n);
>         }
> @@ -887,7 +888,7 @@ restart:
>
>         dst_hold(&rt->dst);
>         if (nrt) {
> -               err =3D ip6_ins_rt(nrt);
> +               err =3D (nrt->dst.flags & DST_NOCACHE) ? 0 : ip6_ins_=
rt(nrt);
>                 if (!err)
>                         goto out2;
>         }
>
>
