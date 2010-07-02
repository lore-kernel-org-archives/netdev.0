From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xfrm bugs with mark logic
Date: Fri, 02 Jul 2010 17:01:38 +0200
Message-ID: <1278082898.2530.37.camel@edumazet-laptop>
References: <AANLkTimsVHoNk3B1oTI6awlNtrmNED7vwe2flzTap9aP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter Kosyh <p.kosyh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65314 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758763Ab0GBPBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 11:01:43 -0400
Received: by fxm14 with SMTP id 14so2449740fxm.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 08:01:42 -0700 (PDT)
In-Reply-To: <AANLkTimsVHoNk3B1oTI6awlNtrmNED7vwe2flzTap9aP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 juillet 2010 =C3=A0 14:40 +0400, Peter Kosyh a =C3=A9cri=
t :
> Hello! I am currently working with 2.6.34, trying to use iptables ...
> -j MARK with XFRM policy. So, i found at least
> two bugs in 2.6.34 kernel.
>=20
> First bug is just typo in  xfrm_mark_get (net/xfrm.h):
>=20
> memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
>=20
> must be:
>=20
> memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(*m));
>=20
> The second one, is clearing mark in flowi structure via memset in
> _decode_session4 (net/ipv4/xfrm4_policy.c).
> (see net/ipv4/netfilter.c, ip_route_me_harder function)
> int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
> /* ... */
>         if (addr_type =3D=3D RTN_LOCAL) {
> /* ... */
>                 fl.mark =3D skb->mark; /* here, set mark from skb */
> /* ... */
> #ifdef CONFIG_XFRM
>         if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
>             xfrm_decode_session(skb, &fl, AF_INET) =3D=3D 0) { /* her=
e
> fl->mark will be zeroed */
>             /* ... */
>             if (xfrm_lookup(net, &dst, &fl, skb->sk, 0)) /* here
> policy lookup will fail */
>=20
> Do not know about ipv6 anything, but it's like that it affected by
> this bug too. :(
>=20
> P.S. Sorry for my bad English. :)
>=20
> w.b.r. Peter Kosyh
>=20
> diff -Nur linux-2.6.34/include/net/xfrm.h linux-2.6.34.fix/include/ne=
t/xfrm.h
> --- linux-2.6.34/include/net/xfrm.h	2010-05-16 21:17:36.000000000 +00=
00
> +++ linux-2.6.34.fix/include/net/xfrm.h	2010-07-02 10:05:33.000000000=
 +0000
> @@ -1587,7 +1587,7 @@
>  static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_m=
ark *m)
>  {
>  	if (attrs[XFRMA_MARK])
> -		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(m));
> +		memcpy(m, nla_data(attrs[XFRMA_MARK]), sizeof(*m));
>  	else
>  		m->v =3D m->m =3D 0;
> diff -Nur linux-2.6.34/net/ipv4/xfrm4_policy.c
> linux-2.6.34.fix/net/ipv4/xfrm4_policy.c
> --- linux-2.6.34/net/ipv4/xfrm4_policy.c	2010-05-16 21:17:36.00000000=
0 +0000
> +++ linux-2.6.34.fix/net/ipv4/xfrm4_policy.c	2010-07-02 10:17:51.0000=
00000 +0000
> @@ -186,6 +186,7 @@
>  	fl->fl4_dst =3D reverse ? iph->saddr : iph->daddr;
>  	fl->fl4_src =3D reverse ? iph->daddr : iph->saddr;
>  	fl->fl4_tos =3D iph->tos;
> +	fl->mark =3D skb->mark;
>  }
>=20
>  static inline int xfrm4_garbage_collect(struct dst_ops *ops)
> --

Hi Peter

XFRMA_MARK part already in net-2.6 tree :

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
t;h=3D4efd7e833591721bec21cc4730a7f6261417840f

Please submit another patch the second problem you spotted ?




