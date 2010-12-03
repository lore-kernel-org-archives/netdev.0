From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unable to handle kernel NULL pointer dereference in skb_dequeue
Date: Fri, 03 Dec 2010 14:09:51 +0100
Message-ID: <1291381791.2897.250.camel@edumazet-laptop>
References: <0fe401cb92e7$85ba2260$912e6720$@si>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, gvs@zemos.net,
	Rami Rosen <ramirose@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Toshio <andrej@ota.si>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0fe401cb92e7$85ba2260$912e6720$@si>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 13:42 +0100, Toshio a =C3=A9cr=
it :
> I have also hit on Bug 20292 (https://bugzilla.kernel.org/show_bug.cg=
i?id=3D20292) in final 2.6.36. After investigating changes made between=
 2.6.35.4, which worked, and 2.6.36 which started oopsing, I think the =
problem was in double freeing of skb caused by change of return value f=
or __pppoe_xmit in case of errors.
>=20
> As it turned out this might be the cause of random BUG reports throug=
ht the kernel, whenever something touched skb. Most common BUG with my =
use case happened at skb_dequeue:
>=20

CC netdev and Rami Rosen

> 00000060 <skb_dequeue>:
>       60:       53                      push   %ebx
>       61:       89 c2                   mov    %eax,%edx
>       63:       9c                      pushf =20
>       64:       59                      pop    %ecx
>       65:       fa                      cli   =20
>       66:       8b 00                   mov    (%eax),%eax
>       68:       39 c2                   cmp    %eax,%edx
>       6a:       74 24                   je     90 <skb_dequeue+0x30>
>       6c:       85 c0                   test   %eax,%eax
>       6e:       74 1a                   je     8a <skb_dequeue+0x2a>
>       70:       ff 4a 08                decl   0x8(%edx)
>       73:       8b 18                   mov    (%eax),%ebx
>       75:       c7 00 00 00 00 00       movl   $0x0,(%eax)
>       7b:       8b 50 04                mov    0x4(%eax),%edx
>       7e:       c7 40 04 00 00 00 00    movl   $0x0,0x4(%eax)
>       85:       89 53 04                mov    %edx,0x4(%ebx)
>       88:*      89 1a                   mov    %ebx,(%edx)
>       8a:       51                      push   %ecx
>       8b:       9d                      popf  =20
>       8c:       5b                      pop    %ebx
>       8d:       c3                      ret   =20
>       8e:       66 90                   xchg   %ax,%ax
>       90:       b8 00 00 00 00          mov    $0x0,%eax
>       95:       eb f3                   jmp    8a <skb_dequeue+0x2a>
>       97:       89 f6                   mov    %esi,%esi
>       99:       8d bc 27 00 00 00 00    lea    0x0(%edi,%eiz,1),%edi
>=20
>=20
> This location corresponds to line "next =3D next->next" from inlined =
__skb_dequeue(). The only reason BUG could happen here is something ove=
rwriting or otherwise corrupting skb list.
>=20
> Patch that works for me is below. Now I only hope I haven't (re)intro=
duced a memory leak...
>=20
> I am not subscribed to LKML, so please reply-to-all if you need to co=
ntact me.
>=20
> ---------------------------------------------------------------------=
--------
> --- linux-2.6.36/drivers/net/pppoe.c    2010-10-20 22:30:22.000000000=
 +0200
> +++ linux-2.6.36.toshio/drivers/net/pppoe.c     2010-12-03 13:11:56.0=
00000000 +0100
> @@ -924,8 +924,10 @@
>         /* Copy the data if there is no space for the header or if it=
's
>          * read-only.
>          */
> -       if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len))
> +       if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len)) {
> +               kfree_skb(skb);
>                 goto abort;
> +       }
> =20
>         __skb_push(skb, sizeof(*ph));
>         skb_reset_network_header(skb);
> @@ -947,7 +949,6 @@
>         return 1;
> =20
>  abort:
> -       kfree_skb(skb);
>         return 0;
>  }
>=20

Problem comes from commit 55c95e738da85 (fix return value of
__pppoe_xmit() method)

I am not sure patch is OK
