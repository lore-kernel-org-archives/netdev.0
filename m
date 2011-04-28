From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: add RCU protection to inet->opt
Date: Thu, 28 Apr 2011 22:49:19 +0200
Message-ID: <1304023759.2954.8.camel@edumazet-laptop>
References: <1302881994.3613.34.camel@edumazet-laptop>
	 <1303415137.2784.23.camel@edumazet-laptop>
	 <20110428.132032.115947683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43485 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab1D1UtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:49:25 -0400
Received: by wya21 with SMTP id 21so2399893wya.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 13:49:23 -0700 (PDT)
In-Reply-To: <20110428.132032.115947683.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 avril 2011 =C3=A0 13:20 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 21 Apr 2011 21:45:37 +0200
>=20
> > [PATCH] inet: add RCU protection to inet->opt
>=20
> Applied, although I had to add the following build fix to the
> final commit:
>=20
> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
> index cc67367..962a607 100644
> --- a/net/l2tp/l2tp_ip.c
> +++ b/net/l2tp/l2tp_ip.c
> @@ -416,7 +416,6 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, st=
ruct sock *sk, struct msghdr *m
>  	int rc;
>  	struct l2tp_ip_sock *lsa =3D l2tp_ip_sk(sk);
>  	struct inet_sock *inet =3D inet_sk(sk);
> -	struct ip_options *opt =3D inet->opt;
>  	struct rtable *rt =3D NULL;
>  	int connected =3D 0;
>  	__be32 daddr;
> @@ -471,9 +470,14 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, s=
truct sock *sk, struct msghdr *m
>  		rt =3D (struct rtable *) __sk_dst_check(sk, 0);
> =20
>  	if (rt =3D=3D NULL) {
> +		struct ip_options_rcu *inet_opt;
> +
> +		inet_opt =3D rcu_dereference_protected(inet->inet_opt,
> +						     sock_owned_by_user(sk));
> +
>  		/* Use correct destination address if we have options. */
> -		if (opt && opt->srr)
> -			daddr =3D opt->faddr;
> +		if (inet_opt && inet_opt->opt.srr)
> +			daddr =3D inet_opt->opt.faddr;
> =20
>  		/* If this fails, retransmit mechanism of transport layer will
>  		 * keep trying until route appears or the connection times

Gah... I wonder how I missed it.

Are you sure socket is locked at this point ? ( by a priori call to
lock_sock())

Thanks !


