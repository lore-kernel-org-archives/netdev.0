From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: reset flowi parameters on route connect
Date: Sun, 05 Feb 2012 00:33:36 +0100
Message-ID: <1328398416.2731.52.camel@edumazet-laptop>
References: <1328396686-15430-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41923 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab2BDXdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 18:33:43 -0500
Received: by wgbdt10 with SMTP id dt10so5006947wgb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 15:33:41 -0800 (PST)
In-Reply-To: <1328396686-15430-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 05 f=C3=A9vrier 2012 =C3=A0 01:04 +0200, Julian Anastasov a=
 =C3=A9crit :
> 	Eric Dumazet found that commit 813b3b5db83
> (ipv4: Use caller's on-stack flowi as-is in output
> route lookups.) that comes in 3.0 added a regression.
> The problem appears to be that resulting flowi4_oif is
> used incorrectly as input parameter to some routing lookups.
> The result is that when connecting to local port without
> listener if the IP address that is used is not on a loopback
> interface we incorrectly assign RTN_UNICAST to the output
> route because no route is matched by oif=3Dlo. The RST packet
> can not be sent immediately by tcp_v4_send_reset because
> it expects RTN_LOCAL.
>=20
> 	So, change ip_route_connect and ip_route_newports to
> update the flowi4 fields that are input parameters because
> we do not want unnecessary binding to oif.
>=20
> 	To make it clear what are the input parameters that
> can be modified during lookup and to show which fields of
> floiw4 are reused add a new function to update the flowi4
> structure: flowi4_update_output.
>=20
> Thanks to Yurij M. Plotnikov for providing a bug report including a
> program to reproduce the problem.
>=20
> Thanks to Eric Dumazet for tracking the problem down to
> tcp_v4_send_reset and providing initial fix.
>=20
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>=20
> 	Eric, please comment and ack this change by signing it.
>=20
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

This seems very good to me, thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
