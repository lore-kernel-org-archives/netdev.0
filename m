From: Wang Xingtong <wangxingtong@cn.fujitsu.com>
Subject: Re: [PATCH] IPv6 : add multicast routing verify which net_device
 is lo
Date: Tue, 20 Dec 2011 17:47:31 +0800
Message-ID: <4EF059B3.1020705@cn.fujitsu.com>
References: <4EF0279A.30800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63001 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab1LTJsh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 04:48:37 -0500
In-Reply-To: <4EF0279A.30800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Xingtong =E5=86=99=E9=81=93:
> In currently routing subsystem, when we lookup a multicast routing
> to send muticast packets to outside, rt6_device_match will return
> the rt6_info which it's match first. if we add a multicast route on
> loopback devices beforce the others interface, rt6_device_match will
> retrun the rt6_info which rt6i_dev->name is "lo". But, obviously,
> we can't send a muticast packet to outside using loopback devices.
> It case all multicast packets blocking.
>=20
> Commit 4af04aba93f47699e disabled kernel add multicast route on lo
> automatically. However,  we can't surmise the routing-add order or
> interdict add multicast routing on loopback devices in user space.
> The bug still exist. So, i think more stronger routing subsystem is
> necessary.

sorry, the patch has some problem , i will send V2 later.

>=20
> Signed-off-by: Wang xingtong <wangxingtong@cn.fujitsu.com>
>=20
> ---
>  net/ipv6/route.c |   19 ++++++++++++++++---
>  1 files changed, 16 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index b582a0a..3871ef4 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -334,9 +334,16 @@ static inline struct rt6_info=20
> *rt6_device_match(struct net *net,
>      struct rt6_info *local =3D NULL;
>      struct rt6_info *sprt;
>=20
> -    if (!oif && ipv6_addr_any(saddr))
> +    if (!oif && ipv6_addr_any(saddr)){
> +        if (unlikely(rt->rt6i_dev->flags & IFF_LOOPBACK &&
> +            ipv6_addr_is_multicast(&rt->rt6i_dst.addr))){
> +            rt=3Drt->dst.rt6_next;
> +            goto match;
> +        }
>          goto out;
> +    }
>=20
> +match:
>      for (sprt =3D rt; sprt; sprt =3D sprt->dst.rt6_next) {
>          struct net_device *dev =3D sprt->rt6i_dev;
>=20
> @@ -355,9 +362,15 @@ static inline struct rt6_info=20
> *rt6_device_match(struct net *net,
>                  local =3D sprt;
>              }
>          } else {
> -            if (ipv6_chk_addr(net, saddr, dev,
> -                      flags & RT6_LOOKUP_F_IFACE))
> +            if (ipv6_addr_any(saddr)){
> +                if (unlikely(rt->rt6i_dev->flags & IFF_LOOPBACK &&
> +                    ipv6_addr_is_multicast(&rt->rt6i_dst.addr))){
> +                    continue;
>                  return sprt;
> +            }
> +            else if (ipv6_chk_addr(net, saddr, dev,
> +                      flags & RT6_LOOKUP_F_IFACE))
> +                    return sprt;
>          }
>      }
>=20
