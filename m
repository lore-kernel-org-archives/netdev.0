From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: code cleanups
Date: Thu, 30 Sep 2010 07:16:48 +0200
Message-ID: <1285823808.5211.627.camel@edumazet-laptop>
References: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33249 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab0I3FQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 01:16:57 -0400
Received: by fxm4 with SMTP id 4so482266fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 22:16:55 -0700 (PDT)
In-Reply-To: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 10:24 +0800, Changli Gao a =C3=A9crit=
 :
> Compare operations are more readable, and compilers generate the same=
 code
> for the both.
>=20

You have a buggy compiler then.

I know this code is ugly, but please keep it as is, dont add conditiona=
l
branches on hot paths.

Thanks

> Use the macros fl4_* to shrink the length of the lines.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/ipv4/af_inet.c |    7 +++----
>  net/ipv4/route.c   |   27 ++++++++++++---------------
>  2 files changed, 15 insertions(+), 19 deletions(-)
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index f581f77..ef26640 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1338,10 +1338,9 @@ static struct sk_buff **inet_gro_receive(struc=
t sk_buff **head,
> =20
>  		iph2 =3D ip_hdr(p);
> =20
> -		if ((iph->protocol ^ iph2->protocol) |
> -		    (iph->tos ^ iph2->tos) |
> -		    ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
> -		    ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
> +		if (iph->protocol !=3D iph2->protocol || iph->tos !=3D iph2->tos |=
|
> +		    (__force u32)iph->saddr !=3D (__force u32)iph2->saddr ||
> +		    (__force u32)iph->daddr !=3D (__force u32)iph2->daddr) {
>  			NAPI_GRO_CB(p)->same_flow =3D 0;
>  			continue;
>  		}
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 98beda4..6b00fde 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -683,19 +683,18 @@ static inline bool rt_caching(const struct net =
*net)
>  static inline bool compare_hash_inputs(const struct flowi *fl1,
>  					const struct flowi *fl2)
>  {
> -	return ((((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl=
_u.ip4_u.daddr) |
> -		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u=
=2Esaddr) |
> -		(fl1->iif ^ fl2->iif)) =3D=3D 0);
> +	return (__force u32)fl1->fl4_dst =3D=3D (__force u32)fl2->fl4_dst &=
&
> +	       (__force u32)fl1->fl4_src =3D=3D (__force u32)fl2->fl4_src &=
&
> +	       fl1->iif =3D=3D fl2->iif;
>  }
> =20
>  static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
>  {
> -	return (((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_=
u.ip4_u.daddr) |
> -		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u=
=2Esaddr) |
> -		(fl1->mark ^ fl2->mark) |
> -		(*(u16 *)&fl1->nl_u.ip4_u.tos ^ *(u16 *)&fl2->nl_u.ip4_u.tos) |
> -		(fl1->oif ^ fl2->oif) |
> -		(fl1->iif ^ fl2->iif)) =3D=3D 0;
> +	return (__force u32)fl1->fl4_dst =3D=3D (__force u32)fl2->fl4_dst &=
&
> +	       (__force u32)fl1->fl4_src =3D=3D (__force u32)fl2->fl4_src &=
&
> +	       fl1->mark =3D=3D fl2->mark &&
> +	       *(u16 *)&fl1->fl4_tos =3D=3D *(u16 *)&fl2->fl4_tos &&
> +	       fl1->oif =3D=3D fl2->oif && fl1->iif =3D=3D fl2->iif;
>  }
> =20
>  static inline int compare_netns(struct rtable *rt1, struct rtable *r=
t2)
> @@ -2286,12 +2285,10 @@ int ip_route_input_common(struct sk_buff *skb=
, __be32 daddr, __be32 saddr,
> =20
>  	for (rth =3D rcu_dereference(rt_hash_table[hash].chain); rth;
>  	     rth =3D rcu_dereference(rth->dst.rt_next)) {
> -		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
> -		     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr) |
> -		     (rth->fl.iif ^ iif) |
> -		     rth->fl.oif |
> -		     (rth->fl.fl4_tos ^ tos)) =3D=3D 0 &&
> -		    rth->fl.mark =3D=3D skb->mark &&
> +		if ((__force u32)rth->fl.fl4_dst =3D=3D (__force u32)daddr &&
> +		    (__force u32)rth->fl.fl4_src =3D=3D (__force u32)saddr &&
> +		    rth->fl.iif =3D=3D iif && rth->fl.oif =3D=3D 0 &&
> +		    rth->fl.fl4_tos =3D=3D tos && rth->fl.mark =3D=3D skb->mark &&
>  		    net_eq(dev_net(rth->dst.dev), net) &&
>  		    !rt_is_expired(rth)) {
>  			if (noref) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


