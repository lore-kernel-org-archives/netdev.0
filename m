From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 04 Feb 2012 20:43:50 +0100
Message-ID: <1328384630.2731.46.camel@edumazet-laptop>
References: <4F2B7DF1.5050303@oktetlabs.ru>
	   <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1328358402.2731.11.camel@edumazet-laptop>
	  <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
	 <1328374715.2731.21.camel@edumazet-laptop>
	 <alpine.LFD.2.00.1202041912430.1496@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34778 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210Ab2BDTn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 14:43:56 -0500
Received: by werb13 with SMTP id b13so3449277wer.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 11:43:54 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1202041912430.1496@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 19:39 +0200, Julian Anastasov a =C3=
=A9crit :

> [PATCH] ipv4: reset flowi parameters on route connect
>=20
> 	ip_route_connect and ip_route_newports need to reset
> some flowi fields that are input parameters because we do not
> want unnecessary binding to oif. Fixes problem with lost
> RST packets when connecting to local port that has no
> listener.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Please Julian, dont submit an official patch like this without proper
credits, and proper reference to bug origin, to help stable backport.

Issue was reported by Yurij, and I spent some time on it to find the
problem, introduced in 3.0.


> ---
>  include/net/flow.h  |   10 ++++++++++
>  include/net/route.h |    4 ++++
>  2 files changed, 14 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/net/flow.h b/include/net/flow.h
> index 9b58243..6c469db 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -93,6 +93,16 @@ static inline void flowi4_init_output(struct flowi=
4 *fl4, int oif,
>  	fl4->fl4_dport =3D dport;
>  	fl4->fl4_sport =3D sport;
>  }
> +
> +/* Reset some input parameters after previous lookup */
> +static inline void flowi4_update_output(struct flowi4 *fl4, int oif,=
 __u8 tos,
> +					__be32 daddr, __be32 saddr)
> +{
> +	fl4->flowi4_oif =3D oif;
> +	fl4->flowi4_tos =3D tos;
> +	fl4->daddr =3D daddr;
> +	fl4->saddr =3D saddr;

> +}
>  				     =20


> =20
>  struct flowi6 {
> diff --git a/include/net/route.h b/include/net/route.h
> index 91855d1..b1c0d5b 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -270,6 +270,7 @@ static inline struct rtable *ip_route_connect(str=
uct flowi4 *fl4,
>  		if (IS_ERR(rt))
>  			return rt;
>  		ip_rt_put(rt);
> +		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
>  	}
>  	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
>  	return ip_route_output_flow(net, fl4, sk);
> @@ -284,6 +285,9 @@ static inline struct rtable *ip_route_newports(st=
ruct flowi4 *fl4, struct rtable
>  		fl4->fl4_dport =3D dport;
>  		fl4->fl4_sport =3D sport;
>  		ip_rt_put(rt);
> +		flowi4_update_output(fl4, sk->sk_bound_dev_if,
> +				     RT_CONN_FLAGS(sk), fl4->daddr,
> +				     fl4->saddr);
>  		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
>  		return ip_route_output_flow(sock_net(sk), fl4, sk);
>  	}

I dont understand the saddr/daddr part, since you basically have :

	fl4->daddr =3D fl4->daddr;
	fl4->saddr =3D fl4->saddr;


__ip_route_output_key() always had the possibility to change
saddr/daddr, I dont think we have to deal with it.
