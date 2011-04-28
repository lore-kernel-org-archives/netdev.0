From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: add RCU protection to inet->opt
Date: Thu, 28 Apr 2011 22:55:36 +0200
Message-ID: <1304024136.2954.9.camel@edumazet-laptop>
References: <1303415137.2784.23.camel@edumazet-laptop>
	 <20110428.132032.115947683.davem@davemloft.net>
	 <1304023759.2954.8.camel@edumazet-laptop>
	 <20110428.135226.242113407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41876 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789Ab1D1Uzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 16:55:41 -0400
Received: by wya21 with SMTP id 21so2403797wya.19
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 13:55:39 -0700 (PDT)
In-Reply-To: <20110428.135226.242113407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 avril 2011 =C3=A0 13:52 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 28 Apr 2011 22:49:19 +0200
>=20
> > Are you sure socket is locked at this point ? ( by a priori call to
> > lock_sock())
>=20
> Ugh, it's not, I'll commit this fix which is safe because we're only
> peeking at inet_opt to fetch the faddr value then we never reference
> it again:
>=20
> diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
> index 962a607..e13c166 100644
> --- a/net/l2tp/l2tp_ip.c
> +++ b/net/l2tp/l2tp_ip.c
> @@ -472,13 +472,15 @@ static int l2tp_ip_sendmsg(struct kiocb *iocb, =
struct sock *sk, struct msghdr *m
>  	if (rt =3D=3D NULL) {
>  		struct ip_options_rcu *inet_opt;
> =20
> -		inet_opt =3D rcu_dereference_protected(inet->inet_opt,
> -						     sock_owned_by_user(sk));
> +		rcu_read_lock();
> +		inet_opt =3D rcu_dereference(inet->inet_opt);
> =20
>  		/* Use correct destination address if we have options. */
>  		if (inet_opt && inet_opt->opt.srr)
>  			daddr =3D inet_opt->opt.faddr;
> =20
> +		rcu_read_unlock();
> +
>  		/* If this fails, retransmit mechanism of transport layer will
>  		 * keep trying until route appears or the connection times
>  		 * itself out.


Thats perfect, thanks !


